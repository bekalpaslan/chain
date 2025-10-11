import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_health_provider.dart';
import '../models/project_health.dart';
import '../theme/dark_mystique_theme.dart';
import '../widgets/mystique_components.dart';

/// Project Health Dashboard Screen
///
/// Displays comprehensive project health metrics including:
/// - Overall completion score
/// - Category breakdown
/// - Critical blockers
/// - Agent status grid
/// - Top priorities
class ProjectHealthScreen extends StatelessWidget {
  const ProjectHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectHealthProvider(),
      child: const _ProjectHealthView(),
    );
  }
}

class _ProjectHealthView extends StatelessWidget {
  const _ProjectHealthView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectHealthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Health Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading ? null : () => provider.refresh(),
            tooltip: 'Refresh Data',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && !provider.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null && !provider.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final health = provider.projectHealth;
          if (health == null) {
            return const Center(
              child: Text('No data available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with last updated
                  _buildHeader(health.metadata),
                  const SizedBox(height: 24),

                  // Overall health card
                  _OverallHealthCard(metadata: health.metadata),
                  const SizedBox(height: 24),

                  // Category scores grid
                  _CategoryScoresGrid(categoryScores: health.categoryScores),
                  const SizedBox(height: 24),

                  // Critical blockers
                  _CriticalBlockersCard(blockers: health.criticalBlockers),
                  const SizedBox(height: 24),

                  // Top priorities
                  _TopPrioritiesCard(recommendations: health.recommendations),
                  const SizedBox(height: 24),

                  // Agent status grid
                  _AgentStatusSection(agentAssessments: health.agentAssessments),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ProjectHealthMetadata metadata) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Assessment Version ${metadata.assessmentVersion}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'Last Updated: ${_formatDateTime(metadata.lastUpdated)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDateTime(String isoDateTime) {
    try {
      final dt = DateTime.parse(isoDateTime);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
             '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDateTime;
    }
  }
}

/// Overall Health Card showing circular progress
class _OverallHealthCard extends StatelessWidget {
  final ProjectHealthMetadata metadata;

  const _OverallHealthCard({required this.metadata});

  @override
  Widget build(BuildContext context) {
    final score = metadata.overallCompletion;
    final color = _getScoreColor(score);

    return MystiqueCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: score / 10,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        score.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        '/ 10',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Project Health',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getHealthDescription(score),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatChip(
                        icon: Icons.people,
                        label: '${metadata.totalAgents} Agents',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      _buildStatChip(
                        icon: Icons.trending_up,
                        label: _getStatusLabel(score),
                        color: color,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 7.0) return DarkMystiqueTheme.success;
    if (score >= 5.0) return DarkMystiqueTheme.warning;
    return DarkMystiqueTheme.error;
  }

  String _getHealthDescription(double score) {
    if (score >= 8.0) return 'Excellent progress! Project is on track.';
    if (score >= 7.0) return 'Good progress with minor improvements needed.';
    if (score >= 5.0) return 'Fair progress. Several areas need attention.';
    if (score >= 3.0) return 'Critical issues detected. Immediate action required.';
    return 'Severe blockers present. Urgent intervention needed.';
  }

  String _getStatusLabel(double score) {
    if (score >= 7.0) return 'Good';
    if (score >= 5.0) return 'Fair';
    return 'Critical';
  }
}

/// Category Scores Grid
class _CategoryScoresGrid extends StatelessWidget {
  final Map<String, double> categoryScores;

  const _CategoryScoresGrid({required this.categoryScores});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Breakdown',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1200
                ? 4
                : constraints.maxWidth > 900
                    ? 3
                    : constraints.maxWidth > 600
                        ? 2
                        : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: categoryScores.length,
              itemBuilder: (context, index) {
                final entry = categoryScores.entries.elementAt(index);
                return _CategoryScoreCard(
                  category: _formatCategoryName(entry.key),
                  score: entry.value,
                );
              },
            );
          },
        ),
      ],
    );
  }

  String _formatCategoryName(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class _CategoryScoreCard extends StatelessWidget {
  final String category;
  final double score;

  const _CategoryScoreCard({
    required this.category,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(score);

    return MystiqueCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  score.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.grey.shade800,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: score / 10,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 7.0) return DarkMystiqueTheme.success;
    if (score >= 5.0) return DarkMystiqueTheme.warning;
    return DarkMystiqueTheme.error;
  }
}

/// Critical Blockers Card
class _CriticalBlockersCard extends StatelessWidget {
  final List<CriticalBlocker> blockers;

  const _CriticalBlockersCard({required this.blockers});

  @override
  Widget build(BuildContext context) {
    return MystiqueCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: blockers.isEmpty ? DarkMystiqueTheme.success : DarkMystiqueTheme.error,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Critical Blockers (${blockers.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (blockers.isEmpty)
              const Text(
                'No critical blockers detected. Great job!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                ),
              )
            else
              ...blockers.map((blocker) => _BlockerItem(blocker: blocker)),
          ],
        ),
      ),
    );
  }
}

class _BlockerItem extends StatelessWidget {
  final CriticalBlocker blocker;

  const _BlockerItem({required this.blocker});

  @override
  Widget build(BuildContext context) {
    final severityColor = blocker.severity == 'BLOCKING'
        ? DarkMystiqueTheme.error
        : DarkMystiqueTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  blocker.severity,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  blocker.area,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: severityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            blocker.description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Impact: ${blocker.impact}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Top Priorities Card
class _TopPrioritiesCard extends StatelessWidget {
  final Recommendations recommendations;

  const _TopPrioritiesCard({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return MystiqueCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: DarkMystiqueTheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Top Priorities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.immediateActions.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: DarkMystiqueTheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: DarkMystiqueTheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildRecommendationRow(
              icon: Icons.center_focus_strong,
              label: 'Sprint Focus',
              value: recommendations.sprintFocus,
            ),
            const SizedBox(height: 12),
            _buildRecommendationRow(
              icon: Icons.groups,
              label: 'Resource Allocation',
              value: recommendations.resourceAllocation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Agent Status Section
class _AgentStatusSection extends StatelessWidget {
  final List<AgentAssessment> agentAssessments;

  const _AgentStatusSection({required this.agentAssessments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Agent Status',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1400
                ? 4
                : constraints.maxWidth > 1000
                    ? 3
                    : constraints.maxWidth > 700
                        ? 2
                        : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: agentAssessments.length,
              itemBuilder: (context, index) {
                return _AgentCard(assessment: agentAssessments[index]);
              },
            );
          },
        ),
      ],
    );
  }
}

class _AgentCard extends StatefulWidget {
  final AgentAssessment assessment;

  const _AgentCard({required this.assessment});

  @override
  State<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends State<_AgentCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(widget.assessment.completionScore);
    final emotionIcon = _getEmotionIcon(widget.assessment.emotion);
    final statusIcon = _getStatusIcon(widget.assessment.status);

    return MystiqueCard(
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(statusIcon, size: 20, color: scoreColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.assessment.agentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(emotionIcon, size: 20, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 12),

              // Score
              Row(
                children: [
                  Text(
                    widget.assessment.completionScore.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    ' / 10',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Summary
              Text(
                widget.assessment.assessmentSummary,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade300,
                ),
                maxLines: _isExpanded ? null : 2,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
              ),

              if (_isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                // Top Priorities
                if (widget.assessment.topPriorities.isNotEmpty) ...[
                  _buildSection(
                    'Top Priorities',
                    widget.assessment.topPriorities,
                    Icons.flag,
                    Colors.blue,
                  ),
                  const SizedBox(height: 8),
                ],

                // Critical Gaps
                if (widget.assessment.criticalGaps.isNotEmpty) ...[
                  _buildSection(
                    'Critical Gaps',
                    widget.assessment.criticalGaps,
                    Icons.error_outline,
                    DarkMystiqueTheme.warning,
                  ),
                  const SizedBox(height: 8),
                ],

                // Blockers
                if (widget.assessment.blockers.isNotEmpty) ...[
                  _buildSection(
                    'Blockers',
                    widget.assessment.blockers,
                    Icons.block,
                    DarkMystiqueTheme.error,
                  ),
                ],
              ],

              const Spacer(),

              // Expand indicator
              Center(
                child: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...items.take(3).map(
              (item) => Padding(
                padding: const EdgeInsets.only(left: 20, top: 2),
                child: Text(
                  '• $item',
                  style: const TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 7.0) return DarkMystiqueTheme.success;
    if (score >= 5.0) return DarkMystiqueTheme.warning;
    return DarkMystiqueTheme.error;
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'satisfied':
        return Icons.sentiment_satisfied;
      case 'neutral':
        return Icons.sentiment_neutral;
      case 'focused':
        return Icons.psychology;
      case 'frustrated':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return Icons.play_circle_filled;
      case 'working':
        return Icons.engineering;
      case 'idle':
        return Icons.pause_circle_filled;
      case 'done':
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }
}
