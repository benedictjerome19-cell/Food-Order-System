package com.benedictjeromemart.dao;

import java.util.List;
import java.util.Optional;

import com.benedictjeromemart.model.Restaurant;

public interface RestaurantDAO {
    Optional<Restaurant> findByOwnerId(int ownerId);
    Optional<Restaurant> findById(int id);
    List<Restaurant> findAll();
    Restaurant create(Restaurant restaurant);
}
