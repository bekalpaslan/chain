package com.thechain.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "User profile information")
public class UserProfileResponse {

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

    @Schema(description = "UUID of the user's current active child (invited user)", example = "c3d4e5f6-a7b8-9012-cdef-123456789012")
    private UUID activeChildId;

    @Schema(description = "User account status", example = "ACTIVE", allowableValues = {"ACTIVE", "REMOVED", "REVERTED"})
    private String status;

    @Schema(description = "Number of tickets this user let expire without use", example = "2")
    private Integer wastedTicketsCount;

    @Schema(description = "Account creation timestamp", example = "2024-01-15T10:30:00Z")
    private Instant createdAt;
}
