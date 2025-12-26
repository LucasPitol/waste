import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_ai_app/models/wallet_member.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision_controller.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision_skeleton.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/remove_member_modal.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:meudin_ai_app/services/wallet_service.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class WalletMembersWidget extends StatelessWidget {
  final WalletVisionWidgetController controller;
  final bool isWalletOwner;
  final String walletId;

  const WalletMembersWidget({
    super.key,
    required this.controller,
    required this.isWalletOwner,
    required this.walletId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (controller.isLoadingMembers) {
      return const WalletMembersSkeleton();
    }

    if (controller.membersError != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark 
              ? theme.colorScheme.surface 
              : Styles.whiteColor,
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark 
                  ? Colors.black.withOpacity(0.3)
                  : Styles.greyLighter,
              offset: const Offset(0, 2),
              blurRadius: 2,
            ),
          ],
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                controller.membersError!,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color ?? Styles.primaryTextColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? theme.colorScheme.surface 
            : Styles.whiteColor,
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.3)
                : Styles.greyLighter,
            offset: const Offset(0, 2),
            blurRadius: 2,
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with "Add Member" button (only for owner)
          if (isWalletOwner)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Membros',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToAddMember(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.plus,
                        size: 14,
                        color: Styles.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Adicionar membro',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Styles.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Membros',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                ),
              ),
            ),
          
          // Members list
          if (controller.members.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Nenhum membro encontrado',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey.shade600,
                  ),
                ),
              ),
            )
          else
            Column(
              children: controller.members.map((member) {
                final currentUserId = UserService.currentUser?.id;
                final isCurrentUser = member.id == currentUserId;
                final isOwner = member.isOwner;
                // Dono não pode ser removido
                final canRemove = isWalletOwner && !isOwner;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    member.name?.isNotEmpty == true 
                                        ? member.name! 
                                        : (member.email ?? ''),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                                    ),
                                  ),
                                ),
                                if (isOwner)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Styles.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Dono',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Styles.primaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (member.name?.isNotEmpty == true && member.email?.isNotEmpty == true)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  member.email!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            if (isCurrentUser && !isOwner)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '(Você)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Styles.primaryColor,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (canRemove)
                        PopupMenuButton<String>(
                          icon: FaIcon(
                            FontAwesomeIcons.ellipsisVertical,
                            size: 16,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey.shade600,
                          ),
                          onSelected: (value) {
                            if (value == 'remove') {
                              _showRemoveMemberModal(context, member);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'remove',
                              child: Row(
                                children: [
                                  const FaIcon(
                                    FontAwesomeIcons.trash,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remover',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddMember(BuildContext context) async {
    if (walletId.isEmpty) return;

    final result = await Get.toNamed(
      AppRoutes.addMemberRoute,
      arguments: walletId,
    );

    if (result == true && walletId.isNotEmpty) {
      // Refresh members list
      await controller.loadMembers(walletId);
    }
  }

  Future<void> _showRemoveMemberModal(BuildContext context, WalletMember member) async {
    final theme = Theme.of(context);
    bool? confirmed;

    await Get.bottomSheet(
      RemoveMemberModal(
        memberName: member.name ?? '',
        memberEmail: member.email ?? '',
        onConfirm: () {
          confirmed = true;
        },
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
    );

    if (confirmed == true && member.id != null && walletId.isNotEmpty) {
      // Show loading
      controller.isLoadingMembers = true;
      controller.update();

      try {
        final walletService = WalletService();
        final response = await walletService.removeMemberFromWallet(
          walletId,
          member.id!,
        );

        if (response.success) {
          // Refresh members list
          await controller.loadMembers(walletId);
        } else {
          controller.isLoadingMembers = false;
          controller.update();
          
          Get.bottomSheet(
            JoyModal.errorBottomSheet(
              context: Get.context!,
              errorList: [response.errorMessage ?? 'Erro ao remover membro'],
              title: 'Erro ao remover membro',
            ),
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            backgroundColor: Colors.transparent,
          );
        }
      } catch (e) {
        controller.isLoadingMembers = false;
        controller.update();
        
        Get.bottomSheet(
          JoyModal.errorBottomSheet(
            context: Get.context!,
            errorList: ['Erro ao remover membro: $e'],
            title: 'Erro ao remover membro',
          ),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Colors.transparent,
        );
      }
    }
  }
}
