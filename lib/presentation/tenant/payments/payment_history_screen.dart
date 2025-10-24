import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/providers/payment_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../common/widgets/loading_indicator.dart';
import '../../common/widgets/error_widget.dart';
import '../../common/widgets/empty_state_widget.dart';
import '../../../core/utils/formatters.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
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
        title: const Text('Payment History'),
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
        child: Consumer<PaymentProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.payments.isEmpty) {
              return const LoadingIndicator(message: 'Loading payments...');
            }

            if (provider.error != null && provider.payments.isEmpty) {
              return ErrorDisplayWidget(
                message: provider.error!,
                onRetry: () {
                  final authProvider = context.read<AuthProvider>();
                  if (authProvider.user != null) {
                    provider.fetchPayments(tenantId: authProvider.user!.id);
                  }
                },
              );
            }

            if (provider.payments.isEmpty) {
              return const EmptyStateWidget(
                message: 'No payment history yet',
                icon: Icons.receipt_long_outlined,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.payments.length,
              itemBuilder: (context, index) {
                final payment = provider.payments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppFormatters.formatCurrency(payment.amount),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
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
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.calendar_today,
                          label: 'Payment Date',
                          value: AppFormatters.formatDate(
                            DateTime.parse(payment.paymentDate),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.payment,
                          label: 'Method',
                          value: AppFormatters.formatPaymentMethod(
                            payment.paymentMethod,
                          ),
                        ),
                        if (payment.referenceNumber != null) ...[
                          const SizedBox(height: 8),
                          _DetailRow(
                            icon: Icons.tag,
                            label: 'Reference',
                            value: payment.referenceNumber!,
                          ),
                        ],
                        if (payment.notes != null) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.note, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  payment.notes!,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.grey),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
