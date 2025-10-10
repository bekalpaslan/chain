package com.thechain.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

/**
 * Response DTO for users in a chain (children invited by current user)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "User information for members of a user's chain (invited descendants)")
public class UserChainResponse {

    @Schema(description = "Unique user identifier", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
    private UUID userId;

    @Schema(description = "User's unique chain key identifier", example = "CH-12346")
    private String chainKey;

    @Schema(description = "User's display name", example = "Jane Smith")
    private String displayName;

    @Schema(description = "User's position in the global chain", example = "12346")
    private Integer position;

    @Schema(description = "User account status", example = "ACTIVE", allowableValues = {"ACTIVE", "REMOVED"})
    private String status;

    @Schema(description = "Timestamp when user joined the chain", example = "2024-01-15T10:30:00Z")
    private Instant joinedAt;

    @Schema(description = "Invitation status", example = "ACTIVE", allowableValues = {"ACTIVE", "REMOVED", "REVERTED"})
    private String invitationStatus;
}
