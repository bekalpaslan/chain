package com.thechain.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.CachingConfigurer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

/**
 * Redis Cache Configuration
 * Configures different cache regions with appropriate TTLs
 */
@Configuration
public class CacheConfig implements CachingConfigurer {

    // Cache names
    public static final String USER_CACHE = "users";
    public static final String TICKET_CACHE = "tickets";
    public static final String CHAIN_CACHE = "chains";
    public static final String BADGE_CACHE = "badges";
    public static final String USER_PROFILE_CACHE = "userProfiles";
    public static final String CHAIN_STATS_CACHE = "chainStats";

    @Bean
    public CacheManager cacheManager(RedisConnectionFactory connectionFactory) {
        return RedisCacheManager.builder(connectionFactory)
                .cacheDefaults(defaultCacheConfiguration())
                .withInitialCacheConfigurations(getCacheConfigurations())
                .transactionAware()
                .build();
    }

    /**
     * Default cache configuration with 10 minute TTL
     */
    private RedisCacheConfiguration defaultCacheConfiguration() {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

        return RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofMinutes(10))
                .serializeKeysWith(
                        RedisSerializationContext.SerializationPair.fromSerializer(
                                new StringRedisSerializer()
                        )
                )
                .serializeValuesWith(
                        RedisSerializationContext.SerializationPair.fromSerializer(
                                new GenericJackson2JsonRedisSerializer(objectMapper)
                        )
                )
                .disableCachingNullValues();
    }

    /**
     * Configure cache-specific TTLs
     */
    private Map<String, RedisCacheConfiguration> getCacheConfigurations() {
        Map<String, RedisCacheConfiguration> cacheConfigurations = new HashMap<>();

        // User cache - 30 minutes (users don't change frequently)
        cacheConfigurations.put(USER_CACHE,
                defaultCacheConfiguration().entryTtl(Duration.ofMinutes(30)));

        // Ticket cache - 5 minutes (tickets have 24h lifecycle)
        cacheConfigurations.put(TICKET_CACHE,
                defaultCacheConfiguration().entryTtl(Duration.ofMinutes(5)));

        // Chain cache - 15 minutes (chains change with ticket activity)
        cacheConfigurations.put(CHAIN_CACHE,
                defaultCacheConfiguration().entryTtl(Duration.ofMinutes(15)));

        // Badge cache - 1 hour (badges are relatively static)
        cacheConfigurations.put(BADGE_CACHE,
                defaultCacheConfiguration().entryTtl(Duration.ofHours(1)));

        // User profile cache - 20 minutes
        cacheConfigurations.put(USER_PROFILE_CACHE,
                defaultCacheConfiguration().entryTtl(Duration.ofMinutes(20)));

        // Chain stats cache - 5 minutes (stats update frequently)
        cacheConfigurations.put(CHAIN_STATS_CACHE,
                defaultCacheConfiguration().entryTtl(Duration.ofMinutes(5)));

        return cacheConfigurations;
    }
}
