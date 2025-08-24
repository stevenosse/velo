import { VeloCommands } from '../../commands/velo-commands';

// Mock vscode
jest.mock('vscode', () => ({
  window: {
    showInputBox: jest.fn(),
    showQuickPick: jest.fn(),
    showErrorMessage: jest.fn(),
    showWarningMessage: jest.fn(),
    showTextDocument: jest.fn(),
    activeTextEditor: undefined,
  },
  workspace: {
    fs: {
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
  Uri: {
    file: jest.fn().mockImplementation((path: string) => ({ fsPath: path })),
  },
}), { virtual: true });

// Mock PathUtils
jest.mock('../../utils/path-utils', () => ({
  PathUtils: {
    getTargetDirectory: jest.fn().mockReturnValue('/test/directory'),
    createFilePath: jest.fn().mockImplementation((dir, name) => `${dir}/${name}.dart`),
    fileExists: jest.fn().mockResolvedValue(false),
    getRelativeImportPath: jest.fn().mockReturnValue('./counter_state.dart'),
  },
}));

// Import mocked vscode after defining mocks
import * as vscode from 'vscode';

describe('VeloCommands', () => {
  let commands: VeloCommands;

  beforeEach(() => {
    commands = new VeloCommands();
    jest.clearAllMocks();
  });

  describe('newVelo', () => {
    it('should create a new Velo file successfully', async () => {
      (vscode.window.showInputBox as jest.Mock).mockResolvedValue('CounterVelo');
      
      await commands.newVelo();
      
      expect((vscode.workspace.fs.writeFile as jest.Mock)).toHaveBeenCalled();
      expect((vscode.window.showTextDocument as jest.Mock)).toHaveBeenCalled();
    });

    it('should handle no input gracefully', async () => {
      (vscode.window.showInputBox as jest.Mock).mockResolvedValue(undefined);
      
      await commands.newVelo();
      
      expect((vscode.workspace.fs.writeFile as jest.Mock)).not.toHaveBeenCalled();
    });
  });

  describe('newState', () => {
    it('should create a new State file successfully', async () => {
      (vscode.window.showInputBox as jest.Mock)
        .mockResolvedValueOnce('CounterState')
        .mockResolvedValueOnce(undefined); // No properties
      
      await commands.newState();
      
      expect((vscode.workspace.fs.writeFile as jest.Mock)).toHaveBeenCalled();
      expect((vscode.window.showTextDocument as jest.Mock)).toHaveBeenCalled();
    });
  });

  describe('newVeloWithState', () => {
    it('should create both Velo and State files', async () => {
      (vscode.window.showInputBox as jest.Mock)
        .mockResolvedValueOnce('Counter')
        .mockResolvedValueOnce(undefined);
      
      await commands.newVeloWithState();
      
      expect((vscode.workspace.fs.writeFile as jest.Mock)).toHaveBeenCalledTimes(2);
    });
  });

  describe('newTest', () => {
    it('should create a test file successfully', async () => {
      (vscode.window.showInputBox as jest.Mock).mockResolvedValue('counter_velo');
      
      await commands.newTest();
      
      expect((vscode.workspace.fs.createDirectory as jest.Mock)).toHaveBeenCalled();
      expect((vscode.workspace.fs.writeFile as jest.Mock)).toHaveBeenCalled();
    });
  });
});