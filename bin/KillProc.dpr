library KillProc;

{ Wichtiger Hinweis zur DLL-Speicherverwaltung: ShareMem muss sich in der
  ersten Unit der unit-Klausel der Bibliothek und des Projekts befinden (Projekt-
  Quelltext anzeigen), falls die DLL Prozeduren oder Funktionen exportiert, die
  Strings als Parameter oder Funktionsergebnisse �bergeben. Das gilt f�r alle
  Strings, die von oder an die DLL �bergeben werden -- sogar f�r diejenigen, die
  sich in Records und Klassen befinden. Sharemem ist die Schnittstellen-Unit zur
  Verwaltungs-DLL f�r gemeinsame Speicherzugriffe, BORLNDMM.DLL.
  Um die Verwendung von BORLNDMM.DLL zu vermeiden, k�nnen Sie String-
  Informationen als PChar- oder ShortString-Parameter �bergeben. }


uses
  SysUtils,
  Windows,
  Unit_ProcTools in 'Unit_ProcTools.pas',
  Unit_NSIS in 'Unit_NSIS.pas';

{$R *.res}

var
  proc_killed: Integer;
  proc_faild: Integer;

procedure DoKillProcesses(ProcName:String; KillThem:Boolean);
var
  ProcList: TPIDList;
  i: Integer;
  s: String;
begin
  if (GetProcessList(ProcList) <> ERROR_SUCCESS) or (Length(ProcList) < 1) then begin
    proc_faild := -1;
    Exit;
  end;

  for i := 0 to Length(ProcList)-1 do
    if (GetProcessName(ProcList[i],s) = ERROR_SUCCESS) and (AnsiLowerCase(s) = ProcName) then
      if KillThem then begin
        if KillProcess(ProcList[i]) then inc(proc_killed) else inc(proc_faild);
      end else begin
        inc(proc_killed);
      end;  
end;

procedure KillProcesses(KillThem:Boolean);
begin
  proc_killed := 0;
  proc_faild := 0;

  DoKillProcesses(AnsiLowerCase(GetUserVariable(INST_0)),KillThem);

  SetUserVariable(INST_0, IntToStr(proc_killed));
  SetUserVariable(INST_1, IntToStr(proc_faild));
end;

procedure ex_dll(const hwndParent: HWND; const string_size: integer; const variables: PChar; const stacktop: pointer); cdecl;
begin
  Init(hwndParent, string_size, variables, stacktop);
  KillProcesses(true);
end;

procedure ex_dll2(const hwndParent: HWND; const string_size: integer; const variables: PChar; const stacktop: pointer); cdecl;
begin
  Init(hwndParent, string_size, variables, stacktop);
  KillProcesses(false);
end;

exports ex_dll name 'KillProcesses';
exports ex_dll2 name 'FindProcesses';

begin
end.

