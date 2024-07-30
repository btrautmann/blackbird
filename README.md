# Blackbird

[![pub package](https://img.shields.io/pub/v/blackbird.svg)](https://pub.dev/packages/blackbird)
![CI](https://github.com/btrautmann/blackbird/actions/workflows/dart.yml/badge.svg)
[![codecov](https://codecov.io/gh/btrautmann/blackbird/graph/badge.svg?token=MXT6227EXW)](https://codecov.io/gh/btrautmann/blackbird)

A boolean logic library for Dart and Flutter, allowing you to build trees of conditions and evaluate them.

## Purpose

While there is no limit to what you can/should do with `blackbird`, it's aimed at building flexible query UIs for your applications.

<p align="center">
<img src="https://raw.githubusercontent.com/btrautmann/blackbird/main/assets/example.png" alt="Example" width="200" style="aspect-ratio: 9 / 19.5;">
</p>


## Design

Blackbird is designed to provide the building blocks for building condition trees (blackbird is named after Blackbird State Forest in Delaware, US.). Out of the box, it provides the `Condition`, `NestedCondition`, `TestCondition`, and `Test` classes. You can use these to build complex trees of conditions and evaluate them.

## Example usage

Check out the [example](example/main.dart) for a simple example.

```dart
final condition = Or(
  [
    IsTrue(StartsWithLowerCase()),
    IsTrue(ContainsString('One')),
  ],
);

expect(condition.evaluate('hello'), isTrue);
expect(condition.evaluate('On'), isFalse);
```

## Features

- **Type-safe**: The entire condition tree is typed to your type `T`.
- **Extensible**: Define `Test` objects according to _your_ domain.
- **Readable**: The API is designed to be readable and expressive.

## Installation

```sh
dart pub add blackbird
```
