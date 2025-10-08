package com.thechain.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
@Slf4j
public class GeocodingService {

    public record Location(String city, String country) {}

    public Location reverseGeocode(BigDecimal latitude, BigDecimal longitude) {
        // For MVP, return placeholder
        // In production, integrate with service like OpenStreetMap Nominatim or Google Geocoding API
        log.info("Reverse geocoding: {}, {}", latitude, longitude);

        // Simple mock logic based on lat/lon ranges
        String country = determineCountry(latitude.doubleValue(), longitude.doubleValue());

        return new Location("Unknown City", country);
    }

    private String determineCountry(double lat, double lon) {
        // Very basic country detection by coordinate ranges
        if (lat >= 24 && lat <= 49 && lon >= -125 && lon <= -66) {
            return "US";
        } else if (lat >= 36 && lat <= 71 && lon >= -10 && lon <= 40) {
            return "EU";
        } else if (lat >= 49 && lat <= 62 && lon >= -141 && lon <= -52) {
            return "CA";
        } else if (lat >= -44 && lat <= -10 && lon >= 113 && lon <= 154) {
            return "AU";
        }
        return "XX"; // Unknown
    }
}
