package com.thechain.integration;

import com.thechain.dto.AuthResponse;
import com.thechain.dto.RegisterRequest;
import com.thechain.entity.Ticket;
import com.thechain.entity.User;
import com.thechain.exception.BusinessException;
import com.thechain.repository.TicketRepository;
import com.thechain.repository.UserRepository;
import com.thechain.service.AuthService;
import com.thechain.service.JwtService;
import com.thechain.service.TicketService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Integration test for JWT authentication flow.
 * Tests complete lifecycle: registration → login → token validation
 */
@SpringBootTest
@ActiveProfiles("test")
@TestPropertySource(properties = {
    "spring.flyway.enabled=false",
    "spring.jpa.hibernate.ddl-auto=create-drop"
})
@Transactional
class JwtAuthenticationIntegrationTest {

    @Autowired
    private AuthService authService;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private TicketService ticketService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TicketRepository ticketRepository;

    @Autowired
    private org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    private User seed;
    private Ticket validTicket;

    @BeforeEach
    void setUp() {
        // Create seed user at position 0
        seed = User.builder()
                .position(0)
                .chainKey("SEED00000000")
                .displayName("Seed User")
                .status("seed")
                .username("seeduser")
                .passwordHash(passwordEncoder.encode("seedpassword"))
                .wastedTicketsCount(0)
                .build();
        seed = userRepository.save(seed);

        // Generate a valid ticket using TicketService (properly signed)
        ticketService.generateTicket(seed.getId());

        // Retrieve the generated ticket
        validTicket = ticketRepository.findByOwnerIdAndStatus(seed.getId(), Ticket.TicketStatus.ACTIVE)
                .stream()
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Ticket not generated"));
    }

    @Test
    void completeAuthFlow_RegistrationToLoginToValidation() {
        // Step 1: Register new user via ticket
        RegisterRequest registerRequest = RegisterRequest.builder()
                .ticketId(validTicket.getId())
                .ticketSignature(validTicket.getSignature()) // Use actual ticket signature
                .username("newuser")
                .password("password123")
                .build();

        AuthResponse registrationResponse = authService.register(registerRequest);

        // Verify registration response
        assertThat(registrationResponse).isNotNull();
        assertThat(registrationResponse.getDisplayName()).isEqualTo("newuser");
        assertThat(registrationResponse.getPosition()).isEqualTo(1);
        assertThat(registrationResponse.getTokens()).isNotNull();
        assertThat(registrationResponse.getTokens().getAccessToken()).isNotNull();
        assertThat(registrationResponse.getTokens().getRefreshToken()).isNotNull();

        String accessToken = registrationResponse.getTokens().getAccessToken();
        String refreshToken = registrationResponse.getTokens().getRefreshToken();
        UUID newUserId = registrationResponse.getUserId();

        // Verify ticket was marked as used
        Ticket usedTicket = ticketRepository.findById(validTicket.getId()).orElseThrow();
        assertThat(usedTicket.getStatus()).isEqualTo(Ticket.TicketStatus.USED);
        assertThat(usedTicket.getUsedAt()).isNotNull();

        // Verify user was created in database
        User newUser = userRepository.findByUsername("newuser").orElseThrow();
        assertThat(newUser.getDisplayName()).isEqualTo("newuser");
        assertThat(newUser.getPosition()).isEqualTo(1);
        assertThat(newUser.getActiveChildId()).isNull(); // New user has no invitee yet

        // Step 2: Validate access token
        assertThat(jwtService.validateToken(accessToken, newUserId)).isTrue();
        assertThat(jwtService.extractChainKey(accessToken)).isNotNull();
        assertThat(jwtService.extractUserId(accessToken)).isEqualTo(newUserId);

        // Step 3: Validate refresh token
        assertThat(jwtService.validateRefreshToken(refreshToken, newUserId)).isTrue();

        // Step 4: Login with username/password
        AuthResponse loginResponse = authService.login("newuser", "password123");

        assertThat(loginResponse).isNotNull();
        assertThat(loginResponse.getTokens().getAccessToken()).isNotNull();
        assertThat(loginResponse.getTokens().getRefreshToken()).isNotNull();
        assertThat(loginResponse.getDisplayName()).isEqualTo("newuser");

        // Verify new tokens are valid
        String newAccessToken = loginResponse.getTokens().getAccessToken();
        assertThat(jwtService.validateToken(newAccessToken, newUserId)).isTrue();
    }

    @Test
    void registration_WithInvalidTicket_Fails() {
        RegisterRequest request = RegisterRequest.builder()
                .ticketId(UUID.randomUUID()) // Non-existent ticket
                .ticketSignature("test-signature")
                .username("newuser")
                .password("password123")
                .build();

        assertThatThrownBy(() -> authService.register(request))
            .isInstanceOf(BusinessException.class)
            .hasMessageContaining("Ticket not found");
    }

    @Test
    void registration_WithExpiredTicket_Fails() {
        // Create expired ticket
        Ticket expiredTicket = createExpiredTicket(seed);

        RegisterRequest request = RegisterRequest.builder()
                .ticketId(expiredTicket.getId())
                .ticketSignature("test-signature")
                .username("newuser")
                .password("password123")
                .build();

        assertThatThrownBy(() -> authService.register(request))
            .isInstanceOf(BusinessException.class)
            .hasMessageContaining("Ticket has expired");
    }

    @Test
    void registration_WithUsedTicket_Fails() {
        // Mark ticket as used
        validTicket.setStatus(Ticket.TicketStatus.USED);
        validTicket.setUsedAt(Instant.now());
        ticketRepository.save(validTicket);

        RegisterRequest request = RegisterRequest.builder()
                .ticketId(validTicket.getId())
                .ticketSignature("test-signature")
                .username("newuser")
                .password("password123")
                .build();

        assertThatThrownBy(() -> authService.register(request))
            .isInstanceOf(BusinessException.class)
            .hasMessageContaining("Ticket is used");
    }

    @Test
    void login_WithValidCredentials_ReturnsTokens() {
        // First, create a user
        User user = User.builder()
                .position(1)
                .chainKey("CK-00000001")
                .displayName("Test User")
                .username("testuser")
                .passwordHash(passwordEncoder.encode("password123"))
                .status("active")
                .wastedTicketsCount(0)
                .build();
        userRepository.save(user);

        // Login
        AuthResponse response = authService.login("testuser", "password123");

        assertThat(response.getTokens().getAccessToken()).isNotNull();
        assertThat(response.getTokens().getRefreshToken()).isNotNull();
        assertThat(jwtService.validateToken(response.getTokens().getAccessToken(), user.getId())).isTrue();
    }

    @Test
    void login_WithInvalidUsername_Fails() {
        assertThatThrownBy(() -> authService.login("nonexistent", "password"))
            .isInstanceOf(BusinessException.class)
            .hasMessageContaining("User not found");
    }

    @Test
    void login_WithWrongPassword_Fails() {
        // Create user
        User user = User.builder()
                .position(1)
                .chainKey("CK-00000001")
                .displayName("Test User")
                .username("testuser")
                .passwordHash(passwordEncoder.encode("password123"))
                .status("active")
                .wastedTicketsCount(0)
                .build();
        userRepository.save(user);

        // Try to login with wrong password
        assertThatThrownBy(() -> authService.login("testuser", "wrongpassword"))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("Invalid username or password");
    }

    @Test
    void tokenValidation_WithValidToken_Succeeds() {
        // Create user and generate token
        User user = User.builder()
                .position(1)
                .chainKey("CK-00000001")
                .displayName("Test User")
                .username("testuser")
                .status("active")
                .build();
        user = userRepository.save(user);

        String token = jwtService.generateAccessToken(user.getId(), user.getChainKey(), user.getPosition(), null);

        assertThat(jwtService.validateToken(token, user.getId())).isTrue();
        assertThat(jwtService.extractChainKey(token)).isEqualTo("CK-00000001");
        assertThat(jwtService.extractUserId(token)).isEqualTo(user.getId());
    }

    @Test
    void tokenValidation_WithInvalidToken_Fails() {
        String invalidToken = "invalid.jwt.token";
        UUID randomUserId = UUID.randomUUID();

        assertThat(jwtService.validateToken(invalidToken, randomUserId)).isFalse();
    }

    @Test
    void refreshToken_Generation_HasLongerExpiration() {
        User user = User.builder()
                .position(1)
                .chainKey("CK-00000001")
                .username("testuser")
                .build();
        user = userRepository.save(user);

        String accessToken = jwtService.generateAccessToken(user.getId(), user.getChainKey(), user.getPosition(), null);
        String refreshToken = jwtService.generateRefreshToken(user.getId(), null);

        // Both should be valid
        assertThat(jwtService.validateAccessToken(accessToken, user.getId())).isTrue();
        assertThat(jwtService.validateRefreshToken(refreshToken, user.getId())).isTrue();

        // Both should contain userId
        assertThat(jwtService.extractUserId(accessToken)).isEqualTo(user.getId());
        assertThat(jwtService.extractUserId(refreshToken)).isEqualTo(user.getId());

        // Verify token types
        assertThat(jwtService.extractTokenType(accessToken)).isEqualTo("access");
        assertThat(jwtService.extractTokenType(refreshToken)).isEqualTo("refresh");
    }

    @Test
    void multipleLogins_GenerateDifferentTokens() throws InterruptedException {
        User user = User.builder()
                .position(1)
                .chainKey("CK-00000001")
                .displayName("Test User")
                .username("testuser")
                .passwordHash(passwordEncoder.encode("password123"))
                .status("active")
                .wastedTicketsCount(0)
                .build();
        userRepository.save(user);

        AuthResponse response1 = authService.login("testuser", "password123");

        // Wait enough time to ensure different second in timestamp
        Thread.sleep(1100);

        AuthResponse response2 = authService.login("testuser", "password123");

        // Tokens should be different (different issuance time)
        assertThat(response1.getTokens().getAccessToken()).isNotEqualTo(response2.getTokens().getAccessToken());

        // But both should be valid and contain same user info
        assertThat(jwtService.validateToken(response1.getTokens().getAccessToken(), user.getId())).isTrue();
        assertThat(jwtService.validateToken(response2.getTokens().getAccessToken(), user.getId())).isTrue();

        assertThat(jwtService.extractChainKey(response1.getTokens().getAccessToken()))
            .isEqualTo(jwtService.extractChainKey(response2.getTokens().getAccessToken()));
    }

    @Test
    void accessToken_ContainsAllRequiredClaims() {
        User user = User.builder()
                .position(42)
                .chainKey("CK-00000042")
                .username("testuser")
                .build();
        user = userRepository.save(user);

        String accessToken = jwtService.generateAccessToken(user.getId(), user.getChainKey(), user.getPosition(), null);

        // Verify all claims
        assertThat(jwtService.extractUserId(accessToken)).isEqualTo(user.getId());
        assertThat(jwtService.extractChainKey(accessToken)).isEqualTo("CK-00000042");
        assertThat(jwtService.extractPosition(accessToken)).isEqualTo(42);
        assertThat(jwtService.extractTokenType(accessToken)).isEqualTo("access");
        assertThat(jwtService.isTokenExpired(accessToken)).isFalse();
    }

    @Test
    void registration_UpdatesParentInviteePosition() {
        RegisterRequest registerRequest = RegisterRequest.builder()
                .ticketId(validTicket.getId())
                .ticketSignature(validTicket.getSignature()) // Use actual ticket signature
                .username("newuser")
                .password("password123")
                .build();

        AuthResponse register = authService.register(registerRequest);

        // Verify parent (seed) now has inviteePosition set
        User updatedSeed = userRepository.findById(seed.getId()).orElseThrow();
        assertThat(updatedSeed.getActiveChildId()).isEqualTo(register.getUserId());
    }

    /**
     * Helper: Create an expired ticket for testing
     */
    private Ticket createExpiredTicket(User owner) {
        Instant past = Instant.now().minus(25, ChronoUnit.HOURS);
        String ticketCode = "EXPIRED-" + UUID.randomUUID().toString().substring(0, 8);

        // Create payload
        String payload = String.format("%s|%d|%d|%s",
                owner.getId().toString(),
                past.toEpochMilli(),
                past.plus(24, ChronoUnit.HOURS).toEpochMilli(),
                UUID.randomUUID().toString());

        Ticket ticket = Ticket.builder()
                .ownerId(owner.getId())
                .ticketCode(ticketCode)
                .nextPosition(owner.getPosition() + 1)
                .status(Ticket.TicketStatus.ACTIVE)
                .issuedAt(past)
                .expiresAt(past.plus(24, ChronoUnit.HOURS))
                .attemptNumber(1)
                .ruleVersion(1)
                .durationHours(24)
                .signature("test-signature") // Doesn't matter for expired ticket tests
                .payload(payload)
                .build();

        return ticketRepository.save(ticket);
    }
}
