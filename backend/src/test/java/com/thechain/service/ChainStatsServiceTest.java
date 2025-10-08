package com.thechain.service;

import com.thechain.dto.ChainStatsResponse;
import com.thechain.entity.Attachment;
import com.thechain.entity.Ticket;
import com.thechain.entity.User;
import com.thechain.repository.AttachmentRepository;
import com.thechain.repository.TicketRepository;
import com.thechain.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ChainStatsServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private TicketRepository ticketRepository;

    @Mock
    private AttachmentRepository attachmentRepository;

    @InjectMocks
    private ChainStatsService chainStatsService;

    private List<User> testUsers;
    private List<Attachment> testAttachments;

    @BeforeEach
    void setUp() {
        // Create test users
        User user1 = User.builder()
                .id(UUID.randomUUID())
                .chainKey("TEST00000001")
                .displayName("User 1")
                .position(1)
                .locationCountry("US")
                .build();

        User user2 = User.builder()
                .id(UUID.randomUUID())
                .chainKey("TEST00000002")
                .displayName("User 2")
                .position(2)
                .locationCountry("DE")
                .build();

        User user3 = User.builder()
                .id(UUID.randomUUID())
                .chainKey("TEST00000003")
                .displayName("User 3")
                .position(3)
                .locationCountry("GB")
                .build();

        testUsers = Arrays.asList(user1, user2, user3);

        // Create test attachments
        Attachment attachment1 = Attachment.builder()
                .id(UUID.randomUUID())
                .parentId(user1.getId())
                .childId(user2.getId())
                .attachedAt(Instant.now().minusSeconds(3600))
                .build();

        Attachment attachment2 = Attachment.builder()
                .id(UUID.randomUUID())
                .parentId(user2.getId())
                .childId(user3.getId())
                .attachedAt(Instant.now().minusSeconds(1800))
                .build();

        testAttachments = Arrays.asList(attachment1, attachment2);
    }

    @Test
    void getGlobalStats_ReturnsCorrectUserCount() {
        // Given
        when(userRepository.countByDeletedAtIsNull()).thenReturn(100L);
        when(ticketRepository.countByStatus(Ticket.TicketStatus.ACTIVE)).thenReturn(15L);
        when(attachmentRepository.findTop20ByOrderByAttachedAtDesc()).thenReturn(testAttachments);
        when(userRepository.findById(any())).thenReturn(Optional.of(testUsers.get(0)));

        // When
        ChainStatsResponse response = chainStatsService.getGlobalStats();

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getTotalUsers()).isEqualTo(100L);
    }

    @Test
    void getGlobalStats_ReturnsCorrectActiveTickets() {
        // Given
        when(userRepository.countByDeletedAtIsNull()).thenReturn(50L);
        when(ticketRepository.countByStatus(Ticket.TicketStatus.ACTIVE)).thenReturn(25L);
        when(attachmentRepository.findTop20ByOrderByAttachedAtDesc()).thenReturn(testAttachments);
        when(userRepository.findById(any())).thenReturn(Optional.of(testUsers.get(0)));

        // When
        ChainStatsResponse response = chainStatsService.getGlobalStats();

        // Then
        assertThat(response.getActiveTickets()).isEqualTo(25L);
    }

    @Test
    void getGlobalStats_ReturnsRecentAttachments() {
        // Given
        when(userRepository.countByDeletedAtIsNull()).thenReturn(50L);
        when(ticketRepository.countByStatus(Ticket.TicketStatus.ACTIVE)).thenReturn(10L);
        when(attachmentRepository.findTop20ByOrderByAttachedAtDesc()).thenReturn(testAttachments);

        // Mock user lookups for each attachment
        when(userRepository.findById(testAttachments.get(0).getChildId()))
                .thenReturn(Optional.of(testUsers.get(1)));
        when(userRepository.findById(testAttachments.get(1).getChildId()))
                .thenReturn(Optional.of(testUsers.get(2)));

        // When
        ChainStatsResponse response = chainStatsService.getGlobalStats();

        // Then
        assertThat(response.getRecentAttachments()).isNotNull();
        assertThat(response.getRecentAttachments()).hasSize(2);

        ChainStatsResponse.RecentAttachment first = response.getRecentAttachments().get(0);
        assertThat(first.getDisplayName()).isEqualTo("User 2");
        assertThat(first.getChildPosition()).isEqualTo(2);
        assertThat(first.getCountry()).isEqualTo("DE");
    }

    @Test
    void getGlobalStats_HandlesNullUsers() {
        // Given
        when(userRepository.countByDeletedAtIsNull()).thenReturn(50L);
        when(ticketRepository.countByStatus(Ticket.TicketStatus.ACTIVE)).thenReturn(10L);
        when(attachmentRepository.findTop20ByOrderByAttachedAtDesc()).thenReturn(testAttachments);
        when(userRepository.findById(any())).thenReturn(Optional.empty());

        // When
        ChainStatsResponse response = chainStatsService.getGlobalStats();

        // Then
        assertThat(response.getRecentAttachments()).isEmpty();
    }

    @Test
    void getGlobalStats_HandlesEmptyAttachments() {
        // Given
        when(userRepository.countByDeletedAtIsNull()).thenReturn(10L);
        when(ticketRepository.countByStatus(Ticket.TicketStatus.ACTIVE)).thenReturn(5L);
        when(attachmentRepository.findTop20ByOrderByAttachedAtDesc()).thenReturn(List.of());

        // When
        ChainStatsResponse response = chainStatsService.getGlobalStats();

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getTotalUsers()).isEqualTo(10L);
        assertThat(response.getActiveTickets()).isEqualTo(5L);
        assertThat(response.getRecentAttachments()).isEmpty();
    }

    @Test
    void getGlobalStats_SetsLastUpdateTime() {
        // Given
        Instant beforeCall = Instant.now();
        when(userRepository.countByDeletedAtIsNull()).thenReturn(10L);
        when(ticketRepository.countByStatus(Ticket.TicketStatus.ACTIVE)).thenReturn(5L);
        when(attachmentRepository.findTop20ByOrderByAttachedAtDesc()).thenReturn(List.of());

        // When
        ChainStatsResponse response = chainStatsService.getGlobalStats();
        Instant afterCall = Instant.now();

        // Then
        assertThat(response.getLastUpdate()).isBetween(beforeCall, afterCall);
    }

    @Test
    void getGlobalStats_CallsRepositoriesCorrectly() {
        // Given
        when(userRepository.countByDeletedAtIsNull()).thenReturn(10L);
        when(ticketRepository.countByStatus(Ticket.TicketStatus.ACTIVE)).thenReturn(5L);
        when(attachmentRepository.findTop20ByOrderByAttachedAtDesc()).thenReturn(List.of());

        // When
        chainStatsService.getGlobalStats();

        // Then
        verify(userRepository).countByDeletedAtIsNull();
        verify(ticketRepository).countByStatus(Ticket.TicketStatus.ACTIVE);
        verify(attachmentRepository).findTop20ByOrderByAttachedAtDesc();
    }
}
