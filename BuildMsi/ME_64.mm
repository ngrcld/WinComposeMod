#define COMPANY_SUMMARY_TEMPLATE x64;0
#define COMPANY_PACKAGE_REQUIRES_ELEVATED_PRIVLEDGES Y
#define COMPANY_ALLUSERS_CREATE_PROPERTY Y
#define BATCH_ACCOUNT System
#define ProdInfo.ProductName WinComposeMod
#define ProdInfo.Default.MsiName WinComposeMod_<$ProductVersion>_Setup_64

#define VER_FILENAME.VER ME.Ver  ;; I only want one VER file

#define ONEXIT_GENERATE_HTML N

; include MAKEMSI support
#include "ME.MMH"

; define default location where file should install and add files
<$DirectoryTree Key="INSTALLDIR" Dir="[ProgramFiles64Folder]\WinComposeMod" Change="\" PrimaryFolder="Y">
<$FilesExclude "..\bin\Release\SequencesUser.txt" ExList="NotThese">  ;; Don't include these
<$Files "..\bin\Release\*" SubDir="TREE" DestDir="INSTALLDIR" ExList="NotThese">
<$Files "Files\*" SubDir="TREE" DestDir="INSTALLDIR">

; === Before Install ===
; create the batch file
<$Component "BatchFile_Bef_Inst" Directory_="INSTALLDIR">
  #define OurBatchFile_Bef_Inst_SN BeforeInstall.bat
  #define OurBatchFile_Bef_Inst <$MAKEMSI_OTHER_DIR>\<$OurBatchFile_Bef_Inst_SN>
  <$FileMake "<$OurBatchFile_Bef_Inst>">
    @echo off
    rem Delete WinComposeMod scheduled task
    %windir%\system32\schtasks.exe /delete /f /tn WinComposeMod
    rem Stop the process WinCompose.exe
    %windir%\system32\taskkill.exe /f /im WinCompose.exe
    rem Delete generated configuration files
    del .\metadata.xml
    del .\settings.ini
    del <$OurBatchFile_Bef_Inst_SN>
  <$/FileMake>
  ; add the batch file
  <$File Source="<$OurBatchFile_Bef_Inst>" KeyPath="Y">
<$/Component>
; invoke the batch file
#define CmdExeFix "  ;; CMD.EXE "feature". Thanks MS...
#(
  <$ExeCa  ;; see https://makemsi-manual.dennisbareis.com/execa.htm and https://makemsi-manual.dennisbareis.com/scheduleca.htm
          EXE=^cmd.exe^
         Args=^/c <$CmdExeFix>"[INSTALLDIR]<$OurBatchFile_Bef_Inst_SN>" "[INSTALLDIR]"<$CmdExeFix>^
      WorkDir="INSTALLDIR"
    Condition=^"1" = "1" and VersionNT^
          Seq="InstallFiles-"
         Type="<$BATCH_ACCOUNT> AnyRc"
  >
#)

; === After Install ===
; create the batch file
<$Component "BatchFile_Aft_Inst" Directory_="INSTALLDIR">
  #define OurBatchFile_Aft_Inst_SN AfterInstall.bat
  #define OurBatchFile_Aft_Inst <$MAKEMSI_OTHER_DIR>\<$OurBatchFile_Aft_Inst_SN>
  <$FileMake "<$OurBatchFile_Aft_Inst>">
    @echo off
    rem Copy SequencesDefault.txt to SequencesUser.txt without overwriting
    if not exist SequencesUser.txt copy SequencesDefault.txt SequencesUser.txt
    rem Write installed path in scheduled task xml file
    echo | .\fnr.exe --cl --find "[INSTALLDIR]" --replace "%CD%" --dir "." --fileMask "WinComposeModTask.xml"
    rem Add WinComposeMod scheduled task
    %windir%\system32\schtasks.exe /create /f /tn WinComposeMod /xml WinComposeModTask.xml
    rem Run WinComposeMod scheduled task
    %windir%\system32\schtasks.exe /run /tn WinComposeMod
    del <$OurBatchFile_Aft_Inst_SN>
  <$/FileMake>
  ; add the batch file
  <$File Source="<$OurBatchFile_Aft_Inst>" KeyPath="Y">
<$/Component>
; invoke the batch file
; (already defined)  #define CmdExeFix "  ;; CMD.EXE "feature". Thanks MS...
#(
  <$ExeCa  ;; see https://makemsi-manual.dennisbareis.com/execa.htm and https://makemsi-manual.dennisbareis.com/scheduleca.htm
          EXE=^cmd.exe^
         Args=^/c <$CmdExeFix>"[INSTALLDIR]<$OurBatchFile_Aft_Inst_SN>" "[INSTALLDIR]"<$CmdExeFix>^
      WorkDir="INSTALLDIR"
    Condition=^<$CONDITION_EXCEPT_UNINSTALL> and VersionNT^
          Seq="StartServices-"
         Type="<$BATCH_ACCOUNT> AnyRc"
  >
#)

; === Before Uninstall ===
; create the batch file
<$Component "BatchFile_Bef_Uninst" Directory_="INSTALLDIR">
  #define OurBatchFile_Bef_Uninst_SN BeforeUninstall.bat
  #define OurBatchFile_Bef_Uninst <$MAKEMSI_OTHER_DIR>\<$OurBatchFile_Bef_Uninst_SN>
  <$FileMake "<$OurBatchFile_Bef_Uninst>">
    @echo off
    rem Delete WinComposeMod scheduled task
    %windir%\system32\schtasks.exe /delete /f /tn WinComposeMod
    rem Stop the process WinCompose.exe
    %windir%\system32\taskkill.exe /f /im WinCompose.exe
    rem Delete generated configuration files
    del .\metadata.xml
    del .\settings.ini
    del <$OurBatchFile_Bef_Uninst_SN>
  <$/FileMake>
  ; add the batch file
  <$File Source="<$OurBatchFile_Bef_Uninst>" KeyPath="Y">
<$/Component>
; invoke the batch file
;; (already defined)  #define CmdExeFix "  ;; CMD.EXE "feature". Thanks MS...
#(
  <$ExeCa  ;; see https://makemsi-manual.dennisbareis.com/execa.htm and https://makemsi-manual.dennisbareis.com/scheduleca.htm
          EXE=^cmd.exe^
         Args=^/c <$CmdExeFix>"[INSTALLDIR]<$OurBatchFile_Bef_Uninst_SN>" "[INSTALLDIR]"<$CmdExeFix>^
      WorkDir="INSTALLDIR"
    Condition=^<$CONDITION_UNINSTALL_ONLY> and VersionNT^
          Seq="StopServices-"
         Type="<$BATCH_ACCOUNT> AnyRc"
  >
#)

<$Icon "..\src\res\icon_normal.ico" Key="WinCompose.exe" Product="Y">
