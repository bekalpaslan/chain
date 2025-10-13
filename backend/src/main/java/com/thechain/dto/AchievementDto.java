package com.thechain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

/**
 * Achievement/Badge for gamification
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AchievementDto {

    /**
     * Unique achievement ID
     */
    private String id;

    /**
     * Achievement name
     */
    private String name;

    /**
     * Achievement description
     */
    private String description;

    /**
     * Icon/emoji for display
     */
    private String icon;

    /**
     * Rarity level (common, uncommon, rare, epic, legendary)
     */
    private String rarity;

    /**
     * When the achievement was earned (null if not yet earned)
     */
    private Instant earnedAt;

    /**
     * Progress towards earning (0.0 to 1.0)
     */
    private Double progress;

    /**
     * Target count for completion (if applicable)
     */
    private Integer targetCount;

    /**
     * Current count towards target (if applicable)
     */
    private Integer currentCount;
}
