package com.thechain.security;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.*;

class JwtUtilTest {

    private JwtUtil jwtUtil;
    private final String testSecretKey = "test-secret-key-for-jwt-minimum-256-bits-long-for-hs512-algorithm-security";
    private final long accessTokenExpiration = 3600000L; // 1 hour in milliseconds
    private final long refreshTokenExpiration = 86400000L; // 24 hours in milliseconds

    @BeforeEach
    void setUp() {
        jwtUtil = new JwtUtil(testSecretKey, accessTokenExpiration, refreshTokenExpiration);
    }

    @Test
    void generateAccessToken_Success() {
        // Given
        UUID userId = UUID.randomUUID();
        String chainKey = "TEST00000001";
        String deviceId = "test-device";

        // When
        String token = jwtUtil.generateAccessToken(userId, chainKey, deviceId);

        // Then
        assertThat(token).isNotNull().isNotEmpty();
        assertThat(token.split("\\.")).hasSize(3); // JWT has 3 parts
    }

    @Test
    void generateRefreshToken_Success() {
        // Given
        UUID userId = UUID.randomUUID();
        String deviceId = "test-device";

        // When
        String token = jwtUtil.generateRefreshToken(userId, deviceId);

        // Then
        assertThat(token).isNotNull().isNotEmpty();
    }

    @Test
    void extractUserId_ValidToken_ReturnsUserId() {
        // Given
        UUID userId = UUID.randomUUID();
        String chainKey = "TEST00000001";
        String deviceId = "test-device";
        String token = jwtUtil.generateAccessToken(userId, chainKey, deviceId);

        // When
        UUID extractedUserId = jwtUtil.extractUserId(token);

        // Then
        assertThat(extractedUserId).isEqualTo(userId);
    }

    @Test
    void extractDeviceId_ValidToken_ReturnsDeviceId() {
        // Given
        UUID userId = UUID.randomUUID();
        String chainKey = "TEST00000001";
        String deviceId = "test-device";
        String token = jwtUtil.generateAccessToken(userId, chainKey, deviceId);

        // When
        String extractedDeviceId = jwtUtil.extractDeviceId(token);

        // Then
        assertThat(extractedDeviceId).isEqualTo(deviceId);
    }

    @Test
    void isTokenValid_ValidToken_ReturnsTrue() {
        // Given
        UUID userId = UUID.randomUUID();
        String chainKey = "TEST00000001";
        String deviceId = "test-device";
        String token = jwtUtil.generateAccessToken(userId, chainKey, deviceId);

        // When
        boolean isValid = jwtUtil.isTokenValid(token);

        // Then
        assertThat(isValid).isTrue();
    }

    @Test
    void isTokenValid_InvalidToken_ReturnsFalse() {
        // Given
        String invalidToken = "invalid.jwt.token";

        // When
        boolean isValid = jwtUtil.isTokenValid(invalidToken);

        // Then
        assertThat(isValid).isFalse();
    }

    @Test
    void isTokenValid_TamperedToken_ReturnsFalse() {
        // Given
        UUID userId = UUID.randomUUID();
        String chainKey = "TEST00000001";
        String deviceId = "test-device";
        String token = jwtUtil.generateAccessToken(userId, chainKey, deviceId);

        // Tamper with the token
        String tamperedToken = token.substring(0, token.length() - 5) + "XXXXX";

        // When
        boolean isValid = jwtUtil.isTokenValid(tamperedToken);

        // Then
        assertThat(isValid).isFalse();
    }

    @Test
    void refreshToken_ValidRefreshToken_CanExtractUserId() {
        // Given
        UUID userId = UUID.randomUUID();
        String deviceId = "test-device";
        String refreshToken = jwtUtil.generateRefreshToken(userId, deviceId);

        // Verify refresh token is valid
        assertThat(jwtUtil.isTokenValid(refreshToken)).isTrue();

        // When - Extract userId from refresh token
        UUID extractedUserId = jwtUtil.extractUserId(refreshToken);

        // Then
        assertThat(extractedUserId).isEqualTo(userId);
    }

    @Test
    void generateAccessToken_CanExtractAllFields() {
        // Given
        UUID userId = UUID.randomUUID();
        String chainKey = "TEST00000001";
        String deviceId = "test-device";

        // When
        String token = jwtUtil.generateAccessToken(userId, chainKey, deviceId);

        // Then - Verify all fields can be extracted
        assertThat(jwtUtil.extractUserId(token)).isEqualTo(userId);
        assertThat(jwtUtil.extractDeviceId(token)).isEqualTo(deviceId);
        assertThat(jwtUtil.isTokenValid(token)).isTrue();
    }
}
