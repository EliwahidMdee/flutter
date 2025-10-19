import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/dashboard_provider.dart';
import '../../common/providers/property_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../common/widgets/dashboard_card.dart';
import '../../common/widgets/loading_indicator.dart';
import '../../common/widgets/error_widget.dart';
import '../../../config/theme.dart';

class LandlordDashboardScreen extends StatefulWidget {
  const LandlordDashboardScreen({Key? key}) : super(key: key);

  @override
  State<LandlordDashboardScreen> createState() => _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends State<LandlordDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
      context.read<PropertyProvider>().fetchProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landlord Dashboard'),
        actions: [
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
          await context.read<DashboardProvider>().fetchDashboardData();
          await context.read<PropertyProvider>().fetchProperties();
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
                  // Welcome
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return Text(
                        'Hello, ${auth.user?.name ?? 'Landlord'}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Stats
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      DashboardCard(
                        title: 'My Properties',
                        value: stats.totalProperties.toString(),
                        icon: Icons.apartment,
                        color: AppTheme.landlordAccent,
                        onTap: () => context.push('/landlord/properties'),
                      ),
                      DashboardCard(
                        title: 'Active Tenants',
                        value: stats.activeTenants.toString(),
                        icon: Icons.people,
                        color: Colors.blue,
                        onTap: () => context.push('/landlord/tenants'),
                      ),
                      DashboardCard(
                        title: 'Occupancy Rate',
                        value: stats.occupancyRate != null 
                            ? '${(stats.occupancyRate! * 100).toStringAsFixed(0)}%'
                            : 'N/A',
                        icon: Icons.business,
                        color: Colors.orange,
                      ),
                      DashboardCard(
                        title: 'Monthly Revenue',
                        value: '\$${stats.monthlyRevenue.toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Properties
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Properties',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () => context.push('/landlord/properties'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Consumer<PropertyProvider>(
                    builder: (context, propProvider, _) {
                      if (propProvider.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      if (propProvider.properties.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.home_work_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text('No properties yet'),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => 
                                      context.push('/landlord/properties/add'),
                                  child: const Text('Add Property'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return Column(
                        children: propProvider.properties.take(3).map((property) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.apartment),
                              title: Text(property.name),
                              subtitle: Text(property.address),
                              trailing: Text(
                                '${property.occupiedUnits ?? 0}/${property.totalUnits} units',
                              ),
                              onTap: () => context.push(
                                '/landlord/properties/${property.id}',
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
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
              // Already on dashboard
              break;
            case 1:
              context.push('/landlord/properties');
              break;
            case 2:
              context.push('/landlord/payments');
              break;
            case 3:
              context.push('/landlord/tenants');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.landlordAccent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Properties',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tenants',
          ),
        ],
      ),
    );
  }
}
