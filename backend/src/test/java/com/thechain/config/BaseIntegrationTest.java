package com.thechain.config;

import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

/**
 * Base class for all integration tests that require Spring Boot context.
 *
 * This class configures:
 * - TestContainers with PostgreSQL (production-like database)
 * - Flyway migrations enabled (tests real migration scripts)
 * - Mocks Redis dependencies (RedisTemplate)
 * - JWT configuration for tests
 *
 * Benefits over H2:
 * - Uses real PostgreSQL with JSONB support
 * - Tests actual Flyway migrations
 * - Guarantees production parity
 *
 * Extend this class in your test to get consistent test configuration.
 */
@SpringBootTest(
    properties = {
        // Enable Flyway migrations (tests real migration scripts)
        "spring.flyway.enabled=true",
        "spring.flyway.locations=classpath:db/migration",

        // JPA Configuration
        "spring.jpa.hibernate.ddl-auto=validate",
        "spring.jpa.show-sql=false",

        // Disable SQL Script Initialization (using Flyway instead)
        "spring.sql.init.mode=never",

        // Disable Redis (use mock instead)
        "spring.cache.type=none",
        "spring.data.redis.repositories.enabled=false",

        // JWT Configuration for tests
        "jwt.secret=test-secret-key-for-unit-tests-minimum-256-bits-long-string-here",
        "jwt.expiration=3600000",
        "jwt.refresh-expiration=2592000000"
    }
)
@AutoConfigureMockMvc
@Import(TestRedisConfig.class)
@Testcontainers
public abstract class BaseIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test")
            .withReuse(true); // Reuse container across tests for speed

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
        registry.add("spring.datasource.driver-class-name", () -> "org.postgresql.Driver");
    }
}
