package com.thechain.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordHashGenerator {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String password = "alpaslan";
        String hash = encoder.encode(password);
        System.out.println("BCrypt hash for 'alpaslan': " + hash);

        // Verify it works
        boolean matches = encoder.matches(password, hash);
        System.out.println("Verification test: " + matches);
    }
}
