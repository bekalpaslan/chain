package com.thechain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

/**
 * Badge entity - predefined badges users can earn
 */
@Entity
@Table(name = "badges")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Badge {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true, length = 50, name = "badge_type")
    private String badgeType;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, length = 10)
    private String icon;

    @Column(columnDefinition = "TEXT")
    private String description;

    // Predefined badge types
    public static final String CHAIN_SAVIOR = "chain_savior";
    public static final String CHAIN_GUARDIAN = "chain_guardian";
    public static final String CHAIN_LEGEND = "chain_legend";
}
