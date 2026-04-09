import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
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
          child: Text('Tin tức sức khỏe', style: AppTextStyles.heading3),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
        ),
        child: Row(
          children: [
            // Placeholder image
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              ),
              child: const Icon(Icons.article_rounded, color: AppColors.primary, size: 36),
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
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.source,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeFormatter.format(article.publishedAt),
                      style: AppTextStyles.caption,
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
