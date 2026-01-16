import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/promo_code_card.dart';
import '../providers/promo_code_provider.dart';
import '../widgets/banner_widget.dart';
import '../widgets/filter_chips_widget.dart';
import '../widgets/sort_dropdown.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'details_page.dart';
import 'post_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(promoCodesNotifierProvider.notifier).loadPromoCodes();
    }
  }

  Future<void> _handleVote(String promoCodeId, bool isUpvote) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in to vote')));
      return;
    }

    final upvoteUseCase = ref.read(upvotePromoCodeProvider);
    final downvoteUseCase = ref.read(downvotePromoCodeProvider);
    final removeVoteUseCase = ref.read(removeVoteProvider);

    final promoCodeList = ref.read(promoCodesNotifierProvider).value;
    if (promoCodeList == null) return;

    final promoCode = promoCodeList.firstWhere(
      (code) => code.id == promoCodeId,
      orElse: () => promoCodeList.first, // Fallback
    );

    final isCurrentlyUpvoted = promoCode.upvotedBy.contains(currentUser.id);
    final isCurrentlyDownvoted = promoCode.downvotedBy.contains(currentUser.id);

    if (isUpvote) {
      if (isCurrentlyUpvoted) {
        await removeVoteUseCase(promoCodeId, currentUser.id);
      } else {
        if (isCurrentlyDownvoted) {
          await removeVoteUseCase(promoCodeId, currentUser.id);
        }
        await upvoteUseCase(promoCodeId, currentUser.id);
      }
    } else {
      if (isCurrentlyDownvoted) {
        await removeVoteUseCase(promoCodeId, currentUser.id);
      } else {
        if (isCurrentlyUpvoted) {
          await removeVoteUseCase(promoCodeId, currentUser.id);
        }
        await downvoteUseCase(promoCodeId, currentUser.id);
      }
    }

    // Refresh the list
    ref.read(promoCodesNotifierProvider.notifier).loadPromoCodes(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final promoCodesAsync = ref.watch(promoCodesNotifierProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref
              .read(promoCodesNotifierProvider.notifier)
              .loadPromoCodes(refresh: true);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Banner
            SliverToBoxAdapter(child: BannerWidget()),

            // Filter chips and sort
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FilterChipsWidget(
                        onFilterChanged: (service) {
                          ref
                              .read(promoCodesNotifierProvider.notifier)
                              .setFilter(service);
                        },
                      ),
                    ),
                    SortDropdown(
                      onSortChanged: (sortOption) {
                        ref
                            .read(promoCodesNotifierProvider.notifier)
                            .setSortOption(sortOption);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Promo codes list
            promoCodesAsync.when(
              data: (promoCodes) {
                if (promoCodes.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No promo codes found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final promoCode = promoCodes[index];
                    return PromoCodeCard(
                      promoCode: promoCode,
                      currentUserId: currentUser?.id,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailsPage(promoCodeId: promoCode.id),
                          ),
                        );
                      },
                      onUpvote: () {
                        _handleVote(promoCode.id, true);
                      },
                      onDownvote: () {
                        _handleVote(promoCode.id, false);
                      },
                    );
                  }, childCount: promoCodes.length),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading promo codes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(promoCodesNotifierProvider.notifier)
                              .loadPromoCodes(refresh: true);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
