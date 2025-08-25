import * as vscode from 'vscode';
import { DartAnalyzer } from '../analyzer/dart-analyzer';
import { TemplateGenerator } from '../templates/template-generator';

export class VeloCodeActionProvider implements vscode.CodeActionProvider {
  private templateGenerator = new TemplateGenerator();
  private dartAnalyzer = new DartAnalyzer();

  public provideCodeActions(
    document: vscode.TextDocument,
    range: vscode.Range | vscode.Selection,
    _context: vscode.CodeActionContext,
    _token: vscode.CancellationToken
  ): vscode.CodeAction[] | undefined {
    const actions: vscode.CodeAction[] = [];
    const selectedText = document.getText(range).trim();

    if (!selectedText) {
      return actions;
    }

    // Add wrapping actions
    const wrappingActions = this.createWrappingActions(document, range, selectedText);
    actions.push(...wrappingActions);

    // Add conversion actions if applicable
    const conversionActions = this.createConversionActions(document, range, selectedText);
    actions.push(...conversionActions);

    return actions;
  }

  private createWrappingActions(
    document: vscode.TextDocument,
    range: vscode.Range,
    selectedText: string
  ): vscode.CodeAction[] {
    const actions: vscode.CodeAction[] = [];

    // Try to detect Velo and State types from context
    const veloTypes = this.dartAnalyzer.findVeloTypesInDocument(document);

    const defaultVeloType = veloTypes.length > 0 ? veloTypes[0].veloType : 'MyNotifier';
    const defaultStateType = veloTypes.length > 0 ? veloTypes[0].stateType : 'MyState';

    // Wrap with VeloBuilder
    const wrapWithBuilderAction = new vscode.CodeAction(
      'Wrap with VeloBuilder',
      vscode.CodeActionKind.QuickFix
    );
    wrapWithBuilderAction.edit = new vscode.WorkspaceEdit();
    wrapWithBuilderAction.edit.replace(
      document.uri,
      range,
      this.templateGenerator.generateVeloBuilder(selectedText, defaultVeloType, defaultStateType)
    );
    actions.push(wrapWithBuilderAction);

    // Wrap with VeloListener
    const wrapWithListenerAction = new vscode.CodeAction(
      'Wrap with VeloListener',
      vscode.CodeActionKind.QuickFix
    );
    wrapWithListenerAction.edit = new vscode.WorkspaceEdit();
    wrapWithListenerAction.edit.replace(
      document.uri,
      range,
      this.templateGenerator.generateVeloListener(selectedText, defaultVeloType, defaultStateType)
    );
    actions.push(wrapWithListenerAction);

    // Wrap with VeloConsumer
    const wrapWithConsumerAction = new vscode.CodeAction(
      'Wrap with VeloConsumer',
      vscode.CodeActionKind.QuickFix
    );
    wrapWithConsumerAction.edit = new vscode.WorkspaceEdit();
    wrapWithConsumerAction.edit.replace(
      document.uri,
      range,
      this.templateGenerator.generateVeloConsumer(selectedText, defaultVeloType, defaultStateType)
    );
    actions.push(wrapWithConsumerAction);

    // Wrap with Provider
    const wrapWithProviderAction = new vscode.CodeAction(
      'Wrap with Provider',
      vscode.CodeActionKind.QuickFix
    );
    wrapWithProviderAction.edit = new vscode.WorkspaceEdit();
    wrapWithProviderAction.edit.replace(
      document.uri,
      range,
      this.templateGenerator.generateProvider(selectedText, defaultVeloType)
    );
    actions.push(wrapWithProviderAction);

    return actions;
  }

  private createConversionActions(
    document: vscode.TextDocument,
    range: vscode.Range,
    selectedText: string
  ): vscode.CodeAction[] {
    const actions: vscode.CodeAction[] = [];

    // Convert VeloBuilder to VeloConsumer
    if (selectedText.includes('VeloBuilder')) {
      const convertToConsumerAction = new vscode.CodeAction(
        'Convert to VeloConsumer',
        vscode.CodeActionKind.QuickFix
      );
      convertToConsumerAction.edit = new vscode.WorkspaceEdit();
      convertToConsumerAction.edit.replace(
        document.uri,
        range,
        this.convertBuilderToConsumer(selectedText)
      );
      actions.push(convertToConsumerAction);
    }

    // Convert VeloConsumer to VeloBuilder
    if (selectedText.includes('VeloConsumer')) {
      const convertToBuilderAction = new vscode.CodeAction(
        'Convert to VeloBuilder',
        vscode.CodeActionKind.QuickFix
      );
      convertToBuilderAction.edit = new vscode.WorkspaceEdit();
      convertToBuilderAction.edit.replace(
        document.uri,
        range,
        this.convertConsumerToBuilder(selectedText)
      );
      actions.push(convertToBuilderAction);
    }

    // Convert Provider to MultiProvider
    if (selectedText.includes('Provider<') && !selectedText.includes('MultiProvider')) {
      const convertToMultiProviderAction = new vscode.CodeAction(
        'Convert to MultiProvider',
        vscode.CodeActionKind.QuickFix
      );
      convertToMultiProviderAction.edit = new vscode.WorkspaceEdit();
      convertToMultiProviderAction.edit.replace(
        document.uri,
        range,
        this.convertToMultiProvider(selectedText)
      );
      actions.push(convertToMultiProviderAction);
    }

    return actions;
  }

  private convertBuilderToConsumer(builderText: string): string {
    return builderText.replace(
      /VeloBuilder<([^>]+)>\s*\(\s*builder:\s*\(([^)]+)\)\s*\{/,
      'VeloConsumer<$1>(\n  listener: ($2) {\n    // TODO: Add your listener logic here\n  },\n  builder: ($2) {'
    );
  }

  private convertConsumerToBuilder(consumerText: string): string {
    // Remove listener parameter and keep only builder
    return consumerText
      .replace('VeloConsumer', 'VeloBuilder')
      .replace(/listener:\s*\([^)]+\)\s*\{[^}]*\},?\s*/s, '');
  }

  private convertToMultiProvider(providerText: string): string {
    const providerMatch = providerText.match(/Provider<([^>]+)>\s*\(\s*([^)]+)\s*\)/s);
    if (providerMatch) {
      return `MultiProvider(
  providers: [
    Provider<${providerMatch[1]}>(${providerMatch[2]}),
  ],
  child: ${this.extractChildFromProvider(providerText)},
)`;
    }
    return providerText;
  }

  private extractChildFromProvider(providerText: string): string {
    const childMatch = providerText.match(/child:\s*([^,}]+)/s);
    return childMatch ? childMatch[1].trim() : 'child';
  }
}