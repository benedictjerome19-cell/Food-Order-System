package com.benedictjeromemart.dao;

import java.util.ArrayList;
import java.util.List;
import com.benedictjeromemart.model.CartItem;

public class CartDAOImpl implements CartDAO {
    private final List<CartItem> cartItems = new ArrayList<>();

    @Override
    public List<CartItem> findByUser(int userId) {
        return cartItems;
    }

    @Override
    public void addOrUpdate(int userId, int menuItemId, int quantity) {
        // Test stub implementation
    }

    @Override
    public void remove(int userId, int menuItemId) {
        // Test stub implementation
    }

    @Override
    public void clearCart(int userId) {
        cartItems.clear();
    }
}