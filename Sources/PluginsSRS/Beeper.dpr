library Beeper;

uses
  Windows,
  SharedTypes in '..\SharedTypes.pas',
  BeeperPluginSettings in 'BeeperPluginSettings.pas' { BeeperSettingsForm } ,
  GV in 'GV.pas';

function DoAction: Cardinal; stdcall;
begin
  Result := 1;
  MessageBeep(BeeperType);
  Sleep(450);
  MessageBeep(BeeperType);
  Sleep(450);
  MessageBeep(BeeperType);
  Sleep(190);
  MessageBeep(BeeperType);
  Sleep(190);
  MessageBeep(BeeperType);
  Sleep(450);
  MessageBeep(BeeperType);
  Sleep(260);
  MessageBeep(BeeperType);
  Sleep(260);
  MessageBeep(BeeperType);
  Sleep(260);
  MessageBeep(BeeperType);
  Sleep(550);
  MessageBeep(BeeperType);
  Sleep(180);
  MessageBeep(BeeperType);
end;

function GetPluginInfo(): TPluginInfo; stdcall;
begin
  Result.Name := '���';
  Result.Author := '������ ������ [Azizoff]';
  Result.Description := PWideChar('�������� ������' + #13 + #10 +
      '������ ������� � ����� ��������.' + #13 + #10 +
      '������ ��� - ��� - ��� - �� - ��� - ��� - �� - ��� - ��� - ��� - ���');
  Result.HasSettings := True;
  Result.Version := SetVersion(0, 0, 2, 1);
end;

function ShowSettings(): Cardinal; stdcall;
begin
  BeeperSettingsForm := TBeeperSettingsForm.Create(nil);
  Result := BeeperSettingsForm.ShowModal;
  BeeperSettingsForm.Free;
end;

exports DoAction name 'DoAction', GetPluginInfo name 'GetPluginInfo',
  ShowSettings name 'ShowSettings';

begin

end.
