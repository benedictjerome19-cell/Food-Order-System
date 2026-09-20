package com.benedictjeromemart.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.Optional;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.benedictjeromemart.dao.UserDAO;
import com.benedictjeromemart.dao.UserDAOImpl;
import com.benedictjeromemart.model.User;
import com.benedictjeromemart.util.PasswordUtil;

// FIX 1: Updated the mapping to match the HTML form exactly
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        Optional<User> userOpt = userDAO.findByEmail(email);

        if (userOpt.isPresent() && PasswordUtil.verify(password, userOpt.get().getPasswordHash())) {
            User user = userOpt.get();

            // Manage session securely
            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            HttpSession session = req.getSession(true);
            session.setAttribute("userId", user.getId());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("userName", user.getName());
            session.setMaxInactiveInterval(30 * 60); // 30 min timeout

            // FIX 2: Redirect the browser to the homepage upon successful login
            resp.sendRedirect(req.getContextPath() + "/home.jsp");

        } else {
            // FIX 3: Redirect back to the login page with an error parameter if login fails
            String errorMessage = URLEncoder.encode("Invalid email or password", "UTF-8");
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=" + errorMessage);
        }
    }
}