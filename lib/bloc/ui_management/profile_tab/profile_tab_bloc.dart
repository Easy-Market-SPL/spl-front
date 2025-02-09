import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'profile_tab_event.dart';
part 'profile_tab_state.dart';

class ProfileTabBloc extends Bloc<ProfileTabEvent, ProfileTabState> {
  ProfileTabBloc() : super(ProfileTabInitial()) {
    on<ProfileTabEvent>((event, emit) {
      emit(ProfileTabInitial());
    });

    on<ChangeTab>((event, emit) {
      emit(ProfileTabSetState(informationTab: event.isPaymentTab));
    });
  }
}
