package com.benedictjeromemart.dao;

import java.util.List;

import com.benedictjeromemart.model.Review;

public interface ReviewDAO {
    /** One review per (restaurant, user) — re-reviewing updates the existing row. */
    Review upsert(int restaurantId, int userId, int rating, String comment);
    List<Review> findByRestaurantId(int restaurantId);
    double findAverageRating(int restaurantId);
}
