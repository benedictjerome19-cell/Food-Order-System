package com.benedictjeromemart.listener;

import java.io.File;
import java.io.InputStream;
import java.net.URI;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Properties;
import java.util.Scanner;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

/**
 * Database bootstrap.
 *
 * Precedence (last one wins):
 *   1. built-in default: local H2 file ./data/benedictjeromemart
 *   2. config.properties on the classpath (local development only, gitignored)
 *   3. environment variables (how Render injects config):
 *        DATABASE_URL  = Render's "Internal Database URL" (postgresql://user:pass@host/db)
 *        or DB_URL     = jdbc:postgresql://host:5432/db  (+ DB_USERNAME / DB_PASSWORD)
 *
 * If the URL starts with jdbc:postgresql: the PostgreSQL driver and
 * schema-postgres.sql are used, otherwise H2 and schema.sql.
 */
@WebListener
public class AppContextListener implements ServletContextListener {

    private static HikariDataSource dataSource;

    /** Tables with an "id" identity column whose counter must be kept in sync. */
    private static final String[] ID_TABLES = {
        "users", "restaurants", "menu_items", "cart_items", "orders", "order_items", "reviews"
    };

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        if (dataSource != null && !dataSource.isClosed()) {
            return;
        }

        // 1. defaults
        String dbUrl = "jdbc:h2:./data/benedictjeromemart";
        String dbUser = "sa";
        String dbPass = "";

        // 2. config.properties (local development)
        try (InputStream in = AppContextListener.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (in != null) {
                Properties props = new Properties();
                props.load(in);
                if (props.getProperty("db.url") != null) dbUrl = props.getProperty("db.url").trim();
                if (props.getProperty("db.username") != null) dbUser = props.getProperty("db.username").trim();
                if (props.getProperty("db.password") != null) dbPass = props.getProperty("db.password");
            }
        } catch (Exception ignored) {
            // no config file: keep defaults
        }

        // 3. environment variables win
        String rawUrl = firstNonBlank(System.getenv("DB_URL"), System.getenv("DATABASE_URL"));
        if (rawUrl != null) {
            if (rawUrl.startsWith("jdbc:")) {
                dbUrl = rawUrl;
            } else {
                try {
                    String[] parsed = parsePostgresUrl(rawUrl);
                    dbUrl = parsed[0];
                    dbUser = parsed[1];
                    dbPass = parsed[2];
                } catch (Exception e) {
                    System.err.println("[DB] Could not parse database URL from environment: " + e.getMessage());
                }
            }
        }
        String envUser = System.getenv("DB_USERNAME");
        String envPass = System.getenv("DB_PASSWORD");
        if (envUser != null && !envUser.isBlank()) dbUser = envUser;
        if (envPass != null) dbPass = envPass;

        boolean postgres = dbUrl.startsWith("jdbc:postgresql:");
        if (postgres) {
            System.out.println("[DB] Using PostgreSQL");
        } else {
            System.out.println("[DB] Using local H2 file database: " + dbUrl
                    + "  (NOT persistent on Render - set DATABASE_URL there)");
            ensureDataDirectoryExists(dbUrl);
        }

        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(dbUrl);
        config.setDriverClassName(postgres ? "org.postgresql.Driver" : "org.h2.Driver");
        config.setUsername(dbUser);
        config.setPassword(dbPass);
        config.setMaximumPoolSize(10);

        dataSource = new HikariDataSource(config);
        if (sce != null && sce.getServletContext() != null) {
            sce.getServletContext().setAttribute("dataSource", dataSource);
        }

        initSchema(postgres);
    }

    private void initSchema(boolean postgres) {
        String resource = postgres ? "schema-postgres.sql" : "schema.sql";
        try (Connection conn = dataSource.getConnection();
             InputStream is = AppContextListener.class.getClassLoader().getResourceAsStream(resource)) {

            if (is == null) {
                System.err.println("[DB] Schema file not found on classpath: " + resource);
                return;
            }

            // Drop full-line comments, then split into statements.
            StringBuilder cleaned = new StringBuilder();
            try (Scanner lines = new Scanner(is, "UTF-8")) {
                while (lines.hasNextLine()) {
                    String line = lines.nextLine();
                    if (!line.trim().startsWith("--")) {
                        cleaned.append(line).append('\n');
                    }
                }
            }

            try (Statement stmt = conn.createStatement()) {
                for (String raw : cleaned.toString().split(";")) {
                    String sql = raw.trim();
                    if (sql.isEmpty()) continue;
                    // Identity counters are synced below from the real data,
                    // so a restart never resets them.
                    if (sql.toUpperCase().contains("RESTART WITH")) continue;
                    try {
                        stmt.execute(sql);
                    } catch (Exception e) {
                        String preview = sql.length() > 80 ? sql.substring(0, 80) + "..." : sql;
                        System.err.println("[DB] Schema statement failed: " + e.getMessage() + " -> " + preview);
                    }
                }
            }

            syncIdentityCounters(conn, postgres);
            System.out.println("[DB] Schema ready");
        } catch (Exception e) {
            System.err.println("[DB] Schema initialization failed: " + e.getMessage());
        }
    }

    /** Sets each table's next id to MAX(id)+1 (needed after seeding / importing rows with explicit ids). */
    private void syncIdentityCounters(Connection conn, boolean postgres) {
        for (String table : ID_TABLES) {
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COALESCE(MAX(id), 0) + 1 FROM " + table)) {
                rs.next();
                long next = rs.getLong(1);
                try (Statement st2 = conn.createStatement()) {
                    if (postgres) {
                        st2.execute("SELECT setval(pg_get_serial_sequence('" + table + "', 'id'), " + next + ", false)");
                    } else {
                        st2.execute("ALTER TABLE " + table + " ALTER COLUMN id RESTART WITH " + next);
                    }
                }
            } catch (Exception e) {
                System.err.println("[DB] Could not sync id counter for " + table + ": " + e.getMessage());
            }
        }
    }

    /** postgresql://user:pass@host[:port]/db  ->  {jdbcUrl, user, password} */
    private static String[] parsePostgresUrl(String raw) throws Exception {
        URI uri = new URI(raw.trim());
        String user = "";
        String pass = "";
        String userInfo = uri.getUserInfo();
        if (userInfo != null) {
            int colon = userInfo.indexOf(':');
            user = colon >= 0 ? userInfo.substring(0, colon) : userInfo;
            pass = colon >= 0 ? userInfo.substring(colon + 1) : "";
        }
        int port = uri.getPort() == -1 ? 5432 : uri.getPort();
        String url = "jdbc:postgresql://" + uri.getHost() + ":" + port + uri.getPath();
        // External Render hostnames contain dots and require SSL; internal ones do not.
        if (uri.getHost().contains(".")) {
            url += "?sslmode=require";
        }
        return new String[] { url, user, pass };
    }

    private static String firstNonBlank(String a, String b) {
        if (a != null && !a.isBlank()) return a.trim();
        if (b != null && !b.isBlank()) return b.trim();
        return null;
    }

    /** H2 does not create missing parent directories on its own. */
    private void ensureDataDirectoryExists(String jdbcUrl) {
        try {
            String path = jdbcUrl.replaceFirst("^jdbc:h2:(file:)?", "");
            int semicolon = path.indexOf(';');
            if (semicolon != -1) path = path.substring(0, semicolon);

            File dbFile = new File(path).getAbsoluteFile();
            File parentDir = dbFile.getParentFile();
            if (parentDir != null && !parentDir.exists()) {
                parentDir.mkdirs();
            }
        } catch (Exception e) {
            System.err.println("[DB] Could not verify/create data directory: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (dataSource != null) {
            dataSource.close();
        }
    }

    public static HikariDataSource getDataSource() {
        return dataSource;
    }

    public static void setDataSource(HikariDataSource ds) {
        dataSource = ds;
    }
}