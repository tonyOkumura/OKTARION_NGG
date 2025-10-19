import 'package:flutter/material.dart';
import 'package:get/get.dart';
//
import '../../../../core/core.dart';

class MainController extends GetxController {
  final RxString title = 'Главная'.obs;
  final PageController pageController = PageController();
  final RxInt selectedIndex = 0.obs;
  // Mock badges (can be wired to real counters later)
  final RxInt unreadMessages = 0.obs;
  final RxInt pendingContacts = 0.obs;
  final RxInt tasksOpen = 0.obs;
  final RxInt eventsToday = 0.obs;
  final RxInt totalNotifications = 0.obs;

  void onPageChanged(int index) {
    switch (index) {
      case 0:
        title.value = 'Главная';
        break;
      case 1:
        title.value = 'Контакты';
        break;
      case 2:
        title.value = 'Сообщения';
        break;
      case 3:
        title.value = 'Задачи';
        break;
      case 4:
        title.value = 'События';
        break;
      case 5:
        title.value = 'Файлы';
        break;
      case 6:
        title.value = 'Настройки';
        break;
    }
    selectedIndex.value = index;
  }

  void onSidebarTapped(int index) {
    pageController.jumpToPage(index);
    onPageChanged(index);
  }

  void signOut() async {
    try {
      LogService.i('🚪 Signing out from MainController...');
      
      // Выходим из Supabase
      await SupabaseService.instance.signOut();
      
      LogService.i('✅ Successfully signed out from MainController');
      
      

      
    } catch (e, stackTrace) {
      LogService.e('❌ Sign out failed from MainController: $e', e, stackTrace);
      


    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
