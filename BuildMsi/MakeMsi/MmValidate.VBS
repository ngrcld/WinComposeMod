'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:27pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\MmValidate.V
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\MmValidate.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



'************************************************************************
'*** Simple tool (C)opyright Dennis Bareis 2004. All rights reserved. ***
'************************************************************************
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
dim IsCscript
if ucase(mid(wscript.FullName, len(wscript.Path) + 2, 1)) = "C" Then
IsCscript = true
else
IsCscript = false
end if
DisplayHeader()
sayC "Initializing..."
dim oShell      : set oShell  = MkObject("WScript.Shell")
dim oFS         : set oFs     = MkObject("Scripting.FileSystemObject")
dim MakemsiDir  : MakemsiDir = GetEnv("MAKEMSI_DIR", "")
if  right(MakemsiDir, 1) = "\" then
MakemsiDir = left(MakemsiDir, len(MakemsiDir)-1)
end if
dim UnicodeHdr  : UnicodeHdr = MakemsiDir & "\FFFE.HEX"
const ForReading   = 1
const ForWriting   = 2
dim ValidateThis   : ValidateThis   = ""
dim ValidateWith   : ValidateWith   = ""
dim OutputFile     : OutputFile     = ""
dim FilterFile     : FilterFile     = GetEnv("MMVALIDATE_FILTER", MakemsiDir & "\MmValidate.FLT")
dim ErrorsInMsgBox : ErrorsInMsgBox = false
dim i, OneArg, OneArgL1
for i = 0 to Wscript.Arguments.Count-1
OneArg  = Wscript.Arguments(i)
OneArgL1 = left(OneArg, 1)
if  OneArgL1 = "-" or OneArgL1 = "/" then
dim ParmPos : ParmPos = instr(OneArg, ":")
dim Switch, Parameter
if  ParmPos = 0 then
Switch    = mid(OneArg, 2)
Parameter = ""
else
Switch    = mid(OneArg, 2, ParmPos-2)
Parameter = mid(OneArg, ParmPos+1)
end if
select case lcase(Switch)
case lcase("Output")
OutputFile = Parameter
Parameter  = ""
case lcase("ICE")
ValidateWith = Parameter
Parameter    = ""
case lcase("ErrorsInMsgBox")
ErrorsInMsgBox = true
case else
InvalidArguments "The switch ""/" & Switch & """ is unknown!"
end select
else
ValidateThis = OneArg
end if
next
dim MsiVal2Dir :         MsiVal2Dir = GetEnv("MMVALIDATE_MSIVAL2_DIR", "")
if  MsiVal2Dir = "" then MsiVal2Dir = GetEnv("MAKEMSI_MSIVAL2_DIR",    "C:\Program Files\MSIVAL2")
if  right(MsiVal2Dir, 1) = "\" then
MsiVal2Dir = left(MsiVal2Dir, len(MsiVal2Dir)-1)
end if
if  not oFS.FolderExists(MsiVal2Dir) then
error("The platform SDK program ""MSIVAL2"" doesn't appear to be installed (in """ & MsiVal2Dir & """).")
end if
dim MsiVal2Exe : MsiVal2Exe = MsiVal2Dir & "\MsiVal2.EXE"
if  not oFS.FileExists(MsiVal2Exe) then
error("Couldn't find ""MsiVal2.EXE"" in the existing directory """ & MsiVal2Dir & """.")
end if
if  ValidateThis = "" then
Error "Expected at least the name of a MSI/MSM to be validated."
end if
if  not oFS.FileExists(ValidateThis) then
error "Could not find the file to be validated (""" & ValidateThis & """)!"
end if
ValidateThis = oFS.GetAbsolutePathName(ValidateThis)
if  ValidateWith = "" then
ValidateWith = GetEnv("MMVALIDATE_CUB", "")
if  ValidateWith = "" then ValidateWith = GetEnv("MAKEMSI_CUB", "darice.cub")
end if
if  instr(ValidateWith, "\") = 0 then
ValidateWith = MsiVal2Dir & "\" & ValidateWith
end if
if  not oFS.FileExists(ValidateWith) then
Error "Could not find the validation suite """ & ValidateWith & """!"
end if
if  OutputFile = "" then
OutputFile = ".\Validate.IT\" & oFs.GetBaseName(ValidateThis) & ".txt"
end if
MakeFilesDirectory OutputFile
if  not oFS.FileExists(FilterFile) then
Error "The filter file """ & FilterFile & """ doesn't exist!"
end if
if  not IsCscript then
dim Title    : Title    = "FILTER VALIDATION MESSAGES?"
dim Question : Question = "Do you wish to filter the validaton result?"
Question = Question & vbCRLF & vbCRLF & "Filtering is used so that you won't see messages "
Question = Question & "that you have previously determined have no harmful effect! "
Question = Question & "You can modify the default with the ""MMVALIDATE_FILTER"" environment variable."
Question = Question & vbCRLF & vbCRLF & "The defined filter is """ & FilterFile & """."
'dim Yn : Yn = MsgBox(Question, vbYesNo+vbQuestion+vbDefaultButton1+vbSystemModal, Title)
'if Yn <> vbCancel then
'    ;--- Use the template or ask user? --------------------------------------
'    if  Yn = vbNo then
'        FilterFile = ""
'    end if
'end if
end if
sayC "Running the validation program..."
sayC "  * Checking: " & ValidateThis
sayC "  *    With : " & ValidateWith
if  FilterFile <> "" then
sayC "  *  Filter : " & FilterFile
end if
dim RedirFile : RedirFile = GetEnv("TEMP", "") & "\MSIVAL2R.TMP"
DeleteFile(RedirFile)
DeleteFile(OutputFile)
dim Cmd, CmdRc
Cmd =       """" & MsiVal2Exe   & """ "
Cmd = Cmd & """" & ValidateThis & """ "
Cmd = Cmd & """" & ValidateWith & """ "
Cmd = Cmd & "-f "
Cmd = Cmd & "-l "
Cmd = Cmd & """" & OutputFile & """ "
Cmd = Cmd & ">""" & RedirFile & """ 2>&1"
CmdRc = oShell.run("%comspec% /c """ & Cmd & """", 0, true)
if  not oFS.FileExists(OutputFile) then
Error "The validation command failed to produce any output and returned" & vbCRLF & _
"a return code of " & CmdRc & ". It generated this output:" & vbCRLF & vbCRLF & _
ReadFile(RedirFile)
end if
sayC "Converting to ASCII..."
dim TmpFile   : TmpFile   = GetEnv("TEMP", "") & "\WithHdr.TMP"
dim AsciiFile : AsciiFile = GetEnv("TEMP", "") & "\Ascii.TMP"
DeleteFile(AsciiFile)
Cmd = "copy /b """ & UnicodeHdr & """+""" & OutputFile & """ """ & TmpFile & """"
CmdRc = oShell.run("%comspec% /c """ & Cmd & """", 0, true)
Cmd = "type """ & TmpFile & """ 2>&1 >  """ & AsciiFile & """"
CmdRc = oShell.run("%comspec% /c """ & Cmd & """", 0, true)
if  FilterFile <> "" then
sayC "Filtering the results..."
dim FilteredFile : FilteredFile = GetEnv("TEMP", "") & "\FilteredOutput.TMP"
dim FindMult     : FindMult     = MakemsiDir & "\FindMult.VBS"
DeleteFile(FilteredFile)
Cmd = "cscript.exe //NoLogo """ & FindMult & """ ""@" & FilterFile & """ < """ & AsciiFile & """ 2>&1 > """ & FilteredFile & """"
CmdRc = oShell.run("%comspec% /c """ & Cmd & """", 0, true)
end if
dim Stream : set Stream = oFS.CreateTextFile(OutputFile, true)
Stream.writeline StarLine("")
Stream.writeline StarLine("*** VALIDATED DATABASE DETAILS ***")
Stream.writeline StarLine("")
Stream.writeline ""
Stream.writeline "Validating : " & ValidateThis
Stream.writeline "             " & GetFileDetails(ValidateThis)
Stream.writeline "With CUB   : " & ValidateWith
Stream.writeline "             " & GetFileDetails(ValidateWith)
if  FilterFile = "" then
Stream.writeline "With Filter: NONE"
else
Stream.writeline "With Filter: " & FilterFile
Stream.writeline "             " & GetFileDetails(FilterFile)
end if
Stream.writeline ""
Stream.writeline ""
Stream.writeline ""
if  FilterFile <> "" then
Stream.writeline StarLine("")
Stream.writeline StarLine("*** FILTERED OUTPUT ***")
Stream.writeline StarLine("")
Stream.writeline ""
Stream.writeline ReadFile(FilteredFile)
end if
Stream.writeline ""
Stream.writeline ""
Stream.writeline ""
Stream.writeline StarLine("")
Stream.writeline StarLine("*** UNFILTERED OUTPUT ***")
Stream.writeline StarLine("")
Stream.writeline ""
Stream.writeline ReadFile(AsciiFile)
Stream.writeline ""
Stream.writeline StarLine("")
Stream.writeline StarLine("*** FINISHED ***")
Stream.writeline StarLine("")
Stream.close()
Cmd = "start notepad.exe """ & OutputFile & """"
CmdRc = oShell.run("%comspec% /c """ & Cmd & """", 0, true)
wscript.quit 99




function GetEnv(EnvVar, Default)
on error goto 0
GetEnv = ""
dim Try : Try = "%" & EnvVar & "%"
on error resume next
GetEnv = oShell.ExpandEnvironmentStrings(Try)
on error goto 0
if  GetEnv = Try then
GetEnv = Default
end if
end function

function AddComma2Long(ByVal TheInteger)
AddComma2Long = FormatNumber(TheInteger, 0, True, False, True)
end function

sub say(Text)
wscript.echo Text
end sub

sub sayC(Text)
if  IsCscript then
Say Text
end if
end sub

function StarLine(Text)
dim TextLen : TextLen = len(Text)
if  TextLen >= 160 then
StarLine = Text
else
StarLine = Text & string(160-TextLen, "*")
end if
end function

function ReadFile(FileName)
on error resume next        'Q&D to handle 0 length file - stupid VB...
dim ReadStream : set ReadStream = oFS.OpenTextFile(FileName, ForReading)
ReadFile = ReadStream.readall()
ReadStream.Close()
if  err.number <> 0 then
ReadFile = ""
end if
end function

sub DeleteFile(FileName)
if  oFS.FileExists(FileName) then
on error resume next
oFs.DeleteFile(FileName)
if  err.number <> 0 then
error "Could not delete """ & FileName & """, reason 0x" & hex(err.number) & " - " & err.description
end if
end if
end sub

sub Error(ByVal Text)
if   IsCscript and not ErrorsInMsgBox then
Say Text
else
MsgBox Text, vbCritical, "MmValidate.VBS version 05.231"
end if
wscript.quit 888
end sub

function GetFileDetails(FileName)
dim oFile : set oFile = oFS.GetFile(FileName)
dim FileTime : FileTime = FormatDateTime(oFile.DateLastModified, vbLongDate) & ", " & FormatDateTime(oFile.DateLastModified, vbLongTime)
dim FileSize : FileSize = AddComma2Long(oFile.size)
set oFile = Nothing
dim oInstaller : set oInstaller = MkObject("WindowsInstaller.Installer")
dim oRecHash   : set oRecHash   = oInstaller.FileHash(FileName, 0)
dim FileMd5    : FileMD5 = PrettyHash(oRecHash)
set oRecHash   = Nothing
GetFileDetails = "Size " & FileSize & ", dated " & FileTime & ", MD5 = " & FileMD5
end function

sub VbsError(ByVal Doing)
dim Msg
If  err.number <> 0 then
Msg = Doing & vbCRLF & vbCRLF & err.Source & " 0x" & Hex(err.number) & ": " & err.Description
Error(Msg)
end if
End Sub

function MkObject(ByVal AutomationClass)
on error resume next
set MkObject = wscript.CreateObject(AutomationClass)
VbsError "Loading the automation class """ & AutomationClass & """"
end function

sub MakeFilesDirectory(ByVal FileName)
on error resume next
oFS.CreateFolder oFs.GetParentFolderName( oFS.GetAbsolutePathName(FileName) )
end sub
sub DisplayHeader()
if  not DisplayedHeader and IsCscript then
say "[]----------------------------------------------------[]"
say "| MMVALIDATE.VBS v05.231: Validates MSI/MSM files      |"
say "| (C)opyright Dennis Bareis 2003. All rights reserved. |"
say "|         http://dennisbareis.com/index.htm          |"
say "[]----------------------------------------------------[]"
say ""
DisplayedHeader = true
end if
end sub

sub InvalidArguments(ErrorMessage)
DisplayHeader()
say "Invalid arguments"
say "~~~~~~~~~~~~~~~~~"
say ErrorMessage
say ""
say "CORRECT SYNTAX"
say "~~~~~~~~~~~~~~"
say "cscript.exe [path\]MsiDiff[.VBS]  [MsiBefore]  Msi  [Options]"
say ""
say "OPTIONS"
say "~~~~~~~"
say "/Output:file    : Name of the output file (validation results)."
say "/ErrorsInMsgBox : If under cscript, display fatal error in dialog!"
ExitRc 255
end sub

'=========================================================================
function PrettyHash(ByVal UglyHash)
'=========================================================================
PrettyHash = Hex8(UglyHash.IntegerData(1)) & "-" & Hex8(UglyHash.IntegerData(2)) & "-" & Hex8(UglyHash.IntegerData(3)) & "-" & Hex8(UglyHash.IntegerData(4))
end function

'=========================================================================
function Hex8(Value)
'=========================================================================
Hex8 = hex(Value)
Hex8 = right(string(8, "0") & Hex8, 8)
Hex8 = mid(Hex8,7,2) & mid(Hex8,5,2) & mid(Hex8,3,2) & mid(Hex8,1,2)
end function
