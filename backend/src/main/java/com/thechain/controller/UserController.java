package com.thechain.controller;

import com.thechain.dto.ErrorResponse;
import com.thechain.dto.UserProfileResponse;
import com.thechain.dto.UserChainResponse;
import com.thechain.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@Tag(name = "Users", description = "User profile and chain management")
@SecurityRequirement(name = "bearerAuth")
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    @Operation(
        summary = "Get current user profile",
        description = "Retrieves the authenticated user's profile information including chain position, " +
                     "parent/child relationships, and account statistics."
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Profile retrieved successfully",
            content = @Content(schema = @Schema(implementation = UserProfileResponse.class))
        ),
        @ApiResponse(
            responseCode = "401",
            description = "Authentication required",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        ),
        @ApiResponse(
            responseCode = "404",
            description = "User not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    public ResponseEntity<UserProfileResponse> getCurrentUser(Authentication authentication) {
        // Get user ID from SecurityContext (set by JwtAuthenticationFilter)
        UUID userId = (UUID) authentication.getPrincipal();
        UserProfileResponse profile = userService.getUserProfile(userId);
        return ResponseEntity.ok(profile);
    }

    @GetMapping("/me/chain")
    @Operation(
        summary = "Get user's chain (invited users)",
        description = "Retrieves the list of users directly invited by the authenticated user. " +
                     "Shows the user's descendants in the chain with their status and join dates."
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Chain retrieved successfully",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = UserChainResponse.class)))
        ),
        @ApiResponse(
            responseCode = "401",
            description = "Authentication required",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        ),
        @ApiResponse(
            responseCode = "404",
            description = "User not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    public ResponseEntity<List<UserChainResponse>> getMyChain(Authentication authentication) {
        // Get user ID from SecurityContext (set by JwtAuthenticationFilter)
        UUID userId = (UUID) authentication.getPrincipal();
        List<UserChainResponse> chain = userService.getUserChain(userId);
        return ResponseEntity.ok(chain);
    }
}
