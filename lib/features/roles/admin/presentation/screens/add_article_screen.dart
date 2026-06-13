import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/facility_entities.dart';
import '../controllers/admin_controller.dart';

class AddArticleScreen extends StatefulWidget {
  final ArticleEntity? article; 
  
  const AddArticleScreen({super.key, this.article});

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _authorController = TextEditingController(text: widget.article?.authorName ?? '');
    _categoryController = TextEditingController(text: widget.article?.category ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.article != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? 'Chỉnh sửa bài viết' : 'Tạo bài viết mới',
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Tiêu đề bài viết'),
                  validator: (value) => value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(labelText: 'Tên bác sĩ tác giả'),
                  validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên tác giả' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Chuyên khoa / Danh mục'),
                  validator: (value) => value!.isEmpty ? 'Vui lòng nhập danh mục' : null,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final controller = context.read<AdminController>();

                        if (isEditMode) {
                          final updatedArticle = ArticleEntity(
                            id: widget.article!.id, 
                            title: _titleController.text.trim(),
                            authorName: _authorController.text.trim(),
                            category: _categoryController.text.trim(),
                            status: widget.article!.status,
                            views: widget.article!.views,
                            publishDate: widget.article!.publishDate,
                          );
                          controller.updateArticle(updatedArticle); 
                          } else {
                          final now = DateTime.now();
                          final formattedDate = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';
                          final newArticle = ArticleEntity(
                            id: 'art_${now.millisecondsSinceEpoch}',
                            title: _titleController.text.trim(),
                            authorName: _authorController.text.trim(),
                            category: _categoryController.text.trim(),
                            status: 'Đã xuất bản',
                            views: 0,
                            publishDate: formattedDate,
                          );
                          controller.addNewArticle(newArticle);
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      isEditMode ? 'Cập nhật bài viết' : 'Xuất bản bài viết', 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}