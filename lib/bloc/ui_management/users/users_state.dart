part of 'users_bloc.dart';

class UsersState extends Equatable {
  final User? sessionUser;

  const UsersState({
    this.sessionUser,
  });

  // CopyWith method
  UsersState copyWith({
    User? sessionUser,
  }) {
    return UsersState(
      sessionUser: sessionUser ?? this.sessionUser,
    );
  }

  @override
  List<Object?> get props => [sessionUser];
}
