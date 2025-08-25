import * as path from 'path';
import * as vscode from 'vscode';
import { TemplateGenerator } from '../templates/template-generator';
import { PathUtils } from '../utils/path-utils';

export class VeloCommands {
  private templateGenerator = new TemplateGenerator();

  /**
   * Creates a new Velo class
   */
  async newVelo(uri?: vscode.Uri): Promise<void> {
    const targetDir = PathUtils.getTargetDirectory(uri);
    if (!targetDir) {
      vscode.window.showErrorMessage('No target directory found');
      return;
    }

    const fileName = await vscode.window.showInputBox({
      prompt: 'Enter Velo class name',
      placeHolder: 'CounterNotifier',
      validateInput: (value) => {
        if (!value) return 'Name is required';
        if (!/^[A-Z][a-zA-Z0-9]*Notifier$/.test(value)) {
          return 'Name must be PascalCase and end with "Notifier"';
        }
        return null;
      },
    });

    if (!fileName) return;

    const filePath = PathUtils.createFilePath(targetDir, fileName);

    if (await PathUtils.fileExists(filePath)) {
      const overwrite = await vscode.window.showWarningMessage(
        `File ${path.basename(filePath)} already exists. Overwrite?`,
        'Yes',
        'No'
      );
      if (overwrite !== 'Yes') return;
    }

    const content = this.templateGenerator.generateVeloClass(fileName);
    await this.writeFile(filePath, content);
    await vscode.window.showTextDocument(vscode.Uri.file(filePath));
  }

  /**
   * Creates a new State class
   */
  async newState(uri?: vscode.Uri): Promise<void> {
    const targetDir = PathUtils.getTargetDirectory(uri);
    if (!targetDir) {
      vscode.window.showErrorMessage('No target directory found');
      return;
    }

    const fileName = await vscode.window.showInputBox({
      prompt: 'Enter State class name',
      placeHolder: 'CounterState',
      validateInput: (value) => {
        if (!value) return 'Name is required';
        if (!/^[A-Z][a-zA-Z0-9]*State$/.test(value)) {
          return 'Name must be PascalCase and end with "State"';
        }
        return null;
      },
    });

    if (!fileName) return;

    const properties = await this.getStateProperties();
    const filePath = PathUtils.createFilePath(targetDir, fileName);

    if (await PathUtils.fileExists(filePath)) {
      const overwrite = await vscode.window.showWarningMessage(
        `File ${path.basename(filePath)} already exists. Overwrite?`,
        'Yes',
        'No'
      );
      if (overwrite !== 'Yes') return;
    }

    const content = this.templateGenerator.generateStateClass(fileName, properties);
    await this.writeFile(filePath, content);
    await vscode.window.showTextDocument(vscode.Uri.file(filePath));
  }

  /**
   * Creates both Velo and State classes
   */
  async newVeloWithState(uri?: vscode.Uri): Promise<void> {
    const targetDir = PathUtils.getTargetDirectory(uri);
    if (!targetDir) {
      vscode.window.showErrorMessage('No target directory found');
      return;
    }

    const baseName = await vscode.window.showInputBox({
      prompt: 'Enter base name (e.g., "Counter" will create CounterNotifier and CounterState)',
      placeHolder: 'Counter',
      validateInput: (value) => {
        if (!value) return 'Name is required';
        if (!/^[A-Z][a-zA-Z0-9]*$/.test(value)) {
          return 'Name must be PascalCase and start with uppercase letter';
        }
        return null;
      },
    });

    if (!baseName) return;

    const properties = await this.getStateProperties();
    const veloName = `${baseName}Notifier`;
    const stateName = `${baseName}State`;

    // Create state file
    const stateFilePath = PathUtils.createFilePath(targetDir, stateName);
    const stateContent = this.templateGenerator.generateStateClass(stateName, properties);
    await this.writeFile(stateFilePath, stateContent);

    // Create velo file with import
    const veloFilePath = PathUtils.createFilePath(targetDir, veloName);
    const stateImport = PathUtils.getRelativeImportPath(veloFilePath, stateFilePath);
    const veloContent = this.templateGenerator.generateVeloClassWithState(veloName, stateName, stateImport);
    await this.writeFile(veloFilePath, veloContent);

    await vscode.window.showTextDocument(vscode.Uri.file(veloFilePath));
  }

  /**
   * Creates a test file
   */
  async newTest(uri?: vscode.Uri): Promise<void> {
    const targetDir = PathUtils.getTargetDirectory(uri);
    if (!targetDir) {
      vscode.window.showErrorMessage('No target directory found');
      return;
    }

    const testName = await vscode.window.showInputBox({
      prompt: 'Enter test name (without _test suffix)',
      placeHolder: 'counter_notifier',
      validateInput: (value) => {
        if (!value) return 'Name is required';
        if (!/^[a-z][a-z0-9_]*$/.test(value)) {
          return 'Name must be snake_case and start with lowercase letter';
        }
        return null;
      },
    });

    if (!testName) return;

    // Create test directory if it doesn't exist
    const testDir = path.join(targetDir, 'test');
    await vscode.workspace.fs.createDirectory(vscode.Uri.file(testDir));

    const testFilePath = PathUtils.createFilePath(testDir, `${testName}_test`);
    const content = this.templateGenerator.generateTestFile(testName);
    await this.writeFile(testFilePath, content);
    await vscode.window.showTextDocument(vscode.Uri.file(testFilePath));
  }

  /**
   * Gets state properties from user input
   */
  private async getStateProperties(): Promise<Array<{ name: string; type: string; defaultValue?: string }>> {
    const properties: Array<{ name: string; type: string; defaultValue?: string }> = [];

    // eslint-disable-next-line no-constant-condition
    while (true) {
      const propertyInput = await vscode.window.showInputBox({
        prompt: `Enter property (format: "name:type:defaultValue" or "name:type"). Press ESC to finish.`,
        placeHolder: 'count:int:0',
      });

      if (!propertyInput) break;

      const parts = propertyInput.split(':');
      if (parts.length < 2) {
        vscode.window.showErrorMessage('Invalid format. Use "name:type" or "name:type:defaultValue"');
        continue;
      }

      properties.push({
        name: parts[0].trim(),
        type: parts[1].trim(),
        defaultValue: parts[2]?.trim(),
      });

      const addMore = await vscode.window.showQuickPick(['Add another property', 'Finish'], {
        placeHolder: 'Add more properties?',
      });

      if (addMore !== 'Add another property') break;
    }

    return properties;
  }

  /**
   * Writes content to a file
   */
  private async writeFile(filePath: string, content: string): Promise<void> {
    const uri = vscode.Uri.file(filePath);
    const uint8Array = Buffer.from(content, 'utf8');
    await vscode.workspace.fs.writeFile(uri, uint8Array);
  }
}