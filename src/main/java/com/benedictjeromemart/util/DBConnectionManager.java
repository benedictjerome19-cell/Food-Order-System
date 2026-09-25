package com.benedictjeromemart.util;

import java.sql.Connection;
import java.sql.SQLException;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class DBConnectionManager {
    private static HikariDataSource dataSource;
    private static String initErrorDetail = "Not initialized yet";

    static {
        try {
            // Explicitly load the PostgreSQL driver
            Class.forName("org.postgresql.Driver");

            HikariConfig config = new HikariConfig();
            
            config.setJdbcUrl("jdbc:postgresql://localhost:5432/benedictjeromemart");
            config.setUsername("postgres");
            
            // ---> PUT YOUR ACTUAL POSTGRESQL PASSWORD HERE <---
            config.setPassword("Btechaids@2008");

            config.setMaximumPoolSize(10);
            config.setMinimumIdle(2);
            config.setIdleTimeout(30000);
            config.setConnectionTimeout(30000);

            dataSource = new HikariDataSource(config);
            System.out.println("[DB] HikariCP PostgreSQL DataSource initialized successfully.");
        } catch (Throwable e) {
            initErrorDetail = e.getClass().getName() + ": " + e.getMessage();
            System.err.println("[DB] FATAL ERROR: Failed to initialize HikariCP connection pool: " + initErrorDetail);
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            throw new SQLException("Database connection pool is not initialized. Root cause: " + initErrorDetail);
        }
        return dataSource.getConnection();
    }

    public static HikariDataSource getDataSource() {
        return dataSource;
    }

    public static void closePool() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            System.out.println("[DB] HikariCP PostgreSQL DataSource closed successfully.");
        }
    }
}