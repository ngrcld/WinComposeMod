'----------------------------------------------------------------------------
'     MODULE NAME:   ShouldBeEmpty.vbs
'
'         $Author:   USER "Dennis"  $
'       $Revision:   1.1  $
'           $Date:   02 Aug 2017 17:15:30  $
'        $Logfile:   D:/DBAREIS/Projects.PVCS/Win32/MakeMsi/ShouldBeEmpty.vbs.pvcs  $
'
'     DESCRIPTION:   Helper to check nothing generated into the "should be empty" file.
'----------------------------------------------------------------------------

'--- Don't allow use via WSCRIPT! -------------------------------------------
if ucase(mid(wscript.FullName, len(wscript.Path) + 2, 1)) = "W" Then
    wscript.echo "You can't use WSCRIPT on this VB script, use CSCRIPT instead!"
    wscript.quit 999
end if

'--- Init -------------------------------------------------------------------
const MsOsBugWorkaround = 219
dim PgmVersion : PgmVersion = "17.08.02b"


'--- Read the input (file), look for unexpected text ------------------------
dim LeftOver : LeftOver = ""
do  while wscript.stdin.AtEndOfStream <> true
   '--- Read the line -------------------------------------------------------
   Line = wscript.stdin.ReadLine()

   '--- Is the line "blank"? ------------------------------------------------
   Line = replace(Line, vbCR,   " ")
   Line = replace(Line, vbLF,   " ")
   Line = replace(Line, vbTAB,  " ")
   Line = trim(Line)

   '--- Get rid of any duplicated spaces ------------------------------------
   dim After : After = Line
   do
        Line = After
        After = replace(Line, "  ",  " ")
   loop while Line <> After

   '--- Add to unexpected Text? ---------------------------------------------
   if   len(Line) <> 0 then
        LeftOver = LeftOver & Line & vbCRLF
   end if
loop

'--- Check Results ----------------------------------------------------------
if  len(LeftOver) = 0 then
    wscript.quit(MsOsBugWorkaround)
else
    dim Line : Line = string(25, "-")
    dim H : H = ""
        H = H & "[]------------------------------------------------[]"           & vbCRLF
        H = H & "| ShouldBeEmpty.vbs v" & PgmVersion & ": MAKEMSI HELPER VBS |"  & vbCRLF
        H = H & "[]------------------------------------------------[]"           & vbCRLF
        H = H                                                                    & vbCRLF
        H = H & "Some data was found in the file which is expected to be empty!" & vbCRLF
        H = H                                                                    & vbCRLF
        H = H & "This means that some sort of mistake was made, typically this will be text"           & vbCRLF
        H = H & "that you have accidently entered or perhaps you didn't invoke a MAKEMSI command"      & vbCRLF
        H = H & "correctly (e.g. you used ""<shortcut ..."" instead of ""<$shortcut ..."")."           & vbCRLF
        H = H                                                                                          & vbCRLF
        H = H & "Anyway knowing the text (below) you should be able to determine the source of"        & vbCRLF
        H = H & "the issue(s)!"                                                                        & vbCRLF
        H = H                                                                                          & vbCRLF
        H = H & Line & "[ UNEXPECTED TEXT - START ]" & Line & vbCRLF


    dim T : T = Line & "[ UNEXPECTED TEXT - END ]" & Line & vbCRLF

    wscript.stdout.write(H & LeftOver & T)
    wscript.quit(666)
end if


