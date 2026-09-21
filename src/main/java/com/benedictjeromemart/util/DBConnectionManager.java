package com.benedictjeromemart.util;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

/**
 * Manages database connections using HikariCP and connects directly 
 * to the Render PostgreSQL database.
 */
public class DBConnectionManager {

    private static HikariDataSource dataSource;

    static {
        try {
            HikariConfig config = new HikariConfig();
            // Render PostgreSQL connection details
            config.setJdbcUrl("jdbc:postgresql://dpg-dan44m142hec73d535bg-a/benedictjeromemart_db");
            config.setUsername("benedictjeromemart_db_user");
            config.setPassword("3hAmYmzSSwaSTy9mDgUO7bs9AgiEsrQ4");
            config.setDriverClassName("org.postgresql.Driver");
            
            // Connection pool tuning parameters for cloud stability
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(2);
            config.setIdleTimeout(30000);
            config.setConnectionTimeout(30000);

            dataSource = new HikariDataSource(config);
            
            // Automatically initialize database tables on startup
            initializeDatabase();
            
        } catch (Exception e) {
            System.err.println("Failed to initialize HikariCP connection pool: " + e.getMessage());
        }
    }

    private DBConnectionManager() {}

    public static Connection getConnection() throws SQLException {
        if (dataSource == null || dataSource.isClosed()) {
            throw new SQLException("Database connection pool is not initialized.");
        }
        return dataSource.getConnection();
    }

    public static HikariDataSource getDataSource() {
        return dataSource;
    }

    /** Allows unit tests to inject a test data source. */
    public static void setDataSource(HikariDataSource ds) {
        dataSource = ds;
    }

    public static void initializeProductionDataSource() {
        // Handled automatically by the static block
    }

    private static void initializeDatabase() {
        String createUsersTable = "CREATE TABLE IF NOT EXISTS users (" +
                "id SERIAL PRIMARY KEY, " +
                "fullname VARCHAR(100) NOT NULL, " +
                "email VARCHAR(100) UNIQUE NOT NULL, " +
                "password VARCHAR(255) NOT NULL, " +
                "role VARCHAR(50) DEFAULT 'customer'" +
                ");";

        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute(createUsersTable);
            System.out.println("[DB] Users table verified/created successfully in PostgreSQL.");
        } catch (SQLException e) {
            System.err.println("Error initializing database tables: " + e.getMessage());
        }
    }
}