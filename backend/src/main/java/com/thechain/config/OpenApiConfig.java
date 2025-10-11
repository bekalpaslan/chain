package com.thechain.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Arrays;

/**
 * OpenAPI 3.0 configuration for The Chain API documentation.
 * Provides Swagger UI and OpenAPI JSON specification generation.
 */
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI chainOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("The Chain API")
                .version("1.0.0")
                .description("Grow with solidarity and trust. A social experiment. " +
                    "The Chain is a unique social network where users can only join through " +
                    "time-limited invite tickets, creating an exclusive and viral growth mechanism.")
                .contact(new Contact()
                    .name("The Chain Team")
                    .email("support@thechain.app")
                    .url("https://thechain.app"))
                .license(new License()
                    .name("MIT License")
                    .url("https://opensource.org/licenses/MIT")))
            .servers(Arrays.asList(
                new Server()
                    .url("http://localhost:8080/api/v1")
                    .description("Development server"),
                new Server()
                    .url("https://api.thechain.app/api/v1")
                    .description("Production server")))
            .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
            .components(new Components()
                .addSecuritySchemes("bearerAuth",
                    new SecurityScheme()
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("bearer")
                        .bearerFormat("JWT")
                        .description("JWT access token obtained from /auth/login or /auth/register. " +
                            "Format: 'Bearer <token>'")));
    }
}
