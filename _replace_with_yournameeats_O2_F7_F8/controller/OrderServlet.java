package com.yourname.yournameeats.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.yourname.yournameeats.dao.CartDAO;
import com.yourname.yournameeats.dao.CartDAOImpl;
import com.yourname.yournameeats.dao.MenuItemDAO;
import com.yourname.yournameeats.dao.MenuItemDAOImpl;
import com.yourname.yournameeats.dao.OrderDAO;
import com.yourname.yournameeats.dao.OrderDAOImpl;
import com.yourname.yournameeats.model.CartItem;
import com.yourname.yournameeats.model.MenuItem;
import com.yourname.yournameeats.util.GsonUtil;

@WebServlet("/api/v1/orders")
public class OrderServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAOImpl();
    private final MenuItemDAO menuItemDAO = new MenuItemDAOImpl();
    private final OrderDAO orderDAO = new OrderDAOImpl();
    private final Gson gson = GsonUtil.create();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        HttpSession session = req.getSession(false);
        int userId = (int) session.getAttribute("userId");

        List<CartItem> cartItems = cartDAO.findByUser(userId);
        JsonObject envelope = new JsonObject();

        if (cartItems.isEmpty()) {
            JsonObject error = new JsonObject();
            error.addProperty("code", "EMPTY_CART");
            error.addProperty("message", "Cannot checkout an empty cart");
            envelope.addProperty("success", false);
            envelope.add("data", null);
            envelope.add("error", error);
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write(gson.toJson(envelope));
            return;
        }

        BigDecimal total = BigDecimal.ZERO;
        int restaurantId = 0;
        for (CartItem item : cartItems) {
            MenuItem menuItem = menuItemDAO.findById(item.getMenuItemId());
            total = total.add(menuItem.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            restaurantId = menuItem.getRestaurantId();
        }

        int orderId = orderDAO.placeOrder(userId, restaurantId, cartItems, total);

        JsonObject data = new JsonObject();
        data.addProperty("orderId", orderId);
        data.addProperty("total", total);
        data.addProperty("status", "PENDING");

        envelope.addProperty("success", true);
        envelope.add("data", data);
        envelope.add("error", null);
        resp.setStatus(HttpServletResponse.SC_CREATED);
        resp.getWriter().write(gson.toJson(envelope));
    }
}