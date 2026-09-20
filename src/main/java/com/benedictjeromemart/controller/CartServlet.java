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
import com.benedictjeromemart.model.CartItem;
import com.benedictjeromemart.model.MenuItem;
import com.benedictjeromemart.util.GsonUtil;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

@WebServlet("/api/v1/cart/*")
public class CartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAOImpl();
    private final MenuItemDAO menuItemDAO = new MenuItemDAOImpl();
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
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED", "Please log in");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        List<CartItem> cartItems = cartDAO.findByUser(userId);

        // Build a JSON array that includes name and price for each item
        JsonArray jsonItems = new JsonArray();
        for (CartItem ci : cartItems) {
            MenuItem mi = menuItemDAO.findById(ci.getMenuItemId());
            JsonObject obj = new JsonObject();
            obj.addProperty("id", ci.getId());
            obj.addProperty("menuItemId", ci.getMenuItemId());
            obj.addProperty("quantity", ci.getQuantity());
            if (mi != null) {
                obj.addProperty("name", mi.getName());
                obj.addProperty("price", mi.getPrice());
            } else {
                obj.addProperty("name", "Menu Item #" + ci.getMenuItemId());
                obj.addProperty("price", BigDecimal.ZERO);
            }
            jsonItems.add(obj);
        }

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", jsonItems);
        envelope.add("error", null);

        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(envelope));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED", "Please log in");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String menuItemIdStr = req.getParameter("menuItemId");
        String quantityStr = req.getParameter("quantity");

        if (menuItemIdStr == null) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "menuItemId is required");
            return;
        }

        int menuItemId = Integer.parseInt(menuItemIdStr);
        int quantity = quantityStr != null ? Integer.parseInt(quantityStr) : 1;

        cartDAO.addOrUpdate(userId, menuItemId, quantity);

        // Return updated cart items with names and prices
        doGet(req, resp);
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED", "Please log in");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String menuItemIdStr = req.getParameter("menuItemId");

        if (menuItemIdStr != null) {
            cartDAO.remove(userId, Integer.parseInt(menuItemIdStr));
        }

        // Return updated cart items
        doGet(req, resp);
    }
}