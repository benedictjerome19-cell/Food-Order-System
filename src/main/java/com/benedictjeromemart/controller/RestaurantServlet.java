package com.benedictjeromemart.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.benedictjeromemart.dao.RestaurantDAO;
import com.benedictjeromemart.dao.RestaurantDAOImpl;
import com.benedictjeromemart.model.Restaurant;
import com.benedictjeromemart.util.JsonUtil;
import com.google.gson.JsonObject;

@WebServlet("/api/v1/restaurants")
public class RestaurantServlet extends HttpServlet {

    private final RestaurantDAO restaurantDAO = new RestaurantDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        List<Restaurant> restaurants = restaurantDAO.findAll();

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", JsonUtil.GSON.toJsonTree(restaurants));
        envelope.add("error", null);

        resp.setStatus(HttpServletResponse.SC_OK);
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }
}
