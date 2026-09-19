package com.benedictjeromemart.controller;

import java.io.IOException;
import java.util.List;

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
public class CartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAOImpl();
    private final Gson gson = GsonUtil.create();

    /** Safely fetches the logged-in user's ID from session. Returns null if unauthenticated. */
    private Integer getUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            return (Integer) session.getAttribute("userId");
        }
        return null;
    }

    private void writeUnauthorized(HttpServletResponse resp) throws IOException {
        JsonObject error = new JsonObject();
        error.addProperty("code", "UNAUTHORIZED");
        error.addProperty("message", "Please log in to manage your cart.");

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", false);
        envelope.add("data", null);
        envelope.add("error", error);

        resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        resp.getWriter().write(gson.toJson(envelope));
    }

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

    /** Extracts a request parameter, supporting both form-encoded data and raw JSON payloads. */
    private String getParam(HttpServletRequest req, JsonObject jsonBody, String paramName) {
        String val = req.getParameter(paramName);
        if ((val == null || val.isBlank()) && jsonBody != null && jsonBody.has(paramName)) {
            val = jsonBody.get(paramName).getAsString();
        }
        return val;
    }

    /** Parses raw JSON body if request Content-Type is application/json. */
    private JsonObject parseJsonBody(HttpServletRequest req) {
        if (req.getContentType() != null && req.getContentType().toLowerCase().contains("application/json")) {
            try {
                return gson.fromJson(req.getReader(), JsonObject.class);
            } catch (Exception ignored) {
            }
        }
        return null;
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

        resp.setStatus(HttpServletResponse.SC_OK);
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

        JsonObject jsonBody = parseJsonBody(req);
        String menuItemIdParam = getParam(req, jsonBody, "menuItemId");
        String quantityParam = getParam(req, jsonBody, "quantity");

        if (menuItemIdParam == null || menuItemIdParam.isBlank()) {
            writeBadRequest(resp, "menuItemId is required.");
            return;
        }

        int quantity = 1; // Default to 1 item if quantity parameter is omitted
        if (quantityParam != null && !quantityParam.isBlank()) {
            try {
                quantity = Integer.parseInt(quantityParam);
            } catch (NumberFormatException e) {
                writeBadRequest(resp, "quantity must be a valid number.");
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

            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write(gson.toJson(envelope));
        } catch (NumberFormatException e) {
            writeBadRequest(resp, "menuItemId must be a valid number.");
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

        JsonObject jsonBody = parseJsonBody(req);
        String menuItemIdParam = getParam(req, jsonBody, "menuItemId");

        if (menuItemIdParam == null || menuItemIdParam.isBlank()) {
            writeBadRequest(resp, "menuItemId is required.");
            return;
        }

        try {
            int menuItemId = Integer.parseInt(menuItemIdParam);
            cartDAO.remove(userId, menuItemId);

            JsonObject envelope = new JsonObject();
            envelope.addProperty("success", true);
            envelope.add("data", null);
            envelope.add("error", null);

            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write(gson.toJson(envelope));
        } catch (NumberFormatException e) {
            writeBadRequest(resp, "menuItemId must be a valid number.");
        }
    }
}