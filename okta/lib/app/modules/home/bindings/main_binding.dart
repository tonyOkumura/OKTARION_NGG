import 'package:get/get.dart';
import 'package:okta/app/modules/home/controllers/home_controller.dart';
import 'package:okta/app/modules/home/controllers/main_controller.dart';
import 'package:okta/app/modules/settings/controllers/settings_controller.dart';
import 'package:okta/app/modules/contacts/controllers/contacts_controller.dart';
import 'package:okta/app/modules/messages/controllers/messages_controller.dart';
import 'package:okta/app/modules/tasks/controllers/tasks_controller.dart';
import 'package:okta/app/modules/events/controllers/events_controller.dart';
import 'package:okta/app/modules/files/controllers/files_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainController>(
      MainController(),
    );
    Get.put<HomeController>(
      HomeController(),
    );
    Get.put<SettingsController>(
      SettingsController(),
    );
    Get.put<ContactsController>(
      ContactsController(),
    );
    Get.put<MessagesController>(
      MessagesController(),
    );
    Get.put<TasksController>(
      TasksController(),
    );
    Get.put<EventsController>(
      EventsController(),
    );
    Get.put<FilesController>(
      FilesController(),
    );
  }
}