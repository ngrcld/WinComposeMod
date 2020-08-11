;--- Before Install: Create Our Batch file --------------------------------------------------
<$Component "BatchFile_Bef_Inst" Directory_="INSTALLDIR">
  #define OurBatchFile_Bef_Inst_SN BeforeInstall.bat
  #define OurBatchFile_Bef_Inst <$MAKEMSI_OTHER_DIR>\<$OurBatchFile_Bef_Inst_SN>
  <$FileMake "<$OurBatchFile_Bef_Inst>">
    @echo off
    rem Delete WinComposeMod scheduled task
    %windir%\system32\schtasks.exe /delete /f /tn WinComposeMod
    rem Stop the process WinCompose.exe
    %windir%\system32\taskkill.exe /f /im WinCompose.exe
    del <$OurBatchFile_Bef_Inst_SN>
  <$/FileMake>
  ;--- Add the batch file -------------------------------------------------
  <$File Source="<$OurBatchFile_Bef_Inst>" KeyPath="Y">
<$/Component>
;--- Before Install: Invoke the batch file --------------------------------------------------
#define CmdExeFix "  ;; CMD.EXE "feature". Thanks MS...
#(
  <$ExeCa  ;; see https://makemsi-manual.dennisbareis.com/execa.htm and https://makemsi-manual.dennisbareis.com/scheduleca.htm
          EXE=^cmd.exe^
         Args=^/c <$CmdExeFix>"[INSTALLDIR]<$OurBatchFile_Bef_Inst_SN>" "[INSTALLDIR]"<$CmdExeFix>^
      WorkDir="INSTALLDIR"
    Condition=^"1" = "1" and VersionNT^
          Seq="InstallFiles-"
         Type="<$batch_account> AnyRc"
  >
#)
