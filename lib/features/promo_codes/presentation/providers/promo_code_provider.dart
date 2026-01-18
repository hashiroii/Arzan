import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/promo_code.dart';
import '../../domain/repositories/promo_code_repository.dart';
import '../../domain/usecases/get_promo_codes.dart';
import '../../domain/usecases/create_promo_code.dart';
import '../../domain/usecases/vote_promo_code.dart';
import '../../domain/usecases/get_promo_code_by_id.dart';
import '../../../../core/utils/dependency_injection.dart';

final promoCodeRepositoryProvider = Provider<PromoCodeRepository>((ref) {
  return DependencyInjection.promoCodeRepository;
});

final getPromoCodesProvider = Provider<GetPromoCodes>((ref) {
  return GetPromoCodes(ref.read(promoCodeRepositoryProvider));
});

final createPromoCodeProvider = Provider<CreatePromoCode>((ref) {
  return CreatePromoCode(ref.read(promoCodeRepositoryProvider));
});

final upvotePromoCodeProvider = Provider<UpvotePromoCode>((ref) {
  return UpvotePromoCode(ref.read(promoCodeRepositoryProvider));
});

final downvotePromoCodeProvider = Provider<DownvotePromoCode>((ref) {
  return DownvotePromoCode(ref.read(promoCodeRepositoryProvider));
});

final removeVoteProvider = Provider<RemoveVote>((ref) {
  return RemoveVote(ref.read(promoCodeRepositoryProvider));
});

final getPromoCodeByIdProvider = Provider<GetPromoCodeById>((ref) {
  return GetPromoCodeById(ref.read(promoCodeRepositoryProvider));
});

class PromoCodesNotifier extends StateNotifier<AsyncValue<List<PromoCode>>> {
  final GetPromoCodes getPromoCodes;
  String? _serviceFilter;
  SortOption sortOption = SortOption.mostRecent;
  String? lastDocumentId;
  bool hasMore = true;

  String? get serviceFilter => _serviceFilter;

  PromoCodesNotifier(this.getPromoCodes) : super(const AsyncValue.loading()) {
    loadPromoCodes();
  }

  Future<void> loadPromoCodes({bool refresh = false}) async {
    if (refresh) {
      lastDocumentId = null;
      hasMore = true;
      state = const AsyncValue.loading();
    }

    if (!hasMore && !refresh) return;

    final result = await getPromoCodes(
      serviceFilter: _serviceFilter,
      sortOption: sortOption,
      limit: 20,
      lastDocumentId: lastDocumentId,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (promoCodes) {
        if (promoCodes.isEmpty) {
          hasMore = false;
          if (refresh) {
            state = const AsyncValue.data([]);
          }
        } else {
          final sortedPromoCodes = _sortWithExpiredAtEnd(promoCodes);
          lastDocumentId = sortedPromoCodes.last.id;
          if (refresh) {
            state = AsyncValue.data(sortedPromoCodes);
          } else {
            final currentList = state.value ?? [];
            final existingIds = currentList.map((e) => e.id).toSet();
            final newPromoCodes = sortedPromoCodes.where((code) => !existingIds.contains(code.id)).toList();
            if (newPromoCodes.isNotEmpty) {
              final sortedCurrentList = _sortWithExpiredAtEnd(currentList);
              state = AsyncValue.data([...sortedCurrentList, ...newPromoCodes]);
            }
          }
        }
      },
    );
  }

  void setFilter(String? service) {
    _serviceFilter = service;
    loadPromoCodes(refresh: true);
  }

  void setSortOption(SortOption sort) {
    sortOption = sort;
    loadPromoCodes(refresh: true);
  }

  void updatePromoCodeVote(String promoCodeId, String userId, bool isUpvote) {
    final currentList = state.value;
    if (currentList == null) return;

    final updatedList = currentList.map((code) {
      if (code.id != promoCodeId) return code;

      final wasUpvoted = code.upvotedBy.contains(userId);
      final wasDownvoted = code.downvotedBy.contains(userId);

      List<String> newUpvotedBy = List.from(code.upvotedBy);
      List<String> newDownvotedBy = List.from(code.downvotedBy);
      int newUpvotes = code.upvotes;
      int newDownvotes = code.downvotes;

      if (isUpvote) {
        if (wasUpvoted) {
          newUpvotedBy.remove(userId);
          newUpvotes = (newUpvotes - 1).clamp(0, double.infinity).toInt();
        } else {
          if (wasDownvoted) {
            newDownvotedBy.remove(userId);
            newDownvotes = (newDownvotes - 1).clamp(0, double.infinity).toInt();
          }
          newUpvotedBy.add(userId);
          newUpvotes = newUpvotes + 1;
        }
      } else {
        if (wasDownvoted) {
          newDownvotedBy.remove(userId);
          newDownvotes = (newDownvotes - 1).clamp(0, double.infinity).toInt();
        } else {
          if (wasUpvoted) {
            newUpvotedBy.remove(userId);
            newUpvotes = (newUpvotes - 1).clamp(0, double.infinity).toInt();
          }
          newDownvotedBy.add(userId);
          newDownvotes = newDownvotes + 1;
        }
      }

      return code.copyWith(
        upvotes: newUpvotes.clamp(0, double.infinity).toInt(),
        downvotes: newDownvotes.clamp(0, double.infinity).toInt(),
        upvotedBy: newUpvotedBy,
        downvotedBy: newDownvotedBy,
      );
    }).toList();

    final sortedList = _sortWithExpiredAtEnd(updatedList);
    state = AsyncValue.data(sortedList);
  }

  List<PromoCode> _sortWithExpiredAtEnd(List<PromoCode> promoCodes) {
    final active = <PromoCode>[];
    final expired = <PromoCode>[];
    
    for (final code in promoCodes) {
      if (code.isExpired) {
        expired.add(code);
      } else {
        active.add(code);
      }
    }
    
    return [...active, ...expired];
  }
}

final promoCodesNotifierProvider =
    StateNotifierProvider<PromoCodesNotifier, AsyncValue<List<PromoCode>>>((
      ref,
    ) {
      return PromoCodesNotifier(ref.read(getPromoCodesProvider));
    });
