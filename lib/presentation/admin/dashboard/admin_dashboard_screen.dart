import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/dashboard_provider.dart';
import '../../common/providers/notification_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../common/widgets/dashboard_card.dart';
import '../../common/widgets/loading_indicator.dart';
import '../../common/widgets/error_widget.dart';
import '../../../config/theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
      context.read<NotificationProvider>().fetchUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          // Notifications badge
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // TODO: Navigate to notifications
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications screen coming soon'),
                        ),
                      );
                    },
                  ),
                  if (notifProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${notifProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Profile menu
          PopupMenuButton<String>(
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
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          // Navigate based on index
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              context.push('/admin/reports');
              break;
            case 2:
              context.push('/admin/payments');
              break;
            case 3:
              context.push('/admin/tenants');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.adminAccent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.approval),
            label: 'Approvals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Manage',
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<DashboardProvider>().fetchDashboardData();
        await context.read<NotificationProvider>().fetchUnreadCount();
      },
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Text(
                      'Welcome back, ${auth.user?.name ?? 'Admin'}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    );
                  },
                ),
                const SizedBox(height: 20),
                
                // Stats cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    DashboardCard(
                      title: 'Total Properties',
                      value: stats.totalProperties.toString(),
                      icon: Icons.apartment,
                      color: Colors.blue,
                    ),
                    DashboardCard(
                      title: 'Active Tenants',
                      value: stats.activeTenants.toString(),
                      icon: Icons.people,
                      color: Colors.green,
                    ),
                    DashboardCard(
                      title: 'Pending Payments',
                      value: stats.pendingPayments.toString(),
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                      onTap: () => context.push('/admin/payments'),
                    ),
                    DashboardCard(
                      title: 'Monthly Revenue',
                      value: '\$${stats.monthlyRevenue.toStringAsFixed(0)}',
                      icon: Icons.attach_money,
                      color: Colors.purple,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Recent activities section
                if (stats.recentActivities != null && 
                    stats.recentActivities!.isNotEmpty) ...[
                  Text(
                    'Recent Activities',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  
                  // Activity list
                  ...stats.recentActivities!.map((activity) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          _getActivityIcon(activity.type),
                          color: AppTheme.adminAccent,
                        ),
                        title: Text(activity.title),
                        subtitle: Text(activity.description),
                        trailing: Text(
                          activity.timeAgo,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          );
        },
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
