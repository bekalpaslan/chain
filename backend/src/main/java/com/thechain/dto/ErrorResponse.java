package com.thechain.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Standard error response structure for all API errors
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Standard error response")
public class ErrorResponse {

    @Schema(description = "Error details")
    private ErrorDetails error;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @Schema(description = "Error details object")
    public static class ErrorDetails {

        @Schema(
            description = "Error code identifying the type of error",
            example = "INVALID_TICKET",
            requiredMode = Schema.RequiredMode.REQUIRED
        )
        private String code;

        @Schema(
            description = "Human-readable error message",
            example = "The provided ticket is invalid or has expired",
            requiredMode = Schema.RequiredMode.REQUIRED
        )
        private String message;

        @Schema(
            description = "Timestamp when the error occurred (ISO 8601 format)",
            example = "2024-01-15T10:30:00Z",
            requiredMode = Schema.RequiredMode.REQUIRED
        )
        private String timestamp;

        @Schema(
            description = "Unique request identifier for tracking and debugging",
            example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
            requiredMode = Schema.RequiredMode.REQUIRED
        )
        private String requestId;
    }
}
