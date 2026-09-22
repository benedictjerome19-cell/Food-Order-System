package com.benedictjeromemart.controller;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.benedictjeromemart.dao.OrderDAO;
import com.benedictjeromemart.dao.OrderDAOImpl;
import com.benedictjeromemart.dao.RestaurantDAO;
import com.benedictjeromemart.dao.RestaurantDAOImpl;
import com.benedictjeromemart.model.OrderSummary;
import com.benedictjeromemart.model.Restaurant;
import com.benedictjeromemart.util.JsonUtil;
import com.google.gson.JsonObject;

@WebServlet("/api/v1/orders/history")
public class OrderHistoryServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAOImpl();
    private final RestaurantDAO restaurantDAO = new RestaurantDAOImpl();

    private void writeError(HttpServletResponse resp, int status, String code, String message) throws IOException {
        JsonObject error = new JsonObject();
        error.addProperty("code", code);
        error.addProperty("message", message);
        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", false);
        envelope.add("data", null);
        envelope.add("error", error);
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED", "Please log in to view history");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        String role = (String) session.getAttribute("userRole");

        List<OrderSummary> orders;
        if ("RESTAURANT_OWNER".equals(role)) {
            Optional<Restaurant> restaurant = restaurantDAO.findByOwnerId(userId);
            orders = restaurant.isPresent()
                ? orderDAO.findByRestaurantId(restaurant.get().getId())
                : List.of();
        } else {
            orders = orderDAO.findByBuyerId(userId);
        }

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", JsonUtil.GSON.toJsonTree(orders));
        envelope.add("error", null);
        
        resp.setContentType("application/json");
        resp.setStatus(HttpServletResponse.SC_OK);
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }
}