package com.thechain.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

/**
 * Response DTO for POST /tickets/scan endpoint.
 * Contains ticket details plus parent (inviter) information for the registration UI.
 */
@Data
@Builder
@Schema(description = "Ticket scan response with inviter information for registration")
public class TicketScanResponse {

    // --- Ticket Information ---

    @Schema(description = "Unique ticket identifier", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
    private UUID ticketId;

    @Schema(description = "Current ticket status", example = "ACTIVE", allowableValues = {"ACTIVE", "USED", "EXPIRED"})
    private String status;

    @Schema(description = "Ticket issuance timestamp", example = "2024-01-15T10:30:00Z")
    private Instant issuedAt;

    @Schema(description = "Ticket expiration timestamp", example = "2024-01-16T10:30:00Z")
    private Instant expiresAt;

    @Schema(description = "Remaining time in milliseconds until expiration", example = "86400000")
    private Long timeRemaining;

    @Schema(description = "Which attempt number this is for the inviter (1, 2, or 3)", example = "1")
    private Integer attemptNumber;

    @Schema(description = "Current ticket duration in hours", example = "24")
    private Integer durationHours;

    // --- Inviter (Parent) Information ---

    @Schema(description = "UUID of the inviter (ticket owner)", example = "b2c3d4e5-f6a7-8901-bcde-f12345678901")
    private UUID inviterId;

    @Schema(description = "Display name of the inviter", example = "CryptoKing")
    private String inviterDisplayName;

    @Schema(description = "Chain key of the inviter", example = "ABCD1234EF56")
    private String inviterChainKey;

    @Schema(description = "Position of the inviter in the chain", example = "42")
    private Integer inviterPosition;

    @Schema(description = "Country of the inviter (ISO 3166-1 alpha-2)", example = "US")
    private String inviterCountry;

    @Schema(description = "Membership tier of the inviter", example = "permanent", allowableValues = {"candidate", "permanent"})
    private String inviterMembershipTier;

    // --- Chain Context ---

    @Schema(description = "Your position in the chain if you join", example = "43")
    private Integer yourFuturePosition;

    @Schema(description = "Total active members in the chain", example = "1234")
    private Long totalChainMembers;

    // --- Validation Status ---

    @Schema(description = "Whether the ticket is valid and ready for registration", example = "true")
    private Boolean isValid;

    @Schema(description = "Validation message if ticket is invalid", example = "Ticket has expired")
    private String validationMessage;
}
