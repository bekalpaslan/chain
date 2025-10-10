package com.thechain.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "User registration request with invite ticket")
public class RegisterRequest {

    @NotNull(message = "Ticket ID is required")
    @Schema(
        description = "UUID of the invite ticket obtained from QR code scan",
        example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
        requiredMode = Schema.RequiredMode.REQUIRED
    )
    private UUID ticketId;

    @NotBlank(message = "Ticket signature is required")
    @Schema(
        description = "Cryptographic signature of the ticket for verification",
        example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        requiredMode = Schema.RequiredMode.REQUIRED
    )
    private String ticketSignature;

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 20, message = "Username must be between 3 and 20 characters")
    @Schema(
        description = "Desired username (3-20 characters, must be unique)",
        example = "john_doe",
        minLength = 3,
        maxLength = 20,
        requiredMode = Schema.RequiredMode.REQUIRED
    )
    private String username;

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    @Schema(
        description = "Password (minimum 6 characters)",
        example = "SecurePass123!",
        minLength = 6,
        requiredMode = Schema.RequiredMode.REQUIRED
    )
    private String password;

    @Size(min = 3, max = 50, message = "Display name must be between 3 and 50 characters")
    @Schema(
        description = "Display name shown to other users (3-50 characters, optional)",
        example = "John Doe",
        minLength = 3,
        maxLength = 50,
        requiredMode = Schema.RequiredMode.NOT_REQUIRED
    )
    private String displayName;
}
