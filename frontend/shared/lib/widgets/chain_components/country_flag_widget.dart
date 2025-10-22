import 'package:flutter/material.dart';

/// Widget to display country flags with opacity
/// Uses flagcdn.com for flag images
class CountryFlagWidget extends StatelessWidget {
  final String? countryCode;
  final double size;
  final double opacity;
  final bool showFallback;

  const CountryFlagWidget({
    super.key,
    this.countryCode,
    this.size = 24,
    this.opacity = 0.15,
    this.showFallback = true,
  });

  @override
  Widget build(BuildContext context) {
    if (countryCode == null || countryCode!.isEmpty) {
      return showFallback ? _buildFallback() : const SizedBox.shrink();
    }

    // Use flagcdn.com for flag images (free, no API key needed)
    final flagUrl = 'https://flagcdn.com/w80/${countryCode!.toLowerCase()}.png';

    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size * 0.7, // Most flags are rectangular
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Image.network(
            flagUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallback();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.white.withOpacity(0.05),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size * 0.7,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.flag_outlined,
          size: size * 0.5,
          color: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }
}

/// Extension to get country name from code
extension CountryCodeExtension on String {
  String get countryName {
    final countries = {
      'US': 'United States',
      'GB': 'United Kingdom',
      'DE': 'Germany',
      'FR': 'France',
      'JP': 'Japan',
      'BR': 'Brazil',
      'IN': 'India',
      'CN': 'China',
      'KR': 'South Korea',
      'AU': 'Australia',
      'CA': 'Canada',
      'MX': 'Mexico',
      'ES': 'Spain',
      'IT': 'Italy',
      'NL': 'Netherlands',
      'SE': 'Sweden',
      'NO': 'Norway',
      'FI': 'Finland',
      'DK': 'Denmark',
      'PL': 'Poland',
      'TR': 'Turkey',
      'RU': 'Russia',
      'AR': 'Argentina',
      'CL': 'Chile',
      'CO': 'Colombia',
      'ZA': 'South Africa',
      'EG': 'Egypt',
      'NG': 'Nigeria',
      'KE': 'Kenya',
      'MA': 'Morocco',
      'SA': 'Saudi Arabia',
      'AE': 'UAE',
      'IL': 'Israel',
      'SG': 'Singapore',
      'MY': 'Malaysia',
      'TH': 'Thailand',
      'ID': 'Indonesia',
      'PH': 'Philippines',
      'VN': 'Vietnam',
      'NZ': 'New Zealand',
      'IE': 'Ireland',
      'CH': 'Switzerland',
      'AT': 'Austria',
      'BE': 'Belgium',
      'PT': 'Portugal',
      'GR': 'Greece',
      'CZ': 'Czech Republic',
      'HU': 'Hungary',
      'RO': 'Romania',
      'UA': 'Ukraine',
    };

    return countries[toUpperCase()] ?? 'Unknown';
  }

  String get flagEmoji {
    // Convert country code to flag emoji using Unicode regional indicators
    if (length != 2) return '🏳️';

    final firstChar = codeUnitAt(0);
    final secondChar = codeUnitAt(1);

    // Regional indicator symbols start at 0x1F1E6 for 'A'
    final firstEmoji = String.fromCharCode(0x1F1E6 - 65 + firstChar);
    final secondEmoji = String.fromCharCode(0x1F1E6 - 65 + secondChar);

    return firstEmoji + secondEmoji;
  }
}