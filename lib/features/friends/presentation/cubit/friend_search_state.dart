import 'package:equatable/equatable.dart';

abstract class FriendSearchState extends Equatable {
  const FriendSearchState();

  @override
  List<Object?> get props => [];
}

class FriendSearchInitial extends FriendSearchState {}

class FriendSearchLoading extends FriendSearchState {}

class FriendSearchLoaded extends FriendSearchState {
  final List<Map<String, dynamic>> users;

  const FriendSearchLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class FriendSearchError extends FriendSearchState {
  final String message;

  const FriendSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
