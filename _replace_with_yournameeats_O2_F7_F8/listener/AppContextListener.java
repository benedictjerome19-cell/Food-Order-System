package com.yourname.yournameeats.listener;

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
        HikariConfig config = new HikariConfig();
        // Embedded H2 for local dev — file-based so data persists between restarts
        config.setJdbcUrl("jdbc:h2:C:/Users/DELL USER/Downloads/java/project_3/benedictmart/jerome_zom/data/benedictjeromemart;AUTO_SERVER=TRUE");
        config.setDriverClassName("org.h2.Driver");
        config.setUsername("sa");
        config.setPassword("");
        config.setMaximumPoolSize(10);

        dataSource = new HikariDataSource(config);
        sce.getServletContext().setAttribute("dataSource", dataSource);

        // Ensure the restaurants table exists. There is no schema.sql in this
        // project, so tables were created manually at some point — this one
        // was likely missed, which is why owner/menu-items requests fail
        // while other DB writes (cart, orders) work fine.
        try (java.sql.Connection conn = dataSource.getConnection();
             java.sql.Statement stmt = conn.createStatement()) {
            stmt.execute(
                "CREATE TABLE IF NOT EXISTS restaurants (" +
                "  id INT AUTO_INCREMENT PRIMARY KEY," +
                "  owner_id INT NOT NULL," +
                "  name VARCHAR(255)," +
                "  cuisine_type VARCHAR(255)," +
                "  address VARCHAR(500)," +
                "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                ")"
            );
        } catch (java.sql.SQLException e) {
            throw new RuntimeException("Failed to ensure restaurants table exists", e);
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
}