package com.benedictjeromemart.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

// FIX 1: Update the mapping to match the HTML navigation link
@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    // FIX 2: Add doGet because clicking an HTML <a> link triggers a GET request
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        processLogout(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        processLogout(req, resp);
    }

    private void processLogout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Destroy the user session securely
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        // FIX 3: Redirect the user smoothly back to the login page
        resp.sendRedirect(req.getContextPath() + "/login.jsp");
    }
}