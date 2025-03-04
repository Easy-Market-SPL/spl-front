part of 'profile_tab_bloc.dart';

@immutable
sealed class ProfileTabEvent {}

class ChangeTab extends ProfileTabEvent {
  final int showedTab;
  ChangeTab(this.showedTab);
}
