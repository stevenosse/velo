import * as vscode from 'vscode';
import { VeloCommands } from './commands/velo-commands';
import { VeloCodeActionProvider } from './providers/code-action-provider';

export function activate(context: vscode.ExtensionContext): void {
  console.log('Velo extension is now active!');

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

    // Code action provider
    vscode.languages.registerCodeActionsProvider(
      'dart',
      new VeloCodeActionProvider(),
      {
        providedCodeActionKinds: [vscode.CodeActionKind.Refactor],
      }
    ),
  ];

  context.subscriptions.push(...disposables);
}

export function deactivate(): void {
  // Clean up resources if needed
}