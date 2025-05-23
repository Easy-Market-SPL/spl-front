import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/users_models/user.dart';
import '../../../services/api_services/user_service/user_service.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc() : super(UsersState()) {
    on<OnUpdateSessionUserEvent>((event, emit) {
      emit(state.copyWith(sessionUser: event.user));
    });

    on<OnClearUserEvent>((event, emit) {
      emit(state.copyWith(sessionUser: null));
    });
  }

  Future<void> getUser(String? id) async {
    if (id == null) return;
    final user = await UserService.getUser(id);
    add(OnUpdateSessionUserEvent(user));
  }

  Future<bool> updateUser(UserModel user) async {
    bool answer = await UserService.updateUser(user, user.id);
    if (answer) {
      add(OnUpdateSessionUserEvent(user));
    }
    return answer;
  }

  void clearUser() {
    add(OnClearUserEvent());
  }
}
