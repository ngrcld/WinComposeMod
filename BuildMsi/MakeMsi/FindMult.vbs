'----------------------------------------------------------------------------
'     MODULE NAME:   FindMult.VBS
'
'         $Author:   USER "Dennis"  $
'       $Revision:   1.5  $
'           $Date:   06 Aug 2017 08:29:20  $
'        $Logfile:   D:/DBAREIS/Projects.PVCS/Win32/MakeMsi/FindMult.vbs.pvcs  $
'
'     DESCRIPTION:   A better "FIND"
'----------------------------------------------------------------------------

'--- Don't allow use via WSCRIPT! -------------------------------------------
if ucase(mid(wscript.FullName, len(wscript.Path) + 2, 1)) = "W" Then
    wscript.echo "You can't use WSCRIPT on this VB script, use CSCRIPT instead!"
    wscript.quit 999
end if

'--- Init -------------------------------------------------------------------
public PgmVersion : PgmVersion = "17.212"
set oShell   = WScript.CreateObject("WScript.Shell")
set oFs      = CreateObject("Scripting.FileSystemObject")
public const ForReading = 1
dim RuleType(500), Rule(500)
dim RuleCnt: RuleCnt = 0
dim HaveRemoveRules: HaveRemoveRules = false
dim HaveAddRules:    HaveAddRules    = false
dim HaveCatchRule:   HaveCatchRule   = false    'Rule which says what to do with "other" lines

'--- Load OK list of strings ------------------------------------------------
if Wscript.Arguments.Count = 0 then
   InvalidArguments("No parameters passed")
end if
for i = 0 to Wscript.Arguments.Count-1
    '--- Get argument -------------------------------------------------------
    RememberRule(Wscript.Arguments(i))
next

'--- Add a "catch rest" rule if required ------------------------------------
if not HaveCatchRule then
   '--- Need to create a rule -----------------------------------------------
   if  HaveAddRules and HaveRemoveRules then
       InvalidArguments("You must create a ""+*"" or a ""-*"" rule at the end.")
   end if
   if  HaveAddRules then
       RememberRule("-*")           'User only had "+" rules
   else
       RememberRule("+*")           'User only had "-" rules
   end if
end if


'--- Work through stdin passing through lines if allowed --------------------
ExitRc = 0
set TmpSteam = wscript.stdin
do  while TmpSteam.AtEndOfStream <> true
   '--- Read the line -------------------------------------------------------
   Line = TmpSteam.ReadLine

   '--- Output the line if that is what is wanted ---------------------------
   if  WantLine(Line) then
       say Line
       ExitRc = 1
   end if
loop
wscript.quit(ExitRc)



'============================================================================
function WantLine(Line)
'============================================================================
   '--- Pass the line through each rule until one found that matches --------
   for RI = 0 to RuleCnt-1
       '--- Is this rule a regular expression? ------------------------------
       'if  TypeName(Rule(RI)) = "RegExp" then                           '2008-08-13 - Have seen "IRegExp2" also!
       if  instr(ucase(TypeName(Rule(RI))), ucase("RegExp")) <> 0 then   'Assume all regular expression objects contain "RegExp"!
           '--- Its a regular expression ------------------------------------
           Match = Rule(RI).test(Line)
       else
           '--- Its just a string -------------------------------------------
           RuleText = Rule(RI)
           Match = false
           if  RuleText = "*" then
               Match = true
           else
               '--- Blank Rule matches on blank lines -----------------------
               if  RuleText = "" then
                   if  trim(Line) = "" then
                       Match = true
                   end if
               else
                   '--- Only "in string" rules allowed at this time ---------
                   if  instr(1, Line, RuleText, 1) <> 0 then
                       Match = true
                   end if
               end if
           end if
       end if

       '--- A Match? --------------------------------------------------------
       if  Match then
           '--- Return whether or not the line is wanted --------------------
           if  RuleType(RI) = "-" then
               WantLine = false            '- rule
           else
               WantLine = true             '+ rule
           end if

           '--- Record the rule that matched --------------------------------
           Say2StdErr RuleType(RI) & "," & RI+1 & "," & trim(Line)

           '--- Found it ----------------------------------------------------
           exit function
       end if
   next

   '--- Should never get here -----------------------------------------------
   Die("Bug in WantLine(), no rule found on a line")
end function


'============================================================================
sub RememberRule(OneRule)
'============================================================================

   '--- Must start with either a "+", "-" or "@" ----------------------------
   Left1 = left(OneRule, 1)
   Rest  = mid(OneRule,  2)
   select case Left1
       '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       case "+"
       '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           HaveAddRules = true
       '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       case "-"
       '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           HaveRemoveRules = true
       '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       case "@"
       '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           '--- Make sure the file exists -----------------------------------
           if  not oFS.FileExists(Rest) then
               Die("The file of """ & Rest & """ does not exist")
           end if

           '--- Load the file -----------------------------------------------
           set TmpStream = oFS.OpenTextFile(Rest, ForReading)
           do  while TmpStream.AtEndOfStream <> true
               '--- Read the line -------------------------------------------
               FileLine = trim( TmpStream.ReadLine )
               Left1    = left(FileLine, 1)

               '--- Is this a comment or blank line? ------------------------
               dim LineArg
               if  FileLine <> "" and Left1 <> ";" then
                   '--- Split up --------------------------------------------
                   LineArg = split(FileLine, Left1)

                   '--- Ignore first and last (blank), but add rules --------
                   for FI = 1 to ubound(LineArg)-1
                       RememberRule( LineArg(FI) )
                   next
               end if
           loop
           TmpStream.close

           '--- return to caller --------------------------------------------
           exit sub
       '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       case else
       '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           InvalidArguments("Invalid Rule of """ & OneRule & """")
   end select

   '--- Have "+" or "-" rule ------------------------------------------------
   RuleType(RuleCnt) = left(OneRule, 1)
   OneRule           = mid(OneRule,  2)

   '--- Is the rule a regular expression or a simple string rule? -----------
   if  ucase(left(OneRule, 3)) <> "RE:" then
       '--- A string --------------------------------------------------------
       Rule(RuleCnt) = OneRule
   else
       '--- "RE:" or "re:" means case sensitive ("Re:" is case insensitive) -
       dim oRE
       on error resume next
       set oRE = new RegExp
       if err.number <> 0 then
          '--- Windows stuffed? ----------------------------------------------------
          Die("Could not create a regular expression (""new RegExp""), windows clagged? VBSCRIPT.DLL probably needs registering (IE6+upgrade recently?)...")
       end if
       on error goto 0

       '--- Set Pattern being looked for ------------------------------------
       oRE.Pattern = mid(OneRule, 4)

       '--- Care about case? ------------------------------------------------
       oRE.IgnoreCase = (left(OneRule, 3) = "Re:")
       set Rule(RuleCnt) = oRE
   end if
   RuleCnt = RuleCnt + 1

   '--- Was this a catch rest rule? -----------------------------------------
   if  Rest = "*" then
       HaveCatchRule = true
   end if
end sub



'============================================================================
sub Say(Text)
'============================================================================
   wscript.echo Text
end sub

'============================================================================
sub Say2StdErr(Text)
'============================================================================
   wscript.stderr.writeline Text
end sub


'============================================================================
sub Die(Text)
'============================================================================
   say "ERROR"
   say "~~~~~"
   say Text & chr(7)
   wscript.quit 219
end sub


'============================================================================
sub InvalidArguments(ErrorMessage)
'============================================================================
   Say "[]------------------------------------------------------[]"
   Say "| FINDMULT.VBS v" & PgmVersion & ": Filters STDIN (multiple filters) |"
   Say "[]------------------------------------------------------[]"
   Say ""
   Say "This program filters text input from stdin (piped or redirected)."
   Say "Due to a windows bug you must specifically run via CSCRIPT and not let it"
   Say "default to using CSCRIPT (which forces you to specify path - thanks MS!)!"
   Say "You can specify as many rules for inclusion (+) or exclusion (+) as you wish."
   Say ""
   Say "There are 2 types of rules the first is a simple rule, ""*"" matches all"
   Say "and anything else matches if it exists in a stdin line (case sensitive match)."
   Say "The second type is a regular expression, this is indicated by beginning"
   Say "the string with ""RE:"" (in any case) - if the case was ""Re:"" then the"
   Say "regular expression is case insensitive."
   Say "Rule order is important as the first match is applied."
   Say ""
   Say "Blank lines or those starting with "";"" in the rule file(s) are ignored, all"
   Say "others specify one or more rules (per line), the first character is used as a"
   Say "delimiter, for example ""/+rule 1/"" or ""!-rule 1!+Rule 2 !""."
   Say ""
   Say "Invalid arguments"
   Say "~~~~~~~~~~~~~~~~~"
   Say ErrorMessage
   Say ""
   Say "CORRECT SYNTAX"
   Say "~~~~~~~~~~~~~~"
   Say "CSCRIPT FullPath\FINDMULT[.VBS] [+Rule | -Rule | @RuleFile] ... < filex"
   Wscript.Quit 255
end sub
