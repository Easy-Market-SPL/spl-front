part of 'users_bloc.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object> get props => [];
}

class OnUpdateSessionUserEvent extends UsersEvent {
  final UserModel? user;
  const OnUpdateSessionUserEvent(this.user);
}

class OnCreateExternalUserEvent extends UsersEvent {
  final UserModel user;
  
  const OnCreateExternalUserEvent(this.user);
}

class OnClearUserEvent extends UsersEvent {}
