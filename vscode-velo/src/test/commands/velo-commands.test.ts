import { VeloCommands } from '../../commands/velo-commands';

// Mock vscode
const mockShowInputBox = jest.fn();
const mockShowQuickPick = jest.fn();
const mockShowErrorMessage = jest.fn();
const mockShowWarningMessage = jest.fn();
const mockShowTextDocument = jest.fn();
const mockWriteFile = jest.fn();
const mockCreateDirectory = jest.fn();

jest.mock('vscode', () => ({
  window: {
    showInputBox: mockShowInputBox,
    showQuickPick: mockShowQuickPick,
    showErrorMessage: mockShowErrorMessage,
    showWarningMessage: mockShowWarningMessage,
    showTextDocument: mockShowTextDocument,
    activeTextEditor: undefined,
  },
  workspace: {
    fs: {
      writeFile: mockWriteFile,
      createDirectory: mockCreateDirectory,
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
    file: jest.fn().mockImplementation((path) => ({ fsPath: path })),
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

describe('VeloCommands', () => {
  let commands: VeloCommands;

  beforeEach(() => {
    commands = new VeloCommands();
    jest.clearAllMocks();
  });

  describe('newVelo', () => {
    it('should create a new Velo file successfully', async () => {
      mockShowInputBox.mockResolvedValue('CounterVelo');
      
      await commands.newVelo();
      
      expect(mockShowInputBox).toHaveBeenCalledWith({
        prompt: 'Enter Velo class name',
        placeHolder: 'CounterVelo',
        validateInput: expect.any(Function),
      });
      expect(mockWriteFile).toHaveBeenCalled();
      expect(mockShowTextDocument).toHaveBeenCalled();
    });

    it('should validate Velo class name', async () => {
      mockShowInputBox.mockResolvedValue('counterVelo'); // Invalid: should start with uppercase
      
      await commands.newVelo();
      
      const validateInput = mockShowInputBox.mock.calls[0][0].validateInput;
      expect(validateInput('counterVelo')).toBeTruthy();
      expect(validateInput('CounterVelo')).toBeNull();
      expect(validateInput('')).toBeTruthy();
    });

    it('should handle no input gracefully', async () => {
      mockShowInputBox.mockResolvedValue(undefined);
      
      await commands.newVelo();
      
      expect(mockWriteFile).not.toHaveBeenCalled();
    });

    it('should show error when no target directory found', async () => {
      const { PathUtils } = jest.requireActual('../../utils/path-utils');
      PathUtils.getTargetDirectory.mockReturnValue(undefined);
      
      await commands.newVelo();
      
      expect(mockShowErrorMessage).toHaveBeenCalledWith('No target directory found');
    });
  });

  describe('newState', () => {
    it('should create a new State file successfully', async () => {
      mockShowInputBox
        .mockResolvedValueOnce('CounterState')
        .mockResolvedValueOnce(undefined); // No properties
      
      await commands.newState();
      
      expect(mockShowInputBox).toHaveBeenCalledWith({
        prompt: 'Enter State class name',
        placeHolder: 'CounterState',
        validateInput: expect.any(Function),
      });
      expect(mockWriteFile).toHaveBeenCalled();
      expect(mockShowTextDocument).toHaveBeenCalled();
    });

    it('should validate State class name', async () => {
      mockShowInputBox.mockResolvedValue('Counter'); // Invalid: should end with "State"
      
      await commands.newState();
      
      const validateInput = mockShowInputBox.mock.calls[0][0].validateInput;
      expect(validateInput('Counter')).toBeTruthy();
      expect(validateInput('CounterState')).toBeNull();
      expect(validateInput('counterState')).toBeTruthy(); // Invalid: should start with uppercase
    });

    it('should collect state properties', async () => {
      mockShowInputBox
        .mockResolvedValueOnce('CounterState')
        .mockResolvedValueOnce('count:int:0') // First property
        .mockResolvedValueOnce('isLoading:bool:false'); // Second property
      
      mockShowQuickPick
        .mockResolvedValueOnce('Add another property') // Add second property
        .mockResolvedValueOnce('Finish'); // Finish after second property
      
      await commands.newState();
      
      expect(mockShowQuickPick).toHaveBeenCalledTimes(2);
      expect(mockShowQuickPick).toHaveBeenCalledWith(['Add another property', 'Finish'], {
        placeHolder: 'Add more properties?',
      });
    });
  });

  describe('newVeloWithState', () => {
    it('should create both Velo and State files', async () => {
      mockShowInputBox
        .mockResolvedValueOnce('Counter') // Base name
        .mockResolvedValueOnce(undefined); // No properties
      
      await commands.newVeloWithState();
      
      expect(mockWriteFile).toHaveBeenCalledTimes(2); // Both state and velo files
      expect(mockShowTextDocument).toHaveBeenCalledWith(
        expect.objectContaining({
          fsPath: '/test/directory/CounterVelo.dart'
        })
      );
    });

    it('should validate base name', async () => {
      mockShowInputBox.mockResolvedValue('counter'); // Invalid: should start with uppercase
      
      await commands.newVeloWithState();
      
      const validateInput = mockShowInputBox.mock.calls[0][0].validateInput;
      expect(validateInput('counter')).toBeTruthy();
      expect(validateInput('Counter')).toBeNull();
    });
  });

  describe('newTest', () => {
    it('should create a test file successfully', async () => {
      mockShowInputBox.mockResolvedValue('counter_velo');
      
      await commands.newTest();
      
      expect(mockShowInputBox).toHaveBeenCalledWith({
        prompt: 'Enter test name (without _test suffix)',
        placeHolder: 'counter_velo',
        validateInput: expect.any(Function),
      });
      expect(mockCreateDirectory).toHaveBeenCalled();
      expect(mockWriteFile).toHaveBeenCalled();
      expect(mockShowTextDocument).toHaveBeenCalled();
    });

    it('should validate test name', async () => {
      mockShowInputBox.mockResolvedValue('CounterVelo'); // Invalid: should be snake_case
      
      await commands.newTest();
      
      const validateInput = mockShowInputBox.mock.calls[0][0].validateInput;
      expect(validateInput('CounterVelo')).toBeTruthy();
      expect(validateInput('counter_velo')).toBeNull();
      expect(validateInput('123invalid')).toBeTruthy(); // Invalid: starts with number
    });
  });

  describe('file overwrite handling', () => {
    it('should ask for confirmation when file exists', async () => {
      const { PathUtils } = jest.requireActual('../../utils/path-utils');
      PathUtils.fileExists.mockResolvedValue(true);
      
      mockShowInputBox.mockResolvedValue('CounterVelo');
      mockShowWarningMessage.mockResolvedValue('Yes');
      
      await commands.newVelo();
      
      expect(mockShowWarningMessage).toHaveBeenCalledWith(
        'File counter_velo.dart already exists. Overwrite?',
        'Yes',
        'No'
      );
      expect(mockWriteFile).toHaveBeenCalled();
    });

    it('should cancel creation when user chooses not to overwrite', async () => {
      const { PathUtils } = jest.requireActual('../../utils/path-utils');
      PathUtils.fileExists.mockResolvedValue(true);
      
      mockShowInputBox.mockResolvedValue('CounterVelo');
      mockShowWarningMessage.mockResolvedValue('No');
      
      await commands.newVelo();
      
      expect(mockWriteFile).not.toHaveBeenCalled();
      expect(mockShowTextDocument).not.toHaveBeenCalled();
    });
  });
});