import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/dashboard_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../common/widgets/dashboard_card.dart';
import '../../common/widgets/loading_indicator.dart';
import '../../common/widgets/error_widget.dart';
import '../../../config/theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // default to the center Dashboard button (index 2)
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined, color: Colors.black87),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.adminAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_outline, color: AppTheme.adminAccent),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                context.push('/profile');
              } else if (value == 'settings') {
                context.push('/settings');
              } else if (value == 'logout') {
                context.read<AuthProvider>().logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });

                switch (index) {
                  case 0:
                    // Reports
                    context.push('/admin/reports');
                    break;
                  case 1:
                    // Approvals
                    context.push('/admin/payments');
                    break;
                  case 2:
                    // Dashboard (center) - stay on this screen
                    break;
                  case 3:
                    // Manage tenants
                    context.push('/admin/tenants');
                    break;
                  case 4:
                    // Settings
                    context.push('/settings');
                    break;
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.adminAccent,
              unselectedItemColor: Colors.grey[400],
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.assessment_outlined),
                  activeIcon: Icon(Icons.assessment),
                  label: 'Reports',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.approval_outlined),
                  activeIcon: Icon(Icons.approval),
                  label: 'Approvals',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.dashboard_outlined),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.adminAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.adminAccent.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.dashboard, color: Colors.white),
                  ),
                  label: 'Dashboard',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Manage',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getBody() {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<DashboardProvider>().fetchDashboardData();
      },
      color: AppTheme.adminAccent,
      child: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.stats == null) {
            return const LoadingIndicator(message: 'Loading dashboard...');
          }

          if (provider.error != null && provider.stats == null) {
            return ErrorDisplayWidget(
              message: provider.error!,
              onRetry: () => provider.fetchDashboardData(),
            );
          }

          final stats = provider.stats;
          if (stats == null) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with gradient
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            auth.user?.name ?? 'Admin',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Cards
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildModernCard(
                              title: 'Properties',
                              value: stats.totalProperties.toString(),
                              icon: Icons.apartment,
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade400, Colors.blue.shade700],
                              ),
                              onTap: () => context.push('/admin'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildModernCard(
                              title: 'Tenants',
                              value: stats.activeTenants.toString(),
                              icon: Icons.people,
                              gradient: LinearGradient(
                                colors: [Colors.green.shade400, Colors.green.shade700],
                              ),
                              onTap: () => context.push('/admin/tenants'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildModernCard(
                        title: 'Payments Due',
                        value: stats.pendingPayments.toString(),
                        icon: Icons.pending_actions,
                        subtitle: 'Requires attention',
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade400, Colors.red.shade600],
                        ),
                        isWide: true,
                        onTap: () => context.push('/admin/payments'),
                      ),

                      const SizedBox(height: 28),

                      // Quick Actions
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildActionButton(
                              label: 'Add Property',
                              icon: Icons.add_home_work,
                              color: Colors.blue.shade700,
                              onTap: () => context.push('/landlord/properties/add'),
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              label: 'Add Tenant',
                              icon: Icons.person_add,
                              color: Colors.green.shade700,
                              onTap: () => context.push('/admin/tenants'),
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              label: 'Payments',
                              icon: Icons.payment,
                              color: Colors.orange.shade700,
                              onTap: () => context.push('/admin/payments'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Financial Metrics
                      const Text(
                        'Financial Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Monthly Revenue',
                              value: '\$${stats.monthlyRevenue.toStringAsFixed(0)}',
                              icon: Icons.trending_up,
                              color: Colors.purple.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Total Revenue',
                              value: stats.totalRevenue != null
                                  ? '\$${stats.totalRevenue!.toStringAsFixed(0)}'
                                  : '-',
                              icon: Icons.account_balance_wallet,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Property Metrics
                      const Text(
                        'Property Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Occupied',
                              value: stats.occupiedUnits?.toString() ?? '-',
                              icon: Icons.home_work,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Total Units',
                              value: stats.totalUnits?.toString() ?? '-',
                              icon: Icons.view_compact,
                              color: Colors.brown.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Occupancy Rate',
                              value: stats.occupancyRate != null
                                  ? '${stats.occupancyRate!.toStringAsFixed(1)}%'
                                  : '-',
                              icon: Icons.show_chart,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Recent Leases',
                              value: stats.recentActivities?.length.toString() ?? '0',
                              icon: Icons.description,
                              color: Colors.deepOrange.shade700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Recent Activities
                      if (stats.recentActivities != null &&
                          stats.recentActivities!.isNotEmpty) ...[
                        const Text(
                          'Recent Activities',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        ...stats.recentActivities!.map((activity) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.adminAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getActivityIcon(activity.type),
                                  color: AppTheme.adminAccent,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                activity.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  activity.description,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              trailing: Text(
                                activity.timeAgo,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
    String? subtitle,
    bool isWide = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                if (isWide)
                  Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.7), size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return Icons.payment;
      case 'tenant':
        return Icons.person_add;
      case 'property':
        return Icons.home_work;
      case 'lease':
        return Icons.description;
      default:
        return Icons.info;
    }
  }
}
