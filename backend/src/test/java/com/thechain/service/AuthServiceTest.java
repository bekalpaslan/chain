package com.thechain.service;

import com.thechain.dto.AuthResponse;
import com.thechain.dto.RegisterRequest;
import com.thechain.entity.Ticket;
import com.thechain.entity.User;
import com.thechain.exception.BusinessException;
import com.thechain.repository.AttachmentRepository;
import com.thechain.repository.TicketRepository;
import com.thechain.repository.UserRepository;
import com.thechain.security.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
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
    private GeocodingService geocodingService;

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
                .deviceId("test-device")
                .deviceFingerprint("test-fingerprint")
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
        registerRequest.setDisplayName("New User");
        registerRequest.setDeviceId("new-device");
        registerRequest.setDeviceFingerprint("new-fingerprint");
        registerRequest.setShareLocation(false);
    }

    @Test
    void register_Success() {
        // Given
        when(ticketRepository.findById(testTicket.getId())).thenReturn(Optional.of(testTicket));
        when(ticketService.verifyTicketSignature(testTicket, "test-signature")).thenReturn(true);
        when(userRepository.existsByDeviceFingerprint("new-fingerprint")).thenReturn(false);
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        when(userRepository.findMaxPosition()).thenReturn(1);

        User newUser = User.builder()
                .id(UUID.randomUUID())
                .chainKey("TEST00000002")
                .displayName("New User")
                .position(2)
                .parentId(testUser.getId())
                .deviceId("new-device")
                .deviceFingerprint("new-fingerprint")
                .build();

        when(userRepository.save(any(User.class))).thenReturn(newUser);
        when(jwtUtil.generateAccessToken(any(), any(), any())).thenReturn("access-token");
        when(jwtUtil.generateRefreshToken(any(), any())).thenReturn("refresh-token");

        // When
        AuthResponse response = authService.register(registerRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getDisplayName()).isEqualTo("New User");
        assertThat(response.getPosition()).isEqualTo(2);
        assertThat(response.getParentId()).isEqualTo(testUser.getId());
        assertThat(response.getTokens().getAccessToken()).isEqualTo("access-token");

        verify(ticketRepository).save(any(Ticket.class));
        verify(userRepository, times(2)).save(any(User.class));
        verify(attachmentRepository).save(any());
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
    void register_DuplicateDevice_ThrowsException() {
        // Given
        when(ticketRepository.findById(testTicket.getId())).thenReturn(Optional.of(testTicket));
        when(ticketService.verifyTicketSignature(testTicket, "test-signature")).thenReturn(true);
        when(userRepository.existsByDeviceFingerprint("new-fingerprint")).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> authService.register(registerRequest))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("Device already registered");
    }

    @Test
    void register_ParentHasChild_ThrowsException() {
        // Given
        testUser.setChildId(UUID.randomUUID());
        when(ticketRepository.findById(testTicket.getId())).thenReturn(Optional.of(testTicket));
        when(ticketService.verifyTicketSignature(testTicket, "test-signature")).thenReturn(true);
        when(userRepository.existsByDeviceFingerprint("new-fingerprint")).thenReturn(false);
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));

        // When & Then
        assertThatThrownBy(() -> authService.register(registerRequest))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("already has a child");
    }

    @Test
    void register_WithLocation_Success() {
        // Given
        registerRequest.setShareLocation(true);
        registerRequest.setLatitude(new BigDecimal("52.5200"));
        registerRequest.setLongitude(new BigDecimal("13.4050"));

        when(ticketRepository.findById(testTicket.getId())).thenReturn(Optional.of(testTicket));
        when(ticketService.verifyTicketSignature(testTicket, "test-signature")).thenReturn(true);
        when(userRepository.existsByDeviceFingerprint("new-fingerprint")).thenReturn(false);
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        when(userRepository.findMaxPosition()).thenReturn(1);
        when(geocodingService.reverseGeocode(any(), any()))
                .thenReturn(new GeocodingService.Location("Berlin", "DE"));

        User newUser = User.builder()
                .id(UUID.randomUUID())
                .chainKey("TEST00000002")
                .displayName("New User")
                .position(2)
                .parentId(testUser.getId())
                .deviceId("new-device")
                .deviceFingerprint("new-fingerprint")
                .build();

        when(userRepository.save(any(User.class))).thenReturn(newUser);
        when(jwtUtil.generateAccessToken(any(), any(), any())).thenReturn("access-token");
        when(jwtUtil.generateRefreshToken(any(), any())).thenReturn("refresh-token");

        // When
        AuthResponse response = authService.register(registerRequest);

        // Then
        assertThat(response).isNotNull();
        verify(geocodingService).reverseGeocode(any(), any());
    }

    @Test
    void login_Success() {
        // Given
        String deviceId = "test-device";
        String deviceFingerprint = "test-fingerprint";

        when(userRepository.findByDeviceId(deviceId)).thenReturn(Optional.of(testUser));
        when(jwtUtil.generateAccessToken(any(), any(), any())).thenReturn("access-token");
        when(jwtUtil.generateRefreshToken(any(), any())).thenReturn("refresh-token");

        // When
        AuthResponse response = authService.login(deviceId, deviceFingerprint);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getDisplayName()).isEqualTo("Test User");
        assertThat(response.getTokens().getAccessToken()).isEqualTo("access-token");
    }

    @Test
    void login_UserNotFound_ThrowsException() {
        // Given
        String deviceId = "unknown-device";
        String deviceFingerprint = "test-fingerprint";

        when(userRepository.findByDeviceId(deviceId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> authService.login(deviceId, deviceFingerprint))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("not found");
    }

    @Test
    void login_FingerprintMismatch_ThrowsException() {
        // Given
        String deviceId = "test-device";
        String wrongFingerprint = "wrong-fingerprint";

        when(userRepository.findByDeviceId(deviceId)).thenReturn(Optional.of(testUser));

        // When & Then
        assertThatThrownBy(() -> authService.login(deviceId, wrongFingerprint))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("verification failed");
    }
}
