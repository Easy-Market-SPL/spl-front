part of 'users_management_bloc.dart';

abstract class UsersManagementEvent extends Equatable {
  const UsersManagementEvent();

  @override
  List<Object> get props => [];
}

class OnLoadUsersEvent extends UsersManagementEvent {
  final List<UserModel> users;

  const OnLoadUsersEvent(this.users);
}

class OnAddUserEvent extends UsersManagementEvent {
  final UserModel user;

  const OnAddUserEvent(this.user);

  @override
  List<Object> get props => [user];
}

class OnUpdateUserEvent extends UsersManagementEvent {
  final UserModel user;

  const OnUpdateUserEvent(this.user);

  @override
  List<Object> get props => [user];
}

class OnSoftDeleteUserEvent extends UsersManagementEvent {
  final UserModel user;

  const OnSoftDeleteUserEvent(this.user);

  @override
  List<Object> get props => [user];
}

class OnPermanentDeleteUserEvent extends UsersManagementEvent {
  final UserModel user;

  const OnPermanentDeleteUserEvent(this.user);

  @override
  List<Object> get props => [user];
}

class OnRestoreUserEvent extends UsersManagementEvent {
  final UserModel user;

  const OnRestoreUserEvent(this.user);

  @override
  List<Object> get props => [user];
}
