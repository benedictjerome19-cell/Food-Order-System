package com.benedictjeromemart.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.benedictjeromemart.listener.AppContextListener;
import com.benedictjeromemart.model.MenuItem;

public class MenuItemDAOImpl implements MenuItemDAO {

    @Override
    public List<MenuItem> search(String keyword, String category) {
        StringBuilder sql = new StringBuilder("SELECT * FROM menu_items WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND LOWER(name) LIKE ?");
            params.add("%" + keyword.toLowerCase() + "%");
        }
        if (category != null && !category.isBlank()) {
            sql.append(" AND category = ?");
            params.add(category);
        }

        List<MenuItem> results = new ArrayList<>();
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) results.add(mapRow(rs));
            }
            return results;

        } catch (SQLException e) {
            throw new RuntimeException("Failed to search menu items", e);
        }
    }

    @Override
    public MenuItem findById(int id) {
        String sql = "SELECT * FROM menu_items WHERE id = ?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to find menu item", e);
        }
    }

    @Override
    public List<MenuItem> findByRestaurantId(int restaurantId) {
        String sql = "SELECT * FROM menu_items WHERE restaurant_id = ? ORDER BY id DESC";
        List<MenuItem> results = new ArrayList<>();
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, restaurantId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) results.add(mapRow(rs));
            }
            return results;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to find menu items by restaurant", e);
        }
    }

    @Override
    public MenuItem create(MenuItem item) {
        String sql = "INSERT INTO menu_items (restaurant_id, name, description, price, stock_qty, category, image_url, is_available) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, TRUE)";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, item.getRestaurantId());
            stmt.setString(2, item.getName());
            stmt.setString(3, item.getDescription());
            stmt.setBigDecimal(4, item.getPrice());
            stmt.setInt(5, item.getStockQty());
            stmt.setString(6, item.getCategory());
            stmt.setString(7, item.getImageUrl());
            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) item.setId(rs.getInt(1));
            }
            return item;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to create menu item", e);
        }
    }

    @Override
    public void update(MenuItem item) {
        String sql = "UPDATE menu_items SET name=?, description=?, price=?, stock_qty=?, category=?, image_url=? " +
                     "WHERE id=? AND restaurant_id=?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, item.getName());
            stmt.setString(2, item.getDescription());
            stmt.setBigDecimal(3, item.getPrice());
            stmt.setInt(4, item.getStockQty());
            stmt.setString(5, item.getCategory());
            stmt.setString(6, item.getImageUrl());
            stmt.setInt(7, item.getId());
            stmt.setInt(8, item.getRestaurantId());
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to update menu item", e);
        }
    }

    @Override
    public void delete(int id, int restaurantId) {
        String sql = "DELETE FROM menu_items WHERE id = ? AND restaurant_id = ?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.setInt(2, restaurantId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to delete menu item", e);
        }
    }

    @Override
    public void deleteById(int id) {
        String sql = "DELETE FROM menu_items WHERE id = ?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to delete menu item", e);
        }
    }

    @Override
    public boolean updatePriceByName(String namePattern, double newPrice) {
        String sql = "UPDATE menu_items SET price = ? WHERE LOWER(name) LIKE ?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBigDecimal(1, java.math.BigDecimal.valueOf(newPrice));
            stmt.setString(2, "%" + namePattern.toLowerCase().trim() + "%");
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to update price by name", e);
        }
    }

    @Override
    public boolean updateStockByName(String namePattern, int newStock) {
        String sql = "UPDATE menu_items SET stock_qty = ? WHERE LOWER(name) LIKE ?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, newStock);
            stmt.setString(2, "%" + namePattern.toLowerCase().trim() + "%");
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to update stock by name", e);
        }
    }

    @Override
    public boolean updateAvailabilityByName(String namePattern, boolean available) {
        // FIXED: Changed column from 'available' to 'is_available' to match the database schema
        String sql = "UPDATE menu_items SET is_available = ? WHERE LOWER(name) LIKE ?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBoolean(1, available);
            stmt.setString(2, "%" + namePattern.toLowerCase().trim() + "%");
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to update availability by name", e);
        }
    }

    private MenuItem mapRow(ResultSet rs) throws SQLException {
        MenuItem item = new MenuItem();
        item.setId(rs.getInt("id"));
        item.setRestaurantId(rs.getInt("restaurant_id"));
        item.setName(rs.getString("name"));
        item.setDescription(rs.getString("description"));
        item.setPrice(rs.getBigDecimal("price"));
        item.setStockQty(rs.getInt("stock_qty"));
        item.setCategory(rs.getString("category"));
        item.setImageUrl(rs.getString("image_url"));
        return item;
    }
}