import 'package:get/get.dart';
import 'package:mny_champ/app/features/authentication/bindings/authentication_binding.dart';
import 'package:mny_champ/app/features/authentication/views/screens/authentication_screen.dart';
import 'package:mny_champ/app/features/login/bindings/login_binding.dart';
import 'package:mny_champ/app/features/login/views/screens/login_screen.dart';
import 'package:mny_champ/app/features/mainpage/bindings/mainpage_binding.dart';
import 'package:mny_champ/app/features/mainpage/views/views/mainpage_screen.dart';
import 'package:mny_champ/app/features/registration/bindings/registration_binding.dart';
import 'package:mny_champ/app/features/registration/views/screens/registration_screen.dart';
import 'package:mny_champ/app/features/splash/views/screens/splash_screen.dart';

part 'app_routes.dart';

abstract class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: _Paths.splash,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: _Paths.login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.registration,
      page: () => RegistrationScreen(),
      binding: RegistrationBinding(),
    ),
    GetPage(
        name: _Paths.authentication,
        page: () => AuthenticationScreen(),
        transition: Transition.cupertino,
        binding: AuthenticationBinding()),
    GetPage(
      name: _Paths.mainpage,
      page: () => MainPageScreen(),
      binding: MainPageBinding(),
    )
  ];
}