;----------------------------------------------------------------------------
;
;    MODULE NAME:   PrettyMd5.VH
;
;        $Author:   USER "Dennis"  $
;      $Revision:   1.0  $
;          $Date:   20 Oct 2003 18:03:30  $
;       $Logfile:   C:/DBAREIS/Projects.PVCS/Win32/MakeMsi/PrettyMd5.VH.pvcs  $
;      COPYRIGHT:   (C)opyright Dennis Bareis, Australia, 2003
;                   All rights reserved.
;
;   Code for pretty formatting of an MD5 given a MD5 record.
;----------------------------------------------------------------------------
<?NewLine>

'=========================================================================
function PrettyHash(ByVal UglyHash)
'=========================================================================
   PrettyHash = Hex8(UglyHash.IntegerData(1)) & "-" & Hex8(UglyHash.IntegerData(2)) & "-" & Hex8(UglyHash.IntegerData(3)) & "-" & Hex8(UglyHash.IntegerData(4))
end function

<?NewLine>
'=========================================================================
function Hex8(Value)              ;;Returns 8 digit hex value
'=========================================================================
   ;--- Create the hash as 8 digit hex (Bytes are reversed) ---------
   Hex8 = hex(Value)
   Hex8 = right(string(8, "0") & Hex8, 8)

   ;--- Correct the order of the 4 bytes ----------------------------
   Hex8 = mid(Hex8,7,2) & mid(Hex8,5,2) & mid(Hex8,3,2) & mid(Hex8,1,2)
end function

