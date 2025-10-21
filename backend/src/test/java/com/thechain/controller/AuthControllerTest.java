package com.thechain.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.thechain.dto.AuthResponse;
import com.thechain.dto.RegisterRequest;
import com.thechain.dto.AuthResponse.TokenInfo;
import com.thechain.service.AuthService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class AuthControllerTest extends com.thechain.config.BaseIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthService authService;

    private RegisterRequest registerRequest;
    private AuthResponse authResponse;

    @BeforeEach
    void setUp() {
        registerRequest = new RegisterRequest();
        registerRequest.setTicketId(UUID.randomUUID());
        registerRequest.setTicketSignature("test-signature");
        registerRequest.setUsername("testuser");
        registerRequest.setPassword("password123");

        authResponse = AuthResponse.builder()
                .userId(UUID.randomUUID())
                .chainKey("TEST00000001")
                .displayName("Test User")
                .tokens(TokenInfo.builder()
                        .accessToken("access-token")
                        .refreshToken("refresh-token")
                        .expiresIn(3600L)
                        .build())
                .build();
    }

    @Test
    void register_Success_Returns201() throws Exception {
        // Given
        when(authService.register(any(RegisterRequest.class))).thenReturn(authResponse);

        // When & Then
        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.userId").exists())
                .andExpect(jsonPath("$.chainKey").value("TEST00000001"))
                .andExpect(jsonPath("$.displayName").value("Test User"))
                .andExpect(jsonPath("$.tokens.accessToken").value("access-token"));
    }

    @Test
    void register_WithLocation_Success() throws Exception {

        when(authService.register(any(RegisterRequest.class))).thenReturn(authResponse);

        // When & Then
        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.userId").exists());
    }

    @Test
    void register_InvalidRequest_Returns400() throws Exception {
        // Given - Invalid request without required fields
        RegisterRequest invalidRequest = new RegisterRequest();

        // When & Then
        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void login_Success_Returns200() throws Exception {
        // Given
        Map<String, String> loginRequest = new HashMap<>();
        loginRequest.put("username", "testuser");
        loginRequest.put("password", "password123");

        when(authService.login("testuser", "password123"))
                .thenReturn(authResponse);

        // When & Then
        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").exists())
                .andExpect(jsonPath("$.tokens.accessToken").value("access-token"));
    }

    @Test
    void login_WithoutCredentials_Returns400() throws Exception {
        // Given - Empty request
        Map<String, String> loginRequest = new HashMap<>();

        // When & Then
        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void login_WithOnlyUsername_Returns400() throws Exception {
        // Given - Username without password
        Map<String, String> loginRequest = new HashMap<>();
        loginRequest.put("username", "testuser");

        // When & Then
        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void login_WithOnlyPassword_Returns400() throws Exception {
        // Given - Password without username
        Map<String, String> loginRequest = new HashMap<>();
        loginRequest.put("password", "password123");

        // When & Then
        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void health_Returns200() throws Exception {
        // When & Then
        mockMvc.perform(get("/auth/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"))
                .andExpect(jsonPath("$.service").value("chain-backend"));
    }

    @Test
    void refreshToken_Success_Returns200() throws Exception {
        // Given
        Map<String, String> refreshRequest = new HashMap<>();
        refreshRequest.put("refreshToken", "valid-refresh-token");

        when(authService.refreshToken("valid-refresh-token"))
                .thenReturn(authResponse);

        // When & Then
        mockMvc.perform(post("/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(refreshRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").exists())
                .andExpect(jsonPath("$.tokens.accessToken").value("access-token"))
                .andExpect(jsonPath("$.tokens.refreshToken").value("refresh-token"));
    }
}
