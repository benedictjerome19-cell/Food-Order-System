package com.yourname.yournameeats.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import com.yourname.yournameeats.listener.AppContextListener;
import com.yourname.yournameeats.model.Restaurant;

public class RestaurantDAOImpl implements RestaurantDAO {

    @Override
    public Optional<Restaurant> findByOwnerId(int ownerId) {
        return runSingleQuery("SELECT * FROM restaurants WHERE owner_id = ?", ownerId);
    }

    @Override
    public Optional<Restaurant> findById(int id) {
        return runSingleQuery("SELECT * FROM restaurants WHERE id = ?", id);
    }

    private Optional<Restaurant> runSingleQuery(String sql, int param) {
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, param);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? Optional.of(mapRow(rs)) : Optional.empty();
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to find restaurant", e);
        }
    }

    @Override
    public List<Restaurant> findAll() {
        String sql = "SELECT * FROM restaurants ORDER BY id";
        List<Restaurant> results = new ArrayList<>();
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) results.add(mapRow(rs));
            return results;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to fetch restaurants", e);
        }
    }

    @Override
    public Restaurant create(Restaurant restaurant) {
        String sql = "INSERT INTO restaurants (owner_id, name, cuisine_type, address) VALUES (?, ?, ?, ?)";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, restaurant.getOwnerId());
            stmt.setString(2, restaurant.getName());
            stmt.setString(3, restaurant.getCuisineType());
            stmt.setString(4, restaurant.getAddress());
            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) restaurant.setId(rs.getInt(1));
            }
            return restaurant;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to create restaurant", e);
        }
    }

    private Restaurant mapRow(ResultSet rs) throws SQLException {
        Restaurant r = new Restaurant();
        r.setId(rs.getInt("id"));
        r.setOwnerId(rs.getInt("owner_id"));
        r.setName(rs.getString("name"));
        r.setCuisineType(rs.getString("cuisine_type"));
        r.setAddress(rs.getString("address"));
        Timestamp ts = rs.getTimestamp("created_at"); // was missing before — findByOwnerId never set this
        if (ts != null) r.setCreatedAt(ts.toLocalDateTime());
        return r;
    }
}
