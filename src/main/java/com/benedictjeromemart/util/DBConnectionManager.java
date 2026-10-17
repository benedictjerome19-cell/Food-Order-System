package com.benedictjeromemart.util;

import java.io.InputStream;
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

    private static volatile boolean envUrlDetected = false;
    private static volatile String lastConfiguredTarget = "none";
    private static volatile String lastErrorMessage = null;
    private static volatile String configuredUser = null;

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "PostgreSQL Driver not found on classpath", e);
        }
        initPool();
    }

    public static synchronized void initPool() {
        if (dataSource != null && !dataSource.isClosed()) {
            return;
        }

        try {
            HikariConfig config = new HikariConfig();
            config.setDriverClassName("org.postgresql.Driver");

            // 1. Resolve connection URL from environment
            String rawUrl = System.getenv("DATABASE_URL");
            if (rawUrl == null || rawUrl.trim().isEmpty()) {
                rawUrl = System.getenv("JDBC_DATABASE_URL");
            }
            if (rawUrl == null || rawUrl.trim().isEmpty()) {
                rawUrl = System.getenv("DB_URL");
            }

            if (rawUrl != null && !rawUrl.trim().isEmpty()) {
                envUrlDetected = true;
                rawUrl = rawUrl.trim();
                // Strip enclosing quotes if present
                if ((rawUrl.startsWith("\"") && rawUrl.endsWith("\"")) || (rawUrl.startsWith("'") && rawUrl.endsWith("'"))) {
                    rawUrl = rawUrl.substring(1, rawUrl.length() - 1).trim();
                }

                LOGGER.info("[DB] Environment database URL detected. Parsing configuration...");

                // Parse standard URL: [scheme://][user[:password]@]host[:port][/dbname][?query]
                String withoutPrefix = rawUrl;
                if (withoutPrefix.startsWith("jdbc:postgresql://")) {
                    withoutPrefix = withoutPrefix.substring("jdbc:postgresql://".length());
                } else if (withoutPrefix.startsWith("postgresql://")) {
                    withoutPrefix = withoutPrefix.substring("postgresql://".length());
                } else if (withoutPrefix.startsWith("postgres://")) {
                    withoutPrefix = withoutPrefix.substring("postgres://".length());
                }

                String queryParams = "";
                int qIdx = withoutPrefix.indexOf('?');
                if (qIdx != -1) {
                    queryParams = withoutPrefix.substring(qIdx + 1);
                    withoutPrefix = withoutPrefix.substring(0, qIdx);
                }

                String username = null;
                String password = null;
                int atIdx = withoutPrefix.lastIndexOf('@');
                if (atIdx != -1) {
                    String userInfo = withoutPrefix.substring(0, atIdx);
                    withoutPrefix = withoutPrefix.substring(atIdx + 1);
                    int colonIdx = userInfo.indexOf(':');
                    if (colonIdx != -1) {
                        username = userInfo.substring(0, colonIdx);
                        password = userInfo.substring(colonIdx + 1);
                    } else {
                        username = userInfo;
                    }
                }

                String hostAndPort = withoutPrefix;
                String dbName = "";
                int slashIdx = withoutPrefix.indexOf('/');
                if (slashIdx != -1) {
                    hostAndPort = withoutPrefix.substring(0, slashIdx);
                    dbName = withoutPrefix.substring(slashIdx + 1);
                }

                String host = hostAndPort;
                int port = 5432;
                int colonIdx = hostAndPort.lastIndexOf(':');
                if (colonIdx != -1) {
                    host = hostAndPort.substring(0, colonIdx);
                    try {
                        port = Integer.parseInt(hostAndPort.substring(colonIdx + 1));
                    } catch (NumberFormatException ignored) {}
                }

                StringBuilder jdbcUrl = new StringBuilder("jdbc:postgresql://")
                        .append(host)
                        .append(":")
                        .append(port)
                        .append("/")
                        .append(dbName);

                boolean isLocal = "localhost".equalsIgnoreCase(host) || "127.0.0.1".equals(host);
                if (queryParams.isEmpty()) {
                    if (!isLocal) {
                        jdbcUrl.append("?sslmode=require");
                    }
                } else {
                    jdbcUrl.append("?").append(queryParams);
                    if (!isLocal && !queryParams.contains("sslmode=")) {
                        jdbcUrl.append("&sslmode=require");
                    }
                }

                config.setJdbcUrl(jdbcUrl.toString());

                if (username != null && !username.isEmpty()) {
                    config.setUsername(username);
                } else {
                    String envUser = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : System.getenv("DB_USERNAME");
                    if (envUser != null) config.setUsername(envUser);
                }

                if (password != null) {
                    config.setPassword(password);
                } else {
                    String envPass = System.getenv("DB_PASSWORD");
                    if (envPass != null) config.setPassword(envPass);
                }

                configuredUser = config.getUsername();
                lastConfiguredTarget = host + ":" + port + "/" + dbName;
                LOGGER.info("[DB] Configured target: " + lastConfiguredTarget + ", user: " + configuredUser);
            } else {
                envUrlDetected = false;
                // Local Development Fallback
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
                configuredUser = localUser;
                lastConfiguredTarget = "localhost:5432/benedictjeromemart";
                LOGGER.info("[DB] Configured local database connection for " + localUser + " at " + localUrl);
            }

            config.setMaximumPoolSize(10);
            config.setMinimumIdle(2);
            config.setIdleTimeout(30000);
            config.setConnectionTimeout(15000);
            config.setMaxLifetime(1800000);
            config.setPoolName("BenedictHikariPool");

            dataSource = new HikariDataSource(config);
            lastErrorMessage = null;
            System.out.println("[DB] PostgreSQL Connection Pool initialized successfully!");
        } catch (Throwable t) {
            String msg = t.getMessage();
            if (t.getCause() != null) {
                msg += " (Cause: " + t.getCause().getMessage() + ")";
            }
            lastErrorMessage = msg;
            LOGGER.log(Level.SEVERE, "[DB] Failed to initialize database connection pool: " + lastErrorMessage, t);
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

    public static Connection getConnection() throws SQLException {
        if (dataSource == null || dataSource.isClosed()) {
            initPool();
        }
        if (dataSource == null) {
            if (!envUrlDetected) {
                throw new SQLException(
                    "DATABASE_URL environment variable is NOT set in Render. " +
                    "Please go to your Render Web Service dashboard -> Environment tab -> Add 'DATABASE_URL' with your PostgreSQL connection string."
                );
            }
            throw new SQLException(
                "Cannot connect to PostgreSQL at [" + lastConfiguredTarget + "] as user [" + configuredUser + "]: " +
                (lastErrorMessage != null ? lastErrorMessage : "Connection failed. Please verify credentials, host, and SSL settings.")
            );
        }
        return dataSource.getConnection();
    }

    public static HikariDataSource getDataSource() {
        if (dataSource == null || dataSource.isClosed()) {
            initPool();
        }
        return dataSource;
    }

    public static boolean isEnvUrlDetected() {
        return envUrlDetected;
    }

    public static String getLastConfiguredTarget() {
        return lastConfiguredTarget;
    }

    public static String getConfiguredUser() {
        return configuredUser;
    }

    public static String getLastErrorMessage() {
        return lastErrorMessage;
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