package com.thechain.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
@Schema(description = "Invite ticket response with QR code and metadata")
public class TicketResponse {

    @Schema(description = "Unique ticket identifier", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
    private UUID ticketId;

    @Schema(description = "QR code payload data for scanning", example = "{\"ticketId\":\"...\",\"signature\":\"...\"}")
    private String qrPayload;

    @Schema(description = "URL to the QR code image", example = "https://api.thechain.app/qr/a1b2c3d4-e5f6-7890-abcd-ef1234567890.png")
    private String qrCodeUrl;

    @Schema(description = "Deep link for mobile apps", example = "thechain://invite?ticket=a1b2c3d4-e5f6-7890-abcd-ef1234567890")
    private String deepLink;

    @Schema(description = "Cryptographic signature for ticket verification", example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
    private String signature;

    @Schema(description = "Ticket issuance timestamp", example = "2024-01-15T10:30:00Z")
    private Instant issuedAt;

    @Schema(description = "Ticket expiration timestamp (24 hours after issuance)", example = "2024-01-16T10:30:00Z")
    private Instant expiresAt;

    @Schema(description = "Current ticket status", example = "ACTIVE", allowableValues = {"ACTIVE", "USED", "EXPIRED"})
    private String status;

    @Schema(description = "Remaining time in seconds until expiration", example = "86400")
    private Long timeRemaining;

    @Schema(description = "UUID of the ticket owner (issuer)", example = "b2c3d4e5-f6a7-8901-bcde-f12345678901")
    private UUID ownerId;
}
