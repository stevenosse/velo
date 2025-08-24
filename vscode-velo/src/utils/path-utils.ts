import * as path from 'path';
import * as vscode from 'vscode';

export class PathUtils {
  /**
   * Converts a string to PascalCase
   */
  static toPascalCase(input: string): string {
    // If it's already PascalCase, return as-is
    if (input.match(/^[A-Z][a-zA-Z0-9]*$/)) {
      return input;
    }
    
    return input
      .split(/[-_\s]/)
      .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
      .join('');
  }

  /**
   * Converts a string to snake_case
   */
  static toSnakeCase(input: string): string {
    return input
      .replace(/([A-Z])/g, '_$1')
      .toLowerCase()
      .replace(/^_/, '');
  }

  /**
   * Gets the target directory from URI or active editor
   */
  static getTargetDirectory(uri?: vscode.Uri): string | undefined {
    if (uri) {
      return uri.fsPath;
    }

    const activeEditor = vscode.window.activeTextEditor;
    if (activeEditor) {
      return path.dirname(activeEditor.document.fileName);
    }

    const workspaceFolders = vscode.workspace.workspaceFolders;
    if (workspaceFolders && workspaceFolders.length > 0) {
      return workspaceFolders[0].uri.fsPath;
    }

    return undefined;
  }

  /**
   * Creates a file path with proper extension
   */
  static createFilePath(directory: string, fileName: string, extension = '.dart'): string {
    const snakeCaseFileName = this.toSnakeCase(fileName);
    return path.join(directory, `${snakeCaseFileName}${extension}`);
  }

  /**
   * Gets relative import path between two files
   */
  static getRelativeImportPath(fromFile: string, toFile: string): string {
    const relativePath = path.relative(path.dirname(fromFile), toFile);
    return relativePath.replace(/\\/g, '/');
  }

  /**
   * Checks if a file already exists
   */
  static async fileExists(filePath: string): Promise<boolean> {
    try {
      await vscode.workspace.fs.stat(vscode.Uri.file(filePath));
      return true;
    } catch {
      return false;
    }
  }
}