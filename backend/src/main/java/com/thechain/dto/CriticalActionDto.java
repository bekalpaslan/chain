package com.thechain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Critical action requiring user attention
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CriticalActionDto {

    /**
     * Action type (ticketExpiring, ticketExpired, becameTip, chainBroken, etc.)
     */
    private String type;

    /**
     * Action title
     */
    private String title;

    /**
     * Detailed description
     */
    private String description;

    /**
     * Time remaining in seconds (null if not applicable)
     */
    private Long timeRemainingSeconds;

    /**
     * Icon name for UI rendering
     */
    private String icon;

    /**
     * Color code for UI rendering
     */
    private String color;
}
