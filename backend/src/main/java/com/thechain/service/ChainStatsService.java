package com.thechain.service;

import com.thechain.dto.ChainStatsResponse;
import com.thechain.entity.Attachment;
import com.thechain.entity.Ticket;
import com.thechain.entity.User;
import com.thechain.repository.AttachmentRepository;
import com.thechain.repository.TicketRepository;
import com.thechain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChainStatsService {

    private final UserRepository userRepository;
    private final TicketRepository ticketRepository;
    private final AttachmentRepository attachmentRepository;

    public ChainStatsResponse getGlobalStats() {
        long totalUsers = userRepository.countByDeletedAtIsNull();
        long activeTickets = ticketRepository.countByStatus(Ticket.TicketStatus.ACTIVE);

        // Get recent attachments
        List<Attachment> recentAttachments = attachmentRepository.findTop20ByOrderByAttachedAtDesc();

        List<ChainStatsResponse.RecentAttachment> recentList = recentAttachments.stream()
                .map(attachment -> {
                    User child = userRepository.findById(attachment.getChildId()).orElse(null);
                    if (child == null) return null;

                    return ChainStatsResponse.RecentAttachment.builder()
                            .childPosition(child.getPosition())
                            .displayName(child.getDisplayName())
                            .timestamp(attachment.getAttachedAt())
                            .country(null)  // Location tracking removed
                            .build();
                })
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toList());

        return ChainStatsResponse.builder()
                .totalUsers(totalUsers)
                .activeTickets(activeTickets)
                .chainStartDate(Instant.now()) // TODO: Get actual first user creation date
                .averageGrowthRate(0.0) // TODO: Calculate
                .totalWastedTickets(0L) // TODO: Implement wasted tickets tracking
                .wasteRate(0.0)
                .countries(0) // TODO: Count distinct countries
                .lastUpdate(Instant.now())
                .recentAttachments(recentList)
                .build();
    }
}
