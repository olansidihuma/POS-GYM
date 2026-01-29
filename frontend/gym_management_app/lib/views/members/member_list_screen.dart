import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/member_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class MemberListScreen extends StatelessWidget {
  const MemberListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberController());
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(AppRoutes.memberForm),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
              ),
              onChanged: (value) {
                controller.searchMembers(value);
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.members.isEmpty) {
                return const LoadingWidget();
              }

              if (controller.members.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No members found',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return isTablet
                  ? _buildGridView(controller)
                  : _buildListView(controller);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(MemberController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchMembers(refresh: true),
      child: ListView.builder(
        itemCount: controller.members.length,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemBuilder: (context, index) {
          final member = controller.members[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: member.isMembershipActive
                    ? AppColors.success
                    : AppColors.error,
                child: Text(
                  member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                member.fullName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.memberCode,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Expires: ${member.membershipExpiry != null ? member.membershipExpiry.toString().split(' ')[0] : 'N/A'}',
                    style: TextStyle(
                      color: member.isMembershipActive
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    Get.toNamed(AppRoutes.memberForm, arguments: member);
                  } else if (value == 'delete') {
                    _confirmDelete(controller, member.id!);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(MemberController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.2,
      ),
      itemCount: controller.members.length,
      itemBuilder: (context, index) {
        final member = controller.members[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: member.isMembershipActive
                      ? AppColors.success
                      : AppColors.error,
                  child: Text(
                    member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Flexible(
                  child: Text(
                    member.fullName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  member.memberCode,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: () {
                        Get.toNamed(AppRoutes.memberForm, arguments: member);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: () {
                        _confirmDelete(controller, member.id!);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(MemberController controller, int memberId) {
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this member?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        controller.deleteMember(memberId);
        Get.back();
      },
    );
  }
}
