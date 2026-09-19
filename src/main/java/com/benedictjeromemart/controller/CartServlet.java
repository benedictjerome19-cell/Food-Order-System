package com.benedictjeromemart.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.annotation.MultipartConfig;
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
@MultipartConfig
public class CartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAOImpl();
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
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(envelope));
    }

    private String getParam(HttpServletRequest req, JsonObject jsonBody, String key) {
        String val = req.getParameter(key);
        if (val == null && jsonBody != null && jsonBody.has(key)) {
            val = jsonBody.get(key).getAsString();
        }
        return val;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer userId = getUserId(req);
        if (userId == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED", "Please log in");
            return;
        }

        List<CartItem> items = cartDAO.findByUser(userId);
        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", gson.toJsonTree(items));
        envelope.add("error", null);
        
        resp.setContentType("application/json");
        resp.setStatus(HttpServletResponse.SC_OK);
        resp.getWriter().write(gson.toJson(envelope));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer userId = getUserId(req);
        if (userId == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED", "Please log in");
            return;
        }

        JsonObject jsonBody = null;
        if (req.getContentType() != null && req.getContentType().contains("json")) {
            try {
                jsonBody = gson.fromJson(req.getReader(), JsonObject.class);
            } catch (Exception ignored) {}
        }

        String menuItemIdParam = getParam(req, jsonBody, "menuItemId");
        String quantityParam = getParam(req, jsonBody, "quantity");

        if (menuItemIdParam == null || menuItemIdParam.isBlank()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "menuItemId is required");
            return;
        }

        int quantity = 1;
        if (quantityParam != null && !quantityParam.isBlank()) {
            try {
                quantity = Integer.parseInt(quantityParam);
            } catch (NumberFormatException e) {
                writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "quantity must be a number");
                return;
            }
        }

        try {
            int menuItemId = Integer.parseInt(menuItemIdParam);
            // 1. Add the item to the database
            cartDAO.addOrUpdate(userId, menuItemId, quantity);

            // 2. Fetch the newly updated cart list
            List<CartItem> updatedCart = cartDAO.findByUser(userId);

            // 3. Send the updated cart back to the frontend
            JsonObject envelope = new JsonObject();
            envelope.addProperty("success", true);
            envelope.add("data", gson.toJsonTree(updatedCart));
            envelope.add("error", null);
            
            resp.setContentType("application/json");
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write(gson.toJson(envelope));
        } catch (NumberFormatException e) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "menuItemId must be a number");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer userId = getUserId(req);
        if (userId == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED", "Please log in");
            return;
        }

        JsonObject jsonBody = null;
        if (req.getContentType() != null && req.getContentType().contains("json")) {
            try {
                jsonBody = gson.fromJson(req.getReader(), JsonObject.class);
            } catch (Exception ignored) {}
        }

        String menuItemIdParam = getParam(req, jsonBody, "menuItemId");
        if (menuItemIdParam == null || menuItemIdParam.isBlank()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "menuItemId is required");
            return;
        }

        try {
            int menuItemId = Integer.parseInt(menuItemIdParam);
            // 1. Remove the item
            cartDAO.remove(userId, menuItemId);

            // 2. Fetch the newly updated cart list
            List<CartItem> updatedCart = cartDAO.findByUser(userId);

            // 3. Send it back to the frontend
            JsonObject envelope = new JsonObject();
            envelope.addProperty("success", true);
            envelope.add("data", gson.toJsonTree(updatedCart));
            envelope.add("error", null);
            
            resp.setContentType("application/json");
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write(gson.toJson(envelope));
        } catch (NumberFormatException e) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "menuItemId must be a number");
        }
    }
}