package com.thechain.dto;

import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
public class AuthResponse {

    private UUID userId;
    private String chainKey;
    private String displayName;
    private Integer position;
    private UUID parentId;
    private String parentDisplayName;
    private Instant createdAt;
    private TokenInfo tokens;

    @Data
    @Builder
    public static class TokenInfo {
        private String accessToken;
        private String refreshToken;
        private Long expiresIn;
    }
}
