'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:14pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\MmLockfile.V
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\MmLockFile.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



Option Explicit
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
dim PgmVersion : PgmVersion = "04.281"
const ForAppending = 8
if  Wscript.Arguments.count <> 1 then
MsgBox "Expected the name of the file to lock...", vbCritical, "EXPECTED ONE ONLY PARAMETER"
wscript.quit 999
end if
dim OFS      : set oFS  = CreateObject("Scripting.FileSystemObject")
dim FileName : FileName = Wscript.Arguments(0)
if  not oFS.FileExists(FileName) then
MsgBox "The file """ & FileName & """ doesn't exist!", vbCritical, "INVALID FILENAME"
wscript.quit 999
end if
dim Stream : set Stream = oFS.OpenTextFile(FileName, ForAppending, True)
MsgBox "The file """ & FileName & """ is now locked." & vbCRLF & vbCRLF & "Click ""OK"" to unlock the file.", vbInformation, "LOCKED!"
Stream.close()
set Stream = Nothing
set oFS    = Nothing
