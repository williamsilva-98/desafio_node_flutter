import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../view_models/users_form/user_form_cubit.dart';

class UserFormView extends StatelessWidget {
  const UserFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo usuário'),
      ),
      body: BlocListener<UserFormCubit, UserFormState>(
        listenWhen: (prev, curr) =>
            curr.status != UserFormStatus.initial &&
            curr.status != UserFormStatus.submitting,
        listener: (context, state) {
          if (state.status == UserFormStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuário cadastrado com sucesso.'),
                backgroundColor: Color(0xFF2E7D32),
              ),
            );
            Navigator.of(context).pop(true);
            return;
          }
          
          if (state.status == UserFormStatus.validationError ||
              state.status == UserFormStatus.apiError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Erro'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: _UserFormFields(),
        ),
      ),
    );
  }
}

class _UserFormFields extends StatefulWidget {
  const _UserFormFields();

  @override
  State<_UserFormFields> createState() => _UserFormFieldsState();
}

class _UserFormFieldsState extends State<_UserFormFields> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<UserFormCubit>().submit(
          name: _nameController.text,
          email: _emailController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserFormCubit, UserFormState>(
      buildWhen: (prev, curr) => curr.status == UserFormStatus.submitting,
      builder: (context, state) {
        final isSubmitting = state.status == UserFormStatus.submitting;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Ex.: João Silva',
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _emailFocus.requestFocus(),
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              focusNode: _emailFocus,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                hintText: 'Ex.: joao@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: isSubmitting ? null : _submit,
              child: isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Cadastrar'),
            ),
          ],
        );
      },
    );
  }
}
