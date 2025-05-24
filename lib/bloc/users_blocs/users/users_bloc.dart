import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/services/api_services/user_service/user_sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    on<OnCreateExternalUserEvent>((event, emit) async {
      final userCreated = await UserService.createUser(event.user);
      if (userCreated) {
        emit(state.copyWith(sessionUser: event.user));
      }
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

  Future<bool> createExternalUser(User supabaseUser, {String defaultRole = 'customer'}) async {
    try {
      final newUser = await UserSyncService.syncExternalUser(supabaseUser);
      if (newUser != null) {
        add(OnUpdateSessionUserEvent(newUser));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void clearUser() {
    add(OnClearUserEvent());
  }
}
