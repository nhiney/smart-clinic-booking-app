import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_clinic_booking/core/theme/icare_tokens.dart';
import '../../data/datasources/doctor_remote_datasource.dart';
import '../../data/models/doctor_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Patient → Tìm bác sĩ — Full Search / Filter Screen
// ═══════════════════════════════════════════════════════════════════════════

class PatientFindDoctorScreen extends StatefulWidget {
  const PatientFindDoctorScreen({super.key});

  @override
  State<PatientFindDoctorScreen> createState() => _PatientFindDoctorScreenState();
}

class _PatientFindDoctorScreenState extends State<PatientFindDoctorScreen> {
  final _searchCtrl = TextEditingController();
  bool _showClear = false;

  final _activeFilters = <String>[];
  final _inactiveFilters = ['Còn lịch hôm nay', 'BHYT', '<5km', '4.5★+'];

  // Dữ liệu thật từ Firestore.
  final _ds = DoctorRemoteDatasource();
  List<DoctorModel> _doctors = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _ds.getDoctors();
      list.sort((a, b) => b.rating.compareTo(a.rating));
      if (mounted) {
        setState(() {
          _doctors = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<DoctorModel> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _doctors;
    return _doctors.where((d) {
      return d.name.toLowerCase().contains(q) ||
          d.specialty.toLowerCase().contains(q) ||
          d.hospital.toLowerCase().contains(q);
    }).toList();
  }

  // Màu avatar ổn định theo tên.
  Color _avatarColor(String name) {
    const palette = [
      Color(0xFF1565C0), Color(0xFFD43F75), Color(0xFF5B47D6),
      Color(0xFF0F9D58), Color(0xFFE8710A), Color(0xFF00838F),
    ];
    return palette[name.hashCode.abs() % palette.length];
  }

  String _initials(String name) {
    final parts = name.replaceAll(RegExp(r'(BS\.?|TS\.?|PGS\.?|GS\.?|CK\s?I*I*\.?)', caseSensitive: false), '')
        .trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[parts.length - 2].characters.first +
            parts.last.characters.first)
        .toUpperCase();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            _buildSortRow(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ─── Body (dữ liệu thật) ─────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 52, color: IColors.ink3),
              const SizedBox(height: 12),
              Text('Không tải được danh sách bác sĩ.\n$_error',
                  textAlign: TextAlign.center,
                  style: IText.body(size: 13, color: IColors.ink2)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDoctors,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    final docs = _filtered;
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_search_rounded, size: 52, color: IColors.ink3),
            const SizedBox(height: 12),
            Text(
                _doctors.isEmpty
                    ? 'Chưa có dữ liệu bác sĩ'
                    : 'Không tìm thấy bác sĩ phù hợp',
                style: IText.body(size: 15, color: IColors.ink2)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _realDoctorCard(docs[i], i == 0),
    );
  }

  Widget _realDoctorCard(DoctorModel d, bool isTop) {
    return _buildDoctorCard(
      isTop: isTop,
      doctorId: d.id,
      name: d.name,
      specialty: d.specialty.isEmpty ? 'Đa khoa' : d.specialty,
      degree: d.experience >= 20
          ? 'PGS.TS'
          : d.experience >= 10
              ? 'TS.BS'
              : 'BS',
      years: d.experience,
      langs: 'VI',
      rating: d.rating,
      reviewCount: d.totalReviews,
      distance: d.distanceKm ?? 0,
      hospital: d.hospital.isEmpty ? 'Phòng khám ICare' : d.hospital,
      bhytRange: 'GD1–GD5',
      slots: const [],
      soonest: null,
      slotCount: 0,
      price: 200000,
      bhytDiscount: 80,
      avatarColor: _avatarColor(d.name),
      initials: _initials(d.name),
      imageUrl: d.imageUrl,
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: IColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: IColors.line),
                boxShadow: IColors.cardShadow,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: IColors.ink),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tìm bác sĩ', style: IText.display(size: 20, color: IColors.ink)),
                Text(
                    _loading
                        ? 'Đang tải...'
                        : '${_doctors.length} bác sĩ · ${_doctors.map((d) => d.specialty).where((s) => s.isNotEmpty).toSet().length} chuyên khoa',
                    style: IText.body(size: 12, color: IColors.ink3)),
              ],
            ),
          ),
          // Filter button with badge
          Stack(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: IColors.ink,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: IColors.cardShadow,
                ),
                child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
              ),
              Positioned(
                right: -2, top: -2,
                child: Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    color: IColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: IColors.bg, width: 1.5),
                  ),
                  child: const Center(child: Text('3', style: TextStyle(
                    fontFamily: IFont.inter, fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white,
                  ))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: IColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: IColors.line),
          boxShadow: IColors.cardShadow,
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(Icons.search_rounded, color: IColors.primary500, size: 22),
            ),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: IText.body(size: 14, weight: FontWeight.w500, color: IColors.ink),
                onChanged: (v) => setState(() => _showClear = v.isNotEmpty),
                decoration: InputDecoration(
                  hintText: 'Tên bác sĩ, chuyên khoa, bệnh viện...',
                  hintStyle: IText.body(size: 14, color: IColors.ink3),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_showClear)
              GestureDetector(
                onTap: () => setState(() { _searchCtrl.clear(); _showClear = false; }),
                child: Container(
                  width: 22, height: 22,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(color: IColors.ink200, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 13),
                ),
              ),
            Container(width: 1, height: 22, color: IColors.line, margin: const EdgeInsets.symmetric(horizontal: 4)),
            GestureDetector(
              onTap: () { HapticFeedback.lightImpact(); },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(Icons.mic_rounded, color: IColors.primary500, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Filter Chips ─────────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 0, 0),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            ..._activeFilters.map((f) => _activeChip(f)),
            ..._inactiveFilters.map((f) => _inactiveChip(f)),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _activeChip(String label) {
    return GestureDetector(
      onTap: () => setState(() => _activeFilters.remove(label)),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: IColors.ink,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: IText.body(size: 12.5, weight: FontWeight.w600, color: Colors.white)),
          const SizedBox(width: 6),
          const Icon(Icons.close_rounded, color: Colors.white60, size: 14),
        ]),
      ),
    );
  }

  Widget _inactiveChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: IColors.line),
      ),
      child: Center(child: Text(label, style: IText.body(size: 12.5, weight: FontWeight.w500, color: IColors.ink2))),
    );
  }

  // ─── Sort Row ─────────────────────────────────────────────────────────────────
  void _showSortSheet(BuildContext context) {
    final options = ['Đánh giá cao nhất', 'Gần nhất', 'Kinh nghiệm nhiều nhất', 'Phí thấp nhất'];
    showModalBottomSheet(
      context: context,
      backgroundColor: IColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: IColors.line, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Sắp xếp theo', style: IText.body(size: 16, weight: FontWeight.w700, color: IColors.ink)),
          const SizedBox(height: 12),
          ...options.map((o) => ListTile(
            dense: true,
            leading: const Icon(Icons.check_circle_outline_rounded, color: IColors.primary500, size: 20),
            title: Text(o, style: IText.body(size: 14, color: IColors.ink)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã sắp xếp: $o'), duration: const Duration(seconds: 1)),
              );
            },
          )),
        ]),
      ),
    );
  }

  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        children: [
          Text('Hiển thị ${_filtered.length}/${_doctors.length} bác sĩ',
              style: IText.body(size: 12.5, color: IColors.ink3)),
          const Spacer(),
          GestureDetector(
            onTap: () => _showSortSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: IColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: IColors.line),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Đánh giá cao', style: IText.body(size: 12, weight: FontWeight.w600, color: IColors.ink)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: IColors.ink),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: IColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: IColors.line),
            ),
            child: const Icon(Icons.map_outlined, size: 18, color: IColors.ink2),
          ),
        ],
      ),
    );
  }

  // ─── Doctor Card ─────────────────────────────────────────────────────────────
  Widget _buildDoctorCard({
    required bool isTop,
    required String name,
    required String specialty,
    required String degree,
    required int years,
    required String langs,
    required double rating,
    required int reviewCount,
    required double distance,
    required String hospital,
    required String bhytRange,
    required List<String> slots,
    String? soonest,
    required int slotCount,
    required int price,
    required int bhytDiscount,
    required Color avatarColor,
    required String initials,
    String doctorId = '',
    String? imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isTop) const SizedBox(height: 2),
                // Doctor meta row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Stack(children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [avatarColor.withValues(alpha: 0.7), avatarColor],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(
                            color: avatarColor.withValues(alpha: 0.3),
                            blurRadius: 12, offset: const Offset(0, 4),
                          )],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: (imageUrl != null && imageUrl.isNotEmpty)
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                    child: Text(initials,
                                        style: const TextStyle(
                                            fontFamily: IFont.interTight,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white))),
                              )
                            : Center(child: Text(initials, style: const TextStyle(
                                fontFamily: IFont.interTight, fontSize: 20,
                                fontWeight: FontWeight.w800, color: Colors.white,
                              ))),
                      ),
                      Positioned(
                        right: -1, bottom: -1,
                        child: Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: IColors.success, shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 11),
                        ),
                      ),
                    ]),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Degree + years + langs
                        Text(
                          'BS · $years NĂM KN · $langs',
                          style: IText.label(size: 10, color: IColors.ink3),
                        ),
                        const SizedBox(height: 4),
                        Text(name, style: IText.body(size: 15.5, weight: FontWeight.w700, color: IColors.ink)),
                        Text(specialty, style: IText.body(size: 12.5, color: IColors.ink3)),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.star_rounded, size: 13, color: IColors.amber),
                          const SizedBox(width: 3),
                          Text('$rating', style: IText.num(size: 12, color: IColors.ink, weight: FontWeight.w700)),
                          Text(' ($reviewCount)', style: IText.label(size: 11, color: IColors.ink3)),
                          Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 3, height: 3, decoration: const BoxDecoration(color: IColors.ink200, shape: BoxShape.circle)),
                          const Icon(Icons.location_on_rounded, size: 12, color: IColors.ink3),
                          const SizedBox(width: 2),
                          Text('${distance}km', style: IText.label(size: 11, color: IColors.ink3)),
                        ]),
                      ],
                    )),
                  ],
                ),
                const SizedBox(height: 12),

                // Hospital strip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: IColors.line2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    const Icon(Icons.local_hospital_rounded, size: 14, color: IColors.primary500),
                    const SizedBox(width: 7),
                    Expanded(child: Text(hospital, style: IText.body(size: 12.5, weight: FontWeight.w600, color: IColors.ink))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: IColors.successBg,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text('BHYT $bhytRange', style: IText.label(size: 9.5, color: IColors.success)),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),

                // Slots OR warning
                if (slots.isNotEmpty) ...[
                  Row(children: [
                    Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(color: IColors.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text('Còn $slotCount slot hôm nay', style: IText.body(size: 12, weight: FontWeight.w600, color: IColors.success)),
                    const Spacer(),
                    ...slots.map((t) => Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: IColors.successBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: IColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Text(t, style: IText.num(size: 11.5, color: IColors.success, weight: FontWeight.w700)),
                    )),
                  ]),
                ] else if (soonest != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: IColors.warningBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: IColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: IColors.warning),
                      const SizedBox(width: 6),
                      Text('Hết slot hôm nay · ', style: IText.body(size: 12, color: IColors.warning)),
                      Text('Sớm nhất: $soonest', style: IText.body(size: 12, weight: FontWeight.w700, color: IColors.warning)),
                    ]),
                  ),
                ],
                const SizedBox(height: 12),

                // Divider
                const Divider(color: IColors.line, height: 1),
                const SizedBox(height: 12),

                // Fee + CTA
                Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      '${price ~/ 1000}.000đ/lượt',
                      style: IText.num(size: 16, weight: FontWeight.w800, color: IColors.ink),
                    ),
                    Text(
                      'BHYT giảm $bhytDiscount% → ${(price * (100 - bhytDiscount) ~/ 100000)}K',
                      style: IText.body(size: 11.5, color: IColors.success, weight: FontWeight.w600),
                    ),
                  ]),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.push('/doctor/profile-booking', extra: doctorId);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [IColors.primary500, IColors.primary700],
                          begin: Alignment.centerLeft, end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(
                          color: IColors.primary500.withValues(alpha: 0.35),
                          blurRadius: 12, offset: const Offset(0, 4),
                        )],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Đặt khám', style: IText.body(size: 13.5, weight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(width: 5),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                      ]),
                    ),
                  ),
                ]),
              ],
            ),
          ),

          // "★ ĐỀ XUẤT" ribbon for top card
          if (isTop)
            Positioned(
              right: 0, top: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(14),
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFC97B00), Color(0xFFB45309)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 11),
                    const SizedBox(width: 4),
                    Text('ĐỀ XUẤT', style: IText.label(size: 10, color: Colors.white)),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
