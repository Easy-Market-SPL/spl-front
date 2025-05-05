import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../../product_blocs/labels_store/labels_store_event.dart';
part 'labels_store_state.dart';

class LabelsStoreBloc extends Bloc<LabelsStoreEvent, LabelsStoreState> {
  LabelsStoreBloc() : super(LabelsStoreInitial()) {
    on<LoadLabels>((event, emit) {
      emit(LabelsStoreSetState(labels: []));
    });

    on<AddLabel>((event, emit) {
      final newLabels = List<String>.from(state.labels)..add(event.label);
      emit(LabelsStoreSetState(labels: newLabels));
    });
  }
}
