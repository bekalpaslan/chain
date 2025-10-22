package com.thechain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

/**
 * Chain member representation for dashboard visibility (±1 positions)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChainMemberDto {

    /**
     * User's display name
     */
    private String displayName;

    /**
     * User's unique chain key
     */
    private String chainKey;

    /**
     * User's position in the global chain
     */
    private Integer position;

    /**
     * Member status (active, pending, expired, removed, tip, genesis, milestone, ghost)
     */
    private String status;

    /**
     * Whether this is the current authenticated user
     */
    private Boolean isCurrentUser;

    /**
     * User's avatar emoji
     */
    private String avatarEmoji;

    /**
     * When the user joined the chain
     */
    private Instant joinedAt;

    /**
     * Number of users this member has successfully invited
     */
    private Integer invitedCount;

    /**
     * User's country code (ISO 3166-1 alpha-2, e.g., "US", "GB", "DE")
     */
    private String countryCode;
}
