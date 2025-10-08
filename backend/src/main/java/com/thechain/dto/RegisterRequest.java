package com.thechain.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.math.BigDecimal;
import java.util.UUID;

@Data
public class RegisterRequest {

    @NotNull(message = "Ticket ID is required")
    private UUID ticketId;

    @NotBlank(message = "Ticket signature is required")
    private String ticketSignature;

    @Size(min = 3, max = 50, message = "Display name must be between 3 and 50 characters")
    private String displayName;

    @NotBlank(message = "Device ID is required")
    private String deviceId;

    @NotBlank(message = "Device fingerprint is required")
    private String deviceFingerprint;

    private Boolean shareLocation = false;

    private BigDecimal latitude;

    private BigDecimal longitude;
}
