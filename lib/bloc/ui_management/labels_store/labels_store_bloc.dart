import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'labels_store_event.dart';
part 'labels_store_state.dart';

class LabelsStoreBloc extends Bloc<LabelsStoreEvent, LabelsStoreState> {
  LabelsStoreBloc() : super(LabelsStoreInitial()) {
    on<LoadLabels>((event, emit) {
      emit(LabelsStoreSetState(labels: ['Label 1', 'Label 2', 'Label 3']));
    });

    on<AddLabel>((event, emit) {
      final newLabels = List<String>.from(state.labels)..add(event.label);
      emit(LabelsStoreSetState(labels: newLabels));
    });
  }
}
