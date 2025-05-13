import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/product_models/labels/label.dart';
import '../../../../services/api_services/product_services/label_service.dart';
import 'label_event.dart';
import 'label_state.dart';

class LabelBloc extends Bloc<LabelEvent, LabelState> {
  LabelBloc() : super(LabelInitial()) {
    on<LoadLabels>(_onLoadLabels);
    on<CreateLabel>(_onCreateLabel);
  }

  Future<void> _onLoadLabels(LoadLabels event, Emitter<LabelState> emit) async {
    emit(LabelLoading());
    try {
      await LabelService.initializeLabelService();
      final labels = await LabelService.getLabels();
      emit(LabelsLoaded(labels ?? []));
    } catch (e) {
      emit(LabelError("Error cargando etiquetas"));
    }
  }

  Future<void> _onCreateLabel(
      CreateLabel event, Emitter<LabelState> emit) async {
    emit(LabelLoading());
    try {
      final label =
          Label(idLabel: 0, name: event.name, description: event.description);

      final createdLabel = await LabelService.createLabel(label);
      if (createdLabel != null) {
        emit(LabelCreated(createdLabel));
        add(LoadLabels());
      } else {
        emit(LabelError("Error creating label"));
      }
    } catch (e) {
      emit(LabelError("Error creating label"));
    }
  }
}
