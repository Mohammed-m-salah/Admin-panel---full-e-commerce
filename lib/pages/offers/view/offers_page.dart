import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/model/offer_model.dart';
import '../logic/cubit/offer_cubit.dart';
import '../logic/cubit/offer_state.dart';
import 'widgets/add_offer.dart';
import 'widgets/update_offer.dart';
import 'widgets/delete_offer.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _typeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<OfferModel> _filterOffers(List<OfferModel> offers) {
    return offers.where((offer) {
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = offer.title.toLowerCase();
        final code = (offer.code ?? '').toLowerCase();
        final description = (offer.description ?? '').toLowerCase();
        matchesSearch = title.contains(query) ||
            code.contains(query) ||
            description.contains(query);
      }

      bool matchesStatus = true;
      if (_statusFilter != 'All') {
        matchesStatus =
            offer.status?.toLowerCase() == _statusFilter.toLowerCase();
      }

      bool matchesType = true;
      if (_typeFilter != 'All') {
        matchesType =
            offer.discountType.toLowerCase() == _typeFilter.toLowerCase();
      }

      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OfferCubit, OfferState>(
      listener: (context, state) {
        if (state is OfferOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(state.message),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (state is OfferError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(state.message),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        List<OfferModel> offers = [];
        if (state is OfferLoaded) {
          offers = state.offers;
        }

        final filteredOffers = _filterOffers(offers);
        final activeOffers =
            offers.where((o) => o.status?.toLowerCase() == 'active').toList();
        final scheduledOffers = offers
            .where((o) => o.status?.toLowerCase() == 'scheduled')
            .toList();
        final expiredOffers =
            offers.where((o) => o.status?.toLowerCase() == 'expired').toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatCards(offers, filteredOffers),
                      const SizedBox(height: 24),
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      _buildOffersTable(context, state, filteredOffers),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5542F6), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Offers & Discounts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                'Manage promotional offers and discount codes',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {
              // Export offers
            },
            icon: const Icon(Icons.download_outlined, size: 20),
            label: const Text('Export'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5542F6),
              side: const BorderSide(color: Color(0xFF5542F6)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              final cubit = context.read<OfferCubit>();
              showDialog(
                context: context,
                builder: (dialogContext) => BlocProvider.value(
                  value: cubit,
                  child: const AddOfferDialog(),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add Offer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5542F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(
      List<OfferModel> allOffers, List<OfferModel> filteredOffers) {
    final activeCount =
        allOffers.where((o) => o.status?.toLowerCase() == 'active').length;
    final scheduledCount =
        allOffers.where((o) => o.status?.toLowerCase() == 'scheduled').length;
    final totalUsage =
        allOffers.fold<int>(0, (sum, o) => sum + (o.usedCount ?? 0));
    final totalSavings = allOffers.fold<double>(0, (sum, o) {
      if (o.discountType == 'fixed') {
        return sum + (o.discountValue * (o.usedCount ?? 0));
      }
      return sum;
    });

    return Row(
      children: [
        _buildStatCard(
          title: 'Total Offers',
          value: allOffers.length.toString(),
          icon: Icons.local_offer_outlined,
          color: const Color(0xFF5542F6),
          subtitle: 'All offers',
          trend: '+${filteredOffers.length} shown',
          trendUp: true,
        ),
        const SizedBox(width: 20),
        _buildStatCard(
          title: 'Active Offers',
          value: activeCount.toString(),
          icon: Icons.check_circle_outline,
          color: const Color(0xFF10B981),
          subtitle: 'Currently running',
          trend: activeCount > 0 ? 'Live now' : 'No active',
          trendUp: activeCount > 0,
        ),
        const SizedBox(width: 20),
        _buildStatCard(
          title: 'Scheduled',
          value: scheduledCount.toString(),
          icon: Icons.schedule_outlined,
          color: const Color(0xFFF59E0B),
          subtitle: 'Upcoming offers',
          trend: scheduledCount > 0 ? 'Pending' : 'None scheduled',
          trendUp: scheduledCount > 0,
        ),
        const SizedBox(width: 20),
        _buildStatCard(
          title: 'Total Redemptions',
          value: _formatNumber(totalUsage),
          icon: Icons.redeem_outlined,
          color: const Color(0xFFEF4444),
          subtitle: 'Times used',
          trend: '\$${_formatNumber(totalSavings.toInt())} saved',
          trendUp: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    String? trend,
    bool trendUp = true,
  }) {
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
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (trend != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trendUp
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: trendUp
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5542F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: Color(0xFF5542F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.percent_rounded,
                  title: 'Percentage Discount',
                  description: 'Create a percentage-based discount offer',
                  color: const Color(0xFF5542F6),
                  onTap: () {
                    final cubit = context.read<OfferCubit>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: cubit,
                        child: const AddOfferDialog(initialType: 'percentage'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.attach_money_rounded,
                  title: 'Fixed Amount Discount',
                  description: 'Create a fixed amount discount offer',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    final cubit = context.read<OfferCubit>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: cubit,
                        child: const AddOfferDialog(initialType: 'fixed'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.qr_code_rounded,
                  title: 'Promo Code',
                  description: 'Generate a unique promotional code',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    final cubit = context.read<OfferCubit>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: cubit,
                        child: const AddOfferDialog(withCode: true),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.timer_outlined,
                  title: 'Flash Sale',
                  description: 'Create a time-limited flash sale',
                  color: const Color(0xFFEF4444),
                  onTap: () {
                    final cubit = context.read<OfferCubit>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: cubit,
                        child: const AddOfferDialog(isFlashSale: true),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersTable(
      BuildContext context, OfferState state, List<OfferModel> filteredOffers) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText:
                          'Search offers by title, code or description...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon:
                          Icon(Icons.search_rounded, color: Colors.grey[400]),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded,
                                  color: Colors.grey[400]),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items:
                          ['All', 'Active', 'Inactive', 'Scheduled', 'Expired']
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                      onChanged: (value) =>
                          setState(() => _statusFilter = value ?? 'All'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _typeFilter,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: ['All', 'Percentage', 'Fixed']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _typeFilter = value ?? 'All'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
            ),
            child: const Row(
              children: [
                SizedBox(
                    width: 60,
                    child: Text('',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280)))),
                SizedBox(width: 12),
                Expanded(
                    flex: 2,
                    child: Text('Offer',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280)))),
                Expanded(
                    child: Text('Applies To',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280)))),
                Expanded(
                    child: Text('Discount',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280)))),
                Expanded(
                    flex: 2,
                    child: Text('Duration',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280)))),
                Expanded(
                    child: Text('Usage',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280)))),
                SizedBox(
                    width: 80,
                    child: Text('Status',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280)))),
                SizedBox(
                    width: 140,
                    child: Text('Actions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280)))),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Table Content
          SizedBox(
            height: 400,
            child: _buildTableContent(context, state, filteredOffers),
          ),
        ],
      ),
    );
  }

  Widget _buildTableContent(
      BuildContext context, OfferState state, List<OfferModel> offers) {
    if (state is OfferLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF5542F6)),
      );
    }

    if (state is OfferError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.error_outline,
                  size: 40, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<OfferCubit>().fetchOffers(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5542F6),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (offers.isEmpty) {
      final bool isFiltering = _searchQuery.isNotEmpty ||
          _statusFilter != 'All' ||
          _typeFilter != 'All';

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                isFiltering
                    ? Icons.search_off_rounded
                    : Icons.local_offer_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFiltering ? 'No offers match your search' : 'No offers yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltering
                  ? 'Try adjusting your filters'
                  : 'Create your first offer to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            if (isFiltering)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _statusFilter = 'All';
                    _typeFilter = 'All';
                  });
                },
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5542F6),
                  side: const BorderSide(color: Color(0xFF5542F6)),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  final cubit = context.read<OfferCubit>();
                  showDialog(
                    context: context,
                    builder: (dialogContext) => BlocProvider.value(
                      value: cubit,
                      child: const AddOfferDialog(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Offer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5542F6),
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: offers.length,
      itemBuilder: (context, index) => OfferRow(offer: offers[index]),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Offer Row Widget with Toggle Switch
// ═══════════════════════════════════════════════════════════════════════════════

class OfferRow extends StatefulWidget {
  final OfferModel offer;

  const OfferRow({super.key, required this.offer});

  @override
  State<OfferRow> createState() => _OfferRowState();
}

class _OfferRowState extends State<OfferRow> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.offer.status?.toLowerCase() == 'active';
  }

  @override
  void didUpdateWidget(OfferRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offer.status != widget.offer.status) {
      _isActive = widget.offer.status?.toLowerCase() == 'active';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _isActive ? Colors.white : Colors.grey[50],
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Offer Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isActive
                    ? [
                        _getOfferColor(widget.offer.discountType)
                            .withOpacity(0.8),
                        _getOfferColor(widget.offer.discountType),
                      ]
                    : [Colors.grey[400]!, Colors.grey[500]!],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isActive
                  ? [
                      BoxShadow(
                        color: _getOfferColor(widget.offer.discountType)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.offer.discountType == 'percentage'
                      ? Icons.percent_rounded
                      : Icons.attach_money_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.offer.discountType == 'percentage'
                      ? '${widget.offer.discountValue.toStringAsFixed(0)}%'
                      : '\$${widget.offer.discountValue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Title & Description
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.offer.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        _isActive ? const Color(0xFF1F2937) : Colors.grey[500],
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.offer.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.offer.description!,
                    style: TextStyle(
                      color: _isActive
                          ? const Color(0xFF6B7280)
                          : Colors.grey[400],
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),

          // Applies To (Target)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isActive
                    ? _getTargetColor(widget.offer.target).withOpacity(0.1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isActive
                      ? _getTargetColor(widget.offer.target).withOpacity(0.3)
                      : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTargetIcon(widget.offer.target),
                    size: 14,
                    color: _isActive
                        ? _getTargetColor(widget.offer.target)
                        : Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.offer.targetDisplayName,
                      style: TextStyle(
                        color: _isActive
                            ? _getTargetColor(widget.offer.target)
                            : Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Discount
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isActive
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.offer.formattedDiscount,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isActive ? const Color(0xFF10B981) : Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Duration
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: _isActive
                          ? const Color(0xFF6B7280)
                          : Colors.grey[400],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatDate(widget.offer.startDate)} - ${_formatDate(widget.offer.endDate)}',
                      style: TextStyle(
                        color: _isActive
                            ? const Color(0xFF1F2937)
                            : Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDaysRemainingColor(widget.offer.endDate)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getDaysRemaining(widget.offer.endDate),
                    style: TextStyle(
                      color: _getDaysRemainingColor(widget.offer.endDate),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Usage
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.offer.usedCount ?? 0}${widget.offer.usageLimit != null ? ' / ${widget.offer.usageLimit}' : ''}',
                  style: TextStyle(
                    color:
                        _isActive ? const Color(0xFF1F2937) : Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.offer.usageLimit != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (widget.offer.usedCount ?? 0) /
                          widget.offer.usageLimit!,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getUsageColor((widget.offer.usedCount ?? 0) /
                            widget.offer.usageLimit!),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Toggle Status Switch
          SizedBox(
            width: 80,
            child: Center(
              child: Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                    final newStatus = value ? 'Active' : 'Inactive';
                    final updatedOffer = OfferModel(
                      id: widget.offer.id,
                      title: widget.offer.title,
                      description: widget.offer.description,
                      discountType: widget.offer.discountType,
                      discountValue: widget.offer.discountValue,
                      minimumPurchase: widget.offer.minimumPurchase,
                      maximumDiscount: widget.offer.maximumDiscount,
                      code: widget.offer.code,
                      startDate: widget.offer.startDate,
                      endDate: widget.offer.endDate,
                      usageLimit: widget.offer.usageLimit,
                      usedCount: widget.offer.usedCount,
                      status: newStatus,
                    );
                    context.read<OfferCubit>().updateOffer(updatedOffer);
                  },
                  activeColor: const Color(0xFF10B981),
                  activeTrackColor: const Color(0xFF10B981).withOpacity(0.3),
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: Icons.visibility_outlined,
                  color: const Color(0xFF3B82F6),
                  tooltip: 'View',
                  onTap: () {
                    // View offer details
                  },
                ),
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: const Color(0xFF5542F6),
                  tooltip: 'Edit',
                  onTap: () {
                    final cubit = context.read<OfferCubit>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: cubit,
                        child: UpdateOfferDialog(offer: widget.offer),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.copy_outlined,
                  color: const Color(0xFFF59E0B),
                  tooltip: 'Duplicate',
                  onTap: () {
                    // Duplicate offer
                  },
                ),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  color: const Color(0xFFEF4444),
                  tooltip: 'Delete',
                  onTap: () {
                    final cubit = context.read<OfferCubit>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: cubit,
                        child: DeleteOfferDialog(offer: widget.offer),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  Color _getOfferColor(String type) {
    return type == 'percentage'
        ? const Color(0xFF5542F6)
        : const Color(0xFF10B981);
  }

  Color _getUsageColor(double ratio) {
    if (ratio >= 0.9) return const Color(0xFFEF4444);
    if (ratio >= 0.7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  Color _getTargetColor(DiscountTarget target) {
    switch (target) {
      case DiscountTarget.all:
        return const Color(0xFF10B981);
      case DiscountTarget.category:
        return const Color(0xFF5542F6);
      case DiscountTarget.product:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _getTargetIcon(DiscountTarget target) {
    switch (target) {
      case DiscountTarget.all:
        return Icons.apps_rounded;
      case DiscountTarget.category:
        return Icons.category_rounded;
      case DiscountTarget.product:
        return Icons.inventory_2_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _getDaysRemaining(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;

    if (difference < 0) return 'Expired ${-difference}d ago';
    if (difference == 0) return 'Expires today';
    if (difference == 1) return '1 day left';
    return '$difference days left';
  }

  Color _getDaysRemainingColor(DateTime endDate) {
    final difference = endDate.difference(DateTime.now()).inDays;
    if (difference < 0) return const Color(0xFFEF4444);
    if (difference <= 3) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }
}
