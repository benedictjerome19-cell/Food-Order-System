package com.benedictjeromemart.util;

import java.net.URI;
import java.sql.Connection;
import java.sql.SQLException;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class DBConnectionManager {
    private static HikariDataSource dataSource;

    static {
        try {
            HikariConfig config = new HikariConfig();

            // Check if running on Render or cloud environment
            String databaseUrl = System.getenv("postgresql://benedictjeromemart_db_user:3hAmYmzSSwaSTy9mDgUO7bs9AgiEsrQ4@dpg-dan44m142hec73d535bg-a/benedictjeromemart_db");

            if (databaseUrl != null && !databaseUrl.isEmpty()) {
                // Parse Render's postgres:// URL format for JDBC
                if (databaseUrl.startsWith("postgres://")) {
                    URI dbUri = new URI(databaseUrl);
                    String username = dbUri.getUserInfo().split(":")[0];
                    String password = dbUri.getUserInfo().split(":")[1];
                    String jdbcUrl = "jdbc:postgresql://" + dbUri.getHost() + ":" + dbUri.getPort() + dbUri.getPath();

                    config.setJdbcUrl(jdbcUrl);
                    config.setUsername(username);
                    config.setPassword(password);
                } else {
                    config.setJdbcUrl(databaseUrl);
                }
            } else {
                // Local Development Fallback
                config.setJdbcUrl("jdbc:postgresql://localhost:5432/jerome_zom");
                config.setUsername("postgres");
                config.setPassword("postgres");
            }

            config.setMaximumPoolSize(10);
            config.setMinimumIdle(2);
            config.setIdleTimeout(30000);
            config.setConnectionTimeout(30000);

            dataSource = new HikariDataSource(config);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to initialize database connection pool.", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            throw new SQLException("Database connection pool is not initialized.");
        }
        return dataSource.getConnection();
    }
}