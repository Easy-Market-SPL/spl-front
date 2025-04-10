import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_event.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_state.dart';
import 'package:spl_front/models/data/label.dart';
import 'package:spl_front/services/api/label_service.dart';

class LabelBloc extends Bloc<LabelEvent, LabelState> {
  LabelBloc() : super(LabelInitial()) {
    on<LoadLabels>(_onLoadLabels);
    on<LoadDashboardLabels>(_onLoadDashboardLabels);
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

  Future<void> _onLoadDashboardLabels(LoadDashboardLabels event, Emitter<LabelState> emit) async {
    emit(LabelLoading());
    try {
      await LabelService.initializeLabelService();
      final labels = [Label(idLabel: -1, name: "Todos", description: "")];
      labels.addAll(await LabelService.getLabels() ?? []);
      emit(LabelDashboardLoaded(labels));
    } catch (e) {
      emit(LabelError("Error cargando etiquetas"));
    }
  }

  Future<void> _onCreateLabel(CreateLabel event, Emitter<LabelState> emit) async {
    emit(LabelLoading());
    try {
      final label = Label(
        idLabel: 0, 
        name: event.name, 
        description: event.description
      );
      
      final createdLabel = await LabelService.createLabel(label);
      if (createdLabel != null) {
        emit(LabelCreated(createdLabel));
        add(LoadLabels());
      } else {
        emit(LabelError("Error creando etiqueta"));
      }
    } catch (e) {
      emit(LabelError("Error creando etiqueta"));
    }
  }
}