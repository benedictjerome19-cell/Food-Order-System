package com.yourname.yournameeats.controller;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.JsonObject;
import com.yourname.yournameeats.dao.OrderDAO;
import com.yourname.yournameeats.dao.OrderDAOImpl;
import com.yourname.yournameeats.dao.RestaurantDAO;
import com.yourname.yournameeats.dao.RestaurantDAOImpl;
import com.yourname.yournameeats.model.OrderSummary;
import com.yourname.yournameeats.model.Restaurant;
import com.yourname.yournameeats.util.JsonUtil;

@WebServlet("/api/v1/orders/history")
public class OrderHistoryServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAOImpl();
    private final RestaurantDAO restaurantDAO = new RestaurantDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        HttpSession session = req.getSession(false);
        int userId = (int) session.getAttribute("userId");
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
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }
}
