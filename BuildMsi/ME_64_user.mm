#define COMPANY_SUMMARY_TEMPLATE x64;0
#define COMPANY_PACKAGE_REQUIRES_ELEVATED_PRIVLEDGES N
#define COMPANY_ALLUSERS_CREATE_PROPERTY N
#define BATCH_ACCOUNT Impersonate
#define ProdInfo.ProductName WinComposeMod user
#define ProdInfo.Default.MsiName WinComposeMod_<$ProductVersion>_Setup_64_user

#define VER_FILENAME.VER ME.Ver  ;; I only want one VER file

#define ONEXIT_GENERATE_HTML N

; include MAKEMSI support
#include "ME.MMH"

; define default location where file should install and add files
<$DirectoryTree Key="INSTALLDIR" Dir="[AppDataFolder]\WinComposeMod" Change="\" PrimaryFolder="Y">
<$Files "..\bin\Release\*" SubDir="TREE" DestDir="INSTALLDIR">

; === Before Install ===
; create the batch file
<$Component "BatchFile_Bef_Inst" Directory_="INSTALLDIR">
  #define OurBatchFile_Bef_Inst_SN BeforeInstall.bat
  #define OurBatchFile_Bef_Inst <$MAKEMSI_OTHER_DIR>\<$OurBatchFile_Bef_Inst_SN>
  <$FileMake "<$OurBatchFile_Bef_Inst>">
    @echo off
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
    rem Run WinComposeMod
    start "" .\WinCompose.exe
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

<$Component "NonAdvertisedShortcut" Create="Y" Directory_="INSTALLDIR">
  #(
    <$Shortcut
           Target="[INSTALLDIR]WinCompose.exe"
            Title="WinComposeMod"
             Icon="WinCompose.exe"
    >
  #)
<$/Component>
