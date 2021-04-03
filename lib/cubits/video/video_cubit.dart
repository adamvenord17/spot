import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:video_player/video_player.dart';

import '../../models/profile.dart';
import '../../models/video.dart';

part 'video_state.dart';

/// Takes care of actions done on single video
/// like viewing liking, blocking and such
class VideoCubit extends Cubit<VideoState> {
  VideoCubit() : super(VideoInitial());

  late final String _videoId;
  late final Video _video;
  late final VideoPlayerController _videoPlayerController;
  bool _videoInitialized = false;

  Future<void> initialize(String videoId) async {
    _videoId = videoId;

    // TODO get video data with videoId
    final video = Video(
      id: 'fsda',
      createdAt: DateTime.now(),
      createdBy: Profile(
        id: 'fsa',
        name: 'aaa',
        imageUrl:
            'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
      ),
      description: 'This is just a sample description',
      imageUrl:
          'https://tblg.k-img.com/restaurant/images/Rvw/91056/640x640_rect_91056529.jpg',
      thumbnailUrl:
          'https://tblg.k-img.com/restaurant/images/Rvw/91056/640x640_rect_91056529.jpg',
      gifUrl:
          'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
      url: 'https://www.w3schools.com/html/mov_bbb.mp4',
      location: const LatLng(37.43296265331129, -122.08832357078792),
    );

    _video = video;

    emit(VideoLoading(video));

    _videoPlayerController = VideoPlayerController.network(
        'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4');
    await _videoPlayerController.initialize();
    _videoInitialized = true;
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
    emit(VideoPlaying(
      video: _video,
      videoPlayerController: _videoPlayerController,
    ));
  }

  Future<void> pause() async {
    await _videoPlayerController.pause();
    if (!(state is VideoLoading)) {
      emit(VideoPaused(
        video: _video,
        videoPlayerController: _videoPlayerController,
      ));
    }
  }

  Future<void> resume() async {
    await _videoPlayerController.play();
    if (_videoInitialized) {
      emit(VideoPlaying(
        video: _video,
        videoPlayerController: _videoPlayerController,
      ));
    }
  }

  @override
  Future<void> close() {
    _videoPlayerController.dispose();
    return super.close();
  }
}
