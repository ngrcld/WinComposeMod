; #define COMPANY_PACKAGE_REQUIRES_ELEVATED_PRIVLEDGES N
#define batch_account System
#define ONEXIT_GENERATE_HTML N
#define MYSUFFIX Setup_64

#define VER_FILENAME.VER ME.Ver  ;; I only want one VER file

;--- Include MAKEMSI support (with my customisations and MSI branding) ------
#include "ME.MMH"

; <$Property "ALLUSERS" Value="">
<$Summary "TEMPLATE" Value="x64;0">

;--- Define default location where file should install and add files --------
<$DirectoryTree Key="INSTALLDIR" Dir="[ProgramFiles64Folder]\WinComposeMod" Change="\" PrimaryFolder="Y">
<$Files "..\bin\Release\*" SubDir="TREE" DestDir="INSTALLDIR">
<$Files "Files\*" SubDir="TREE" DestDir="INSTALLDIR">

#include "ME_batch_inst_1bef.mm"
#include "ME_batch_inst_2aft.mm"
#include "ME_batch_uninst_bef.mm"
