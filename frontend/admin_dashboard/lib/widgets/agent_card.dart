import 'package:flutter/material.dart';
import '../models/agent_status.dart';
import '../theme/dark_mystique_theme.dart';
import 'mystique_components.dart';

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
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Only animate if agent is active or working
    if (widget.agent.status == 'active' || widget.agent.status == 'working') {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AgentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.agent.status == 'active' || widget.agent.status == 'working') {
      if (!_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      }
    } else {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 220,
              height: 280,
              transform: Matrix4.identity()
                ..scale(_isHovered ? 1.02 : 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: DarkMystiqueTheme.shadowPurple,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.agent.statusColor.withOpacity(
                      widget.agent.status == 'active' || widget.agent.status == 'working'
                          ? _glowAnimation.value
                          : 0.3,
                    ),
                    width: widget.agent.status == 'blocked' ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.agent.statusColor.withOpacity(
                        widget.agent.status == 'active' || widget.agent.status == 'working'
                            ? _glowAnimation.value * 0.5
                            : 0.2,
                      ),
                      blurRadius: 20,
                      spreadRadius: widget.agent.status == 'blocked' ? 5 : 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar and Emotion
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
                                widget.agent.statusColor.withOpacity(0.3),
                                widget.agent.statusColor.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Icon(
                            _getAgentIcon(widget.agent.role),
                            size: 30,
                            color: widget.agent.statusColor,
                          ),
                        ),
                        // Emotion indicator
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: DarkMystiqueTheme.deepVoid,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            widget.agent.emotionEmoji,
                            style: const TextStyle(fontSize: 16),
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
                            DarkMystiqueTheme.etherealPurple.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.agent.statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.agent.statusColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.agent.statusIcon,
                            size: 12,
                            color: widget.agent.statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.agent.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: widget.agent.statusColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
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
            ),
          );
        },
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