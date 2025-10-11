package com.thechain.controller;

import com.thechain.entity.User;
import com.thechain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/temp")
@RequiredArgsConstructor
public class TempPasswordController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/set-password")
    public Map<String, String> setPassword(@RequestParam String username, @RequestParam String password) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        String hash = passwordEncoder.encode(password);
        user.setPasswordHash(hash);
        userRepository.save(user);

        Map<String, String> response = new HashMap<>();
        response.put("message", "Password updated successfully");
        response.put("username", username);
        response.put("password", password);
        response.put("hash", hash);
        return response;
    }
}
