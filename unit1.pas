unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls, Dos, Process;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnBrowse: TButton;
    btnShow: TButton;
    cbxHidden: TCheckBox;
    save_chk: TCheckBox;
    crc2: TCheckBox;
    crc1: TCheckBox;
    crc0: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    edtDirectory: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnShowClick(Sender: TObject);
    procedure crc0Change(Sender: TObject);
    procedure crc1Change(Sender: TObject);
    procedure crc2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;

var
  Form1: TForm1;
  USERDIR: String;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  F: TextFile;
  S: string;
begin
  edtDirectory.Text := ExtractFileDir(ParamStr(0));
  USERDIR := GetUserDir;
  Edit2.Text := USERDIR + 'Desktop';

  if FileExists('maker_cfg.txt') then
   begin
    AssignFile(F, 'maker_cfg.txt');
    Reset(F);
      ReadLn(F, S);

      ReadLn(F, S);
      if S = '1:X' then begin cbxHidden.Checked := True; end else if S = '1:x' then begin cbxHidden.Checked := False; end;
      ReadLn(F, S);
      if S = '2:X' then begin crc0.Checked := True; end else if S = '2:x' then begin crc0.Checked := False; end;
      ReadLn(F, S);
      if S = '3:X' then begin crc1.Checked := True; end else if S = '3:x' then begin crc1.Checked := False; end;
      ReadLn(F, S);
      if S = '4:X' then begin crc2.Checked := True; end else if S = '4:x' then begin crc2.Checked := False; end;
      ReadLn(F, S);
      if S = '5:X' then begin save_chk.Checked := True; end else if S = '5:x' then begin save_chk.Checked := False; end;
      ReadLn(F, S);
      edtDirectory.Text := S;
      ReadLn(F, S);
      Edit1.Text := S;
      ReadLn(F, S);
      Edit2.Text := S;
    CloseFile(F);
   end;
end;

procedure TForm1.btnBrowseClick(Sender: TObject);
begin
  if not(SelectDirectoryDialog1.Execute) then Exit;
  edtDirectory.Text := SelectDirectoryDialog1.FileName;
end;

procedure TForm1.btnShowClick(Sender: TObject);
var
  ListOfFiles   : array of string;
  ListOfFolders : array of string;
  SearchResult  : SearchRec;
  Attribute     : Word;
  Message       : string;
  i             : Integer;

  Process: TProcess;
begin
  Label3.Visible := False;

  SetLength(ListOfFiles, 0);
  SetLength(ListOfFolders, 0);

  // Prepare attribute
  Attribute := archive or readonly;
  if cbxHidden.Checked then
    Attribute := Attribute or hidden;

  // List the files
  FindFirst (edtDirectory.Text+DirectorySeparator+'*.*', Attribute, SearchResult);
  while (DosError = 0) do
  begin
    SetLength(ListOfFiles, Length(ListOfFiles) + 1); // Increase the list
    ListOfFiles[High(ListOfFiles)] := SearchResult.Name; // Add it at the end of the list
    FindNext(SearchResult);
  end;
  FindClose(SearchResult);

  // Show the result
  memo1.Clear ;
  Memo1.Lines.Add(';*** MakeCAB Directive file;');
  Memo1.Lines.Add('.OPTION EXPLICIT');
  Memo1.Lines.Add('.Set CabinetNameTemplate=' + '"' + Edit1.Text + '.cab"');
  Memo1.Lines.Add('.Set DiskDirectoryTemplate=' + '"' + Edit2.Text + '"');
  Memo1.Lines.Add('.Set MaxDiskSize=0');
  Memo1.Lines.Add('.Set Cabinet=on');

 if crc0.Checked = True then begin
  Memo1.Lines.Add('.Set Compress=off');
 end else if crc1.Checked = True then begin
  Memo1.Lines.Add('.Set Compress=on');
  Memo1.Lines.Add('.Set CompressionType=MSzip');
 end else if crc2.Checked = True then begin
  Memo1.Lines.Add('.Set Compress=on');
  Memo1.Lines.Add('.Set CompressionType=LZX');
 end;

  for i := Low(ListOfFiles) to High(ListOfFiles) do begin
    Memo1.Lines.Add('"' + edtDirectory.Text + '\' + ListOfFiles[i] + '" ' + '"' + ListOfFiles[i] + '"');
  end;

  memo1.Lines.SaveToFile('cmd_list\list.txt');

  Process := TProcess.Create(nil);
    try
      Process.Executable := 'cmd_list\dolist.cmd';
      Process.Options := Process.Options + [poWaitOnExit];
      Process.Execute;
    finally
      Process.Free;
    end;
    //ShowMessage('done');
    Label3.Visible := True;
    if save_chk.Checked = True then begin
    memo1.Clear ;
    memo1.Lines.Add('app-info:');
    {hiden}
      if cbxHidden.Checked = True then begin
       memo1.Lines.Add('1:X');
      end else begin
       memo1.Lines.Add('1:x');
      end;
    {none}
      if crc0.Checked = True then begin
       memo1.Lines.Add('2:X');
      end else begin
       memo1.Lines.Add('2:x');
      end;
    {MSzip}
      if crc1.Checked = True then begin
       memo1.Lines.Add('3:X');
      end else begin
       memo1.Lines.Add('3:x');
      end;
    {LZX}
      if crc2.Checked = True then begin
       memo1.Lines.Add('4:X');
      end else begin
       memo1.Lines.Add('4:x');
      end;
    {save_ch}
      if save_chk.Checked = True then begin
       memo1.Lines.Add('5:X');
      end else begin
       memo1.Lines.Add('5:x');
      end;

    memo1.Lines.Add(edtDirectory.Text);
    memo1.Lines.Add(Edit1.Text);
    memo1.Lines.Add(Edit2.Text);
    memo1.Lines.SaveToFile('maker_cfg.txt');
    end;
end;

procedure TForm1.crc0Change(Sender: TObject);
begin
  if crc0.Checked = True then begin
   crc1.Checked := False;
   crc2.Checked := False;
  end;
end;

procedure TForm1.crc1Change(Sender: TObject);
begin
  if crc1.Checked = True then begin
   crc0.Checked := False;
   crc2.Checked := False;
  end;
end;

procedure TForm1.crc2Change(Sender: TObject);
begin
  if crc2.Checked = True then begin
   crc0.Checked := False;
   crc1.Checked := False;
  end;
end;

end.
