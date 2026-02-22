part of 'user_form_cubit.dart';

enum UserFormStatus { initial, submitting, success, validationError, apiError }

class UserFormState extends Equatable {
  const UserFormState._({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const UserFormState.initial()
      : this._(status: UserFormStatus.initial);

  const UserFormState.submitting()
      : this._(status: UserFormStatus.submitting);

  const UserFormState.success(User user)
      : this._(status: UserFormStatus.success, user: user);

  const UserFormState.validationError(String message)
      : this._(status: UserFormStatus.validationError, errorMessage: message);

  const UserFormState.apiError(String message)
      : this._(status: UserFormStatus.apiError, errorMessage: message);

  final UserFormStatus status;
  final User? user;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, user, errorMessage];
}
