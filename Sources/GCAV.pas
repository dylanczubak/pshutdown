unit GCAV;

interface

uses SharedTypes;

type
  TPluginsList = record
    PluginFile: string;
    PluginDesription: TPluginInfo;
  end;

const

  WMU_PSHUTDOWN_INC = 2331;
  WMU_DEFAULT = 1024 + WMU_PSHUTDOWN_INC;
  WMU_PLUGIN_SELECTED = WMU_DEFAULT + 1;
  WMU_1 = WMU_DEFAULT + 2;
  WMU_2 = WMU_DEFAULT + 3;
  WMU_3 = WMU_DEFAULT + 4;


  SECONDS_IN_DAY = 86400;
  SECONDS_IN_HOUR = 3600;
  SECONDS_IN_MINUTE = 60;

  DEF_SETTINGS_FILE = 'Settings.ini';
  PLUGIN_PATH = 'Plugins\';
  LANGUAGE_PATH = 'Languages\';
  NEW_LINE = #13 + #10;
  {
    ������������ ����������: [gvs]
    [gv] - (Global Value)
    [s] - (Settings) ����������, ���������� �� ��������� ���������
    }
var

  MainFormHandle: Cardinal;

  mbtext_AreYouShoreWantTo: string = '�� ������������� ������ ';
  mbtext_ThisPluginHasNoSettings: string = '� ������� ������� ��� ��������.';
  mbtext_UnableToSaveSettings: string = '���������� ��������� ���������.';
  mbtext_FileIsWriteProtected: string = '���� ������� �� ������.';
  mbtext_ChoosePlugin: string = '������� ������';

  gvMainWindowHandle: LongWord;
  { [���������] }
  gvFilePath: string; // ���� ������������ �����
  gvParameters: string = ''; // ��������� ������������ �����
  gvSoundPath: string = ''; // ���� ����� �����
  gvSoundLoop: boolean = False;
  gvTextMessage: string = ''; // ����� ���������

  { GENERAL }
  gvsShowMessageIfNow: boolean = True;
  // �������� ������ ��� ���������� ������� ����������
  gvsShowMessageOnlyForCrytical: boolean = False;
  // �������� ������ ������������� ������ ��� ����������� ������� }
  gvsForceAction: boolean = False;
  // True = ��������� ����� ����������� �������������, ���� ���� �� �������� ���������
  gvsBeepLastTen: boolean = False;
  gvsBeepOnB: boolean = False;
  // �������� �������� ������ � ������ ������� {gvsBeepOnI}
  gvsBeepOnI: Integer = 2; // ������� ��������� ������
  gvsAskIfClose: boolean = True;

  { INTERFACE }
  gvsMinimizeToTray: boolean = False; // True = ����������� ���� � ����
  gvsMinimizeOnEscape: boolean = False; // True = ����������� �� ESCAPE
  gvsLanguageFile: string;
  { PASSWORD }

  gvApplicationPath: string = '';
  gvLanguagesPath: string = '';
  gvPluginsPath: string = '';

implementation

end.
