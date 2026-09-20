package com.benedictjeromemart.util;

import java.sql.Connection;
import java.sql.SQLException;

import com.benedictjeromemart.listener.AppContextListener;
import com.zaxxer.hikari.HikariDataSource;

/**
 * Thin wrapper kept so existing code (UserDAOImpl, tests) keeps working.
 * It does NOT create its own connection and contains NO credentials:
 * it simply hands out connections from the single pool owned by AppContextListener.
 */
public class DBConnectionManager {

    private DBConnectionManager() {}

    public static Connection getConnection() throws SQLException {
        HikariDataSource ds = AppContextListener.getDataSource();
        if (ds == null || ds.isClosed()) {
            throw new SQLException(
                "Database is not initialized. Look for '[DB]' lines in the server startup log "
              + "(DATABASE_URL / DB_URL, DB_USERNAME, DB_PASSWORD).");
        }
        return ds.getConnection();
    }

    public static HikariDataSource getDataSource() {
        return AppContextListener.getDataSource();
    }

    /** Allows unit tests to inject a test data source. */
    public static void setDataSource(HikariDataSource ds) {
        AppContextListener.setDataSource(ds);
    }

    /** Kept for backward compatibility with existing tests; the pool is created by AppContextListener. */
    public static void initializeProductionDataSource() {
        // intentionally empty
    }
}