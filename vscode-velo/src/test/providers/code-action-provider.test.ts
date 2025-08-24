import { VeloCodeActionProvider } from '../../providers/code-action-provider';
import { MockTextDocument } from '../mocks/vscode-mocks';
import * as vscode from 'vscode';

// Mock vscode
jest.mock('vscode', () => ({
  CodeActionKind: {
    Refactor: { value: 'refactor' }
  },
  CodeAction: jest.fn().mockImplementation((title, kind) => ({
    title,
    kind,
    edit: undefined,
  })),
  WorkspaceEdit: jest.fn().mockImplementation(() => ({
    replace: jest.fn(),
  })),
  Range: jest.fn().mockImplementation((start, end) => ({ start, end })),
  Position: jest.fn().mockImplementation((line, character) => ({ line, character })),
  Uri: {
    file: jest.fn().mockImplementation((path) => ({ fsPath: path })),
  },
}), { virtual: true });

describe('VeloCodeActionProvider', () => {
  let provider: VeloCodeActionProvider;
  let mockContext: vscode.CodeActionContext;

  beforeEach(() => {
    provider = new VeloCodeActionProvider();
    mockContext = {} as vscode.CodeActionContext;
  });

  describe('provideCodeActions', () => {
    it('should return empty array for empty selection', () => {
      const document = new MockTextDocument('');
      const range = new vscode.Range(0, 0, 0, 0);
      
      const actions = provider.provideCodeActions(document as any, range, mockContext, {} as any);
      
      expect(actions).toEqual([]);
    });

    it('should provide wrapping actions for selected text', () => {
      const content = `
class CounterVelo extends Velo<CounterState> {}
Container()
      `;
      const document = new MockTextDocument(content);
      const range = new vscode.Range(2, 0, 2, 11); // Select "Container()"
      
      const actions = provider.provideCodeActions(document as any, range, mockContext, {} as any);
      
      expect(actions).toBeDefined();
      if (actions) {
        expect(actions.length).toBeGreaterThan(0);
        const actionTitles = actions.map(action => action.title);
        expect(actionTitles).toContain('Wrap with VeloBuilder');
        expect(actionTitles).toContain('Wrap with VeloListener');
        expect(actionTitles).toContain('Wrap with VeloConsumer');
        expect(actionTitles).toContain('Wrap with Provider');
      }
    });

    it('should provide conversion actions for VeloBuilder', () => {
      const content = `
VeloBuilder<CounterVelo, CounterState>(
  builder: (context, state) => Container(),
)
      `;
      const document = new MockTextDocument(content);
      const range = new vscode.Range(1, 0, 3, 1);
      
      const actions = provider.provideCodeActions(document as any, range, mockContext, {} as any);
      
      expect(actions).toBeDefined();
      if (actions) {
        const actionTitles = actions.map(action => action.title);
        expect(actionTitles).toContain('Convert to VeloConsumer');
      }
    });

    it('should provide conversion actions for VeloConsumer', () => {
      const content = `
VeloConsumer<CounterVelo, CounterState>(
  listener: (context, state) {},
  builder: (context, state) => Container(),
)
      `;
      const document = new MockTextDocument(content);
      const range = new vscode.Range(1, 0, 4, 1);
      
      const actions = provider.provideCodeActions(document as any, range, mockContext, {} as any);
      
      expect(actions).toBeDefined();
      if (actions) {
        const actionTitles = actions.map(action => action.title);
        expect(actionTitles).toContain('Convert to VeloBuilder');
      }
    });

    it('should provide conversion actions for Provider to MultiProvider', () => {
      const content = `
Provider<CounterVelo>(
  create: (_) => CounterVelo(),
  child: MyWidget(),
)
      `;
      const document = new MockTextDocument(content);
      const range = new vscode.Range(1, 0, 4, 1);
      
      const actions = provider.provideCodeActions(document as any, range, mockContext, {} as any);
      
      expect(actions).toBeDefined();
      if (actions) {
        const actionTitles = actions.map(action => action.title);
        expect(actionTitles).toContain('Convert to MultiProvider');
      }
    });
  });

  describe('conversion methods', () => {
    it('should convert VeloBuilder to VeloConsumer', () => {
      const builderText = `VeloBuilder<CounterVelo, CounterState>(
  builder: (context, state) {
    return Container();
  },
)`;
      
      const result = (provider as any).convertBuilderToConsumer(builderText);
      
      expect(result).toContain('VeloConsumer<CounterVelo, CounterState>');
      expect(result).toContain('listener: (context, state) {');
      expect(result).toContain('// TODO: Add your listener logic here');
      expect(result).toContain('builder: (context, state) {');
    });

    it('should convert VeloConsumer to VeloBuilder', () => {
      const consumerText = `VeloConsumer<CounterVelo, CounterState>(
  listener: (context, state) {
    // Some listener logic
  },
  builder: (context, state) {
    return Container();
  },
)`;
      
      const result = (provider as any).convertConsumerToBuilder(consumerText);
      
      expect(result).toContain('VeloBuilder');
      expect(result).not.toContain('listener:');
      expect(result).not.toContain('// Some listener logic');
    });

    it('should convert Provider to MultiProvider', () => {
      const providerText = `Provider<CounterVelo>(
  create: (_) => CounterVelo(),
  dispose: (_, velo) => velo.dispose(),
  child: MyWidget(),
)`;
      
      const result = (provider as any).convertToMultiProvider(providerText);
      
      expect(result).toContain('MultiProvider(');
      expect(result).toContain('providers: [');
      expect(result).toContain('Provider<CounterVelo>(');
      expect(result).toContain('child: MyWidget(),');
    });
  });
});