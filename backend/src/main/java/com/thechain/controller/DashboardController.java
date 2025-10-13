package com.thechain.controller;

import com.thechain.dto.DashboardResponse;
import com.thechain.dto.ErrorResponse;
import com.thechain.service.DashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

/**
 * Dashboard Controller
 * Provides comprehensive dashboard data for authenticated users
 *
 * @author Backend Team
 * @since 2025-01-12
 */
@RestController
@RequestMapping("/users/me")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Dashboard", description = "User dashboard data aggregation")
@SecurityRequirement(name = "bearerAuth")
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/dashboard")
    @Operation(
        summary = "Get comprehensive dashboard data",
        description = "Retrieves all dashboard data for the authenticated user including: " +
                     "user profile, visible chain members (±1), statistics, critical actions, " +
                     "recent activities, achievements, and notification status. " +
                     "This endpoint aggregates data from multiple sources for efficient dashboard loading."
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Dashboard data retrieved successfully",
            content = @Content(schema = @Schema(implementation = DashboardResponse.class))
        ),
        @ApiResponse(
            responseCode = "401",
            description = "Authentication required - invalid or missing JWT token",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        ),
        @ApiResponse(
            responseCode = "404",
            description = "User not found - the authenticated user does not exist in the database",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        ),
        @ApiResponse(
            responseCode = "500",
            description = "Internal server error - unexpected error while aggregating dashboard data",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    public ResponseEntity<DashboardResponse> getDashboard(Authentication authentication) {
        // Get user ID from SecurityContext (set by JwtAuthenticationFilter)
        UUID userId = (UUID) authentication.getPrincipal();

        log.info("Dashboard request from user: {}", userId);

        // Get comprehensive dashboard data
        DashboardResponse dashboard = dashboardService.getDashboardData(userId);

        log.info("Dashboard data loaded successfully for user: {}", userId);

        return ResponseEntity.ok(dashboard);
    }
}
