package com.thechain.entity;

/**
 * Enum for user removal reasons
 * Currently only WASTED is supported (3 wasted tickets)
 */
public enum RemovalReason {
    /**
     * User wasted 3 tickets (3-strike rule)
     */
    WASTED
}
