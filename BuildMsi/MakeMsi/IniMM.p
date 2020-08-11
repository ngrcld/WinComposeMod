;----------------------------------------------------------------------------
;
;    MODULE NAME:   IniMM.P
;
;        $Author:   USER "Dennis"  $
;      $Revision:   1.1  $
;          $Date:   02 Aug 2005 17:20:34  $
;       $Logfile:   C:/DBAREIS/Projects.PVCS/Win32/MakeMsi/IniMM.P.pvcs  $
;      COPYRIGHT:   (C)opyright Dennis Bareis, Australia, 2003
;                   All rights reserved.
;
; DESCRIPTION
; ~~~~~~~~~~~
; This file is executed via PPWIZARD and is passed the name of a ".INI" file
; and generates a MAKEMSI type representation.
;
; This process is invoked via an explorer shell extension and will execute
; a command similar to:
;
;    ppwizard IniMM.P /output:out\1.txt '/Define:INIFILE=c:\tmp\1.ini'
;
;----------------------------------------------------------------------------

#define UpdateMmLocation
#define MAKEMSI_NONCA_SCRIPT_DIR <??*TEMP>
#include "FileMake.MMH"
#include "NotMsiFmt.MMH"
#include "ImportTranslations.MMH"
#include "INIIMPORT.MMH"
<$IniImport "<$INIFILE>" IniFile="<$INIFILE $$FilePart:N>" IniDir="INSTALLDIR" ApplyDefinitions="N">
