package com.yourname.yournameeats.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.yourname.yournameeats.listener.AppContextListener;
import com.yourname.yournameeats.model.Review;

public class ReviewDAOImpl implements ReviewDAO {

    @Override
    public Review upsert(int restaurantId, int userId, int rating, String comment) {
        String checkSql = "SELECT id FROM reviews WHERE restaurant_id = ? AND user_id = ?";
        String updateSql = "UPDATE reviews SET rating = ?, comment = ?, created_at = CURRENT_TIMESTAMP WHERE id = ?";
        String insertSql = "INSERT INTO reviews (restaurant_id, user_id, rating, comment) VALUES (?, ?, ?, ?)";

        try (Connection conn = AppContextListener.getDataSource().getConnection()) {

            Integer existingId = null;
            try (PreparedStatement check = conn.prepareStatement(checkSql)) {
                check.setInt(1, restaurantId);
                check.setInt(2, userId);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next()) existingId = rs.getInt("id");
                }
            }

            int reviewId;
            if (existingId != null) {
                try (PreparedStatement update = conn.prepareStatement(updateSql)) {
                    update.setInt(1, rating);
                    update.setString(2, comment);
                    update.setInt(3, existingId);
                    update.executeUpdate();
                }
                reviewId = existingId;
            } else {
                try (PreparedStatement insert = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                    insert.setInt(1, restaurantId);
                    insert.setInt(2, userId);
                    insert.setInt(3, rating);
                    insert.setString(4, comment);
                    insert.executeUpdate();
                    try (ResultSet rs = insert.getGeneratedKeys()) {
                        rs.next();
                        reviewId = rs.getInt(1);
                    }
                }
            }

            Review review = new Review();
            review.setId(reviewId);
            review.setRestaurantId(restaurantId);
            review.setUserId(userId);
            review.setRating(rating);
            review.setComment(comment);
            return review;

        } catch (SQLException e) {
            throw new RuntimeException("Failed to save review", e);
        }
    }

    @Override
    public List<Review> findByRestaurantId(int restaurantId) {
        String sql = "SELECT * FROM reviews WHERE restaurant_id = ? ORDER BY created_at DESC";
        List<Review> results = new ArrayList<>();
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, restaurantId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review();
                    r.setId(rs.getInt("id"));
                    r.setRestaurantId(rs.getInt("restaurant_id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setRating(rs.getInt("rating"));
                    r.setComment(rs.getString("comment"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) r.setCreatedAt(ts.toLocalDateTime());
                    results.add(r);
                }
            }
            return results;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to fetch reviews", e);
        }
    }

    @Override
    public double findAverageRating(int restaurantId) {
        String sql = "SELECT AVG(rating) AS avg_rating FROM reviews WHERE restaurant_id = ?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, restaurantId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    double avg = rs.getDouble("avg_rating");
                    return rs.wasNull() ? 0.0 : avg;
                }
                return 0.0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to compute average rating", e);
        }
    }
}
