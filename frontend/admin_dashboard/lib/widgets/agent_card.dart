import 'package:flutter/material.dart';
import '../models/agent_status.dart';
import '../theme/dark_mystique_theme.dart';
import 'mystique_agent_components/mystique_agent_components.dart';

/// Enhanced Agent Card with prominent visual status indicators
/// TASK-012: 4px border, top-right badge, enhanced animation, improved glow
class AgentCard extends StatefulWidget {
  final AgentStatus agent;
  final VoidCallback? onTap;

  const AgentCard({
    super.key,
    required this.agent,
    this.onTap,
  });

  @override
  State<AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends State<AgentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500), // TASK-012: 1.5s smooth animation
      vsync: this,
    );

    // TASK-012: Enhanced pulse animation (0.5 → 1.0 instead of 0.3 → 0.6)
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // TASK-012: Use shouldPulse helper method from AgentStatus
    if (widget.agent.shouldPulse) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AgentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // TASK-012: Use shouldPulse helper and reset to full opacity when stopped
    if (widget.agent.shouldPulse != oldWidget.agent.shouldPulse) {
      if (widget.agent.shouldPulse) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.value = 1.0; // Reset to full opacity
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Agent ${widget.agent.name}, status: ${widget.agent.statusText}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            // TASK-012: Improved glow effects
            final glowOpacity = widget.agent.shouldPulse
                ? _glowAnimation.value * 0.3
                : 0.2;
            final blurRadius = widget.agent.shouldPulse ? 30.0 : 20.0;
            final spreadRadius = widget.agent.shouldPulse ? 4.0 : 2.0;

            return GestureDetector(
              onTap: widget.onTap,
              child: AnimatedScale(
                scale: _isHovered ? 1.02 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: 220,
                  height: 280,
                  child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: DarkMystiqueTheme.shadowPurple,
                        borderRadius: BorderRadius.circular(16),
                        // TASK-012: Enhanced 4px border (primary indicator)
                        border: Border.all(
                          color: widget.agent.statusColor.withValues(
                            alpha: widget.agent.shouldPulse ? _glowAnimation.value : 1.0,
                          ),
                          width: 4.0, // Increased from 1-2px to 4px
                        ),
                        // TASK-012: Improved glow effects
                        boxShadow: [
                          BoxShadow(
                            color: widget.agent.statusColor.withValues(alpha: glowOpacity),
                            blurRadius: blurRadius,
                            spreadRadius: spreadRadius,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar with Status and Emotion indicators
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                widget.agent.statusColor.withValues(alpha: 0.3),
                                widget.agent.statusColor.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Icon(
                            _getAgentIcon(widget.agent.role),
                            size: 30,
                            color: widget.agent.statusColor,
                          ),
                        ),
                        // Emotion indicator using new component
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: DarkMystiqueTheme.deepVoid,
                            shape: BoxShape.circle,
                          ),
                          child: CompactEmotionIndicator(
                            emotion: widget.agent.emotion,
                            size: 16,
                          ),
                        ),
                      ],
                    ),

                    // Agent Name
                    Text(
                      widget.agent.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: DarkMystiqueTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Role
                    Text(
                      widget.agent.role,
                      style: TextStyle(
                        fontSize: 11,
                        color: DarkMystiqueTheme.textSecondary,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            DarkMystiqueTheme.etherealPurple.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // Status Badge using new component
                    MystiqueStatusBadge(
                      status: widget.agent.status,
                      animated: widget.agent.shouldPulse,
                      size: 14.0,
                    ),

                    // Current Task
                    if (widget.agent.currentTask != null) ...[
                      Text(
                        'Current Task:',
                        style: TextStyle(
                          fontSize: 10,
                          color: DarkMystiqueTheme.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.agent.currentTask!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: DarkMystiqueTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else
                      Container(
                        height: 30,
                        alignment: Alignment.center,
                        child: Text(
                          'No active task',
                          style: TextStyle(
                            fontSize: 11,
                            color: DarkMystiqueTheme.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    // Progress Bar (if applicable)
                    if (widget.agent.progress != null)
                      Column(
                        children: [
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: widget.agent.progress,
                            backgroundColor: DarkMystiqueTheme.twilightGray,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.agent.statusColor,
                            ),
                            minHeight: 3,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(widget.agent.progress! * 100).toInt()}% Complete',
                            style: TextStyle(
                              fontSize: 9,
                              color: DarkMystiqueTheme.textMuted,
                            ),
                          ),
                        ],
                      ),

                    // Last Activity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 10,
                          color: DarkMystiqueTheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.agent.timeSinceLastActivity,
                          style: TextStyle(
                            fontSize: 10,
                            color: DarkMystiqueTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    ],
                      ),
                    ),
                    // TASK-012: Top-right status badge (secondary indicator)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.agent.statusColor.withValues(alpha: 0.2),
                          border: Border.all(
                            color: widget.agent.statusColor,
                            width: 2.0,
                          ),
                        ),
                        child: Icon(
                          widget.agent.statusIcon,
                          size: 16,
                          color: widget.agent.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          },
        ),
      ),
    );
  }

  IconData _getAgentIcon(String role) {
    final iconMap = {
      'Project Management': Icons.dashboard,
      'System Architecture': Icons.architecture,
      'Backend Development': Icons.code,
      'Database Design': Icons.storage,
      'Quality Assurance': Icons.bug_report,
      'DevOps & Infrastructure': Icons.cloud,
      'UI/UX Design': Icons.palette,
      'Frontend Development': Icons.web,
      'Mobile Development': Icons.phone_android,
      'Agile Facilitation': Icons.groups,
      'Product Strategy': Icons.lightbulb,
      'User Psychology': Icons.psychology,
      'Game Theory': Icons.casino,
      'Legal & Compliance': Icons.gavel,
    };
    return iconMap[role] ?? Icons.person;
  }
}