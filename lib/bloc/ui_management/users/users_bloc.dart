import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/user.dart';
import 'package:spl_front/services/api/user_service.dart';

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

  void clearUser() {
    add(OnClearUserEvent());
  }
}
