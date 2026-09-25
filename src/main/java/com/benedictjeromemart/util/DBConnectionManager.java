package com.benedictjeromemart.util;

import java.net.URI;
import java.sql.Connection;
import java.sql.SQLException;

import javax.sql.DataSource;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class DBConnectionManager {
    private static HikariDataSource dataSource;

    static {
        try {
            HikariConfig config = new HikariConfig();

            // Look up the environment variable key set on Render
            String databaseUrl = System.getenv("DATABASE_URL");
            if (databaseUrl == null || databaseUrl.isEmpty()) {
                databaseUrl = System.getenv("JDBC_DATABASE_URL");
            }

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

    public static DataSource getDataSource() {
        return dataSource;
    }

    public static void closePool() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}