import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/repositories/repository.dart';
import 'package:supabase/supabase.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late SupabaseClient supabaseClient;
  late HttpServer mockServer;

  Future<void> handleRequests(HttpServer server) async {
    await for (final HttpRequest request in server) {
      final url = request.uri.toString();
      if (url == '/rest/v1/rpc/nearby_videos?limit=5') {
        final jsonString = jsonEncode([
          {
            'id': '',
            'url': '',
            'image_url': '',
            'thumbnail_url': '',
            'gif_url': '',
            'description': '',
            'user_id': '',
            'location': 'POINT(44.0 46.0)',
            'created_at': '2021-04-17T00:00:30.75',
          },
        ]);
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonString)
          ..close();
      } else if (url == '/auth/v1/token?grant_type=password') {
        final jsonString = jsonEncode({
          'access_token': '',
          'expires_in': 3600,
          'refresh_token': '',
          'token_type': '',
          'provider_token': '',
          'user': {
            'id': 'aaa',
            'app_metadata': {},
            'user_metadata': {},
            'aud': '',
            'email': 'some@some.com',
            'created_at': '2021-04-17T00:00:30.75',
            'confirmed_at': '2021-04-17T00:00:30.75',
            'last_sign_in_at': '',
            'role': '',
            'updated_at': '2021-04-17T00:00:30.75',
          },
        });
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonString)
          ..close();
      } else if (url == '/auth/v1/signup') {
        final jsonString = jsonEncode({
          'access_token': '',
          'expires_in': 3600,
          'refresh_token': '',
          'token_type': '',
          'provider_token': '',
          'user': {
            'id': 'aaa',
            'app_metadata': {},
            'user_metadata': {},
            'aud': '',
            'email': 'some@some.com',
            'created_at': '2021-04-17T00:00:30.75',
            'confirmed_at': '2021-04-17T00:00:30.75',
            'last_sign_in_at': '',
            'role': '',
            'updated_at': '2021-04-17T00:00:30.75',
          },
        });
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonString)
          ..close();
      } else if (url == '/rest/v1/users?select=%2A&id=eq.aaa') {
        final jsonString = jsonEncode([
          {
            'id': 'aaa',
            'name': 'tyler',
            'description': 'Hi',
          },
        ]);
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonString)
          ..close();
      } else {
        request.response
          ..statusCode = HttpStatus.ok
          ..close();
      }
    }
  }

  setUp(() async {
    mockServer = await HttpServer.bind('localhost', 0);
    supabaseClient =
        SupabaseClient('http://${mockServer.address.host}:${mockServer.port}', 'supabaseKey');
    handleRequests(mockServer);
  });

  tearDown(() async {
    await mockServer.close();
  });

  group('repository', () {
    test('signUp', () async {
      final repository = Repository(supabaseClient: supabaseClient);

      final sessionString = await repository.signUp(email: '', password: '');

      expect(sessionString is String, true);
    });

    test('signIn', () async {
      final repository = Repository(supabaseClient: supabaseClient);

      final sessionString = await repository.signIn(email: '', password: '');

      expect(sessionString is String, true);
    });

    test('getSelfProfile', () async {
      final repository = Repository(supabaseClient: supabaseClient);

      await repository.signIn(email: '', password: '');

      final profile = await repository.getSelfProfile();

      expect(profile!.id, 'aaa');
    });

    test('getVideosFromLocation', () async {
      final repository = Repository(supabaseClient: supabaseClient);

      await repository.signIn(email: '', password: '');

      await repository.getVideosFromLocation(const LatLng(45.0, 45.0));

      repository.mapVideosStream.listen(
        expectAsync1(
          (videos) {
            expect(videos.length, 1);
          },
        ),
      );
    });
  });
}
