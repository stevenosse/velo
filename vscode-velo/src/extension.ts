import * as vscode from 'vscode';
import { VeloCommands } from './commands/velo-commands';
import { VeloCodeActionProvider } from './providers/code-action-provider';

export function activate(context: vscode.ExtensionContext): void {
  // Register commands
  const veloCommands = new VeloCommands();

  const disposables = [
    // Command registrations
    vscode.commands.registerCommand('velo.newVelo', (uri) =>
      veloCommands.newVelo(uri)
    ),
    vscode.commands.registerCommand('velo.newState', (uri) =>
      veloCommands.newState(uri)
    ),
    vscode.commands.registerCommand('velo.newVeloWithState', (uri) =>
      veloCommands.newVeloWithState(uri)
    ),
    vscode.commands.registerCommand('velo.newTest', (uri) =>
      veloCommands.newTest(uri)
    ),

    // Debug command for testing code actions
    vscode.commands.registerCommand('velo.debugCodeActions', () => {
      const editor = vscode.window.activeTextEditor;
      if (editor) {
        const selection = editor.selection;
        const selectedText = editor.document.getText(selection);
        vscode.window.showInformationMessage(`Selected text: "${selectedText}"`);
      } else {
        vscode.window.showInformationMessage('No active editor');
      }
    }),

    // Code action provider
    vscode.languages.registerCodeActionsProvider(
      'dart',
      new VeloCodeActionProvider(),
      {
        providedCodeActionKinds: [
          vscode.CodeActionKind.Refactor,
          vscode.CodeActionKind.QuickFix,
        ],
      }
    ),
  ];

  context.subscriptions.push(...disposables);
}

export function deactivate(): void {
  // Clean up resources if needed
}