import 'package:flutter/material.dart';
import 'person_card.dart';
import 'tip_person_card.dart';
import 'blurred_person_card.dart';

/// Showcase widget that displays all person card types for design reference
/// This helps visualize how different card types look together
class PersonCardShowcase extends StatelessWidget {
  const PersonCardShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F), // Deep Void
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text(
          'Person Card Design System',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Core Card Types'),
            const SizedBox(height: 16),

            // 1. Genesis Card
            _buildCardWithLabel(
              label: '🌱 Genesis (Position #1)',
              description: 'The original member who started The Chain',
              card: _buildGenesisCard(),
            ),

            // 2. Active Member Card
            _buildCardWithLabel(
              label: '✅ Active Member',
              description: 'Standard members in the chain',
              card: const PersonCard(
                displayName: 'Michael Chen',
                chainKey: 'CHAIN0000045',
                position: 36,
                status: 'active',
              ),
            ),

            // 3. Current User Card
            _buildCardWithLabel(
              label: '⭐ Current User (YOU)',
              description: 'Your position in the chain',
              card: const PersonCard(
                displayName: 'Alex Thompson',
                chainKey: 'CHAIN0000037',
                position: 37,
                isCurrentUser: true,
                status: 'active',
              ),
            ),

            // 4. TIP Card
            _buildCardWithLabel(
              label: '⚡ The TIP (Active Holder)',
              description: 'The only person who can currently invite',
              card: const TipPersonCard(
                displayName: 'Emma Rodriguez',
                chainKey: 'CHAIN0000100',
                position: 100,
              ),
            ),

            // 5. Pending Card
            _buildCardWithLabel(
              label: '⏳ Pending Invitation',
              description: 'Invitation sent, waiting to join',
              card: _buildPendingCard(),
            ),

            // 6. Ghost Card
            _buildCardWithLabel(
              label: '👻 Ghost Slot',
              description: 'Empty position waiting for invitation',
              card: const BlurredPersonCard(
                position: 101,
                isGhost: true,
              ),
            ),

            // 7. Wasted Card
            _buildCardWithLabel(
              label: '🚫 Wasted Invitation',
              description: 'Invitation expired without being used',
              card: _buildWastedCard(),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Special Cases'),
            const SizedBox(height: 16),

            // 8. Milestone Card
            _buildCardWithLabel(
              label: '🎯 Milestone Position',
              description: 'Celebrating significant positions (#100, #1000)',
              card: _buildMilestoneCard(),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Combined View Example'),
            const SizedBox(height: 16),
            _buildChainExample(),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCardWithLabel({
    required String label,
    required String description,
    required Widget card,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          card,
        ],
      ),
    );
  }

  Widget _buildGenesisCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).scale(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Genesis Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🌱',
                  style: TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sarah Johnson',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '#1',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'CHAIN0000001',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'THE BEGINNING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFD700),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withOpacity(0.15),
            const Color(0xFFD97706).withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.5),
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFFF59E0B),
              child: Icon(
                Icons.access_time,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Smith',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Invitation Sent',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '⏰ 23h 15m remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWastedCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      opacity: 0.6,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEF4444).withOpacity(0.1),
              const Color(0xFFDC2626).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFFEF4444),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'David Wilson',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white54,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      'Invitation Expired',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '❌ Expired 2 hours ago',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC0C0C0), Color(0xFFA8A8A8)],
        ).scale(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC0C0C0).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC0C0C0).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Sparkle overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: _SparklePainter(),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFC0C0C0), Color(0xFFA8A8A8)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '💯',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emma Rodriguez',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 16,
                            color: Color(0xFFC0C0C0),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'MILESTONE #100',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC0C0C0),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChainExample() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How They Look Together',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 350,
            child: Column(
              children: [
                // Genesis
                _buildMiniCard('🌱', 'Genesis', '#1', const Color(0xFFFFD700)),
                _buildConnector(),

                // Ellipsis
                _buildEllipsis('34 members'),
                _buildConnector(),

                // Active
                _buildMiniCard('✅', 'Active', '#36', const Color(0xFF10B981)),
                _buildConnector(),

                // Current User
                _buildMiniCard('⭐', 'YOU', '#37', const Color(0xFF7C3AED)),
                _buildConnector(),

                // Active
                _buildMiniCard('✅', 'Active', '#38', const Color(0xFF10B981)),
                _buildConnector(),

                // Ellipsis
                _buildEllipsis('61 members'),
                _buildConnector(),

                // TIP
                _buildMiniCard('⚡', 'TIP', '#100', const Color(0xFF10B981)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(String emoji, String label, String position, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            '$label $position',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      height: 20,
      width: 2,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildEllipsis(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⋮', style: TextStyle(color: Colors.white38)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          const Text('⋮', style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Add some sparkle dots
    for (int i = 0; i < 10; i++) {
      final x = (size.width / 10) * i + 10;
      final y = (size.height / 2) + (i.isEven ? -10 : 10);
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}