;--- After Install: Create Our Batch file --------------------------------------------------
<$Component "BatchFile_Aft_Inst" Directory_="INSTALLDIR">
  #define OurBatchFile_Aft_Inst_SN AfterInstall.bat
  #define OurBatchFile_Aft_Inst <$MAKEMSI_OTHER_DIR>\<$OurBatchFile_Aft_Inst_SN>
  <$FileMake "<$OurBatchFile_Aft_Inst>">
    @echo off
    rem Add WinComposeMod scheduled task
    %windir%\system32\schtasks.exe /create /f /tn WinComposeMod /xml WinComposeModTask.xml
    rem Run WinComposeMod scheduled task
    %windir%\system32\schtasks.exe /tn WinComposeMod /run
    del <$OurBatchFile_Aft_Inst_SN>
  <$/FileMake>
  ;--- Add the batch file -------------------------------------------------
  <$File Source="<$OurBatchFile_Aft_Inst>" KeyPath="Y">
<$/Component>
;--- After Install: Invoke the batch file --------------------------------------------------
;; (already defined)  #define CmdExeFix "  ;; CMD.EXE "feature". Thanks MS...
#(
  <$ExeCa  ;; see https://makemsi-manual.dennisbareis.com/execa.htm and https://makemsi-manual.dennisbareis.com/scheduleca.htm
          EXE=^cmd.exe^
         Args=^/c <$CmdExeFix>"[INSTALLDIR]<$OurBatchFile_Aft_Inst_SN>" "[INSTALLDIR]"<$CmdExeFix>^
      WorkDir="INSTALLDIR"
    Condition=^<$CONDITION_EXCEPT_UNINSTALL> and VersionNT^
          Seq="StartServices-"
         Type="<$batch_account> AnyRc"
  >
#)
