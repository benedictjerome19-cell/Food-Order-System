package com.yourname.yournameeats.dao;

import java.math.BigDecimal;
import java.util.List;

import com.yourname.yournameeats.model.CartItem;
import com.yourname.yournameeats.model.OrderSummary;

public interface OrderDAO {
    int placeOrder(int buyerId, int restaurantId, List<CartItem> cartItems, BigDecimal total);

    List<OrderSummary> findByBuyerId(int buyerId);
    List<OrderSummary> findByRestaurantId(int restaurantId);
    List<OrderSummary> findAll();

    /** Owner-only: moves an order one step forward (PENDING->CONFIRMED->SHIPPED->DELIVERED).
     *  Restricted to orders belonging to restaurantId. Returns false if the order
     *  doesn't exist for that restaurant, or is already DELIVERED. */
    boolean advanceStatus(int orderId, int restaurantId);

    /** Admin-only: sets a status directly, no restaurant check, no sequence check. */
    boolean forceStatus(int orderId, String status);

    String findStatus(int orderId);

    /** Used to gate reviews: has this buyer ever had a DELIVERED order from this restaurant? */
    boolean hasDeliveredOrder(int buyerId, int restaurantId);
}
