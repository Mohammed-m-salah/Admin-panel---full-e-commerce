import 'package:flutter/material.dart';
import '../data/model/notification_model.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Notifications Management Page
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _typeFilter = 'All';

  // Sample notification data
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      title: 'Special Offer - 50% Off',
      body: 'Enjoy 50% off on all products for a limited time!',
      type: NotificationType.newOffer,
      target: NotificationTarget.allUsers,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      sentCount: 1520,
      readCount: 890,
    ),
    NotificationModel(
      id: '2',
      title: 'Your Order is on the Way',
      body: 'Your order #12345 has been shipped and will arrive in 2-3 days',
      type: NotificationType.orderStatusChange,
      target: NotificationTarget.specificUser,
      userId: 'user123',
      userName: 'John Smith',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      sentCount: 1,
      readCount: 1,
    ),
    NotificationModel(
      id: '3',
      title: 'Product Back in Stock',
      body: 'iPhone 15 Pro is now available!',
      type: NotificationType.productBackInStock,
      target: NotificationTarget.allUsers,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      sentCount: 2300,
      readCount: 1200,
      isAutomatic: true,
    ),
    NotificationModel(
      id: '4',
      title: 'New Order',
      body: 'You have a new order #12346',
      type: NotificationType.newOrder,
      target: NotificationTarget.specificUser,
      userId: 'admin',
      userName: 'Admin',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      sentCount: 1,
      readCount: 1,
      isAutomatic: true,
    ),
    NotificationModel(
      id: '5',
      title: 'New Banner!',
      body: 'New banner added - Summer Sale',
      type: NotificationType.newBanner,
      target: NotificationTarget.allUsers,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      sentCount: 1800,
      readCount: 950,
      isAutomatic: true,
    ),
  ];

  // Auto notification settings
  final List<AutoNotificationSetting> _autoSettings = [
    AutoNotificationSetting(
      type: NotificationType.newOrder,
      title: 'New Order',
      description: 'Send notification when a new order is received',
      isEnabled: true,
    ),
    AutoNotificationSetting(
      type: NotificationType.orderStatusChange,
      title: 'Order Status Change',
      description: 'Send notification to customer when order status changes',
      isEnabled: true,
    ),
    AutoNotificationSetting(
      type: NotificationType.newOffer,
      title: 'New Offer',
      description: 'Send notification to all users when a new offer is added',
      isEnabled: true,
    ),
    AutoNotificationSetting(
      type: NotificationType.productBackInStock,
      title: 'Product Back in Stock',
      description: 'Send notification when a product is back in stock',
      isEnabled: false,
    ),
    AutoNotificationSetting(
      type: NotificationType.newBanner,
      title: 'New Banner',
      description: 'Send notification when a new banner is published',
      isEnabled: true,
    ),
  ];

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

  List<NotificationModel> _filterNotifications() {
    return _notifications.where((notification) {
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        matchesSearch = notification.title.toLowerCase().contains(query) ||
            notification.body.toLowerCase().contains(query);
      }

      bool matchesType = true;
      if (_typeFilter != 'All') {
        matchesType = notification.type.toString().contains(_typeFilter);
      }

      return matchesSearch && matchesType;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCards(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildTabSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
                colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                'Send and manage notifications to users',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showSendNotificationDialog(
              target: NotificationTarget.allUsers,
            ),
            icon: const Icon(Icons.send_rounded, size: 20),
            label: const Text('Send Notification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    final totalSent =
        _notifications.fold<int>(0, (sum, n) => sum + n.sentCount);
    final totalRead =
        _notifications.fold<int>(0, (sum, n) => sum + n.readCount);
    final readRate = totalSent > 0 ? (totalRead / totalSent * 100) : 0;

    return Row(
      children: [
        _buildStatCard(
          title: 'Total Notifications',
          value: _notifications.length.toString(),
          icon: Icons.notifications_outlined,
          color: const Color(0xFFFF6B6B),
          subtitle: 'All notifications',
        ),
        const SizedBox(width: 20),
        _buildStatCard(
          title: 'Sent Notifications',
          value: _formatNumber(totalSent),
          icon: Icons.send_outlined,
          color: const Color(0xFF10B981),
          subtitle: 'Total sent',
        ),
        const SizedBox(width: 20),
        _buildStatCard(
          title: 'Read Notifications',
          value: _formatNumber(totalRead),
          icon: Icons.mark_email_read_outlined,
          color: const Color(0xFF3B82F6),
          subtitle: 'Total read',
        ),
        const SizedBox(width: 20),
        _buildStatCard(
          title: 'Read Rate',
          value: '${readRate.toStringAsFixed(1)}%',
          icon: Icons.analytics_outlined,
          color: const Color(0xFFF59E0B),
          subtitle: 'Engagement rate',
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
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
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: Color(0xFFFF6B6B),
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
                  icon: Icons.people_outline,
                  title: 'Send to All Users',
                  description: 'Send notification to all registered users',
                  color: const Color(0xFF5542F6),
                  onTap: () => _showSendNotificationDialog(
                    target: NotificationTarget.allUsers,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.person_outline,
                  title: 'Send to Specific User',
                  description: 'Send notification to a single user only',
                  color: const Color(0xFF10B981),
                  onTap: () => _showSendNotificationDialog(
                    target: NotificationTarget.specificUser,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Auto Notifications',
                  description: 'Manage automatic notification settings',
                  color: const Color(0xFFF59E0B),
                  onTap: () => _tabController.animateTo(2),
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

  Widget _buildTabSection() {
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
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFF6B6B),
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: const Color(0xFFFF6B6B),
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.history_outlined),
                  text: 'Notification History',
                ),
                Tab(
                  icon: Icon(Icons.send_outlined),
                  text: 'Sent Notifications',
                ),
                Tab(
                  icon: Icon(Icons.settings_outlined),
                  text: 'Auto Settings',
                ),
              ],
            ),
          ),
          SizedBox(
            height: 600,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationHistoryTab(),
                _buildSentNotificationsTab(),
                _buildAutoSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationHistoryTab() {
    final filteredNotifications = _filterNotifications();

    return Column(
      children: [
        _buildSearchAndFilterBar(),
        Expanded(
          child: filteredNotifications.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredNotifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(filteredNotifications[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSentNotificationsTab() {
    final sentNotifications = _notifications
        .where((n) => n.target == NotificationTarget.allUsers)
        .toList();

    return sentNotifications.isEmpty
        ? _buildEmptyState(
            message: 'No notifications sent to all users',
          )
        : ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: sentNotifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildNotificationCard(sentNotifications[index]);
            },
          );
  }

  Widget _buildAutoSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Automatic notifications are sent automatically when certain events occur in the system',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _autoSettings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildAutoSettingCard(_autoSettings[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
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
                hintText: 'Search notifications...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon:
                            Icon(Icons.close_rounded, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _typeFilter,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: [
                  'All',
                  'newOrder',
                  'orderStatusChange',
                  'newOffer',
                  'productBackInStock',
                  'newBanner',
                ].map((type) {
                  String displayName;
                  switch (type) {
                    case 'All':
                      displayName = 'All';
                      break;
                    case 'newOrder':
                      displayName = 'New Order';
                      break;
                    case 'orderStatusChange':
                      displayName = 'Status Change';
                      break;
                    case 'newOffer':
                      displayName = 'New Offer';
                      break;
                    case 'productBackInStock':
                      displayName = 'Back in Stock';
                      break;
                    case 'newBanner':
                      displayName = 'New Banner';
                      break;
                    default:
                      displayName = type;
                  }
                  return DropdownMenuItem(
                    value: type,
                    child: Text(displayName),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _typeFilter = value ?? 'All'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getTypeColor(notification.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getTypeIcon(notification.type),
              color: _getTypeColor(notification.type),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    if (notification.isAutomatic)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 12,
                              color: Color(0xFFF59E0B),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Auto',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFF59E0B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildNotificationMeta(
                      icon: Icons.category_outlined,
                      text: notification.typeDisplayName,
                    ),
                    const SizedBox(width: 16),
                    _buildNotificationMeta(
                      icon: Icons.person_outline,
                      text: notification.targetDisplayName,
                    ),
                    const SizedBox(width: 16),
                    _buildNotificationMeta(
                      icon: Icons.send_outlined,
                      text: '${_formatNumber(notification.sentCount)} sent',
                    ),
                    const SizedBox(width: 16),
                    _buildNotificationMeta(
                      icon: Icons.visibility_outlined,
                      text: '${_formatNumber(notification.readCount)} read',
                    ),
                    const Spacer(),
                    Text(
                      _formatTimeAgo(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[400]),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'resend',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 8),
                    Text('Resend'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              // Handle menu actions
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationMeta({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAutoSettingCard(AutoNotificationSetting setting) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: setting.isEnabled
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getTypeColor(setting.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTypeIcon(setting.type),
              color: _getTypeColor(setting.type),
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  setting.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  setting.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: setting.isEnabled,
            onChanged: (value) {
              // Toggle setting
              setState(() {});
            },
            activeColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({String? message}) {
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
              Icons.notifications_off_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message ?? 'No notifications',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by sending a new notification to users',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showSendNotificationDialog(
              target: NotificationTarget.allUsers,
            ),
            icon: const Icon(Icons.send_rounded),
            label: const Text('Send Notification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSendNotificationDialog({
    required NotificationTarget target,
  }) {
    showDialog(
      context: context,
      builder: (context) => _SendNotificationDialog(target: target),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newOrder:
        return Icons.shopping_bag_outlined;
      case NotificationType.orderStatusChange:
        return Icons.local_shipping_outlined;
      case NotificationType.newOffer:
        return Icons.local_offer_outlined;
      case NotificationType.productBackInStock:
        return Icons.inventory_2_outlined;
      case NotificationType.newBanner:
        return Icons.photo_library_outlined;
      case NotificationType.custom:
        return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.newOrder:
        return const Color(0xFF5542F6);
      case NotificationType.orderStatusChange:
        return const Color(0xFF10B981);
      case NotificationType.newOffer:
        return const Color(0xFFFF6B6B);
      case NotificationType.productBackInStock:
        return const Color(0xFF3B82F6);
      case NotificationType.newBanner:
        return const Color(0xFFF59E0B);
      case NotificationType.custom:
        return const Color(0xFF6B7280);
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Send Notification Dialog
// ═══════════════════════════════════════════════════════════════════════════════

class _SendNotificationDialog extends StatefulWidget {
  final NotificationTarget target;

  const _SendNotificationDialog({required this.target});

  @override
  State<_SendNotificationDialog> createState() =>
      _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<_SendNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _userSearchController = TextEditingController();

  late NotificationTarget _target;
  String? _selectedUserId;
  String? _selectedUserName;

  // Sample user data
  final List<Map<String, String>> _users = [
    {'id': 'user1', 'name': 'John Smith', 'email': 'john@example.com'},
    {'id': 'user2', 'name': 'Jane Doe', 'email': 'jane@example.com'},
    {'id': 'user3', 'name': 'Mike Johnson', 'email': 'mike@example.com'},
    {'id': 'user4', 'name': 'Sarah Wilson', 'email': 'sarah@example.com'},
  ];

  @override
  void initState() {
    super.initState();
    _target = widget.target;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 650),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTargetSelector(),
                      if (_target == NotificationTarget.specificUser) ...[
                        const SizedBox(height: 20),
                        _buildUserSelector(),
                      ],
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Notification Title',
                        hint: 'Enter notification title',
                        prefixIcon: Icons.title_outlined,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a title'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _bodyController,
                        label: 'Notification Body',
                        hint: 'Enter notification content',
                        prefixIcon: Icons.message_outlined,
                        maxLines: 4,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter content'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildPreviewSection(),
                    ],
                  ),
                ),
              ),
              _buildDialogActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.send_outlined,
              color: Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Send New Notification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Send To',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTargetOption(
                icon: Icons.people_outline,
                title: 'All Users',
                isSelected: _target == NotificationTarget.allUsers,
                onTap: () => setState(() {
                  _target = NotificationTarget.allUsers;
                  _selectedUserId = null;
                  _selectedUserName = null;
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTargetOption(
                icon: Icons.person_outline,
                title: 'Specific User',
                isSelected: _target == NotificationTarget.specificUser,
                onTap: () => setState(() {
                  _target = NotificationTarget.specificUser;
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTargetOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF6B6B).withOpacity(0.1)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFFF6B6B) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected ? const Color(0xFFFF6B6B) : Colors.grey[700],
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFFF6B6B),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select User',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _userSearchController,
                decoration: InputDecoration(
                  hintText: 'Search for user...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const Divider(height: 1),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final isSelected = _selectedUserId == user['id'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedUserId = user['id'];
                          _selectedUserName = user['name'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: isSelected
                            ? const Color(0xFFFF6B6B).withOpacity(0.1)
                            : null,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  const Color(0xFF5542F6).withOpacity(0.1),
                              child: Text(
                                user['name']![0],
                                style: const TextStyle(
                                  color: Color(0xFF5542F6),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    user['email']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFFFF6B6B),
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
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
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFFF6B6B),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.phone_android_outlined,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Notification Preview',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Color(0xFFFF6B6B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleController.text.isEmpty
                            ? 'Notification Title'
                            : _titleController.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _bodyController.text.isEmpty
                            ? 'Notification content will appear here...'
                            : _bodyController.text,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (_target == NotificationTarget.specificUser &&
                      _selectedUserId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a user'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  // Send notification logic here
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification sent successfully!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Send'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
