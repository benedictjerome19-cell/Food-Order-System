package com.yourname.yournameeats.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.yourname.yournameeats.dao.MenuItemDAO;
import com.yourname.yournameeats.dao.MenuItemDAOImpl;
import com.yourname.yournameeats.dao.RestaurantDAO;
import com.yourname.yournameeats.dao.RestaurantDAOImpl;
import com.yourname.yournameeats.model.MenuItem;
import com.yourname.yournameeats.model.Restaurant;
import com.yourname.yournameeats.util.GsonUtil;

@WebServlet("/api/v1/owner/menu-items")
public class ManageMenuServlet extends HttpServlet {

    private final RestaurantDAO restaurantDAO = new RestaurantDAOImpl();
    private final MenuItemDAO menuItemDAO = new MenuItemDAOImpl();
    private final Gson gson = GsonUtil.create();

    /** Finds the owner's restaurant, auto-creating a starter one on first use. */
    private Restaurant getOrCreateRestaurant(int ownerId, String ownerName) {
        Optional<Restaurant> existing = restaurantDAO.findByOwnerId(ownerId);
        if (existing.isPresent()) return existing.get();

        Restaurant r = new Restaurant();
        r.setOwnerId(ownerId);
        r.setName(ownerName + "'s Restaurant");
        r.setCuisineType("General");
        r.setAddress("Not set");
        return restaurantDAO.create(r);
    }

    private boolean isOwner(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null && "RESTAURANT_OWNER".equals(session.getAttribute("userRole"));
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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        if (!isOwner(req)) {
            writeError(resp, HttpServletResponse.SC_FORBIDDEN, "FORBIDDEN", "Restaurant owner access only");
            return;
        }
        HttpSession session = req.getSession(false);
        int userId = (int) session.getAttribute("userId");
        String userName = (String) session.getAttribute("userName");

        Restaurant restaurant = getOrCreateRestaurant(userId, userName != null ? userName : "My");
        List<MenuItem> items = menuItemDAO.findByRestaurantId(restaurant.getId());

        JsonObject data = new JsonObject();
        data.addProperty("restaurantId", restaurant.getId());
        data.addProperty("restaurantName", restaurant.getName());
        data.add("items", gson.toJsonTree(items));

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", data);
        envelope.add("error", null);
        resp.getWriter().write(gson.toJson(envelope));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        if (!isOwner(req)) {
            writeError(resp, HttpServletResponse.SC_FORBIDDEN, "FORBIDDEN", "Restaurant owner access only");
            return;
        }
        HttpSession session = req.getSession(false);
        int userId = (int) session.getAttribute("userId");
        String userName = (String) session.getAttribute("userName");
        Restaurant restaurant = getOrCreateRestaurant(userId, userName != null ? userName : "My");

        String idParam = req.getParameter("id");
        String name = req.getParameter("name");
        String description = req.getParameter("description");
        String priceParam = req.getParameter("price");
        String stockParam = req.getParameter("stockQty");
        String category = req.getParameter("category");
        String imageUrl = req.getParameter("imageUrl");

        if (name == null || name.isBlank() || priceParam == null || priceParam.isBlank()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "Name and price are required");
            return;
        }

        BigDecimal price;
        try {
            price = new BigDecimal(priceParam);
        } catch (NumberFormatException e) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "Price must be a valid number");
            return;
        }

        MenuItem item = new MenuItem();
        item.setRestaurantId(restaurant.getId());
        item.setName(name);
        item.setDescription(description);
        item.setPrice(price);
        item.setStockQty(stockParam != null && !stockParam.isBlank() ? Integer.parseInt(stockParam) : 0);
        item.setCategory(category);
        item.setImageUrl(imageUrl);

        JsonObject envelope = new JsonObject();
        try {
            if (idParam != null && !idParam.isBlank()) {
                item.setId(Integer.parseInt(idParam));
                menuItemDAO.update(item);
                envelope.addProperty("success", true);
                envelope.add("data", gson.toJsonTree(item));
                envelope.add("error", null);
                resp.setStatus(HttpServletResponse.SC_OK);
            } else {
                MenuItem created = menuItemDAO.create(item);
                envelope.addProperty("success", true);
                envelope.add("data", gson.toJsonTree(created));
                envelope.add("error", null);
                resp.setStatus(HttpServletResponse.SC_CREATED);
            }
        } catch (Exception e) {
            // TEMPORARY: surface the real cause in the response so it's visible
            // directly in the browser/Network tab instead of only in the
            // Tomcat console. Remove this catch (or stop sending e.toString())
            // once the bug is found and fixed.
            String detail = e.getClass().getSimpleName() + ": " + e.getMessage();
            Throwable cause = e.getCause();
            if (cause != null) {
                detail += " | caused by " + cause.getClass().getSimpleName() + ": " + cause.getMessage();
            }
            writeError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "SERVER_ERROR", detail);
            return;
        }
        resp.getWriter().write(gson.toJson(envelope));
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        if (!isOwner(req)) {
            writeError(resp, HttpServletResponse.SC_FORBIDDEN, "FORBIDDEN", "Restaurant owner access only");
            return;
        }
        HttpSession session = req.getSession(false);
        int userId = (int) session.getAttribute("userId");
        String userName = (String) session.getAttribute("userName");
        Restaurant restaurant = getOrCreateRestaurant(userId, userName != null ? userName : "My");

        String idParam = req.getParameter("id");
        if (idParam == null) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "id is required");
            return;
        }
        menuItemDAO.delete(Integer.parseInt(idParam), restaurant.getId());

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", null);
        envelope.add("error", null);
        resp.getWriter().write(gson.toJson(envelope));
    }
}