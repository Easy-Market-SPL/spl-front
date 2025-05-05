part of 'labels_store_bloc.dart';

@immutable
sealed class LabelsStoreEvent {}

class LoadLabels extends LabelsStoreEvent {}

class AddLabel extends LabelsStoreEvent {
  final String label;
  AddLabel(this.label);
}
