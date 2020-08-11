;----------------------------------------------------------------------------
;
;    MODULE NAME:   IDT2DEFN.P
;
;        $Author:   USER "Dennis"  $
;      $Revision:   1.0  $
;          $Date:   15 May 2004 17:17:46  $
;       $Logfile:   C:/DBAREIS/Projects.PVCS/Win32/MakeMsi/IDT2DEFN.P.pvcs  $
;      COPYRIGHT:   (C)opyright Dennis Bareis, Australia, 2003
;                   All rights reserved.
;
; DESCRIPTION
; ~~~~~~~~~~~
; This file is executed via PPWIZARD and is passed the name of a ".REG" file
; in "regedit 4" format and generates a MAKEMSI type representation.
;
; This process is invoked via an explorer shell extension and will execute
; a command similar to:
;
;    ppwizard RE4MM.P /output:out\1.txt '/Define:RE4=c:\tmp\1.reg'
;
;----------------------------------------------------------------------------

#define UpdateMmLocation
#include "TableDef.MMH"
<$TableDefinitionIDT "<$IDT>" ApplyDefinitions="N">
