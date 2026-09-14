package com.benedictjeromemart.dao;

import com.benedictjeromemart.model.CartItem;
import java.util.List;

public interface CartDAO {
    void addOrUpdate(int userId, int menuItemId, int quantity);
    void remove(int userId, int menuItemId);
    List<CartItem> findByUser(int userId);
    void clearCart(int userId);
}
