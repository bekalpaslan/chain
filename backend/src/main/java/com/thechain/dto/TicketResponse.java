package com.thechain.dto;

import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
public class TicketResponse {

    private UUID ticketId;
    private String qrPayload;
    private String qrCodeUrl;
    private String deepLink;
    private String signature;
    private Instant issuedAt;
    private Instant expiresAt;
    private String status;
    private Long timeRemaining;
    private UUID ownerId;
}
