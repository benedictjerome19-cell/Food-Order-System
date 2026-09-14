package com.benedictjeromemart.dao;

import com.benedictjeromemart.listener.AppContextListener;
import com.benedictjeromemart.model.User;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.Statement;
import java.util.Optional;
import java.util.Scanner;

import static org.junit.jupiter.api.Assertions.*;

public class UserDAOTest {

    private static HikariDataSource dataSource;
    private UserDAO userDAO;

    @BeforeAll
    public static void setUpDB() throws Exception {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1");
        config.setUsername("sa");
        config.setPassword("");
        dataSource = new HikariDataSource(config);
        AppContextListener.setDataSource(dataSource);

        try (Connection conn = dataSource.getConnection();
             InputStream is = UserDAOTest.class.getClassLoader().getResourceAsStream("schema.sql")) {
            if (is != null) {
                Scanner scanner = new Scanner(is, "UTF-8").useDelimiter(";");
                try (Statement stmt = conn.createStatement()) {
                    while (scanner.hasNext()) {
                        String statement = scanner.next().trim();
                        if (!statement.isEmpty()) {
                            stmt.execute(statement);
                        }
                    }
                }
            }
        }
    }

    @AfterAll
    public static void tearDownDB() {
        if (dataSource != null) {
            dataSource.close();
        }
    }

    @BeforeEach
    public void setUp() {
        userDAO = new UserDAOImpl();
    }

    @Test
    public void testCreateAndFindByEmail() {
        String testEmail = "testuser_" + System.currentTimeMillis() + "@test.com";
        User user = new User("Test User", testEmail, "hash123", "CUSTOMER");
        User created = userDAO.create(user);

        assertNotNull(created);
        assertTrue(created.getId() > 0);

        Optional<User> found = userDAO.findByEmail(testEmail);
        assertTrue(found.isPresent());
        assertEquals("Test User", found.get().getName());
        assertEquals("CUSTOMER", found.get().getRole());
    }
}
