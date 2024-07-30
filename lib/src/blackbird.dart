import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// {@template conditions}
/// A condition that can be evaluated.
///
/// [T] is the object to be tested.
/// [R] is the type of the [Test]s that perform evaluation within
/// the [Condition] tree.
/// {@endtemplate}
sealed class Condition<T, R extends Test<T>> extends Equatable {
  /// {@macro conditions}
  Condition();

  final _id = const Uuid().v4();

  /// Evaluates the condition on [t].
  bool evaluate(T t);
}

/// {@template test}
/// A test that can be performed on an object.
///
/// Used to define the leaf nodes of a [Condition].
/// {@endtemplate}
abstract class Test<T> extends Equatable {
  /// {@macro test}
  const Test();

  /// Invoke the test on [t].
  bool call(T t);
}

/// {@template test_condition}
/// A [Condition] whose evaluation is determined by a [Test].
/// {@endtemplate}
sealed class TestCondition<T, R extends Test<T>> extends Condition<T, R>
    with EquatableMixin {
  /// {@macro test_condition}
  TestCondition(this.test);

  /// The test that determines the condition's evaluation.
  final R test;

  @override
  List<Object?> get props => [test];
}

/// {@template nested_condition}
/// A [Condition] that has sub-conditions. [evaluate] returns true
/// based on subclass implementation.
/// {@endtemplate}
sealed class NestedCondition<T, R extends Test<T>> extends Condition<T, R> {
  /// {@macro nested_condition}
  NestedCondition(this.conditions);

  /// The sub-conditions of this condition.
  final List<Condition<T, R>> conditions;

  @override
  List<Object?> get props =>
      // Sort by hash code to ensure that the order of the conditions
      // does not affect the equality comparison.
      [...conditions.sortedBy<num>((c) => c.hashCode)];
}

/// An enum that can be used to identify a [Condition]'s type.
///
/// These will always be unique to the [Condition] type and can be relied
/// upon for serialization and deserialization.
enum ConditionType {
  /// Maps to [IsTrue].
  isTrue,

  /// Maps to [IsNotTrue].
  isNotTrue,

  /// Maps to [And].
  and,

  /// Maps to [Or].
  or,
}

/// {@template is_true}
/// A [Condition] that has no sub-conditions. [evaluate] returns true
/// if the provided [test] is met.
/// {@endtemplate}
class IsTrue<T, R extends Test<T>> extends TestCondition<T, R> {
  /// {@macro is_true}
  IsTrue(super.test);

  @override
  bool evaluate(T t) {
    return test(t);
  }
}

/// {@template is_not_true}
/// A [Condition] that has no sub-conditions. [evaluate] returns true
/// if the provided [test] is not met.
/// {@endtemplate}
class IsNotTrue<T, R extends Test<T>> extends TestCondition<T, R> {
  /// {@macro is_not_true}
  IsNotTrue(super.test);

  @override
  bool evaluate(T t) {
    return !test(t);
  }
}

/// {@template and}
/// A [Condition] that applies the logical AND operation, wherein [evaluate]
/// returns true if all of the sub-conditions are true.
///
/// If no sub-conditions are provided, [evaluate] returns true.
/// {@endtemplate}
class And<T, R extends Test<T>> extends NestedCondition<T, R> {
  /// {@macro and}
  And(super.conditions);

  @override
  bool evaluate(T t) {
    return conditions.every((c) => c.evaluate(t));
  }
}

/// {@template or}
/// A [Condition] that applies the logical OR operation wherein [evaluate]
/// returns true if any of the sub-conditions are true.
///
/// If no sub-conditions are provided, [evaluate] returns false.
/// {@endtemplate}
class Or<T, R extends Test<T>> extends NestedCondition<T, R> {
  /// {@macro or}
  Or(super.conditions);

  @override
  bool evaluate(T t) {
    return conditions.any((c) => c.evaluate(t));
  }
}

/// nodoc
extension ConditionX<T, R extends Test<T>> on Condition<T, R> {
  /// Returns the [ConditionType] of the [Condition].
  ///
  /// Useful for serializing a [Condition] or [Condition] tree,
  /// for instance when persisting to a database.
  ConditionType get type {
    return switch (this) {
      IsTrue<T, R>() => ConditionType.isTrue,
      IsNotTrue<T, R>() => ConditionType.isNotTrue,
      And<T, R>() => ConditionType.and,
      Or<T, R>() => ConditionType.or,
    };
  }
}

/// nodoc
extension NestedConditionX<T, R extends Test<T>> on NestedCondition<T, R> {
  /// Replaces [old] with [replacement] in the condition tree.
  ///
  /// Generally this will be called on the root condition.
  NestedCondition<T, R> replace(
    Condition<T, R> old,
    Condition<T, R> replacement, {
    List<Condition<T, R>> additional = const [],
  }) {
    Iterable<Condition<T, R>> replaceInternal() sync* {
      for (final condition in conditions) {
        if (condition is NestedCondition<T, R>) {
          yield condition.replace(
            old,
            replacement,
            additional: additional,
          );
        } else {
          if (condition._id == old._id) {
            yield replacement;
            for (final additionalCondition in additional) {
              yield additionalCondition;
            }
          } else {
            yield condition;
          }
        }
      }
    }

    if (replacement is NestedCondition<T, R> && _id == old._id) {
      // Replace the entire tree.
      return replacement;
    }

    return switch (this) {
      And() => And(replaceInternal().toList()),
      Or() => Or(replaceInternal().toList()),
    };
  }

  /// Adds a [Condition] to the receiver [NestedCondition].
  ///
  /// Returns a new [NestedCondition] with the added [Condition].
  NestedCondition<T, R> add(Condition<T, R> condition) {
    return switch (this) {
      And() => And({...conditions, condition}.toList()),
      Or() => Or({...conditions, condition}.toList()),
    };
  }

  /// Removes a [Condition] from the receiver [NestedCondition].
  ///
  /// Returns a new [NestedCondition] without the removed [Condition].
  NestedCondition<T, R> remove(Condition<T, R> condition) {
    return switch (this) {
      And() => And(conditions.where((c) => c._id != condition._id).toList()),
      Or() => Or(conditions.where((c) => c._id != condition._id).toList()),
    };
  }

  /// Returns true if any of the [NestedCondition]s beneath this one
  /// are empty.
  bool containsEmptyChild() {
    return conditions.any((c) {
      if (c is NestedCondition<T, R>) {
        return c.conditions.isEmpty || c.containsEmptyChild();
      }
      return false;
    });
  }

  /// Returns true if this [NestedCondition] contains duplicate
  /// sub-[Condition]s.
  bool containsDuplicates() {
    return duplicates().isNotEmpty;
  }

  /// Returns a list of duplicate sub-[Condition]s for this [NestedCondition].
  List<Condition> duplicates() {
    final seen = <Condition>{};
    final duplicates = <Condition>[];
    for (final condition in conditions) {
      if (!seen.add(condition)) duplicates.add(condition);
    }
    return duplicates;
  }

  /// Returns a list of reasons why this [NestedCondition] is invalid.
  List<InvalidConditionTreeReason> get invalidReasons {
    final reasons = <InvalidConditionTreeReason>[];
    if (containsEmptyChild()) {
      reasons.add(InvalidConditionTreeReason.emptyChild);
    }
    if (containsDuplicates()) reasons.add(InvalidConditionTreeReason.duplicate);
    return reasons;
  }
}

/// An enum that describes the reasons why a [NestedCondition] is invalid.
enum InvalidConditionTreeReason {
  /// A [NestedCondition] contains an empty child.
  emptyChild,

  /// A duplicate [Condition] is found in the [NestedCondition].
  duplicate,
}

/// {@template test_condition_draft}
/// A draft of a [TestCondition]. The only difference between this and
/// a [TestCondition] is that the [test] is nullable. This allows for
/// the creation of a [TestCondition] without a [Test] instance, useful
/// for creating a [TestCondition] with a [Test] that is not yet known.
/// {@endtemplate}
sealed class TestConditionDraft<T, R extends Test<T>> {
  /// {@macro test_condition_draft}
  const TestConditionDraft([this.test]);

  /// The test that determines the condition's evaluation.
  final R? test;
}

/// {@template is_true_draft}
/// A draft of an [IsTrue] condition.
/// {@endtemplate}
class IsTrueDraft<T, R extends Test<T>> extends TestConditionDraft<T, R> {
  /// {@macro is_true_draft}
  const IsTrueDraft([super.test]);
}

/// {@template is_not_true_draft}
/// A draft of an [IsNotTrue] condition.
/// {@endtemplate}
class IsNotTrueDraft<T, R extends Test<T>> extends TestConditionDraft<T, R> {
  /// {@macro is_not_true_draft}
  const IsNotTrueDraft([super.test]);
}
