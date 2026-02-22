part of 'user_list_cubit.dart';

enum UserListStatus { initial, loading, loaded, failure }

class UserListState extends Equatable {
  final UserListStatus status;
  final List<User> users;
  final String? errorMessage;
  
  const UserListState._({
    required this.status,
    this.users = const [],
    this.errorMessage,
  });

  const UserListState.initial()
      : this._(status: UserListStatus.initial);

  const UserListState.loading()
      : this._(status: UserListStatus.loading);

  const UserListState.loaded(List<User> users)
      : this._(status: UserListStatus.loaded, users: users);

  const UserListState.failure(String errorMessage)
      : this._(status: UserListStatus.failure, errorMessage: errorMessage);


  @override
  List<Object?> get props => [status, users, errorMessage];
}
