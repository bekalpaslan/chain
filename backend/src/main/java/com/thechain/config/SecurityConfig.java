package com.thechain.config;

import com.thechain.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

/**
 * Security Configuration for The Chain Application
 *
 * Configures Spring Security with JWT-based authentication, CORS support,
 * and endpoint authorization rules.
 *
 * @author Backend Team
 * @since 2025-01-10
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    @Value("${cors.allowed-origins:http://localhost:3000,http://localhost:3001}")
    private String[] allowedOrigins;

    /**
     * Configures the security filter chain with JWT authentication and CORS.
     *
     * Security Features:
     * - CORS enabled using custom configuration
     * - CSRF disabled (stateless JWT authentication)
     * - Stateless session management
     * - JWT filter for token validation
     * - Public endpoints for authentication and documentation
     * - Protected endpoints requiring authentication
     *
     * @param http HttpSecurity configuration
     * @return configured SecurityFilterChain
     * @throws Exception if configuration fails
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            // Disable CSRF for stateless JWT authentication
            .csrf(csrf -> csrf.disable())

            // Enable CORS with custom configuration
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))

            // Stateless session management (no server-side sessions)
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

            // Configure endpoint authorization
            .authorizeHttpRequests(auth -> auth
                // Public endpoints - no authentication required
                .requestMatchers("/auth/**").permitAll()
                .requestMatchers("/actuator/**").permitAll()

                // OpenAPI documentation endpoints
                .requestMatchers("/api-docs/**").permitAll()
                .requestMatchers("/swagger-ui/**").permitAll()
                .requestMatchers("/swagger-ui.html").permitAll()
                .requestMatchers("/v3/api-docs/**").permitAll()

                // Allow OPTIONS requests for CORS preflight
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()

                // Temporarily allow ticket operations for testing
                .requestMatchers("/tickets/**").permitAll()

                // Allow chain stats to be public
                .requestMatchers("/chain/stats").permitAll()

                // All other endpoints require authentication
                .anyRequest().authenticated()
            )

            // Add JWT authentication filter before username/password filter
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * Configures CORS settings for the application.
     *
     * Configuration supports:
     * - Configurable allowed origins (via application properties)
     * - All standard HTTP methods needed for REST APIs
     * - JWT token handling via Authorization header
     * - Credentials support for cookie-based sessions if needed
     * - Preflight request caching to reduce OPTIONS calls
     *
     * @return CorsConfigurationSource with proper CORS settings
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // Set allowed origins - configurable via application.yml
        // Security consideration: Only allow specific origins, never use "*" with credentials
        // Default: http://localhost:3000,http://localhost:3001 for development
        // Production: Set via CORS_ALLOWED_ORIGINS environment variable
        configuration.setAllowedOrigins(Arrays.asList(allowedOrigins));

        // Allow all common HTTP methods including PATCH for partial updates
        configuration.setAllowedMethods(Arrays.asList(
            "GET",
            "POST",
            "PUT",
            "PATCH",
            "DELETE",
            "OPTIONS"
        ));

        // Allow all headers to support various client needs
        // This is secure because we've restricted origins
        // Includes Authorization for JWT tokens
        configuration.setAllowedHeaders(Arrays.asList("*"));

        // Expose headers that clients need to read
        // Authorization: For reading JWT tokens
        // X-Total-Count: For pagination
        // X-User-Id: For user identification
        configuration.setExposedHeaders(Arrays.asList(
            "Authorization",
            "X-User-Id",
            "X-Total-Count",
            "Content-Type"
        ));

        // Allow credentials (cookies, authorization headers)
        // Required for JWT authentication
        // NOTE: When credentials are true, allowedOrigins cannot be "*"
        configuration.setAllowCredentials(true);

        // Cache preflight response for 1 hour (3600 seconds)
        // Reduces OPTIONS requests overhead
        configuration.setMaxAge(3600L);

        // Apply CORS configuration to all endpoints
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
