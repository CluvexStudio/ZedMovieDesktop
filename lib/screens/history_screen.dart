import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../constants/app_theme.dart';
import '../models/movie.dart';
import '../models/series.dart';
import 'movie_detail_screen.dart';
import 'series_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Watch History'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: isDark ? AppTheme.blueGradient : AppTheme.purpleGradient,
                ),
              ),
            ),
            actions: [
              Consumer<HistoryProvider>(
                builder: (context, provider, _) {
                  if (provider.history.isEmpty) return const SizedBox();
                  return IconButton(
                    icon: const Icon(Icons.delete_sweep_rounded),
                    onPressed: () => _showClearDialog(context, provider),
                  );
                },
              ),
            ],
          ),
          Consumer<HistoryProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (provider.history.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 80,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No watch history',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your watched content will appear here',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = provider.history[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildHistoryCard(context, item, isDark, provider),
                      );
                    },
                    childCount: provider.history.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    Map<String, dynamic> item,
    bool isDark,
    HistoryProvider provider,
  ) {
    final watchedAt = DateTime.fromMillisecondsSinceEpoch(item['watchedAt']);
    final timeAgo = _getTimeAgo(watchedAt);

    return Dismissible(
      key: Key('${item['type']}_${item['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: AppTheme.accentPink,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        provider.removeFromHistory(item['id'], item['type']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Removed from history'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => provider.addToHistory(item),
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (item['type'] == 'movie') {
            final movie = Movie(
              id: item['id'],
              type: item['type'],
              title: item['title'],
              description: '',
              year: 0,
              imdb: 0,
              rating: 0,
              image: item['image'],
              cover: '',
              genres: [],
              sources: [],
              countries: [],
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
            );
          } else {
            final series = Series(
              id: item['id'],
              type: item['type'],
              title: item['title'],
              description: '',
              year: 0,
              imdb: 0,
              rating: 0,
              image: item['image'],
              cover: '',
              genres: [],
              countries: [],
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SeriesDetailScreen(series: series)),
            );
          }
        },
        child: Container(
          height: 120,
          decoration: AppTheme.cardDecoration(isDark),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: item['image'],
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: isDark ? AppTheme.cardBlack : AppTheme.lightGrey,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: isDark ? AppTheme.cardBlack : AppTheme.lightGrey,
                    child: const Icon(Icons.movie, size: 32),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['type'] == 'movie' ? 'Movie' : 'Series',
                              style: TextStyle(
                                color: AppTheme.accentPurple,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  void _showClearDialog(BuildContext context, HistoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Watch History'),
        content: const Text('Are you sure you want to clear all watch history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
