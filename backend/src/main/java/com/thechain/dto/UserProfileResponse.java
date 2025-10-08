package com.thechain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {
    private UUID userId;
    private String chainKey;
    private String displayName;
    private Integer position;
    private UUID parentId;
    private UUID activeChildId;
    private String status;
    private Integer wastedTicketsCount;
    private Instant createdAt;
}
