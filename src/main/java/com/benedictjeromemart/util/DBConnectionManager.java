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
            // Explicitly load the PostgreSQL driver to prevent "No suitable driver"
            Class.forName("org.postgresql.Driver");

            HikariConfig config = new HikariConfig();

            // Look up the standard environment variable name used by deployment platforms (like Render)
            String databaseUrl = System.getenv("DATABASE_URL");

            if (databaseUrl != null && !databaseUrl.isEmpty()) {
                // Parse Render's postgres:// or postgresql:// URL format for JDBC
                if (databaseUrl.startsWith("postgres://") || databaseUrl.startsWith("postgresql://")) {
                    URI dbUri = new URI(databaseUrl.replace("postgresql://", "postgres://"));
                    String userInfo = dbUri.getUserInfo();
                    
                    if (userInfo != null && userInfo.contains(":")) {
                        String username = userInfo.split(":")[0];
                        String password = userInfo.split(":")[1];
                        int port = dbUri.getPort() == -1 ? 5432 : dbUri.getPort();
                        String jdbcUrl = "jdbc:postgresql://" + dbUri.getHost() + ":" + port + dbUri.getPath();

                        config.setJdbcUrl(jdbcUrl);
                        config.setUsername(username);
                        config.setPassword(password);
                    } else {
                        config.setJdbcUrl(databaseUrl);
                    }
                } else {
                    config.setJdbcUrl(databaseUrl);
                }
            } else {
                // Local Development Fallback
                config.setJdbcUrl("jdbc:postgresql://localhost:5432/benedictjeromemart");
                config.setUsername("postgres");
                config.setPassword("Btechaids@2008");
            }

            config.setMaximumPoolSize(10);
            config.setMinimumIdle(2);
            config.setIdleTimeout(30000);
            config.setConnectionTimeout(30000);

            dataSource = new HikariDataSource(config);
            System.out.println("[DB] PostgreSQL Connection Pool initialized successfully!");
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

    public static HikariDataSource getDataSource() {
        return dataSource;
    }

    public static void closePool() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}