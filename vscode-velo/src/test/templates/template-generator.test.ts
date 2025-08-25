import { TemplateGenerator, StateProperty } from '../../templates/template-generator';

describe('TemplateGenerator', () => {
  let generator: TemplateGenerator;

  beforeEach(() => {
    generator = new TemplateGenerator();
  });

  describe('generateVeloClass', () => {
    it('should generate a basic Velo class template', () => {
      const result = generator.generateVeloClass('CounterVelo');
      
      expect(result).toContain('class CounterVelo extends Velo<CounterState>');
      expect(result).toContain('CounterVelo() : super(const CounterState());');
      expect(result).toContain('import \'package:velo/velo.dart\';');
      expect(result).toContain('// TODO: Add your methods here');
    });
  });

  describe('generateStateClass', () => {
    it('should generate state class with no properties', () => {
      const result = generator.generateStateClass('CounterState', []);
      
      expect(result).toContain('class CounterState extends Equatable');
      expect(result).toContain('const CounterState({});');
      expect(result).toContain('// TODO: Add your properties here');
      expect(result).toContain('import \'package:equatable/equatable.dart\';');
    });

    it('should generate state class with properties', () => {
      const properties: StateProperty[] = [
        { name: 'count', type: 'int', defaultValue: '0' },
        { name: 'isLoading', type: 'bool', defaultValue: 'false' },
        { name: 'data', type: 'String' }, // no default value
      ];

      const result = generator.generateStateClass('CounterState', properties);
      
      expect(result).toContain('final int count;');
      expect(result).toContain('final bool isLoading;');
      expect(result).toContain('final String data;');
      expect(result).toContain('this.count = 0');
      expect(result).toContain('this.isLoading = false');
      expect(result).toContain('required this.data');
      expect(result).toContain('List<Object?> get props => [count, isLoading, data];');
      expect(result).toContain('int? count,');
      expect(result).toContain('bool? isLoading,');
      expect(result).toContain('String? data');
    });
  });

  describe('generateVeloClassWithState', () => {
    it('should generate Velo class with state import', () => {
      const result = generator.generateVeloClassWithState(
        'CounterVelo',
        'CounterState',
        './counter_state.dart'
      );
      
      expect(result).toContain('import \'package:velo/velo.dart\';');
      expect(result).toContain('import \'./counter_state.dart\';');
      expect(result).toContain('class CounterVelo extends Velo<CounterState>');
      expect(result).toContain('CounterVelo() : super(const CounterState());');
      expect(result).toContain('// Example async method:');
    });
  });

  describe('generateTestFile', () => {
    it('should generate test file template', () => {
      const result = generator.generateTestFile('counter_velo');
      
      expect(result).toContain('import \'package:flutter_test/flutter_test.dart\';');
      expect(result).toContain('import \'package:velo_test/velo_test.dart\';');
      expect(result).toContain('group(\'CounterVelo\', () {');
      expect(result).toContain('late CounterVelo velo;');
      expect(result).toContain('setUp(() {');
      expect(result).toContain('tearDown(() {');
      expect(result).toContain('velo.dispose();');
    });
  });

  describe('generateVeloBuilder', () => {
    it('should generate VeloBuilder wrapper', () => {
      const result = generator.generateVeloBuilder(
        'Container()',
        'CounterVelo',
        'CounterState'
      );
      
      expect(result).toContain('VeloBuilder<CounterVelo, CounterState>(');
      expect(result).toContain('builder: (context, state) {');
      expect(result).toContain('return Container();');
    });
  });

  describe('generateVeloListener', () => {
    it('should generate VeloListener wrapper', () => {
      const result = generator.generateVeloListener(
        'Container()',
        'CounterVelo',
        'CounterState'
      );
      
      expect(result).toContain('VeloListener<CounterVelo, CounterState>(');
      expect(result).toContain('listener: (context, state) {');
      expect(result).toContain('child: Container(),');
    });
  });

  describe('generateVeloConsumer', () => {
    it('should generate VeloConsumer wrapper', () => {
      const result = generator.generateVeloConsumer(
        'Container()',
        'CounterVelo',
        'CounterState'
      );
      
      expect(result).toContain('VeloConsumer<CounterVelo, CounterState>(');
      expect(result).toContain('listener: (context, state) {');
      expect(result).toContain('builder: (context, state) {');
      expect(result).toContain('return Container();');
    });
  });

  describe('generateProvider', () => {
    it('should generate Provider wrapper', () => {
      const result = generator.generateProvider('MyWidget()', 'CounterVelo');
      
      expect(result).toContain('Provider<CounterVelo>(');
      expect(result).toContain('create: (_) => CounterVelo(),');
      expect(result).toContain('dispose: (_, velo) => velo.dispose(),');
      expect(result).toContain('child: MyWidget(),');
    });
  });
});