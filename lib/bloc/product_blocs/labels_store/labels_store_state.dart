part of 'labels_store_bloc.dart';

@immutable
sealed class LabelsStoreState {
  final List<String> labels;
  const LabelsStoreState({this.labels = const []});
}

final class LabelsStoreInitial extends LabelsStoreState {}

final class LabelsStoreSetState extends LabelsStoreState {
  const LabelsStoreSetState({required super.labels});
}
