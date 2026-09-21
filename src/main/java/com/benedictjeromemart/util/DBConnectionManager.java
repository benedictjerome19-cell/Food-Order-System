package com.benedictjeromemart.util;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class DBConnectionManager {

    private static HikariDataSource dataSource;

    static {
        try {
            HikariConfig config = new HikariConfig();
            // Render PostgreSQL connection string with required SSL mode
            config.setJdbcUrl("jdbc:postgresql://dpg-dan44m142hec73d535bg-a/benedictjeromemart_db?sslmode=require");
            config.setUsername("benedictjeromemart_db_user");
            config.setPassword("3hAmYmzSSwaSTy9mDgUO7bs9AgiEsrQ4");
            config.setDriverClassName("org.postgresql.Driver");
            
            config.setMaximumPoolSize(5);
            config.setMinimumIdle(1);
            config.setConnectionTimeout(30000);

            dataSource = new HikariDataSource(config);
            
            // Initialize database schema
            initializeDatabase();
            
        } catch (Exception e) {
            System.err.println("CRITICAL: Failed to initialize database pool: ");
            e.printStackTrace();
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

    public static void setDataSource(HikariDataSource ds) {
        dataSource = ds;
    }

    public static void initializeProductionDataSource() {}

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
            System.err.println("CRITICAL: Error initializing database tables: " + e.getMessage());
            e.printStackTrace();
        }
    }
}