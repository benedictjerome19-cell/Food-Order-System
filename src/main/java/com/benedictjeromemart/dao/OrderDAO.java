package com.benedictjeromemart.dao;

import java.math.BigDecimal;
import java.util.List;

import com.benedictjeromemart.model.CartItem;
import com.benedictjeromemart.model.OrderSummary;

public interface OrderDAO {
    int placeOrder(int buyerId, int restaurantId, List<CartItem> cartItems, BigDecimal total, 
                   String deliveryAddress, String customerPhone, String paymentMethod, String transactionId);

    List<OrderSummary> findByBuyerId(int buyerId);
    List<OrderSummary> findByRestaurantId(int restaurantId);
    List<OrderSummary> findAll();

    boolean advanceStatus(int orderId, int restaurantId);
    boolean forceStatus(int orderId, String status);
    String findStatus(int orderId);
    boolean hasDeliveredOrder(int buyerId, int restaurantId);
}