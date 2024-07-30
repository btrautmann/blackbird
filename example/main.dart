import 'package:blackbird/blackbird.dart';

sealed class StringTest extends Test<String> {}

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

void main() {
  final condition = And(
    [
      IsTrue(StartsWithLowerCase()),
      IsTrue(ContainsString('One')),
    ],
  );

  print(condition.evaluate('payeeOne')); // true
  print(condition.evaluate('PayeeOne')); // false
}
