'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:25pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\_ExportDb.V
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\_ExportDb.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



'************************************************************************
'*** Simple tool (C)opyright Dennis Bareis 2003. All rights reserved. ***
'************************************************************************
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
const ForReading                   = 1
const msiOpenDatabaseModeReadOnly  = 0
const msiOpenDatabaseModePatchFile = 32
const msiReadStreamAnsi            = 2
dim SummaryStreamName : SummaryStreamName = chr(5) & "SummaryInformation"
dim oFS         : set oFs        = CreateObject("Scripting.FileSystemObject")
dim oShell      : set oShell     = CreateObject("WScript.Shell")
dim oInstaller  : set oInstaller = CreateObject("WindowsInstaller.Installer")
dim TouchUp     : TouchUp        = true
dim TableCntOk  : TableCntOk     = 0
dim TableCntErr : TableCntErr    = 0
dim MsgBoxTitle : MsgBoxTitle    = "Export of Windows Installer Database"
dim FailedTables: FailedTables   = ""
dim MakeMsiDir  : MakeMsiDir     = oFS.GetParentFoldername(wscript.ScriptFullName)
if  wscript.arguments.count <> 1 then
Error "Expected the name of the Windows Installer database on the command line!"
end if
dim WiFile : WiFile = wscript.arguments(0)
dim ExportDir  : ExportDir = "Exported.IDT\" & oFS.GetFileName(WiFile)
ExportDir = oFS.GetAbsolutePathName(ExportDir)
oShell.run "cmd.exe /c rd /s /q """ & ExportDir & """", 0, true
oShell.run "cmd.exe /c md       """ & ExportDir & """", 0, true
if  ucase(right(WiFile, 4)) <> ".MSP" then
OpenMode = msiOpenDatabaseModeReadOnly
else
OpenMode = msiOpenDatabaseModeReadOnly + msiOpenDatabaseModePatchFile
end if
if  not oFS.FileExists(WiFile) then
Error "The file """ & WiFile & """ doesn't exist!"
end if
set oMsi = oInstaller.OpenDatabase(WiFile, OpenMode)
ExportTable "_SummaryInformation"
ExportTable "_ForceCodepage"
dim oView : set oView = oMSI.OpenView("SELECT `Name` FROM `_Tables`")
oView.Execute
do
set oRec = oView.Fetch
if oRec is Nothing then exit do
ExportTable oRec.StringData(1)
loop
oView.close
ExportOtherStuff()
Cmd = "cmd.exe /c set PPWIZARD_CONSOLEFILE=&set PPWIZARD_ERRORFILE=& "
Cmd = Cmd & """" & MakeMsiDir & "\reg4mm.exe"" """ & MakeMsiDir & "\PpWiz4MM.4MM"" "
Cmd = Cmd & "'/ConsoleFile:" & ExportDir & "\ALL.PpwConsole.TXT' "
Cmd = Cmd & "'/output:"      & ExportDir & "\ALL.MmTable' "
Cmd = Cmd & "'/define:IDT="  & ExportDir & "\*.IDT' "
Cmd = Cmd & "/DeleteOnError:N /Sleep:0,0 "
Cmd = Cmd & "'" & MakeMsiDir & "\IDT2DEFN.P'"
oShell.run Cmd, 1, true
if  TouchUp then
RemoveIbdFileExtensionsOnBinaries()
MoveAllEmptyIdtFiles()
end if
Dim T, Icon
T = "Successfully exported " & TableCntOk & " tables from the database"
if  FailedTables = "" then
T = T & "."
Icon = VbInformation
else
T = T & " (" & TableCntErr & " failed)." & vbCRLF & vbCRLF & "The following tables failed to export: " & FailedTables
Icon = VbCritical
end if
T = T & vbCRLF & vbCRLF
T = T & "The tables were exported to the """ & ExportDir & """ directory."
T = T & "The ""ALL.MmTable"" file contains the MAKEMSI ""TableDefinition"" commands for all exported tables."
MsgBox T, Icon, MsgBoxTitle
'oShell.run "cmd.exe /c start """"  """ & ExportDir & """", 1, false
oShell.run "EXPLORER.EXE /e,/root,""" & ExportDir & """", 1, false
wscript.quit 9

'=========================================================================
sub ExportOtherStuff()
'=========================================================================
ExportBinaries("_Streams")
ExportBinaries("_Storages")
end sub

'=========================================================================
sub RemoveIbdFileExtensionsOnBinaries()
'=========================================================================
'on error resume next
dim oFolderE : set oFolderE = oFS.GetFolder(ExportDir)
dim oFolders : set oFolders = oFolderE.SubFolders
dim oFolder
for each oFolder in oFolders
dim oFile
dim FileCnt : FileCnt = 0
for each oFile in oFolder.files
FileCnt = FileCnt + 1
if  "IBD" = ucase(oFS.GetExtensionName(oFile.path)) then
dim NewName : NewName = left(oFile.path, len(oFile.path)-4)
dim NewExtn : NewExtn = ""
if  instr(left(oFile.name, len(oFile.name)-4), ".") = 0 then
dim Size     : Size = oFile.Size
if  Size > 9999 then
Size = 9999
end if
dim Contents
if  Size = 0 then
Contents = ""
else
dim oStream  : set oStream = oFS.OpenTextFile(oFile.path, ForReading)
Contents = oStream.read(Size)
oStream.close
end if
NewExtn = WorkOutProbableExtension(Contents, "dll")
if  NewExtn <> "" then NewExtn = ".(guess)." & NewExtn
end if
oFile.Move NewName & NewExtn
end if
set oFile = Nothing
next
if  FileCnt = 0 then
oFolder.Delete True
end if
set oFolder = Nothing
next
set oFolder  = Nothing
set oFolderS = Nothing
set oFolderE = Nothing
end sub

'=========================================================================
sub MoveAllEmptyIdtFiles()
'=========================================================================
on error resume next
dim EmptyDir : EmptyDir = ExportDir & "\#EMPTY#.IDT"
dim oFolder  : set oFolder = oFS.GetFolder(ExportDir)
dim oFiles   : set oFiles  = oFolder.Files
dim oFile
for each oFile in oFiles
if  "IDT" = ucase(oFS.GetExtensionName(oFile.path)) then
dim LineCnt  : LineCnt     = 0
dim oStream  : set oStream = oFS.OpenTextFile(oFile.path, ForReading)
dim ItsEmpty : ItsEmpty    = true
do  while oStream.AtEndOfStream <> true
'--- Read the line -------------------------------------------
dim FileLine : FileLine = oStream.ReadLine()
LineCnt = LineCnt + 1
if   LineCnt > 3 then
ItsEmpty = False
exit do
end if
loop
oStream.close
if  ItsEmpty then
if  not oFS.FolderExists(EmptyDir) then
oFS.CreateFolder(EmptyDir)
end if
dim DestFile : DestFile = EmptyDir & "\" & oFile.name
oFile.Move DestFile
end if
end if
set oFile = Nothing
next
end sub

'=========================================================================
sub ExportBinaries(ByVal TableName)
'=========================================================================
on error resume next
dim oView : set oView = oMSI.OpenView("SELECT * FROM `" & TableName & "`")
dim Cnt   : Cnt = 0
dim Dir   : Dir = ExportDir & "\" & TableName
dim Name
oView.Execute
do
set oRec = oView.Fetch
if oRec is Nothing then exit do
dim Bits, TableDir
Name     = oRec.StringData(1)
Bits     = split(Name, ".")      'Bits(0) may be a table name
TableDir = ExportDir & "\" & Bits(0)
if   not oFS.FolderExists(TableDir) and Name <> SummaryStreamName then
Cnt = Cnt + 1
if   Cnt = 1 then
oFS.CreateFolder(Dir)
end if
dim FileSize, FileContents
FileSize     = oRec.DataSize(2)
FileContents = oRec.ReadStream(2, FileSize, msiReadStreamAnsi)
set oRec  = Nothing
dim FileName, Stream
err.clear()
FileName = Dir & "\" & Name & ".ibd"
set Stream = oFS.CreateTextFile(FileName, True)
if err.number <> 0 then
FileName = Dir & "\" & Cnt
set Stream = oFS.CreateTextFile(FileName, True)
end if
Stream.Write FileContents
Stream.close
set Stream = Nothing
end if
loop
oView.close
end sub

'=========================================================================
sub ExportTable(ByVal TableName)
'=========================================================================
on error resume next
oMSI.Export TableName, ExportDir, TableName & ".IDT"
if err.number = 0 then
TableCntOk = TableCntOk + 1
else
TableCntErr = TableCntErr + 1
if FailedTables <> "" then FailedTables = FailedTables & ", "
FailedTables = FailedTables & TableName
end if
end sub
function MsiError(ByVal Doing)
dim Msg, oLast
If  err.number <> 0 then
Msg = Doing & vbCRLF & vbCRLF & err.Source & " 0x" & Hex(err.number) & ": " & err.Description
If  Not oInstaller Is Nothing Then
Set oLast = oInstaller.LastErrorRecord
If  Not oLast Is Nothing Then
Msg = Msg & vbNewLine & oLast.FormatText
end if
end if
Error(Msg)
end if
end function
sub Error(ByVal Text)
dim Title : Title = MsgBoxTitle
Text = Text & vbCRLF & vbCRLF & "Note that this program is now terminating"
MsgBox Text, vbCritical, MsgBoxTitle
ExitRc 999
end sub


'=========================================================================
function WorkOutProbableExtension(ByVal FileContents, MzName)
'=========================================================================
on error resume next
dim StringsVb   : StringsVb   = "CreateObject(, on error resume next, on error goto 0, end if, exit sub, exit function, exit loop"
dim StringsJs   : StringsJs   = "ActivexObject("
dim HeaderL3Ico : HeaderL3Ico = chr(0) & chr(0) & chr(1)
dim HeaderL2Jpg : HeaderL2Jpg = chr(&HFF) & chr(&HD8)
dim Extn : Extn = ""
if  left(FileContents, 4) = "MSCF" then
Extn = "cab"
elseif left(FileContents, 3) = "GIF" then
Extn = "gif"
elseif left(FileContents, 2) = HeaderL2Jpg then
Extn = "jpg"
elseif left(FileContents, 2) = "MZ" then
Extn = MzName
elseif left(FileContents, 2) = "BM" then
Extn = "bmp"
elseif left(FileContents, 2) = "PK" then
Extn = "zip"
elseif left(FileContents, 5) = "%PDF-" then
Extn = "pdf"
elseif left(FileContents, 3) = HeaderL3Ico then
Extn = "ico"
elseif Contains(FileContents, StringsJs) then
Extn = "js"
elseif Contains(FileContents, StringsVb) then
Extn = "vbs"
end if
WorkOutProbableExtension = Extn
end function


'=========================================================================
function Contains(ByVal Contents, ByVal List)
'=========================================================================
dim Items : Items = split(ucase(List), ",")
Contents = ucase(Contents)
dim x
for x = 0 to ubound(Items)
if  instr(Contents, trim(Items(x))) <> 0 then
Contains = true
exit function
end if
next
Contains = false
end function
