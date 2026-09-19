package com.benedictjeromemart.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.benedictjeromemart.dao.CartDAO;
import com.benedictjeromemart.dao.CartDAOImpl;
import com.benedictjeromemart.model.CartItem;
import com.benedictjeromemart.util.GsonUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

@WebServlet("/api/v1/cart")
@MultipartConfig // CRITICAL FIX: Allows Tomcat to read modern JavaScript FormData
public class CartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAOImpl();
    private final Gson gson = GsonUtil.create();

    // Safely gets the user ID, returning null if the session is invalid
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

    // Helper to safely read parameters whether they come from a standard form or JSON
    private String extractParameter(HttpServletRequest req, String paramName) {
        String value = req.getParameter(paramName);
        if (value == null || value.isBlank()) {
            // Check if the frontend accidentally sent it under 'id' instead of 'menuItemId'
            if ("menuItemId".equals(paramName)) {
                value = req.getParameter("id"); 
            }
        }
        return value;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        
        Integer userId = getUserId(req);
        if (userId == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED", "Please log in to view your cart.");
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
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED", "Please log in to add items to your cart.");
            return;
        }

        String menuItemIdParam = extractParameter(req, "menuItemId");
        String quantityParam = extractParameter(req, "quantity");

        if (menuItemIdParam == null || menuItemIdParam.isBlank()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "menuItemId is required.");
            return;
        }

        // Default to 1 if quantity is missing
        int quantity = 1; 
        if (quantityParam != null && !quantityParam.isBlank()) {
            try {
                quantity = Integer.parseInt(quantityParam);
            } catch (NumberFormatException e) {
                writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "quantity must be a number.");
                return;
            }
        }

        try {
            int menuItemId = Integer.parseInt(menuItemIdParam);
            cartDAO.addOrUpdate(userId, menuItemId, quantity);

            JsonObject envelope = new JsonObject();
            envelope.addProperty("success", true);
            envelope.add("data", null);
            envelope.add("error", null);
            resp.getWriter().write(gson.toJson(envelope));
            
        } catch (NumberFormatException e) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "menuItemId must be a number.");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        
        Integer userId = getUserId(req);
        if (userId == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED", "Please log in to modify your cart.");
            return;
        }

        String menuItemIdParam = extractParameter(req, "menuItemId");
        if (menuItemIdParam == null || menuItemIdParam.isBlank()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "menuItemId is required.");
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
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "menuItemId must be a number.");
        }
    }
}