package com.thechain.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;
import java.util.function.Function;

/**
 * JwtService - JWT token generation and validation
 *
 * Features:
 * - Generate access tokens (15 min expiry)
 * - Generate refresh tokens (7 days expiry)
 * - Validate tokens
 * - Extract claims (userId, chainKey, position, etc.)
 */
@Service
@Slf4j
public class JwtService {

    @Value("${jwt.secret:thechain-default-secret-key-change-in-production-min-32-chars}")
    private String jwtSecret;

    @Value("${jwt.access-token-expiry-seconds:900}") // 15 minutes
    private long accessTokenExpirySeconds;

    @Value("${jwt.refresh-token-expiry-seconds:604800}") // 7 days
    private long refreshTokenExpirySeconds;

    /**
     * Generate access token for user
     */
    public String generateAccessToken(UUID userId, String chainKey, Integer position, String deviceId) {
        Instant now = Instant.now();
        Instant expiry = now.plusSeconds(accessTokenExpirySeconds);

        var builder = Jwts.builder()
            .subject(userId.toString())
            .claim("chainKey", chainKey)
            .claim("type", "access")
            .issuedAt(Date.from(now))
            .expiration(Date.from(expiry))
            .signWith(getSigningKey());

        if (position != null) {
            builder.claim("position", position);
        }

        if (deviceId != null) {
            builder.claim("deviceId", deviceId);
        }

        return builder.compact();
    }

    /**
     * Generate refresh token for user
     */
    public String generateRefreshToken(UUID userId, String deviceId) {
        Instant now = Instant.now();
        Instant expiry = now.plusSeconds(refreshTokenExpirySeconds);

        return Jwts.builder()
            .subject(userId.toString())
            .claim("type", "refresh")
            .claim("deviceId", deviceId)
            .issuedAt(Date.from(now))
            .expiration(Date.from(expiry))
            .signWith(getSigningKey())
            .compact();
    }

    /**
     * Extract userId from token
     */
    public UUID extractUserId(String token) {
        String subject = extractClaim(token, Claims::getSubject);
        return UUID.fromString(subject);
    }

    /**
     * Extract chainKey from token
     */
    public String extractChainKey(String token) {
        return extractClaim(token, claims -> claims.get("chainKey", String.class));
    }

    /**
     * Extract position from token
     */
    public Integer extractPosition(String token) {
        return extractClaim(token, claims -> claims.get("position", Integer.class));
    }

    /**
     * Extract token type (access/refresh)
     */
    public String extractTokenType(String token) {
        return extractClaim(token, claims -> claims.get("type", String.class));
    }

    /**
     * Extract deviceId from token
     */
    public String extractDeviceId(String token) {
        return extractClaim(token, claims -> claims.get("deviceId", String.class));
    }

    /**
     * Extract expiration date
     */
    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    /**
     * Extract specific claim
     */
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    /**
     * Extract all claims from token
     */
    private Claims extractAllClaims(String token) {
        return Jwts.parser()
            .verifyWith(getSigningKey())
            .build()
            .parseSignedClaims(token)
            .getPayload();
    }

    /**
     * Check if token is expired
     */
    public boolean isTokenExpired(String token) {
        try {
            return extractExpiration(token).before(new Date());
        } catch (Exception e) {
            return true;
        }
    }

    /**
     * Validate token
     */
    public boolean validateToken(String token, UUID userId) {
        try {
            final UUID tokenUserId = extractUserId(token);
            return (tokenUserId.equals(userId) && !isTokenExpired(token));
        } catch (Exception e) {
            log.error("Token validation failed: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Validate access token
     */
    public boolean validateAccessToken(String token, UUID userId) {
        try {
            String tokenType = extractTokenType(token);
            return "access".equals(tokenType) && validateToken(token, userId);
        } catch (Exception e) {
            log.error("Access token validation failed: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Validate refresh token
     */
    public boolean validateRefreshToken(String token, UUID userId) {
        try {
            String tokenType = extractTokenType(token);
            return "refresh".equals(tokenType) && validateToken(token, userId);
        } catch (Exception e) {
            log.error("Refresh token validation failed: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Get signing key from secret
     */
    private SecretKey getSigningKey() {
        byte[] keyBytes = jwtSecret.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    /**
     * Get access token expiry in seconds
     */
    public long getAccessTokenExpirySeconds() {
        return accessTokenExpirySeconds;
    }

    /**
     * Get refresh token expiry in seconds
     */
    public long getRefreshTokenExpirySeconds() {
        return refreshTokenExpirySeconds;
    }
}
