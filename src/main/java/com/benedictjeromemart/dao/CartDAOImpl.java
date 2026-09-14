package com.benedictjeromemart.dao;

import com.benedictjeromemart.listener.AppContextListener;
import com.benedictjeromemart.model.CartItem;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAOImpl implements CartDAO {

    @Override
    public void addOrUpdate(int userId, int menuItemId, int quantity) {
        String checkSql = "SELECT id FROM cart_items WHERE user_id = ? AND menu_item_id = ?";
        String updateSql = "UPDATE cart_items SET quantity = ? WHERE id = ?";
        String insertSql = "INSERT INTO cart_items (user_id, menu_item_id, quantity) VALUES (?, ?, ?)";

        try (Connection conn = AppContextListener.getDataSource().getConnection()) {

            try (PreparedStatement check = conn.prepareStatement(checkSql)) {
                check.setInt(1, userId);
                check.setInt(2, menuItemId);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next()) {
                        int cartItemId = rs.getInt("id");
                        try (PreparedStatement update = conn.prepareStatement(updateSql)) {
                            update.setInt(1, quantity);
                            update.setInt(2, cartItemId);
                            update.executeUpdate();
                        }
                        return;
                    }
                }
            }

            try (PreparedStatement insert = conn.prepareStatement(insertSql)) {
                insert.setInt(1, userId);
                insert.setInt(2, menuItemId);
                insert.setInt(3, quantity);
                insert.executeUpdate();
            }

        } catch (SQLException e) {
            throw new RuntimeException("Failed to add/update cart item", e);
        }
    }

    @Override
    public void remove(int userId, int menuItemId) {
        String sql = "DELETE FROM cart_items WHERE user_id = ? AND menu_item_id = ?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, menuItemId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to remove cart item", e);
        }
    }

    @Override
    public List<CartItem> findByUser(int userId) {
        String sql = "SELECT * FROM cart_items WHERE user_id = ?";
        List<CartItem> results = new ArrayList<>();
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setId(rs.getInt("id"));
                    item.setUserId(rs.getInt("user_id"));
                    item.setMenuItemId(rs.getInt("menu_item_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    results.add(item);
                }
            }
            return results;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to fetch cart", e);
        }
    }

    @Override
    public void clearCart(int userId) {
        String sql = "DELETE FROM cart_items WHERE user_id = ?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to clear cart", e);
        }
    }
}
