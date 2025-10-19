import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/providers/payment_provider.dart';
import '../../common/widgets/loading_indicator.dart';
import '../../common/widgets/error_widget.dart';
import '../../common/widgets/empty_state_widget.dart';
import '../../../core/utils/formatters.dart';

class PaymentApprovalScreen extends StatefulWidget {
  const PaymentApprovalScreen({Key? key}) : super(key: key);

  @override
  State<PaymentApprovalScreen> createState() => _PaymentApprovalScreenState();
}

class _PaymentApprovalScreenState extends State<PaymentApprovalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().fetchPendingPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Approvals'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<PaymentProvider>().fetchPendingPayments(),
        child: Consumer<PaymentProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.pendingPayments.isEmpty) {
              return const LoadingIndicator(message: 'Loading payments...');
            }

            if (provider.error != null && provider.pendingPayments.isEmpty) {
              return ErrorDisplayWidget(
                message: provider.error!,
                onRetry: () => provider.fetchPendingPayments(),
              );
            }

            if (provider.pendingPayments.isEmpty) {
              return const EmptyStateWidget(
                message: 'No pending payments',
                icon: Icons.check_circle_outline,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.pendingPayments.length,
              itemBuilder: (context, index) {
                final payment = provider.pendingPayments[index];
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
                        if (payment.tenant != null)
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16),
                              const SizedBox(width: 8),
                              Text(payment.tenant!.name),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              AppFormatters.formatDate(
                                DateTime.parse(payment.paymentDate),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.payment, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              AppFormatters.formatPaymentMethod(
                                payment.paymentMethod,
                              ),
                            ),
                          ],
                        ),
                        if (payment.notes != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Notes: ${payment.notes}',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // TODO: Implement reject
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Reject feature coming soon'),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final success = await provider.approvePayment(
                                    payment.id,
                                  );
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Payment approved successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Approve'),
                              ),
                            ),
                          ],
                        ),
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
