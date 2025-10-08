package com.thechain.controller;

import com.thechain.dto.UserProfileResponse;
import com.thechain.dto.UserChainResponse;
import com.thechain.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
     * Get current user profile
     * Frontend needs this to display user info after login
     */
    @GetMapping("/me")
    public ResponseEntity<UserProfileResponse> getCurrentUser(
            @RequestHeader("X-User-Id") UUID userId) {
        UserProfileResponse profile = userService.getUserProfile(userId);
        return ResponseEntity.ok(profile);
    }

    /**
     * Get users invited by current user (their chain/children)
     * Frontend uses this to display "My Chain" section
     */
    @GetMapping("/me/chain")
    public ResponseEntity<List<UserChainResponse>> getMyChain(
            @RequestHeader("X-User-Id") UUID userId) {
        List<UserChainResponse> chain = userService.getUserChain(userId);
        return ResponseEntity.ok(chain);
    }
}
