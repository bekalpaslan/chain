package com.thechain.config;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Comprehensive CORS Configuration Integration Tests
 *
 * Tests CORS (Cross-Origin Resource Sharing) configuration to ensure:
 * 1. Allowed origins (localhost:3000, localhost:3001, localhost:8080) can access the API
 * 2. Unauthorized origins are blocked
 * 3. Preflight OPTIONS requests are handled correctly
 * 4. All necessary CORS headers are present in responses
 *
 * Context:
 * - Backend API: http://localhost:8080
 * - Flutter Public App: http://localhost:3000
 * - Flutter Private App: http://localhost:3001
 */
@ActiveProfiles("test")
class CorsConfigurationTest extends BaseIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    // ==================== Allowed Origins Tests ====================

    @Test
    void corsRequest_FromPublicApp_ShouldBeAllowed() throws Exception {
        // Test that Flutter public app (localhost:3000) can access the API
        mockMvc.perform(get("/chain/stats")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:3000"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"));
    }

    @Test
    void corsRequest_FromPrivateApp_ShouldBeAllowed() throws Exception {
        // Test that Flutter private app (localhost:3001) can access the API
        mockMvc.perform(get("/chain/stats")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3001")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:3001"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"));
    }

    @Test
    void corsRequest_FromBackendApi_ShouldBeAllowed() throws Exception {
        // Test that same-origin requests from backend (localhost:8080) are allowed
        mockMvc.perform(get("/chain/stats")
                        .header(HttpHeaders.ORIGIN, "http://localhost:8080")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:8080"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"));
    }

    // ==================== Unauthorized Origins Tests ====================

    @Test
    void corsRequest_FromUnauthorizedOrigin_ShouldBeBlocked() throws Exception {
        // Test that requests from unauthorized origins are blocked
        // The request will succeed but CORS headers will not include the origin
        mockMvc.perform(get("/chain/stats")
                        .header(HttpHeaders.ORIGIN, "http://evil.com")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                // Access-Control-Allow-Origin header should NOT be present or should not match
                .andExpect(result -> {
                    String allowOrigin = result.getResponse().getHeader(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN);
                    // Either header is null or doesn't match the evil origin
                    if (allowOrigin != null) {
                        // Should not be "http://evil.com"
                        assert !allowOrigin.equals("http://evil.com") :
                            "Unauthorized origin should not be in Access-Control-Allow-Origin header";
                    }
                });
    }

    @Test
    void corsRequest_FromRandomPort_ShouldBeBlocked() throws Exception {
        // Test that localhost with unauthorized port is blocked
        mockMvc.perform(get("/chain/stats")
                        .header(HttpHeaders.ORIGIN, "http://localhost:9999")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(result -> {
                    String allowOrigin = result.getResponse().getHeader(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN);
                    if (allowOrigin != null) {
                        assert !allowOrigin.equals("http://localhost:9999") :
                            "Unauthorized port should not be in Access-Control-Allow-Origin header";
                    }
                });
    }

    @Test
    void corsRequest_FromHttpsOrigin_ShouldBeBlocked() throws Exception {
        // Test that HTTPS version of localhost:3000 is blocked (we only allow HTTP)
        mockMvc.perform(get("/chain/stats")
                        .header(HttpHeaders.ORIGIN, "https://localhost:3000")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(result -> {
                    String allowOrigin = result.getResponse().getHeader(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN);
                    if (allowOrigin != null) {
                        assert !allowOrigin.equals("https://localhost:3000") :
                            "HTTPS origin should not be allowed when only HTTP is configured";
                    }
                });
    }

    // ==================== Preflight (OPTIONS) Request Tests ====================

    @Test
    void preflightRequest_FromPublicApp_ShouldSucceed() throws Exception {
        // Test OPTIONS preflight request from Flutter public app
        mockMvc.perform(options("/auth/register")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "POST")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_HEADERS, "Content-Type, Authorization"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:3000"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_METHODS,
                    containsString("POST")))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_MAX_AGE, "3600"));
    }

    @Test
    void preflightRequest_FromPrivateApp_ShouldSucceed() throws Exception {
        // Test OPTIONS preflight request from Flutter private app
        mockMvc.perform(options("/tickets")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3001")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "POST")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_HEADERS, "Content-Type, Authorization"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:3001"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_METHODS,
                    containsString("POST")))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_MAX_AGE, "3600"));
    }

    @Test
    void preflightRequest_FromUnauthorizedOrigin_ShouldNotHaveCorsHeaders() throws Exception {
        // Test OPTIONS preflight from unauthorized origin
        mockMvc.perform(options("/auth/register")
                        .header(HttpHeaders.ORIGIN, "http://evil.com")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "POST")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_HEADERS, "Content-Type"))
                .andExpect(result -> {
                    String allowOrigin = result.getResponse().getHeader(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN);
                    if (allowOrigin != null) {
                        assert !allowOrigin.equals("http://evil.com") :
                            "Unauthorized origin should not receive CORS headers";
                    }
                });
    }

    // ==================== HTTP Methods Tests ====================

    @Test
    void corsRequest_WithGetMethod_ShouldBeAllowed() throws Exception {
        mockMvc.perform(get("/chain/stats")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000"))
                .andExpect(status().isOk())
                .andExpect(header().exists(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN));
    }

    @Test
    void corsRequest_WithPostMethod_ShouldBeAllowed() throws Exception {
        mockMvc.perform(post("/auth/register")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(header().exists(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN));
    }

    @Test
    void corsRequest_WithPutMethod_ShouldBeAllowed() throws Exception {
        mockMvc.perform(put("/tickets/123")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(header().exists(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN));
    }

    @Test
    void corsRequest_WithPatchMethod_ShouldBeAllowed() throws Exception {
        mockMvc.perform(patch("/tickets/123")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(header().exists(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN));
    }

    @Test
    void corsRequest_WithDeleteMethod_ShouldBeAllowed() throws Exception {
        mockMvc.perform(delete("/tickets/123")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000"))
                .andExpect(header().exists(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN));
    }

    @Test
    void preflightRequest_ForAllMethods_ShouldReturnAllowedMethods() throws Exception {
        mockMvc.perform(options("/tickets")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "GET"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_METHODS,
                    containsString("GET")))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_METHODS,
                    containsString("POST")))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_METHODS,
                    containsString("PUT")))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_METHODS,
                    containsString("PATCH")))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_METHODS,
                    containsString("DELETE")))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_METHODS,
                    containsString("OPTIONS")));
    }

    // ==================== Headers Tests ====================

    @Test
    void preflightRequest_ShouldAllowAllHeaders() throws Exception {
        // Test that all headers are allowed (configured as "*")
        mockMvc.perform(options("/auth/register")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "POST")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_HEADERS,
                            "Authorization, Content-Type, X-User-Id, Custom-Header"))
                .andExpect(status().isOk())
                .andExpect(header().exists(HttpHeaders.ACCESS_CONTROL_ALLOW_HEADERS));
    }

    @Test
    void corsResponse_ShouldExposeRequiredHeaders() throws Exception {
        // Test that response headers are exposed to the client
        mockMvc.perform(get("/chain/stats")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000"))
                .andExpect(status().isOk())
                .andExpect(header().exists(HttpHeaders.ACCESS_CONTROL_EXPOSE_HEADERS));
    }

    // ==================== Credentials Tests ====================

    @Test
    void corsRequest_ShouldAllowCredentials() throws Exception {
        // Test that credentials (cookies, auth headers) are allowed
        mockMvc.perform(get("/chain/stats")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer test-token"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"));
    }

    @Test
    void preflightRequest_WithAuthorizationHeader_ShouldBeAllowed() throws Exception {
        mockMvc.perform(options("/tickets")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3001")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "GET")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_HEADERS, "Authorization"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"));
    }

    // ==================== Endpoint Coverage Tests ====================

    @Test
    void corsRequest_ToPublicAuthEndpoint_ShouldWork() throws Exception {
        // Test CORS on public authentication endpoints
        mockMvc.perform(post("/auth/login")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:3000"));
    }

    @Test
    void corsRequest_ToPublicTicketEndpoint_ShouldWork() throws Exception {
        // Test CORS on public ticket endpoints
        mockMvc.perform(get("/tickets/test")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3001"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:3001"));
    }

    @Test
    void corsRequest_ToPublicChainEndpoint_ShouldWork() throws Exception {
        // Test CORS on public chain endpoints
        mockMvc.perform(get("/chain/stats")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:3000"));
    }

    @Test
    void corsRequest_ToActuatorEndpoint_ShouldWork() throws Exception {
        // Test CORS on actuator endpoints
        mockMvc.perform(get("/actuator/health")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:3000"));
    }

    // ==================== Max Age Tests ====================

    @Test
    void preflightRequest_ShouldSetMaxAge() throws Exception {
        // Test that preflight response is cached for 1 hour (3600 seconds)
        mockMvc.perform(options("/auth/register")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "POST"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_MAX_AGE, "3600"));
    }

    // ==================== Wildcard Path Tests ====================

    @Test
    void corsConfiguration_ShouldApplyToAllEndpoints() throws Exception {
        // Test that CORS is applied to all endpoints (/**)
        String[] endpoints = {
            "/auth/login",
            "/auth/register",
            "/tickets",
            "/chain/stats",
            "/actuator/health"
        };

        for (String endpoint : endpoints) {
            mockMvc.perform(get(endpoint)
                            .header(HttpHeaders.ORIGIN, "http://localhost:3000"))
                    .andExpect(header().exists(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN));
        }
    }

    // ==================== Real-World Scenario Tests ====================

    @Test
    void realWorldScenario_PublicAppLogin_ShouldHaveCorrectCorsHeaders() throws Exception {
        // Simulate real login request from Flutter public app
        mockMvc.perform(post("/auth/login")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000")
                        .header(HttpHeaders.CONTENT_TYPE, "application/json")
                        .content("{\"username\":\"test\",\"password\":\"test\"}"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:3000"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"));
    }

    @Test
    void realWorldScenario_PrivateAppTicketCreation_ShouldHaveCorrectCorsHeaders() throws Exception {
        // Simulate real ticket creation from Flutter private app
        mockMvc.perform(post("/tickets")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3001")
                        .header(HttpHeaders.CONTENT_TYPE, "application/json")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer fake-jwt-token")
                        .content("{}"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:3001"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"));
    }

    @Test
    void realWorldScenario_PreflightBeforeAuthenticatedRequest_ShouldSucceed() throws Exception {
        // Simulate preflight before authenticated request
        mockMvc.perform(options("/tickets")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3001")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "POST")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_HEADERS,
                            "Authorization, Content-Type"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:3001"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_METHODS, containsString("POST")))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_MAX_AGE, "3600"));
    }
}
