package com.benedictjeromemart.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.JsonObject;
import com.benedictjeromemart.chat.ChatProvider;
import com.benedictjeromemart.chat.GeminiChatProvider;
import com.benedictjeromemart.chat.MockChatProvider;
import com.benedictjeromemart.dao.CartDAO;
import com.benedictjeromemart.dao.CartDAOImpl;
import com.benedictjeromemart.dao.MenuItemDAO;
import com.benedictjeromemart.dao.MenuItemDAOImpl;
import com.benedictjeromemart.model.CartItem;
import com.benedictjeromemart.model.MenuItem;
import com.benedictjeromemart.util.JsonUtil;

@WebServlet(urlPatterns = {"/api/chat", "/api/v1/chat"})
public class ChatbotServlet extends HttpServlet {

    private static final int MAX_MESSAGES_PER_WINDOW = 10;
    private static final long WINDOW_MILLIS = 60_000L;
    private static final int MAX_INPUT_LENGTH = 300;

    private final MockChatProvider fallbackProvider = new MockChatProvider();
    private final MenuItemDAO menuItemDAO = new MenuItemDAOImpl();
    private final CartDAO cartDAO = new CartDAOImpl();

    private ChatProvider selectProvider() {
        try {
            return new GeminiChatProvider();
        } catch (Exception e) {
            return fallbackProvider;
        }
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
              .append(", stock: ").append(item.getStockQty()).append(")\n");
        }
        return sb.toString();
    }

    private String processAdminOrCustomerCommands(String msg, Integer userId) {
        String lower = msg.toLowerCase().trim();

        // 1. Admin DB Update: "Set <Item> price to <15.99>"
        Pattern setPricePattern = Pattern.compile("(?:set|update)\\s+(.+?)\\s+price\\s+to\\s+(?:rs\\.?\\s*)?(\\d+(?:\\.\\d+)?)", Pattern.CASE_INSENSITIVE);
        Matcher setPriceMatcher = setPricePattern.matcher(msg);
        if (setPriceMatcher.find()) {
            String item = setPriceMatcher.group(1).trim();
            double price = Double.parseDouble(setPriceMatcher.group(2));
            boolean updated = menuItemDAO.updatePriceByName(item, price);
            if (updated) {
                return "⚡ Live DB Confirmed: Updated price of '" + item + "' to Rs." + String.format("%.2f", price) + ".";
            } else {
                return "⚠️ Item matching '" + item + "' was not found in database.";
            }
        }

        // 2. Admin DB Update: "Mark <Item> as out of stock / in stock"
        if (lower.contains("out of stock") || lower.contains("in stock")) {
            boolean available = !lower.contains("out of stock");
            Pattern stockPattern = Pattern.compile("mark\\s+(.+?)\\s+as", Pattern.CASE_INSENSITIVE);
            Matcher stockMatcher = stockPattern.matcher(msg);
            String item = stockMatcher.find() ? stockMatcher.group(1).trim() : msg.replaceAll("(?i)(mark|as|out of stock|in stock)", "").trim();
            boolean updated = menuItemDAO.updateAvailabilityByName(item, available);
            if (updated) {
                return "⚡ Live DB Confirmed: Marked '" + item + "' as " + (available ? "Available (In Stock)" : "Out of Stock") + ".";
            }
        }

        // 3. Admin DB Update: "Update stock of <Item> to <100>"
        Pattern updateStockPattern = Pattern.compile("(?:update|set)\\s+stock\\s+of\\s+(.+?)\\s+to\\s+(\\d+)", Pattern.CASE_INSENSITIVE);
        Matcher updateStockMatcher = updateStockPattern.matcher(msg);
        if (updateStockMatcher.find()) {
            String item = updateStockMatcher.group(1).trim();
            int qty = Integer.parseInt(updateStockMatcher.group(2));
            boolean updated = menuItemDAO.updateStockByName(item, qty);
            if (updated) {
                return "⚡ Live DB Confirmed: Stock for '" + item + "' updated to " + qty + " units.";
            }
        }

        // 4. Customer Cart Operation: "Add <Item> to cart"
        if (lower.startsWith("add ") && lower.contains("to cart")) {
            String itemName = lower.substring(4, lower.indexOf("to cart")).trim();
            List<MenuItem> matches = menuItemDAO.search(itemName, null);
            if (matches != null && !matches.isEmpty()) {
                MenuItem item = matches.get(0);
                if (userId != null && userId > 0) {
                    cartDAO.addOrUpdate(userId, item.getId(), 1);
                    return "🛒 Added '" + item.getName() + "' (Rs." + item.getPrice() + ") to your live cart!";
                } else {
                    return "🛒 Found '" + item.getName() + "'! Please login to add items directly to your cart.";
                }
            }
        }

        return null;
    }

    private void writeError(HttpServletResponse resp, int status, String code, String message) throws IOException {
        JsonObject error = new JsonObject();
        error.addProperty("code", code);
        error.addProperty("message", message);
        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", false);
        envelope.addProperty("reply", message);
        envelope.add("data", null);
        envelope.add("error", error);
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");
        String message = req.getParameter("message");

        if (message == null || message.isBlank()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "Message is required");
            return;
        }

        if (message.length() > MAX_INPUT_LENGTH) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "Message exceeds " + MAX_INPUT_LENGTH + " characters");
            return;
        }

        // Rate Limiter (10 msg/min)
        List<Long> timestamps = (List<Long>) session.getAttribute("chatTimestamps");
        if (timestamps == null) timestamps = new ArrayList<>();
        long now = System.currentTimeMillis();
        timestamps.removeIf(t -> now - t > WINDOW_MILLIS);
        if (timestamps.size() >= MAX_MESSAGES_PER_WINDOW) {
            writeError(resp, 429, "RATE_LIMITED", "Too many messages. Please wait a minute before trying again.");
            return;
        }
        timestamps.add(now);
        session.setAttribute("chatTimestamps", timestamps);

        // Session Cache
        Map<String, String> cache = (Map<String, String>) session.getAttribute("chatCache");
        if (cache == null) cache = new HashMap<>();

        String cacheKey = message.trim().toLowerCase();
        String reply;

        if (cache.containsKey(cacheKey)) {
            reply = cache.get(cacheKey);
        } else {
            // Check for direct DB admin commands or cart intents
            String commandReply = processAdminOrCustomerCommands(message, userId);
            if (commandReply != null) {
                reply = commandReply;
            } else {
                ChatProvider provider = selectProvider();
                try {
                    String context = buildMenuContext();
                    reply = provider.getReply(message, context);
                } catch (Exception e) {
                    reply = fallbackProvider.getReply(message, null);
                }
            }
            cache.put(cacheKey, reply);
            session.setAttribute("chatCache", cache);
        }

        JsonObject data = new JsonObject();
        data.addProperty("reply", reply);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.addProperty("reply", reply); // Top-level reply for flat JS access
        envelope.add("data", data);          // Nested reply for data.reply JS access
        envelope.add("error", null);

        resp.setStatus(HttpServletResponse.SC_OK);
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }
}
