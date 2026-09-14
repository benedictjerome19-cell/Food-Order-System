package com.benedictjeromemart.dao;

import java.util.List;

import com.benedictjeromemart.model.MenuItem;

public interface MenuItemDAO {
    List<MenuItem> search(String keyword, String category);
    MenuItem findById(int id);
    List<MenuItem> findByRestaurantId(int restaurantId);
    MenuItem create(MenuItem item);
    void update(MenuItem item);
    void delete(int id, int restaurantId);
    void deleteById(int id); // admin moderation: delete any listing regardless of restaurant
    boolean updatePriceByName(String namePattern, double newPrice);
    boolean updateStockByName(String namePattern, int newStock);
    boolean updateAvailabilityByName(String namePattern, boolean available);
}