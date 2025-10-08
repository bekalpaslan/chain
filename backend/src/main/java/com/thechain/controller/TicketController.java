package com.thechain.controller;

import com.thechain.dto.TicketResponse;
import com.thechain.service.TicketService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/tickets")
@RequiredArgsConstructor
public class TicketController {

    private final TicketService ticketService;

    @PostMapping("/generate")
    public ResponseEntity<TicketResponse> generateTicket(@RequestHeader("X-User-Id") UUID userId) {
        // In production, extract userId from JWT token
        TicketResponse response = ticketService.generateTicket(userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{ticketId}")
    public ResponseEntity<TicketResponse> getTicket(@PathVariable UUID ticketId) {
        TicketResponse response = ticketService.getTicket(ticketId);
        return ResponseEntity.ok(response);
    }
}
