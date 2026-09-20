package com.benedictjeromemart.dao;

import java.sql.Connection;
import java.sql.Statement;
import java.util.Optional;

import org.junit.jupiter.api.AfterEach;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.benedictjeromemart.util.DBConnectionManager;
import com.benedictjeromemart.model.User;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class UserDAOTest {

    private HikariDataSource dataSource;
    private UserDAO userDAO;

    @BeforeEach
    public void setUp() throws Exception {
        // Configure H2 in-memory database for testing
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1");
        config.setUsername("sa");
        config.setPassword("");
        
        dataSource = new HikariDataSource(config);
        // Inject into DBConnectionManager instead of AppContextListener
        DBConnectionManager.setDataSource(dataSource);

        // Create users table with all required columns including 'password'
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("CREATE TABLE IF NOT EXISTS users (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "name VARCHAR(100) NOT NULL, " +
                    "email VARCHAR(100) UNIQUE NOT NULL, " +
                    "password VARCHAR(255) NOT NULL, " +
                    "role VARCHAR(50) DEFAULT 'CUSTOMER'" +
                    ")");
        }

        userDAO = new UserDAOImpl();
    }

    @AfterEach
    public void tearDown() throws Exception {
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("DROP TABLE IF EXISTS users");
        }
        if (dataSource != null) {
            dataSource.close();
        }
        DBConnectionManager.setDataSource(null);
        DBConnectionManager.initializeProductionDataSource(); // Restore production pool
    }

    @Test
    public void testCreateAndFindByEmail() {
        User user = new User("Test User", "testuser_" + System.currentTimeMillis() + "@test.com", "secret123", "CUSTOMER");
        
        User createdUser = userDAO.create(user);
        assertNotNull(createdUser);
        assertTrue(createdUser.getId() > 0);

        Optional<User> found = userDAO.findByEmail(createdUser.getEmail());
        assertTrue(found.isPresent());
        assertEquals(createdUser.getEmail(), found.get().getEmail());
        assertEquals("Test User", found.get().getName());
    }
}