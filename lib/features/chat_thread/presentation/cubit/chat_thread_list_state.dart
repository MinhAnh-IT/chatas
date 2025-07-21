import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_thread.dart';

abstract class ChatThreadListState extends Equatable {
  const ChatThreadListState();

  @override
  List<Object?> get props => [];
}

class ChatThreadListInitial extends ChatThreadListState {}

class ChatThreadListLoading extends ChatThreadListState {}

class ChatThreadListLoaded extends ChatThreadListState {
  final List<ChatThread> threads;
  const ChatThreadListLoaded(this.threads);

  @override
  List<Object?> get props => [threads];
}

class ChatThreadListError extends ChatThreadListState {
  final String message;
  const ChatThreadListError(this.message);

  @override
  List<Object?> get props => [message];
}
