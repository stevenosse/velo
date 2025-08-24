export class MockTextDocument {
  uri: any;
  fileName: string;
  isUntitled = false;
  languageId = 'dart';
  version = 1;
  isDirty = false;
  isClosed = false;
  save: () => Thenable<boolean> = jest.fn();
  eol = 1; // LF
  encoding = 'utf8';
  lineCount: number;

  private _text: string;

  constructor(content: string, uri?: vscode.Uri) {
    this._text = content;
    this.lineCount = content.split('\n').length;
    this.uri = uri || vscode.Uri.file('/test.dart');
    this.fileName = this.uri.fsPath;
  }

  getText(range?: vscode.Range): string {
    if (!range) {
      return this._text;
    }
    const lines = this._text.split('\n');
    const startLine = Math.max(0, range.start.line);
    const endLine = Math.min(lines.length - 1, range.end.line);
    
    if (startLine === endLine) {
      return lines[startLine].substring(range.start.character, range.end.character);
    }
    
    const result = [
      lines[startLine].substring(range.start.character),
      ...lines.slice(startLine + 1, endLine),
      lines[endLine].substring(0, range.end.character)
    ];
    
    return result.join('\n');
  }

  getWordRangeAtPosition(): vscode.Range | undefined {
    return undefined;
  }

  validateRange(range: vscode.Range): vscode.Range {
    return range;
  }

  validatePosition(position: vscode.Position): vscode.Position {
    return position;
  }

  positionAt(offset: number): vscode.Position {
    const lines = this._text.substring(0, offset).split('\n');
    return new vscode.Position(lines.length - 1, lines[lines.length - 1].length);
  }

  offsetAt(position: vscode.Position): number {
    const lines = this._text.split('\n');
    let offset = 0;
    for (let i = 0; i < position.line; i++) {
      offset += lines[i].length + 1; // +1 for newline
    }
    return offset + position.character;
  }

  lineAt(position: vscode.Position | number): vscode.TextLine {
    const lineNumber = typeof position === 'number' ? position : position.line;
    const lines = this._text.split('\n');
    const text = lines[lineNumber] || '';
    
    return {
      lineNumber,
      text,
      range: new vscode.Range(lineNumber, 0, lineNumber, text.length),
      rangeIncludingLineBreak: new vscode.Range(lineNumber, 0, lineNumber + 1, 0),
      firstNonWhitespaceCharacterIndex: text.search(/\S|$/),
      isEmptyOrWhitespace: text.trim().length === 0,
    };
  }
}

export class MockWorkspaceEdit {
  size = 0;
  
  replace(_uri: vscode.Uri, _range: vscode.Range, _newText: string): void {
    this.size++;
  }

  insert(_uri: vscode.Uri, _position: vscode.Position, _newText: string): void {
    this.size++;
  }

  delete(_uri: vscode.Uri, _range: vscode.Range): void {
    this.size++;
  }

  has(_uri: vscode.Uri): boolean {
    return this.size > 0;
  }

  set(_uri: vscode.Uri, edits: any): void {
    this.size = Array.isArray(edits) ? edits.length : 1;
  }

  get(_uri: vscode.Uri): any[] {
    return [];
  }

  createFile(_uri: vscode.Uri, _options?: any): void {
    this.size++;
  }

  deleteFile(_uri: vscode.Uri, _options?: any): void {
    this.size++;
  }

  renameFile(_oldUri: vscode.Uri, _newUri: vscode.Uri, _options?: any): void {
    this.size++;
  }

  entries(): [vscode.Uri, any[]][] {
    return [];
  }
}

export const mockVscode = {
  CodeActionKind: {
    Refactor: { value: 'refactor' }
  },
  Range: jest.fn().mockImplementation((start, end) => ({ start, end })),
  Position: jest.fn().mockImplementation((line, character) => ({ line, character })),
  CodeAction: jest.fn().mockImplementation((title, kind) => ({ 
    title, 
    kind,
    edit: undefined 
  })),
  WorkspaceEdit: MockWorkspaceEdit,
  Uri: {
    file: jest.fn().mockImplementation((path) => ({ fsPath: path, scheme: 'file' })),
  },
  workspace: {
    fs: {
      stat: jest.fn(),
      writeFile: jest.fn(),
      createDirectory: jest.fn(),
    },
    workspaceFolders: [
      {
        uri: { fsPath: '/workspace' },
        name: 'test-workspace',
        index: 0,
      }
    ],
  },
  window: {
    showInputBox: jest.fn(),
    showQuickPick: jest.fn(),
    showErrorMessage: jest.fn(),
    showWarningMessage: jest.fn(),
    showTextDocument: jest.fn(),
    activeTextEditor: undefined,
  },
  commands: {
    registerCommand: jest.fn(),
  },
  languages: {
    registerCodeActionsProvider: jest.fn(),
  },
};