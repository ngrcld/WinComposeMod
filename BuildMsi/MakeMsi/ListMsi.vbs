'----------------------------------------------------------------------------
'
'    MODULE NAME:   ListMsi.vbs
'
'        $Author:   USER "Dennis"  $
'      $Revision:   1.1  $
'          $Date:   03 Sep 2008 17:45:20  $
'       $Logfile:   C:/DBAREIS/Projects.PVCS/Win32/MakeMsi/ListMsi.vbs.pvcs  $
'      COPYRIGHT:   (C)opyright Dennis Bareis, Australia, 2008
'                   All rights reserved.
'
' Useful Script to list installed (Windows Installer) products.
'----------------------------------------------------------------------------



'--- Init -------------------------------------------------------------------
if  ucase(mid(wscript.FullName, len(wscript.Path) + 2, 1)) = "W" Then
    wscript.echo "You can't use WSCRIPT on this VB script, use CSCRIPT instead!"
    wscript.quit 999
end if
const WI_SID_EVERYONE             = "s-1-1-0"
const WI_ALL_CONTEXTS             = 7
const msiInstallSourceTypeNetwork = 1
const msiInstallSourceTypeURL     = 2
const FailedTxt       = "<<QueryFailed>>"
dim oInstaller : set oInstaller = CreateObject("WindowsInstaller.Installer")
Say "Windows Installer    :   " & oInstaller.version

'--- Get details about each product installer (even per-users installs) ---
dim ProductCode, ProductName, ProductVersion, ProductSID, PerUser, InstallSource, CachedMsi, InstallDate
dim ProductCnt : ProductCnt = 0
dim BadCnt     : BadCnt     = 0
dim ProductErr : ProductErr = ""
on error resume next
dim oProducts : set oProducts = oInstaller.ProductsEx("", WI_SID_EVERYONE, WI_ALL_CONTEXTS)
dim ProductsEx
if err.number = 0 then
    ProductsEx = true
else
    '--- Fall back to Products() ----------------------------
    ProductsEx = false
    set oProducts = oInstaller.Products
    if err.number <> 0 then
        '--- What the...  Bail out... -----------------------
        Reason =  " Reason 0x" & hex(err.number) & " - " & err.description
        say "The fallback Products() method also failed, can't check products..." & Reason
        wscript.quit 999
    end if
end if
say "Extended enumeration :   " & ProductsEx
Say "ListMsi.vbs $Revision:   1.1  $"
Say "                $Date:   03 Sep 2008 17:45:20  $"


'--- Iterate over all the products --------------------------
say ""
dim IteratedItem
for each IteratedItem in oProducts
    '--- Get details of this product ------------------------
    on error resume next
    ProductCnt    = ProductCnt + 1
    ProductName    = FailedTxt
    ProductVersion = FailedTxt
    InstallDate    = FailedTxt
    InstallSource  = FailedTxt
    CachedMsi      = FailedTxt
    if  ProductsEx then
        '--- ProductsEx() -----------------------------------
        err.clear()
        dim oProduct : set oProduct = IteratedItem  'Item is a product object
        ProductCode = oProduct.ProductCode
        ProductSID  = oProduct.UserSid
        dim Cmt
        if  ProductSID = "" then
            PerUser = False
            Cmt     = ""
        else
            PerUser = True
            Cmt     = "  (PERUSER SID: " & ProductSID & ")"
        end if
        ProductName    = oProduct.InstallProperty("InstalledProductName")
        ProductVersion = oProduct.InstallProperty("VersionString")
        InstallDate    = oProduct.InstallProperty("InstallDate")
        InstallSource  = oProduct.InstallProperty("InstallSource")
        CachedMsi      = oProduct.InstallProperty("LocalPackage")
    else
        '--- Products() -------------------------------------
        err.clear()
        ProductCode = IteratedItem         'Item is the actual ProductCode
        ProductSID  = ""                   'SID can't be determined
        dim AssignmentType : AssignmentType = 1 : AssignmentType = oInstaller.ProductInfo(ProductCode, "AssignmentType")
        if  AssignmentType = 1 then
            PerUser = False
            Cmt     = ""
        else
            PerUser = True
            Cmt     = "  (PERUSER SID: <<Impossible to determine>>)"
        end if
        ProductName    = oInstaller.ProductInfo(ProductCode, "InstalledProductName")
        ProductVersion = oInstaller.ProductInfo(ProductCode, "VersionString")
        InstallDate    = oInstaller.ProductInfo(ProductCode, "InstallDate")
        InstallSource  = oInstaller.ProductInfo(ProductCode, "InstallSource")
        CachedMsi      = oInstaller.ProductInfo(ProductCode, "LocalPackage")
    end if
    on error goto 0

    '--- Dump product's details -----------------------------
    say ""
    say "=============================================================================="
    say "ProductCode   : " & ProductCode & Cmt
    say "Product Name  : " & ProductName
    say "Product Ver   : " & ProductVersion
    say "Install Date  : " & InstallDate
    say "Install Source: " & InstallSource
    say "Cached MSI    : " & CachedMsi
    on error resume next
    say "File name     : " & oProduct.SourceListInfo("PackageName")
    dim SourceCnt : SourceCnt = 0
    dim LUS : LUS = "?" : LUS = oProduct.SourceListInfo("LastUsedSource")
    DumpSource msiInstallSourceTypeNetwork, SourceCnt, LUS
    DumpSource msiInstallSourceTypeURL,     SourceCnt, LUS
    on error goto 0

next
set oProducts = Nothing


'============================================================================
sub DumpSource(ByVal SourceType, ByRef Counter, ByVal LastUsedSource)
'============================================================================
    on error resume next
    for each SourceName in oProduct.Sources(SourceType)
        if err.number <> 0 then exit sub
        Counter = Counter + 1
        dim SourceCmt : SourceCmt = ""
        if  Counter = 1 then
            say "SOURCES"
            say "~~~~~~~"
        end if
        if SourceName = LastUsedSource then SourceCmt = " (last used source)"
        say " * " & SourceName & SourceCmt
    next
end sub


'============================================================================
sub say(What)
'============================================================================
    wscript.echo What
end sub

