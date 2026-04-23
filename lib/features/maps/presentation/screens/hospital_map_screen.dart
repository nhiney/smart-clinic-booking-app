import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../domain/entities/hospital_entity.dart';
import '../controllers/hospital_map_controller.dart';
import 'package:smart_clinic_booking/features/review/presentation/screens/review_screen.dart';

class HospitalMapScreen extends ConsumerStatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  ConsumerState<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends ConsumerState<HospitalMapScreen> {
  final Completer<GoogleMapController> _googleMapController = Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();

  static const CameraPosition _defaultCenter = CameraPosition(
    target: LatLng(10.7769, 106.7009), // HCMC Center Default
    zoom: 12.0,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController.complete(controller);
  }

  Future<void> _animateToUserLocation() async {
    final state = ref.read(hospitalMapProvider);
    if (state.userLocation != null) {
      final GoogleMapController controller = await _googleMapController.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(state.userLocation!.latitude, state.userLocation!.longitude),
        14.0,
      ));
    }
  }

  Future<void> _routeToHospital(HospitalEntity hospital) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${hospital.lat},${hospital.lng}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở bản đồ chỉ đường.')),
        );
      }
    }
  }

  Set<Marker> _buildMarkers(HospitalMapState state) {
    return state.filteredHospitals.map((hospital) {
      final isSelected = state.selectedHospital?.id == hospital.id;
      return Marker(
        markerId: MarkerId(hospital.id),
        position: LatLng(hospital.lat, hospital.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure,
        ),
        onTap: () {
          ref.read(hospitalMapProvider.notifier).selectHospital(hospital);
          _showHospitalBottomSheet(hospital);
        },
      );
    }).toSet();
  }

  void _showHospitalBottomSheet(HospitalEntity hospital) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(hospital.name, style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(hospital.address, style: AppTextStyles.body)),
              ],
            ),
            const SizedBox(height: 12),
            if (hospital.specialties.isNotEmpty)
              Wrap(
                spacing: 6,
                children: hospital.specialties.map((s) => Chip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.primarySurface,
                )).toList(),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _routeToHospital(hospital),
                icon: const Icon(Icons.directions, color: Colors.white,),
                label: const Text("Chỉ đường", style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewScreen(
                        hospitalId: hospital.id,
                        hospitalName: hospital.name,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.star_outline, color: AppColors.primary),
                label: const Text("Xem đánh giá & nhận xét", style: TextStyle(color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).whenComplete(() {
      ref.read(hospitalMapProvider.notifier).selectHospital(null);
    });
  }

  Widget _filterChip(String label, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.primary),
        selected: isSelected,
        onSelected: (val) {},
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[200]!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hospitalMapProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandedAppBar(
        title: "Tìm bệnh viện gần nhất",
        showBackButton: true,
      ),
      body: state.isLoading
          ? const LoadingWidget(itemCount: 1)
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _defaultCenter,
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: _buildMarkers(state),
                  onTap: (_) => ref.read(hospitalMapProvider.notifier).selectHospital(null),
                ),
                
                // Search & Filter Bar
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => ref.read(hospitalMapProvider.notifier).searchHospitals(val),
                          decoration: InputDecoration(
                            hintText: 'Tìm theo tên hoặc chuyên khoa...',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _filterChip('Tất cả', Icons.all_inclusive_rounded, true),
                            _filterChip('Đa khoa', Icons.local_hospital_rounded, false),
                            _filterChip('Nhi khoa', Icons.child_care_rounded, false),
                            _filterChip('Răng hàm mặt', Icons.medical_services_rounded, false),
                            _filterChip('Mắt', Icons.visibility_rounded, false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Locate Me Button
                Positioned(
                  bottom: 120, // Leave space for horizontal list if needed
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: "nearby_fab",
                        backgroundColor: AppColors.primary,
                        onPressed: () => ref.read(hospitalMapProvider.notifier).findNearby(),
                        child: const Icon(Icons.near_me, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        heroTag: "locate_fab",
                        backgroundColor: Colors.white,
                        onPressed: _animateToUserLocation,
                        child: const Icon(Icons.my_location, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

                // Bottom Horizontal List
                if (state.filteredHospitals.isNotEmpty)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.filteredHospitals.length,
                      itemBuilder: (context, index) {
                        final hospital = state.filteredHospitals[index];
                        final isSelected = state.selectedHospital?.id == hospital.id;
                        
                        return GestureDetector(
                          onTap: () async {
                            ref.read(hospitalMapProvider.notifier).selectHospital(hospital);
                            final GoogleMapController controller = await _googleMapController.future;
                            controller.animateCamera(CameraUpdate.newLatLng(LatLng(hospital.lat, hospital.lng)));
                            _showHospitalBottomSheet(hospital);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 280,
                            margin: const EdgeInsets.only(right: 12, bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(16),
                                    image: const DecorationImage(
                                      image: NetworkImage('https://images.unsplash.com/photo-1587350859728-117698f4eac0?q=80&w=200&auto=format&fit=crop'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        hospital.name, 
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                        maxLines: 1, 
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                                          const SizedBox(width: 4),
                                          Text('4.8', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                                          const SizedBox(width: 8),
                                          Container(
                                            height: 12,
                                            width: 1,
                                            color: Colors.grey[300],
                                          ),
                                          const SizedBox(width: 8),
                                          Text('Đang mở cửa', style: TextStyle(fontSize: 12, color: Colors.green[600], fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        hospital.address,
                                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Error Overlay
                if (state.error != null)
                  Positioned(
                    top: 80,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        state.error!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
