package com.thechain.exception;

import com.thechain.dto.ErrorResponse;
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
import java.util.UUID;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessException(BusinessException ex) {
        log.error("Business exception: {} - {}", ex.getErrorCode(), ex.getMessage());

        ErrorResponse.ErrorDetails errorDetails = ErrorResponse.ErrorDetails.builder()
            .code(ex.getErrorCode())
            .message(ex.getMessage())
            .timestamp(Instant.now().toString())
            .requestId(UUID.randomUUID().toString())
            .build();

        ErrorResponse errorResponse = ErrorResponse.builder()
            .error(errorDetails)
            .build();

        HttpStatus status = determineStatus(ex.getErrorCode());
        return ResponseEntity.status(status).body(errorResponse);
    }

    @ExceptionHandler(MissingRequestHeaderException.class)
    public ResponseEntity<ErrorResponse> handleMissingRequestHeader(MissingRequestHeaderException ex) {
        log.error("Missing request header: {}", ex.getHeaderName());

        ErrorResponse.ErrorDetails errorDetails = ErrorResponse.ErrorDetails.builder()
            .code("MISSING_HEADER")
            .message("Required header '" + ex.getHeaderName() + "' is missing")
            .timestamp(Instant.now().toString())
            .requestId(UUID.randomUUID().toString())
            .build();

        ErrorResponse errorResponse = ErrorResponse.builder()
            .error(errorDetails)
            .build();

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ErrorResponse> handleTypeMismatch(MethodArgumentTypeMismatchException ex) {
        log.error("Type mismatch for parameter: {}", ex.getName());

        ErrorResponse.ErrorDetails errorDetails = ErrorResponse.ErrorDetails.builder()
            .code("INVALID_PARAMETER")
            .message("Invalid value for parameter '" + ex.getName() + "'")
            .timestamp(Instant.now().toString())
            .requestId(UUID.randomUUID().toString())
            .build();

        ErrorResponse errorResponse = ErrorResponse.builder()
            .error(errorDetails)
            .build();

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(MethodArgumentNotValidException ex) {
        log.error("Validation failed: {}", ex.getMessage());

        ErrorResponse.ErrorDetails errorDetails = ErrorResponse.ErrorDetails.builder()
            .code("VALIDATION_ERROR")
            .message("Invalid request data")
            .timestamp(Instant.now().toString())
            .requestId(UUID.randomUUID().toString())
            .build();

        ErrorResponse errorResponse = ErrorResponse.builder()
            .error(errorDetails)
            .build();

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ErrorResponse> handleMethodNotSupported(HttpRequestMethodNotSupportedException ex) {
        log.error("Method not supported: {}", ex.getMethod());

        ErrorResponse.ErrorDetails errorDetails = ErrorResponse.ErrorDetails.builder()
            .code("METHOD_NOT_ALLOWED")
            .message("HTTP method '" + ex.getMethod() + "' is not supported for this endpoint")
            .timestamp(Instant.now().toString())
            .requestId(UUID.randomUUID().toString())
            .build();

        ErrorResponse errorResponse = ErrorResponse.builder()
            .error(errorDetails)
            .build();

        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED).body(errorResponse);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgument(IllegalArgumentException ex) {
        log.error("Illegal argument: {}", ex.getMessage());

        ErrorResponse.ErrorDetails errorDetails = ErrorResponse.ErrorDetails.builder()
            .code("INVALID_REQUEST")
            .message(ex.getMessage())
            .timestamp(Instant.now().toString())
            .requestId(UUID.randomUUID().toString())
            .build();

        ErrorResponse errorResponse = ErrorResponse.builder()
            .error(errorDetails)
            .build();

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
        log.error("Unexpected exception", ex);

        ErrorResponse.ErrorDetails errorDetails = ErrorResponse.ErrorDetails.builder()
            .code("INTERNAL_ERROR")
            .message("An unexpected error occurred")
            .timestamp(Instant.now().toString())
            .requestId(UUID.randomUUID().toString())
            .build();

        ErrorResponse errorResponse = ErrorResponse.builder()
            .error(errorDetails)
            .build();

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
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
