package com.benedictjeromemart.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.benedictjeromemart.listener.AppContextListener;
import com.benedictjeromemart.model.CartItem;
import com.benedictjeromemart.model.OrderItemDetail;
import com.benedictjeromemart.model.OrderSummary;

public class OrderDAOImpl implements OrderDAO {

    @Override
    public int placeOrder(int buyerId, int restaurantId, List<CartItem> cartItems, BigDecimal total,
                          String deliveryAddress, String customerPhone, String paymentMethod, String transactionId) {
        String insertOrderSql =
            "INSERT INTO orders (buyer_id, restaurant_id, status, total_amount, delivery_address, customer_phone, payment_method, payment_status, transaction_id) " +
            "VALUES (?, ?, 'PENDING', ?, ?, ?, ?, 'PAID', ?)";
        String insertItemSql =
            "INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) " +
            "SELECT ?, ?, ?, price FROM menu_items WHERE id = ?";
        String clearCartSql = "DELETE FROM cart_items WHERE user_id = ?";

        Connection conn = null;
        try {
            conn = AppContextListener.getDataSource().getConnection();
            conn.setAutoCommit(false);

            int orderId;
            try (PreparedStatement stmt = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setInt(1, buyerId);
                stmt.setInt(2, restaurantId);
                stmt.setBigDecimal(3, total);
                stmt.setString(4, deliveryAddress);
                stmt.setString(5, customerPhone);
                stmt.setString(6, paymentMethod);
                stmt.setString(7, transactionId);
                stmt.executeUpdate();
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    rs.next();
                    orderId = rs.getInt(1);
                }
            }

            try (PreparedStatement stmt = conn.prepareStatement(insertItemSql)) {
                for (CartItem item : cartItems) {
                    stmt.setInt(1, orderId);
                    stmt.setInt(2, item.getMenuItemId());
                    stmt.setInt(3, item.getQuantity());
                    stmt.setInt(4, item.getMenuItemId());
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }

            try (PreparedStatement stmt = conn.prepareStatement(clearCartSql)) {
                stmt.setInt(1, buyerId);
                stmt.executeUpdate();
            }

            conn.commit();
            return orderId;

        } catch (SQLException e) {
            if (conn != null) { try { conn.rollback(); } catch (SQLException ignored) {} }
            throw new RuntimeException("Failed to place order", e);
        } finally {
            if (conn != null) { try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {} }
        }
    }

    @Override
    public List<OrderSummary> findByBuyerId(int buyerId) {
        return runOrderSummaryQuery("WHERE o.buyer_id = ?", buyerId);
    }

    @Override
    public List<OrderSummary> findByRestaurantId(int restaurantId) {
        return runOrderSummaryQuery("WHERE o.restaurant_id = ?", restaurantId);
    }

    @Override
    public List<OrderSummary> findAll() {
        return runOrderSummaryQuery("", null);
    }

    private List<OrderSummary> runOrderSummaryQuery(String whereClause, Integer filterValue) {
        String sql =
            "SELECT o.id, o.buyer_id, u.name AS buyer_name, o.restaurant_id, r.name AS restaurant_name, " +
            "o.status, o.total_amount, o.delivery_address, o.customer_phone, o.payment_method, o.payment_status, o.transaction_id, o.created_at " +
            "FROM orders o " +
            "JOIN restaurants r ON r.id = o.restaurant_id " +
            "JOIN users u ON u.id = o.buyer_id " +
            (whereClause.isEmpty() ? "" : whereClause + " ") +
            "ORDER BY o.created_at DESC";

        Map<Integer, OrderSummary> byId = new LinkedHashMap<>();
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            if (filterValue != null) stmt.setInt(1, filterValue);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    OrderSummary summary = new OrderSummary();
                    summary.setId(rs.getInt("id"));
                    summary.setBuyerId(rs.getInt("buyer_id"));
                    summary.setBuyerName(rs.getString("buyer_name"));
                    summary.setRestaurantId(rs.getInt("restaurant_id"));
                    summary.setRestaurantName(rs.getString("restaurant_name"));
                    summary.setStatus(rs.getString("status"));
                    summary.setTotalAmount(rs.getBigDecimal("total_amount"));
                    summary.setDeliveryAddress(rs.getString("delivery_address"));
                    summary.setCustomerPhone(rs.getString("customer_phone"));
                    summary.setPaymentMethod(rs.getString("payment_method"));
                    summary.setPaymentStatus(rs.getString("payment_status"));
                    summary.setTransactionId(rs.getString("transaction_id"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) summary.setCreatedAt(ts.toLocalDateTime());
                    summary.setItems(new ArrayList<>());
                    byId.put(summary.getId(), summary);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to fetch orders", e);
        }

        if (!byId.isEmpty()) attachItems(byId);
        return new ArrayList<>(byId.values());
    }

    private void attachItems(Map<Integer, OrderSummary> byId) {
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < byId.size(); i++) {
            if (i > 0) placeholders.append(",");
            placeholders.append("?");
        }

        String sql =
            "SELECT oi.order_id, oi.menu_item_id, mi.name, oi.quantity, oi.unit_price " +
            "FROM order_items oi " +
            "JOIN menu_items mi ON mi.id = oi.menu_item_id " +
            "WHERE oi.order_id IN (" + placeholders + ")";

        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            int i = 1;
            for (Integer orderId : byId.keySet()) {
                stmt.setInt(i++, orderId);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    OrderItemDetail detail = new OrderItemDetail();
                    detail.setMenuItemId(rs.getInt("menu_item_id"));
                    detail.setName(rs.getString("name"));
                    detail.setQuantity(rs.getInt("quantity"));
                    BigDecimal unitPrice = rs.getBigDecimal("unit_price");
                    detail.setUnitPrice(unitPrice);
                    detail.setLineTotal(unitPrice.multiply(BigDecimal.valueOf(detail.getQuantity())));

                    OrderSummary summary = byId.get(rs.getInt("order_id"));
                    if (summary != null) summary.getItems().add(detail);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to fetch order items", e);
        }
    }

    @Override
    public boolean advanceStatus(int orderId, int restaurantId) {
        String sql =
            "UPDATE orders SET status = CASE status " +
            "WHEN 'PENDING' THEN 'CONFIRMED' " +
            "WHEN 'CONFIRMED' THEN 'SHIPPED' " +
            "WHEN 'SHIPPED' THEN 'DELIVERED' " +
            "ELSE status END " +
            "WHERE id = ? AND restaurant_id = ? AND status IN ('PENDING','CONFIRMED','SHIPPED')";

        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, orderId);
            stmt.setInt(2, restaurantId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to advance order status", e);
        }
    }

    @Override
    public boolean forceStatus(int orderId, String status) {
        String sql = "UPDATE orders SET status = ? WHERE id = ?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, orderId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to force order status", e);
        }
    }

    @Override
    public String findStatus(int orderId) {
        String sql = "SELECT status FROM orders WHERE id = ?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? rs.getString("status") : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to fetch order status", e);
        }
    }

    @Override
    public boolean hasDeliveredOrder(int buyerId, int restaurantId) {
        String sql = "SELECT 1 FROM orders WHERE buyer_id = ? AND restaurant_id = ? AND status = 'DELIVERED' LIMIT 1";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, buyerId);
            stmt.setInt(2, restaurantId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to check delivered orders", e);
        }
    }
}