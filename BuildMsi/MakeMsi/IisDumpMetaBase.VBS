'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:13pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\IisDumpMetaBase.V
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\IisDumpMetaBase.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



Option Explicit
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
dim PgmVersion : PgmVersion = "05.127"
const PI  = "  * "
const PVI = "    => "
'--- Don't allow use via WSCRIPT! -------------------------------------------
if ucase(mid(wscript.FullName, len(wscript.Path) + 2, 1)) = "W" Then
say "You can't use WSCRIPT on this VB script, use CSCRIPT instead!"
wscript.quit 999
end if
say "[]--------------------------------------------[]"
say "| IisDumpMetaBase.VBS v" & PgmVersion & " by Dennis Bareis |"
say "[]--------------------------------------------[]"
say ""
dim RootObject : RootObject = ""
dim DumpTree   : DumpTree   = true
if  wscript.arguments.count > 0 then
RootObject = wscript.arguments(0)
if  wscript.arguments.count > 1 then
say "WARNING: Ignoring all but the first parameter..."
end if
else
RootObject = "IIS:"                     'VB/ADSI bug causes PV?
RootObject = "IIS://LocalHost/MimeMap"  'For testing (I don't know how to dump mimemap arrays yet)
RootObject = "IIS://LocalHost"
end if
if  left(RootObject, 1) = "-" then
RootObject = mid(RootObject, 2)
DumpTree   = false
end if
dim oRoot : set oRoot = GetAdsiObject(RootObject)
DumpAdsiObject oRoot, DumpTree
set oRoot = Nothing
wscript.quit 0


'=============================================
function Say(What)
'=============================================
wscript.echo  What
end function


'=============================================
function GetAdsiObject(ByVal FullAdsiPath)
'=============================================
on error resume next
say  "Getting ADSI Object : " & FullAdsiPath
set GetAdsiObject = GetObject(FullAdsiPath)
if  err.number <> 0 then
say  ""
say  "ERROR"
say  "~~~~~"
say  "Failed loading the IIS object, reason 0x" & hex(err.number) & " - " & err.description
dim oShell : set oShell = CreateObject("WScript.Shell")
err.clear()
dim DisplayName : DisplayName = oShell.RegRead("HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\DisplayName")
if  err.number <> 0 then
say  ""
say "IIS does not appear to have been installed on this local computer..."
end if
set oShell = Nothing
wscript.quit 9876
end if
end function





'=============================================
function DumpAdsiObject(ByVal oADSI, ByVal DumpChildren)
'=============================================
on error resume next
dim Cnt
say ""
say ""
say "====[ START DUMP """ & oADSI.name & """]============================="
oADSI.GetInfo()
say "ADSI properties"
say "~~~~~~~~~~~~~~~"
say PI & "AdsPath = " & oADSI.AdsPath
say PI & "Class   = " & oADSI.class
say PI & "GUID    = " & oADSI.GUID
say PI & "Parent  = " & oADSI.Parent
dim oSchema : set oSchema = GetObject(oADSI.Schema)
DumpSetOfProperties oADSI, oSchema.MandatoryProperties, "Mandatory Properties"
DumpSetOfProperties oADSI, oSchema.OptionalProperties,  "Optional Properties"
dim oContained
Cnt = 0
for each oContained in oADSI
say ""
Cnt = Cnt + 1
if  Cnt = 1 then
dim Suffix
if   DumpChildren then
Suffix = "(see below)"
else
Suffix = "(not being dumped)"
end if
say "Contains Objects " & Suffix
say "~~~~~~~~~~~~~~~~"
end if
dim PISPC : PISPC= replace(PI, "*", " ")
say PI    & "Name    = " & oContained.name
say PISPC & "Class   = " & oContained.class
say PISPC & "AdsPath = " & oContained.AdsPath
say PISPC & "GUID    = " & oContained.GUID
next
on error goto 0
say "====[ END DUMP """ & oADSI.name & """]============================="
say ""
say ""
if   DumpChildren then
for each oContained in oADSI
DumpAdsiObject oContained, DumpChildren
next
end if
end function


'=============================================
sub DumpSetOfProperties(ByVal oADSI, ByVal oPropertyList, ByVal Title)
'=============================================
on error resume next
dim Properties()
dim PropertyCnt  : PropertyCnt  = 0
dim PropertyName : PropertyName = ""
for  each PropertyName in oPropertyList
if  PropertyName = "" then
exit for
end if
redim preserve Properties(PropertyCnt)
Properties(PropertyCnt) = PropertyName
PropertyCnt = PropertyCnt + 1
next
dim i, j, temp
if  PropertyCnt > 1 then
for i = PropertyCnt-1-1 To 0 Step -1
for j = 0 to i
if Properties(j) > Properties(j+1) then
temp            = Properties(j+1)
Properties(j+1) = Properties(j)
Properties(j)   = temp
end if
next
next
end if
for i = 0 to PropertyCnt-1
PropertyName = Properties(i)
if  i = 0 then
Title = PropertyCnt & " " & Title
say ""
say Title
say string(len(Title), "~")
end if
dim PropertyValue : PropertyValue = oADSI.Get(PropertyName)  'The .Get()/.GetEx() can sometimes kill the process - ADSI bug (to see try "IIS:" as root object)?
if  not IsArray(PropertyValue) then
DumpProperty PI, 0, PropertyName, PropertyValue
else
say PI & PropertyName & " (array):"
dim OneStr
dim MemberCnt : MemberCnt = 0
for each OneStr in PropertyValue
MemberCnt = MemberCnt + 1
DumpProperty PVI, MemberCnt, PropertyName, OneStr
next
if   MemberCnt = 0 then
say PVI & "<<EmptyArray>>"
end if
end if
next
end sub


'=============================================
sub DumpProperty(ByVal Indent, ByVal Cnt, ByVal ItsName, ByRef ItsValue)
'=============================================
on error resume next
dim Prefix
if  Cnt = 0 then
Prefix = Indent & ItsName & " = "
else
Prefix = Indent
end if
if  ItsName = "MimeMap" then
dim ObjIndent : ObjIndent = string(len(Indent), " ")
say Indent    & "OBJECT #" & Cnt & " IISMimeType:"
say ObjIndent & "- MimeType =" & ItsValue.MimeType
say ObjIndent & "- Extension=" & ItsValue.Extension
else
err.clear()
say Prefix & ItsValue
if  err.number <> 0 then
say Prefix & "!!! Failed to display value (TYPE = " & typename(ItsValue) & ")"
end if
end if
end sub
