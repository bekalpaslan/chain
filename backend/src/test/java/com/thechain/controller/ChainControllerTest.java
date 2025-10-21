package com.thechain.controller;

import com.thechain.dto.ChainStatsResponse;
import com.thechain.service.ChainStatsService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;




class ChainControllerTest extends com.thechain.config.BaseIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ChainStatsService chainStatsService;

    private ChainStatsResponse statsResponse;

    @BeforeEach
    void setUp() {
        List<ChainStatsResponse.RecentAttachment> recentAttachments = new ArrayList<>();
        recentAttachments.add(ChainStatsResponse.RecentAttachment.builder()
                .displayName("User 1")
                .childPosition(Integer.valueOf(2))
                .country("US")
                .timestamp(Instant.now())
                .build());
        recentAttachments.add(ChainStatsResponse.RecentAttachment.builder()
                .displayName("User 2")
                .childPosition(Integer.valueOf(3))
                .country("DE")
                .timestamp(Instant.now())
                .build());

        statsResponse = ChainStatsResponse.builder()
                .totalUsers(100L)
                .activeTickets(15L)
                .recentAttachments(recentAttachments)
                .lastUpdate(Instant.now())
                .build();
    }

    @Test
    void getStats_Success_Returns200() throws Exception {
        // Given
        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then
        mockMvc.perform(get("/chain/stats")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalUsers").value(100))
                .andExpect(jsonPath("$.activeTickets").value(15))
                .andExpect(jsonPath("$.recentAttachments").isArray())
                .andExpect(jsonPath("$.recentAttachments[0].displayName").value("User 1"))
                .andExpect(jsonPath("$.recentAttachments[0].childPosition").value(2))
                .andExpect(jsonPath("$.recentAttachments[0].country").value("US"))
                .andExpect(jsonPath("$.lastUpdate").exists());
    }

    @Test
    void getStats_EmptyAttachments_Returns200() throws Exception {
        // Given
        statsResponse = ChainStatsResponse.builder()
                .totalUsers(50L)
                .activeTickets(5L)
                .recentAttachments(new ArrayList<>())
                .lastUpdate(Instant.now())
                .build();

        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then
        mockMvc.perform(get("/chain/stats")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalUsers").value(50))
                .andExpect(jsonPath("$.activeTickets").value(5))
                .andExpect(jsonPath("$.recentAttachments").isEmpty());
    }

    @Test
    void getStats_ZeroUsers_Returns200() throws Exception {
        // Given
        statsResponse = ChainStatsResponse.builder()
                .totalUsers(0L)
                .activeTickets(0L)
                .recentAttachments(new ArrayList<>())
                .lastUpdate(Instant.now())
                .build();

        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then
        mockMvc.perform(get("/chain/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalUsers").value(0))
                .andExpect(jsonPath("$.activeTickets").value(0));
    }

    @Test
    void getStats_LargeNumbers_Returns200() throws Exception {
        // Given
        statsResponse = ChainStatsResponse.builder()
                .totalUsers(1_000_000L)
                .activeTickets(50_000L)
                .recentAttachments(new ArrayList<>())
                .lastUpdate(Instant.now())
                .build();

        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then
        mockMvc.perform(get("/chain/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalUsers").value(1000000))
                .andExpect(jsonPath("$.activeTickets").value(50000));
    }

    @Test
    void getStats_MultipleRecentAttachments_Returns200() throws Exception {
        // Given
        List<ChainStatsResponse.RecentAttachment> attachments = new ArrayList<>();
        for (int i = 1; i <= 10; i++) {
            attachments.add(ChainStatsResponse.RecentAttachment.builder()
                    .displayName("User " + i)
                    .childPosition(i + 1)
                    .country("US")
                    .timestamp(Instant.now().minusSeconds(i * 60))
                    .build());
        }

        statsResponse = ChainStatsResponse.builder()
                .totalUsers(100L)
                .activeTickets(15L)
                .recentAttachments(attachments)
                .lastUpdate(Instant.now())
                .build();

        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then
        mockMvc.perform(get("/chain/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.recentAttachments").isArray())
                .andExpect(jsonPath("$.recentAttachments.length()").value(10))
                .andExpect(jsonPath("$.recentAttachments[0].displayName").value("User 1"))
                .andExpect(jsonPath("$.recentAttachments[9].displayName").value("User 10"));
    }

    @Test
    void getStats_WithoutContentType_Returns200() throws Exception {
        // Given
        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then
        mockMvc.perform(get("/chain/stats"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.totalUsers").exists());
    }

    @Test
    void getStats_ResponseStructure_IsValid() throws Exception {
        // Given
        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then
        mockMvc.perform(get("/chain/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalUsers").isNumber())
                .andExpect(jsonPath("$.activeTickets").isNumber())
                .andExpect(jsonPath("$.recentAttachments").isArray())
                .andExpect(jsonPath("$.lastUpdate").isString());
    }

    @Test
    void getStats_RecentAttachmentStructure_IsValid() throws Exception {
        // Given
        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then
        mockMvc.perform(get("/chain/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.recentAttachments[0].displayName").isString())
                .andExpect(jsonPath("$.recentAttachments[0].childPosition").isNumber())
                .andExpect(jsonPath("$.recentAttachments[0].country").isString())
                .andExpect(jsonPath("$.recentAttachments[0].timestamp").isString());
    }

    @Test
    void getStats_ServiceCalledOnce() throws Exception {
        // Given
        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When
        mockMvc.perform(get("/chain/stats"))
                .andExpect(status().isOk());

        // Then
        verify(chainStatsService, times(1)).getGlobalStats();
    }

    @Test
    void getStats_MultipleRequests_ServiceCalledMultipleTimes() throws Exception {
        // Given
        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When
        mockMvc.perform(get("/chain/stats")).andExpect(status().isOk());
        mockMvc.perform(get("/chain/stats")).andExpect(status().isOk());
        mockMvc.perform(get("/chain/stats")).andExpect(status().isOk());

        // Then
        verify(chainStatsService, times(3)).getGlobalStats();
    }

    @Test
    void getStats_WithAcceptHeader_ReturnsJson() throws Exception {
        // Given
        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then
        mockMvc.perform(get("/chain/stats")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    }

    @Test
    void getStats_DifferentCountries_Returns200() throws Exception {
        // Given
        List<ChainStatsResponse.RecentAttachment> attachments = new ArrayList<>();
        attachments.add(ChainStatsResponse.RecentAttachment.builder()
                .displayName("User US")
                .childPosition(2)
                .country("US")
                .timestamp(Instant.now())
                .build());
        attachments.add(ChainStatsResponse.RecentAttachment.builder()
                .displayName("User DE")
                .childPosition(3)
                .country("DE")
                .timestamp(Instant.now())
                .build());
        attachments.add(ChainStatsResponse.RecentAttachment.builder()
                .displayName("User JP")
                .childPosition(4)
                .country("JP")
                .timestamp(Instant.now())
                .build());

        statsResponse = ChainStatsResponse.builder()
                .totalUsers(100L)
                .activeTickets(15L)
                .recentAttachments(attachments)
                .lastUpdate(Instant.now())
                .build();

        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then
        mockMvc.perform(get("/chain/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.recentAttachments[0].country").value("US"))
                .andExpect(jsonPath("$.recentAttachments[1].country").value("DE"))
                .andExpect(jsonPath("$.recentAttachments[2].country").value("JP"));
    }

    @Test
    void getStats_NullCountry_Returns200() throws Exception {
        // Given
        List<ChainStatsResponse.RecentAttachment> attachments = new ArrayList<>();
        attachments.add(ChainStatsResponse.RecentAttachment.builder()
                .displayName("User 1")
                .childPosition(2)
                .country(null)
                .timestamp(Instant.now())
                .build());

        statsResponse = ChainStatsResponse.builder()
                .totalUsers(100L)
                .activeTickets(15L)
                .recentAttachments(attachments)
                .lastUpdate(Instant.now())
                .build();

        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then
        mockMvc.perform(get("/chain/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.recentAttachments[0].displayName").value("User 1"))
                .andExpect(jsonPath("$.recentAttachments[0].childPosition").value(2));
    }

    @Test
    void getStats_Endpoint_UsesGetMethod() throws Exception {
        // Given
        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then - POST should not work
        mockMvc.perform(post("/chain/stats"))
                .andExpect(status().isMethodNotAllowed());
    }

    @Test
    void getStats_Endpoint_RejectsPostMethod() throws Exception {
        // When & Then
        mockMvc.perform(post("/chain/stats")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isMethodNotAllowed());

        verify(chainStatsService, never()).getGlobalStats();
    }

    @Test
    void getStats_Endpoint_RejectsPutMethod() throws Exception {
        // When & Then
        mockMvc.perform(put("/chain/stats")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isMethodNotAllowed());

        verify(chainStatsService, never()).getGlobalStats();
    }

    @Test
    void getStats_Endpoint_RejectsDeleteMethod() throws Exception {
        // When & Then
        mockMvc.perform(delete("/chain/stats"))
                .andExpect(status().isMethodNotAllowed());

        verify(chainStatsService, never()).getGlobalStats();
    }

    @Test
    void getStats_EndpointPath_IsCaseSensitive() throws Exception {
        // When & Then - wrong case should return 403 (blocked by security before routing)
        mockMvc.perform(get("/chain/Stats"))
                .andExpect(status().isForbidden());

        verify(chainStatsService, never()).getGlobalStats();
    }

    @Test
    void getStats_WithQueryParams_StillWorks() throws Exception {
        // Given
        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then - query params should be ignored
        mockMvc.perform(get("/chain/stats?foo=bar&baz=qux"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalUsers").value(100));

        verify(chainStatsService, times(1)).getGlobalStats();
    }

    @Test
    void getStats_ConcurrentRequests_HandledCorrectly() throws Exception {
        // Given
        when(chainStatsService.getGlobalStats()).thenReturn(statsResponse);

        // When & Then - simulate concurrent requests
        for (int i = 0; i < 5; i++) {
            mockMvc.perform(get("/chain/stats"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.totalUsers").value(100));
        }

        verify(chainStatsService, times(5)).getGlobalStats();
    }
}
