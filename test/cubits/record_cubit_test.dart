// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:spot/cubits/record/record_cubit.dart';

void main() {
  group('RecordCubit', () {
    test('initial state is RecordInitial', () {
      expect(RecordCubit().state is RecordInitial, true);
    });

    blocTest<RecordCubit, RecordState>(
      'emits RecordInProgress when startRecording is called',
      build: () => RecordCubit(),
      act: (cubit) => cubit.startRecording(),
      expect: () => [isA<RecordInProgress>()],
    );
  });
}
