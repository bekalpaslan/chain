package com.thechain.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
@Schema(description = "Authentication response with user details and JWT tokens")
public class AuthResponse {

    @Schema(description = "Unique user identifier", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
    private UUID userId;

    @Schema(description = "User's unique chain key identifier", example = "CH-12345")
    private String chainKey;

    @Schema(description = "User's display name", example = "John Doe")
    private String displayName;

    @Schema(description = "User's position in the global chain", example = "12345")
    private Integer position;

    @Schema(description = "UUID of the parent user who invited this user", example = "b2c3d4e5-f6a7-8901-bcde-f12345678901")
    private UUID parentId;

    @Schema(description = "Display name of the parent user", example = "Jane Smith")
    private String parentDisplayName;

    @Schema(description = "Account creation timestamp", example = "2024-01-15T10:30:00Z")
    private Instant createdAt;

    @Schema(description = "JWT token information")
    private TokenInfo tokens;

    @Data
    @Builder
    @Schema(description = "JWT token information")
    public static class TokenInfo {

        @Schema(description = "JWT access token for API authentication", example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
        private String accessToken;

        @Schema(description = "JWT refresh token for obtaining new access tokens", example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
        private String refreshToken;

        @Schema(description = "Access token expiration time in seconds", example = "3600")
        private Long expiresIn;
    }
}
