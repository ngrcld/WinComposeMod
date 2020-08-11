'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:21pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\DelOlderRE.V
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\DelOlderRE.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+

'
'    MODULE NAME:   DELOLDERRE.V
'
'        $Author:   USER "Dennis"  $
'      $Revision:   1.1  $
'          $Date:   03 Mar 2015 17:39:20  $
'       $Logfile:   C:/DBAREIS/Projects.PVCS/Win32/MakeMsi/DelOlderRE.V.pvcs  $
'
'    DESCRIPTION:   Free up disk space by removing files based
'                   on age and creation date. For example, if log files
'                   are only needed for 30 days then this script can
'                   delete files equal to or older than a specified age
'                   in days.
'                   If age spec is -1, then can be used to delete all files.
'                   Can be used with a schedule service to run each night.
Option Explicit
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
dim PgmVersion : PgmVersion = "15.062a"
dim TotalSize  : TotalSize  = clng(0)
dim MatchCount : MatchCount = 0
dim OldCount   : OldCount   = 0
dim EmptyCount : EmptyCount = 0
Dim oFs, objLogFile, strLogFileName, TheDate
Const ForReading = 1, ForWriting = 2, ForAppending = 8
Set oFs = CreateObject("Scripting.FileSystemObject")
dim PgmInfo : PgmInfo = "DELOLDER.VBS v" & PgmVersion
if ucase(mid(wscript.FullName, len(wscript.Path) + 2, 1)) = "W" Then
Say "You can't use WSCRIPT on " & PgmInfo & ", use CSCRIPT instead!"
wscript.quit 999
end if
Say "[]-------------------------------------------------------------[]"
Say "| DELOLDERRE.VBS v" & PgmVersion & ": Deletes files older than a given age |"
Say "[]-------------------------------------------------------------[]"
Say ""
dim MsiCnt : MsiCnt = 0
dim i
dim OptionOnlyListFiles      : OptionOnlyListFiles      = False
dim OptionDoSubdirectories   : OptionDoSubdirectories   = False
dim OptionDeleteEmptyFolders : OptionDeleteEmptyFolders = False
dim OptionDateDiffType       : OptionDateDiffType       = "d"
dim OptionDateDiffDesc       : OptionDateDiffDesc       = "days"
dim NsIndex                  : NsIndex                  = 0
dim BaseDir  : BaseDir  = ""
dim BaseMask : BaseMask = ""
dim Age      : Age      = ""
dim ThisArg, ThisArg1
for i = 0 to Wscript.Arguments.Count-1
ThisArg  = Wscript.Arguments(i)
ThisArg1 = left(ThisArg, 2)
select case ucase(ThisArg)
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case "-H", "/H"
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OptionDateDiffType = "h"
OptionDateDiffDesc = "hours"
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case "-L", "/L"
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OptionOnlyListFiles = True
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case "-S", "/S"
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OptionDoSubdirectories = True
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case "-K", "/K"
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OptionDeleteEmptyFolders = True
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case else
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NsIndex = NsIndex + 1
select case NsIndex
case 1
BaseDir  = ThisArg
if BaseDir = "" then InvalidArguments "Directory can't be empty (use ""."" for current."
case 2
BaseMask = ThisArg
case 3
Age = ThisArg
case else
InvalidArguments "TOO MANY NON SWITCH ARGUMENTS OR UNKNOWN SWITCH" & vbCRLF & "PARAMETER VALUE: " & ThisArg
end select
end select
next
if Age = "" then
InvalidArguments "You didn't supply enough arguments!"
end if
dim oRE
if BaseMask = ""    then BaseMask = "*.*"
if BaseMask = "*"   then BaseMask = "*.*"
if BaseMask = "*.*" then BaseMask = ".*"
set oRE         = new RegExp
oRE.Pattern     = BaseMask
oRE.IgnoreCase  = true
dim Action, DirTree
if OptionOnlyListFiles = True then
Action = "Listing"
else
Action = "Deleting"
end if
if OptionDoSubdirectories = True then
DirTree = "directory tree"
else
DirTree = "directory"
end if
Say Action & " files older than " & Age & " " & OptionDateDiffDesc & " in " & DirTree & " """ & BaseDir & """" & vbCRLF & "where they match the regular expression """ & BaseMask & """"
Say ""
if  not oFS.FolderExists(BaseDir) then
say "The folder doesn't exist (nothing to cleanup)..."
else
TheDate = Date & " " & Time
TidyFolder BaseDir, Age
if OldCount <> 0 or EmptyCount <> 0 then say ""
dim What
if OldCount = MatchCount then
What = "all " & AddComma2Long(OldCount)
else
What = AddComma2Long(OldCount) & " files out of the " &  AddComma2Long(MatchCount)
end if
TotalSize = TotalSize / clng(1024*1024)         'Now in MB
say "Processed " & What & " files matching the mask (" & AddComma2Long(TotalSize) & " MB)"
end if
Wscript.Quit 0
'============================================================================
Sub TidyFilesInOneDirectory (Dir2Tidy, intMaxFileAge)
'============================================================================
Dim oFolder           ' Folder object containing the file
Dim oFiles            ' Collection of files in folder object
Dim oFile               ' File object in the folder
Dim intFileAge          ' Age of the file in days
Dim strBaseName          ' Base name portion of file name
Dim strExtName          ' Extension name portion of file name
Dim strCurBaseName          ' Current file object base name
Dim strCurExtName          ' Current file object extension name
'
On Error Resume Next
'
' Parse the parent folder, file base, and extension names.
' Use the parent folder to create a collection of the files
' contained in the parent folder.
'
''''strBaseName   = UCase(oFs.GetBaseName(strFileToTidy))
''''strExtName    = UCase(oFs.GetExtensionName(strFileToTidy))
Set oFolder = oFs.GetFolder(Dir2Tidy)
Set oFiles  = oFolder.Files ' collection of files
'
' In Loop:
'
'     Process each file in the parent folder and test to see
'     if there is a name and age match.
'
For Each oFile In oFiles
'strCurBaseName = UCase(oFs.GetBaseName(oFile.Path))
'     strCurExtName = UCase(oFs.GetExtensionName(oFile.Path))
'     If (strBaseName = "*" and strExtName = "*") _
'      or (strBaseName = "*" and strCurExtName = strExtName) _
'      or (strCurBaseName = strBaseName and strExtName = "*") _
'      or (strCurBaseName = strBaseName and strCurExtName = strExtName) Then
if  oRE.test(oFile.Name) then
'
MatchCount = MatchCount + 1
intFileAge = DateDiff(OptionDateDiffType, oFile.DateLastModified, TheDate)
'Say "compare: '" & intFileAge & "' => '" & intMaxFileAge & "'"
If cint(intFileAge) > cint(intMaxFileAge) Then
'           time to Del
'Say strParentPath & "\" & oFile.Name & " size=" & oFile.size & " Created=" & oFile.DateCreated & " Deleted=" & Date & " " & Time
TotalSize = TotalSize + clng(oFile.size)
OldCount = OldCount + 1
if OptionOnlyListFiles = False then
Say "   - " & oFile.Path
oFile.Delete
else
Say "   * " & oFile.Path
end if
End If
End If
Next
if  OptionDeleteEmptyFolders then
dim HaveItems : HaveItems = False
For each oFile In oFolder.SubFolders
HaveItems = true
exit for
next
For each oFile In oFolder.Files
HaveItems = true
exit for
next
if  not HaveItems then
if  OptionOnlyListFiles = False then
EmptyCount = EmptyCount + 1
say "   - " & oFolder.Path & "\ (empty folder)"
oFolder.delete
end if
end if
end if
End Sub
'============================================================================
Sub TidyFolder(ByVal Dir2Tidy, ByVal intMaxFileAge)
'============================================================================
Dim oFolder          ' Folder object containing the file
Dim MoreFolders          ' Collection of sub-folders in folder
Dim SubFolder          ' Sub-folder object in folder
Dim strFileName          ' File base and extension name
if OptionDoSubdirectories then
' Look for subfolders
'
Set oFolder   = oFs.GetFolder(Dir2Tidy)
Set MoreFolders = oFolder.SubFolders
'
' In Loop:
'
' Process all subfolders.
'
For Each SubFolder In MoreFolders
TidyFolder SubFolder.Path, intMaxFileAge
Next
end if
TidyFilesInOneDirectory Dir2Tidy, intMaxFileAge
End Sub
'============================================================================
function AddComma2Long(ByVal TheInteger)
'============================================================================
on error resume next
AddComma2Long = TheInteger              'Cover all fallback is to return original value
'AddComma2Long = FormatNumber(clng(TheInteger), 0, True, False, True)
AddComma2Long = FormatNumber(cdbl(TheInteger), 0, True, False, True)
end function
'============================================================================
sub InvalidArguments(ErrorMessage)
'============================================================================
Say "Invalid arguments"
Say "~~~~~~~~~~~~~~~~~"
Say "    " & ErrorMessage
Say ""
Say ""
Say "CORRECT SYNTAX"
Say "~~~~~~~~~~~~~~"
Say "    " & "DelOlderRE[.VBS]  Directory FileMaskAsRegularExpression AgeInDays"
Say "                      [-S] [-K] [-L]"
Say ""
Say "    SEE: http://makemsi-manual.dennisbareis.com/regular_expression.htm"
Say "    TIP: Use ""-L"" to test any expression first!!!!"
Say ""
Say ""
Say "EXAMPLE ("".*"" means any characters) dot escaped as ""\."")"
Say "~~~~~~~~"
Say "     cscript .\DelOlderRE.vbs ""c:\tmp"" "".*\.txt"" 2 -S -K"
Say "     cscript.exe //NoLogo  .\DelOlderRE.vbs ""."" ""system.*\.log"" 2"
Say ""
Say ""
Say "OPTIONS"
Say "~~~~~~~"
Say "    " & "-S : Process whole directory tree (not just single folder)"
Say "    " & "-K : KILL (delete) empty subdirectories"
Say "    " & "-H : Maximum age specified in hours and not days"
Say "    " & "-L : List (don't delete) matching files"
Say chr(7) & chr(7)
Wscript.Quit 255
end sub
'============================================================================
Sub Say(TheLine)
'============================================================================
Wscript.Echo TheLine
end sub
