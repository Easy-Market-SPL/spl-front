import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/pages/auth/login/login_page.dart';
import 'package:spl_front/pages/auth/login/login_page_variant.dart';
import 'package:spl_front/pages/auth/login/login_page_web.dart';
import 'package:spl_front/pages/auth/register/register_page.dart';
import 'package:spl_front/pages/auth/register/register_page_variant.dart';
import 'package:spl_front/spl/spl_variables.dart';

Widget loginPageFactory(BuildContext ctx) {
  if (kIsWeb) {
    return WebLoginPage();
  }
  if (SPLVariables.hasThirdAuth) {
    return LoginPageVariant();
  }
  return LoginPage();
}

Widget registerPageFactory(BuildContext ctx) {
  if (SPLVariables.hasThirdAuth) {
    return RegisterPageVariant();
  }
  return RegisterPage();
}