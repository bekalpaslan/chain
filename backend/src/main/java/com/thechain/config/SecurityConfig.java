package com.thechain.config;

import com.thechain.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
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

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // Public endpoints
                .requestMatchers("/auth/**").permitAll()
                .requestMatchers("/actuator/**").permitAll()
                // OpenAPI documentation endpoints
                .requestMatchers("/api-docs/**").permitAll()
                .requestMatchers("/swagger-ui/**").permitAll()
                .requestMatchers("/swagger-ui.html").permitAll()
                .requestMatchers("/v3/api-docs/**").permitAll()
                // Temporarily allow ticket operations for testing
                .requestMatchers("/tickets/**").permitAll()
                // Allow chain stats to be public
                .requestMatchers("/chain/stats").permitAll()
                // All other endpoints require authentication
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // Allowed origins for Flutter frontend apps and backend API
        // Security consideration: Only allow specific localhost ports for development
        // In production, replace with actual domain names
        configuration.setAllowedOrigins(Arrays.asList(
            "http://localhost:3000",    // Flutter public app (port 3000)
            "http://localhost:3001",    // Flutter private app (port 3001)
            "http://localhost:8080"     // Backend API (same-origin requests)
        ));

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
        configuration.setAllowedHeaders(Arrays.asList("*"));

        // Expose headers that clients need to read
        configuration.setExposedHeaders(Arrays.asList(
            "Authorization",
            "X-User-Id",
            "Content-Type"
        ));

        // Allow credentials (cookies, authorization headers)
        // Required for JWT authentication
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
