import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/components/notification_dot.dart';
import 'package:spot/cubits/notification/notification_cubit.dart';
import 'package:spot/models/notification.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/pages/tab_page.dart';
import 'package:spot/pages/tabs/map_tab.dart';
import 'package:spot/pages/tabs/notifications_tab.dart';
import 'package:spot/pages/tabs/profile_tab.dart';
import 'package:spot/pages/tabs/search_tab.dart';

import '../helpers/helpers.dart';

void main() {
  setUpAll(() {
    registerFallbackValue<DateTime>(DateTime.parse('2021-05-20T00:00:00.00'));
  });
  group('TabPage', () {
    final repository = MockRepository();

    testWidgets('Every tab gets rendered', (tester) async {
      final tabPage = TabPage();
      await tester.pumpApp(
        widget: MultiBlocProvider(
          providers: [
            BlocProvider<NotificationCubit>(
                create: (context) => NotificationCubit(repository: repository)),
          ],
          child: tabPage,
        ),
        repository: repository,
      );
      expect(find.byType(MapTab), findsOneWidget);
      expect(find.byType(SearchTab), findsOneWidget);
      expect(find.byType(NotificationsTab), findsOneWidget);
      expect(find.byType(ProfileTab), findsOneWidget);
    });

    testWidgets('Initial index is 0', (tester) async {
      final tabPage = TabPage();
      await tester.pumpApp(
        widget: MultiBlocProvider(
          providers: [
            BlocProvider<NotificationCubit>(
                create: (context) => NotificationCubit(repository: repository)),
          ],
          child: tabPage,
        ),
        repository: repository,
      );
      expect(tabPage.createState().currentIndex, 0);
    });

    testWidgets('Tapping Home goes to tab index 0', (tester) async {
      final tabPage = TabPage();
      await tester.pumpApp(
        widget: MultiBlocProvider(
          providers: [
            BlocProvider<NotificationCubit>(
                create: (context) => NotificationCubit(repository: repository)),
          ],
          child: tabPage,
        ),
        repository: repository,
      );
      await tester.tap(find.ancestor(of: find.text('Home'), matching: find.byType(InkResponse)));
      expect(tabPage.createState().currentIndex, 0);
    });
    testWidgets('Tapping Search goes to tab index 1', (tester) async {
      final tabPage = TabPage();
      await tester.pumpApp(
        widget: MultiBlocProvider(
          providers: [
            BlocProvider<NotificationCubit>(
                create: (context) => NotificationCubit(repository: repository)),
          ],
          child: tabPage,
        ),
        repository: repository,
      );
      await tester.tap(find.ancestor(of: find.text('Search'), matching: find.byType(InkResponse)));
      expect(tester.state<TabPageState>(find.byWidget(tabPage)).currentIndex, 1);
    });
    testWidgets('Tapping Notifications goes to tab index 2', (tester) async {
      final tabPage = TabPage();
      await tester.pumpApp(
        widget: MultiBlocProvider(
          providers: [
            BlocProvider<NotificationCubit>(
                create: (context) => NotificationCubit(repository: repository)),
          ],
          child: tabPage,
        ),
        repository: repository,
      );
      await tester
          .tap(find.ancestor(of: find.text('Notifications'), matching: find.byType(InkResponse)));
      expect(tester.state<TabPageState>(find.byWidget(tabPage)).currentIndex, 2);
    });

    testWidgets('Tapping Profile goes to tab index 3', (tester) async {
      final tabPage = TabPage();
      await tester.pumpApp(
        widget: MultiBlocProvider(
          providers: [
            BlocProvider<NotificationCubit>(
                create: (context) => NotificationCubit(repository: repository)),
          ],
          child: tabPage,
        ),
        repository: repository,
      );
      await tester.tap(find.ancestor(of: find.text('Profile'), matching: find.byType(InkResponse)));
      expect(tester.state<TabPageState>(find.byWidget(tabPage)).currentIndex, 3);
    });

    testWidgets('Notification dots are shown properly', (tester) async {
      when(repository.getNotifications).thenAnswer(
        (_) => Future.value([
          AppNotification(
            type: NotificationType.like,
            createdAt: DateTime.now(),
            targetVideoId: '',
            targetVideoThumbnail: 'https://adamvenord17.dev/images/profile.jpg',
            actionUid: 'aaa',
            actionUserName: 'Tyler',
            isNew: true,
          ),
          AppNotification(
            type: NotificationType.follow,
            createdAt: DateTime.now(),
            actionUid: 'aaa',
            actionUserName: 'Tyler',
            isNew: false,
          ),
          AppNotification(
            type: NotificationType.comment,
            createdAt: DateTime.now(),
            targetVideoId: '',
            targetVideoThumbnail: 'https://adamvenord17.dev/images/profile.jpg',
            actionUid: 'aaa',
            actionUserName: 'Tyler',
            commentText: 'hey',
            isNew: false,
          ),
        ]),
      );
      when(() => repository.updateTimestampOfLastSeenNotification(any()))
          .thenAnswer((_) => Future.value());
      when(repository.determinePosition).thenAnswer((_) => Future.value(const LatLng(0, 0)));
      when(() => repository.getVideosFromLocation(const LatLng(0, 0)))
          .thenAnswer((_) => Future.value([]));
      when(() => repository.getVideosInBoundingBox(
              LatLngBounds(southwest: const LatLng(0, 0), northeast: const LatLng(45, 45))))
          .thenAnswer((_) => Future.value([]));
      when(() => repository.mapVideosStream).thenAnswer((_) => Stream.value([]));
      when(() => repository.userId).thenReturn('aaa');
      when(() => repository.getProfile('aaa'))
          .thenAnswer((_) => Future.value(Profile(id: 'id', name: 'name')));
      when((() => repository.profileStream)).thenAnswer((_) => Stream.value({}));
      when(() => repository.getVideosFromUid('aaa')).thenAnswer((_) => Future.value([]));

      final tabPage = TabPage();
      await tester.pumpApp(
        widget: MultiBlocProvider(
          providers: [
            BlocProvider<NotificationCubit>(
              create: (context) => NotificationCubit(repository: repository)..loadNotifications(),
            ),
          ],
          child: tabPage,
        ),
        repository: repository,
      );
      expect(find.byType(NotificationDot), findsNothing);
      await tester.pump();

      // Finds the one dot in notification tab and bottom tab bar
      expect(find.byType(NotificationDot), findsNWidgets(2));
      await tester
          .tap(find.ancestor(of: find.text('Notifications'), matching: find.byType(InkResponse)));
      await tester.pump();
      expect(find.byType(NotificationDot), findsNWidgets(1));
    });
  });
}
