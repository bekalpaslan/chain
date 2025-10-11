package com.thechain.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordHashGenerator {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String password = "Welcome123!";
        String hash = encoder.encode(password);
        System.out.println("=== PASSWORD HASH GENERATOR ===");
        System.out.println("Password: " + password);
        System.out.println("BCrypt Hash: " + hash);
        System.out.println("Hash Length: " + hash.length());

        // Verify it works
        boolean matches = encoder.matches(password, hash);
        System.out.println("Verification: " + (matches ? "SUCCESS" : "FAILED"));
        System.out.println("=============================");
    }
}
