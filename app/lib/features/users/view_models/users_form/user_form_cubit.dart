import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../data/models/user.dart';
import '../../../../data/repositories/user_repository.dart';

part 'user_form_state.dart';

class UserFormCubit extends Cubit<UserFormState> {
  final UserRepository _userRepository;
  
  UserFormCubit({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository(),
      super(const UserFormState.initial());


  Future<void> submit({required String name, required String email}) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty) {
      emit(const UserFormState.validationError('Nome é obrigatório.'));
      return;
    }
    if (trimmedEmail.isEmpty) {
      emit(const UserFormState.validationError('E-mail é obrigatório.'));
      return;
    }

    emit(const UserFormState.submitting());
    try {
      final user = await _userRepository.createUser(
        name: trimmedName,
        email: trimmedEmail,
      );
      emit(UserFormState.success(user));
    } on ApiException catch (e) {
      emit(UserFormState.apiError(e.message));
    } catch (e) {
      emit(
        UserFormState.apiError('Não foi possível cadastrar. Tente novamente.'),
      );
    }
  }

  void reset() {
    emit(const UserFormState.initial());
  }
}
