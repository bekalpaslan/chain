import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/agent_card.dart';
import '../widgets/mystique_components.dart';
import '../theme/dark_mystique_theme.dart';

class ProjectBoardScreen extends StatelessWidget {
  const ProjectBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkMystiqueTheme.deepVoid,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DarkMystiqueTheme.deepVoid,
              DarkMystiqueTheme.shadowPurple.withOpacity(0.3),
            ],
          ),
        ),
        child: Consumer<DashboardProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.agents.isEmpty) {
              return const Center(
                child: MystiqueLoadingIndicator(
                  message: 'Connecting to agents...',
                ),
              );
            }

            if (provider.error != null && provider.agents.isEmpty) {
              return Center(
                child: MystiqueAlert(
                  message: provider.error!,
                  type: MystiqueAlertType.error,
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _buildHeader(context, provider),
                ),

                // Project Overview
                if (provider.projectStatus != null)
                  SliverToBoxAdapter(
                    child: _buildProjectOverview(context, provider),
                  ),

                // Quick Stats
                SliverToBoxAdapter(
                  child: _buildQuickStats(context, provider),
                ),

                // Agents Section Title
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people,
                          color: DarkMystiqueTheme.etherealPurple,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Agent Status',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: DarkMystiqueTheme.textPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Agent Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: provider.agents
                          .map((agent) => AgentCard(
                                agent: agent,
                                onTap: () => _showAgentDetails(context, agent),
                              ))
                          .toList(),
                    ),
                  ),
                ),

                // Activity Timeline
                SliverToBoxAdapter(
                  child: _buildActivityTimeline(context, provider),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 48),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DarkMystiqueTheme.shadowPurple.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: DarkMystiqueTheme.mysticViolet.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => DarkMystiqueTheme.mysticGradient.createShader(bounds),
                child: const Text(
                  'Project Board - The Chain',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DarkMystiqueTheme.successGlow,
                      boxShadow: [
                        BoxShadow(
                          color: DarkMystiqueTheme.successGlow.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Real-time Connected',
                    style: TextStyle(
                      fontSize: 12,
                      color: DarkMystiqueTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: DarkMystiqueTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${_getTimeAgo(provider.lastUpdate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: DarkMystiqueTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                color: DarkMystiqueTheme.etherealPurple,
                onPressed: () => provider.loadData(),
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                color: DarkMystiqueTheme.textSecondary,
                onPressed: () {},
                tooltip: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectOverview(BuildContext context, DashboardProvider provider) {
    final project = provider.projectStatus!;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: MystiqueCard(
        elevated: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rocket_launch,
                  color: DarkMystiqueTheme.etherealPurple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Project Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DarkMystiqueTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: project.healthColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: project.healthColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        project.healthIcon,
                        size: 14,
                        color: project.healthColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        project.health.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: project.healthColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              project.activeSprint,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: DarkMystiqueTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              project.sprintId,
              style: TextStyle(
                fontSize: 12,
                color: DarkMystiqueTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sprint Progress',
                      style: TextStyle(
                        fontSize: 12,
                        color: DarkMystiqueTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${project.sprintProgress}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: DarkMystiqueTheme.ghostCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: project.sprintProgress / 100,
                    minHeight: 8,
                    backgroundColor: DarkMystiqueTheme.twilightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      DarkMystiqueTheme.ghostCyan,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric('Story Points', '${project.completedPoints}/${project.totalStoryPoints}', Icons.trending_up),
                _buildMetric('Active Tasks', project.activeTasks.toString(), Icons.assignment),
                _buildMetric('Critical', project.criticalTasks.toString(), Icons.priority_high, DarkMystiqueTheme.errorPulse),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, [Color? color]) {
    final metricColor = color ?? DarkMystiqueTheme.etherealPurple;
    return Column(
      children: [
        Icon(icon, size: 20, color: metricColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: metricColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: DarkMystiqueTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, DashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: MystiqueStatCard(
              title: 'Active Agents',
              value: provider.activeAgents.length.toString(),
              icon: Icons.flash_on,
              accentColor: DarkMystiqueTheme.ghostCyan,
              subtitle: 'Currently working',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: MystiqueStatCard(
              title: 'Blocked',
              value: provider.blockedAgents.length.toString(),
              icon: Icons.block,
              accentColor: DarkMystiqueTheme.errorPulse,
              subtitle: 'Need attention',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: MystiqueStatCard(
              title: 'Idle',
              value: provider.idleAgents.length.toString(),
              icon: Icons.schedule,
              accentColor: DarkMystiqueTheme.mysticViolet,
              subtitle: 'Available',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: MystiqueStatCard(
              title: 'Total Agents',
              value: provider.agents.length.toString(),
              icon: Icons.people,
              accentColor: DarkMystiqueTheme.etherealPurple,
              subtitle: 'Team size',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline(BuildContext context, DashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: MystiqueCard(
        elevated: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: DarkMystiqueTheme.etherealPurple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Activity Timeline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DarkMystiqueTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: Icon(
                    Icons.filter_list,
                    size: 16,
                    color: DarkMystiqueTheme.textSecondary,
                  ),
                  label: Text(
                    'Filter',
                    style: TextStyle(
                      color: DarkMystiqueTheme.textSecondary,
                    ),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: DarkMystiqueTheme.deepVoid.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DarkMystiqueTheme.twilightGray,
                  width: 1,
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: provider.activityLogs.length,
                itemBuilder: (context, index) {
                  final log = provider.activityLogs[index];
                  final isError = log.contains('error') || log.contains('failed');
                  final isSuccess = log.contains('completed') || log.contains('deployed');

                  Color logColor = DarkMystiqueTheme.textSecondary;
                  if (isError) {
                    logColor = DarkMystiqueTheme.errorPulse;
                  } else if (isSuccess) {
                    logColor = DarkMystiqueTheme.successGlow;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isError ? Icons.error_outline :
                          isSuccess ? Icons.check_circle_outline :
                          Icons.info_outline,
                          size: 14,
                          color: logColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            log,
                            style: TextStyle(
                              fontSize: 12,
                              color: logColor,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 10) {
      return 'just now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  void _showAgentDetails(BuildContext context, agent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DarkMystiqueTheme.shadowPurple,
        title: Text(
          agent.name,
          style: const TextStyle(color: DarkMystiqueTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Role', agent.role),
            _buildDetailRow('Status', agent.status),
            _buildDetailRow('Emotion', '${agent.emotionEmoji} ${agent.emotion}'),
            if (agent.currentTask != null)
              _buildDetailRow('Current Task', agent.currentTask!),
            _buildDetailRow('Last Activity', agent.timeSinceLastActivity),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: DarkMystiqueTheme.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: DarkMystiqueTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}