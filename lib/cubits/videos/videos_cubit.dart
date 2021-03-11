import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spot/models/video.dart';

part 'videos_state.dart';

class VideosCubit extends Cubit<VideosState> {
  VideosCubit() : super(VideosInitial());

  Future<void> loadVideos() async {
    // TODO receive geo point and get videos
  }
}
