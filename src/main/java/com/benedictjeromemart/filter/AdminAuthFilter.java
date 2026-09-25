package com.benedictjeromemart.filter;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class AdminAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization logic if needed during filter startup
    }

    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        boolean authorized = false;

        if (session != null) {
            String role = (String) session.getAttribute("userRole");
            if (role != null) {
                role = role.trim().toUpperCase();
                if ("ADMIN".equals(role) || "DEVELOPER".equals(role)) {
                    authorized = true;
                }
            }
        }

        if (authorized) {
            // User is an authorized admin/developer; proceed with request
            chain.doFilter(request, response);
        } else {
            // Unauthorized access; redirect securely to login page
            res.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    @Override
    public void destroy() {
        // Cleanup logic if needed during filter shutdown
    }
}