import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incidents/core/validators.dart';

void main() {
  group('email', () {
    test('accepts student and staff ALU addresses', () {
      expect(Validators.email('a.hassan@alustudent.com'), isNull);
      expect(Validators.email('j.uwase@alueducation.com'), isNull);
    });

    test('ignores surrounding spaces and letter case', () {
      expect(Validators.email('  A.Hassan@ALUSTUDENT.com '), isNull);
    });

    test('rejects other domains', () {
      expect(Validators.email('amina@gmail.com'), isNotNull);
      expect(Validators.email('amina@alustudent.com.evil.io'), isNotNull);
    });

    test('rejects empty and malformed input', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('alustudent.com'), isNotNull);
      expect(Validators.email('@alustudent.com'), isNotNull);
    });
  });

  group('password', () {
    test('requires eight characters and a number', () {
      expect(Validators.password('short1'), isNotNull);
      expect(Validators.password('longenough'), isNotNull);
      expect(Validators.password('longenough7'), isNull);
    });
  });

  group('report fields', () {
    test('title length is enforced', () {
      expect(Validators.title('Leak'), isNotNull);
      expect(Validators.title('Leaking tap'), isNull);
      expect(Validators.title('x' * 81), isNotNull);
    });

    test('description needs some detail', () {
      expect(Validators.description('Broken'), isNotNull);
      expect(Validators.description('The tap on floor 2 has been leaking since Monday.'), isNull);
    });

    test('full name needs first and last name', () {
      expect(Validators.fullName('Amina'), isNotNull);
      expect(Validators.fullName('Amina Hassan'), isNull);
    });
  });
}
