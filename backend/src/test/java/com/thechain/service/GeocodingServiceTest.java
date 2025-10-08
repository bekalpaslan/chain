package com.thechain.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.*;

class GeocodingServiceTest {

    private GeocodingService geocodingService;

    @BeforeEach
    void setUp() {
        geocodingService = new GeocodingService();
    }

    @Test
    void reverseGeocode_USCoordinates_ReturnsUS() {
        // Given - Coordinates in USA (New York)
        BigDecimal latitude = new BigDecimal("40.7128");
        BigDecimal longitude = new BigDecimal("-74.0060");

        // When
        GeocodingService.Location location = geocodingService.reverseGeocode(latitude, longitude);

        // Then
        assertThat(location).isNotNull();
        assertThat(location.city()).isEqualTo("Unknown City");
        assertThat(location.country()).isEqualTo("US");
    }

    @Test
    void reverseGeocode_EUCoordinates_ReturnsEU() {
        // Given - Coordinates in Europe (Berlin)
        BigDecimal latitude = new BigDecimal("52.5200");
        BigDecimal longitude = new BigDecimal("13.4050");

        // When
        GeocodingService.Location location = geocodingService.reverseGeocode(latitude, longitude);

        // Then
        assertThat(location).isNotNull();
        assertThat(location.city()).isEqualTo("Unknown City");
        assertThat(location.country()).isEqualTo("EU");
    }

    @Test
    void reverseGeocode_CanadaCoordinates_ReturnsCA() {
        // Given - Coordinates in Canada (Toronto)
        BigDecimal latitude = new BigDecimal("53.5461");
        BigDecimal longitude = new BigDecimal("-113.4938");

        // When
        GeocodingService.Location location = geocodingService.reverseGeocode(latitude, longitude);

        // Then
        assertThat(location).isNotNull();
        assertThat(location.city()).isEqualTo("Unknown City");
        assertThat(location.country()).isEqualTo("CA");
    }

    @Test
    void reverseGeocode_AustraliaCoordinates_ReturnsAU() {
        // Given - Coordinates in Australia (Sydney)
        BigDecimal latitude = new BigDecimal("-33.8688");
        BigDecimal longitude = new BigDecimal("151.2093");

        // When
        GeocodingService.Location location = geocodingService.reverseGeocode(latitude, longitude);

        // Then
        assertThat(location).isNotNull();
        assertThat(location.city()).isEqualTo("Unknown City");
        assertThat(location.country()).isEqualTo("AU");
    }

    @Test
    void reverseGeocode_UnknownCoordinates_ReturnsXX() {
        // Given - Coordinates in unknown region
        BigDecimal latitude = new BigDecimal("0.0");
        BigDecimal longitude = new BigDecimal("0.0");

        // When
        GeocodingService.Location location = geocodingService.reverseGeocode(latitude, longitude);

        // Then
        assertThat(location).isNotNull();
        assertThat(location.city()).isEqualTo("Unknown City");
        assertThat(location.country()).isEqualTo("XX");
    }
}
