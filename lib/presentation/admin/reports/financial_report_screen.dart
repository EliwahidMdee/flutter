import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Use canonical provider/widgets with package imports
import 'package:rental_management_app/presentation/common/providers/report_provider.dart';
import 'package:rental_management_app/presentation/common/widgets/loading_indicator.dart';
import 'package:rental_management_app/presentation/common/widgets/error_widget.dart' as errw;

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Initial load for first tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().load(ReportTab.revenue);
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final provider = context.read<ReportProvider>();
      switch (_tabController.index) {
        case 0:
          provider.load(ReportTab.revenue);
          break;
        case 1:
          provider.load(ReportTab.expenses);
          break;
        case 2:
          provider.load(ReportTab.profitLoss);
          break;
        case 3:
          provider.load(ReportTab.balanceSheet);
          break;
        case 4:
          provider.load(ReportTab.occupancy);
          break;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Revenue'),
            Tab(text: 'Expenses'),
            Tab(text: 'Profit & Loss'),
            Tab(text: 'Balance Sheet'),
            Tab(text: 'Occupancy'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Select date range',
            icon: const Icon(Icons.date_range),
            onPressed: _pickRange,
          ),
          PopupMenuButton<String>(
            tooltip: 'Open report detail',
            onSelected: (val) {
              final tab = _tabToEnum(_tabController.index);
              final route = _routeFor(tab, val);
              if (route != null) context.push(route);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'summary', child: Text('Open summary view')),
              PopupMenuItem(value: 'detailed', child: Text('Open detailed view')),
            ],
            icon: const Icon(Icons.open_in_new),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final idx = _tabController.index;
              final provider = context.read<ReportProvider>();
              provider.clearError();
              provider.load(_tabToEnum(idx));
            },
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (BuildContext context, ReportProvider provider, Widget? _) {
          if (provider.isLoading && provider.error == null) {
            return LoadingIndicator(message: 'Loading report...');
          }

          if (provider.error != null) {
            return errw.ErrorDisplayWidget(
              message: provider.error!,
              onRetry: () => provider.load(_tabToEnum(_tabController.index)),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildReportView(context, 'Revenue', provider.revenueData),
              _buildReportView(context, 'Expenses', provider.expensesData),
              _buildReportView(context, 'Profit & Loss', provider.profitLossData),
              _buildReportView(context, 'Balance Sheet', provider.balanceSheetData),
              _buildReportView(context, 'Occupancy', provider.occupancyData),
            ],
          );
        },
      ),
    );
  }

  ReportTab _tabToEnum(int index) {
    switch (index) {
      case 0:
        return ReportTab.revenue;
      case 1:
        return ReportTab.expenses;
      case 2:
        return ReportTab.profitLoss;
      case 3:
        return ReportTab.balanceSheet;
      case 4:
      default:
        return ReportTab.occupancy;
    }
  }

  Future<void> _pickRange() async {
    final provider = context.read<ReportProvider>();
    final now = DateTime.now();
    final initialDateRange = provider.range ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );

    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: initialDateRange,
      helpText: 'Select date range',
    );

    if (!mounted) return;
    await provider.setRange(selected, tabsToRefresh: [
      ReportTab.revenue,
      ReportTab.expenses,
      ReportTab.profitLoss,
      ReportTab.balanceSheet,
      ReportTab.occupancy,
    ]);
  }

  Widget _buildReportView(BuildContext context, String title, Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return Center(
        child: Text(
          'No $title data',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final numericEntries = data.entries
        .where((e) => e.value is num)
        .toList();

    final listEntries = data.entries
        .where((e) => e.value is List)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (numericEntries.isNotEmpty) ...[
              const Text(
                'Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: numericEntries
                    .map((e) => _metricChip(e.key, e.value as num))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            for (final entry in listEntries) ...[
              Text(
                _humanize(entry.key),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildListSection(entry.value as List),
              const SizedBox(height: 24),
            ],

            // Fallback raw JSON view
            const Text(
              'Raw Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(data),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricChip(String label, num value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _humanize(label),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(List list) {
    if (list.isEmpty) {
      return Text('No items', style: TextStyle(color: Colors.grey[600]));
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        shrinkWrap: true,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final item = list[index];
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            final title = map.entries.firstWhere(
              (e) => e.key.toLowerCase().contains('title') || e.key.toLowerCase().contains('name'),
              orElse: () => map.entries.first,
            );
            return ListTile(
              title: Text(title.value.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(map.entries.map((e) => '${_humanize(e.key)}: ${e.value}').join(' • '),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            );
          }
          return ListTile(title: Text(item.toString()));
        },
      ),
    );
  }

  String _humanize(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  String? _routeFor(ReportTab tab, String type) {
    // type: 'summary' | 'detailed'
    switch (tab) {
      case ReportTab.revenue:
        // revenue maps to income-statement routes in our router for now
        return '/admin/reports/income-statement/${type}';
      case ReportTab.expenses:
        return '/admin/reports/income-statement/${type}';
      case ReportTab.profitLoss:
        return '/admin/reports/income-statement/${type}';
      case ReportTab.balanceSheet:
        return '/admin/reports/balance-sheet/${type}';
      case ReportTab.occupancy:
        return '/admin/reports/occupancy/${type}';
      default:
        return null;
    }
  }
}
