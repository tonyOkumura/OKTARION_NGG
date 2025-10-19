import 'package:get/get.dart';
import '../../../../core/core.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxnString errorText = RxnString();

  Future<void> loadData() async {
    isLoading.value = true;
    errorText.value = null;
    try {
      LogService.i('🏠 Loading home data...');
      // TODO: Implement actual data loading
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      LogService.i('✅ Home data loaded successfully');
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to load home data: $e', e, stackTrace);
      errorText.value = 'Не удалось загрузить данные';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }
}
