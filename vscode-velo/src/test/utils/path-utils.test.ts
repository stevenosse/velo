import { PathUtils } from '../../utils/path-utils';
import * as vscode from 'vscode';

// Mock vscode
jest.mock('vscode', () => ({
  workspace: {
    fs: {
      stat: jest.fn(),
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
    activeTextEditor: undefined,
  },
  Uri: {
    file: jest.fn().mockImplementation((path) => ({ fsPath: path })),
  },
}), { virtual: true });

describe('PathUtils', () => {
  describe('toPascalCase', () => {
    it('should convert snake_case to PascalCase', () => {
      expect(PathUtils.toPascalCase('counter_velo')).toBe('CounterVelo');
      expect(PathUtils.toPascalCase('user_profile_state')).toBe('UserProfileState');
    });

    it('should convert kebab-case to PascalCase', () => {
      expect(PathUtils.toPascalCase('counter-velo')).toBe('CounterVelo');
      expect(PathUtils.toPascalCase('user-profile-state')).toBe('UserProfileState');
    });

    it('should convert space separated to PascalCase', () => {
      expect(PathUtils.toPascalCase('counter velo')).toBe('CounterVelo');
      expect(PathUtils.toPascalCase('user profile state')).toBe('UserProfileState');
    });

    it('should handle already PascalCase strings', () => {
      expect(PathUtils.toPascalCase('CounterVelo')).toBe('CounterVelo');
    });
  });

  describe('toSnakeCase', () => {
    it('should convert PascalCase to snake_case', () => {
      expect(PathUtils.toSnakeCase('CounterVelo')).toBe('counter_velo');
      expect(PathUtils.toSnakeCase('UserProfileState')).toBe('user_profile_state');
    });

    it('should handle already snake_case strings', () => {
      expect(PathUtils.toSnakeCase('counter_velo')).toBe('counter_velo');
    });

    it('should handle camelCase', () => {
      expect(PathUtils.toSnakeCase('counterVelo')).toBe('counter_velo');
    });
  });

  describe('getTargetDirectory', () => {
    it('should return fsPath from provided URI', () => {
      const uri = { fsPath: '/test/path' } as vscode.Uri;
      expect(PathUtils.getTargetDirectory(uri)).toBe('/test/path');
    });

    it('should return directory from active editor when no URI provided', () => {
      const mockEditor = {
        document: {
          fileName: '/workspace/lib/main.dart'
        }
      } as vscode.TextEditor;
      
      (vscode.window as any).activeTextEditor = mockEditor;
      expect(PathUtils.getTargetDirectory()).toBe('/workspace/lib');
    });

    it('should return workspace folder when no URI or active editor', () => {
      (vscode.window as any).activeTextEditor = undefined;
      expect(PathUtils.getTargetDirectory()).toBe('/workspace');
    });
  });

  describe('createFilePath', () => {
    it('should create file path with snake_case name and .dart extension', () => {
      const result = PathUtils.createFilePath('/test', 'CounterVelo');
      expect(result).toBe('/test/counter_velo.dart');
    });

    it('should create file path with custom extension', () => {
      const result = PathUtils.createFilePath('/test', 'CounterVelo', '.test.dart');
      expect(result).toBe('/test/counter_velo.test.dart');
    });
  });

  describe('getRelativeImportPath', () => {
    it('should return correct relative path', () => {
      const fromFile = '/project/lib/pages/counter_page.dart';
      const toFile = '/project/lib/velo/counter_velo.dart';
      const result = PathUtils.getRelativeImportPath(fromFile, toFile);
      expect(result).toBe('../velo/counter_velo.dart');
    });
  });

  describe('fileExists', () => {
    it('should return true if file exists', async () => {
      (vscode.workspace.fs.stat as jest.Mock).mockResolvedValue({});
      const result = await PathUtils.fileExists('/test/file.dart');
      expect(result).toBe(true);
    });

    it('should return false if file does not exist', async () => {
      (vscode.workspace.fs.stat as jest.Mock).mockRejectedValue(new Error('File not found'));
      const result = await PathUtils.fileExists('/test/nonexistent.dart');
      expect(result).toBe(false);
    });
  });
});