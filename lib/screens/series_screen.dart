import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/series_provider.dart';
import '../models/filter_type.dart';
import '../models/genre.dart';
import '../widgets/series_card.dart';
import '../widgets/genre_chip.dart';
import '../widgets/filter_chip_widget.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeriesProvider>().loadGenres();
    });
    
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 500) {
      context.read<SeriesProvider>().loadSeries();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF0A0E21),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Series',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildFilterSection(),
                const SizedBox(height: 16),
                _buildGenreSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
          _buildSeriesGrid(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Consumer<SeriesProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              FilterChipWidget(
                filterType: FilterType.latest,
                selectedFilter: provider.filterType,
                label: 'Latest',
                icon: Icons.access_time,
                onTap: () => provider.setFilterType(FilterType.latest),
              ),
              FilterChipWidget(
                filterType: FilterType.byYear,
                selectedFilter: provider.filterType,
                label: 'By Year',
                icon: Icons.calendar_today,
                onTap: () => provider.setFilterType(FilterType.byYear),
              ),
              FilterChipWidget(
                filterType: FilterType.byImdb,
                selectedFilter: provider.filterType,
                label: 'Top Rated',
                icon: Icons.star,
                onTap: () => provider.setFilterType(FilterType.byImdb),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenreSection() {
    return Consumer<SeriesProvider>(
      builder: (context, provider, child) {
        if (provider.genres.isEmpty) {
          return const SizedBox();
        }

        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              GenreChip(
                genre: Genre(id: 0, title: 'All'),
                isSelected: provider.selectedGenreId == 0,
                onTap: () => provider.setGenreFilter(0),
              ),
              ...provider.genres.map((genre) {
                return GenreChip(
                  genre: genre,
                  isSelected: provider.selectedGenreId == genre.id,
                  onTap: () => provider.setGenreFilter(genre.id),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeriesGrid() {
    return Consumer<SeriesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.series.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null && provider.series.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load series',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadSeries(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.series.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Text(
                'No series found',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == provider.series.length) {
                  return provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox();
                }
                return SeriesCard(
                  series: provider.series[index],
                  width: double.infinity,
                  height: 240,
                );
              },
              childCount: provider.series.length + (provider.isLoading ? 1 : 0),
            ),
          ),
        );
      },
    );
  }
}

