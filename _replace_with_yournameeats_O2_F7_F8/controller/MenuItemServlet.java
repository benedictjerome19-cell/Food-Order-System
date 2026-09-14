package com.yourname.yournameeats.controller;

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
import com.yourname.yournameeats.dao.MenuItemDAO;
import com.yourname.yournameeats.dao.MenuItemDAOImpl;
import com.yourname.yournameeats.model.MenuItem;

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
        String keyword = req.getParameter("keyword");
        String category = req.getParameter("category");

        List<MenuItem> items = menuItemDAO.search(keyword, category);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", gson.toJsonTree(items));
        envelope.add("error", null);

        resp.getWriter().write(gson.toJson(envelope));
    }
}
