package com.benedictjeromemart.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;

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
        resp.getWriter().write(gson.toJson(envelope));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED", "Please log in to checkout");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        
        // Extract multi-step checkout parameters from the frontend request
        String deliveryAddress = req.getParameter("deliveryAddress");
        String customerPhone = req.getParameter("customerPhone");
        String paymentMethod = req.getParameter("paymentMethod");

        if (deliveryAddress == null || deliveryAddress.isBlank() || customerPhone == null || customerPhone.isBlank()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "Delivery address and phone number are required.");
            return;
        }

        if (paymentMethod == null || paymentMethod.isBlank()) {
            paymentMethod = "ONLINE_UPI";
        }

        List<CartItem> cartItems = cartDAO.findByUser(userId);

        if (cartItems == null || cartItems.isEmpty()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "EMPTY_CART", "Cannot checkout an empty cart");
            return;
        }

        BigDecimal total = BigDecimal.ZERO;
        int restaurantId = 0;
        
        for (CartItem item : cartItems) {
            MenuItem menuItem = menuItemDAO.findById(item.getMenuItemId());
            if (menuItem != null) {
                total = total.add(menuItem.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
                restaurantId = menuItem.getRestaurantId();
            } else {
                writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "INVALID_ITEM", "Cart contains an invalid item.");
                return;
            }
        }

        try {
            // Generate unique transaction ID
            String transactionId = "TXN-" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) + "-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();

            // Place order passing all 8 required arguments
            int orderId = orderDAO.placeOrder(userId, restaurantId, cartItems, total, deliveryAddress, customerPhone, paymentMethod, transactionId);

            JsonObject data = new JsonObject();
            data.addProperty("orderId", orderId);
            data.addProperty("total", total);
            data.addProperty("status", "PENDING");
            data.addProperty("transactionId", transactionId);
            data.addProperty("paymentMethod", paymentMethod);
            data.addProperty("deliveryAddress", deliveryAddress);

            JsonObject envelope = new JsonObject();
            envelope.addProperty("success", true);
            envelope.add("data", data);
            envelope.add("error", null);
            
            resp.setContentType("application/json");
            resp.setStatus(HttpServletResponse.SC_CREATED);
            resp.getWriter().write(gson.toJson(envelope));
            
        } catch (RuntimeException e) { 
            e.printStackTrace();
            writeError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "SERVER_ERROR", "Failed to place order: " + e.getMessage());
        }
    }
}