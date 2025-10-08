package com.thechain.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.thechain.dto.AuthResponse;
import com.thechain.dto.RegisterRequest;
import com.thechain.dto.AuthResponse.TokenInfo;
import com.thechain.service.AuthService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.FilterType;
@WebMvcTest(controllers = AuthController.class, excludeAutoConfiguration = {org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration.class, org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration.class, org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration.class})
class AuthControllerTest {

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
        registerRequest.setDisplayName("Test User");
        registerRequest.setDeviceId("test-device");
        registerRequest.setDeviceFingerprint("test-fingerprint");
        registerRequest.setShareLocation(false);

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
        // Given
        registerRequest.setShareLocation(true);
        registerRequest.setLatitude(new BigDecimal("52.5200"));
        registerRequest.setLongitude(new BigDecimal("13.4050"));

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
        loginRequest.put("deviceId", "test-device");
        loginRequest.put("deviceFingerprint", "test-fingerprint");

        when(authService.login("test-device", "test-fingerprint"))
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
    void health_Returns200() throws Exception {
        // When & Then
        mockMvc.perform(get("/auth/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"))
                .andExpect(jsonPath("$.service").value("chain-backend"));
    }
}
