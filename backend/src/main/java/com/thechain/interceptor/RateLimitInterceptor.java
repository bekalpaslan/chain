package com.thechain.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.time.Duration;

/**
 * Rate Limiting Interceptor using Redis
 * Implements sliding window rate limiting per endpoint and user
 *
 * NOTE: RedisTemplate is optional - if Redis is not available (e.g., in tests),
 * rate limiting will be skipped gracefully.
 */
@Component
@Slf4j
public class RateLimitInterceptor implements HandlerInterceptor {

    private final RedisTemplate<String, String> redisTemplate;

    /**
     * Default constructor for when Redis is not available
     * Rate limiting will be disabled
     */
    public RateLimitInterceptor() {
        this.redisTemplate = null;
        log.warn("RedisTemplate not available - rate limiting will be disabled");
    }

    /**
     * Constructor with RedisTemplate
     * Enables rate limiting with Redis backend
     */
    @Autowired(required = false)
    public RateLimitInterceptor(RedisTemplate<String, String> redisTemplate) {
        this.redisTemplate = redisTemplate;
        if (redisTemplate == null) {
            log.warn("RedisTemplate not available - rate limiting will be disabled");
        }
    }

    // Rate limit configurations
    private static final int AUTH_REQUESTS_PER_MINUTE = 5;
    private static final int API_REQUESTS_PER_MINUTE = 100;
    private static final int TICKET_REQUESTS_PER_MINUTE = 10;

    @Override
    public boolean preHandle(@org.springframework.lang.NonNull HttpServletRequest request,
                             @org.springframework.lang.NonNull HttpServletResponse response,
                             @org.springframework.lang.NonNull Object handler) throws Exception {
        String requestURI = request.getRequestURI();
        String method = request.getMethod();

        // Skip OPTIONS requests (CORS preflight)
        if ("OPTIONS".equals(method)) {
            return true;
        }

        // Get identifier (IP for anonymous, userId for authenticated)
        String identifier = getIdentifier(request);

        // Determine rate limit based on endpoint
        RateLimitConfig config = getRateLimitConfig(requestURI);

        if (config == null) {
            return true; // No rate limiting for this endpoint
        }

        // Skip rate limiting if Redis is not available (e.g., in tests)
        if (redisTemplate == null) {
            return true;
        }

        // Check rate limit
        String key = String.format("rate_limit:%s:%s:%s", config.name, identifier, getCurrentWindow(config.windowSeconds));

        Long requests = redisTemplate.opsForValue().increment(key);

        if (requests != null && requests == 1) {
            // First request in this window, set expiration
            redisTemplate.expire(key, Duration.ofSeconds(config.windowSeconds));
        }

        if (requests != null && requests > config.maxRequests) {
            log.warn("Rate limit exceeded for {} on endpoint {}: {} requests in {}s window",
                    identifier, requestURI, requests, config.windowSeconds);

            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType("application/json");
            response.getWriter().write(String.format(
                    "{\"error\":\"RATE_LIMIT_EXCEEDED\",\"message\":\"Too many requests. Limit: %d requests per %d seconds\",\"retryAfter\":%d}",
                    config.maxRequests, config.windowSeconds, config.windowSeconds
            ));
            return false;
        }

        // Add rate limit headers
        response.setHeader("X-RateLimit-Limit", String.valueOf(config.maxRequests));
        response.setHeader("X-RateLimit-Remaining", String.valueOf(Math.max(0, config.maxRequests - (requests != null ? requests : 0))));
        response.setHeader("X-RateLimit-Reset", String.valueOf(System.currentTimeMillis() / 1000 + config.windowSeconds));

        return true;
    }

    /**
     * Get identifier for rate limiting
     * Uses userId for authenticated requests, IP address otherwise
     */
    private String getIdentifier(HttpServletRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication != null && authentication.isAuthenticated() &&
            !"anonymousUser".equals(authentication.getPrincipal())) {
            return "user:" + authentication.getName();
        }

        // Fallback to IP address
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty()) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isEmpty()) {
            ip = request.getRemoteAddr();
        }

        return "ip:" + ip;
    }

    /**
     * Determine rate limit configuration based on endpoint
     */
    private RateLimitConfig getRateLimitConfig(String requestURI) {
        // Authentication endpoints - stricter limits
        if (requestURI.contains("/auth/register") || requestURI.contains("/auth/login")) {
            return new RateLimitConfig("auth", AUTH_REQUESTS_PER_MINUTE, 60);
        }

        // Ticket generation - strict limits
        if (requestURI.contains("/tickets") && !requestURI.contains("/verify")) {
            return new RateLimitConfig("ticket", TICKET_REQUESTS_PER_MINUTE, 60);
        }

        // General API endpoints
        if (requestURI.startsWith("/api/v1/")) {
            return new RateLimitConfig("api", API_REQUESTS_PER_MINUTE, 60);
        }

        return null; // No rate limiting
    }

    /**
     * Get current time window for rate limiting
     */
    private long getCurrentWindow(int windowSeconds) {
        return System.currentTimeMillis() / 1000 / windowSeconds;
    }

    /**
     * Rate limit configuration
     */
    private static class RateLimitConfig {
        final String name;
        final int maxRequests;
        final int windowSeconds;

        RateLimitConfig(String name, int maxRequests, int windowSeconds) {
            this.name = name;
            this.maxRequests = maxRequests;
            this.windowSeconds = windowSeconds;
        }
    }
}
