# Conditions

[![pub package](https://img.shields.io/pub/v/blackbird.svg)](https://pub.dev/packages/blackbird)
![CI](https://github.com/btrautmann/blackbird/actions/workflows/dart.yml/badge.svg)
[![codecov](https://codecov.io/gh/btrautmann/blackbird/graph/badge.svg?token=MXT6227EXW)](https://codecov.io/gh/btrautmann/blackbird)

A boolean logic library for Dart and Flutter, allowing you to build trees of conditions and evaluate them.

## Example usage

Check out the [example](example/lib/main.dart) for a simple example.

## Features

- **Type-safe**: The entire condition tree is typed to your type `T`.
- **Extensible**: Define `Test` objects given your own domain. `Conditions` does the work of evaluating them.
- **Readable**: The API is designed to be readable and expressive.

## Installation

```sh
dart pub add blackbird
```
