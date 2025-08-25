import { DartAnalyzer } from '../../analyzer/dart-analyzer';
import { MockTextDocument } from '../mocks/vscode-mocks';

describe('DartAnalyzer', () => {
  let analyzer: DartAnalyzer;

  beforeEach(() => {
    analyzer = new DartAnalyzer();
  });

  describe('findVeloTypesInDocument', () => {
    it('should find Velo class definitions', () => {
      const content = `
class CounterVelo extends Velo<CounterState> {
  CounterVelo() : super(const CounterState());
}

class UserVelo extends Velo<UserState> {
  UserVelo() : super(const UserState());
}
      `;
      const document = new MockTextDocument(content);
      const types = analyzer.findVeloTypesInDocument(document as any);

      expect(types).toHaveLength(2);
      expect(types[0]).toEqual({
        veloType: 'CounterVelo',
        stateType: 'CounterState',
        line: 1,
      });
      expect(types[1]).toEqual({
        veloType: 'UserVelo',
        stateType: 'UserState',
        line: 5,
      });
    });

    it('should find Velo widget usages', () => {
      const content = `
VeloBuilder<CounterVelo, CounterState>(
  builder: (context, state) => Text('count: ' + state.count.toString()),
)

VeloConsumer<UserVelo, UserState>(
  builder: (context, state) => Text(state.name),
  listener: (context, state) {},
)
      `;
      const document = new MockTextDocument(content);
      const types = analyzer.findVeloTypesInDocument(document as any);

      expect(types).toHaveLength(2);
      expect(types[0]).toEqual({
        veloType: 'CounterVelo',
        stateType: 'CounterState',
        line: 1,
      });
      expect(types[1]).toEqual({
        veloType: 'UserVelo',
        stateType: 'UserState',
        line: 5,
      });
    });
  });

  describe('hasVeloImport', () => {
    it('should return true if document has velo import', () => {
      const content = `
import 'package:flutter/material.dart';
import 'package:velo/velo.dart';
import 'package:provider/provider.dart';
      `;
      const document = new MockTextDocument(content);
      expect(analyzer.hasVeloImport(document as any)).toBe(true);
    });

    it('should return false if document does not have velo import', () => {
      const content = `
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
      `;
      const document = new MockTextDocument(content);
      expect(analyzer.hasVeloImport(document as any)).toBe(false);
    });
  });

  describe('getImports', () => {
    it('should extract all import statements', () => {
      const content = `
import 'package:flutter/material.dart';
import 'package:velo/velo.dart';
import '../models/user.dart';
      `;
      const document = new MockTextDocument(content);
      const imports = analyzer.getImports(document as any);

      expect(imports).toHaveLength(3);
      expect(imports).toContain('package:flutter/material.dart');
      expect(imports).toContain('package:velo/velo.dart');
      expect(imports).toContain('../models/user.dart');
    });
  });

  describe('findStateProperties', () => {
    it('should find properties in state class', () => {
      const content = `
class CounterState extends Equatable {
  const CounterState({
    this.count = 0,
    this.isLoading = false,
    required this.data,
  });

  final int count;
  final bool isLoading;
  final String data;
  final List<String>? items;

  @override
  List<Object?> get props => [count, isLoading, data, items];
}
      `;
      const document = new MockTextDocument(content);
      const properties = analyzer.findStateProperties(document as any, 'CounterState');

      expect(properties).toHaveLength(4);
      expect(properties[0]).toEqual({ type: 'int', name: 'count' });
      expect(properties[1]).toEqual({ type: 'bool', name: 'isLoading' });
      expect(properties[2]).toEqual({ type: 'String', name: 'data' });
      expect(properties[3]).toEqual({ type: 'List<String>?', name: 'items' });
    });
  });

  describe('isLikelyWidget', () => {
    it('should return true for widget-like text', () => {
      expect(analyzer.isLikelyWidget('Container(child: Text("Hello"))')).toBe(true);
      expect(analyzer.isLikelyWidget('Column(children: [])')).toBe(true);
      expect(analyzer.isLikelyWidget('ElevatedButton(onPressed: null)')).toBe(true);
    });

    it('should return false for non-widget text', () => {
      expect(analyzer.isLikelyWidget('final count = 0;')).toBe(false);
      expect(analyzer.isLikelyWidget('void increment() {}')).toBe(false);
    });
  });

  describe('findContextUsages', () => {
    it('should find context.read and context.watch usages', () => {
      const content = `
void increment() {
  context.read<CounterVelo>().increment();
}

Widget build(BuildContext context) {
  final state = context.watch<CounterVelo>();
  final user = context.read<UserVelo>();
  return Text(state.count.toString());
}
      `;
      const document = new MockTextDocument(content);
      const usages = analyzer.findContextUsages(document as any);

      expect(usages).toHaveLength(3);
      expect(usages[0]).toEqual({ type: 'read', veloType: 'CounterVelo', line: 2 });
      expect(usages[1]).toEqual({ type: 'watch', veloType: 'CounterVelo', line: 6 });
      expect(usages[2]).toEqual({ type: 'read', veloType: 'UserVelo', line: 7 });
    });
  });
});