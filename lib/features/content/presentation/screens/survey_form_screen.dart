import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/core/theme/colors/app_colors.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/features/content/domain/entities/content_entities.dart';
import 'package:smart_clinic_booking/features/content/presentation/controllers/content_controller.dart';

class SurveyFormScreen extends ConsumerStatefulWidget {
  final Survey survey;

  const SurveyFormScreen({super.key, required this.survey});

  @override
  ConsumerState<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends ConsumerState<SurveyFormScreen> {
  final Map<String, dynamic> _answers = {};
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  double get _completionRatio {
    if (widget.survey.questions.isEmpty) return 0.0;
    int answered = 0;
    for (final q in widget.survey.questions) {
      final ans = _answers[q.id];
      if (ans != null) {
        if (ans is String && ans.isNotEmpty) answered++;
        if (ans is List && ans.isNotEmpty) answered++;
        if (ans is int) answered++;
      }
    }
    return answered / widget.survey.questions.length;
  }

  bool _validateRequiredAnswers() {
    for (final q in widget.survey.questions) {
      if (!q.required) continue;
      final ans = _answers[q.id];
      if (ans == null) return false;
      if (ans is String && ans.isEmpty) return false;
      if (ans is List && ans.isEmpty) return false;
    }
    return true;
  }

  Future<void> _submit() async {
    // Find the first unanswered required question to scroll to it
    if (!_validateRequiredAnswers()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng trả lời đầy đủ các câu hỏi bắt buộc (*)'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        _showErrorDialog('Bạn cần đăng nhập để gửi khảo sát.');
        return;
      }

      // Sanitize answers so Firestore can serialize them
      final sanitizedAnswers = _answers.map((key, value) {
        if (value is List) return MapEntry(key, List<String>.from(value));
        return MapEntry(key, value);
      });

      debugPrint('[Survey] Submitting surveyId=${widget.survey.id} userId=${user.uid}');
      debugPrint('[Survey] Answers: $sanitizedAnswers');

      final result = await ref.read(contentRepositoryProvider).submitSurveyResponse(
        surveyId: widget.survey.id,
        userId: user.uid,
        answers: sanitizedAnswers,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      result.fold(
        (failure) {
          debugPrint('[Survey] Submit failed: ${failure.message}');
          _showErrorDialog(failure.message);
        },
        (_) {
          debugPrint('[Survey] Submit success');
          // Refresh the survey list to reflect completion
          ref.read(surveyProvider.notifier).loadSurveys(userId: user.uid);
          setState(() => _isSubmitted = true);
        },
      );
    } catch (e, st) {
      debugPrint('[Survey] Submit exception: $e\n$st');
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showErrorDialog('Đã xảy ra lỗi không mong đợi.\n$e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red, size: 22),
            SizedBox(width: 8),
            Text('Không thể gửi khảo sát',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message,
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandedAppBar(
        title: 'Khảo sát & Đánh giá',
        showBackButton: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: _completionRatio,
            backgroundColor: Colors.grey.shade200,
            color: AppColors.primary,
            minHeight: 6,
          ),
        ),
      ),
      body: _isSubmitted ? _buildThankYou() : _buildForm(),
    );
  }

  Widget _buildThankYou() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 80, color: Colors.green.shade400),
          const SizedBox(height: 20),
          const Text(
            'Cảm ơn bạn đã tham gia!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Phản hồi của bạn giúp chúng tôi cải thiện dịch vụ.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          ...widget.survey.questions.asMap().entries.map(
            (entry) => _buildQuestionCard(entry.key, entry.value),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Gửi khảo sát', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.survey.category != null) ...[
                _CategoryChip(category: widget.survey.category!),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: LinearProgressIndicator(
                  value: _completionRatio,
                  backgroundColor: Colors.grey.shade100,
                  color: AppColors.primary,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(_completionRatio * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.survey.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.survey.description,
            style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${widget.survey.estimatedMinutes} phút',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.question_answer_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${widget.survey.questions.length} câu hỏi',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, SurveyQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600),
              children: [
                TextSpan(text: '${index + 1}. ${question.text}'),
                if (question.required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildAnswerWidget(question),
        ],
      ),
    );
  }

  Widget _buildAnswerWidget(SurveyQuestion question) {
    switch (question.type) {
      case 'single_choice':
        return _buildSingleChoice(question);
      case 'multiple_choice':
        return _buildMultipleChoice(question);
      case 'rating':
        return _buildRating(question);
      case 'text':
        return _buildTextAnswer(question);
      default:
        return _buildSingleChoice(question);
    }
  }

  Widget _buildSingleChoice(SurveyQuestion question) {
    final selected = _answers[question.id] as String?;
    return Column(
      children: question.options.map((option) {
        final isSelected = selected == option;
        return InkWell(
          onTap: () => setState(() => _answers[question.id] = option),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(option, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoice(SurveyQuestion question) {
    final selected = (_answers[question.id] as List<String>?) ?? [];
    return Column(
      children: question.options.map((option) {
        final isChecked = selected.contains(option);
        return InkWell(
          onTap: () {
            setState(() {
              final current = List<String>.from(_answers[question.id] as List<String>? ?? []);
              if (isChecked) {
                current.remove(option);
              } else {
                current.add(option);
              }
              _answers[question.id] = current;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isChecked ? AppColors.primary : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isChecked ? AppColors.primary : Colors.transparent,
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(option, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRating(SurveyQuestion question) {
    final rating = _answers[question.id] as int?;
    final maxRating = question.maxRating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(maxRating, (i) {
            final starNum = i + 1;
            final isFilled = rating != null && starNum <= rating;
            return GestureDetector(
              onTap: () => setState(() => _answers[question.id] = starNum),
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFilled ? Colors.amber.shade600 : Colors.grey.shade400,
                  size: 32,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          rating == null ? 'Chưa đánh giá' : '$rating/$maxRating sao',
          style: TextStyle(
            fontSize: 13,
            color: rating == null ? Colors.grey : AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextAnswer(SurveyQuestion question) {
    return TextField(
      maxLines: 3,
      onChanged: (v) => setState(() => _answers[question.id] = v),
      decoration: InputDecoration(
        hintText: 'Nhập câu trả lời của bạn...',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}

// ─── Category Chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = _categoryColors(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.$1,
        ),
      ),
    );
  }

  static (Color, Color) _categoryColors(String category) {
    switch (category) {
      case 'Dịch vụ':
        return (const Color(0xFF2563EB), const Color(0xFFDBEAFE));
      case 'Bác sĩ':
        return (const Color(0xFF059669), const Color(0xFFD1FAE5));
      case 'Cơ sở vật chất':
        return (const Color(0xFFD97706), const Color(0xFFFEF3C7));
      case 'Trải nghiệm':
        return (const Color(0xFF7C3AED), const Color(0xFFEDE9FE));
      case 'Dinh dưỡng':
        return (const Color(0xFFDB2777), const Color(0xFFFCE7F3));
      default:
        return (AppColors.primary, const Color(0xFFDBEAFE));
    }
  }
}
