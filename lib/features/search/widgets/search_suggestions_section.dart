import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/features/search/providers/search_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/poet_horizontal_card.dart';

class SearchSuggestionsSection extends ConsumerWidget {
  const SearchSuggestionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestedPoets = ref.watch(suggestedPoetsProvider);

    return suggestedPoets.when(
      data: (response) {
        if (response.content.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Suggested Poets',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 165,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: response.content.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final poet = response.content[index];
                    return PoetHorizontalCard(
                      poet: poet,
                      onTap: () {
                        context.push('/main/poets/${poet.publicId}');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (error, stack) => const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      ),
    );
  }
}
