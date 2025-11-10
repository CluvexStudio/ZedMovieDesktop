import 'package:flutter/material.dart';
import '../models/country.dart';
import '../models/movie.dart';
import '../models/series.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/series_card.dart';
import '../constants/app_theme.dart';

class CountryContentScreen extends StatefulWidget {
  final Country country;

  const CountryContentScreen({super.key, required this.country});

  @override
  State<CountryContentScreen> createState() => _CountryContentScreenState();
}

class _CountryContentScreenState extends State<CountryContentScreen> {
  List<dynamic> _content = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadContent();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 500) {
      _loadMore();
    }
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final newContent = await ApiService.getContentByCountry(
        widget.country.id,
        page: _currentPage,
      );

      setState(() {
        if (_currentPage == 0) {
          _content = newContent;
        } else {
          _content.addAll(newContent);
        }
        _hasMore = newContent.isNotEmpty && newContent.length >= 20;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_hasMore && !_isLoading) {
      _currentPage++;
      await _loadContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.country.title),
              background: Container(
                decoration: BoxDecoration(
                  gradient: isDark ? AppTheme.purpleGradient : AppTheme.blueGradient,
                ),
              ),
            ),
          ),
          if (_isLoading && _content.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null && _content.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppTheme.accentPink,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load content',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _currentPage = 0;
                        _loadContent();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_content.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.movie_filter_rounded,
                      size: 80,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No content found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'from ${widget.country.title}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == _content.length) {
                      return _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox();
                    }
                    final item = _content[index];
                    if (item is Movie) {
                      return MovieCard(
                        movie: item,
                        width: double.infinity,
                        height: 240,
                      );
                    } else {
                      return SeriesCard(
                        series: item as Series,
                        width: double.infinity,
                        height: 240,
                      );
                    }
                  },
                  childCount: _content.length + (_isLoading ? 1 : 0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

