import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/services/data/datasource/remote/service_remote_datasource.dart';

void main() {
  test('normalizeToList returns empty for null', () {
    final res = normalizeToList(null);
    expect(res, isEmpty);
  });

  test('normalizeToList returns same list when input is a list', () {
    final input = [1, 2, 3];
    final res = normalizeToList(input);
    expect(res, equals(input));
  });

  test('normalizeToList extracts list from common keys', () {
    final input = {
      'services': [
        {'id': 1},
        {'id': 2},
      ],
    };
    final res = normalizeToList(input);
    expect(res.length, 2);
    expect(res.first, isA<Map>());
  });

  test('normalizeToList finds nested items', () {
    final input = {
      'data': {
        'items': [10, 20, 30],
      },
    };
    final res = normalizeToList(input);
    expect(res, equals([10, 20, 30]));
  });

  test('normalizeToList wraps single map into list', () {
    final input = {'id': 5, 'name': 'single'};
    final res = normalizeToList(input);
    expect(res.length, 1);
    expect(res.first, equals(input));
  });
}
