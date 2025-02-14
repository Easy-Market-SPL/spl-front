part of 'profile_tab_bloc.dart';

@immutable
sealed class ProfileTabState {
  final int showedTab; // 0 for information, 1 for payment, 2 for addresses
  const ProfileTabState({this.showedTab = 0});
}

final class ProfileTabInitial extends ProfileTabState {
  const ProfileTabInitial();
}

final class ProfileTabSetState extends ProfileTabState {
  const ProfileTabSetState({required super.showedTab});
}
