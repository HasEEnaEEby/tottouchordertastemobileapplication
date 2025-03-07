import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_colors.dart';

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<ProfileInfoItem> items;
  final bool showTopBorder;
  final bool showBottomBorder;
  final VoidCallback? onTapHeader;

  const ProfileInfoCard({
    super.key,
    required this.title,
    this.icon,
    required this.items,
    this.showTopBorder = true,
    this.showBottomBorder = true,
    this.onTapHeader,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.secondaryDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          InkWell(
            onTap: onTapHeader,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (icon != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (onTapHeader != null) const Spacer(),
                  if (onTapHeader != null)
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          ),

          // Divider
          if (showTopBorder)
            Divider(
              height: 1,
              thickness: 1,
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            ),

          // Card Items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Column(
              children: [
                InkWell(
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        // Item Icon
                        if (item.icon != null)
                          Icon(
                            item.icon,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        if (item.icon != null) const SizedBox(width: 12),

                        // Item Title
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),

                        // Item Value
                        if (item.value.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              item.value,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.grey.shade400
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),

                        // Custom Trailing Widget
                        if (item.trailing != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: item.trailing!,
                          ),

                        // Navigation indicator if onTap present and no custom trailing
                        if (item.onTap != null && item.trailing == null)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.chevron_right,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (!isLast || showBottomBorder)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: item.icon != null ? 40 : 16,
                    endIndent: 16,
                    color: isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class ProfileInfoItem {
  final IconData? icon;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ProfileInfoItem({
    this.icon,
    required this.title,
    required this.value,
    this.onTap,
    this.trailing,
  });
}
