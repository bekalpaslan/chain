package com.thechain.controller;

import com.thechain.dto.ChainStatsResponse;
import com.thechain.service.ChainStatsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/chain")
@RequiredArgsConstructor
public class ChainController {

    private final ChainStatsService chainStatsService;

    @GetMapping("/stats")
    public ResponseEntity<ChainStatsResponse> getStats() {
        ChainStatsResponse response = chainStatsService.getGlobalStats();
        return ResponseEntity.ok(response);
    }
}
