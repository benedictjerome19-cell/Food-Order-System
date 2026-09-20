package com.benedictjeromemart.dao;

import com.benedictjeromemart.model.CartItem;
import com.benedictjeromemart.model.Order;
import com.benedictjeromemart.model.OrderItem;
import com.benedictjeromemart.model.OrderSummary;
import java.math.BigDecimal;
import java.util.List;

public interface OrderDAO {
    int createOrder(Order order, List<OrderItem> items);
    int placeOrder(Integer buyerId, int restaurantId, List<CartItem> cartItems, BigDecimal totalAmount, String deliveryAddress, String customerPhone, String paymentMethod, String transactionId);
    OrderSummary getOrderById(int orderId);
    List<OrderSummary> getOrdersByBuyerId(int buyerId);
    List<OrderSummary> findByBuyerId(int buyerId);
    List<OrderSummary> getOrdersByRestaurantId(int restaurantId);
    List<OrderSummary> findByRestaurantId(int restaurantId);
    List<OrderSummary> findAll();
    void updateOrderStatus(int orderId, String status);
    boolean advanceStatus(int orderId, int status);
    boolean forceStatus(int orderId, String status);
    String findStatus(int orderId);
    boolean hasDeliveredOrder(int userId, int restaurantId);
}