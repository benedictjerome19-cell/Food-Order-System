package com.benedictjeromemart.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.benedictjeromemart.model.User;
import com.benedictjeromemart.service.UserService;
import com.benedictjeromemart.util.GsonUtil;

@WebServlet("/api/v1/register")
public class RegisterServlet extends HttpServlet {

    private final UserService userService = new UserService();
    private final Gson gson = GsonUtil.create();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");

        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String role = req.getParameter("role"); // CUSTOMER or RESTAURANT_OWNER

        JsonObject envelope = new JsonObject();

        try {
            User created = userService.register(name, email, password, role);

            JsonObject data = new JsonObject();
            data.addProperty("id", created.getId());
            data.addProperty("name", created.getName());
            data.addProperty("email", created.getEmail());
            data.addProperty("role", created.getRole());

            envelope.addProperty("success", true);
            envelope.add("data", data);
            envelope.add("error", null);

            resp.setStatus(HttpServletResponse.SC_CREATED);

        } catch (IllegalArgumentException e) {
            JsonObject error = new JsonObject();
            error.addProperty("code", "VALIDATION_ERROR");
            error.addProperty("message", e.getMessage());

            envelope.addProperty("success", false);
            envelope.add("data", null);
            envelope.add("error", error);

            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }

        resp.getWriter().write(gson.toJson(envelope));
    }
}