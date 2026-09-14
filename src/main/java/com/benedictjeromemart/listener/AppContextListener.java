package com.benedictjeromemart.listener;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

@WebListener
public class AppContextListener implements ServletContextListener {

    private static HikariDataSource dataSource;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        if (dataSource != null && !dataSource.isClosed()) {
            return;
        }

        String dbUrl = "jdbc:h2:D:/benedictmart/benedictmart/jerome_zom/data/benedictjeromemart;AUTO_SERVER=TRUE";
        String dbUser = "sa";
        String dbPass = "";

        try (java.io.InputStream in = AppContextListener.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (in != null) {
                java.util.Properties props = new java.util.Properties();
                props.load(in);
                if (props.getProperty("db.url") != null) dbUrl = props.getProperty("db.url");
                if (props.getProperty("db.username") != null) dbUser = props.getProperty("db.username");
                if (props.getProperty("db.password") != null) dbPass = props.getProperty("db.password");
            }
        } catch (Exception ignored) {}

        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(dbUrl);
        config.setDriverClassName("org.h2.Driver");
        config.setUsername(dbUser);
        config.setPassword(dbPass);
        config.setMaximumPoolSize(10);

        dataSource = new HikariDataSource(config);
        if (sce != null && sce.getServletContext() != null) {
            sce.getServletContext().setAttribute("dataSource", dataSource);
        }

        // Initialize schema from schema.sql
        try (java.sql.Connection conn = dataSource.getConnection();
             java.io.InputStream is = AppContextListener.class.getClassLoader().getResourceAsStream("schema.sql")) {
            if (is != null) {
                java.util.Scanner scanner = new java.util.Scanner(is, "UTF-8").useDelimiter(";");
                try (java.sql.Statement stmt = conn.createStatement()) {
                    while (scanner.hasNext()) {
                        String statement = scanner.next().trim();
                        if (!statement.isEmpty()) {
                            stmt.execute(statement);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Database schema initialization warning: " + e.getMessage());
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