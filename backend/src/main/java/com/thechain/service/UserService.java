package com.thechain.service;

import com.thechain.config.CacheConfig;
import com.thechain.dto.UserChainResponse;
import com.thechain.dto.UserProfileResponse;
import com.thechain.entity.Invitation;
import com.thechain.entity.User;
import com.thechain.exception.BusinessException;
import com.thechain.repository.InvitationRepository;
import com.thechain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final InvitationRepository invitationRepository;

    /**
     * Get user profile by ID
     */
    @Cacheable(value = CacheConfig.USER_PROFILE_CACHE, key = "#userId")
    @Transactional(readOnly = true)
    public UserProfileResponse getUserProfile(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));

        return UserProfileResponse.builder()
                .userId(user.getId())
                .chainKey(user.getChainKey())
                .displayName(user.getDisplayName())
                .position(user.getPosition())
                .parentId(user.getParentId())
                .activeChildId(user.getActiveChildId())
                .status(user.getStatus())
                .wastedTicketsCount(user.getWastedTicketsCount())
                .createdAt(user.getCreatedAt())
                .build();
    }

    /**
     * Get list of users invited by the current user (their children)
     */
    @Transactional(readOnly = true)
    public List<UserChainResponse> getUserChain(UUID userId) {
        // Find all invitations where this user is the parent
        List<Invitation> invitations = invitationRepository.findAllByParentId(userId);

        return invitations.stream()
                .map(invitation -> {
                    // Get the child user
                    User child = userRepository.findById(invitation.getChildId())
                            .orElse(null);

                    if (child == null) {
                        log.warn("Child user {} not found for invitation {}",
                                invitation.getChildId(), invitation.getId());
                        return null;
                    }

                    return UserChainResponse.builder()
                            .userId(child.getId())
                            .chainKey(child.getChainKey())
                            .displayName(child.getDisplayName())
                            .position(child.getPosition())
                            .status(child.getStatus())
                            .joinedAt(invitation.getAcceptedAt())
                            .invitationStatus(invitation.getStatus().name())
                            .build();
                })
                .filter(response -> response != null)
                .collect(Collectors.toList());
    }
}
