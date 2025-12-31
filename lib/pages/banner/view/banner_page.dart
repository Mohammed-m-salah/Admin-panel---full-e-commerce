import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../data/model/banner_model.dart';
import '../logic/cubit/banner_cubit.dart';
import '../logic/cubit/banner_state.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// صفحة إدارة البانرات - Banner Management Page
// ═══════════════════════════════════════════════════════════════════════════════

class BannerPage extends StatefulWidget {
  const BannerPage({super.key});

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _viewMode = 'grid';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // فلترة البانرات
  List<BannerModel> _filterBanners(List<BannerModel> banners) {
    return banners.where((banner) {
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = banner.title.toLowerCase();
        final description = banner.description?.toLowerCase() ?? '';
        matchesSearch = title.contains(query) || description.contains(query);
      }

      bool matchesStatus = true;
      if (_statusFilter != 'All') {
        matchesStatus =
            banner.status.toLowerCase() == _statusFilter.toLowerCase();
      }

      return matchesSearch && matchesStatus;
    }).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocConsumer<BannerCubit, BannerState>(
        listener: (context, state) {
          if (state is BannerAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Banner added successfully!'),
                  backgroundColor: Color(0xFF10B981)),
            );
          } else if (state is BannerUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Banner updated successfully!'),
                  backgroundColor: Color(0xFF10B981)),
            );
          } else if (state is BannerDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Banner deleted successfully!'),
                  backgroundColor: Color(0xFFEF4444)),
            );
          } else if (state is BannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final banners = context.read<BannerCubit>().banners;
          final filteredBanners = _filterBanners(banners);

          return Column(
            children: [
              _buildHeader(context),
              Expanded(
                  child:
                      _buildContent(context, state, banners, filteredBanners)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF5542F6), Color(0xFF7C3AED)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.photo_library_outlined,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Banners Management',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937))),
              Text('Manage promotional banners displayed on your store',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showAddBannerDialog(context),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add New Banner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5542F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, BannerState state,
      List<BannerModel> banners, List<BannerModel> filteredBanners) {
    if (state is BannerLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF5542F6)),
            SizedBox(height: 16),
            Text('Loading banners...'),
          ],
        ),
      );
    }

    if (state is BannerError && banners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<BannerCubit>().loadBanners(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatCard(
                  title: 'Total Banners',
                  value: banners.length.toString(),
                  icon: Icons.photo_library_outlined,
                  color: const Color(0xFF5542F6),
                  subtitle: 'All banners'),
              const SizedBox(width: 20),
              _buildStatCard(
                  title: 'Active Now',
                  value: banners
                      .where((b) => b.status == 'active')
                      .length
                      .toString(),
                  icon: Icons.play_circle_outline,
                  color: const Color(0xFF10B981),
                  subtitle: 'Currently displayed'),
              const SizedBox(width: 20),
              _buildStatCard(
                  title: 'Total Views',
                  value: _formatNumber(
                      banners.fold<int>(0, (sum, b) => sum + b.views)),
                  icon: Icons.visibility_outlined,
                  color: const Color(0xFF3B82F6),
                  subtitle: 'All time views'),
              const SizedBox(width: 20),
              _buildStatCard(
                  title: 'Total Clicks',
                  value: _formatNumber(
                      banners.fold<int>(0, (sum, b) => sum + b.clicks)),
                  icon: Icons.touch_app_outlined,
                  color: const Color(0xFFF59E0B),
                  subtitle: 'All time clicks'),
            ],
          ),
          const SizedBox(height: 24),
          _buildSearchAndFilterBar(),
          const SizedBox(height: 24),
          if (filteredBanners.isEmpty)
            _buildEmptyState()
          else if (_viewMode == 'grid')
            _buildGridView(filteredBanners)
          else
            _buildListView(filteredBanners),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color,
      required String subtitle}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937))),
                  const SizedBox(height: 4),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280))),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search banners...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon:
                            Icon(Icons.close_rounded, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        })
                    : null,
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: ['All', 'active', 'inactive', 'scheduled'].map((status) {
                  return DropdownMenuItem(
                      value: status,
                      child: Row(children: [
                        Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: _getStatusColor(status),
                                shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(status == 'All'
                            ? 'All'
                            : status[0].toUpperCase() + status.substring(1)),
                      ]));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _statusFilter = value ?? 'All'),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              _buildViewModeButton(Icons.grid_view_rounded, 'grid'),
              _buildViewModeButton(Icons.view_list_rounded, 'list'),
            ]),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => context.read<BannerCubit>().loadBanners(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF9FAFB),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(IconData icon, String mode) {
    final isActive = _viewMode == mode;
    return InkWell(
      onTap: () => setState(() => _viewMode = mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: isActive ? const Color(0xFF5542F6) : Colors.transparent,
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon,
            color: isActive ? Colors.white : Colors.grey[400], size: 20),
      ),
    );
  }

  Widget _buildGridView(List<BannerModel> banners) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.4),
      itemCount: banners.length,
      itemBuilder: (context, index) => _buildBannerCard(banners[index]),
    );
  }

  Widget _buildListView(List<BannerModel> banners) {
    return Column(
        children:
            banners.map((banner) => _buildBannerListItem(banner)).toList());
  }

  Widget _buildBannerCard(BannerModel banner) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  child: Image.network(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Color(0xFF5542F6))));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                          color: const Color(0xFFF3F4F6),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image_outlined,
                                    size: 40, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text('Image not available',
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 12)),
                              ]));
                    },
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7)
                          ]),
                    ),
                  ),
                ),
                Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.drag_indicator,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('Position ${banner.position}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ]),
                    )),
                Positioned(
                    top: 12,
                    right: 12,
                    child: _buildStatusBadge(banner.status)),
                Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Text(
                      banner.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 4)
                          ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Text(banner.description ?? '',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)),
                  const SizedBox(height: 12),
                  Row(children: [
                    _buildMiniStat(
                        Icons.visibility_outlined, _formatNumber(banner.views)),
                    const SizedBox(width: 16),
                    _buildMiniStat(
                        Icons.touch_app_outlined, _formatNumber(banner.clicks)),
                    const SizedBox(width: 16),
                    _buildMiniStat(Icons.percent_rounded,
                        '${banner.ctr.toStringAsFixed(1)}%'),
                    const Spacer(),
                    _buildActionButton(
                        icon: Icons.visibility_outlined,
                        color: const Color(0xFF3B82F6),
                        tooltip: 'Preview',
                        onPressed: () => _showPreviewDialog(banner)),
                    const SizedBox(width: 4),
                    _buildActionButton(
                        icon: Icons.edit_outlined,
                        color: const Color(0xFF5542F6),
                        tooltip: 'Edit',
                        onPressed: () => _showEditBannerDialog(banner)),
                    const SizedBox(width: 4),
                    _buildActionButton(
                        icon: Icons.delete_outline,
                        color: const Color(0xFFEF4444),
                        tooltip: 'Delete',
                        onPressed: () => _showDeleteBannerDialog(banner)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerListItem(BannerModel banner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
          child: SizedBox(
            width: 280,
            height: 140,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(banner.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF3F4F6),
                      child: Icon(Icons.broken_image_outlined,
                          size: 40, color: Colors.grey[400]))),
              Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text('#${banner.position}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  )),
            ]),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(banner.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937))),
                const SizedBox(width: 12),
                _buildStatusBadge(banner.status),
              ]),
              const SizedBox(height: 8),
              Text(banner.description ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(children: [
                _buildListStat('Views', _formatNumber(banner.views),
                    Icons.visibility_outlined),
                const SizedBox(width: 24),
                _buildListStat('Clicks', _formatNumber(banner.clicks),
                    Icons.touch_app_outlined),
                const SizedBox(width: 24),
                _buildListStat('CTR', '${banner.ctr.toStringAsFixed(1)}%',
                    Icons.trending_up_rounded),
              ]),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(children: [
            _buildListActionButton(
                icon: Icons.visibility_outlined,
                label: 'Preview',
                color: const Color(0xFF3B82F6),
                onPressed: () => _showPreviewDialog(banner)),
            const SizedBox(width: 8),
            _buildListActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                color: const Color(0xFF5542F6),
                onPressed: () => _showEditBannerDialog(banner)),
            const SizedBox(width: 8),
            _buildListActionButton(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: const Color(0xFFEF4444),
                onPressed: () => _showDeleteBannerDialog(banner)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildMiniStat(IconData icon, String value) {
    return Row(children: [
      Icon(icon, size: 14, color: Colors.grey[400]),
      const SizedBox(width: 4),
      Text(value,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600])),
    ]);
  }

  Widget _buildListStat(String label, String value, IconData icon) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.grey[400]),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937))),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ]),
    ]);
  }

  Widget _buildActionButton(
      {required IconData icon,
      required Color color,
      required String tooltip,
      required VoidCallback onPressed}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  Widget _buildListActionButton(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'active':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        icon = Icons.check_circle_outline;
        break;
      case 'inactive':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        icon = Icons.pause_circle_outline;
        break;
      case 'scheduled':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        icon = Icons.schedule_outlined;
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        icon = Icons.info_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: textColor),
        const SizedBox(width: 4),
        Text(status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
                color: textColor, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981);
      case 'inactive':
        return const Color(0xFFEF4444);
      case 'scheduled':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildEmptyState() {
    final bool isFiltering = _searchQuery.isNotEmpty || _statusFilter != 'All';
    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(50)),
            child: Icon(
                isFiltering
                    ? Icons.search_off_rounded
                    : Icons.photo_library_outlined,
                size: 48,
                color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(isFiltering ? 'No banners found' : 'No banners yet',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937))),
          const SizedBox(height: 8),
          Text(
              isFiltering
                  ? 'Try adjusting your search or filter criteria'
                  : 'Create your first promotional banner to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          if (isFiltering)
            TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _statusFilter = 'All';
                  });
                },
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear filters'))
          else
            ElevatedButton.icon(
              onPressed: () => _showAddBannerDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Banner'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5542F6),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
        ]),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  void _showPreviewDialog(BannerModel banner) {
    showDialog(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.all(24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            width: screenSize.width > 700 ? 600 : screenSize.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                      child: Row(children: [
                        const Icon(Icons.preview_outlined,
                            color: Color(0xFF5542F6), size: 20),
                        const SizedBox(width: 8),
                        const Text('Banner Preview',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 20)),
                      ]),
                    ),
                    const Divider(height: 1),
                    Image.network(banner.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: const Color(0xFFF3F4F6),
                            child: const Icon(Icons.broken_image,
                                size: 48, color: Colors.grey))),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Flexible(
                                  child: Text(banner.title,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold))),
                              const SizedBox(width: 8),
                              _buildStatusBadge(banner.status),
                            ]),
                            const SizedBox(height: 6),
                            Text(banner.description ?? '',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600])),
                            const SizedBox(height: 12),
                            Wrap(spacing: 6, runSpacing: 6, children: [
                              _buildPreviewStat(
                                  'Pos', '#${banner.position}', Icons.tag),
                              _buildPreviewStat(
                                  'Views',
                                  _formatNumber(banner.views),
                                  Icons.visibility),
                              _buildPreviewStat(
                                  'Clicks',
                                  _formatNumber(banner.clicks),
                                  Icons.touch_app),
                              _buildPreviewStat(
                                  'Type', banner.linkType, Icons.link),
                            ]),
                          ]),
                    ),
                  ]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: const Color(0xFF5542F6)),
        const SizedBox(width: 8),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              Text(label,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            ]),
      ]),
    );
  }

  void _showAddBannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _BannerFormDialog(
        title: 'Add New Banner',
        onSave: (data) {
          context.read<BannerCubit>().addBanner(
                title: data['title'],
                description: data['description'],
                imageUrl: data['image_url'],
                linkType: data['link_type'],
                linkId: data['link_id'],
                externalUrl: data['external_url'],
                status: data['status'].toString().toLowerCase(),
                startDate: data['start_date'],
                endDate: data['end_date'],
              );
        },
      ),
    );
  }

  void _showEditBannerDialog(BannerModel banner) {
    showDialog(
      context: context,
      builder: (dialogContext) => _BannerFormDialog(
        title: 'Edit Banner',
        banner: banner,
        onSave: (data) {
          context.read<BannerCubit>().updateBanner(
                id: banner.id!,
                title: data['title'],
                description: data['description'],
                imageUrl: data['image_url'],
                linkType: data['link_type'],
                linkId: data['link_id'],
                externalUrl: data['external_url'],
                status: data['status'].toString().toLowerCase(),
                startDate: data['start_date'],
                endDate: data['end_date'],
              );
        },
      ),
    );
  }

  void _showDeleteBannerDialog(BannerModel banner) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(50)),
            child: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFEF4444), size: 32),
          ),
          const SizedBox(height: 20),
          const Text('Delete Banner?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
              'Are you sure you want to delete "${banner.title}"?\nThis action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.5)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<BannerCubit>().deleteBanner(banner.id!);
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Delete'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _BannerFormDialog extends StatefulWidget {
  final String title;
  final BannerModel? banner;
  final Function(Map<String, dynamic>) onSave;

  const _BannerFormDialog(
      {required this.title, this.banner, required this.onSave});

  @override
  State<_BannerFormDialog> createState() => _BannerFormDialogState();
}

class _BannerFormDialogState extends State<_BannerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _linkIdController;
  late TextEditingController _externalUrlController;
  String _status = 'Active';
  String _linkType = 'category';
  DateTime? _startDate;
  DateTime? _endDate;

  // متغيرات الصورة
  String? _existingImageUrl; // رابط الصورة الموجودة (للتعديل)
  Uint8List? _selectedImageBytes; // بيانات الصورة المختارة
  String? _selectedImageName; // اسم الصورة المختارة
  bool _isUploading = false; // حالة الرفع

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.banner?.description ?? '');
    _linkIdController =
        TextEditingController(text: widget.banner?.linkId ?? '');

    if (widget.banner != null) {
      _status = widget.banner!.status[0].toUpperCase() +
          widget.banner!.status.substring(1);
      _linkType = widget.banner!.linkType;
      _startDate = widget.banner!.startDate;
      _endDate = widget.banner!.endDate;
      _existingImageUrl = widget.banner!.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkIdController.dispose();
    _externalUrlController.dispose();
    super.dispose();
  }

  // اختيار صورة من الجهاز
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = image.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('فشل في اختيار الصورة: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  // هل توجد صورة (سواء موجودة أو مختارة)؟
  bool get _hasImage =>
      _selectedImageBytes != null ||
      (_existingImageUrl != null && _existingImageUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: const Color(0xFF5542F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                      widget.banner == null
                          ? Icons.add_photo_alternate_outlined
                          : Icons.edit_outlined,
                      color: const Color(0xFF5542F6)),
                ),
                const SizedBox(width: 12),
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded)),
              ]),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ═══════════════════════════════════════════════════════════════
                      // قسم اختيار الصورة
                      // ═══════════════════════════════════════════════════════════════
                      Text('Banner Image',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151))),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _hasImage
                                  ? const Color(0xFF5542F6)
                                  : const Color(0xFFE5E7EB),
                              width: _hasImage ? 2 : 1,
                            ),
                          ),
                          child: _buildImagePreview(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (_selectedImageName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Color(0xFF10B981), size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _selectedImageName!,
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF10B981)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      _buildTextField(
                          controller: _titleController,
                          label: 'Banner Title',
                          hint: 'Enter a catchy title',
                          prefixIcon: Icons.title_outlined,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter a title'
                              : null),
                      const SizedBox(height: 16),
                      _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Enter banner description',
                          prefixIcon: Icons.description_outlined,
                          maxLines: 2),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child: _buildDropdownField(
                                label: 'Link Type',
                                value: _linkType,
                                items: [
                                  'category',
                                  'product',
                                  'offer',
                                  'external'
                                ],
                                onChanged: (value) =>
                                    setState(() => _linkType = value!))),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildDropdownField(
                                label: 'Status',
                                value: _status,
                                items: ['Active', 'Inactive', 'Scheduled'],
                                onChanged: (value) =>
                                    setState(() => _status = value!))),
                      ]),
                      const SizedBox(height: 16),
                      if (_linkType == 'external')
                        _buildTextField(
                            controller: _externalUrlController,
                            label: 'External URL',
                            hint: 'https://example.com',
                            prefixIcon: Icons.link)
                      else
                        _buildTextField(
                            controller: _linkIdController,
                            label:
                                '${_linkType[0].toUpperCase()}${_linkType.substring(1)} ID',
                            hint: 'Enter $_linkType ID',
                            prefixIcon: Icons.tag),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child: _buildDateField(
                                label: 'Start Date',
                                value: _startDate,
                                onTap: () async {
                                  final date = await showDatePicker(
                                      context: context,
                                      initialDate: _startDate ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030));
                                  if (date != null)
                                    setState(() => _startDate = date);
                                })),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildDateField(
                                label: 'End Date',
                                value: _endDate,
                                onTap: () async {
                                  final date = await showDatePicker(
                                      context: context,
                                      initialDate: _endDate ??
                                          DateTime.now()
                                              .add(const Duration(days: 30)),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030));
                                  if (date != null)
                                    setState(() => _endDate = date);
                                })),
                      ]),
                    ]),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isUploading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : () => _handleSave(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5542F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: _isUploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(widget.banner == null
                            ? 'Create Banner'
                            : 'Save Changes'),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // معالجة الحفظ (رفع الصورة ثم حفظ البيانات)
  Future<void> _handleSave(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من وجود صورة
    if (!_hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('الرجاء اختيار صورة للبانر'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String imageUrl;

      // إذا تم اختيار صورة جديدة، نرفعها أولاً
      if (_selectedImageBytes != null) {
        final cubit = context.read<BannerCubit>();
        final uploadedUrl = await cubit.uploadImage(
            _selectedImageBytes!, _selectedImageName ?? 'banner.jpg');
        if (uploadedUrl == null) {
          setState(() => _isUploading = false);
          return; // حدث خطأ أثناء الرفع
        }
        imageUrl = uploadedUrl;
      } else {
        // استخدام الصورة الموجودة
        imageUrl = _existingImageUrl!;
      }

      // إرسال البيانات
      widget.onSave({
        'title': _titleController.text,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'image_url': imageUrl,
        'link_type': _linkType,
        'link_id':
            _linkIdController.text.isEmpty ? null : _linkIdController.text,
        'external_url': _externalUrlController.text.isEmpty
            ? null
            : _externalUrlController.text,
        'status': _status,
        'start_date': _startDate,
        'end_date': _endDate,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // عرض معاينة الصورة
  Widget _buildImagePreview() {
    // إذا تم اختيار صورة جديدة
    if (_selectedImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('صورة جديدة',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // إذا كانت هناك صورة موجودة (في حالة التعديل)
    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _existingImageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF5542F6)));
              },
              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('صورة حالية',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // لا توجد صورة
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(Icons.add_photo_alternate_outlined,
            size: 40, color: Colors.grey[500]),
      ),
      const SizedBox(height: 12),
      Text('اضغط لاختيار صورة',
          style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text('PNG, JPG, WEBP (max 5MB)',
          style: TextStyle(color: Colors.grey[400], fontSize: 12)),
    ]);
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required String hint,
      IconData? prefixIcon,
      int maxLines = 1,
      String? Function(String?)? validator,
      Function(String)? onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151))),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 20, color: Colors.grey[400])
              : null,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF5542F6), width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444))),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    ]);
  }

  Widget _buildDropdownField(
      {required String label,
      required String value,
      required List<String> items,
      required Function(String?) onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151))),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            items: items
                .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item[0].toUpperCase() + item.substring(1))))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ]);
  }

  Widget _buildDateField(
      {required String label,
      required DateTime? value,
      required VoidCallback onTap}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151))),
      const SizedBox(height: 8),
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: Colors.grey[400]),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    value != null
                        ? '${value.day}/${value.month}/${value.year}'
                        : 'Select date',
                    style: TextStyle(
                        color: value != null
                            ? const Color(0xFF1F2937)
                            : Colors.grey[400]))),
          ]),
        ),
      ),
    ]);
  }
}
