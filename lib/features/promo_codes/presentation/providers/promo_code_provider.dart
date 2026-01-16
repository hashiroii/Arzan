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
  String? serviceFilter;
  SortOption sortOption = SortOption.mostRecent;
  String? lastDocumentId;
  bool hasMore = true;

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
      serviceFilter: serviceFilter,
      sortOption: sortOption,
      limit: 20,
      lastDocumentId: lastDocumentId,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (promoCodes) {
        if (promoCodes.isEmpty) {
          hasMore = false;
        } else {
          lastDocumentId = promoCodes.last.id;
          final currentList = state.value ?? [];
          state = AsyncValue.data(
            refresh ? promoCodes : [...currentList, ...promoCodes],
          );
        }
      },
    );
  }

  void setFilter(String? service) {
    serviceFilter = service;
    loadPromoCodes(refresh: true);
  }

  void setSortOption(SortOption sort) {
    sortOption = sort;
    loadPromoCodes(refresh: true);
  }
}

final promoCodesNotifierProvider =
    StateNotifierProvider<PromoCodesNotifier, AsyncValue<List<PromoCode>>>((
      ref,
    ) {
      return PromoCodesNotifier(ref.read(getPromoCodesProvider));
    });
