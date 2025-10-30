import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/dashboard_models.dart';
import '../../theme/app_theme.dart';

/// Enhanced chain visualization with pagination and buffering
class PaginatedChainWidget extends StatefulWidget {
  final List<ChainMember> initialMembers;
  final Future<List<ChainMember>> Function(int offset, int limit) onLoadMore;
  final int bufferSize;
  final int pageSize;

  const PaginatedChainWidget({
    super.key,
    required this.initialMembers,
    required this.onLoadMore,
    this.bufferSize = 10, // Load 10 extra items above and below viewport
    this.pageSize = 20, // Load 20 items at a time
  });

  @override
  State<PaginatedChainWidget> createState() => _PaginatedChainWidgetState();
}

class _PaginatedChainWidgetState extends State<PaginatedChainWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flowController;
  late Animation<double> _flowAnimation;

  // Pagination state
  final List<ChainMember> _allMembers = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentOffset = 0;

  // Viewport tracking
  double _viewportHeight = 0;
  final double _itemHeight = 140; // Estimated height per chain item

  // Buffer management
  final Map<int, bool> _bufferedPositions = {};

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _flowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _flowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flowController,
      curve: Curves.linear,
    ));

    // Initialize members
    _allMembers.addAll(widget.initialMembers);
    _currentOffset = widget.initialMembers.length;

    // Setup scroll listener
    _scrollController.addListener(_onScroll);

    // Pre-buffer initial batch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadBuffer();
    });
  }

  @override
  void dispose() {
    _flowController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * 0.7; // Load more when 70% scrolled

    // Load more when approaching bottom
    if (currentScroll >= threshold && !_isLoadingMore && _hasMore) {
      _loadMore();
    }

    // Check if we need to buffer more items
    _checkBufferNeeds();
  }

  void _checkBufferNeeds() {
    if (!_scrollController.hasClients) return;

    final viewportTop = _scrollController.offset;
    final viewportBottom = viewportTop + _viewportHeight;

    // Calculate which positions are in or near viewport
    final startPosition = (viewportTop / _itemHeight).floor() - widget.bufferSize;
    final endPosition = (viewportBottom / _itemHeight).ceil() + widget.bufferSize;

    // Check if we need to load more for buffer
    if (endPosition > _allMembers.length - 5 && !_isLoadingMore && _hasMore) {
      _loadMore();
    }
  }

  Future<void> _preloadBuffer() async {
    // Preload first buffer batch if needed
    if (_allMembers.length < widget.pageSize * 2 && _hasMore) {
      await _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newMembers = await widget.onLoadMore(_currentOffset, widget.pageSize);

      if (mounted) {
        setState(() {
          _allMembers.addAll(newMembers);
          _currentOffset += newMembers.length;
          _hasMore = newMembers.length == widget.pageSize;
          _isLoadingMore = false;

          // Mark these positions as buffered
          for (int i = _currentOffset - newMembers.length; i < _currentOffset; i++) {
            _bufferedPositions[i] = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more chain members: $e'),
            backgroundColor: AppTheme.darkMystique.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _allMembers.clear();
      _allMembers.addAll(widget.initialMembers);
      _currentOffset = widget.initialMembers.length;
      _hasMore = true;
      _bufferedPositions.clear();
    });

    await _preloadBuffer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;
    _viewportHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.shadowDark,
            theme.shadowDark.withOpacity(0.8),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: theme.gray700.withOpacity(0.3),
            width: 1,
          ),
          bottom: BorderSide(
            color: theme.gray700.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        // Inner container for 3D effect
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.1),
            ],
            stops: const [0.0, 0.05, 0.95, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Chain list with smart scrolling
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: theme.mysticViolet,
                backgroundColor: theme.shadowDark,
                child: _buildChainList(),
              ),
            ),

            // Info bar
            _buildInfoBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = AppTheme.darkMystique;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'THE CHAIN',
            style: TextStyle(
              color: theme.gold,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.mysticViolet.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.mysticViolet.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Text(
              'v2.0.0',
              style: TextStyle(
                color: theme.mysticViolet,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          // Live indicator
          _buildLiveIndicator(),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    final theme = AppTheme.darkMystique;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.emerald.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.emerald.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.emerald,
              boxShadow: [
                BoxShadow(
                  color: theme.emerald.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LIVE',
            style: TextStyle(
              color: theme.emerald,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChainList() {
    final theme = AppTheme.darkMystique;

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Chain members
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < _allMembers.length) {
                final member = _allMembers[index];
                final isLast = index == _allMembers.length - 1;

                return Column(
                  children: [
                    _buildMemberNode(member, index),
                    if (!isLast || _hasMore) _buildAnimatedConnector(),
                  ],
                );
              }

              // Loading indicator at the end
              if (_isLoadingMore && index == _allMembers.length) {
                return _buildLoadingIndicator();
              }

              return null;
            },
            childCount: _allMembers.length + (_isLoadingMore ? 1 : 0),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberNode(ChainMember member, int index) {
    final theme = AppTheme.darkMystique;

    // Determine node appearance based on status
    Color nodeColor = _getNodeColor(member);
    Color borderColor = nodeColor;
    double opacity = member.isCurrentUser ? 1.0 : 0.8;

    // Add entrance animation for newly loaded items
    final isNewlyLoaded = _bufferedPositions[index] ?? false;

    return AnimatedOpacity(
      opacity: isNewlyLoaded ? 1.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            // Node circle with position
            _buildNodeCircle(member, borderColor, opacity),
            const SizedBox(width: 16),
            // Member info card
            Expanded(
              child: _buildMemberCard(member, borderColor, theme),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNodeColor(ChainMember member) {
    final theme = AppTheme.darkMystique;

    switch (member.status) {
      case ChainMemberStatus.genesis:
        return theme.gold;
      case ChainMemberStatus.tip:
        return const Color(0xFF00D4FF); // Cyan
      case ChainMemberStatus.active:
        return theme.emerald;
      case ChainMemberStatus.removed:
      case ChainMemberStatus.expired:
        return theme.errorRed;
      default:
        return theme.mysticViolet;
    }
  }

  Widget _buildNodeCircle(ChainMember member, Color borderColor, double opacity) {
    return Container(
      width: member.isCurrentUser ? 64 : 56,
      height: member.isCurrentUser ? 64 : 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            borderColor.withOpacity(opacity * 0.3),
            borderColor.withOpacity(opacity * 0.2),
            borderColor.withOpacity(opacity * 0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: borderColor.withOpacity(opacity),
          width: member.isCurrentUser ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
          if (member.isCurrentUser)
            BoxShadow(
              color: borderColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '#${member.position}',
              style: TextStyle(
                color: borderColor,
                fontSize: member.isCurrentUser ? 18 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getInitials(member),
              style: TextStyle(
                color: borderColor.withOpacity(0.9),
                fontSize: member.isCurrentUser ? 12 : 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(ChainMember member, Color borderColor, theme) {
    return Container(
      decoration: BoxDecoration(
        color: member.isCurrentUser
            ? borderColor.withOpacity(0.1)
            : theme.shadowDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: member.isCurrentUser
              ? borderColor.withOpacity(0.3)
              : theme.gray700.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.15),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.08),
            ],
            stops: const [0.0, 0.08, 0.92, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.displayName,
              style: TextStyle(
                color: member.isCurrentUser ? borderColor : Colors.white,
                fontSize: 14,
                fontWeight: member.isCurrentUser ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  member.chainKey,
                  style: TextStyle(
                    color: theme.gray500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: borderColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    member.status.label.toUpperCase(),
                    style: TextStyle(
                      color: borderColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
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

  String _getInitials(ChainMember member) {
    if (member.displayName.endsWith('***')) {
      return member.displayName.substring(0, 2);
    }

    final parts = member.displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return member.displayName.substring(0, 2).toUpperCase();
  }

  Widget _buildAnimatedConnector() {
    final theme = AppTheme.darkMystique;

    return SizedBox(
      width: double.infinity,
      height: 24,
      child: Center(
        child: AnimatedBuilder(
          animation: _flowAnimation,
          builder: (context, child) {
            return Container(
              width: 3,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.gray700.withOpacity(0.1),
                    theme.gold.withOpacity(0.3 + 0.3 * _flowAnimation.value),
                    theme.gold.withOpacity(0.5 + 0.4 * _flowAnimation.value),
                    theme.gold.withOpacity(0.3 + 0.3 * (1 - _flowAnimation.value)),
                    theme.gray700.withOpacity(0.1),
                  ],
                  stops: [
                    0.0,
                    _flowAnimation.value * 0.4,
                    _flowAnimation.value * 0.5,
                    _flowAnimation.value * 0.6,
                    1.0,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.gold.withOpacity(0.2 * _flowAnimation.value),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    final theme = AppTheme.darkMystique;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              color: theme.mysticViolet,
              strokeWidth: 2,
            ),
            const SizedBox(height: 12),
            Text(
              'Loading more chain members...',
              style: TextStyle(
                color: theme.gray600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBar() {
    final theme = AppTheme.darkMystique;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.shadowDark.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: theme.gray700.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: ${_allMembers.length} members',
            style: TextStyle(
              color: theme.gray600,
              fontSize: 12,
            ),
          ),
          if (_hasMore)
            Text(
              'Scroll for more',
              style: TextStyle(
                color: theme.mysticViolet,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (!_hasMore)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.emerald.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.emerald.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'All loaded',
                style: TextStyle(
                  color: theme.emerald,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}