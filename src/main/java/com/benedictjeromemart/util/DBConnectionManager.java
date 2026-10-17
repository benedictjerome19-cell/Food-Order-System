package com.benedictjeromemart.util;

import java.io.InputStream;
import java.net.URI;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class DBConnectionManager {
    private static final Logger LOGGER = Logger.getLogger(DBConnectionManager.class.getName());
    private static volatile HikariDataSource dataSource;
    private static final Object LOCK = new Object();

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "PostgreSQL Driver not found on classpath", e);
        }
        initPool();
    }

    private static void initPool() {
        synchronized (LOCK) {
            if (dataSource != null && !dataSource.isClosed()) {
                return;
            }

            try {
                HikariConfig config = new HikariConfig();
                config.setDriverClassName("org.postgresql.Driver");

                // Check environment variables for cloud deployment (Render, Supabase, etc.)
                String rawUrl = System.getenv("DATABASE_URL");
                if (rawUrl == null || rawUrl.trim().isEmpty()) {
                    rawUrl = System.getenv("JDBC_DATABASE_URL");
                }
                if (rawUrl == null || rawUrl.trim().isEmpty()) {
                    rawUrl = System.getenv("DB_URL");
                }

                if (rawUrl != null && !rawUrl.trim().isEmpty()) {
                    rawUrl = rawUrl.trim();
                    LOGGER.info("[DB] Configuring PostgreSQL from environment URL...");

                    if (rawUrl.startsWith("postgres://") || rawUrl.startsWith("postgresql://")) {
                        // Standard cloud connection URI: postgres://username:password@host:port/database
                        URI uri = new URI(rawUrl);
                        String userInfo = uri.getUserInfo();
                        String username = null;
                        String password = null;
                        if (userInfo != null && !userInfo.isEmpty()) {
                            String[] parts = userInfo.split(":", 2);
                            username = parts[0];
                            if (parts.length > 1) {
                                password = parts[1];
                            }
                        }

                        String host = uri.getHost();
                        int port = uri.getPort() > 0 ? uri.getPort() : 5432;
                        String path = uri.getPath(); // e.g., /dbname
                        String dbName = (path != null && path.length() > 1) ? path.substring(1) : "";

                        // Construct standard JDBC URL
                        StringBuilder jdbcUrl = new StringBuilder("jdbc:postgresql://")
                                .append(host)
                                .append(":")
                                .append(port)
                                .append("/")
                                .append(dbName);

                        // SSL Requirement for cloud hosts (Render, Supabase, Neon, etc.)
                        boolean isLocal = "localhost".equalsIgnoreCase(host) || "127.0.0.1".equals(host);
                        String query = uri.getQuery();

                        if (query != null && !query.isEmpty()) {
                            jdbcUrl.append("?").append(query);
                            if (!isLocal && !query.contains("sslmode=")) {
                                jdbcUrl.append("&sslmode=require");
                            }
                        } else {
                            if (!isLocal) {
                                jdbcUrl.append("?sslmode=require");
                            }
                        }

                        config.setJdbcUrl(jdbcUrl.toString());
                        if (username != null && !username.isEmpty()) {
                            config.setUsername(username);
                        }
                        if (password != null) {
                            config.setPassword(password);
                        }
                        LOGGER.info("[DB] Configured JDBC URL: " + sanitizeJdbcUrl(jdbcUrl.toString()) + " with user: " + username);
                    } else if (rawUrl.startsWith("jdbc:postgresql://")) {
                        // Already a JDBC URL
                        String jdbcUrl = rawUrl;
                        if (!jdbcUrl.contains("localhost") && !jdbcUrl.contains("127.0.0.1") && !jdbcUrl.contains("sslmode=")) {
                            jdbcUrl += (jdbcUrl.contains("?") ? "&" : "?") + "sslmode=require";
                        }
                        config.setJdbcUrl(jdbcUrl);
                        String envUser = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : System.getenv("DB_USERNAME");
                        String envPass = System.getenv("DB_PASSWORD");
                        if (envUser != null && !envUser.isEmpty()) config.setUsername(envUser);
                        if (envPass != null) config.setPassword(envPass);
                    } else {
                        config.setJdbcUrl(rawUrl);
                    }
                } else {
                    // Local Development Fallback: try db.properties or config.properties
                    Properties fileProps = loadLocalProperties();
                    String localUrl = fileProps.getProperty("db.url", "jdbc:postgresql://localhost:5432/benedictjeromemart");
                    String localUser = fileProps.getProperty("db.user", fileProps.getProperty("db.username", "postgres"));
                    String localPass = fileProps.getProperty("db.password", "Btechaids@2008");

                    if (!localUrl.contains("sslmode=")) {
                        localUrl += (localUrl.contains("?") ? "&" : "?") + "sslmode=disable";
                    }

                    config.setJdbcUrl(localUrl);
                    config.setUsername(localUser);
                    config.setPassword(localPass);
                    LOGGER.info("[DB] Configured local database connection for " + localUser + " at " + localUrl);
                }

                // Pool optimization settings (well suited for cloud container instances)
                config.setMaximumPoolSize(10);
                config.setMinimumIdle(2);
                config.setIdleTimeout(30000);
                config.setConnectionTimeout(30000);
                config.setMaxLifetime(1800000); // 30 minutes
                config.setPoolName("BenedictHikariPool");

                dataSource = new HikariDataSource(config);
                System.out.println("[DB] PostgreSQL Connection Pool initialized successfully!");
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "[DB] Failed to initialize database connection pool: " + e.getMessage(), e);
            }
        }
    }

    private static Properties loadLocalProperties() {
        Properties props = new Properties();
        for (String file : new String[]{"db.properties", "config.properties"}) {
            try (InputStream in = DBConnectionManager.class.getClassLoader().getResourceAsStream(file)) {
                if (in != null) {
                    props.load(in);
                    return props;
                }
            } catch (Exception ignored) {}
        }
        return props;
    }

    private static String sanitizeJdbcUrl(String url) {
        if (url == null) return null;
        return url.replaceAll(":[^/@:]+@", ":***@");
    }

    public static Connection getConnection() throws SQLException {
        if (dataSource == null || dataSource.isClosed()) {
            initPool();
        }
        if (dataSource == null) {
            throw new SQLException("Database connection pool is not initialized. Please verify DATABASE_URL.");
        }
        return dataSource.getConnection();
    }

    public static HikariDataSource getDataSource() {
        if (dataSource == null || dataSource.isClosed()) {
            initPool();
        }
        return dataSource;
    }

    public static void closePool() {
        synchronized (LOCK) {
            if (dataSource != null && !dataSource.isClosed()) {
                dataSource.close();
                dataSource = null;
            }
        }
    }
}