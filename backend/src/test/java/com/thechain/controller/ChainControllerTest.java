package com.thechain.controller;

import com.thechain.dto.ChainStatsResponse;
import com.thechain.service.ChainStatsService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(controllers = ChainController.class, excludeAutoConfiguration = {org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration.class, org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration.class, org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration.class})
class ChainControllerTest {

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
}
