package com.benedictjeromemart.controller;

import java.io.IOException;
import java.util.Optional;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.benedictjeromemart.dao.UserDAO;
import com.benedictjeromemart.dao.UserDAOImpl;
import com.benedictjeromemart.model.User;
import com.benedictjeromemart.util.GsonUtil;
import com.benedictjeromemart.util.PasswordUtil;

@WebServlet("/api/v1/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAOImpl();
    private final Gson gson = GsonUtil.create();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        JsonObject envelope = new JsonObject();
        Optional<User> userOpt = userDAO.findByEmail(email);

        if (userOpt.isPresent() && PasswordUtil.verify(password, userOpt.get().getPasswordHash())) {
            User user = userOpt.get();

            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            HttpSession session = req.getSession(true);
            session.setAttribute("userId", user.getId());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("userName", user.getName());
            session.setMaxInactiveInterval(30 * 60); // 30 min timeout

            JsonObject data = new JsonObject();
            data.addProperty("id", user.getId());
            data.addProperty("name", user.getName());
            data.addProperty("role", user.getRole());

            envelope.addProperty("success", true);
            envelope.add("data", data);
            envelope.add("error", null);
            resp.setStatus(HttpServletResponse.SC_OK);

        } else {
            JsonObject error = new JsonObject();
            error.addProperty("code", "AUTH_ERROR");
            error.addProperty("message", "Invalid email or password");

            envelope.addProperty("success", false);
            envelope.add("data", null);
            envelope.add("error", error);
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        }

        resp.getWriter().write(gson.toJson(envelope));
    }
}
