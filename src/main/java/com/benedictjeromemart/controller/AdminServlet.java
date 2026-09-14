package com.benedictjeromemart.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.JsonObject;
import com.benedictjeromemart.dao.MenuItemDAO;
import com.benedictjeromemart.dao.MenuItemDAOImpl;
import com.benedictjeromemart.dao.OrderDAO;
import com.benedictjeromemart.dao.OrderDAOImpl;
import com.benedictjeromemart.dao.UserDAO;
import com.benedictjeromemart.dao.UserDAOImpl;
import com.benedictjeromemart.model.AdminUserView;
import com.benedictjeromemart.model.User;
import com.benedictjeromemart.util.JsonUtil;

@WebServlet(urlPatterns = {
    "/api/v1/admin/users",
    "/api/v1/admin/orders",
    "/api/v1/admin/menu-items"
})
public class AdminServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAOImpl();
    private final OrderDAO orderDAO = new OrderDAOImpl();
    private final MenuItemDAO menuItemDAO = new MenuItemDAOImpl();

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null && "ADMIN".equals(session.getAttribute("userRole"));
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
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }

    private void writeOk(HttpServletResponse resp, Object data) throws IOException {
        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", JsonUtil.GSON.toJsonTree(data));
        envelope.add("error", null);
        resp.setContentType("application/json");
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (!isAdmin(req)) {
            writeError(resp, HttpServletResponse.SC_FORBIDDEN, "FORBIDDEN", "Admin access only");
            return;
        }

        String path = req.getServletPath();
        if (path.endsWith("/admin/users")) {
            List<AdminUserView> views = new ArrayList<>();
            for (User u : userDAO.findAll()) {
                views.add(new AdminUserView(u));
            }
            writeOk(resp, views);
        } else if (path.endsWith("/admin/orders")) {
            writeOk(resp, orderDAO.findAll());
        } else {
            writeError(resp, HttpServletResponse.SC_NOT_FOUND, "NOT_FOUND", "Unknown admin resource");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (!isAdmin(req)) {
            writeError(resp, HttpServletResponse.SC_FORBIDDEN, "FORBIDDEN", "Admin access only");
            return;
        }

        String path = req.getServletPath();
        if (path.endsWith("/admin/menu-items")) {
            String idParam = req.getParameter("id");
            if (idParam == null || idParam.isBlank()) {
                writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "id is required");
                return;
            }
            menuItemDAO.deleteById(Integer.parseInt(idParam));
            writeOk(resp, null);
        } else {
            writeError(resp, HttpServletResponse.SC_NOT_FOUND, "NOT_FOUND", "Unknown admin resource");
        }
    }
}
