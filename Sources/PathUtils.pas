unit PathUtils;

interface

uses
  SysUtils {must be before var PathDelim declaration};

function RelativePathToAbsolute(const ABasePath, APath: String): String;
function AbsolutePathToRelative(const ABasePath, APath: String): String;
function WideRelativePathToAbsolute(const ABasePath, APath: WideString): WideString;
function WideAbsolutePathToRelative(const ABasePath, APath: WideString): WideString;
function GetRoot(const APath: String): String;
function WideGetRoot(const APath: WideString): WideString;

var
  PathDelim: Char;
  CaseSensitive: Boolean;

implementation

type TStringArray = array of String;

procedure ResemblePath(const APath: String; var Parts: TStringArray); overload;
var
  i, j, k: Integer;
  S: String;
begin
  j := 1;
  k := 0;
  Parts := nil;
  for i := 1 to Length(APath) do
    if APath[i] = PathDelim then
    begin
      S := Copy(APath, j, i-j);
      if S <> '' then
      begin
        SetLength(Parts, k+1);
        Parts[k] := S;
        Inc(k);
      end;
      j := i+1;
    end;
  if j <= Length(APath) then
  begin
    SetLength(Parts, k+1);
    Parts[k] := Copy(APath, j, MaxInt);
  end;
end;

function RelativePathToAbsolute(const ABasePath, APath: String): String;
var
  i, j, k: Integer;
  TmpPath, S: String;
  RootLevel: Integer;
  Strs1: TStringArray;
begin
  if (Length(APath) > 1) and ((APath[2] = DriveDelim) or // ��������� ����
    ((APath[1] = PathDelim) and (APath[2] = PathDelim))) then // ��� ������� ����
  begin
    Result := APath; // � ����� ������ ���� �� �������� �������������
    Exit;
  end;
  
  RootLevel := Ord((Length(ABasePath) > 1) and ((ABasePath[2] = DriveDelim) // ��������� ����
    or ((ABasePath[1] = PathDelim) and (ABasePath[2] = PathDelim))))-1; // ��� ������� ����
  // ���� ����� ������ � ������� ������ ��������� ������: ([A..Z]:) ��� (\\server_name).
  // ���� RootLevel = 0, �� ��� ����� ���� ������� � ����� ���������� ������ (\home),
  // ��� ���-�� �������������� (���� ��� ������� �����) - ���� ������ �������� �����
  // ��������� (������� �� �������� � �����)
    
  Result := '';
  ResemblePath(ABasePath, Strs1);

  j := 1;
  k := Length(Strs1)-1;
  if APath[Length(APath)] = PathDelim
    then TmpPath := APath
    else TmpPath := APath + PathDelim;
  for i := 1 to Length(TmpPath) do
    if TmpPath[i] = PathDelim then
    begin
      S := Copy(TmpPath, j, i-j);
      if (S <> '') and (S <> '.') then
      begin
        if S = '..' then
        begin
          Dec(k);
          if k < RootLevel then k := RootLevel; // ���� ����� �� �������� :)
          // ���������� ������ ������ �� �������� ��� ��� ����� ����������?
        end
        else
        begin
          Inc(k);
          if k = Length(Strs1) then
            SetLength(Strs1, k+1);
          Strs1[k] := S;
        end;
      end;
      j := i+1;
    end;
  for i := 0 to k do
    Result := Result + Strs1[i] + PathDelim;

  // ������� �������� ���������
  if (Length(APath) > 0) and (APath[Length(APath)] <> PathDelim) then
    SetLength(Result, Length(Result)-1); // � ����� ��� ����� - �.�. ��� �����
  if (Length(ABasePath) > 0) and (ABasePath[1] = PathDelim) then
    Result := PathDelim + Result; // ���� � ������ - ��������� ����
  if (Length(ABasePath) > 1) and (ABasePath[2] = PathDelim) then
    Result := PathDelim + Result; // ��� ����� � ������ - ������� ����
end;

function GetRoot(const APath: String): String;
var
  i: Integer;
begin
  Result := '';
  if Length(APath) > 0 then
    if APath[1] = PathDelim then
      if (Length(APath) > 1) and (APath[2] = PathDelim) then
      begin
        for i := 3 to Length(APath) do // ������� ����
          if APath[i] = PathDelim then
          begin
            Result := Copy(APath, 3, i-3);
            Break;
          end;
        if Result = '' then Result := Copy(APath, 3, MaxInt);
      end
      else Result := PathDelim // ������ �������� �������
    else if (Length(APath) > 1) and (APath[2] = DriveDelim) then
      Result := APath[1] // ��������� ����
    else
      Result := PathDelim;
end;

function SameString(const S1, S2: String): Boolean; overload;
begin
  if CaseSensitive
    then Result := AnsiCompareText(S1, S2) = 0
    else Result := AnsiCompareStr(S1, S2) = 0;
end;

function AbsolutePathToRelative(const ABasePath, APath: String): String;
var
  Strs1, Strs2: TStringArray;
  i, j, k, l: Integer;
begin
  if (Length(ABasePath) = 0) or (Length(APath) = 0) then
  begin
    Result := APath;  // (*)
    Exit;
  end;

  // ���� �� ������ ������� ����� ��� ������
  if not SameString(GetRoot(ABasePath), GetRoot(APath)) then
  begin
    Result := APath;
    Exit;
  end;

  ResemblePath(ABasePath, Strs1);
  ResemblePath(APath, Strs2);

  Result := '';
  k := Length(Strs1); l := 0;
  for i := 0 to Length(Strs2)-1 do
    if i < k then
    begin
      if not SameString(Strs2[i], Strs1[i]) then
      begin
        for j := i to k-1 do Result := Result + '..' + PathDelim;
        Break;
      end
      else Inc(l);
    end
    else
    begin
      Result := '.' + PathDelim;
      Break;
    end;
  // ���� ������ ��� ����� ��������
  if l >= Length(Strs2) then
    if l = k then Result := Result + '.' + PathDelim
    else
      for i := l to k-1 do Result := Result + '..' + PathDelim
  else
    for i := l to Length(Strs2)-1 do
      Result := Result + Strs2[i] + PathDelim;
  if (Length(APath) > 0) and (APath[Length(APath)] <> PathDelim) then
    SetLength(Result, Length(Result)-1); // � ����� ��� ����� - �.�. ��� �����
end;

//------------------------------------------------------------------------------
// Wide-������

type TWideStringArray = array of WideString;

procedure ResemblePath(const APath: WideString; var Parts: TWideStringArray); overload;
var
  i, j, k: Integer;
  S: WideString;
  PathDelimW: WideChar;
begin
  j := 1;
  k := 0;
  Parts := nil;
  PathDelimW := WideChar(PathDelim);
  for i := 1 to Length(APath) do
    if APath[i] = PathDelimW then
    begin
      S := Copy(APath, j, i-j);
      if S <> '' then
      begin
        SetLength(Parts, k+1);
        Parts[k] := S;
        Inc(k);
      end;
      j := i+1;
    end;
  if j <= Length(APath) then
  begin
    SetLength(Parts, k+1);
    Parts[k] := Copy(APath, j, MaxInt);
  end;
end;

function WideRelativePathToAbsolute(const ABasePath, APath: WideString): WideString;
var
  i, j, k: Integer;
  TmpPath, S: WideString;
  RootLevel: Integer;
  Strs1: TWideStringArray;
  DriveDelimW, PathDelimW: WideChar;
begin
  DriveDelimW := WideChar(DriveDelim);
  PathDelimW := WideChar(PathDelim);
  
  if (Length(APath) > 1) and ((APath[2] = DriveDelimW) or // ��������� ����
    ((APath[1] = PathDelimW) and (APath[2] = PathDelimW))) then // ��� ������� ����
  begin
    Result := APath; // � ����� ������ ���� �� �������� �������������
    Exit;
  end;

  RootLevel := Ord((Length(ABasePath) > 1) and ((ABasePath[2] = DriveDelimW) // ��������� ����
    or ((ABasePath[1] = PathDelimW) and (ABasePath[2] = PathDelimW))))-1; // ��� ������� ����
  // ���� ����� ������ � ������� ������ ��������� ������: ([A..Z]:) ��� (\\server_name).
  // ���� RootLevel = 0, �� ��� ����� ���� ������� � ����� ���������� ������ (\home),
  // ��� ���-�� �������������� (���� ��� ������� �����) - ���� ������ �������� �����
  // ��������� (������� �� �������� � �����)

  Result := '';
  ResemblePath(ABasePath, Strs1);

  j := 1;
  k := Length(Strs1)-1;
  if APath[Length(APath)] = PathDelimW
    then TmpPath := APath
    else TmpPath := APath + PathDelimW;
  for i := 1 to Length(TmpPath) do
    if TmpPath[i] = PathDelimW then
    begin
      S := Copy(TmpPath, j, i-j);
      if (S <> '') and (S <> WideString('.')) then
      begin
        if S = WideString('..') then
        begin
          Dec(k);
          if k < RootLevel then k := RootLevel; // ���� ����� �� �������� :)
          // ���������� ������ ������ �� �������� ��� ��� ����� ����������?
        end
        else
        begin
          Inc(k);
          if k = Length(Strs1) then
            SetLength(Strs1, k+1);
          Strs1[k] := S;
        end;
      end;
      j := i+1;
    end;
  for i := 0 to k do
    Result := Result + Strs1[i] + PathDelimW;

  // ������� �������� ���������
  if (Length(APath) > 0) and (APath[Length(APath)] <> PathDelimW) then
    SetLength(Result, Length(Result)-1); // � ����� ��� ����� - �.�. ��� �����
  if (Length(ABasePath) > 0) and (ABasePath[1] = PathDelimW) then
    Result := PathDelimW + Result; // ���� � ������ - ��������� ����
  if (Length(ABasePath) > 1) and (ABasePath[2] = PathDelimW) then
    Result := PathDelimW + Result; // ��� ����� � ������ - ������� ����
end;

function WideGetRoot(const APath: WideString): WideString;
var
  i: Integer;
  PathDelimW: WideChar;
begin
  PathDelimW := WideChar(PathDelim);
  Result := '';
  if Length(APath) > 0 then
    if APath[1] = PathDelimW then
      if (Length(APath) > 1) and (APath[2] = PathDelimW) then
      begin
        for i := 3 to Length(APath) do // ������� ����
          if APath[i] = PathDelimW then
          begin
            Result := Copy(APath, 3, i-3);
            Break;
          end;
        if Result = '' then Result := Copy(APath, 3, MaxInt);
      end
      else Result := PathDelim // ������ �������� �������
    else if (Length(APath) > 1) and (APath[2] = WideChar(DriveDelim)) then
      Result := APath[1] // ��������� ����
    else
      Result := PathDelimW;
end;

function SameString(const S1, S2: WideString): Boolean; overload;
begin
  if CaseSensitive
    then Result := WideCompareText(S1, S2) = 0
    else Result := WideCompareStr(S1, S2) = 0;
end;

function WideAbsolutePathToRelative(const ABasePath, APath: WideString): WideString;
var
  Strs1, Strs2: TStringArray;
  i, j, k, l: Integer;
  PathDelimW: WideChar;
begin
  PathDelimW := WideChar(PathDelim);

  if (Length(ABasePath) = 0) or (Length(APath) = 0) then
  begin
    Result := APath;
    Exit;
  end;

  // ���� �� ������ ������� ����� ��� ������
  if not SameString(WideGetRoot(ABasePath), WideGetRoot(APath)) then
  begin
    Result := APath;
    Exit;
  end;

  ResemblePath(ABasePath, Strs1);
  ResemblePath(APath, Strs2);

  Result := '';
  k := Length(Strs1); l := 0;
  for i := 0 to Length(Strs2)-1 do
    if i < k then
    begin
      if not SameString(Strs2[i], Strs1[i]) then
      begin
        for j := i to k-1 do Result := Result + '..' + PathDelimW;
        Break;
      end
      else Inc(l);
    end
    else
    begin
      Result := WideString('.') + PathDelimW;
      Break;
    end;
  // ���� ������ ��� ����� ��������
  if l >= Length(Strs2) then
    if l = k then Result := Result + '.' + PathDelimW
    else
      for i := l to k-1 do Result := Result + '..' + PathDelimW
  else
    for i := l to Length(Strs2)-1 do
      Result := Result + Strs2[i] + PathDelimW;
  if (Length(APath) > 0) and (APath[Length(APath)] <> PathDelimW) then
    SetLength(Result, Length(Result)-1); // � ����� ��� ����� - �.�. ��� �����
end;

initialization
  PathDelim := SysUtils.PathDelim;
{$if defined(MSWINDOWS) or defined(WINDOWS)}
  CaseSensitive := False;
{$else}
    CaseSensitive := True;
{$ifend}
end.
