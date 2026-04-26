import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/colors/app_colors.dart';
import '../../../../../core/widgets/branded_app_bar.dart';
import '../../../../../shared/widgets/doctor_card.dart';
import '../../../../../shared/widgets/empty_state_widget.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../domain/entities/doctor_catalog_query.dart';
import '../../../domain/entities/doctor_entity.dart';
import '../controllers/doctor_search_controller.dart';
import '../widgets/doctor_filter_chip.dart';
/// Patient flow: discover doctors in Firestore `doctors` with filters and sort.
/// When [pickForBooking] is true, tapping a doctor pops with that [DoctorEntity].
class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({
    super.key,
    this.pickForBooking = false,
    this.initialSearchText,
  });

  final bool pickForBooking;
  final String? initialSearchText;

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchText != null && widget.initialSearchText!.isNotEmpty) {
      context.read<DoctorSearchController>().onSearchChanged(widget.initialSearchText!);
      _searchCtrl.text = widget.initialSearchText!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorSearchController>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  String? _distanceLabel(DoctorEntity d) {
    final km = d.distanceKm;
    if (km == null || km.isInfinite) return null;
    return '${km.toStringAsFixed(1)} km';
  }

  String _sortLabel(DoctorCatalogSort s) {
    switch (s) {
      case DoctorCatalogSort.ratingDesc:
        return 'Đánh giá cao';
      case DoctorCatalogSort.popular:
        return 'Phổ biến';
      case DoctorCatalogSort.nearest:
        return 'Gần nhất';
      case DoctorCatalogSort.experienceDesc:
        return 'Kinh nghiệm nhất';
      case DoctorCatalogSort.experienceAsc:
        return 'Ít kinh nghiệm nhất';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandedAppBar(
        title: widget.pickForBooking
            ? 'Chọn bác sĩ để đặt lịch'
            : 'Tìm kiếm & Khám bệnh',
        showBackButton: true,
        actions: [
          IconButton(
            tooltip: 'Xóa bộ lọc',
            icon: const Icon(Icons.filter_alt_off_outlined),
            onPressed: () {
              _searchCtrl.clear();
              _locationCtrl.clear();
              context.read<DoctorSearchController>().clearFilters();
            },
          ),
        ],
      ),
      body: Consumer<DoctorSearchController>(
        builder: (_, c, __) {
          return CustomScrollView(
            slivers: [
              // 1. Search & Filter Header
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => c.onSearchChanged(v),
                            decoration: InputDecoration(
                              hintText: 'Tìm bác sĩ, chuyên khoa...',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              prefixIcon: const Icon(Icons.search, size: 20),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _locationCtrl,
                            onChanged: (v) => c.setLocationFilter(v),
                            decoration: InputDecoration(
                              hintText: 'Khu vực / địa chỉ...',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              prefixIcon: const Icon(Icons.place_outlined, size: 20),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactDropdown<String>(
                                  label: 'Chuyên khoa',
                                  value: () {
                                    final s = c.specialtyFilter;
                                    if (s.isEmpty) return '';
                                    if (c.specialtyOptions.contains(s)) return s;
                                    return '';
                                  }(),
                                  items: [
                                    const DropdownMenuItem(value: '', child: Text('Tất cả')),
                                    ...c.specialtyOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                                  ],
                                  onChanged: (v) => c.setSpecialty(v ?? ''),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildCompactDropdown<DoctorCatalogSort>(
                                  label: 'Sắp xếp',
                                  value: c.sort,
                                  items: DoctorCatalogSort.values.map((s) => DropdownMenuItem(value: s, child: Text(_sortLabel(s)))).toList(),
                                  onChanged: (v) => v != null ? c.setSort(v) : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Đánh giá tối thiểu',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                DoctorFilterChip(label: 'Tất cả', selected: c.minRating == null, onTap: () => c.setMinRating(null)),
                                const SizedBox(width: 8),
                                DoctorFilterChip(label: '≥ 4.0', selected: c.minRating == 4.0, onTap: () => c.setMinRating(4.0)),
                                const SizedBox(width: 8),
                                DoctorFilterChip(label: '≥ 4.5', selected: c.minRating == 4.5, onTap: () => c.setMinRating(4.5)),
                                const SizedBox(width: 8),
                                DoctorFilterChip(label: '≥ 4.8', selected: c.minRating == 4.8, onTap: () => c.setMinRating(4.8)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Suggestions & History (only if search is empty)
              if (c.searchText.isEmpty && (c.searchHistory.isNotEmpty || c.suggestions.isNotEmpty))
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (c.searchHistory.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tìm kiếm gần đây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              TextButton(
                                onPressed: () => c.clearHistory(),
                                child: const Text('Xóa', style: TextStyle(color: Colors.red, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: c.searchHistory.map((h) => ActionChip(
                              label: Text(h, style: const TextStyle(fontSize: 12)),
                              onPressed: () {
                                _searchCtrl.text = h;
                                c.onSearchChanged(h);
                              },
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade300)),
                            )).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (c.suggestions.isNotEmpty) ...[
                          const Text('Gợi ý cho bạn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ),

              if (c.searchText.isEmpty && c.suggestions.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final d = c.suggestions[index];
                        return DoctorCard(
                          name: d.name,
                          specialty: d.specialty,
                          imageUrl: d.imageUrl,
                          rating: d.rating,
                          hospital: d.displayClinic,
                          experienceYears: d.experience,
                          onTap: () => context.push('/doctor/detail/${d.id}', extra: d),
                        );
                      },
                      childCount: c.suggestions.length,
                    ),
                  ),
                ),

              // 3. Main Search Results
              if (c.searchText.isNotEmpty) ...[
                if (c.viewState == DoctorSearchViewState.loading && c.doctors.isEmpty)
                  const SliverFillRemaining(child: LoadingWidget(itemCount: 5))
                else if (c.viewState == DoctorSearchViewState.error)
                  SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.wifi_off_outlined,
                      title: c.errorMessage ?? 'Đã xảy ra lỗi',
                      buttonText: 'Thử lại',
                      onButtonPressed: () => c.retry(),
                    ),
                  )
                else if (c.viewState == DoctorSearchViewState.empty || (c.viewState == DoctorSearchViewState.loaded && c.doctors.isEmpty))
                  const SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.search_off_outlined,
                      title: 'Không tìm thấy bác sĩ',
                      subtitle: 'Thử đổi bộ lọc hoặc từ khóa tìm kiếm',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final d = c.doctors[index];
                          return DoctorCard(
                            name: d.name.isNotEmpty ? d.name : 'Bác sĩ',
                            specialty: d.specialty.isNotEmpty ? d.specialty : '—',
                            imageUrl: d.imageUrl,
                            rating: d.rating,
                            hospital: d.displayClinic.isNotEmpty ? d.displayClinic : '—',
                            totalReviews: d.totalReviews > 0 ? d.totalReviews : null,
                            distanceLabel: _distanceLabel(d),
                            experienceYears: d.experience,
                            onTap: () {
                              if (widget.pickForBooking) {
                                Navigator.pop(context, d);
                                return;
                              }
                              context.push('/doctor/detail/${d.id}', extra: d);
                            },
                          );
                        },
                        childCount: c.doctors.length,
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompactDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      isExpanded: true,
      items: items,
      onChanged: onChanged,
    );
  }
}
