package com.thechain.controller;

import com.thechain.dto.ErrorResponse;
import com.thechain.dto.TicketResponse;
import com.thechain.service.TicketService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/tickets")
@RequiredArgsConstructor
@Tag(name = "Tickets", description = "Invite ticket generation and management")
@SecurityRequirement(name = "bearerAuth")
public class TicketController {

    private final TicketService ticketService;

    @PostMapping("/generate")
    @Operation(
        summary = "Generate invite ticket",
        description = "Creates a new invite ticket with QR code for the authenticated user. " +
                     "Users can only have one active ticket at a time. Tickets expire after 24 hours. " +
                     "There's a 10-minute cooldown between ticket generations."
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "201",
            description = "Ticket generated successfully",
            content = @Content(schema = @Schema(implementation = TicketResponse.class))
        ),
        @ApiResponse(
            responseCode = "400",
            description = "User already has an active ticket or is in cooldown period",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        ),
        @ApiResponse(
            responseCode = "401",
            description = "Authentication required",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        ),
        @ApiResponse(
            responseCode = "409",
            description = "User already has an active child (cannot generate new ticket)",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    public ResponseEntity<TicketResponse> generateTicket(
        @Parameter(description = "User ID from JWT token", required = true, hidden = true)
        @RequestHeader("X-User-Id") UUID userId
    ) {
        TicketResponse response = ticketService.generateTicket(userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{ticketId}")
    @Operation(
        summary = "Get ticket details",
        description = "Retrieves details of a specific ticket including its status, expiration time, and QR code. " +
                     "This endpoint is public and does not require authentication."
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Ticket found",
            content = @Content(schema = @Schema(implementation = TicketResponse.class))
        ),
        @ApiResponse(
            responseCode = "404",
            description = "Ticket not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    public ResponseEntity<TicketResponse> getTicket(
        @Parameter(description = "UUID of the ticket to retrieve", required = true)
        @PathVariable UUID ticketId
    ) {
        TicketResponse response = ticketService.getTicket(ticketId);
        return ResponseEntity.ok(response);
    }
}
