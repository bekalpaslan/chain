package com.thechain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.Map;

/**
 * Activity feed item for the dashboard
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ActivityDto {

    /**
     * Unique activity ID
     */
    private String id;

    /**
     * Activity type (newMember, inviteExpired, chainGrowth, milestone, etc.)
     */
    private String type;

    /**
     * Activity title
     */
    private String title;

    /**
     * Activity description
     */
    private String description;

    /**
     * When the activity occurred
     */
    private Instant timestamp;

    /**
     * Related user ID (if applicable)
     */
    private String relatedUserId;

    /**
     * Related user name (if applicable)
     */
    private String relatedUserName;

    /**
     * Additional metadata for the activity
     */
    private Map<String, Object> metadata;
}
