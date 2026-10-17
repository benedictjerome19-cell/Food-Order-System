package com.benedictjeromemart.filter;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebFilter("/api/v1/*")
public class AuthFilter implements Filter {

    // Endpoints that don't require login
    private static final String[] PUBLIC_PATHS = {
        "/api/v1/register", "/api/v1/login", "/api/v1/health", "/health", "/api/health",
        "/api/v1/menu-items", "/api/v1/restaurants", "/api/chat", "/api/v1/chat",
        "/api/v1/debug/db"
    };

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // no setup needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = (contextPath != null && !contextPath.isEmpty() && uri.startsWith(contextPath))
                ? uri.substring(contextPath.length())
                : uri;

        boolean isPublic = false;
        for (String publicPath : PUBLIC_PATHS) {
            if (path.equals(publicPath) || path.startsWith(publicPath + "/") || uri.endsWith(publicPath)) {
                isPublic = true;
                break;
            }
        }

        if (isPublic) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.setContentType("application/json");
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write(
                "{\"success\":false,\"data\":null,\"error\":{\"code\":\"UNAUTHENTICATED\",\"message\":\"Login required\"}}"
            );
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // no cleanup needed
    }
}