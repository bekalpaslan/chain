package com.thechain.service;

import com.thechain.dto.AuthResponse;
import com.thechain.dto.RegisterRequest;
import com.thechain.entity.Ticket;
import com.thechain.entity.User;
import com.thechain.exception.BusinessException;
import com.thechain.repository.AttachmentRepository;
import com.thechain.repository.InvitationRepository;
import com.thechain.repository.TicketRepository;
import com.thechain.repository.UserRepository;
import com.thechain.security.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private TicketRepository ticketRepository;

    @Mock
    private AttachmentRepository attachmentRepository;

    @Mock
    private TicketService ticketService;

    @Mock
    private JwtUtil jwtUtil;

    @Mock
    private InvitationRepository invitationRepository;

    @Mock
    private ChainService chainService;

    @Mock
    private org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    @InjectMocks
    private AuthService authService;

    private User testUser;
    private Ticket testTicket;
    private RegisterRequest registerRequest;

    @BeforeEach
    void setUp() {
        // Create test user
        testUser = User.builder()
                .id(UUID.randomUUID())
                .chainKey("TEST00000001")
                .displayName("Test User")
                .position(1)
                .username("testuser")
                .passwordHash("$2a$10$hashedPassword")
                .build();

        // Create test ticket
        testTicket = Ticket.builder()
                .id(UUID.randomUUID())
                .ownerId(testUser.getId())
                .status(Ticket.TicketStatus.ACTIVE)
                .signature("test-signature")
                .issuedAt(Instant.now())
                .expiresAt(Instant.now().plus(24, ChronoUnit.HOURS))
                .build();

        // Create register request
        registerRequest = new RegisterRequest();
        registerRequest.setTicketId(testTicket.getId());
        registerRequest.setTicketSignature("test-signature");
        registerRequest.setUsername("newuser");
        registerRequest.setPassword("password123");
    }

    @Test
    void register_Success() {
        // Given
        when(ticketRepository.findById(testTicket.getId())).thenReturn(Optional.of(testTicket));
        when(ticketService.verifyTicketSignature(testTicket, "test-signature")).thenReturn(true);
        when(userRepository.existsByUsername("newuser")).thenReturn(false);
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        when(userRepository.findMaxPosition()).thenReturn(1);

        User newUser = User.builder()
                .id(UUID.randomUUID())
                .chainKey("TEST00000002")
                .displayName("newuser")
                .position(2)
                .parentId(testUser.getId())
                .username("newuser")
                .passwordHash("$2a$10$hashedPassword")
                .build();

        when(userRepository.save(any(User.class))).thenReturn(newUser);
        when(passwordEncoder.encode("password123")).thenReturn("$2a$10$hashedPassword");
        when(jwtUtil.generateAccessToken(any(), any())).thenReturn("access-token");
        when(jwtUtil.generateRefreshToken(any())).thenReturn("refresh-token");

        // When
        AuthResponse response = authService.register(registerRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getDisplayName()).isEqualTo("newuser");
        assertThat(response.getPosition()).isEqualTo(2);
        assertThat(response.getParentId()).isEqualTo(testUser.getId());
        assertThat(response.getTokens().getAccessToken()).isEqualTo("access-token");

        verify(ticketRepository).save(any(Ticket.class));
        verify(userRepository, times(2)).save(any(User.class));
        verify(invitationRepository).save(any()); // New: Invitation record created
        verify(attachmentRepository).save(any());
        verify(chainService).checkAndAwardChainSaviorBadge(any(User.class)); // New: Badge check
    }

    @Test
    void register_TicketNotFound_ThrowsException() {
        // Given
        when(ticketRepository.findById(any())).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> authService.register(registerRequest))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("Ticket not found");
    }

    @Test
    void register_TicketExpired_ThrowsException() {
        // Given
        testTicket.setExpiresAt(Instant.now().minus(1, ChronoUnit.HOURS));
        when(ticketRepository.findById(testTicket.getId())).thenReturn(Optional.of(testTicket));

        // When & Then
        assertThatThrownBy(() -> authService.register(registerRequest))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("expired");
    }

    @Test
    void register_InvalidSignature_ThrowsException() {
        // Given
        when(ticketRepository.findById(testTicket.getId())).thenReturn(Optional.of(testTicket));
        when(ticketService.verifyTicketSignature(testTicket, "test-signature")).thenReturn(false);

        // When & Then
        assertThatThrownBy(() -> authService.register(registerRequest))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("Invalid ticket signature");
    }

    @Test
    void register_DuplicateUsername_ThrowsException() {
        // Given
        when(ticketRepository.findById(testTicket.getId())).thenReturn(Optional.of(testTicket));
        when(ticketService.verifyTicketSignature(testTicket, "test-signature")).thenReturn(true);
        when(userRepository.existsByUsername("newuser")).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> authService.register(registerRequest))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("Username already taken");
    }

    @Test
    void register_ParentHasActiveChild_ThrowsException() {
        // Given
        testUser.setActiveChildId(UUID.randomUUID());
        when(ticketRepository.findById(testTicket.getId())).thenReturn(Optional.of(testTicket));
        when(ticketService.verifyTicketSignature(testTicket, "test-signature")).thenReturn(true);
        when(userRepository.existsByUsername("newuser")).thenReturn(false);
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));

        // When & Then
        assertThatThrownBy(() -> authService.register(registerRequest))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("already has an active invitee");
    }

    @Test
    void login_Success() {
        // Given
        String username = "testuser";
        String password = "password123";

        when(userRepository.findByUsername(username)).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches(password, testUser.getPasswordHash())).thenReturn(true);
        when(jwtUtil.generateAccessToken(any(), any())).thenReturn("access-token");
        when(jwtUtil.generateRefreshToken(any())).thenReturn("refresh-token");

        // When
        AuthResponse response = authService.login(username, password);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getDisplayName()).isEqualTo("Test User");
        assertThat(response.getTokens().getAccessToken()).isEqualTo("access-token");
    }

    @Test
    void login_UserNotFound_ThrowsException() {
        // Given
        String username = "nonexistent";
        String password = "password123";

        when(userRepository.findByUsername(username)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> authService.login(username, password))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode()).isEqualTo("USER_NOT_FOUND"));
    }

    @Test
    void login_NoPasswordSet_ThrowsException() {
        // Given
        User userWithoutPassword = User.builder()
                .id(UUID.randomUUID())
                .chainKey("TEST00000002")
                .displayName("User Without Password")
                .username("nopassuser")
                .passwordHash(null)
                .build();

        when(userRepository.findByUsername("nopassuser")).thenReturn(Optional.of(userWithoutPassword));

        // When & Then
        assertThatThrownBy(() -> authService.login("nopassuser", "anypassword"))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode()).isEqualTo("NO_PASSWORD_SET"));
    }

    @Test
    void login_InvalidPassword_ThrowsException() {
        // Given
        String username = "testuser";
        String wrongPassword = "wrongpassword";

        when(userRepository.findByUsername(username)).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches(wrongPassword, testUser.getPasswordHash())).thenReturn(false);

        // When & Then
        assertThatThrownBy(() -> authService.login(username, wrongPassword))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode()).isEqualTo("INVALID_PASSWORD"));
    }

    @Test
    void refreshToken_Success() {
        // Given
        String refreshToken = "valid-refresh-token";

        when(jwtUtil.extractUserId(refreshToken)).thenReturn(testUser.getId());
        when(jwtUtil.validateRefreshToken(refreshToken, testUser.getId())).thenReturn(true);
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        when(jwtUtil.generateAccessToken(any(), any())).thenReturn("new-access-token");
        when(jwtUtil.generateRefreshToken(any())).thenReturn("new-refresh-token");

        // When
        AuthResponse response = authService.refreshToken(refreshToken);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getUserId()).isEqualTo(testUser.getId());
        assertThat(response.getChainKey()).isEqualTo("TEST00000001");
        assertThat(response.getTokens().getAccessToken()).isEqualTo("new-access-token");
        assertThat(response.getTokens().getRefreshToken()).isEqualTo("new-refresh-token");
    }

    @Test
    void refreshToken_InvalidToken_ThrowsException() {
        // Given
        String invalidToken = "invalid-refresh-token";
        UUID userId = UUID.randomUUID();

        when(jwtUtil.extractUserId(invalidToken)).thenReturn(userId);
        when(jwtUtil.validateRefreshToken(invalidToken, userId)).thenReturn(false);

        // When & Then
        assertThatThrownBy(() -> authService.refreshToken(invalidToken))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode()).isEqualTo("INVALID_TOKEN"));
    }

    @Test
    void refreshToken_UserNotFound_ThrowsException() {
        // Given
        String refreshToken = "valid-refresh-token";
        UUID userId = UUID.randomUUID();

        when(jwtUtil.extractUserId(refreshToken)).thenReturn(userId);
        when(jwtUtil.validateRefreshToken(refreshToken, userId)).thenReturn(true);
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> authService.refreshToken(refreshToken))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode()).isEqualTo("USER_NOT_FOUND"));
    }
}
