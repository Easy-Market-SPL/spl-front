import 'package:equatable/equatable.dart';
import 'package:spl_front/models/data/label.dart';

abstract class LabelState extends Equatable {
  const LabelState();
  
  @override
  List<Object?> get props => [];
}

class LabelInitial extends LabelState {}

class LabelLoading extends LabelState {}

class LabelsLoaded extends LabelState {
  final List<Label> labels;
  
  const LabelsLoaded(this.labels);
  
  @override
  List<Object?> get props => [labels];
}

class LabelDashboardLoaded extends LabelState {
  final List<Label> labels;
  
  const LabelDashboardLoaded(this.labels);
  
  @override
  List<Object?> get props => [labels];
}

class LabelCreated extends LabelState {
  final Label label;
  
  const LabelCreated(this.label);
  
  @override
  List<Object?> get props => [label];
}

class LabelError extends LabelState {
  final String message;
  
  const LabelError(this.message);
  
  @override
  List<Object?> get props => [message];
}