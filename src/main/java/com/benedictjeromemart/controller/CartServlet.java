package com.benedictjeromemart.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.benedictjeromemart.dao.CartDAO;
import com.benedictjeromemart.dao.CartDAOImpl;
import com.benedictjeromemart.model.CartItem;
import com.benedictjeromemart.util.GsonUtil;

@WebServlet("/api/v1/cart")
public class CartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAOImpl();
    private final Gson gson = GsonUtil.create();

    // Safely gets the user ID, returning null if the session is invalid or expired
    private Integer getUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            return (Integer) session.getAttribute("userId");
        }
        return null;
    }

    // Helper method to send a clean unauthorized error to the frontend
    private void writeUnauthorized(HttpServletResponse resp) throws IOException {
        JsonObject error = new JsonObject();
        error.addProperty("code", "UNAUTHORIZED");
        error.addProperty("message", "Please log in to access your cart");

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", false);
        envelope.add("data", null);
        envelope.add("error", error);

        resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        resp.getWriter().write(gson.toJson(envelope));
    }

    // Helper method for validation errors
    private void writeBadRequest(HttpServletResponse resp, String message) throws IOException {
        JsonObject error = new JsonObject();
        error.addProperty("code", "VALIDATION_ERROR");
        error.addProperty("message", message);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", false);
        envelope.add("data", null);
        envelope.add("error", error);

        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        resp.getWriter().write(gson.toJson(envelope));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        
        Integer userId = getUserId(req);
        if (userId == null) {
            writeUnauthorized(resp);
            return;
        }

        List<CartItem> items = cartDAO.findByUser(userId);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", gson.toJsonTree(items));
        envelope.add("error", null);
        resp.getWriter().write(gson.toJson(envelope));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        
        Integer userId = getUserId(req);
        if (userId == null) {
            writeUnauthorized(resp);
            return;
        }

        String menuItemIdParam = req.getParameter("menuItemId");
        String quantityParam = req.getParameter("quantity");

        if (menuItemIdParam == null || quantityParam == null || menuItemIdParam.isBlank() || quantityParam.isBlank()) {
            writeBadRequest(resp, "Both menuItemId and quantity are required.");
            return;
        }

        try {
            int menuItemId = Integer.parseInt(menuItemIdParam);
            int quantity = Integer.parseInt(quantityParam);
            
            cartDAO.addOrUpdate(userId, menuItemId, quantity);

            JsonObject envelope = new JsonObject();
            envelope.addProperty("success", true);
            envelope.add("data", null);
            envelope.add("error", null);
            resp.getWriter().write(gson.toJson(envelope));
            
        } catch (NumberFormatException e) {
            writeBadRequest(resp, "menuItemId and quantity must be valid numbers.");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        
        Integer userId = getUserId(req);
        if (userId == null) {
            writeUnauthorized(resp);
            return;
        }

        String menuItemIdParam = req.getParameter("menuItemId");
        if (menuItemIdParam == null || menuItemIdParam.isBlank()) {
            writeBadRequest(resp, "menuItemId is required for deletion.");
            return;
        }

        try {
            int menuItemId = Integer.parseInt(menuItemIdParam);
            cartDAO.remove(userId, menuItemId);

            JsonObject envelope = new JsonObject();
            envelope.addProperty("success", true);
            envelope.add("data", null);
            envelope.add("error", null);
            resp.getWriter().write(gson.toJson(envelope));
            
        } catch (NumberFormatException e) {
            writeBadRequest(resp, "menuItemId must be a valid number.");
        }
    }
}