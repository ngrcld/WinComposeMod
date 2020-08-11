;--- Before Uninstall: Create Our Batch file --------------------------------------------------
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
  ;--- Add the batch file -------------------------------------------------
  <$File Source="<$OurBatchFile_Bef_Uninst>" KeyPath="Y">
<$/Component>
;--- Before Uninstall: Invoke the batch file --------------------------------------------------
;; (already defined)  #define CmdExeFix "  ;; CMD.EXE "feature". Thanks MS...
#(
  <$ExeCa  ;; see https://makemsi-manual.dennisbareis.com/execa.htm and https://makemsi-manual.dennisbareis.com/scheduleca.htm
          EXE=^cmd.exe^
         Args=^/c <$CmdExeFix>"[INSTALLDIR]<$OurBatchFile_Bef_Uninst_SN>" "[INSTALLDIR]"<$CmdExeFix>^
      WorkDir="INSTALLDIR"
    Condition=^<$CONDITION_UNINSTALL_ONLY> and VersionNT^
          Seq="StopServices-"
         Type="<$batch_account> AnyRc"
  >
#)
