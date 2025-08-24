export interface StateProperty {
  name: string;
  type: string;
  defaultValue?: string;
}

export class TemplateGenerator {
  /**
   * Generates a Velo class template
   */
  generateVeloClass(className: string): string {
    const stateName = className.replace('Velo', 'State');
    
    return `import 'package:equatable/equatable.dart';
import 'package:velo/velo.dart';

// TODO: Import your state class
// import '${stateName.toLowerCase()}.dart';

class ${className} extends Velo<${stateName}> {
  ${className}() : super(const ${stateName}());

  // TODO: Add your methods here
  // Example:
  // void increment() {
  //   emit(state.copyWith(count: state.count + 1));
  // }
}
`;
  }

  /**
   * Generates a State class template
   */
  generateStateClass(className: string, properties: StateProperty[]): string {
    const hasProperties = properties.length > 0;
    
    // Constructor parameters
    const constructorParams = hasProperties
      ? properties.map(p => `${p.defaultValue ? `this.${p.name} = ${p.defaultValue}` : `required this.${p.name}`}`).join(',\n    ')
      : '';
    
    // Properties declaration
    const propertiesDecl = hasProperties
      ? properties.map(p => `  final ${p.type} ${p.name};`).join('\n')
      : '  // TODO: Add your properties here';
    
    // Props list
    const propsList = hasProperties
      ? properties.map(p => p.name).join(', ')
      : '// TODO: Add your properties here';
    
    // copyWith parameters
    const copyWithParams = hasProperties
      ? properties.map(p => `${p.type}? ${p.name}`).join(',\n    ')
      : '// TODO: Add your copyWith parameters here';
    
    // copyWith body
    const copyWithBody = hasProperties
      ? properties.map(p => `      ${p.name}: ${p.name} ?? this.${p.name}`).join(',\n')
      : '      // TODO: Add your copyWith logic here';

    return `import 'package:equatable/equatable.dart';

class ${className} extends Equatable {
  const ${className}({${hasProperties ? `\n    ${constructorParams},\n  ` : ''}});

${propertiesDecl}

  @override
  List<Object?> get props => [${propsList}];

  ${className} copyWith({
    ${copyWithParams}
  }) {
    return ${className}(
${copyWithBody}
    );
  }
}
`;
  }

  /**
   * Generates a Velo class with state import
   */
  generateVeloClassWithState(veloName: string, stateName: string, stateImport: string): string {
    return `import 'package:velo/velo.dart';
import '${stateImport}';

class ${veloName} extends Velo<${stateName}> {
  ${veloName}() : super(const ${stateName}());

  // TODO: Add your methods here
  // Example:
  // void increment() {
  //   emit(state.copyWith(count: state.count + 1));
  // }
  
  // Example async method:
  // Future<void> loadData() async {
  //   emit(state.copyWith(isLoading: true));
  //   try {
  //     // Your async logic here
  //     final data = await fetchData();
  //     emit(state.copyWith(data: data, isLoading: false));
  //   } catch (error) {
  //     emit(state.copyWith(error: error.toString(), isLoading: false));
  //   }
  // }
}
`;
  }

  /**
   * Generates a test file template
   */
  generateTestFile(testName: string): string {
    const className = testName.split('_').map(word => 
      word.charAt(0).toUpperCase() + word.slice(1)
    ).join('');

    return `import 'package:flutter_test/flutter_test.dart';
import 'package:velo_test/velo_test.dart';

// TODO: Import your classes
// import '../lib/${testName}.dart';

void main() {
  group('${className}', () {
    late ${className} velo;

    setUp(() {
      velo = ${className}();
    });

    tearDown(() {
      velo.dispose();
    });

    test('initial state is correct', () {
      // TODO: Add your initial state test
      // expect(velo.state, equals(const InitialState()));
    });

    test('method name changes state correctly', () {
      // TODO: Add your method tests
      // velo.methodName();
      // expect(velo.state, equals(const ExpectedState()));
    });

    // Example using velo_test matchers
    test('emits correct states', () {
      // TODO: Add state emission tests
      // expectLater(
      //   velo.stream,
      //   emitsInOrder([
      //     const InitialState(),
      //     const LoadingState(),
      //     const LoadedState(data: expectedData),
      //   ]),
      // );
      // velo.loadData();
    });
  });
}
`;
  }

  /**
   * Generates widget wrapping templates
   */
  generateVeloBuilder(selectedText: string, veloType: string, stateType: string): string {
    return `VeloBuilder<${veloType}, ${stateType}>(
  builder: (context, state) {
    return ${selectedText};
  },
)`;
  }

  generateVeloListener(selectedText: string, veloType: string, stateType: string): string {
    return `VeloListener<${veloType}, ${stateType}>(
  listener: (context, state) {
    // TODO: Add your listener logic here
  },
  child: ${selectedText},
)`;
  }

  generateVeloConsumer(selectedText: string, veloType: string, stateType: string): string {
    return `VeloConsumer<${veloType}, ${stateType}>(
  listener: (context, state) {
    // TODO: Add your listener logic here
  },
  builder: (context, state) {
    return ${selectedText};
  },
)`;
  }

  generateProvider(selectedText: string, veloType: string): string {
    return `Provider<${veloType}>(
  create: (_) => ${veloType}(),
  dispose: (_, velo) => velo.dispose(),
  child: ${selectedText},
)`;
  }
}