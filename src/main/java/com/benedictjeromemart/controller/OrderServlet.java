package com.benedictjeromemart.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.benedictjeromemart.dao.CartDAO;
import com.benedictjeromemart.dao.CartDAOImpl;
import com.benedictjeromemart.dao.MenuItemDAO;
import com.benedictjeromemart.dao.MenuItemDAOImpl;
import com.benedictjeromemart.dao.OrderDAO;
import com.benedictjeromemart.dao.OrderDAOImpl;
import com.benedictjeromemart.model.CartItem;
import com.benedictjeromemart.model.MenuItem;
import com.benedictjeromemart.util.GsonUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

@WebServlet("/api/v1/orders")
public class OrderServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAOImpl();
    private final MenuItemDAO menuItemDAO = new MenuItemDAOImpl();
    private final OrderDAO orderDAO = new OrderDAOImpl();
    private final Gson gson = GsonUtil.create();

    private Integer getUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            return (Integer) session.getAttribute("userId");
        }
        return null;
    }

    private void writeError(HttpServletResponse resp, int status, String code, String message) throws IOException {
        JsonObject error = new JsonObject();
        error.addProperty("code", code);
        error.addProperty("message", message);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", false);
        envelope.add("data", null);
        envelope.add("error", error);

        resp.setStatus(status);
        resp.getWriter().write(gson.toJson(envelope));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");

        // 1. Authenticate user session
        Integer userId = getUserId(req);
        if (userId == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED", "Please log in to place an order.");
            return;
        }

        // 2. Retrieve items from current cart
        List<CartItem> cartItems = cartDAO.findByUser(userId);

        if (cartItems == null || cartItems.isEmpty()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "EMPTY_CART", "Cannot checkout an empty cart.");
            return;
        }

        // 3. Compute order total & validate menu items
        BigDecimal total = BigDecimal.ZERO;
        int restaurantId = 0;

        for (CartItem item : cartItems) {
            MenuItem menuItem = menuItemDAO.findById(item.getMenuItemId());
            if (menuItem == null) {
                writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "INVALID_ITEM", "Cart contains an item that no longer exists.");
                return;
            }
            total = total.add(menuItem.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            restaurantId = menuItem.getRestaurantId();
        }

        // 4. Place order in database
        try {
            int orderId = orderDAO.placeOrder(userId, restaurantId, cartItems, total);

            JsonObject data = new JsonObject();
            data.addProperty("orderId", orderId);
            data.addProperty("total", total);
            data.addProperty("status", "PENDING");

            JsonObject envelope = new JsonObject();
            envelope.addProperty("success", true);
            envelope.add("data", data);
            envelope.add("error", null);

            resp.setStatus(HttpServletResponse.SC_CREATED);
            resp.getWriter().write(gson.toJson(envelope));
        } catch (Exception e) {
            writeError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "ORDER_FAILED", "Order processing failed: " + e.getMessage());
        }
    }
}