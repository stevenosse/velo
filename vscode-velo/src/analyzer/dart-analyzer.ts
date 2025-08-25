import * as vscode from 'vscode';

export interface VeloTypeInfo {
  veloType: string;
  stateType: string;
  line: number;
}

export class DartAnalyzer {
  /**
   * Finds Velo types in the current document
   */
  findVeloTypesInDocument(document: vscode.TextDocument): VeloTypeInfo[] {
    const types: VeloTypeInfo[] = [];
    const text = document.getText();
    const lines = text.split('\n');

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      
      // Look for Velo class definitions: class SomeVelo extends Velo<SomeState>
      const veloClassMatch = line.match(/class\s+(\w+)\s+extends\s+Velo<(\w+)>/);
      if (veloClassMatch) {
        types.push({
          veloType: veloClassMatch[1],
          stateType: veloClassMatch[2],
          line: i,
        });
      }

      // Look for VeloBuilder/Consumer/Listener usage: VeloBuilder<SomeVelo, SomeState>
      const veloWidgetMatch = line.match(/Velo(?:Builder|Consumer|Listener)<(\w+),\s*(\w+)>/);
      if (veloWidgetMatch) {
        types.push({
          veloType: veloWidgetMatch[1],
          stateType: veloWidgetMatch[2],
          line: i,
        });
      }
    }

    return types;
  }

  /**
   * Checks if the document contains Velo imports
   */
  hasVeloImport(document: vscode.TextDocument): boolean {
    const text = document.getText();
    return /import\s+['"]package:velo\/velo\.dart['"]/.test(text);
  }

  /**
   * Gets the import statements from the document
   */
  getImports(document: vscode.TextDocument): string[] {
    const text = document.getText();
    const imports: string[] = [];
    const importRegex = /import\s+['"]([^'"]+)['"];/g;
    let match;

    while ((match = importRegex.exec(text)) !== null) {
      imports.push(match[1]);
    }

    return imports;
  }

  /**
   * Finds state properties in a state class
   */
  findStateProperties(document: vscode.TextDocument, stateName: string): Array<{name: string; type: string}> {
    const text = document.getText();
    const properties: Array<{name: string; type: string}> = [];
    
    // Look for final properties in the entire document
    // This is simpler and more reliable than trying to parse class boundaries
    const lines = text.split('\n');
    let inStateClass = false;
    
    for (const line of lines) {
      // Check if we're entering the state class
      if (line.includes(`class ${stateName} extends Equatable`)) {
        inStateClass = true;
        continue;
      }
      
      // Check if we're leaving the class (simple heuristic)
      if (inStateClass && line.match(/^class\s+\w+/) && !line.includes(stateName)) {
        inStateClass = false;
        continue;
      }
      
      // Look for final properties
      if (inStateClass) {
        const propertyMatch = line.match(/final\s+(\w+(?:\?|<[^>]*>)*)\s+(\w+);/);
        if (propertyMatch) {
          properties.push({
            type: propertyMatch[1],
            name: propertyMatch[2],
          });
        }
      }
    }
    
    return properties;
  }

  /**
   * Finds Velo methods in a Velo class
   */
  findVeloMethods(document: vscode.TextDocument, veloName: string): Array<{name: string; isAsync: boolean}> {
    const text = document.getText();
    const methods: Array<{name: string; isAsync: boolean}> = [];
    
    // Find the Velo class
    const veloClassRegex = new RegExp(`class\\s+${veloName}\\s+extends\\s+Velo<[^>]+>\\s*\\{([^}]+)\\}`, 's');
    const veloClassMatch = text.match(veloClassRegex);
    
    if (veloClassMatch) {
      const classBody = veloClassMatch[1];
      
      // Find methods (excluding constructor)
      const methodRegex = /(Future<\w+>|void)\\s+(\\w+)\\s*\\([^)]*\\)\\s*(?:async)?\\s*\\{/g;
      let methodMatch;
      
      while ((methodMatch = methodRegex.exec(classBody)) !== null) {
        const returnType = methodMatch[1];
        const methodName = methodMatch[2];
        
        if (methodName !== veloName) { // Exclude constructor
          methods.push({
            name: methodName,
            isAsync: returnType.startsWith('Future'),
          });
        }
      }
    }
    
    return methods;
  }

  /**
   * Checks if text is likely a widget
   */
  isLikelyWidget(text: string): boolean {
    const widgetIndicators = [
      'Widget',
      'StatelessWidget',
      'StatefulWidget',
      'Container',
      'Text',
      'Column',
      'Row',
      'Scaffold',
      'AppBar',
      'FloatingActionButton',
      'ElevatedButton',
      'TextButton',
      'IconButton',
    ];
    
    return widgetIndicators.some(indicator => text.includes(indicator));
  }

  /**
   * Extracts the widget type from selected text
   */
  extractWidgetType(text: string): string | null {
    const widgetMatch = text.match(/(\w+)\s*\(/);
    return widgetMatch ? widgetMatch[1] : null;
  }

  /**
   * Finds context.read or context.watch usages
   */
  findContextUsages(document: vscode.TextDocument): Array<{type: 'read' | 'watch'; veloType: string; line: number}> {
    const text = document.getText();
    const usages: Array<{type: 'read' | 'watch'; veloType: string; line: number}> = [];
    const lines = text.split('\n');

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      
      // context.read<SomeVelo>()
      const readMatch = line.match(/context\.read<(\w+)>\(\)/);
      if (readMatch) {
        usages.push({
          type: 'read',
          veloType: readMatch[1],
          line: i,
        });
      }

      // context.watch<SomeVelo>()
      const watchMatch = line.match(/context\.watch<(\w+)>\(\)/);
      if (watchMatch) {
        usages.push({
          type: 'watch',
          veloType: watchMatch[1],
          line: i,
        });
      }
    }

    return usages;
  }
}