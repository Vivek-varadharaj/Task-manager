import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:task_manager_app/common/widgets/custom_svg_image.dart';
import 'package:task_manager_app/features/dashboard/controllers/dash_board_controller.dart';
import 'package:task_manager_app/features/home/screens/home_screen.dart';
import 'package:task_manager_app/features/profile/screens/profile_screen.dart';
import 'package:task_manager_app/util/app_colors.dart';
import 'package:task_manager_app/util/app_text_styles.dart';
import 'package:task_manager_app/util/app_texts.dart';
import 'package:task_manager_app/util/dimensions.dart';
import 'package:task_manager_app/util/images.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        Provider.of<DashboardController>(context, listen: false).toggleTabs(0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<DashboardController>(
          builder: (context, controller, child) {
            return Center(
              child: controller.selectedIndex == 0
                  ? const HomeScreen()
                  : const ProfileScreen(),
            );
          },
        ),
      ),
      bottomNavigationBar: Consumer<DashboardController>(
        builder: (context, controller, child) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusInfinity),
              color: AppColors.neutral0,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26747474),
                  offset: Offset(0, 4),
                  blurRadius: 25,
                  spreadRadius: 0,
                ),
              ],
            ),
            margin: const EdgeInsets.all(20),
            child: GNav(haptic: true, tabs: [
              GButton(
                haptic: true,
                onPressed: () {
                  controller.toggleTabs(0);
                },
                icon: Icons.abc,
                backgroundColor: AppColors.primary400,
                leading: CustomSvgImage(
                  width: 24,
                  height: 24,
                  assetPath: Images.home,
                  color: controller.selectedIndex == 0
                      ? AppColors.neutral0
                      : AppColors.neutral60,
                ),
                text: '  ${AppTexts.home}',
                textStyle: AppTextStyles.latoPara.copyWith(
                    color: AppColors.neutral0, fontWeight: FontWeight.w600),
              ),
              GButton(
                haptic: true,
                onPressed: () {
                  controller.toggleTabs(2);
                },
                backgroundColor: AppColors.primary400,
                icon: Icons.people,
                text: '  ${AppTexts.profile}',
                textStyle: AppTextStyles.latoPara.copyWith(
                    color: AppColors.neutral0, fontWeight: FontWeight.w600),
                leading: CustomSvgImage(
                  width: 24,
                  height: 24,
                  assetPath: Images.profile,
                  color: controller.selectedIndex == 2
                      ? AppColors.neutral0
                      : AppColors.neutral60,
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}
