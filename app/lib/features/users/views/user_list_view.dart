import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../view_models/users_list/user_list_cubit.dart';
import '../view_models/users_form/user_form_cubit.dart';
import 'user_form_view.dart';

class UserListView extends StatelessWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserListCubit>()..loadUsers(),
      child: const _UserListContent(),
    );
  }
}

class _UserListContent extends StatefulWidget {
  const _UserListContent();

  @override
  State<_UserListContent> createState() => _UserListContentState();
}

class _UserListContentState extends State<_UserListContent> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _applyFilters(BuildContext context) {
    context.read<UserListCubit>().loadUsers(
          nameFilter: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
          emailFilter: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => getIt<UserFormCubit>(),
                    child: const UserFormView(),
                  ),
                ),
              );
              if (context.mounted && added == true) {
                context.read<UserListCubit>().loadUsers();
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FiltersSection(
            nameController: _nameController,
            emailController: _emailController,
            onApply: () => _applyFilters(context),
          ),
          const Expanded(child: _UserListBody()),
        ],
      ),
    );
  }
}

class _FiltersSection extends StatelessWidget {
  const _FiltersSection({
    required this.nameController,
    required this.emailController,
    required this.onApply,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filtrar',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Nome',
                    isDense: true,
                  ),
                  onSubmitted: (_) => onApply(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'E-mail',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) => onApply(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Buscar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListBody extends StatelessWidget {
  const _UserListBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserListCubit, UserListState>(
      builder: (context, state) {
        switch (state.status) {
          case UserListStatus.initial:
          case UserListStatus.loading:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case UserListStatus.failure:
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'Erro ao carregar',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          case UserListStatus.loaded:
            final users = state.users;
            if (users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum usuário encontrado',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<UserListCubit>().loadUsers(),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        user.email,
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
        }
      },
    );
  }
}
