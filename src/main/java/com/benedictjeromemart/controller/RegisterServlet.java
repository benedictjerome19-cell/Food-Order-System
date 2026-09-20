package com.benedictjeromemart.controller;

import java.io.IOException;
import java.net.URLEncoder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.benedictjeromemart.service.UserService;

// FIX 1: Updated the mapping to match the HTML form exactly
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String role = req.getParameter("role");

        // Set a default role if the frontend form doesn't provide one
        if (role == null || role.trim().isEmpty()) {
            role = "CUSTOMER";
        }

        try {
            // Attempt to register the user in the PostgreSQL database
            userService.register(name, email, password, role);

            // FIX 2: Redirect to the login page on success
            String successMessage = URLEncoder.encode("Registration successful! Please sign in.", "UTF-8");
            resp.sendRedirect(req.getContextPath() + "/login.jsp?success=" + successMessage);

        } catch (IllegalArgumentException e) {
            // FIX 3: Redirect back to the register page with the error message if it fails
            String errorMessage = URLEncoder.encode(e.getMessage(), "UTF-8");
            resp.sendRedirect(req.getContextPath() + "/register.jsp?error=" + errorMessage);
        }
    }
}