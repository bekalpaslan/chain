-- V7: Randomize user countries for visual diversity
-- Description: Assigns random countries to existing users for better visualization

-- Create a temporary table with country codes and names
CREATE TEMP TABLE country_list (
    code VARCHAR(2),
    name VARCHAR(100)
);

-- Insert diverse set of countries with ISO codes
INSERT INTO country_list (code, name) VALUES
    ('US', 'United States'),
    ('GB', 'United Kingdom'),
    ('DE', 'Germany'),
    ('FR', 'France'),
    ('JP', 'Japan'),
    ('BR', 'Brazil'),
    ('IN', 'India'),
    ('CN', 'China'),
    ('KR', 'South Korea'),
    ('AU', 'Australia'),
    ('CA', 'Canada'),
    ('MX', 'Mexico'),
    ('ES', 'Spain'),
    ('IT', 'Italy'),
    ('NL', 'Netherlands'),
    ('SE', 'Sweden'),
    ('NO', 'Norway'),
    ('FI', 'Finland'),
    ('DK', 'Denmark'),
    ('PL', 'Poland'),
    ('TR', 'Turkey'),
    ('RU', 'Russia'),
    ('AR', 'Argentina'),
    ('CL', 'Chile'),
    ('CO', 'Colombia'),
    ('ZA', 'South Africa'),
    ('EG', 'Egypt'),
    ('NG', 'Nigeria'),
    ('KE', 'Kenya'),
    ('MA', 'Morocco'),
    ('SA', 'Saudi Arabia'),
    ('AE', 'United Arab Emirates'),
    ('IL', 'Israel'),
    ('SG', 'Singapore'),
    ('MY', 'Malaysia'),
    ('TH', 'Thailand'),
    ('ID', 'Indonesia'),
    ('PH', 'Philippines'),
    ('VN', 'Vietnam'),
    ('NZ', 'New Zealand'),
    ('IE', 'Ireland'),
    ('CH', 'Switzerland'),
    ('AT', 'Austria'),
    ('BE', 'Belgium'),
    ('PT', 'Portugal'),
    ('GR', 'Greece'),
    ('CZ', 'Czech Republic'),
    ('HU', 'Hungary'),
    ('RO', 'Romania'),
    ('UA', 'Ukraine');

-- Update users with random countries
-- Use position as seed for consistent randomization
UPDATE users
SET belongs_to = (
    SELECT code
    FROM country_list
    ORDER BY random()
    LIMIT 1
)
WHERE belongs_to IS NULL OR belongs_to = 'US';

-- Give seed user a special country (let's make them from Japan as tech hub)
UPDATE users
SET belongs_to = 'JP'
WHERE position = 1;

-- Ensure some geographic diversity by assigning specific regions to certain position ranges
UPDATE users SET belongs_to = (SELECT code FROM country_list WHERE code IN ('US', 'CA', 'MX', 'BR', 'AR') ORDER BY random() LIMIT 1) WHERE position BETWEEN 2 AND 10;
UPDATE users SET belongs_to = (SELECT code FROM country_list WHERE code IN ('GB', 'DE', 'FR', 'ES', 'IT', 'NL') ORDER BY random() LIMIT 1) WHERE position BETWEEN 11 AND 20;
UPDATE users SET belongs_to = (SELECT code FROM country_list WHERE code IN ('JP', 'KR', 'CN', 'SG', 'IN', 'TH') ORDER BY random() LIMIT 1) WHERE position BETWEEN 21 AND 30;
UPDATE users SET belongs_to = (SELECT code FROM country_list WHERE code IN ('AU', 'NZ', 'ID', 'PH', 'MY', 'VN') ORDER BY random() LIMIT 1) WHERE position BETWEEN 31 AND 40;
UPDATE users SET belongs_to = (SELECT code FROM country_list WHERE code IN ('ZA', 'EG', 'NG', 'KE', 'MA', 'AE') ORDER BY random() LIMIT 1) WHERE position BETWEEN 41 AND 50;

-- Log the update
DO $$
BEGIN
    RAISE NOTICE '✓ User countries randomized for better visualization';
    RAISE NOTICE '✓ Seed user (position 1) set to JP';
    RAISE NOTICE '✓ Geographic diversity ensured across positions';
END $$;

-- Clean up
DROP TABLE country_list;