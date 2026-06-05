import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/icare_tokens.dart';
import '../../../../../shared/widgets/empty_state_widget.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/doctor_catalog_query.dart';
import '../../domain/entities/doctor_entity.dart';
import '../controllers/doctor_search_controller.dart';

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
    if (widget.initialSearchText != null &&
        widget.initialSearchText!.isNotEmpty) {
      context
          .read<DoctorSearchController>()
          .onSearchChanged(widget.initialSearchText!);
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
        return 'Kinh nghiệm nhiều';
      case DoctorCatalogSort.experienceAsc:
        return 'Kinh nghiệm ít';
    }
  }

  /// Extracts initials from a full name (up to 2 letters).
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Picks a gradient colour based on the first letter.
  Color _avatarColor(String name) {
    const palette = [
      IColors.primary500,
      IColors.violet,
      IColors.mint,
      IColors.rose,
      IColors.amber,
      IColors.success,
    ];
    final code = name.isEmpty ? 0 : name.codeUnitAt(0);
    return palette[code % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IColors.bg,
      body: Consumer<DoctorSearchController>(
        builder: (_, c, __) {
          return CustomScrollView(
            slivers: [
              // ── Header ─────────────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader(c)),

              // ── Search bar ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _SearchBar(
                    controller: _searchCtrl,
                    onChanged: c.onSearchChanged,
                  ),
                ),
              ),

              // ── Active filter chips ────────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildFilterChips(c),
              ),

              // ── Sort row ───────────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildSortRow(c)),

              // ── Specialty scroll ───────────────────────────────────────────
              SliverToBoxAdapter(child: _buildSpecialtyScroll(c)),

              // ── Main content ───────────────────────────────────────────────
              if (c.viewState == DoctorSearchViewState.loading &&
                  c.doctors.isEmpty)
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
              else if (c.viewState == DoctorSearchViewState.empty ||
                  (c.viewState == DoctorSearchViewState.loaded &&
                      c.doctors.isEmpty))
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.search_off_outlined,
                    title: 'Không tìm thấy bác sĩ',
                    subtitle: 'Thử đổi bộ lọc hoặc từ khóa tìm kiếm',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _DoctorCard(
                        doctor: c.doctors[index],
                        distanceLabel: _distanceLabel(c.doctors[index]),
                        initials: _initials(c.doctors[index].name),
                        avatarColor: _avatarColor(c.doctors[index].name),
                        isFirst: index == 0,
                        onTap: () {
                          final d = c.doctors[index];
                          if (widget.pickForBooking) {
                            Navigator.pop(context, d);
                            return;
                          }
                          context.push('/doctor/detail/${d.id}', extra: d);
                        },
                      ),
                      childCount: c.doctors.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(DoctorSearchController c) {
    final activeCount = [
      c.specialtyFilter.isNotEmpty,
      c.minRating != null,
    ].where((b) => b).length;

    return Container(
      color: IColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Back button
                  _CircleButton(
                    onTap: () => Navigator.maybePop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: IColors.ink),
                  ),
                  const SizedBox(width: 14),
                  // Title column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KHÁM BỆNH',
                          style: IText.label(size: 10, color: IColors.ink3),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.pickForBooking
                              ? 'Chọn bác sĩ'
                              : 'Tìm bác sĩ',
                          style: IText.display(size: 22, color: IColors.ink),
                        ),
                      ],
                    ),
                  ),
                  // Filter button with badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _FilledButton(
                        onTap: () {
                          // Show filter bottom sheet (placeholder)
                          _showFilterSheet(context, c);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.tune_rounded,
                                size: 16, color: IColors.surface),
                            const SizedBox(width: 6),
                            Text(
                              'Lọc',
                              style: IText.label(
                                  size: 12.5, color: IColors.surface),
                            ),
                          ],
                        ),
                      ),
                      if (activeCount > 0)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: IColors.danger,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$activeCount',
                              style: IText.label(
                                  size: 9.5, color: IColors.surface),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '1.247 bác sĩ · 24 chuyên khoa',
                style: IText.body(size: 12.5, color: IColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────

  Widget _buildFilterChips(DoctorSearchController c) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        children: [
          // Specialty active chip
          if (c.specialtyFilter.isNotEmpty) ...[
            _ActiveChip(
              label: c.specialtyFilter,
              onRemove: () => c.setSpecialty(''),
            ),
            const SizedBox(width: 8),
          ],
          // Rating active chip
          if (c.minRating != null) ...[
            _ActiveChip(
              label: '${c.minRating!.toStringAsFixed(1).replaceAll('.0', '')}★+',
              onRemove: () => c.setMinRating(null),
            ),
            const SizedBox(width: 8),
          ],
          // Static inactive chips
          const _InactiveChip(label: 'Còn lịch hôm nay'),
          const SizedBox(width: 8),
          const _InactiveChip(label: 'BHYT'),
        ],
      ),
    );
  }

  // ── Sort row ───────────────────────────────────────────────────────────────

  Widget _buildSortRow(DoctorSearchController c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Row(
        children: [
          Text(
            'Hiển thị ${c.doctors.length}/42 bác sĩ',
            style: IText.body(size: 12, color: IColors.ink3),
          ),
          const Spacer(),
          PopupMenuButton<DoctorCatalogSort>(
            initialValue: c.sort,
            onSelected: c.setSort,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            offset: const Offset(0, 36),
            itemBuilder: (_) => DoctorCatalogSort.values
                .map((s) => PopupMenuItem(
                      value: s,
                      child: Text(_sortLabel(s),
                          style: IText.body(
                              size: 13,
                              weight: FontWeight.w500,
                              color: s == c.sort
                                  ? IColors.primary500
                                  : IColors.ink)),
                    ))
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: IColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: IColors.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_vert_rounded,
                      size: 14, color: IColors.ink2),
                  const SizedBox(width: 4),
                  Text(_sortLabel(c.sort),
                      style: IText.body(
                          size: 12,
                          weight: FontWeight.w600,
                          color: IColors.ink2)),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14, color: IColors.ink3),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleButton(
            size: 34,
            borderColor: IColors.line,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chế độ lưới sắp ra mắt'), duration: Duration(seconds: 1)),
            ),
            child: const Icon(Icons.grid_view_rounded,
                size: 15, color: IColors.ink2),
          ),
        ],
      ),
    );
  }

  // ── Specialty scroll ───────────────────────────────────────────────────────

  Widget _buildSpecialtyScroll(DoctorSearchController c) {
    if (c.specialtyOptions.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
        children: [
          _SpecialtyChip(
            label: 'Tất cả',
            selected: c.specialtyFilter.isEmpty,
            onTap: () => c.setSpecialty(''),
          ),
          ...c.specialtyOptions.map((s) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _SpecialtyChip(
                  label: s,
                  selected: c.specialtyFilter == s,
                  onTap: () => c.setSpecialty(s),
                ),
              )),
        ],
      ),
    );
  }

  // ── Filter bottom sheet (keeps business logic methods accessible) ──────────

  void _showFilterSheet(BuildContext context, DoctorSearchController c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: IColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: IColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Đánh giá tối thiểu',
                style: IText.sectionTitle(color: IColors.ink)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _FilterPill(
                    label: 'Tất cả',
                    selected: c.minRating == null,
                    onTap: () {
                      c.setMinRating(null);
                      Navigator.pop(context);
                    }),
                _FilterPill(
                    label: '≥ 4.0★',
                    selected: c.minRating == 4.0,
                    onTap: () {
                      c.setMinRating(4.0);
                      Navigator.pop(context);
                    }),
                _FilterPill(
                    label: '≥ 4.5★',
                    selected: c.minRating == 4.5,
                    onTap: () {
                      c.setMinRating(4.5);
                      Navigator.pop(context);
                    }),
                _FilterPill(
                    label: '≥ 4.8★',
                    selected: c.minRating == 4.8,
                    onTap: () {
                      c.setMinRating(4.8);
                      Navigator.pop(context);
                    }),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  _searchCtrl.clear();
                  _locationCtrl.clear();
                  c.clearFilters();
                  Navigator.pop(context);
                },
                child: Text('Xóa tất cả bộ lọc',
                    style: IText.body(
                        size: 13.5,
                        color: IColors.danger,
                        weight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Private sub-widgets
// ═══════════════════════════════════════════════════════════════════════════

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, __) {
        return Container(
          height: 52,
          decoration: BoxDecoration(
            color: IColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: IColors.line),
            boxShadow: const [IColors.shadow1],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(Icons.search_rounded,
                  size: 20, color: IColors.primary500),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: IText.body(size: 14, color: IColors.ink),
                  decoration: InputDecoration(
                    hintText: 'Tìm bác sĩ, chuyên khoa...',
                    hintStyle: IText.body(size: 14, color: IColors.ink3),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (value.text.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: IColors.ink3),
                ),
              ],
              Container(
                width: 1,
                height: 22,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: IColors.line,
              ),
              const Icon(Icons.mic_rounded, size: 20, color: IColors.primary500),
              const SizedBox(width: 14),
            ],
          ),
        );
      },
    );
  }
}

// ── Active chip (dark) ─────────────────────────────────────────────────────

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
      decoration: BoxDecoration(
        color: IColors.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: IText.label(size: 11.5, color: IColors.surface)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 14, color: IColors.ink3),
          ),
          const SizedBox(width: 2),
        ],
      ),
    );
  }
}

// ── Inactive chip (white border) ───────────────────────────────────────────

class _InactiveChip extends StatelessWidget {
  final String label;

  const _InactiveChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: IColors.line),
      ),
      child: Text(label, style: IText.label(size: 11.5, color: IColors.ink2)),
    );
  }
}

// ── Specialty chip ─────────────────────────────────────────────────────────

class _SpecialtyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SpecialtyChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? IColors.ink : IColors.surface,
          borderRadius: BorderRadius.circular(999),
          border:
              Border.all(color: selected ? IColors.ink : IColors.line),
        ),
        child: Text(
          label,
          style: IText.label(
              size: 12, color: selected ? IColors.surface : IColors.ink2),
        ),
      ),
    );
  }
}

// ── Filter pill (for bottom sheet) ────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? IColors.ink : IColors.line2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: IText.label(
              size: 12.5,
              color: selected ? IColors.surface : IColors.ink2),
        ),
      ),
    );
  }
}

// ── Circle icon button ─────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final double size;
  final Color borderColor;

  const _CircleButton({
    required this.onTap,
    required this.child,
    this.size = 40,
    this.borderColor = IColors.line,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: IColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

// ── Filled dark button ─────────────────────────────────────────────────────

class _FilledButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _FilledButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: IColors.ink,
          borderRadius: BorderRadius.circular(999),
        ),
        child: child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Doctor Card
// ═══════════════════════════════════════════════════════════════════════════

class _DoctorCard extends StatelessWidget {
  final DoctorEntity doctor;
  final String? distanceLabel;
  final String initials;
  final Color avatarColor;
  final bool isFirst;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.doctor,
    required this.distanceLabel,
    required this.initials,
    required this.avatarColor,
    required this.isFirst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final d = doctor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: IColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: IColors.line),
                boxShadow: const [IColors.shadow1],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top section ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        _buildAvatar(d),
                        const SizedBox(width: 12),
                        // Info
                        Expanded(child: _buildInfo(d)),
                      ],
                    ),
                  ),

                  // ── Hospital strip ───────────────────────────────────────
                  _buildHospitalStrip(d),

                  // ── Slots row ────────────────────────────────────────────
                  _buildSlotsRow(),

                  // ── Fee + CTA ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '350K/lượt',
                              style: IText.num(
                                  size: 14.5,
                                  weight: FontWeight.w800,
                                  color: IColors.ink),
                            ),
                            const SizedBox(height: 2),
                            const IPill.success('BHYT giảm 80%'),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _buildCtaButton()),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Recommended ribbon ───────────────────────────────────────
            if (isFirst) _buildRecommendedRibbon(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(DoctorEntity d) {
    const size = 64.0;
    return SizedBox(
      width: size + 12,
      height: size + 12,
      child: Stack(
        children: [
          // Image or initials
          if (d.imageUrl.isNotEmpty)
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: d.imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (_, __) => _InitialsAvatar(
                    initials: initials, color: avatarColor, size: size),
                errorWidget: (_, __, ___) => _InitialsAvatar(
                    initials: initials, color: avatarColor, size: size),
              ),
            )
          else
            _InitialsAvatar(initials: initials, color: avatarColor, size: size),

          // Verified badge
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: IColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: IColors.surface, width: 2),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(DoctorEntity d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Text(
          'BS · ${d.experience > 0 ? d.experience : '—'}NĂM KN',
          style: IText.label(size: 10, color: IColors.ink3),
        ),
        const SizedBox(height: 4),
        // Name
        Text(
          d.name.isNotEmpty ? d.name : 'Bác sĩ',
          style: const TextStyle(
            fontFamily: IFont.interTight,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: IColors.ink,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        // Specialty
        Text(
          d.specialty.isNotEmpty ? d.specialty : '—',
          style: IText.body(size: 12.5, color: IColors.ink3),
        ),
        const SizedBox(height: 8),
        // Rating row
        _buildRatingRow(d),
      ],
    );
  }

  Widget _buildRatingRow(DoctorEntity d) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFC97B00)),
        const SizedBox(width: 3),
        Text(
          d.rating.toStringAsFixed(1),
          style: IText.num(size: 12.5, weight: FontWeight.w700, color: IColors.ink),
        ),
        const SizedBox(width: 3),
        Text(
          '(${d.totalReviews})',
          style: IText.body(size: 11.5, color: IColors.ink3),
        ),
        if (distanceLabel != null) ...[
          const SizedBox(width: 8),
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: IColors.ink3,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.near_me_rounded, size: 11, color: IColors.ink3),
          const SizedBox(width: 3),
          Text(distanceLabel!,
              style: IText.body(size: 11.5, color: IColors.ink3)),
        ],
      ],
    );
  }

  Widget _buildHospitalStrip(DoctorEntity d) {
    return Container(
      color: IColors.line2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.local_hospital_outlined,
              size: 13, color: IColors.ink3),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              d.displayClinic.isNotEmpty ? d.displayClinic : '—',
              style: IText.body(size: 12, color: IColors.ink2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const IPill.success('BHYT'),
        ],
      ),
    );
  }

  Widget _buildSlotsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          const _SlotChip(label: '09:30'),
          const SizedBox(width: 6),
          const _SlotChip(label: '10:30'),
          const SizedBox(width: 6),
          const _SlotChip(label: '14:00'),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: IColors.warningBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('Sớm nhất T7',
                style: IText.label(
                    size: 10.5, color: IColors.warning)),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [IColors.primary500, IColors.primary700],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Đặt khám →',
          style: IText.label(size: 13, color: IColors.surface),
        ),
      ),
    );
  }

  Widget _buildRecommendedRibbon() {
    return Positioned(
      top: 0,
      right: 0,
      child: ClipRRect(
        borderRadius:
            const BorderRadius.only(topRight: Radius.circular(18)),
        child: CustomPaint(
          size: const Size(88, 88),
          painter: _RibbonPainter(),
          child: SizedBox(
            width: 88,
            height: 88,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 6),
                child: Transform.rotate(
                  angle: 0.785, // 45°
                  child: Text(
                    '★ ĐỀ XUẤT',
                    style: IText.label(
                        size: 8.5, color: IColors.surface),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Initials avatar ────────────────────────────────────────────────────────

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;

  const _InitialsAvatar(
      {required this.initials, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.85), color],
          center: Alignment.topLeft,
          radius: 1.2,
        ),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: IFont.interTight,
          fontSize: size * 0.3,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

// ── Slot chip ──────────────────────────────────────────────────────────────

class _SlotChip extends StatelessWidget {
  final String label;

  const _SlotChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: IColors.successBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: IText.num(
            size: 11, weight: FontWeight.w700, color: IColors.success),
      ),
    );
  }
}

// ── Ribbon painter ─────────────────────────────────────────────────────────

class _RibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFC530), Color(0xFFFFAB00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
