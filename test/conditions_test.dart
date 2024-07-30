import 'package:conditions/conditions.dart';
import 'package:test/test.dart';

void main() {
  group('Condition', () {
    test('Single', () {
      final condition = IsTrue(EqualsString('payeeOne'));

      expect(condition.evaluate('payeeOne'), isTrue);
      expect(condition.evaluate('payeeTwo'), isFalse);
    });

    test('And', () {
      final condition = And(
        [
          IsTrue(StartsWithLowerCase()),
          IsTrue(ContainsString('One')),
        ],
      );

      expect(condition.evaluate('payeeOne'), isTrue);
      expect(condition.evaluate('PayeeOne'), isFalse);
    });

    test('Or', () {
      final condition = Or(
        [
          IsTrue(StartsWithLowerCase()),
          IsTrue(ContainsString('One')),
        ],
      );

      expect(condition.evaluate('hello'), isTrue);
      expect(condition.evaluate('On'), isFalse);
    });

    test('Nested And', () {
      final condition = Or(
        <Condition>[
          IsTrue(StartsWithLowerCase()),
          And(
            [
              IsTrue(ContainsString('a')),
              IsTrue(ContainsString('e')),
            ],
          ),
        ],
      );

      expect(condition.evaluate('Haeiou'), isTrue);
      expect(condition.evaluate('Haiou'), isFalse);
    });

    test('Nested Or', () {
      final condition = And(
        <Condition>[
          IsTrue(StartsWithLowerCase()),
          Or(
            [
              IsTrue(ContainsString('a')),
              IsTrue(ContainsString('e')),
            ],
          ),
        ],
      );

      expect(condition.evaluate('hay'), isTrue);
      expect(condition.evaluate('hy'), isFalse);
    });

    group('Extensions', () {
      group('replace', () {
        test('', () {
          final startsWithLowerCase = IsTrue(StartsWithLowerCase());
          final condition = And(
            [
              startsWithLowerCase,
              IsTrue(ContainsString('One')),
            ],
          );

          expect(condition.evaluate('payeeOne'), isTrue);
          expect(condition.evaluate('PayeeOne'), isFalse);

          final newCondition = condition.replace(
            startsWithLowerCase,
            IsTrue(ContainsString('Two')),
          );

          expect(newCondition.evaluate('One'), isFalse);
          expect(newCondition.evaluate('OneTwo'), isTrue);
        });
      });
    });

    test('equals', () {
      final condition = IsTrue(EqualsString('payeeOne'));
      final condition2 = IsTrue(EqualsString('payeeTwo'));
      final condition3 = IsTrue(EqualsString('payeeOne'));
      final condition4 = IsTrue(StartsWithLowerCase());
      final condition5 = IsTrue(StartsWithLowerCase());

      final composite = And([condition, condition2]);
      final composite2 = And([condition2, condition]);

      expect(condition == condition2, isFalse); // Different values
      expect(composite == composite2, isTrue); // Order doesn't matter
      expect(condition == condition3, isTrue); // Same values
      expect(condition4 == condition5, isTrue); // Same even without values
    });

    test('containsDuplicates', () {
      final condition = IsTrue(EqualsString('payeeOne'));
      final condition2 = IsTrue(EqualsString('payeeTwo'));

      final composite = And([condition, condition2]);
      final composite2 = And([condition2, condition2]);

      expect(composite.containsDuplicates(), isFalse);
      expect(composite2.containsDuplicates(), isTrue);
    });
  });
}

enum StringTestType {
  equals,
  contains,
  startsWithLowerCase,
}

sealed class StringTest extends Test<String> {}

class EqualsString extends StringTest {
  EqualsString(this.value);
  final String value;

  @override
  bool call(String t) {
    return t == value;
  }

  @override
  List<Object?> get props => [value];
}

class ContainsString extends StringTest {
  ContainsString(this.value);
  final String value;

  @override
  bool call(String t) {
    return t.contains(value);
  }

  @override
  List<Object?> get props => [value];
}

class StartsWithLowerCase extends StringTest {
  StartsWithLowerCase();

  @override
  bool call(String t) {
    if (t.isEmpty) return false;
    final test = t.substring(0, 1);
    final regex = RegExp(r'^[a-z]$');
    return regex.hasMatch(test);
  }

  @override
  List<Object?> get props => [];
}
