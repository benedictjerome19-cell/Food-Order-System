package com.benedictjeromemart.listener;

import java.io.InputStream;
import java.net.URI;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Properties;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

@WebListener
public class AppContextListener implements ServletContextListener {

    private static volatile HikariDataSource dataSource;

    private static final String[] ID_TABLES = {
        "users", "restaurants", "menu_items", "cart_items", "orders", "order_items", "reviews"
    };

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        if (dataSource != null && !dataSource.isClosed()) {
            publish(sce);
            return;
        }

        String url = null;
        String user = null;
        String pass = null;

        try (InputStream in = AppContextListener.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) {
                Properties props = new Properties();
                props.load(in);
                url = blankToNull(props.getProperty("db.url"));
                user = firstNonBlank(props.getProperty("db.user"), props.getProperty("db.username"));
                pass = props.getProperty("db.password");
                if (pass != null) pass = pass.trim();
            }
        } catch (Exception e) {
            System.err.println("[DB] Could not read db.properties: " + e.getMessage());
        }

        String envUrl = firstNonBlank(System.getenv("DB_URL"), System.getenv("DATABASE_URL"));
        String envUser = blankToNull(System.getenv("DB_USERNAME"));
        String envPass = System.getenv("DB_PASSWORD");
        if (envUrl != null) url = envUrl;

        if (url == null) {
            throw new IllegalStateException(
                "[DB] No database configured. Set DATABASE_URL (or DB_URL + DB_USERNAME + DB_PASSWORD) "
              + "as environment variables, or create src/main/resources/db.properties for local development.");
        }

        String parsedUser = null;
        String parsedPass = null;
        if (!url.startsWith("jdbc:")) {
            try {
                String[] p = parsePostgresUrl(url);
                url = p[0];
                parsedUser = blankToNull(p[1]);
                parsedPass = p[2];
            } catch (Exception e) {
                throw new IllegalStateException("[DB] Could not understand the database URL: " + e.getMessage(), e);
            }
        }
        user = firstNonBlank(envUser, parsedUser, user);
        pass = envPass != null ? envPass : (parsedPass != null ? parsedPass : pass);

        if (!url.startsWith("jdbc:postgresql:")) {
            throw new IllegalStateException("[DB] Only PostgreSQL is supported. The URL must start with jdbc:postgresql:");
        }
        url = ensureSsl(url);

        System.out.println("[DB] Connecting to " + safeUrl(url) + " as user '" + user + "' ...");

        HikariConfig config = new HikariConfig();
        config.setPoolName("benedictmart-pool");
        config.setJdbcUrl(url);
        config.setDriverClassName("org.postgresql.Driver");
        config.setUsername(user);
        config.setPassword(pass == null ? "" : pass);
        config.setMaximumPoolSize(intEnv("DB_POOL_SIZE", 5));
        config.setConnectionTimeout(15000);
        config.setInitializationFailTimeout(30000);

        try {
            dataSource = new HikariDataSource(config);
        } catch (Exception e) {
            System.err.println("[DB] CONNECTION FAILED: " + rootMessage(e));
            System.err.println("[DB] Hint: " + explain(e));
            throw new IllegalStateException("[DB] Could not connect to PostgreSQL: " + rootMessage(e), e);
        }

        System.out.println("[DB] Connected to PostgreSQL.");
        publish(sce);
        initSchema();
    }

    private void publish(ServletContextEvent sce) {
        if (sce != null && sce.getServletContext() != null) {
            sce.getServletContext().setAttribute("dataSource", dataSource);
        }
    }

    private void initSchema() {
        runSqlScript("schema-postgres.sql", "Schema");
        
        // Auto-seed local data export if users table is empty
        if (isUsersTableEmpty()) {
            System.out.println("[DB] Users table is empty. Importing data-postgres.sql...");
            runSqlScript("data-postgres.sql", "Data migration");
        } else {
            System.out.println("[DB] Users table already contains data. Skipping data-postgres.sql import.");
        }
    }

    private void runSqlScript(String resourceName, String label) {
        try (Connection conn = dataSource.getConnection();
             InputStream is = AppContextListener.class.getClassLoader().getResourceAsStream(resourceName)) {

            if (is == null) {
                System.err.println("[DB] " + resourceName + " not found on the classpath.");
                return;
            }

            String text = new String(is.readAllBytes(), java.nio.charset.StandardCharsets.UTF_8);
            if (!text.isEmpty() && text.charAt(0) == '\uFEFF') text = text.substring(1);

            StringBuilder cleaned = new StringBuilder();
            for (String line : text.split("\\R")) {
                if (!line.trim().startsWith("--")) cleaned.append(line).append('\n');
            }

            int ok = 0;
            try (Statement stmt = conn.createStatement()) {
                for (String raw : cleaned.toString().split(";")) {
                    String sql = raw.trim();
                    if (sql.isEmpty()) continue;
                    try {
                        stmt.execute(sql);
                        ok++;
                    } catch (Exception e) {
                        String preview = sql.length() > 90 ? sql.substring(0, 90) + "..." : sql;
                        System.err.println("[DB] " + label + " statement failed: " + e.getMessage().replace('\n', ' ')
                                + "  ->  " + preview.replace('\n', ' '));
                    }
                }
            }
            System.out.println("[DB] " + label + " ready (" + ok + " statements ok).");
            if (resourceName.equals("schema-postgres.sql")) {
                syncIdCounters(conn);
            }
        } catch (Exception e) {
            System.err.println("[DB] " + label + " initialization failed: " + e.getMessage());
        }
    }

    private boolean isUsersTableEmpty() {
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM users")) {
            if (rs.next()) {
                return rs.getInt(1) == 0;
            }
        } catch (Exception e) {
            return true;
        }
        return false;
    }

    private void syncIdCounters(Connection conn) {
        for (String table : ID_TABLES) {
            String sql = "SELECT setval(pg_get_serial_sequence('" + table + "', 'id'), "
                       + "(SELECT COALESCE(MAX(id), 0) + 1 FROM " + table + "), false)";
            try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
                rs.next();
            } catch (Exception e) {
                System.err.println("[DB] Could not sync id counter for " + table + ": " + e.getMessage());
            }
        }
    }

    static String[] parsePostgresUrl(String raw) throws Exception {
        URI uri = new URI(raw.trim());
        String scheme = uri.getScheme();
        if (scheme == null || !(scheme.equals("postgres") || scheme.equals("postgresql"))) {
            throw new IllegalArgumentException("expected a jdbc:postgresql:// or postgresql:// URL");
        }
        String user = "";
        String pass = "";
        String userInfo = uri.getUserInfo();
        if (userInfo != null) {
            int colon = userInfo.indexOf(':');
            user = colon >= 0 ? userInfo.substring(0, colon) : userInfo;
            pass = colon >= 0 ? userInfo.substring(colon + 1) : "";
        }
        int port = uri.getPort() == -1 ? 5432 : uri.getPort();
        return new String[] { "jdbc:postgresql://" + uri.getHost() + ":" + port + uri.getPath(), user, pass };
    }

    private static String ensureSsl(String url) {
        if (url.contains(".render.com") && !url.contains("sslmode=")) {
            return url + (url.contains("?") ? "&" : "?") + "sslmode=require";
        }
        return url;
    }

    private static String safeUrl(String url) {
        int q = url.indexOf('?');
        return q >= 0 ? url.substring(0, q) : url;
    }

    private static String rootMessage(Throwable t) {
        Throwable r = t;
        while (r.getCause() != null && r.getCause() != r) r = r.getCause();
        return r.getClass().getSimpleName() + ": " + r.getMessage();
    }

    private static String explain(Throwable t) {
        String m = rootMessage(t).toLowerCase();
        if (m.contains("password authentication failed") || m.contains("authentication"))
            return "wrong username or password (check DB_USERNAME / DB_PASSWORD or the password in the URL).";
        if (m.contains("unknownhost") || m.contains("unknown host") || m.contains("name or service"))
            return "the database host name cannot be resolved (use the External URL on your PC, the Internal URL on Render).";
        if (m.contains("timed out") || m.contains("timeout") || m.contains("refused"))
            return "cannot reach the database (firewall / no internet / database suspended or expired in the Render dashboard / wrong host or port).";
        if (m.contains("ssl"))
            return "SSL problem (add ?sslmode=require to the URL).";
        if (m.contains("does not exist"))
            return "database name in the URL is wrong.";
        return "see the message above.";
    }

    private static String blankToNull(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s.trim();
    }

    private static String firstNonBlank(String... values) {
        for (String v : values) {
            if (v != null && !v.trim().isEmpty()) return v.trim();
        }
        return null;
    }

    private static int intEnv(String name, int def) {
        try {
            String v = System.getenv(name);
            return v == null ? def : Integer.parseInt(v.trim());
        } catch (NumberFormatException e) {
            return def;
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            System.out.println("[DB] Connection pool closed.");
        }
    }

    public static HikariDataSource getDataSource() {
        return dataSource;
    }

    public static void setDataSource(HikariDataSource ds) {
        dataSource = ds;
    }
}