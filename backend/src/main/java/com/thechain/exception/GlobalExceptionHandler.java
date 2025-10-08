package com.thechain.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<Map<String, Object>> handleBusinessException(BusinessException ex) {
        log.error("Business exception: {} - {}", ex.getErrorCode(), ex.getMessage());

        Map<String, Object> error = new HashMap<>();
        Map<String, Object> errorDetails = new HashMap<>();

        errorDetails.put("code", ex.getErrorCode());
        errorDetails.put("message", ex.getMessage());
        errorDetails.put("timestamp", Instant.now().toString());
        errorDetails.put("requestId", UUID.randomUUID().toString());

        error.put("error", errorDetails);

        HttpStatus status = determineStatus(ex.getErrorCode());
        return ResponseEntity.status(status).body(error);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGenericException(Exception ex) {
        log.error("Unexpected exception", ex);

        Map<String, Object> error = new HashMap<>();
        Map<String, Object> errorDetails = new HashMap<>();

        errorDetails.put("code", "INTERNAL_ERROR");
        errorDetails.put("message", "An unexpected error occurred");
        errorDetails.put("timestamp", Instant.now().toString());
        errorDetails.put("requestId", UUID.randomUUID().toString());

        error.put("error", errorDetails);

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }

    private HttpStatus determineStatus(String errorCode) {
        return switch (errorCode) {
            case "INVALID_TICKET", "TICKET_EXPIRED", "TICKET_USED", "INVALID_SIGNATURE" -> HttpStatus.BAD_REQUEST;
            case "DUPLICATE_USER" -> HttpStatus.CONFLICT;
            case "USER_NOT_FOUND", "TICKET_NOT_FOUND", "PARENT_NOT_FOUND" -> HttpStatus.NOT_FOUND;
            case "ALREADY_HAS_CHILD", "ACTIVE_TICKET_EXISTS", "PARENT_HAS_CHILD" -> HttpStatus.CONFLICT;
            default -> HttpStatus.BAD_REQUEST;
        };
    }
}
