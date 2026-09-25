package com.benedictjeromemart.listener;

import java.sql.Connection;
import java.sql.SQLException;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import com.benedictjeromemart.util.DBConnectionManager;
import com.zaxxer.hikari.HikariDataSource;

@WebListener
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[DB] Application starting up and verifying PostgreSQL connection...");
        try {
            // Verify connection pool through DBConnectionManager
            try (Connection conn = DBConnectionManager.getConnection()) {
                if (conn != null && !conn.isClosed()) {
                    System.out.println("[DB] Successfully connected to the PostgreSQL database.");
                }
            }
            
            // Expose datasource attribute in servlet context
            HikariDataSource ds = DBConnectionManager.getDataSource();
            if (ds != null && sce != null && sce.getServletContext() != null) {
                sce.getServletContext().setAttribute("dataSource", ds);
            }
        } catch (SQLException e) {
            System.err.println("[DB] CRITICAL: Failed to connect to database during startup: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[DB] Application shutting down. Closing database connection pool...");
        DBConnectionManager.closePool();
    }
}
