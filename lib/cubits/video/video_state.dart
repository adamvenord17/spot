part of 'video_cubit.dart';

@immutable
abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoPlaying extends VideoState {
  VideoPlaying({required this.videoPlayerController});

  final VideoPlayerController videoPlayerController;
}
