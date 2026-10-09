package com.benedictjeromemart.util;

import java.sql.Connection;
import java.sql.SQLException;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class DBConnectionManager {
    private static HikariDataSource dataSource;

    static {
        try {
            // Explicitly load the PostgreSQL driver to prevent "No suitable driver" errors
            Class.forName("org.postgresql.Driver");

            HikariConfig config = new HikariConfig();

            // Look up the standard environment variable name used by Render / Supabase
            String databaseUrl = System.getenv("DATABASE_URL");

            if (databaseUrl != null && !databaseUrl.trim().isEmpty()) {
                databaseUrl = databaseUrl.trim();
                
                // Convert Render or Supabase URL format directly to JDBC format
                if (databaseUrl.startsWith("postgres://")) {
                    databaseUrl = databaseUrl.replace("postgres://", "jdbc:postgresql://");
                } else if (databaseUrl.startsWith("postgresql://")) {
                    databaseUrl = databaseUrl.replace("postgresql://", "jdbc:postgresql://");
                }
                
                // Set the JDBC URL (PostgreSQL driver natively parses embedded credentials & percent-encoding)
                config.setJdbcUrl(databaseUrl);
            } else {
                // Local Development Fallback
                config.setJdbcUrl("jdbc:postgresql://localhost:5432/postgres");
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