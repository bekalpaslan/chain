package com.thechain.controller;

import com.thechain.dto.TicketResponse;
import com.thechain.service.TicketService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(locations = "classpath:application-test.yml")
class TicketControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private TicketService ticketService;

    private TicketResponse ticketResponse;
    private UUID ticketId;
    private UUID userId;

    @BeforeEach
    void setUp() {
        ticketId = UUID.randomUUID();
        userId = UUID.randomUUID();

        ticketResponse = TicketResponse.builder()
                .ticketId(ticketId)
                .ownerId(userId)
                .status("ACTIVE")
                .signature("test-signature")
                .qrCodeUrl("data:image/png;base64,test")
                .qrPayload("test-payload")
                .deepLink("thechain://join?t=" + ticketId)
                .issuedAt(Instant.now())
                .expiresAt(Instant.now().plusSeconds(86400))
                .timeRemaining(86400L)
                .build();
    }

    @Test
    void generateTicket_Success_Returns201() throws Exception {
        // Given
        when(ticketService.generateTicket(any(UUID.class))).thenReturn(ticketResponse);

        // When & Then
        mockMvc.perform(post("/tickets/generate")
                        .header("X-User-Id", userId.toString())
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.ticketId").value(ticketId.toString()))
                .andExpect(jsonPath("$.status").value("ACTIVE"))
                .andExpect(jsonPath("$.signature").value("test-signature"))
                .andExpect(jsonPath("$.qrCodeUrl").exists())
                .andExpect(jsonPath("$.deepLink").exists());
    }

    @Test
    void generateTicket_WithoutUserId_Returns400() throws Exception {
        // When & Then
        mockMvc.perform(post("/tickets/generate")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isBadRequest());
    }

    @Test
    void getTicket_Success_Returns200() throws Exception {
        // Given
        when(ticketService.getTicket(ticketId)).thenReturn(ticketResponse);

        // When & Then
        mockMvc.perform(get("/tickets/" + ticketId)
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ticketId").value(ticketId.toString()))
                .andExpect(jsonPath("$.status").value("ACTIVE"))
                .andExpect(jsonPath("$.timeRemaining").exists());
    }

    @Test
    void getTicket_InvalidUUID_Returns400() throws Exception {
        // When & Then
        mockMvc.perform(get("/tickets/invalid-uuid")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isBadRequest());
    }
}
