package com.thechain.fixtures;

import com.thechain.entity.Ticket;
import com.thechain.entity.User;
import org.apache.commons.lang3.RandomStringUtils;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

/**
 * Test data builder following the Builder pattern for creating test entities.
 * Provides fluent API for creating User and Ticket entities with sensible defaults.
 *
 * Usage:
 * <pre>
 * User user = TestDataBuilder.user().withUsername("testuser").build();
 * Ticket ticket = TestDataBuilder.ticket().withOwnerId(user.getId()).expired().build();
 * </pre>
 */
public class TestDataBuilder {

    /**
     * Builder for creating User test data with fluent API
     */
    public static class UserBuilder {
        private UUID id = UUID.randomUUID();
        private String chainKey = "CHAIN" + RandomStringUtils.randomAlphanumeric(8).toUpperCase();
        private String username = "user_" + RandomStringUtils.randomAlphanumeric(6);
        private String passwordHash = "$2a$10$testHashPlaceholder";
        private String displayName = "Test User";
        private Integer position = 100;
        private UUID parentId = UUID.fromString("a0000000-0000-0000-0000-000000000001");
        private UUID activeChildId = null;
        private Instant createdAt = Instant.now();
        private Instant updatedAt = Instant.now();

        public UserBuilder withId(UUID id) {
            this.id = id;
            return this;
        }

        public UserBuilder withChainKey(String chainKey) {
            this.chainKey = chainKey;
            return this;
        }

        public UserBuilder withUsername(String username) {
            this.username = username;
            return this;
        }

        public UserBuilder withPasswordHash(String passwordHash) {
            this.passwordHash = passwordHash;
            return this;
        }

        public UserBuilder withDisplayName(String displayName) {
            this.displayName = displayName;
            return this;
        }

        public UserBuilder withPosition(Integer position) {
            this.position = position;
            return this;
        }

        public UserBuilder withParentId(UUID parentId) {
            this.parentId = parentId;
            return this;
        }

        public UserBuilder withActiveChildId(UUID activeChildId) {
            this.activeChildId = activeChildId;
            return this;
        }

        public UserBuilder withCreatedAt(Instant createdAt) {
            this.createdAt = createdAt;
            return this;
        }

        /**
         * Configures this user as the seed user with predefined values
         */
        public UserBuilder asSeedUser() {
            this.id = UUID.fromString("a0000000-0000-0000-0000-000000000001");
            this.chainKey = "SEED00000001";
            this.username = "seed";
            this.displayName = "Seed User";
            this.position = 0;
            this.parentId = null;
            this.activeChildId = null;
            return this;
        }

        /**
         * Configures this user as a child of the seed user
         */
        public UserBuilder asChildOfSeed() {
            this.parentId = UUID.fromString("a0000000-0000-0000-0000-000000000001");
            this.position = 1;
            return this;
        }

        /**
         * Configures this user with an active child (has generated a ticket)
         */
        public UserBuilder withActiveChild() {
            this.activeChildId = UUID.randomUUID();
            return this;
        }

        public User build() {
            return User.builder()
                    .id(id)
                    .chainKey(chainKey)
                    .username(username)
                    .passwordHash(passwordHash)
                    .displayName(displayName)
                    .position(position)
                    .parentId(parentId)
                    .activeChildId(activeChildId)
                    .createdAt(createdAt)
                    .updatedAt(updatedAt)
                    .build();
        }
    }

    /**
     * Builder for creating Ticket test data with fluent API
     */
    public static class TicketBuilder {
        private UUID id = UUID.randomUUID();
        private UUID ownerId;
        private Ticket.TicketStatus status = Ticket.TicketStatus.ACTIVE;
        private String payload = "payload_" + RandomStringUtils.randomAlphanumeric(16);
        private String signature = "sig_" + RandomStringUtils.randomAlphanumeric(32);
        private Instant issuedAt = Instant.now();
        private Instant expiresAt = Instant.now().plus(24, ChronoUnit.HOURS);
        private Instant usedAt = null;
        private UUID claimedBy = null;

        public TicketBuilder withId(UUID id) {
            this.id = id;
            return this;
        }

        public TicketBuilder withOwnerId(UUID ownerId) {
            this.ownerId = ownerId;
            return this;
        }

        public TicketBuilder withStatus(Ticket.TicketStatus status) {
            this.status = status;
            return this;
        }

        public TicketBuilder withPayload(String payload) {
            this.payload = payload;
            return this;
        }

        public TicketBuilder withSignature(String signature) {
            this.signature = signature;
            return this;
        }

        public TicketBuilder withIssuedAt(Instant issuedAt) {
            this.issuedAt = issuedAt;
            return this;
        }

        public TicketBuilder withExpiresAt(Instant expiresAt) {
            this.expiresAt = expiresAt;
            return this;
        }

        /**
         * Configures this ticket as expired (expires in the past)
         */
        public TicketBuilder expired() {
            this.expiresAt = Instant.now().minus(1, ChronoUnit.HOURS);
            this.status = Ticket.TicketStatus.EXPIRED;
            return this;
        }

        /**
         * Configures this ticket as used by a specific user
         */
        public TicketBuilder usedBy(UUID userId) {
            this.status = Ticket.TicketStatus.USED;
            this.usedAt = Instant.now();
            this.claimedBy = userId;
            return this;
        }

        /**
         * Configures this ticket as expiring soon (in 30 minutes)
         */
        public TicketBuilder expiringSoon() {
            this.expiresAt = Instant.now().plus(30, ChronoUnit.MINUTES);
            return this;
        }

        /**
         * Configures this ticket with a specific time remaining
         */
        public TicketBuilder expiresIn(long amount, ChronoUnit unit) {
            this.expiresAt = Instant.now().plus(amount, unit);
            return this;
        }

        public Ticket build() {
            return Ticket.builder()
                    .id(id)
                    .ownerId(ownerId)
                    .status(status)
                    .payload(payload)
                    .signature(signature)
                    .issuedAt(issuedAt)
                    .expiresAt(expiresAt)
                    .usedAt(usedAt)
                    .claimedBy(claimedBy)
                    .build();
        }
    }

    /**
     * Creates a new UserBuilder with default values
     */
    public static UserBuilder user() {
        return new UserBuilder();
    }

    /**
     * Creates a new TicketBuilder with default values
     */
    public static TicketBuilder ticket() {
        return new TicketBuilder();
    }

    /**
     * Creates a seed user with predefined ID and chain key
     */
    public static User seedUser() {
        return user().asSeedUser().build();
    }

    /**
     * Creates a standard test user with default values
     */
    public static User defaultUser() {
        return user().build();
    }

    /**
     * Creates an active ticket with default values for a given owner
     */
    public static Ticket activeTicket(UUID ownerId) {
        return ticket().withOwnerId(ownerId).build();
    }

    /**
     * Creates an expired ticket for a given owner
     */
    public static Ticket expiredTicket(UUID ownerId) {
        return ticket().withOwnerId(ownerId).expired().build();
    }
}
