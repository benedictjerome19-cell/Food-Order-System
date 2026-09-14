# Fix: Cart, Payment, and Order History

## Root causes
1. **Cart display bug** — `CartServlet` returned a raw array `[...]`, but the
   JavaScript in `home.jsp` expects an object shape: `{ items: [...] }`. The
   cart items also never carried the item's `name` or `price` — only
   `menuItemId` and `quantity` — so even a shape fix alone wouldn't show
   anything useful.
2. **Payment blocked** — the Pay button stays disabled whenever the cart
   *looks* empty. Since the cart always looked empty (bug #1), payment could
   never be triggered — the checkout backend itself was actually fine.
3. **Order history crash** — `Order.createdAt` is a `LocalDateTime`, which
   Gson can't serialize by default without help.

Fix: a proper SQL join so cart items carry their name/price, a response shape
that matches what the JS expects, and a shared Gson instance that knows how
to handle dates.

Package: `com.yourname.yournameeats`. Full replacements unless marked NEW.

---

## 1. JsonUtil — NEW FILE (if you don't already have this from before)
Path: `src/main/java/com/yourname/yournameeats/util/JsonUtil.java`

```java
package com.yourname.yournameeats.util;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class JsonUtil {

    private static final DateTimeFormatter FORMATTER =
        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public static final Gson GSON = new GsonBuilder()
        .registerTypeAdapter(LocalDateTime.class,
            (JsonSerializer<LocalDateTime>) (src, typeOfSrc, context) ->
                src == null ? null : new JsonPrimitive(src.format(FORMATTER)))
        .create();
}
```

---

## 2. CartDAO — FULL REPLACEMENT (adds a joined "detailed" cart lookup)
Path: `src/main/java/com/yourname/yournameeats/dao/CartDAO.java`

```java
package com.yourname.yournameeats.dao;

import com.yourname.yournameeats.model.CartItem;
import java.util.List;
import java.util.Map;

public interface CartDAO {
    void addOrUpdate(int userId, int menuItemId, int quantity);
    void remove(int userId, int menuItemId);
    List<CartItem> findByUser(int userId);
    List<Map<String, Object>> findDetailedByUser(int userId);
    void clearCart(int userId);
}
```

Path: `src/main/java/com/yourname/yournameeats/dao/CartDAOImpl.java`

```java
package com.yourname.yournameeats.dao;

import com.yourname.yournameeats.listener.AppContextListener;
import com.yourname.yournameeats.model.CartItem;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CartDAOImpl implements CartDAO {

    @Override
    public void addOrUpdate(int userId, int menuItemId, int quantity) {
        String checkSql = "SELECT id FROM cart_items WHERE user_id = ? AND menu_item_id = ?";
        String updateSql = "UPDATE cart_items SET quantity = ? WHERE id = ?";
        String insertSql = "INSERT INTO cart_items (user_id, menu_item_id, quantity) VALUES (?, ?, ?)";

        try (Connection conn = AppContextListener.getDataSource().getConnection()) {

            try (PreparedStatement check = conn.prepareStatement(checkSql)) {
                check.setInt(1, userId);
                check.setInt(2, menuItemId);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next()) {
                        int cartItemId = rs.getInt("id");
                        try (PreparedStatement update = conn.prepareStatement(updateSql)) {
                            update.setInt(1, quantity);
                            update.setInt(2, cartItemId);
                            update.executeUpdate();
                        }
                        return;
                    }
                }
            }

            try (PreparedStatement insert = conn.prepareStatement(insertSql)) {
                insert.setInt(1, userId);
                insert.setInt(2, menuItemId);
                insert.setInt(3, quantity);
                insert.executeUpdate();
            }

        } catch (SQLException e) {
            throw new RuntimeException("Failed to add/update cart item", e);
        }
    }

    @Override
    public void remove(int userId, int menuItemId) {
        String sql = "DELETE FROM cart_items WHERE user_id = ? AND menu_item_id = ?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, menuItemId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to remove cart item", e);
        }
    }

    @Override
    public List<CartItem> findByUser(int userId) {
        String sql = "SELECT * FROM cart_items WHERE user_id = ?";
        List<CartItem> results = new ArrayList<>();
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setId(rs.getInt("id"));
                    item.setUserId(rs.getInt("user_id"));
                    item.setMenuItemId(rs.getInt("menu_item_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    results.add(item);
                }
            }
            return results;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to fetch cart", e);
        }
    }

    /**
     * Joins cart_items with menu_items so the frontend gets name/price
     * directly, without a second round-trip per item.
     */
    @Override
    public List<Map<String, Object>> findDetailedByUser(int userId) {
        String sql = "SELECT ci.id AS cart_item_id, ci.menu_item_id, ci.quantity, " +
                     "mi.name, mi.price " +
                     "FROM cart_items ci " +
                     "JOIN menu_items mi ON ci.menu_item_id = mi.id " +
                     "WHERE ci.user_id = ?";
        List<Map<String, Object>> results = new ArrayList<>();
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("cartItemId", rs.getInt("cart_item_id"));
                    row.put("menuItemId", rs.getInt("menu_item_id"));
                    row.put("name", rs.getString("name"));
                    row.put("price", rs.getBigDecimal("price"));
                    row.put("quantity", rs.getInt("quantity"));
                    results.add(row);
                }
            }
            return results;
        } catch (SQLException e) {
            throw new RuntimeException("Failed to fetch detailed cart", e);
        }
    }

    @Override
    public void clearCart(int userId) {
        String sql = "DELETE FROM cart_items WHERE user_id = ?";
        try (Connection conn = AppContextListener.getDataSource().getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Failed to clear cart", e);
        }
    }
}
```

---

## 3. CartServlet — FULL REPLACEMENT (returns the shape home.jsp actually expects)
Path: `src/main/java/com/yourname/yournameeats/controller/CartServlet.java`

```java
package com.yourname.yournameeats.controller;

import com.google.gson.JsonObject;
import com.yourname.yournameeats.dao.CartDAO;
import com.yourname.yournameeats.dao.CartDAOImpl;
import com.yourname.yournameeats.util.JsonUtil;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/api/v1/cart")
public class CartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAOImpl();

    private int getUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (int) session.getAttribute("userId");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        List<Map<String, Object>> items = cartDAO.findDetailedByUser(getUserId(req));

        // Wrap in {items: [...]} — this is the exact shape home.jsp's
        // loadCart() checks for (result.data.items).
        JsonObject data = new JsonObject();
        data.add("items", JsonUtil.GSON.toJsonTree(items));

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", data);
        envelope.add("error", null);
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        int menuItemId = Integer.parseInt(req.getParameter("menuItemId"));
        int quantity = Integer.parseInt(req.getParameter("quantity"));

        cartDAO.addOrUpdate(getUserId(req), menuItemId, quantity);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", null);
        envelope.add("error", null);
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        int menuItemId = Integer.parseInt(req.getParameter("menuItemId"));

        cartDAO.remove(getUserId(req), menuItemId);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", null);
        envelope.add("error", null);
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }
}
```

---

## 4. OrderServlet — FULL REPLACEMENT (unchanged logic, now uses JsonUtil consistently)
Path: `src/main/java/com/yourname/yournameeats/controller/OrderServlet.java`

```java
package com.yourname.yournameeats.controller;

import com.google.gson.JsonObject;
import com.yourname.yournameeats.dao.*;
import com.yourname.yournameeats.model.CartItem;
import com.yourname.yournameeats.model.MenuItem;
import com.yourname.yournameeats.util.JsonUtil;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/api/v1/orders")
public class OrderServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAOImpl();
    private final MenuItemDAO menuItemDAO = new MenuItemDAOImpl();
    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        HttpSession session = req.getSession(false);
        int userId = (int) session.getAttribute("userId");

        List<CartItem> cartItems = cartDAO.findByUser(userId);
        JsonObject envelope = new JsonObject();

        if (cartItems.isEmpty()) {
            JsonObject error = new JsonObject();
            error.addProperty("code", "EMPTY_CART");
            error.addProperty("message", "Cannot checkout an empty cart");
            envelope.addProperty("success", false);
            envelope.add("data", null);
            envelope.add("error", error);
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
            return;
        }

        BigDecimal total = BigDecimal.ZERO;
        int restaurantId = 0;
        for (CartItem item : cartItems) {
            MenuItem menuItem = menuItemDAO.findById(item.getMenuItemId());
            total = total.add(menuItem.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            restaurantId = menuItem.getRestaurantId();
        }

        int orderId = orderDAO.placeOrder(userId, restaurantId, cartItems, total);

        JsonObject data = new JsonObject();
        data.addProperty("orderId", orderId);
        data.addProperty("total", total);
        data.addProperty("status", "PENDING");

        envelope.addProperty("success", true);
        envelope.add("data", data);
        envelope.add("error", null);
        resp.setStatus(HttpServletResponse.SC_CREATED);
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }
}
```

---

## 5. OrderHistoryServlet — FULL REPLACEMENT (the Gson date fix, in case not applied yet)
Path: `src/main/java/com/yourname/yournameeats/controller/OrderHistoryServlet.java`

```java
package com.yourname.yournameeats.controller;

import com.google.gson.JsonObject;
import com.yourname.yournameeats.dao.*;
import com.yourname.yournameeats.model.Order;
import com.yourname.yournameeats.model.Restaurant;
import com.yourname.yournameeats.util.JsonUtil;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

@WebServlet("/api/v1/orders/history")
public class OrderHistoryServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAOImpl();
    private final RestaurantDAO restaurantDAO = new RestaurantDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"success\":false,\"data\":null,\"error\":{\"code\":\"UNAUTHENTICATED\",\"message\":\"Login required\"}}");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String role = (String) session.getAttribute("userRole");

        List<Order> orders;
        if ("RESTAURANT_OWNER".equals(role)) {
            Optional<Restaurant> restaurant = restaurantDAO.findByOwnerId(userId);
            orders = restaurant.isPresent() ? orderDAO.findByRestaurantId(restaurant.get().getId()) : List.of();
        } else {
            orders = orderDAO.findByBuyerId(userId);
        }

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", JsonUtil.GSON.toJsonTree(orders));
        envelope.add("error", null);
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }
}
```

---

## Terminal commands — rebuild, redeploy, run

```
cd D:\benedictmart\benedictmart\jerome_zom
mvn clean package
```
**Confirm `BUILD SUCCESS`.**

```
cd D:\benedictmart\benedictmart\jerome_zom\tomcat\bin
.\shutdown.bat
```
Wait 5 seconds.
```
Remove-Item -Recurse -Force "D:\benedictmart\benedictmart\jerome_zom\tomcat\webapps\benedictjeromemart" -ErrorAction SilentlyContinue
Copy-Item "D:\benedictmart\benedictmart\jerome_zom\target\benedictjeromemart.war" -Destination "D:\benedictmart\benedictmart\jerome_zom\tomcat\webapps\" -Force
.\startup.bat
```

## Test it

```
http://localhost:8080/benedictjeromemart/home.jsp
```

1. Add an item to cart — it should now show its **name and price** in the cart panel, and the totals (subtotal/tax/total) should calculate correctly
2. The **Pay button should now enable** once something is in the cart
3. Complete checkout — you should see the success overlay with an order ID
4. Go to `orders.jsp` — the order should now appear with its status and total, no crash

---

If cart still shows empty after this, the most likely remaining cause is a
stale browser cache of `home.jsp`'s JavaScript — do a hard refresh
(`Ctrl+Shift+R`) before testing.
