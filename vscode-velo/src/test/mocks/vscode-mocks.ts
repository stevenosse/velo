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

  constructor(content: string, uri?: any) {
    this._text = content;
    this.lineCount = content.split('\n').length;
    this.uri = uri || { fsPath: '/test.dart' };
    this.fileName = this.uri.fsPath;
  }

  getText(range?: any): string {
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

  getWordRangeAtPosition(): any {
    return undefined;
  }

  validateRange(range: any): any {
    return range;
  }

  validatePosition(position: any): any {
    return position;
  }

  positionAt(offset: number): any {
    const lines = this._text.substring(0, offset).split('\n');
    return { line: lines.length - 1, character: lines[lines.length - 1].length };
  }

  offsetAt(position: any): number {
    const lines = this._text.split('\n');
    let offset = 0;
    for (let i = 0; i < position.line; i++) {
      offset += lines[i].length + 1; // +1 for newline
    }
    return offset + position.character;
  }

  lineAt(position: any): any {
    const lineNumber = typeof position === 'number' ? position : position.line;
    const lines = this._text.split('\n');
    const text = lines[lineNumber] || '';
    
    return {
      lineNumber,
      text,
      range: { start: { line: lineNumber, character: 0 }, end: { line: lineNumber, character: text.length } },
      rangeIncludingLineBreak: { start: { line: lineNumber, character: 0 }, end: { line: lineNumber + 1, character: 0 } },
      firstNonWhitespaceCharacterIndex: text.search(/\S|$/),
      isEmptyOrWhitespace: text.trim().length === 0,
    };
  }
}

export class MockWorkspaceEdit {
  size = 0;
  
  replace(_uri: any, _range: any, _newText: string): void {
    this.size++;
  }

  insert(_uri: any, _position: any, _newText: string): void {
    this.size++;
  }

  delete(_uri: any, _range: any): void {
    this.size++;
  }

  has(_uri: any): boolean {
    return this.size > 0;
  }

  set(_uri: any, edits: any): void {
    this.size = Array.isArray(edits) ? edits.length : 1;
  }

  get(_uri: any): any[] {
    return [];
  }

  createFile(_uri: any, _options?: any): void {
    this.size++;
  }

  deleteFile(_uri: any, _options?: any): void {
    this.size++;
  }

  renameFile(_oldUri: any, _newUri: any, _options?: any): void {
    this.size++;
  }

  entries(): [any, any[]][] {
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