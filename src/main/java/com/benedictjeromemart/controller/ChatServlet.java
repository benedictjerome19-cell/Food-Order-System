package com.benedictjeromemart.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.JsonObject;
import com.benedictjeromemart.chat.ChatProvider;
import com.benedictjeromemart.chat.GeminiChatProvider;
import com.benedictjeromemart.chat.MockChatProvider;
import com.benedictjeromemart.dao.MenuItemDAO;
import com.benedictjeromemart.dao.MenuItemDAOImpl;
import com.benedictjeromemart.model.MenuItem;
import com.benedictjeromemart.util.JsonUtil;

@WebServlet("/api/v1/chat-legacy")
public class ChatServlet extends HttpServlet {

    private static final int MAX_MESSAGES_PER_WINDOW = 10;
    private static final long WINDOW_MILLIS = 60_000L;
    private static final int MAX_INPUT_LENGTH = 300;
    private static final int SC_TOO_MANY_REQUESTS = 429;

    private final MockChatProvider fallbackProvider = new MockChatProvider();
    private final MenuItemDAO menuItemDAO = new MenuItemDAOImpl();

    private ChatProvider selectProvider() {
        String flag = System.getProperty("ai.chatbot.provider", "mock");
        if ("gemini".equalsIgnoreCase(flag)) {
            try {
                return new GeminiChatProvider();
            } catch (Exception e) {
                return fallbackProvider;
            }
        }
        return fallbackProvider;
    }

    private String buildMenuContext() {
        List<MenuItem> items = menuItemDAO.search(null, null);
        if (items == null || items.isEmpty()) return null;

        StringBuilder sb = new StringBuilder();
        int limit = Math.min(items.size(), 30);
        for (int i = 0; i < limit; i++) {
            MenuItem item = items.get(i);
            sb.append("- ").append(item.getName())
              .append(": Rs.").append(item.getPrice())
              .append(" (").append(item.getCategory() != null ? item.getCategory() : "General")
              .append(", stock: ").append(item.getStockQty())
              .append(")\n");
        }
        return sb.toString();
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

    @SuppressWarnings("unchecked")
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");

        HttpSession session = req.getSession(true);
        String message = req.getParameter("message");

        if (message == null || message.isBlank()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "message is required");
            return;
        }
        if (message.length() > MAX_INPUT_LENGTH) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR",
                "message must be " + MAX_INPUT_LENGTH + " characters or fewer");
            return;
        }

        // ---- Rate limiting ----
        List<Long> timestamps = (List<Long>) session.getAttribute("chatTimestamps");
        if (timestamps == null) timestamps = new ArrayList<>();

        long now = System.currentTimeMillis();
        timestamps.removeIf(t -> now - t > WINDOW_MILLIS);

        if (timestamps.size() >= MAX_MESSAGES_PER_WINDOW) {
            writeError(resp, SC_TOO_MANY_REQUESTS, "RATE_LIMITED",
                "Too many messages, please wait a moment before trying again");
            return;
        }
        timestamps.add(now);
        session.setAttribute("chatTimestamps", timestamps);

        // ---- Session Cache ----
        Map<String, String> cache = (Map<String, String>) session.getAttribute("chatCache");
        if (cache == null) cache = new HashMap<>();

        String cacheKey = message.trim().toLowerCase();
        String reply;

        if (cache.containsKey(cacheKey)) {
            reply = cache.get(cacheKey);
        } else {
            ChatProvider provider = selectProvider();
            try {
                String context = buildMenuContext();
                reply = provider.getReply(message, context);
            } catch (Exception e) {
                try {
                    reply = fallbackProvider.getReply(message, null);
                } catch (Exception ignored) {
                    reply = "Sorry, I'm having trouble answering right now. " +
                            "You can browse the menu or check Order History directly.";
                }
            }
            cache.put(cacheKey, reply);
            session.setAttribute("chatCache", cache);
        }

        JsonObject data = new JsonObject();
        data.addProperty("reply", reply);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", data);
        envelope.add("error", null);
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }
}
