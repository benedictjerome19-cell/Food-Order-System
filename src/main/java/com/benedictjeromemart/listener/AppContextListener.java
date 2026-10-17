package com.benedictjeromemart.listener;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

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
        try (Connection conn = DBConnectionManager.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("[DB] Successfully connected to the PostgreSQL database.");
                initDatabase(conn);
            }

            // Expose datasource attribute in servlet context
            HikariDataSource ds = DBConnectionManager.getDataSource();
            if (ds != null && sce != null && sce.getServletContext() != null) {
                sce.getServletContext().setAttribute("dataSource", ds);
            }
        } catch (Exception e) {
            System.err.println("[DB] CRITICAL: Database initialization warning: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void initDatabase(Connection conn) {
        try {
            System.out.println("[DB] Applying database schema migrations...");
            executeSqlScript(conn, "schema-postgres.sql");

            boolean needSeed = false;
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM users")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    needSeed = true;
                }
            } catch (SQLException e) {
                needSeed = true;
            }

            if (needSeed) {
                System.out.println("[DB] Empty or new database detected. Seeding initial data from data-postgres.sql...");
                executeSqlScript(conn, "data-postgres.sql");
                System.out.println("[DB] Initial data seeded successfully!");
            } else {
                System.out.println("[DB] Database already contains data. Skipped seed data.");
            }
        } catch (Exception e) {
            System.err.println("[DB] Error initializing schema/seed: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void executeSqlScript(Connection conn, String resourceName) {
        try (InputStream in = getClass().getClassLoader().getResourceAsStream(resourceName)) {
            if (in == null) {
                System.err.println("[DB] Could not find SQL script in resources: " + resourceName);
                return;
            }
            String sql = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            try (Statement stmt = conn.createStatement()) {
                stmt.execute(sql);
                System.out.println("[DB] Successfully executed: " + resourceName);
            }
        } catch (Exception e) {
            System.err.println("[DB] Script execution notice for " + resourceName + ": " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[DB] Application shutting down. Closing database connection pool...");
        DBConnectionManager.closePool();
    }
}

