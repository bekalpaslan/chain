package com.thechain.config;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.data.redis.core.RedisTemplate;

import static org.mockito.Mockito.mock;

/**
 * Test configuration that provides mock Redis dependencies.
 * This allows tests to run without a real Redis instance.
 */
@TestConfiguration
public class TestRedisConfig {

    @Bean
    @Primary
    @SuppressWarnings("unchecked")
    public RedisTemplate<String, String> redisTemplate() {
        // Return a mock RedisTemplate for tests
        // This prevents "No qualifying bean" errors when Redis is disabled
        return mock(RedisTemplate.class);
    }
}
