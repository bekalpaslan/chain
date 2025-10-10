package com.thechain.controller;

import com.thechain.dto.ChainStatsResponse;
import com.thechain.dto.ErrorResponse;
import com.thechain.service.ChainStatsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/chain")
@RequiredArgsConstructor
@Tag(name = "Chain", description = "Global chain statistics and information")
public class ChainController {

    private final ChainStatsService chainStatsService;

    @GetMapping("/stats")
    @Operation(
        summary = "Get global chain statistics",
        description = "Retrieves global statistics about The Chain including total users, active tickets, " +
                     "growth metrics, and recent user attachments. This endpoint is public and does not require authentication."
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Statistics retrieved successfully",
            content = @Content(schema = @Schema(implementation = ChainStatsResponse.class))
        ),
        @ApiResponse(
            responseCode = "500",
            description = "Internal server error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    @SecurityRequirements // No authentication required for public stats
    public ResponseEntity<ChainStatsResponse> getStats() {
        ChainStatsResponse response = chainStatsService.getGlobalStats();
        return ResponseEntity.ok(response);
    }
}
