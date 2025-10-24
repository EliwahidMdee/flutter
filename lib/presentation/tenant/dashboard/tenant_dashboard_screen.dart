import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/payment_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../common/widgets/dashboard_card.dart';
import '../../common/widgets/loading_indicator.dart';
import '../../../config/theme.dart';
import '../../../core/utils/formatters.dart';

class TenantDashboardScreen extends StatefulWidget {
  const TenantDashboardScreen({super.key});

  @override
  State<TenantDashboardScreen> createState() => _TenantDashboardScreenState();
}

class _TenantDashboardScreenState extends State<TenantDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<PaymentProvider>().fetchPayments(
          tenantId: authProvider.user!.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          // Notifications removed from tenant dashboard (keeps profile menu below)
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
      body: RefreshIndicator(
        onRefresh: () async {
          final authProvider = context.read<AuthProvider>();
          if (authProvider.user != null) {
            await context.read<PaymentProvider>().fetchPayments(
              tenantId: authProvider.user!.id,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome
               Consumer<AuthProvider>(
                 builder: (context, auth, _) {
                   return Text(
                     'Welcome, ${auth.user?.name ?? 'Tenant'}!',
                     style: Theme.of(context).textTheme.headlineSmall,
                   );
                 },
               ),
               const SizedBox(height: 20),

              // Top summary row (3 cards)
              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      title: 'Rent Status',
                      value: 'Due',
                      icon: Icons.home,
                      color: AppTheme.tenantAccent,
                      onTap: () => context.push('/tenant/make-payment'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DashboardCard(
                      title: 'Next Due',
                      value: 'Dec 1',
                      icon: Icons.calendar_month,
                      color: Colors.blue,
                      onTap: () => context.push('/tenant/make-payment'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DashboardCard(
                      title: 'Support',
                      value: '-',
                      icon: Icons.info_outline,
                      color: Colors.grey,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Support coming soon')),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => context.push('/tenant/make-payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.tenantAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text('Make Payment', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push('/tenant/payment-history'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text('Payment History', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push('/tenant/lease'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text('Lease Details', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Additional metrics (3-column grid)
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
                children: [
                  DashboardCard(
                    title: 'Monthly Rent',
                    value: '\$1,200',
                    icon: Icons.attach_money,
                    color: AppTheme.tenantAccent,
                  ),
                  DashboardCard(
                    title: 'Next Due',
                    value: 'Dec 1, 2025',
                    icon: Icons.calendar_today,
                    color: Colors.blue,
                  ),
                  DashboardCard(
                    title: 'Lease Length',
                    value: '12 mo',
                    icon: Icons.timer,
                    color: Colors.purple,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Recent Payments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Payments',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.push('/tenant/payment-history'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Consumer<PaymentProvider>(
                builder: (context, paymentProvider, _) {
                  if (paymentProvider.isLoading) {
                    return const LoadingIndicator(message: 'Loading payments...');
                  }
                  
                  if (paymentProvider.payments.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text('No payment history yet'),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return Column(
                    children: paymentProvider.payments.take(5).map((payment) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            Icons.payment,
                            color: payment.statusColor,
                          ),
                          title: Text(
                            AppFormatters.formatCurrency(payment.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            AppFormatters.formatDate(
                              DateTime.parse(payment.paymentDate),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: payment.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              payment.statusDisplay,
                              style: TextStyle(
                                color: payment.statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          switch (index) {
            case 0:
              // Pay Rent
              context.push('/tenant/make-payment');
              break;
            case 1:
              // History
              context.push('/tenant/payment-history');
              break;
            case 2:
              // Center Home - stay on this screen
              break;
            case 3:
              // Alerts / Notifications
              context.push('/tenant/notifications');
              break;
            case 4:
              // Settings
              context.push('/settings');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.tenantAccent,
        unselectedItemColor: Colors.grey[400],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Pay Rent',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.tenantAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.tenantAccent.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.home, color: Colors.white),
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
