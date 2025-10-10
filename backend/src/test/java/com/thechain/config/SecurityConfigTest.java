package com.thechain.config;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SecurityConfigTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private SecurityConfig securityConfig;

    @Autowired
    private CorsConfigurationSource corsConfigurationSource;

    // ==================== Public Endpoints Tests ====================

    @Test
    void authRegisterEndpoint_ShouldBeAccessibleWithoutAuthentication() throws Exception {
        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(result -> {
                    int status = result.getResponse().getStatus();
                    // Should not be 401 (Unauthorized) or 403 (Forbidden)
                    assertThat(status).isNotIn(401, 403);
                });
    }

    @Test
    void authLoginEndpoint_ShouldBeAccessibleWithoutAuthentication() throws Exception {
        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(result -> {
                    int status = result.getResponse().getStatus();
                    // Should not be 401 (Unauthorized) or 403 (Forbidden)
                    assertThat(status).isNotIn(401, 403);
                });
    }

    @Test
    void actuatorHealthEndpoint_ShouldBeAccessibleWithoutAuthentication() throws Exception {
        mockMvc.perform(get("/actuator/health"))
                .andExpect(status().isOk());
    }

    @Test
    void ticketsEndpoint_ShouldBeAccessibleWithoutAuthentication() throws Exception {
        mockMvc.perform(get("/tickets/test")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(result -> {
                    int status = result.getResponse().getStatus();
                    // Should not be 401 (Unauthorized) or 403 (Forbidden)
                    assertThat(status).isNotIn(401, 403);
                });
    }

    @Test
    void chainStatsEndpoint_ShouldBeAccessibleWithoutAuthentication() throws Exception {
        mockMvc.perform(get("/chain/stats")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk()); // Should return stats
    }

    // ==================== Protected Endpoints Tests ====================

    @Test
    void protectedEndpoint_ShouldRequireAuthentication() throws Exception {
        mockMvc.perform(get("/api/protected")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isForbidden()); // 403 because no authentication
    }

    @Test
    void chainEndpoint_ShouldRequireAuthenticationForNonStatsRoutes() throws Exception {
        mockMvc.perform(get("/chain/user")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isForbidden()); // 403 because no authentication
    }

    // ==================== CORS Configuration Tests ====================

    @Test
    void corsConfiguration_ShouldAllowSpecificOrigins() throws Exception {
        CorsConfigurationSource source = securityConfig.corsConfigurationSource();
        CorsConfiguration config = source.getCorsConfiguration(
                mockMvc.perform(get("/chain/stats")).andReturn().getRequest()
        );

        assertThat(config).isNotNull();
        assertThat(config.getAllowedOrigins()).contains(
            "http://localhost:3000",
            "http://localhost:3001",
            "http://localhost:8080"
        );
    }

    @Test
    void corsConfiguration_ShouldAllowCommonHttpMethods() throws Exception {
        CorsConfigurationSource source = securityConfig.corsConfigurationSource();
        CorsConfiguration config = source.getCorsConfiguration(
                mockMvc.perform(get("/chain/stats")).andReturn().getRequest()
        );

        assertThat(config).isNotNull();
        assertThat(config.getAllowedMethods())
                .contains("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS");
    }

    @Test
    void corsConfiguration_ShouldAllowAllHeaders() throws Exception {
        CorsConfigurationSource source = securityConfig.corsConfigurationSource();
        CorsConfiguration config = source.getCorsConfiguration(
                mockMvc.perform(get("/chain/stats")).andReturn().getRequest()
        );

        assertThat(config).isNotNull();
        assertThat(config.getAllowedHeaders()).contains("*");
    }

    @Test
    void corsConfiguration_ShouldAllowCredentials() throws Exception {
        CorsConfigurationSource source = securityConfig.corsConfigurationSource();
        CorsConfiguration config = source.getCorsConfiguration(
                mockMvc.perform(get("/chain/stats")).andReturn().getRequest()
        );

        assertThat(config).isNotNull();
        assertThat(config.getAllowCredentials()).isTrue();
    }

    @Test
    void corsConfiguration_ShouldHaveMaxAge() throws Exception {
        CorsConfigurationSource source = securityConfig.corsConfigurationSource();
        CorsConfiguration config = source.getCorsConfiguration(
                mockMvc.perform(get("/chain/stats")).andReturn().getRequest()
        );

        assertThat(config).isNotNull();
        assertThat(config.getMaxAge()).isEqualTo(3600L);
    }

    @Test
    void corsPreflightRequest_ShouldBeHandledForPublicEndpoints() throws Exception {
        mockMvc.perform(options("/auth/register")
                        .header("Access-Control-Request-Method", "POST")
                        .header("Origin", "http://localhost:3000"))
                .andExpect(status().isOk());
    }

    // ==================== Session Management Tests ====================

    @Test
    void sessionManagement_ShouldBeStateless() throws Exception {
        // First request
        mockMvc.perform(get("/chain/stats"))
                .andExpect(status().isOk())
                .andExpect(result -> {
                    // Verify no session is created
                    assertThat(result.getRequest().getSession(false)).isNull();
                });

        // Second request should not reuse session
        mockMvc.perform(get("/chain/stats"))
                .andExpect(status().isOk())
                .andExpect(result -> {
                    assertThat(result.getRequest().getSession(false)).isNull();
                });
    }

    // ==================== CSRF Tests ====================

    @Test
    void csrfProtection_ShouldBeDisabled() throws Exception {
        // POST request without CSRF token should work for public endpoints
        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(result -> {
                    int status = result.getResponse().getStatus();
                    // Should not be 403 CSRF error
                    assertThat(status).isNotIn(401, 403);
                });
    }

    // ==================== Security Filter Chain Bean Tests ====================

    @Test
    void securityFilterChain_ShouldBeConfigured() throws Exception {
        assertThat(securityConfig).isNotNull();
        assertThat(securityConfig.securityFilterChain(null)).isNotNull();
    }

    @Test
    void corsConfigurationSource_ShouldBeConfigured() {
        assertThat(corsConfigurationSource).isNotNull();
        assertThat(securityConfig.corsConfigurationSource()).isNotNull();
    }

    // ==================== HTTP Methods Tests ====================

    @Test
    void publicEndpoint_ShouldAllowGetRequests() throws Exception {
        mockMvc.perform(get("/chain/stats"))
                .andExpect(status().isOk());
    }

    @Test
    void publicEndpoint_ShouldAllowPostRequests() throws Exception {
        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(result -> {
                    int status = result.getResponse().getStatus();
                    assertThat(status).isNotIn(401, 403);
                });
    }

    @Test
    void ticketsEndpoint_ShouldAllowPutRequests() throws Exception {
        mockMvc.perform(put("/tickets/123")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(result -> {
                    int status = result.getResponse().getStatus();
                    assertThat(status).isNotIn(401, 403);
                });
    }

    @Test
    void ticketsEndpoint_ShouldAllowDeleteRequests() throws Exception {
        mockMvc.perform(delete("/tickets/123"))
                .andExpect(result -> {
                    int status = result.getResponse().getStatus();
                    assertThat(status).isNotIn(401, 403);
                });
    }

    // ==================== Path Matching Tests ====================

    @Test
    void actuatorSubPaths_ShouldBeAccessible() throws Exception {
        mockMvc.perform(get("/actuator/health"))
                .andExpect(status().isOk());
    }

    @Test
    void ticketsSubPaths_ShouldBeAccessible() throws Exception {
        mockMvc.perform(get("/tickets/validate/test-token"))
                .andExpect(result -> {
                    int status = result.getResponse().getStatus();
                    assertThat(status).isNotIn(401, 403);
                });
    }

    // ==================== Content Type Tests ====================

    @Test
    void publicEndpoint_ShouldAcceptJsonContentType() throws Exception {
        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"username\":\"test\"}"))
                .andExpect(result -> {
                    int status = result.getResponse().getStatus();
                    assertThat(status).isNotIn(401, 403);
                });
    }

    @Test
    void publicEndpoint_ShouldAcceptFormContentType() throws Exception {
        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .param("username", "test"))
                .andExpect(result -> {
                    int status = result.getResponse().getStatus();
                    assertThat(status).isNotIn(401, 403);
                });
    }

    // ==================== Multiple Public Endpoints Tests ====================

    @Test
    void multiplePublicEndpoints_ShouldAllBeAccessible() throws Exception {
        String[] publicEndpoints = {
                "/auth/register",
                "/auth/login",
                "/actuator/health",
                "/tickets/test",
                "/chain/stats"
        };

        for (String endpoint : publicEndpoints) {
            mockMvc.perform(get(endpoint))
                    .andExpect(result -> {
                        int status = result.getResponse().getStatus();
                        // Should not be 401 (Unauthorized) or 403 (Forbidden)
                        assertThat(status).isNotIn(401, 403);
                    });
        }
    }
}
