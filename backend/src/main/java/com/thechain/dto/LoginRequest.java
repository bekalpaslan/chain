package com.thechain.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "User login request with credentials")
public class LoginRequest {

    @NotBlank(message = "Username is required")
    @Schema(
        description = "Username for authentication",
        example = "john_doe",
        requiredMode = Schema.RequiredMode.REQUIRED
    )
    private String username;

    @NotBlank(message = "Password is required")
    @Schema(
        description = "Password for authentication",
        example = "SecurePass123!",
        requiredMode = Schema.RequiredMode.REQUIRED
    )
    private String password;
}
