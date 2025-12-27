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

class _OffersPageState extends State<OffersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _typeFilter = 'All';

  @override
  void dispose() {
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
    // ═══════════════════════════════════════════════════════════════════
    // BlocConsumer: يجمع بين listener و builder
    // - listener: للاستماع للحالات وعرض SnackBar
    // - builder: لبناء الواجهة حسب الحالة
    // ═══════════════════════════════════════════════════════════════════
    return BlocConsumer<OfferCubit, OfferState>(
      // ─────────────────────────────────────────────────────────────────
      // listener: يُنفذ عند كل تغيير في الحالة (لا يُعيد بناء الواجهة)
      // مثالي لعرض SnackBar أو Dialog
      // ─────────────────────────────────────────────────────────────────
      listener: (context, state) {
        if (state is OfferOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is OfferError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      // ─────────────────────────────────────────────────────────────────
      // builder: يبني الواجهة حسب الحالة
      // يُعاد بناؤه عند كل تغيير في الحالة
      // ─────────────────────────────────────────────────────────────────
      builder: (context, state) {
        // استخراج قائمة العروض من الحالة
        List<OfferModel> offers = [];
        if (state is OfferLoaded) {
          offers = state.offers;
        }

        // تطبيق الفلترة على القائمة
        final filteredOffers = _filterOffers(offers);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: const Text(
              'Offers & Discounts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // ─────────────────────────────────────────────────────
                    // نمرر الـ Cubit للنافذة حتى تستطيع استدعاء addOffer
                    // ─────────────────────────────────────────────────────
                    final cubit = context.read<OfferCubit>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: cubit,
                        child: const AddOfferDialog(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Offer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5542F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search and Filters Row
                Row(
                  children: [
                    // Search Field
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText:
                              'Search offers by title, code or description...',
                          prefixIcon:
                              const Icon(Icons.search, color: Color(0xFF6B7280)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Color(0xFF6B7280)),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xFF5542F6), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Status Filter
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _statusFilter,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: [
                              'All',
                              'Active',
                              'Inactive',
                              'Scheduled',
                              'Expired'
                            ]
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _statusFilter = value ?? 'All';
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Type Filter
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _typeFilter,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: ['All', 'Percentage', 'Fixed']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _typeFilter = value ?? 'All';
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Statistics Cards
                Row(
                  children: [
                    _buildStatCard(
                      'Total Offers',
                      filteredOffers.length.toString(),
                      Icons.local_offer_outlined,
                      const Color(0xFF5542F6),
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Active Offers',
                      filteredOffers
                          .where((o) => o.status?.toLowerCase() == 'active')
                          .length
                          .toString(),
                      Icons.check_circle_outline,
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Scheduled',
                      filteredOffers
                          .where((o) => o.status?.toLowerCase() == 'scheduled')
                          .length
                          .toString(),
                      Icons.schedule_outlined,
                      const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Total Usage',
                      filteredOffers
                          .fold<int>(0, (sum, o) => sum + (o.usedCount ?? 0))
                          .toString(),
                      Icons.people_outline,
                      const Color(0xFFEF4444),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Offers Table
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Offer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Code',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Discount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Duration',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Usage',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: Text(
                                  'Actions',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),

                        // Table Content - يتغير حسب الحالة
                        Expanded(
                          child: _buildTableContent(state, filteredOffers),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // _buildTableContent: يبني محتوى الجدول حسب الحالة
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildTableContent(OfferState state, List<OfferModel> offers) {
    // ─────────────────────────────────────────────────────────────────────
    // حالة التحميل: نعرض CircularProgressIndicator
    // ─────────────────────────────────────────────────────────────────────
    if (state is OfferLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5542F6),
        ),
      );
    }

    // ─────────────────────────────────────────────────────────────────────
    // حالة الخطأ: نعرض رسالة خطأ مع زر إعادة المحاولة
    // ─────────────────────────────────────────────────────────────────────
    if (state is OfferError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<OfferCubit>().fetchOffers(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // ─────────────────────────────────────────────────────────────────────
    // حالة عدم وجود نتائج
    // ─────────────────────────────────────────────────────────────────────
    if (offers.isEmpty) {
      final bool isFiltering =
          _searchQuery.isNotEmpty || _statusFilter != 'All' || _typeFilter != 'All';

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFiltering ? Icons.search_off : Icons.local_offer_outlined,
              size: 48,
              color: const Color(0xFF6B7280),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltering ? 'No offers match your search' : 'No offers yet',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
              ),
            ),
            if (isFiltering) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _statusFilter = 'All';
                    _typeFilter = 'All';
                  });
                },
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      );
    }

    // ─────────────────────────────────────────────────────────────────────
    // حالة وجود بيانات: نعرض القائمة
    // ─────────────────────────────────────────────────────────────────────
    return ListView.builder(
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return OfferRow(offer: offer);
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// OfferRow: صف العرض في الجدول
// ═══════════════════════════════════════════════════════════════════════════
class OfferRow extends StatelessWidget {
  final OfferModel offer;

  const OfferRow({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Offer Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getOfferColor(offer.discountType).withOpacity(0.8),
                  _getOfferColor(offer.discountType),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                offer.discountType == 'percentage'
                    ? Icons.percent
                    : Icons.attach_money,
                color: Colors.white,
                size: 24,
              ),
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
                  offer.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (offer.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    offer.description!,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Code
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                offer.code ?? '-',
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Discount
          Expanded(
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5542F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    offer.formattedDiscount,
                    style: const TextStyle(
                      color: Color(0xFF5542F6),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Duration
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatDate(offer.startDate)} - ${_formatDate(offer.endDate)}',
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getDaysRemaining(offer.endDate),
                  style: TextStyle(
                    color: _getDaysRemainingColor(offer.endDate),
                    fontSize: 11,
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
                  '${offer.usedCount ?? 0}${offer.usageLimit != null ? '/${offer.usageLimit}' : ''}',
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (offer.usageLimit != null) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (offer.usedCount ?? 0) / offer.usageLimit!,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getUsageColor((offer.usedCount ?? 0) / offer.usageLimit!),
                    ),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ],
            ),
          ),

          // Status
          Expanded(
            child: _buildStatusBadge(offer.status ?? 'Active'),
          ),

          // Actions
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    // ─────────────────────────────────────────────────────
                    // نمرر الـ Cubit لنافذة التعديل
                    // ─────────────────────────────────────────────────────
                    final cubit = context.read<OfferCubit>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: cubit,
                        child: UpdateOfferDialog(offer: offer),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  color: const Color(0xFF5542F6),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () {
                    // ─────────────────────────────────────────────────────
                    // نمرر الـ Cubit لنافذة الحذف
                    // ─────────────────────────────────────────────────────
                    final cubit = context.read<OfferCubit>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: cubit,
                        child: DeleteOfferDialog(offer: offer),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: const Color(0xFFEF4444),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDaysRemaining(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;

    if (difference < 0) return 'Expired ${-difference} days ago';
    if (difference == 0) return 'Expires today';
    if (difference == 1) return '1 day remaining';
    return '$difference days remaining';
  }

  Color _getDaysRemainingColor(DateTime endDate) {
    final difference = endDate.difference(DateTime.now()).inDays;
    if (difference < 0) return const Color(0xFFEF4444);
    if (difference <= 3) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        break;
      case 'inactive':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case 'scheduled':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        break;
      case 'expired':
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
