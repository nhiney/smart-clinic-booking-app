import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/hospital_entity.dart';
import '../controllers/hospital_map_controller.dart';

// ── Google Maps–inspired color palette ───────────────────────────────────────
const Color _kBlue       = Color(0xFF1A73E8); // Google Blue
const Color _kBlueSurf   = Color(0xFFE8F0FE); // Google Blue surface
const Color _kGreen      = Color(0xFF34A853); // Google Green (open)
const Color _kRed        = Color(0xFFEA4335); // Google Red (closed / hospital)
const Color _kYellow     = Color(0xFFFBBC04); // Google Yellow (star)
const Color _kSearchBg   = Color(0xFFF1F3F4); // Google search bar grey
const Color _kDivider    = Color(0xFFE8EAED); // Google divider
const Color _kText1      = Color(0xFF202124); // Google primary text
const Color _kText2      = Color(0xFF5F6368); // Google secondary text
const Color _kTextLight  = Color(0xFF9AA0A6); // Google hint text

class HospitalMapScreen extends ConsumerStatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  ConsumerState<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends ConsumerState<HospitalMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();

  bool _isMapReady = false;
  bool _panelOpen  = true;

  static const double _kPanelW = 300.0;
  static const LatLng _kCenter = LatLng(10.7769, 106.7009);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _mapController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Camera ────────────────────────────────────────────────────────────────

  void _fitCamera(List<HospitalEntity> list) {
    if (list.isEmpty || !_isMapReady) return;
    if (list.length == 1) {
      _mapController.move(LatLng(list.first.lat, list.first.lng), 15);
      return;
    }
    final bounds = LatLngBounds.fromPoints(list.map((h) => LatLng(h.lat, h.lng)).toList());
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)));
  }

  void _goToUser() {
    final loc = ref.read(hospitalMapProvider).userLocation;
    if (loc == null) return;
    _mapController.move(LatLng(loc.latitude, loc.longitude), 15);
  }

  void _zoomIn()  => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
  void _zoomOut() => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);

  Future<void> _openDirections(HospitalEntity h) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${h.lat},${h.lng}');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── Bottom sheet ──────────────────────────────────────────────────────────

  void _showSheet(HospitalEntity h) {
    final dist   = ref.read(hospitalMapProvider).distanceTo(h);
    final router = GoRouter.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HospitalSheet(
        hospital: h,
        distance: dist,
        onDirections: () => _openDirections(h),
        onBook:   () { Navigator.pop(context); router.push('/booking'); },
        onDetail: () { Navigator.pop(context); router.push('/hospital/detail/${h.id}'); },
      ),
    ).whenComplete(() => ref.read(hospitalMapProvider.notifier).selectHospital(null));
  }

  // ── Specialty chip ────────────────────────────────────────────────────────

  Widget _chip(String label, IconData icon, bool active) => GestureDetector(
    onTap: () => ref.read(hospitalMapProvider.notifier).filterBySpecialty(label),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? _kBlue : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? _kBlue : _kDivider, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: active ? Colors.white : _kText2),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
            color: active ? Colors.white : _kText2)),
      ]),
    ),
  );


  // ── Left panel ────────────────────────────────────────────────────────────

  Widget _buildPanel(HospitalMapState state) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: Container(
        width: _kPanelW,
        color: Colors.white,
        child: Column(children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(4, 10, 8, 6),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                color: _kText2,
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              const Expanded(
                child: Text('Tìm bệnh viện',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _kText1)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: _kTextLight,
                onPressed: () => setState(() => _panelOpen = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ]),
          ),

          // ── Search bar (Google Maps style) ───────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _kSearchBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => ref.read(hospitalMapProvider.notifier).searchHospitals(v),
              style: const TextStyle(fontSize: 14, color: _kText1),
              decoration: InputDecoration(
                hintText: 'Tìm bệnh viện, chuyên khoa...',
                hintStyle: const TextStyle(color: _kTextLight, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: _kText2, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16, color: _kTextLight),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(hospitalMapProvider.notifier).searchHospitals('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // ── Category chips (Google Maps style) ───────────────────────────
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip('Tất cả',   Icons.all_inclusive_rounded,   state.activeFilter == 'Tất cả'),
                _chip('Đa khoa',  Icons.local_hospital_rounded,  state.activeFilter == 'Đa khoa'),
                _chip('Nhi khoa', Icons.child_care_rounded,      state.activeFilter == 'Nhi khoa'),
                _chip('Răng',     Icons.medical_services_rounded, state.activeFilter == 'Răng hàm mặt'),
                _chip('Mắt',      Icons.visibility_rounded,      state.activeFilter == 'Mắt'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: _kDivider),

          // ── Hospital list ─────────────────────────────────────────────────
          Expanded(child: _buildList(state)),

          // ── Footer ───────────────────────────────────────────────────────
          Divider(height: 1, color: _kDivider),
          _buildFooter(state),
        ]),
      ),
    );
  }

  // ── Hospital list ─────────────────────────────────────────────────────────

  Widget _buildList(HospitalMapState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: _kBlue));
    }
    if (state.filteredHospitals.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off_rounded, size: 44, color: _kDivider),
          const SizedBox(height: 8),
          const Text('Không tìm thấy bệnh viện',
              style: TextStyle(color: _kTextLight, fontSize: 13)),
        ]),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: state.filteredHospitals.length,
      separatorBuilder: (_, __) => Divider(height: 1, indent: 68, color: _kDivider),
      itemBuilder: (_, i) => _buildItem(state.filteredHospitals[i], state),
    );
  }

  Widget _buildItem(HospitalEntity h, HospitalMapState state) {
    final sel  = state.selectedHospital?.id == h.id;
    final dist = state.distanceTo(h);

    return InkWell(
      onTap: () {
        ref.read(hospitalMapProvider.notifier).selectHospital(h);
        _mapController.move(LatLng(h.lat, h.lng), 15);
        _showSheet(h);
      },
      child: Container(
        color: sel ? _kBlueSurf : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          // Google Maps–style "H" badge: red rounded square
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: h.isOpen ? _kRed : const Color(0xFF757575),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('H',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                      fontSize: 20, height: 1)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.name,
                  style: TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13,
                      color: sel ? _kBlue : _kText1),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Row(children: [
                Container(width: 6, height: 6,
                    decoration: BoxDecoration(
                        color: h.isOpen ? _kGreen : _kRed, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(h.isOpen ? 'Mở cửa' : 'Đóng cửa',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                        color: h.isOpen ? _kGreen : _kRed)),
                if (dist != null) ...[
                  Text(' · ', style: const TextStyle(color: _kTextLight, fontSize: 11)),
                  Text(dist < 1 ? '${(dist * 1000).toInt()}m' : '${dist.toStringAsFixed(1)}km',
                      style: const TextStyle(fontSize: 11, color: _kText2)),
                ],
                Text(' · ', style: const TextStyle(color: _kTextLight, fontSize: 11)),
                const Icon(Icons.star_rounded, size: 11, color: _kYellow),
                const SizedBox(width: 2),
                Text(h.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 11, color: _kText2)),
              ]),
              if (h.specialties.isNotEmpty)
                Text(h.specialties.take(2).join(', '),
                    style: const TextStyle(fontSize: 11, color: _kTextLight),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: _kTextLight, size: 18),
        ]),
      ),
    );
  }

  // ── Panel footer ──────────────────────────────────────────────────────────

  Widget _buildFooter(HospitalMapState state) {
    final open  = state.filteredHospitals.where((h) => h.isOpen).length;
    final total = state.filteredHospitals.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: _kBlueSurf, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.local_hospital_rounded, color: _kBlue, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$total bệnh viện trong khu vực',
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: _kText1)),
            Text('$open đang mở cửa',
                style: const TextStyle(fontSize: 11, color: _kText2)),
          ]),
        ),
        if (state.isNearbyActive)
          GestureDetector(
            onTap: () => ref.read(hospitalMapProvider.notifier).clearNearby(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _kBlueSurf, borderRadius: BorderRadius.circular(8)),
              child: const Text('Xoá lọc',
                  style: TextStyle(fontSize: 11, color: _kBlue, fontWeight: FontWeight.w600)),
            ),
          ),
      ]),
    );
  }


  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hospitalMapProvider);

    ref.listen<HospitalMapState>(hospitalMapProvider, (prev, next) {
      if (prev?.filteredHospitals != next.filteredHospitals &&
          next.filteredHospitals.isNotEmpty && _isMapReady) {
        Future.microtask(() => _fitCamera(next.filteredHospitals));
      }
    });

    return Scaffold(
      body: Stack(children: [
        // ── Full-screen map ──────────────────────────────────────────────
        Positioned.fill(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _kCenter,
              initialZoom: 12.0,
              minZoom: 5,
              maxZoom: 19,
              onMapReady: () {
                setState(() => _isMapReady = true);
                Future.delayed(const Duration(milliseconds: 400), () =>
                    _fitCamera(ref.read(hospitalMapProvider).filteredHospitals));
              },
              onTap: (_, __) {
                if (_panelOpen) {
                  setState(() => _panelOpen = false);
                } else {
                  ref.read(hospitalMapProvider.notifier).selectHospital(null);
                }
              },
            ),
            children: [
              // CartoDB Voyager — free tiles closest to Google Maps look
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.smartClinicBooking',
                maxNativeZoom: 19,
              ),

              // 5 km radius circle
              if (state.isNearbyActive && state.userLocation != null)
                CircleLayer(circles: [
                  CircleMarker(
                    point: LatLng(state.userLocation!.latitude, state.userLocation!.longitude),
                    radius: 5000,
                    useRadiusInMeter: true,
                    color: _kBlue.withValues(alpha: 0.07),
                    borderColor: _kBlue.withValues(alpha: 0.5),
                    borderStrokeWidth: 2,
                  ),
                ]),

              // Hospital markers
              MarkerLayer(
                markers: state.filteredHospitals.map((h) {
                  final sel = state.selectedHospital?.id == h.id;
                  return Marker(
                    point: LatLng(h.lat, h.lng),
                    width:  sel ? 46 : 38,
                    height: sel ? 56 : 46,
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(hospitalMapProvider.notifier).selectHospital(h);
                        _showSheet(h);
                      },
                      child: _HospitalMarker(isOpen: h.isOpen, isSelected: sel),
                    ),
                  );
                }).toList(),
              ),

              // Attribution (required by CartoDB & OSM)
              RichAttributionWidget(
                animationConfig: const ScaleRAWA(),
                attributions: [
                  TextSourceAttribution('© CARTO',
                      onTap: () => launchUrl(Uri.parse('https://carto.com/attributions'))),
                  TextSourceAttribution('© OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright'))),
                ],
              ),
            ],
          ),
        ),

        // ── Safe-area overlays ───────────────────────────────────────────
        SafeArea(
          child: Stack(children: [
            // Left panel
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              left:   _panelOpen ? 0 : -(_kPanelW + 16),
              top: 0, bottom: 0,
              child: SizedBox(width: _kPanelW, child: _buildPanel(state)),
            ),

            // Search/menu open button (Google Maps hamburger style)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              left: _panelOpen ? -54 : 10,
              top: 10,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                elevation: 3,
                shadowColor: Colors.black26,
                child: InkWell(
                  onTap: () => setState(() => _panelOpen = true),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 46, height: 46,
                    alignment: Alignment.center,
                    child: const Icon(Icons.menu_rounded, color: _kText2, size: 22),
                  ),
                ),
              ),
            ),

            // Nearby active banner (Google Blue)
            if (state.isNearbyActive)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOut,
                top: 10,
                left: _panelOpen ? _kPanelW + 8 : 64,
                right: 58,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kBlue,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: _kBlue.withValues(alpha: 0.3), blurRadius: 8)],
                  ),
                  child: Row(children: [
                    const Icon(Icons.near_me_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text('Bán kính 5 km',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(hospitalMapProvider.notifier).clearNearby(),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 15),
                    ),
                  ]),
                ),
              ),

            // Right controls (Google Maps zoom cluster style)
            Positioned(
              right: 10,
              bottom: 32,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                elevation: 2,
                shadowColor: Colors.black26,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  _squareBtn(Icons.add, _zoomIn),
                  Divider(height: 1, color: _kDivider),
                  _squareBtn(Icons.remove, _zoomOut),
                ]),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 130,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _roundBtn(Icons.my_location_rounded, _goToUser, _kBlue),
                const SizedBox(height: 8),
                _roundBtn(
                  Icons.near_me_rounded,
                  () => ref.read(hospitalMapProvider.notifier).findNearby(),
                  Colors.white,
                  iconColor: _kBlue,
                ),
              ]),
            ),

            // Error
            if (state.error != null)
              Positioned(
                top: 10,
                left: _panelOpen ? _kPanelW + 8 : 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kRed.withValues(alpha: 0.93),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(state.error!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center),
                ),
              ),
          ]),
        ),
      ]),
    );
  }

  // ── Google Maps–style zoom button (square, joined) ────────────────────────
  Widget _squareBtn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: SizedBox(width: 40, height: 40,
        child: Icon(icon, color: _kText2, size: 20)),
  );

  // ── Google Maps–style round FAB button ────────────────────────────────────
  Widget _roundBtn(IconData icon, VoidCallback onTap, Color bg, {Color iconColor = Colors.white}) =>
      Material(
        color: bg,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(width: 44, height: 44,
              child: Icon(icon, color: iconColor, size: 22)),
        ),
      );
}

// ── Hospital marker widget ────────────────────────────────────────────────────

class _HospitalMarker extends StatelessWidget {
  final bool isOpen;
  final bool isSelected;
  const _HospitalMarker({required this.isOpen, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    // Google Maps uses red for hospital H-markers regardless of open/closed
    final color = isSelected ? const Color(0xFFC62828) : _kRed;
    final size  = isSelected ? 38.0 : 32.0;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // H badge
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isSelected ? 0.5 : 0.3),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text('H',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                  fontSize: isSelected ? 22 : 18, height: 1)),
        ),
      ),
      // Pin tip (triangle)
      CustomPaint(size: const Size(10, 6), painter: _TipPainter(color)),
    ]);
  }
}

class _TipPainter extends CustomPainter {
  final Color color;
  const _TipPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
    Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width / 2, size.height)..close(),
    Paint()..color = color,
  );
  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Hospital bottom sheet ─────────────────────────────────────────────────────

class _HospitalSheet extends StatelessWidget {
  final HospitalEntity hospital;
  final double?        distance;
  final VoidCallback   onDirections;
  final VoidCallback   onBook;
  final VoidCallback   onDetail;

  const _HospitalSheet({
    required this.hospital, required this.distance,
    required this.onDirections, required this.onBook, required this.onDetail,
  });

  String get _dist {
    if (distance == null) return '';
    return distance! < 1 ? '${(distance! * 1000).toInt()}m' : '${distance!.toStringAsFixed(1)}km';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 2),
          width: 32, height: 4,
          decoration: BoxDecoration(color: _kDivider, borderRadius: BorderRadius.circular(2)),
        ),
        // Cover image
        if (hospital.imageUrl?.isNotEmpty == true)
          ClipRRect(
            child: Image.network(hospital.imageUrl!,
                height: 130, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox()),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Name + distance
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(hospital.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _kText1)),
              ),
              if (distance != null)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: _kBlueSurf, borderRadius: BorderRadius.circular(20)),
                  child: Text(_dist,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kBlue)),
                ),
            ]),
            const SizedBox(height: 8),
            // Status row
            Row(children: [
              Container(width: 7, height: 7,
                  decoration: BoxDecoration(
                      color: hospital.isOpen ? _kGreen : _kRed, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(hospital.isOpen ? 'Đang mở cửa' : 'Đã đóng cửa',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: hospital.isOpen ? _kGreen : _kRed)),
              const SizedBox(width: 12),
              const Icon(Icons.star_rounded, size: 14, color: _kYellow),
              const SizedBox(width: 2),
              Text(hospital.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _kText1)),
            ]),
            const SizedBox(height: 10),
            _row(Icons.location_on_outlined, hospital.address),
            if (hospital.workingHours?.isNotEmpty == true) ...[
              const SizedBox(height: 5),
              _row(Icons.access_time_rounded, hospital.workingHours!),
            ],
            if (hospital.phone?.isNotEmpty == true) ...[
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse('tel:${hospital.phone}');
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
                child: Row(children: [
                  const Icon(Icons.phone_outlined, size: 14, color: _kBlue),
                  const SizedBox(width: 6),
                  Text(hospital.phone!,
                      style: const TextStyle(fontSize: 13, color: _kBlue, fontWeight: FontWeight.w500)),
                ]),
              ),
            ],
            if (hospital.specialties.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6,
                children: hospital.specialties.map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kSearchBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _kDivider),
                  ),
                  child: Text(s, style: const TextStyle(fontSize: 11, color: _kText2)),
                )).toList(),
              ),
            ],
            const SizedBox(height: 18),
            // Action buttons (Google Maps style)
            Row(children: [
              Expanded(child: _btn(Icons.directions_rounded, 'Chỉ đường', _kBlue, onDirections)),
              const SizedBox(width: 10),
              Expanded(child: _btn(Icons.calendar_month_rounded, 'Đặt lịch', _kGreen, onBook)),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDetail,
                icon: const Icon(Icons.info_outline_rounded, size: 16, color: _kBlue),
                label: const Text('Xem chi tiết', style: TextStyle(color: _kBlue, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  side: const BorderSide(color: _kBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _row(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 14, color: _kTextLight),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: _kText2))),
    ],
  );

  Widget _btn(IconData icon, String label, Color color, VoidCallback onTap) =>
      ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 16),
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 11),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
}
