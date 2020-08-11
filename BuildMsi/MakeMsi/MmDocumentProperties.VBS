'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:14pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\MmDocumentProperties.v
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\MmDocumentProperties.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



Option Explicit
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
dim PgmVersion : PgmVersion = "05.295"
if ucase(mid(wscript.FullName, len(wscript.Path) + 2, 1)) = "W" Then
wscript.echo "You can't use WSCRIPT on this VB script, use CSCRIPT instead!"
ExitRc 999
end if
const ssfDrives          = 17
const DefaultOptTemplate = "{N}: {V} "
const DefaultMax         = 50
dim DisplayedHeader : DisplayedHeader  = false
dim ScriptName      : ScriptName       = wscript.ScriptFullName
dim oApplication    : set oApplication = MkObject("Shell.Application")
dim oFs             : set oFs          = MkObject("Scripting.FileSystemObject")
dim oItem, oFolder
dim DumpMode       : DumpMode     = 1
dim FullFileName   : FullFileName = ""
dim OkRc           : OkRc         = 0
dim ResultText     : ResultText   = ""
dim OriginalText   : OriginalText = ""
dim NewLine        : NewLine      = vbCRLF
dim OptionalNameTemplate : OptionalNameTemplate = DefaultOptTemplate
dim Max                  : Max                  = DefaultMax
dim NonSwitchCnt : NonSwitchCnt = 0
for i = 0 to Wscript.Arguments.Count-1
dim OneArg   : OneArg   = CodesReplaced(Wscript.Arguments(i))
dim OneArgL1 : OneArgL1 = left(OneArg, 1)
if  left(OneArgL1, 1) <> "-" and left(OneArgL1, 1) <> "/" then
NonSwitchCnt = NonSwitchCnt + 1
select case NonSwitchCnt
case 1
if  OneArg = "?" then
OneArg = ScriptName
end if
FullFileName = oFS.GetAbsolutePathName(OneArg)
if  not oFS.FileExists(FullFileName) then
error("The file """ & FullFileName & """ doesn't exist!")
end if
case else
InvalidArguments("The only non-switch parameter should be the filename (did not expect """ & OneArg & """)!")
end select
else
dim Bits, Switch, SwitchParm
OneArg = mid(OneArg, 2)
Bits   = split(OneArg, ":", 2)
Switch = Bits(0)
if  ubound(Bits) <> 1 then
SwitchParm = ""
else
SwitchParm = Bits(1)
end if
select case lcase(Switch)
case lcase("Output")
DumpMode   = 0
ResultText = ExpectNonBlankParm()
ResultText = replace(ResultText, "{CRLF}", vbCRLF)
case lcase("DUMP")
DumpMode = 99
case lcase("DUMP-")
DumpMode = 1
case lcase("Template")
OptionalNameTemplate = ExpectNonBlankParm()
case lcase("Max")
Max = ExpectNonBlankParm()
case lcase("NewLine")
NewLine = ExpectNonBlankParm()
case lcase("OkRc")
OkRc = ExpectNonBlankIntParm()
case else
InvalidArguments("The switch ""/" & Switch & """ is unknown!")
end select
end if
next
if NonSwitchCnt = 0 then
InvalidArguments "Expected at least one non-switch parameter (filename)!"
end if
OriginalText = ResultText
on error resume next
set oItem   = oApplication.Namespace(ssfDrives).ParseName(FullFileName)
set oFolder = oItem.Parent
VbsError("Getting document information for """ & FullFileName & """")
dim ItemValue, ItemNameIE, ItemName, ItemSymbol, ItemSymbolOpt
dim i
dim Queued : Queued = ""
for i = -1 to Max
ItemNameIE    = oFolder.GetDetailsOf(null,  i)
ItemName      = PropertyName(ItemNameIE)
ItemSymbol    = "{" & ItemName & "}"
ItemSymbolOpt = "{" & ItemName & "?}"
ItemValue = oFolder.GetDetailsOf(oItem, i)
ItemValue = replace(ItemValue, vbCRLF, "{CRLF}")
ItemValue = replace(ItemValue, vbCR,   "{CR}")
ItemValue = replace(ItemValue, vbLF,   "{LF}")
if  ucase(ItemName) = ucase(ItemValue) then
ItemValue = ""
end if
if  ucase(ItemName) = "TYPE" then
dim DefaultType : DefaultType = ucase(oFS.GetExtensionName(FullFileName) & " File")
if  ucase(ItemValue) = DefaultType then
ItemValue = ""
end if
end if
dim ItemValueOpt : ItemValueOpt = ItemValue
if  DumpMode = 0 then
if  ItemValue = "" then
ItemValue = "*unknown*"
end if
ResultText = replace(ResultText, ItemSymbol, ItemValue)
if  trim(ItemValueOpt) <> "" then
ItemValueOpt = Replace(OptionalNameTemplate, "{V}", ItemValueOpt)
ItemValueOpt = Replace(ItemValueOpt,         "{N}", ItemName)
end if
ResultText = replace(ResultText, ItemSymbolOpt, ItemValueOpt)
else
dim iLng : iLng = len(cstr(Max))
dim PaddedI : PaddedI = right(string(iLng, " ") & i, iLng)
if  trim(ItemValue) <> "" or DumpMode = 99 then
Queued = Queued & "#" & PaddedI & ". " & ItemSymbol & " = " & ItemValue & NewLine
end if
if  ItemNameIE <> "" or trim(ItemValue) <> "" then
ResultText = ResultText & Queued
Queued     = ""
end if
end if
next
if  ResultText = OriginalText then
error("Resultant text unchanged! Initial & final values:" & vbCRLF & vbCRLF & "  ==> " & ResultText)
end if
say ResultText
ExitRc OkRc
function ExpectNonBlankParm()
ExpectNonBlankParm = SwitchParm
if  ExpectNonBlankParm = "" then
InvalidArguments("Expected a non-blank switch parameter on ""/" & Switch & """!")
end if
end function
function ExpectNonBlankIntParm()
on error resume next
ExpectNonBlankIntParm = cint(SwitchParm)
if  err.number <> 0 then
InvalidArguments("Expected a non-blank integer switch parameter on ""/" & Switch & """!")
end if
end function
function CodesReplaced(Text)
dim i, CodeName, CodeValue
CodesReplaced = Text
for i = 0 to 255
if  i < 16 then
CodeName  = "{x0" & ucase(hex(i)) & "}"
else
CodeName  = "{x"  & ucase(hex(i)) & "}"
end if
CodeValue = chr(i)
CodesReplaced = replace(CodesReplaced, CodeName, CodeValue)
next
CodesReplaced = replace(CodesReplaced, "{CRLF}",  vbCRLF)
CodesReplaced = replace(CodesReplaced, "{TAB}",   vbTAB)
CodesReplaced = replace(CodesReplaced, "{'}",     """")
CodesReplaced = replace(CodesReplaced, "{LT}",    "<")
CodesReplaced = replace(CodesReplaced, "{GT}",    ">")
CodesReplaced = replace(CodesReplaced, "{AMP}",   "&")
CodesReplaced = replace(CodesReplaced, "{PIPE}",  "|")
CodesReplaced = replace(CodesReplaced, "{HAT}",   "^")
end function
function PropertyName(ItemName)
PropertyName = ItemName
if  PropertyName = "" then
if  i = -1 then
PropertyName = "ToolTip"
else
PropertyName = "#" & i
end if
end if
end function
sub say(Text)
wscript.echo Text
end sub
sub DisplayHeader()
if  not DisplayedHeader then
say ""
say "[]--------------------------------------------------------------[]"
say "| MmDocumentProperties.VBS v" & PgmVersion & ": Dumps document properties    |"
say "|           (C)opyright Dennis Bareis 2004. All rights reserved. |"
say "|                 http://dennisbareis.com/index.htm |"
say "[]--------------------------------------------------------------[]"
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
say "cscript.exe //NoLogo [path\]MmDocumentProperties[.VBS] [path\]FileName"
say ""
say "OPTIONS"
say "~~~~~~~"
say "/Output:Value   : Almost always supplied (codes 1. {Name} or 2. {Name?})"
say "/Template:Value : Optional Output template (default """ & DefaultOptTemplate & """)"
say "/Max:Integer    : Max search ID (default """ & DefaultMax & """)"
say "/NewLine:Chars  : When dumping, use what for a newline?"
say "/OkRc:Integer   : Default 0, but WSH can EASILY return this on error!"
say ""
say "If you don't supply a non-blank value on the ""/Output"" switch then"
say "all available properties will be dumped."
say "Not all items have meaning for all file types."
say ""
say "The ""/Output"" value should contain at least one template string"
say "such as ""{Dimensions}"" or ""{Dimensions?}"" (non-blank output)."
say "It may also contain ""{CRLF}"" (newline)."
say ""
say "You capture the output by redirecting the ""stdout"" stream."
say "A non-zero return code indicates a problem."
say ""
say "Note that there are many codes available to make it easier to pass difficult"
say "characters on the command line such as {x00}-{xFF}, {CRLF}, {LT}, {GT}, {AMP},"
say "{TAB}, {PIPE}, {HAT} & {'} (double quote}."
say chr(7) & chr(7)
ExitRc 255
end sub
function MkObject(ByVal AutomationClass)
on error resume next
set MkObject = wscript.CreateObject(AutomationClass)
VbsError "Loading the automation class """ & AutomationClass & """"
end function
sub VbsError(ByVal Doing)
dim Msg, oLast
If  err.number <> 0 then
Msg = Doing & vbCRLF & vbCRLF & err.Source & " 0x" & Hex(err.number) & ": " & err.Description
Error(Msg)
end if
End Sub
sub Error(Text)
say ""
say ""
DisplayHeader()
say ""
say "ERROR"
say "~~~~~"
say Text & chr(7)
ExitRc 999
end sub
sub ExitRc(ReturnCode)
on error resume next
set oFolder      = Nothing
set oItem        = Nothing
set oApplication = Nothing
set oFs          = Nothing
wscript.quit ReturnCode
end sub
