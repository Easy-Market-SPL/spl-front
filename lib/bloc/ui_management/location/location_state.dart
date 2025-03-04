part of 'location_bloc.dart';

class LocationState extends Equatable {
  final bool followingUser;
  final LatLng? lastKnowLocation;

  const LocationState({
    this.followingUser = true,
    this.lastKnowLocation,
  });

  LocationState copyWith({
    bool? followingUser,
    LatLng? lastKnowLocation,
  }) {
    return LocationState(
      followingUser: followingUser ?? this.followingUser,
      lastKnowLocation: lastKnowLocation ?? this.lastKnowLocation,
    );
  }

  // Important: Cause the LatLng can be null, we need to put the nullable type at Object ?
  @override
  List<Object?> get props => [followingUser, lastKnowLocation];
}
