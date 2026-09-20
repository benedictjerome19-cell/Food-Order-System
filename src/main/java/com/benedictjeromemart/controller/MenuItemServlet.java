package com.benedictjeromemart.controller;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;
import com.benedictjeromemart.dao.MenuItemDAO;
import com.benedictjeromemart.dao.MenuItemDAOImpl;
import com.benedictjeromemart.model.MenuItem;

@WebServlet("/api/v1/menu-items")
public class MenuItemServlet extends HttpServlet {

    private final MenuItemDAO menuItemDAO = new MenuItemDAOImpl();
    private final Gson gson = new GsonBuilder()
        .registerTypeAdapter(LocalDateTime.class,
            (JsonSerializer<LocalDateTime>) (src, type, ctx) -> new JsonPrimitive(src.toString()))
        .create();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        String keyword = req.getParameter("keyword");
        String category = req.getParameter("category");
        String restaurantIdParam = req.getParameter("restaurantId");

        List<MenuItem> items;
        if (restaurantIdParam != null && !restaurantIdParam.isBlank()) {
            try {
                int restaurantId = Integer.parseInt(restaurantIdParam.trim());
                items = menuItemDAO.findByRestaurantId(restaurantId);
                // Filter by category or keyword if supplied
                if (category != null && !category.isBlank() && !"all".equalsIgnoreCase(category)) {
                    items.removeIf(i -> i.getCategory() == null || !i.getCategory().equalsIgnoreCase(category));
                }
                if (keyword != null && !keyword.isBlank()) {
                    String kw = keyword.toLowerCase();
                    items.removeIf(i -> (i.getName() == null || !i.getName().toLowerCase().contains(kw)) &&
                                        (i.getDescription() == null || !i.getDescription().toLowerCase().contains(kw)));
                }
            } catch (NumberFormatException e) {
                items = menuItemDAO.search(keyword, category);
            }
        } else {
            items = menuItemDAO.search(keyword, category);
        }

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", gson.toJsonTree(items));
        envelope.add("error", null);

        resp.getWriter().write(gson.toJson(envelope));
    }
}
