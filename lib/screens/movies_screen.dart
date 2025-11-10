import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/filter_type.dart';
import '../models/genre.dart';
import '../widgets/movie_card.dart';
import '../widgets/genre_chip.dart';
import '../widgets/filter_chip_widget.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadGenres();
    });
    
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 500) {
      context.read<MovieProvider>().loadMovies();
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
              'Movies',
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
          _buildMoviesGrid(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Consumer<MovieProvider>(
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
    return Consumer<MovieProvider>(
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

  Widget _buildMoviesGrid() {
    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.movies.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null && provider.movies.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load movies',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadMovies(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.movies.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Text(
                'No movies found',
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
                if (index == provider.movies.length) {
                  return provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox();
                }
                return MovieCard(
                  movie: provider.movies[index],
                  width: double.infinity,
                  height: 240,
                );
              },
              childCount: provider.movies.length + (provider.isLoading ? 1 : 0),
            ),
          ),
        );
      },
    );
  }
}

