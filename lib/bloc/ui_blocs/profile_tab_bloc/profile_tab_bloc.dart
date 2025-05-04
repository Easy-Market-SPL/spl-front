import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_tab_event.dart';
part 'profile_tab_state.dart';

class ProfileTabBloc extends Bloc<ProfileTabEvent, ProfileTabState> {
  ProfileTabBloc() : super(ProfileTabInitial()) {
    on<ProfileTabEvent>((event, emit) {
      emit(ProfileTabInitial());
    });

    on<ChangeTab>((event, emit) {
      emit(ProfileTabSetState(showedTab: event.showedTab));
    });
  }
}
