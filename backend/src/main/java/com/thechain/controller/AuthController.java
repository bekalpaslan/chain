package com.thechain.controller;

import com.thechain.dto.AuthResponse;
import com.thechain.dto.ErrorResponse;
import com.thechain.dto.LoginRequest;
import com.thechain.dto.RegisterRequest;
import com.thechain.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "User authentication and registration endpoints")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @Operation(
        summary = "Register new user",
        description = "Creates a new user account using a valid invite ticket. The ticket must be active and not expired. " +
                     "Upon successful registration, returns user details and JWT tokens for authentication."
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "201",
            description = "User registered successfully",
            content = @Content(schema = @Schema(implementation = AuthResponse.class))
        ),
        @ApiResponse(
            responseCode = "400",
            description = "Invalid ticket, ticket expired, or validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        ),
        @ApiResponse(
            responseCode = "409",
            description = "Username already exists",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    @SecurityRequirements // No authentication required for registration
    public ResponseEntity<AuthResponse> register(
        @Parameter(description = "Registration request with user details and invite ticket")
        @Valid @RequestBody RegisterRequest request
    ) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/login")
    @Operation(
        summary = "Authenticate user",
        description = "Login with username and password to receive JWT access and refresh tokens. " +
                     "The access token should be included in the Authorization header for authenticated requests."
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Login successful",
            content = @Content(schema = @Schema(implementation = AuthResponse.class))
        ),
        @ApiResponse(
            responseCode = "401",
            description = "Invalid credentials",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    @SecurityRequirements // No authentication required for login
    public ResponseEntity<AuthResponse> login(
        @Parameter(description = "Login credentials")
        @Valid @RequestBody LoginRequest request
    ) {
        AuthResponse response = authService.login(request.getUsername(), request.getPassword());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/refresh")
    @Operation(
        summary = "Refresh access token",
        description = "Use a valid refresh token to obtain a new access token without re-authenticating. " +
                     "Refresh tokens have a longer expiration time than access tokens."
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Token refreshed successfully",
            content = @Content(schema = @Schema(implementation = AuthResponse.class))
        ),
        @ApiResponse(
            responseCode = "401",
            description = "Invalid or expired refresh token",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    @SecurityRequirements // No authentication required for token refresh
    public ResponseEntity<AuthResponse> refreshToken(
        @Parameter(description = "Refresh token request")
        @RequestBody Map<String, String> request
    ) {
        String refreshToken = request.get("refreshToken");
        AuthResponse response = authService.refreshToken(refreshToken);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/health")
    @Operation(
        summary = "Health check",
        description = "Simple health check endpoint to verify the authentication service is running"
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Service is healthy"
        )
    })
    @SecurityRequirements // No authentication required for health check
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of("status", "UP", "service", "chain-backend"));
    }
}
