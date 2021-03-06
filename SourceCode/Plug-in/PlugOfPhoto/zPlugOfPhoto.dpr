library zPlugOfPhoto;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Windows,
  Classes,
  grobal2 in '..\..\Common\grobal2.pas',
  EngineType in '..\..\Common\EngineType.pas',
  EngineAPI in '..\..\Common\EngineAPI.pas',
  HUtil32 in '..\..\Common\HUtil32.pas',
  DllMain in 'DllMain.pas',
  MD5Unit in '..\..\Common\MD5Unit.pas';

{$R *.res}
const
  PlugName = '用户照片管理插件 (2009/08/27)';
  LoadPlus = '加载用户照片管理插件成功...';
  InitPlus = '正在初始化用户照片管理插件...';
  InitPlusOK = '初始化用户照片管理插件成功...';
  UnLoadPlus = '卸载用户照片管理插件成功...';
  LoadPlusFail = '加载用户照片插件失败...';
type
  TMsgProc = procedure(Msg: PChar; nMsgLen: Integer; nMode: Integer); stdcall;
  TFindProc = function(sProcName: PChar; nNameLen: Integer): Pointer; stdcall;
  TFindObj = function(sObjName: PChar; nNameLen: Integer): TObject; stdcall;
  TSetProc = function(ProcAddr: Pointer; ProcName: PChar; nNameLen: Integer): Boolean; stdcall;

var
  OutMessage: TMsgProc;
  boLoad: Boolean;

function Load(AppHandle: HWnd; MsgProc: TMsgProc; FindProc: TFindProc; SetProc:
  TSetProc; FindOBj: TFindObj; LoadMode: Integer): PChar; stdcall;
begin
  OutMessage := MsgProc;
  boLoad := False;
  if API_GetGrobalVer() = GROBAL2VER then begin
    MsgProc(LoadPlus, length(LoadPlus), LoadMode);
    boLoad := True;
    LoadPlug();
  end else begin
    OutMessage(LoadPlusFail, length(LoadPlusFail), 1);
  end;
  Result := PlugName;
end;

procedure UnLoad(boExit: Boolean); stdcall;
begin
  if boLoad then begin
    UnLoadPlug(boExit);
    OutMessage(UnLoadPlus, length(UnLoadPlus), 1);
  end;
end;

function UnModule(ModuleHookType: Integer; OldPointer, NewPointer: Pointer): Boolean; stdcall;
begin
  Result := False;
  if boLoad then begin
    case ModuleHookType of
      MODULE_USERLOGINSTART: begin
        if @OLDUSERLOGINEND = OldPointer then begin
          OLDUSERLOGINEND := NewPointer;
          Result := True;
        end;
      end;
      MODULE_PLAYOPERATEMESSAGE: begin
        if @OLDPLAYOBJECTOPERATEMESSAGE = OldPointer then begin
          OLDPLAYOBJECTOPERATEMESSAGE := NewPointer;
          Result := True;
        end;
      end;
      MODULE_USERLOADANDSAVE: begin
        if @OLDUSERLOADANDSAVE = OldPointer then begin
          OLDUSERLOADANDSAVE := NewPointer;
          Result := True;
        end;
      end;
    end;
  end;
end;
{
procedure Init(LoadMode: Integer); stdcall;
begin
  OutMessage(InitPlus, length(InitPlus), LoadMode);
  //InitPlug();
  OutMessage(InitPlusOK, length(InitPlusOK), LoadMode);
end;

procedure Config(); stdcall;
begin
  //
end;   }

exports
  Load, UnLoad, UnModule{, Config, Init};
begin
end.
