import 'package:equatable/equatable.dart';

abstract class LabelEvent extends Equatable {
  const LabelEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadLabels extends LabelEvent {}

class CreateLabel extends LabelEvent {
  final String name;
  final String description;
  
  const CreateLabel({required this.name, this.description = ''});
  
  @override
  List<Object?> get props => [name, description];
}