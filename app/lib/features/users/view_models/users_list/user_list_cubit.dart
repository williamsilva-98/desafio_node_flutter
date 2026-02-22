import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/models/user.dart';
import '../../../../data/repositories/user_repository.dart';

part 'user_list_state.dart';

class UserListCubit extends Cubit<UserListState> {
  UserListCubit({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository(),
        super(const UserListState.initial());

  final UserRepository _userRepository;

  Future<void> loadUsers({String? nameFilter, String? emailFilter}) async {
    emit(const UserListState.loading());
    try {
      final users = await _userRepository.getUsers(
        name: nameFilter?.isEmpty == true ? null : nameFilter,
        email: emailFilter?.isEmpty == true ? null : emailFilter,
      );
      emit(UserListState.loaded(users));
    } catch (e) {
      emit(UserListState.failure(e.toString()));
    }
  }
}
