;--- Code -------------------------------------------------------------------
#( '<?NewLine>'
    #define AdsiDumpObjectDefinitions

    ;--- Make us as having done the initialization -------------------------
    #define @@DEFINED_AdsiDumpObjectDefinitions

    ;--- Define stuff ------------------------------------------------------
    const PI  = "  * "          ;;Property indent
    const PVI = "    => "        ;;Property value indent (where array etc)
#)
#( '<?NewLine>'
    #define AdsiDumpObject

    ;--- Validation --------------------------------------------------------
    #ifndef  @@DEFINED_AdsiDumpObjectDefinitions
        #error ^You must first use "AdsiDumpObjectDefinitions" to initialize variables^
    #endif

   <?NewLine>
   '=============================================
   function DumpAdsiObject(ByVal oADSI, ByVal DumpChildren)
   '=============================================
       ;--- Initialization ----------------------------------------------
       on error resume next
       dim Cnt
       {$Say} ""
       {$Say} ""
       {$Say} "====[ START DUMP """ & oADSI.name & """]============================="
       oADSI.GetInfo()                  ;;Make sure cache populated

       ;--- Dump the ADSI objects properties ----------------------------
       {$Say} "ADSI properties"
       {$Say} "~~~~~~~~~~~~~~~"
       {$Say} PI & "AdsPath = " & oADSI.AdsPath
       {$Say} PI & "Class   = " & oADSI.class
       {$Say} PI & "GUID    = " & oADSI.GUID
       {$Say} PI & "Parent  = " & oADSI.Parent

       ;--- Output any manditory properties (none for ADSI?) -------------
       dim oSchema : set oSchema = GetObject(oADSI.Schema)
       DumpSetOfProperties oADSI, oSchema.MandatoryProperties, "Mandatory Properties"
       DumpSetOfProperties oADSI, oSchema.OptionalProperties,  "Optional Properties"

       ;--- Dump basic info about contained objects ---------------------
       dim oContained
       Cnt = 0
       for each oContained in oADSI
           ;--- Inital blank line then between each object --------------
           {$Say} ""

           ;--- Output title on first object ----------------------------
           Cnt = Cnt + 1
           if  Cnt = 1 then
               dim Suffix
               if   DumpChildren then
                    Suffix = "(see below)"
               else
                    Suffix = "(not being dumped)"
               end if
               {$Say} "Contains Objects " & Suffix
               {$Say} "~~~~~~~~~~~~~~~~"
           end if

           ;--- Output Info ---------------------------------------------
           dim PISPC : PISPC= replace(PI, "*", " ")
           {$Say} PI    & "Name    = " & oContained.name
           {$Say} PISPC & "Class   = " & oContained.class
           {$Say} PISPC & "AdsPath = " & oContained.AdsPath
           {$Say} PISPC & "GUID    = " & oContained.GUID
       next

       ;--- End of dump -------------------------------------------------
       on error goto 0
       {$Say} "====[ END DUMP """ & oADSI.name & """]============================="
       {$Say} ""
       {$Say} ""

       ;--- Dump contained objects? -------------------------------------
       if   DumpChildren then
           for each oContained in oADSI
               DumpAdsiObject oContained, DumpChildren
           next
       end if
   end function

   <?NewLine>
   '=============================================
   sub DumpSetOfProperties(ByVal oADSI, ByVal oPropertyList, ByVal Title)
   '=============================================
       ;--- Build list of available properties ------------------------------
       on error resume next
       dim Properties()
       dim PropertyCnt  : PropertyCnt  = 0
       dim PropertyName : PropertyName = ""
       for  each PropertyName in oPropertyList
           if  PropertyName = "" then
               exit for
           end if
           redim preserve Properties(PropertyCnt)
           Properties(PropertyCnt) = PropertyName
           PropertyCnt = PropertyCnt + 1
       next

       ;--- Now sort the property names -------------------------------------
       dim i, j, temp
       if  PropertyCnt > 1 then             ;;No point sorting 1 item!
           for i = PropertyCnt-1-1 To 0 Step -1
               for j = 0 to i
                   if Properties(j) > Properties(j+1) then
                       temp            = Properties(j+1)
                       Properties(j+1) = Properties(j)
                       Properties(j)   = temp
                   end if
               next
           next
       end if

       ;--- Work through each sorted property -------------------------------
       for i = 0 to PropertyCnt-1
           ;--- Get properties name -----------------------------------------
           PropertyName = Properties(i)

           ;--- Output title on first object ----------------------------
           if  i = 0 then
               ;--- Generate the title ----------------------------------
               Title = PropertyCnt & " " & Title
               {$Say} ""
               {$Say} Title
               {$Say} string(len(Title), "~")
           end if

           ;--- Get the value -----------------------------------------------
           dim PropertyValue : PropertyValue = oADSI.Get(PropertyName)  'The .Get()/.GetEx() can sometimes kill the process - ADSI bug (to see try "IIS:" as root object)?

           ;--- Output the value (may be an array) --------------------------
           if  not IsArray(PropertyValue) then
               ;--- Its not an array so just dump ---------------------------
               DumpProperty PI, 0, PropertyName, PropertyValue
           else
               ;--- Its an array --------------------------------------------
               {$Say} PI & PropertyName & " (array):"
               dim OneStr
               dim MemberCnt : MemberCnt = 0
               for each OneStr in PropertyValue
                   MemberCnt = MemberCnt + 1
                   DumpProperty PVI, MemberCnt, PropertyName, OneStr
               next
               if   MemberCnt = 0 then
                    {$Say} PVI & "<<EmptyArray>>"
               end if
           end if
       next
   end sub

   <?NewLine>
   '=============================================
   sub DumpProperty(ByVal Indent, ByVal Cnt, ByVal ItsName, ByRef ItsValue)
   '=============================================
        ;--- Work out the items prefix --------------------------------------
        on error resume next
        dim Prefix
        if  Cnt = 0 then
            Prefix = Indent & ItsName & " = "     ;;Not an array item
        else
            Prefix = Indent                       ;;Array item (name already dumped)
        end if

        ;--- See if its an object we know how to handle ---------------------
        if  ItsName = "MimeMap" then
            ;--- OBJECT: IISMimeType ----------------------------------------
            dim ObjIndent : ObjIndent = string(len(Indent), " ")
            {$Say} Indent    & "OBJECT #" & Cnt & " IISMimeType:"
            {$Say} ObjIndent & "- MimeType =" & ItsValue.MimeType
            {$Say} ObjIndent & "- Extension=" & ItsValue.Extension
        else
            ;--- Not a known/handled object type ----------------------------
            err.clear()
            {$Say} Prefix & ItsValue
            if  err.number <> 0 then
                {$Say} Prefix & "!!! Failed to display value (TYPE = " & typename(ItsValue) & ")"
            end if
        end if
   end sub
#)