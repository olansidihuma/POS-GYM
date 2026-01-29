import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/membership_controller.dart';
import '../../controllers/member_controller.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import 'package:intl/intl.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MembershipController());
    final memberController = Get.put(MemberController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Subscription'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Membership Package',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Membership Packages
              ...controller.packages.map((package) {
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: InkWell(
                    onTap: () {
                      controller.selectPackage(package);
                      _showMemberSelectionDialog(
                        controller,
                        memberController,
                        package,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                package.name,
                                style: AppTextStyles.heading3,
                              ),
                              Text(
                                NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(package.price),
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(package.description),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Duration: ${package.durationMonths} months',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (package.benefits != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Benefits:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(package.benefits!),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Expiring Memberships
              if (controller.expiringMemberships.isNotEmpty) ...[
                Text(
                  'Expiring Soon',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSpacing.md),
                ...controller.expiringMemberships.map((membership) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    color: AppColors.warning.withOpacity(0.1),
                    child: ListTile(
                      leading: Icon(
                        Icons.warning,
                        color: AppColors.warning,
                      ),
                      title: Text(membership.memberName ?? 'Unknown'),
                      subtitle: Text(
                        'Expires: ${DateFormat('dd MMM yyyy').format(membership.endDate)}',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _showRenewalDialog(controller, membership.memberId);
                        },
                        child: const Text('Renew'),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      }),
    );
  }

  void _showMemberSelectionDialog(
    MembershipController controller,
    MemberController memberController,
    package,
  ) {
    Get.defaultDialog(
      title: 'Select Member',
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 400,
          minHeight: 200,
        ),
        child: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (memberController.members.isEmpty) {
              return const Center(child: Text('No members found'));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: memberController.members.length,
              itemBuilder: (context, index) {
                final member = memberController.members[index];
                return ListTile(
                  title: Text(
                    member.fullName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(member.memberCode),
                  onTap: () {
                    Get.back();
                    _showPaymentDialog(controller, member.id!, package.id!);
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _showRenewalDialog(MembershipController controller, int memberId) {
    Get.defaultDialog(
      title: 'Renew Membership',
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 300,
          minHeight: 150,
        ),
        child: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: controller.packages.length,
              itemBuilder: (context, index) {
                final package = controller.packages[index];
                return ListTile(
                  title: Text(
                    package.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(package.price),
                  ),
                  onTap: () {
                    Get.back();
                    _showPaymentDialog(controller, memberId, package.id!, isRenewal: true);
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _showPaymentDialog(
    MembershipController controller,
    int memberId,
    int packageId, {
    bool isRenewal = false,
  }) {
    String selectedPaymentMethod = 'Cash';
    final referenceController = TextEditingController();

    Get.defaultDialog(
      title: 'Payment',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedPaymentMethod,
            decoration: const InputDecoration(
              labelText: 'Payment Method',
            ),
            items: AppConstants.paymentMethods.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: (value) {
              selectedPaymentMethod = value!;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: referenceController,
            decoration: const InputDecoration(
              labelText: 'Payment Reference (Optional)',
            ),
          ),
        ],
      ),
      textConfirm: 'Process',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        bool success;
        if (isRenewal) {
          success = await controller.renewMembership(
            memberId: memberId,
            packageId: packageId,
            paymentMethod: selectedPaymentMethod,
            paymentReference: referenceController.text,
          );
        } else {
          success = await controller.subscribe(
            memberId: memberId,
            packageId: packageId,
            paymentMethod: selectedPaymentMethod,
            paymentReference: referenceController.text,
          );
        }
        
        if (success) {
          Get.back();
        }
      },
    );
  }
}
