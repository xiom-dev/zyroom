{*******************************************************************************
zyRoom project for Ryzom Summer Coding Contest 2009
Copyright (C) 2009 Misugi
http://zyroom.misulud.fr
contact@misulud.fr

Developed with Delphi 7 Personal,
this application is designed for players to view guild rooms and search items.

zyRoom is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

zyRoom is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with zyRoom.  If not, see http://www.gnu.org/licenses.
*******************************************************************************}
unit UnitConfig;

interface

uses
  Classes, IniFiles, SysUtils, LbCipher, LbClass, LbString, XpDOM, Graphics;

resourcestring
  RS_ERROR_GUILD_ALREADY_EXISTS = 'La guilde existe d�j�';
  RS_ERROR_GUILD_NOTFOUND = 'La guilde est introuvable';
  RS_ERROR_KEY_NOTFOUND = 'La cl� API est introuvable';
  RS_ERROR_NAME_NOTFOUND = 'Le nom de la guilde est introuvable';
  
const
  _ENCRYPTION_KEY : TKey64 = (10, 158, 47, 92, 35, 221, 29, 203);
  _CONFIG_FILENAME = 'config.ini';
  _GUILD_DIR = 'guild';
  _ROOM_DIR = 'room';
  _PACK_FILEPATH = '\save\string_client.pack';
  _LANGUAGE_FILENAME = 'languages.lcf';
  _LANGUAGE_FRENCH_ID = 1036;
  _LANGUAGE_GERMAN_ID = 1031;
  _LANGUAGE_ENGLISH_ID = 2057;
  
  _SECTION_GENERAL = 'GENERAL';
  _SECTION_PROXY = 'PROXY';
  _KEY_LANGUAGE = 'Language';
  _KEY_PACKFILE = 'PackFile';
  _KEY_PROXY_ENABLED = 'Enabled';
  _KEY_PROXY_BASIC_AUTH = 'BasicAuth';
  _KEY_PROXY_ADDRESS = 'Address';
  _KEY_PROXY_PORT = 'Port';
  _KEY_PROXY_USER = 'Username';
  _KEY_PROXY_PASSWORD = 'Password';
  _KEY_INTERFACE_COLOR = 'Color';

  _GUILD_FILENAME = 'guild.ini';
  _KEY_GUILD_KEY = 'Key';
  _KEY_GUILD_NAME = 'Name';

  _RES_LOGO = 'logo';
  _RES_CLOSED = 'closed';
  _RES_OPEN = 'open';
  _RES_RESTRICTED = 'restricted';
  _RES_NOICON = 'noicon';

  _MAX_GRID_LINES = 10;
  _VERT_SCROLLBAR_WIDTH = 16;
  _ICON_FILENAME = 'icon.png';
  _INFO_FILENAME = 'info.xml';
  _CATA_ITEM_NAME = 'ixpca01.sitem';
  _MIN_QUALITY = 0;
  _MAX_QUALITY = 270;

type
  // List of the guilds
  TGuild = class(TObject)
  private
    FIniFile: TIniFile;
  public
    constructor Create;
    destructor Destroy; override;

    function  GetGuildKey(AGuildID: String): String;
    function  GetGuildName(AGuildID: String): String;
    function  GuildExists(AGuildID: String): Boolean;
    procedure AddGuild(AGuildID, AGuildKey, AGuildName: String);
    procedure UpdateGuild(AGuildID, AGuildKey, AGuildName: String);
    procedure DeleteGuild(AGuildID: String);
    procedure GuildList(AGuildIDList: TStrings);
  end;

  // Settings of the application
  TConfig = class(TObject)
  private
    FIniFile: TIniFile;
    FCurrentDir: String;
    FCurrentPath: String;
    FConfigFileName: String;
    FLanguageFileName: String;
    
    function GetLanguage: Integer;
    function GetPackFile: String;
    function GetProxyAddress: String;
    function GetProxyEnabled: Boolean;
    function GetProxyPassword: String;
    function GetProxyPort: Integer;
    function GetProxyUsername: String;
    function GetProxyBasicAuth: Boolean;
    function GetInterfaceColor: TColor;
    procedure SetLanguage(const Value: Integer);
    procedure SetPackFile(const Value: String);
    procedure SetProxyAddress(const Value: String);
    procedure SetProxyEnabled(const Value: Boolean);
    procedure SetProxyPassword(Value: String);
    procedure SetProxyPort(Value: Integer);
    procedure SetProxyUsername(const Value: String);
    procedure SetProxyBasicAuth(const Value: Boolean);
    procedure SetInterfaceColor(const Value: TColor);
  public
    constructor Create;
    destructor Destroy; override;

    property CurrentDir: String read FCurrentDir;
    property CurrentPath: String read FCurrentPath;
    property ConfigFileName: String read FConfigFileName;
    property LanguageFileName: String read FLanguageFileName;

    property Language: Integer read GetLanguage write SetLanguage;
    property PackFile: String read GetPackFile write SetPackFile;
    property InterfaceColor: TColor read GetInterfaceColor write SetInterfaceColor;
    property ProxyEnabled: Boolean read GetProxyEnabled write SetProxyEnabled;
    property ProxyBasicAuth: Boolean read GetProxyBasicAuth write SetProxyBasicAuth;
    property ProxyAddress: String read GetProxyAddress write SetProxyAddress;
    property ProxyPort: Integer read GetProxyPort write SetProxyPort;
    property ProxyUsername: String read GetProxyUsername write SetProxyUsername;
    property ProxyPassword: String read GetProxyPassword write SetProxyPassword;

    function GetGuildPath(AGuildID: String): String;
    function GetRoomPath(AGuildID: String): String;
  end;


var
  GConfig: TConfig;
  GGuild: TGuild;

implementation

uses RyzomApi;

{ TConfig }

{*******************************************************************************
Creates settings object
*******************************************************************************}
constructor TConfig.Create;
begin
  inherited;
  FCurrentDir := ExtractFileDir(ParamStr(0));
  FCurrentPath := ExtractFilePath(ParamStr(0));
  FConfigFileName := FCurrentPath + _CONFIG_FILENAME;
  FLanguageFileName := FCurrentPath + _LANGUAGE_FILENAME;;
  FIniFile := TIniFile.Create(FConfigFileName);
end;

{*******************************************************************************
Destroys settings object
*******************************************************************************}
destructor TConfig.Destroy;
begin
  FIniFile.Free;
  inherited;
end;

{*******************************************************************************
Returns the path of a guild directory
*******************************************************************************}
function TConfig.GetGuildPath(AGuildID: String): String;
begin
  Result := Format('%s%s\%s\', [FCurrentPath, _GUILD_DIR, AGuildID]);
end;

{*******************************************************************************
Returns the path of a room directory
*******************************************************************************}
function TConfig.GetRoomPath(AGuildID: String): String;
begin
  Result := Format('%s%s\%s\%s\', [FCurrentPath, _GUILD_DIR, AGuildID, _ROOM_DIR]);
end;

{*******************************************************************************
Returns the color of the interface
*******************************************************************************}
function TConfig.GetInterfaceColor: TColor;
begin
  Result := FIniFile.ReadInteger(_SECTION_GENERAL, _KEY_INTERFACE_COLOR, $00C0BFB4);
end;

{*******************************************************************************
Returns the language code
*******************************************************************************}
function TConfig.GetLanguage: Integer;
begin
  Result := FIniFile.ReadInteger(_SECTION_GENERAL, _KEY_LANGUAGE, 2057);
end;

{*******************************************************************************
Returns the resource file
*******************************************************************************}
function TConfig.GetPackFile: String;
var
  wRyzomDir: String;
begin
  Result := FIniFile.ReadString(_SECTION_GENERAL, _KEY_PACKFILE, '');
  if Result = '' then begin
    wRyzomDir := GetRyzomInstallDir;
    if wRyzomDir <> '' then Result := wRyzomDir + _PACK_FILEPATH;
  end;
end;

{*******************************************************************************
Returns the proxy address
*******************************************************************************}
function TConfig.GetProxyAddress: String;
begin
  Result := FIniFile.ReadString(_SECTION_PROXY, _KEY_PROXY_ADDRESS, '127.0.0.1');
end;

{*******************************************************************************
Returns the proxy authentication type (Basic/Digest)
*******************************************************************************}
function TConfig.GetProxyBasicAuth: Boolean;
begin
  Result := FIniFile.ReadBool(_SECTION_PROXY, _KEY_PROXY_BASIC_AUTH, False);
end;

{*******************************************************************************
Returns the proxy status (enabled/disabled)
*******************************************************************************}
function TConfig.GetProxyEnabled: Boolean;
begin
  Result := FIniFile.ReadBool(_SECTION_PROXY, _KEY_PROXY_ENABLED, False);
end;

{*******************************************************************************
Returns the proxy status
*******************************************************************************}
function TConfig.GetProxyPassword: String;
begin
  Result := FIniFile.ReadString(_SECTION_PROXY, _KEY_PROXY_PASSWORD, '');
  if Result <> '' then begin
    Result := DESEncryptStringEx(Result, _ENCRYPTION_KEY, False);
  end;
end;

{*******************************************************************************
Returns the proxy port
*******************************************************************************}
function TConfig.GetProxyPort: Integer;
begin
  Result := FIniFile.ReadInteger(_SECTION_PROXY, _KEY_PROXY_PORT, 3128);
end;

{*******************************************************************************
Returns the proxy username
*******************************************************************************}
function TConfig.GetProxyUsername: String;
begin
  Result := FIniFile.ReadString(_SECTION_PROXY, _KEY_PROXY_USER, '');
end;

{*******************************************************************************
Changes the color interface
*******************************************************************************}
procedure TConfig.SetInterfaceColor(const Value: TColor);
begin
  FIniFile.WriteInteger(_SECTION_GENERAL, _KEY_INTERFACE_COLOR, Value);
end;

{*******************************************************************************
Changes the language code
*******************************************************************************}
procedure TConfig.SetLanguage(const Value: Integer);
begin
  FIniFile.WriteInteger(_SECTION_GENERAL, _KEY_LANGUAGE, Value);
end;

{*******************************************************************************
Changes the resource file
*******************************************************************************}
procedure TConfig.SetPackFile(const Value: String);
begin
  FIniFile.WriteString(_SECTION_GENERAL, _KEY_PACKFILE, Value);
end;

{*******************************************************************************
Changes the proxy address
*******************************************************************************}
procedure TConfig.SetProxyAddress(const Value: String);
begin
  FIniFile.WriteString(_SECTION_PROXY, _KEY_PROXY_ADDRESS, Value);
end;

{*******************************************************************************
Changes the proxy authentication type (Basic/Digest)
*******************************************************************************}
procedure TConfig.SetProxyBasicAuth(const Value: Boolean);
begin
  FIniFile.WriteBool(_SECTION_PROXY, _KEY_PROXY_BASIC_AUTH, Value);
end;

{*******************************************************************************
Changes the proxy status (enabled/disabled)
*******************************************************************************}
procedure TConfig.SetProxyEnabled(const Value: Boolean);
begin
  FIniFile.WriteBool(_SECTION_PROXY, _KEY_PROXY_ENABLED, Value);
end;

{*******************************************************************************
Changes the proxy password
*******************************************************************************}
procedure TConfig.SetProxyPassword(Value: String);
begin
  Value := DESEncryptStringEx(Value, _ENCRYPTION_KEY, True);
  FIniFile.WriteString(_SECTION_PROXY, _KEY_PROXY_PASSWORD, Value);
end;

{*******************************************************************************
Changes the proxy port
*******************************************************************************}
procedure TConfig.SetProxyPort(Value: Integer);
begin
  if Value <= 0 then Value := 3128;
  FIniFile.WriteInteger(_SECTION_PROXY, _KEY_PROXY_PORT, Value);
end;

{*******************************************************************************
Changes the proxy username
*******************************************************************************}
procedure TConfig.SetProxyUsername(const Value: String);
begin
  FIniFile.WriteString(_SECTION_PROXY, _KEY_PROXY_USER, Value);
end;

{ TGuild }

{*******************************************************************************
Creates guild object
*******************************************************************************}
constructor TGuild.Create;
begin
  inherited;
  FIniFile := TIniFile.Create(GConfig.CurrentPath + _GUILD_FILENAME);
end;

{*******************************************************************************
Destroys guild object
*******************************************************************************}
destructor TGuild.Destroy;
begin
  FIniFile.Free;
  inherited;
end;

{*******************************************************************************
Adds a guild
*******************************************************************************}
procedure TGuild.AddGuild(AGuildID, AGuildKey, AGuildName: String);
var
  wKey: String;
begin
  if FIniFile.SectionExists(AGuildID) then
    raise Exception.Create(RS_ERROR_GUILD_ALREADY_EXISTS);
  wKey := DESEncryptStringEx(AGuildKey, _ENCRYPTION_KEY, True);
  FIniFile.WriteString(AGuildID, _KEY_GUILD_KEY, wKey);
  FIniFile.WriteString(AGuildID, _KEY_GUILD_NAME, AGuildName);
end;

{*******************************************************************************
Updates a guild
*******************************************************************************}
procedure TGuild.UpdateGuild(AGuildID, AGuildKey, AGuildName: String);
var
  wKey: String;
begin
  if not FIniFile.SectionExists(AGuildID) then
    raise Exception.Create(RS_ERROR_GUILD_NOTFOUND);
  wKey := DESEncryptStringEx(AGuildKey, _ENCRYPTION_KEY, True);
  FIniFile.WriteString(AGuildID, _KEY_GUILD_KEY, wKey);
  FIniFile.WriteString(AGuildID, _KEY_GUILD_NAME, AGuildName);
end;

{*******************************************************************************
Deletes a guild
*******************************************************************************}
procedure TGuild.DeleteGuild(AGuildID: String);
begin
  FIniFile.EraseSection(AGuildID);
end;

{*******************************************************************************
Returns the guild key from an ID number
*******************************************************************************}
function TGuild.GetGuildKey(AGuildID: String): String;
var
  wKey: String;
begin
  wKey := FIniFile.ReadString(AGuildID, _KEY_GUILD_KEY, '');
  if wKey = '' then
    raise Exception.Create(RS_ERROR_KEY_NOTFOUND);
  Result := DESEncryptStringEx(wKey, _ENCRYPTION_KEY, False);
end;

{*******************************************************************************
Returns the guild name from an ID number
*******************************************************************************}
function TGuild.GetGuildName(AGuildID: String): String;
begin
  Result := FIniFile.ReadString(AGuildID, _KEY_GUILD_NAME, '');
  if Result = '' then
    raise Exception.Create(RS_ERROR_NAME_NOTFOUND);
end;

{*******************************************************************************
Verifies if a guild exists
*******************************************************************************}
function TGuild.GuildExists(AGuildID: String): Boolean;
begin
  Result := FIniFile.SectionExists(AGuildID);
end;

{*******************************************************************************
Returns the list of the guilds
*******************************************************************************}
procedure TGuild.GuildList(AGuildIDList: TStrings);
begin
  AGuildIDList.Clear;
  FIniFile.ReadSections(AGuildIDList);
end;

end.
