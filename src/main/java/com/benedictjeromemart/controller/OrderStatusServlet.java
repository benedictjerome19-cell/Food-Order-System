package com.benedictjeromemart.controller;

import java.io.IOException;
import java.util.Optional;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.JsonObject;
import com.benedictjeromemart.dao.OrderDAO;
import com.benedictjeromemart.dao.OrderDAOImpl;
import com.benedictjeromemart.dao.RestaurantDAO;
import com.benedictjeromemart.dao.RestaurantDAOImpl;
import com.benedictjeromemart.model.Restaurant;
import com.benedictjeromemart.util.JsonUtil;

@WebServlet("/api/v1/owner/orders/status")
public class OrderStatusServlet extends HttpServlet {

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
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        HttpSession session = req.getSession(false);
        if (session == null || !"RESTAURANT_OWNER".equals(session.getAttribute("userRole"))) {
            writeError(resp, HttpServletResponse.SC_FORBIDDEN, "FORBIDDEN", "Restaurant owner access only");
            return;
        }
        int ownerId = (int) session.getAttribute("userId");

        String orderIdParam = req.getParameter("orderId");
        if (orderIdParam == null || orderIdParam.isBlank()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "orderId is required");
            return;
        }

        Optional<Restaurant> restaurant = restaurantDAO.findByOwnerId(ownerId);
        if (restaurant.isEmpty()) {
            writeError(resp, HttpServletResponse.SC_FORBIDDEN, "FORBIDDEN", "No restaurant found for this owner");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdParam);
        } catch (NumberFormatException e) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "orderId must be a number");
            return;
        }

        boolean advanced = orderDAO.advanceStatus(orderId, restaurant.get().getId());
        if (!advanced) {
            writeError(resp, HttpServletResponse.SC_CONFLICT, "INVALID_TRANSITION",
                "Order not found for this restaurant, or already DELIVERED");
            return;
        }

        String newStatus = orderDAO.findStatus(orderId);

        JsonObject data = new JsonObject();
        data.addProperty("orderId", orderId);
        data.addProperty("status", newStatus);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", data);
        envelope.add("error", null);
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }
}
