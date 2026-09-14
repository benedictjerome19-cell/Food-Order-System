package com.yourname.yournameeats.controller;

import java.io.IOException;
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
import com.yourname.yournameeats.model.CartItem;
import com.yourname.yournameeats.util.GsonUtil;

@WebServlet("/api/v1/cart")
public class CartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAOImpl();
    private final Gson gson = GsonUtil.create();

    private int getUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (int) session.getAttribute("userId");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        List<CartItem> items = cartDAO.findByUser(getUserId(req));

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", gson.toJsonTree(items));
        envelope.add("error", null);
        resp.getWriter().write(gson.toJson(envelope));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        int menuItemId = Integer.parseInt(req.getParameter("menuItemId"));
        int quantity = Integer.parseInt(req.getParameter("quantity"));

        cartDAO.addOrUpdate(getUserId(req), menuItemId, quantity);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", null);
        envelope.add("error", null);
        resp.getWriter().write(gson.toJson(envelope));
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        int menuItemId = Integer.parseInt(req.getParameter("menuItemId"));

        cartDAO.remove(getUserId(req), menuItemId);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", null);
        envelope.add("error", null);
        resp.getWriter().write(gson.toJson(envelope));
    }
}