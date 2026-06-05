import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../domain/entities/health_article.dart';

/// Section 8: Health News Feed — list of health articles.
class HealthNewsFeed extends StatelessWidget {
  final List<HealthArticle> articles;
  final ValueChanged<HealthArticle> onArticleTap;

  const HealthNewsFeed({
    super.key,
    required this.articles,
    required this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Tin tức sức khỏe', style: context.textStyles.heading3),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: articles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) => _ArticleTile(
            article: articles[index],
            onTap: () => onArticleTap(articles[index]),
          ),
        ),
      ],
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final HealthArticle article;
  final VoidCallback onTap;

  const _ArticleTile({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('HH:mm • dd/MM');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: context.radius.mRadius,
          boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 8)],
        ),
        child: Row(
          children: [
            // Placeholder image
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              ),
              child: Icon(Icons.article_rounded, color: context.colors.primary, size: 36),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withOpacity(0.1),
                        borderRadius: context.radius.xsRadius,
                      ),
                      child: Text(
                        article.source,
                        style: context.textStyles.caption.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      style: context.textStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeFormatter.format(article.publishedAt),
                      style: context.textStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
