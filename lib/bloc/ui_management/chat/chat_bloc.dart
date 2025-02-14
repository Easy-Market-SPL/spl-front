import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    // Manage initial messages
    on<LoadMessagesEvent>((event, emit) {
      List<ChatMessage> initialMessages = [
        ChatMessage(
            sender: 'soporte',
            text: 'Buen día, este es el soporte por chat de [Empresa].',
            time: '10:30 AM',
            date: '05/02/2025'),
        ChatMessage(
            sender: 'soporte',
            text: '¿Cómo podemos ayudarte hoy?',
            time: '10:30 AM',
            date: '05/02/2025'),
        ChatMessage(
            sender: 'cliente',
            text:
                'Pueden hacer domicilios a Medina, Cundinamarca? Me interesan algunos de los productos que tienen en descuento',
            time: '10:32 AM',
            date: '05/02/2025'),
        ChatMessage(
            sender: 'soporte',
            text: 'Estimado cliente, si podemos hacer domicilios a Medina, Cundinamarca. Contamos en el momento con entregas a toda Bogotá y alrededores.',
            time: '10:33 AM',
            date: '05/02/2025'
        ),
        ChatMessage(
            sender: 'cliente',
            text: 'Gracias, buen día',
            time: '10:36 AM',
            date: '05/02/2025'
        )
      ];
      emit(ChatLoaded(initialMessages));
    });

    // Manage sending messages
    on<SendMessageEvent>((event, emit) {
      if (state is ChatLoaded) {
        final currentMessages = List<ChatMessage>.from((state as ChatLoaded).messages);
        String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
        String formattedTime = TimeOfDay.now().format(event.context);

        final newMessage = ChatMessage(
          sender: event.sender,
          text: event.text,
          time: formattedTime,
          date: formattedDate,
        );

        //TODO: Implement logic to send message to the server

        currentMessages.add(newMessage);
        emit(ChatLoaded(currentMessages));
      }
    });

    on<SendFileEvent>((event, emit) {
      if (state is ChatLoaded) {
        final currentMessages = List<ChatMessage>.from((state as ChatLoaded).messages);
        String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
        String formattedTime = TimeOfDay.now().format(event.context);

        final newMessage = ChatMessage(
          sender: event.sender,
          text: '',
          time: formattedTime,
          date: formattedDate,
          fileUrl: event.fileUrl,
          type: event.fileType,
        );

        //TODO: Implement logic to send file to the server
        //TODO: Implement message URL update
        currentMessages.add(newMessage);
        emit(ChatLoaded(currentMessages));
      }
    });
  }
}
