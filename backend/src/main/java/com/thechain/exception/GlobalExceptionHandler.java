package com.thechain.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingRequestHeaderException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

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

    @ExceptionHandler(MissingRequestHeaderException.class)
    public ResponseEntity<Map<String, Object>> handleMissingRequestHeader(MissingRequestHeaderException ex) {
        log.error("Missing request header: {}", ex.getHeaderName());

        Map<String, Object> error = new HashMap<>();
        Map<String, Object> errorDetails = new HashMap<>();

        errorDetails.put("code", "MISSING_HEADER");
        errorDetails.put("message", "Required header '" + ex.getHeaderName() + "' is missing");
        errorDetails.put("timestamp", Instant.now().toString());
        errorDetails.put("requestId", UUID.randomUUID().toString());

        error.put("error", errorDetails);

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<Map<String, Object>> handleTypeMismatch(MethodArgumentTypeMismatchException ex) {
        log.error("Type mismatch for parameter: {}", ex.getName());

        Map<String, Object> error = new HashMap<>();
        Map<String, Object> errorDetails = new HashMap<>();

        errorDetails.put("code", "INVALID_PARAMETER");
        errorDetails.put("message", "Invalid value for parameter '" + ex.getName() + "'");
        errorDetails.put("timestamp", Instant.now().toString());
        errorDetails.put("requestId", UUID.randomUUID().toString());

        error.put("error", errorDetails);

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationException(MethodArgumentNotValidException ex) {
        log.error("Validation failed: {}", ex.getMessage());

        Map<String, Object> error = new HashMap<>();
        Map<String, Object> errorDetails = new HashMap<>();

        errorDetails.put("code", "VALIDATION_ERROR");
        errorDetails.put("message", "Invalid request data");
        errorDetails.put("timestamp", Instant.now().toString());
        errorDetails.put("requestId", UUID.randomUUID().toString());

        error.put("error", errorDetails);

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<Map<String, Object>> handleMethodNotSupported(HttpRequestMethodNotSupportedException ex) {
        log.error("Method not supported: {}", ex.getMethod());

        Map<String, Object> error = new HashMap<>();
        Map<String, Object> errorDetails = new HashMap<>();

        errorDetails.put("code", "METHOD_NOT_ALLOWED");
        errorDetails.put("message", "HTTP method '" + ex.getMethod() + "' is not supported for this endpoint");
        errorDetails.put("timestamp", Instant.now().toString());
        errorDetails.put("requestId", UUID.randomUUID().toString());

        error.put("error", errorDetails);

        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED).body(error);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, Object>> handleIllegalArgument(IllegalArgumentException ex) {
        log.error("Illegal argument: {}", ex.getMessage());

        Map<String, Object> error = new HashMap<>();
        Map<String, Object> errorDetails = new HashMap<>();

        errorDetails.put("code", "INVALID_REQUEST");
        errorDetails.put("message", ex.getMessage());
        errorDetails.put("timestamp", Instant.now().toString());
        errorDetails.put("requestId", UUID.randomUUID().toString());

        error.put("error", errorDetails);

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
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
