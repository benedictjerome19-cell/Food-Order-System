package com.yourname.yournameeats.controller;

import java.io.IOException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.JsonObject;
import com.yourname.yournameeats.dao.OrderDAO;
import com.yourname.yournameeats.dao.OrderDAOImpl;
import com.yourname.yournameeats.dao.ReviewDAO;
import com.yourname.yournameeats.dao.ReviewDAOImpl;
import com.yourname.yournameeats.model.Review;
import com.yourname.yournameeats.util.JsonUtil;

@WebServlet("/api/v1/reviews")
public class ReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAOImpl();
    private final OrderDAO orderDAO = new OrderDAOImpl();

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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        String restaurantIdParam = req.getParameter("restaurantId");
        if (restaurantIdParam == null || restaurantIdParam.isBlank()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "restaurantId is required");
            return;
        }
        int restaurantId = Integer.parseInt(restaurantIdParam);

        JsonObject data = new JsonObject();
        data.add("reviews", JsonUtil.GSON.toJsonTree(reviewDAO.findByRestaurantId(restaurantId)));
        data.addProperty("averageRating", reviewDAO.findAverageRating(restaurantId));

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", data);
        envelope.add("error", null);
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        HttpSession session = req.getSession(false);
        int userId = (int) session.getAttribute("userId");

        String restaurantIdParam = req.getParameter("restaurantId");
        String ratingParam = req.getParameter("rating");
        String comment = req.getParameter("comment");

        if (restaurantIdParam == null || restaurantIdParam.isBlank()
                || ratingParam == null || ratingParam.isBlank()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR",
                "restaurantId and rating are required");
            return;
        }

        int restaurantId;
        int rating;
        try {
            restaurantId = Integer.parseInt(restaurantIdParam);
            rating = Integer.parseInt(ratingParam);
        } catch (NumberFormatException e) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "restaurantId/rating must be numbers");
            return;
        }
        if (rating < 1 || rating > 5) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "rating must be between 1 and 5");
            return;
        }

        if (!orderDAO.hasDeliveredOrder(userId, restaurantId)) {
            writeError(resp, HttpServletResponse.SC_FORBIDDEN, "REVIEW_NOT_ALLOWED",
                "You can only review restaurants you have a completed (DELIVERED) order from");
            return;
        }

        Review review = reviewDAO.upsert(restaurantId, userId, rating, comment);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", JsonUtil.GSON.toJsonTree(review));
        envelope.add("error", null);
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }
}
