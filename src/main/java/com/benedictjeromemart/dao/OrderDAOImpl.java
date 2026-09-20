package com.benedictjeromemart.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.benedictjeromemart.model.CartItem;
import com.benedictjeromemart.model.Order;
import com.benedictjeromemart.model.OrderItem;
import com.benedictjeromemart.model.OrderItemDetail;
import com.benedictjeromemart.model.OrderSummary;
import com.benedictjeromemart.util.DBConnectionManager;

public class OrderDAOImpl implements OrderDAO {

    @Override
    public int createOrder(Order order, List<OrderItem> items) {
        String insertOrderSql = "INSERT INTO orders (buyer_id, restaurant_id, status, total_amount, delivery_address, customer_phone, payment_method, payment_status, transaction_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String insertItemSql = "INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) VALUES (?, ?, ?, ?)";
        
        int orderId = -1;
        try (Connection conn = DBConnectionManager.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psOrder = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                psOrder.setInt(1, order.getBuyerId());
                psOrder.setInt(2, order.getRestaurantId());
                psOrder.setString(3, order.getStatus() != null ? order.getStatus() : "PENDING");
                psOrder.setBigDecimal(4, order.getTotalAmount());
                psOrder.setString(5, order.getDeliveryAddress());
                psOrder.setString(6, order.getCustomerPhone());
                psOrder.setString(7, order.getPaymentMethod());
                psOrder.setString(8, order.getPaymentStatus() != null ? order.getPaymentStatus() : "PENDING");
                psOrder.setString(9, order.getTransactionId());
                
                int affectedRows = psOrder.executeUpdate();
                if (affectedRows == 0) {
                    throw new SQLException("Creating order failed, no rows affected.");
                }
                
                try (ResultSet generatedKeys = psOrder.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        orderId = generatedKeys.getInt(1);
                    } else {
                        throw new SQLException("Creating order failed, no ID obtained.");
                    }
                }
            }

            try (PreparedStatement psItem = conn.prepareStatement(insertItemSql)) {
                for (OrderItem item : items) {
                    psItem.setInt(1, orderId);
                    psItem.setInt(2, item.getMenuItemId());
                    psItem.setInt(3, item.getQuantity());
                    psItem.setBigDecimal(4, item.getUnitPrice());
                    psItem.addBatch();
                }
                psItem.executeBatch();
            }

            conn.commit();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to create order", e);
        }
        return orderId;
    }

    @Override
    public int placeOrder(Integer buyerId, int restaurantId, List<CartItem> cartItems, BigDecimal totalAmount, String deliveryAddress, String customerPhone, String paymentMethod, String transactionId) {
        Order order = new Order();
        order.setBuyerId(buyerId != null ? buyerId : 0);
        order.setRestaurantId(restaurantId);
        order.setStatus("PENDING");
        order.setTotalAmount(totalAmount);
        order.setDeliveryAddress(deliveryAddress);
        order.setCustomerPhone(customerPhone);
        order.setPaymentMethod(paymentMethod);
        order.setPaymentStatus("PAID");
        order.setTransactionId(transactionId);

        List<OrderItem> orderItems = new ArrayList<>();
        if (cartItems != null) {
            for (CartItem ci : cartItems) {
                OrderItem oi = new OrderItem();
                oi.setMenuItemId(ci.getMenuItemId());
                oi.setQuantity(ci.getQuantity());
                oi.setUnitPrice(ci.getUnitPrice());
                orderItems.add(oi);
            }
        }
        return createOrder(order, orderItems);
    }

    @Override
    public OrderSummary getOrderById(int orderId) {
        List<OrderSummary> summaries = runOrdersSummaryQuery("o.id = ?", orderId);
        return summaries.isEmpty() ? null : summaries.get(0);
    }

    @Override
    public List<OrderSummary> getOrdersByBuyerId(int buyerId) {
        return runOrdersSummaryQuery("o.buyer_id = ?", buyerId);
    }

    @Override
    public List<OrderSummary> findByBuyerId(int buyerId) {
        return getOrdersByBuyerId(buyerId);
    }

    @Override
    public List<OrderSummary> getOrdersByRestaurantId(int restaurantId) {
        return runOrdersSummaryQuery("o.restaurant_id = ?", restaurantId);
    }

    @Override
    public List<OrderSummary> findByRestaurantId(int restaurantId) {
        return getOrdersByRestaurantId(restaurantId);
    }

    @Override
    public List<OrderSummary> findAll() {
        return runOrdersSummaryQuery(null);
    }

    @Override
    public void updateOrderStatus(int orderId, String status) {
        String sql = "UPDATE orders SET status = ? WHERE id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to update order status", e);
        }
    }

    @Override
    public boolean advanceStatus(int orderId, int status) {
        String statusStr = String.valueOf(status);
        if (status == 1) statusStr = "PENDING";
        else if (status == 2) statusStr = "PREPARING";
        else if (status == 3) statusStr = "OUT_FOR_DELIVERY";
        else if (status == 4) statusStr = "DELIVERED";

        String sql = "UPDATE orders SET status = ? WHERE id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, statusStr);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to advance order status", e);
        }
    }

    @Override
    public boolean forceStatus(int orderId, String status) {
        String sql = "UPDATE orders SET status = ? WHERE id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to force order status", e);
        }
    }

    @Override
    public String findStatus(int orderId) {
        String sql = "SELECT status FROM orders WHERE id = ?";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to find order status", e);
        }
        return null;
    }

    @Override
    public boolean hasDeliveredOrder(int userId, int restaurantId) {
        String sql = "SELECT COUNT(*) FROM orders WHERE buyer_id = ? AND restaurant_id = ? AND status = 'DELIVERED'";
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to check delivered order", e);
        }
        return false;
    }

    private List<OrderSummary> runOrdersSummaryQuery(String whereClause, Object... params) {
        String sql = "SELECT o.id as order_id, o.buyer_id, o.restaurant_id, o.status, o.total_amount, "
                   + "o.delivery_address, o.customer_phone, o.payment_method, o.payment_status, o.transaction_id, o.created_at, "
                   + "r.name as restaurant_name, "
                   + "oi.id as item_id, oi.menu_item_id, oi.quantity, oi.unit_price, "
                   + "m.name as menu_item_name "
                   + "FROM orders o "
                   + "JOIN restaurants r ON o.restaurant_id = r.id "
                   + "JOIN order_items oi ON o.id = oi.order_id "
                   + "JOIN menu_items m ON oi.menu_item_id = m.id";
        
        if (whereClause != null && !whereClause.trim().isEmpty()) {
            sql += " WHERE " + whereClause;
        }

        Map<Integer, OrderSummary> byId = new HashMap<>();
        try (Connection conn = DBConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int orderId = rs.getInt("order_id");
                    OrderSummary summary = byId.get(orderId);
                    if (summary == null) {
                        summary = new OrderSummary();
                        summary.setId(orderId);
                        summary.setBuyerId(rs.getInt("buyer_id"));
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
                        byId.put(orderId, summary);
                    }

                    OrderItemDetail item = new OrderItemDetail();
                    item.setId(rs.getInt("item_id"));
                    item.setOrderId(orderId);
                    item.setMenuItemId(rs.getInt("menu_item_id"));
                    item.setMenuItemName(rs.getString("menu_item_name"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getBigDecimal("unit_price"));
                    summary.getItems().add(item);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to fetch orders", e);
        }
        return new ArrayList<>(byId.values());
    }
}