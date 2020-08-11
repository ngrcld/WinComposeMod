;----------------------------------------------------------------------------
;
;    MODULE NAME:   RE4MM.P
;
;        $Author:   USER "Dennis"  $
;      $Revision:   1.2  $
;          $Date:   16 Jul 2007 17:43:28  $
;       $Logfile:   C:/DBAREIS/Projects.PVCS/Win32/MakeMsi/RE4MM.P.pvcs  $
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
#define MAKEMSI_NONCA_SCRIPT_DIR <??*TEMP>
#include "FileMake.MMH"
#include "ImportTranslations.MMH"
#include "REGISTRY.MMH"
#include "DEBUG.MMH"
#include "REGIMPORT.MMH"
<$RegistryImport "<$RE4>" CURRENT_USER="" LOCAL_MACHINE="" CLASSES_ROOT="" ApplyDefinitions="N">
