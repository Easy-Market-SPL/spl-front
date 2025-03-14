part of 'users_management_bloc.dart';

class UsersManagementState extends Equatable {
  final List<UserModel> users;

  const UsersManagementState({
    this.users = const [],
  });

  UsersManagementState copyWith({
    List<UserModel>? users,
  }) {
    return UsersManagementState(
      users: users ?? this.users,
    );
  }

  @override
  List<Object?> get props => [users];
}
