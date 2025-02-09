part of 'profile_tab_bloc.dart';

@immutable
sealed class ProfileTabState {
  final bool informationTab;
  const ProfileTabState({this.informationTab = true});
}

final class ProfileTabInitial extends ProfileTabState {
  const ProfileTabInitial();
}

final class ProfileTabSetState extends ProfileTabState {
  const ProfileTabSetState({required bool informationTab})
      : super(informationTab: informationTab);
}
