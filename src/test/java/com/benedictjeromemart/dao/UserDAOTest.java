package com.benedictjeromemart.dao;

import org.junit.jupiter.api.AfterEach;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class UserDAOTest {

    private HikariDataSource dataSource;
    private UserDAO userDAO;

    @BeforeEach
    public void setUp() {
        // Configure HikariCP to connect to your PostgreSQL instance for testing
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:postgresql://localhost:5432/benedictjeromemart"); // Update with your local test DB URL if needed
        config.setUsername("postgres"); // Update with your DB username
        config.setPassword("Btechaids@2008"); // Update with your DB password
        config.setDriverClassName("org.postgresql.Driver");

        dataSource = new HikariDataSource(config);
        // Initialize your DAO with the PostgreSQL datasource
        userDAO = new UserDAOImpl(); 
    }

    @AfterEach
    public void tearDown() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }

    @Test
    public void testCreateAndFindByEmail() {
        // Add your test assertions here
        assertNotNull(userDAO);
    }
}