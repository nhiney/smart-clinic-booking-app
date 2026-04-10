import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../shared/widgets/doctor_card.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/doctor_catalog_query.dart';
import '../../domain/entities/doctor_entity.dart';
import '../controllers/doctor_search_controller.dart';
import '../widgets/doctor_filter_chip.dart';
import 'doctor_detail_screen.dart';

/// Patient flow: discover doctors in Firestore `doctors` with filters and sort.
/// When [pickForBooking] is true, tapping a doctor pops with that [DoctorEntity].
class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key, this.pickForBooking = false});

  final bool pickForBooking;

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      context.read<DoctorSearchController>().onSearchChanged(v),
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên bác sĩ, chuyên khoa, phòng khám...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _locationCtrl,
                  onChanged: (v) => context
                      .read<DoctorSearchController>()
                      .setLocationFilter(v),
                  decoration: InputDecoration(
                    hintText: 'Khu vực / địa chỉ (lọc theo vị trí)',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.place_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Consumer<DoctorSearchController>(
            builder: (_, c, __) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: () {
                              final s = c.specialtyFilter;
                              if (s.isEmpty) return '';
                              if (c.specialtyOptions.contains(s)) return s;
                              return '';
                            }(),
                            decoration: InputDecoration(
                              labelText: 'Chuyên khoa',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem<String>(
                                value: '',
                                child: Text('Tất cả chuyên khoa'),
                              ),
                              ...c.specialtyOptions.map(
                                (s) => DropdownMenuItem<String>(
                                  value: s,
                                  child: Text(
                                    s,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (v) => c.setSpecialty(v ?? ''),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<DoctorCatalogSort>(
                            value: c.sort,
                            decoration: InputDecoration(
                              labelText: 'Sắp xếp',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: DoctorCatalogSort.values
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      _sortLabel(s),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) c.setSort(v);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đánh giá tối thiểu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          DoctorFilterChip(
                            label: 'Tất cả',
                            selected: c.minRating == null,
                            onTap: () => c.setMinRating(null),
                          ),
                          const SizedBox(width: 8),
                          DoctorFilterChip(
                            label: '≥ 4.0',
                            selected: c.minRating == 4.0,
                            onTap: () => c.setMinRating(4.0),
                          ),
                          const SizedBox(width: 8),
                          DoctorFilterChip(
                            label: '≥ 4.5',
                            selected: c.minRating == 4.5,
                            onTap: () => c.setMinRating(4.5),
                          ),
                          const SizedBox(width: 8),
                          DoctorFilterChip(
                            label: '≥ 4.8',
                            selected: c.minRating == 4.8,
                            onTap: () => c.setMinRating(4.8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: Consumer<DoctorSearchController>(
              builder: (_, c, __) {
                if (c.viewState == DoctorSearchViewState.loading &&
                    c.doctors.isEmpty) {
                  return const LoadingWidget(itemCount: 5);
                }

                if (c.viewState == DoctorSearchViewState.error) {
                  return EmptyStateWidget(
                    icon: Icons.wifi_off_outlined,
                    title: c.errorMessage ?? 'Đã xảy ra lỗi',
                    buttonText: 'Thử lại',
                    onButtonPressed: () => c.retry(),
                  );
                }

                if (c.viewState == DoctorSearchViewState.empty ||
                    (c.viewState == DoctorSearchViewState.loaded &&
                        c.doctors.isEmpty)) {
                  return const EmptyStateWidget(
                    icon: Icons.search_off_outlined,
                    title: 'Không tìm thấy bác sĩ',
                    subtitle: 'Thử đổi bộ lọc hoặc từ khóa tìm kiếm',
                  );
                }

                return Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: c.doctors.length,
                      itemBuilder: (context, index) {
                        final d = c.doctors[index];
                        return DoctorCard(
                          name: d.name.isNotEmpty ? d.name : 'Bác sĩ',
                          specialty: d.specialty.isNotEmpty
                              ? d.specialty
                              : '—',
                          imageUrl: d.imageUrl,
                          rating: d.rating,
                          hospital: d.displayClinic.isNotEmpty
                              ? d.displayClinic
                              : '—',
                          totalReviews: d.totalReviews > 0
                              ? d.totalReviews
                              : null,
                          distanceLabel: _distanceLabel(d),
                          onTap: () {
                            if (widget.pickForBooking) {
                              Navigator.pop(context, d);
                              return;
                            }
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    DoctorDetailScreen(doctor: d),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    if (c.viewState == DoctorSearchViewState.loading &&
                        c.doctors.isNotEmpty)
                      const LinearProgressIndicator(minHeight: 2),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
