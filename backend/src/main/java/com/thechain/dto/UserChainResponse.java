package com.thechain.dto;

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
public class UserChainResponse {
    private UUID userId;
    private String chainKey;
    private String displayName;
    private Integer position;
    private String status; // active, removed
    private Instant joinedAt;
    private String invitationStatus; // ACTIVE, REMOVED, REVERTED
}
