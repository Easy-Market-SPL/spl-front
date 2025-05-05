import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/users_models/user.dart';
import '../../../services/api_services/user_service/user_service.dart';

part 'users_management_event.dart';
part 'users_management_state.dart';

class UsersManagementBloc
    extends Bloc<UsersManagementEvent, UsersManagementState> {
  UsersManagementBloc() : super(UsersManagementState()) {
    on<OnLoadUsersEvent>((event, emit) {
      emit(state.copyWith(users: event.users));
    });

    on<OnUpdateUserEvent>((event, emit) {
      final List<UserModel> newUsers = List.from(state.users)
        ..removeWhere((user) => user.id == event.user.id)
        ..add(event.user);
      emit(state.copyWith(users: newUsers));
    });

    on<OnAddUserEvent>((event, emit) {
      final List<UserModel> newUsers = List.from(state.users)..add(event.user);
      emit(state.copyWith(users: newUsers));
    });

    on<OnSoftDeleteUserEvent>((event, emit) {
      final List<UserModel> newUsers = List.from(state.users)
        ..removeWhere((user) => user.id == event.user.id);
      emit(state.copyWith(users: newUsers));
    });

    on<OnPermanentDeleteUserEvent>((event, emit) {
      final List<UserModel> newUsers = List.from(state.users)
        ..removeWhere((user) => user.id == event.user.id);
      emit(state.copyWith(users: newUsers));
    });

    on<OnRestoreUserEvent>((event, emit) {
      final List<UserModel> newUsers = List.from(state.users);
      // Add the user back to the list
      newUsers.add(event.user);
      emit(state.copyWith(users: newUsers));
    });
  }

  Future<void> loadUsers() async {
    final users = await UserService.getUsers();
    add(OnLoadUsersEvent(users));
  }

  Future<void> updateUser(UserModel user) async {
    final bool answer = await UserService.updateUser(user, user.id);
    if (answer) {
      add(OnUpdateUserEvent(user));
    }
  }
}
