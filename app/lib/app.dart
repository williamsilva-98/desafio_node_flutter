import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/users/views/user_list_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usuários',
      theme: AppTheme.light,
      home: const UserListView(),
    );
  }
}
