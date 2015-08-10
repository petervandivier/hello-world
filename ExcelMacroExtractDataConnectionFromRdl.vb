Sub workbook_open()
    myDir = InputBox("Please enter the current directory of the .rdl files to be scrubbed.")
End Sub



Public myDir As String

Sub extractData()

    Dim myFile As String, FullFileText As String, textline As String

    If myDir = "" Then
        MsgBox "ERROR: target directory is empty, please enter a valid directory. Sub will exit."
        End
    End If
    
    If Right(myDir, 1) <> "\" Then
        myDir = myDir + "\"
    End If
    
    'myDir = "C:\Users\pvandivier\Desktop\Db_Pdb_Bv\"

    For Each cell In Range("rdl[fileName]")

'set vars empty
        FullFileText = ""
        myFile = ""
        textline = ""

        myFile = cell.Value
        Debug.Print myFile
'extract text of the target file to read into string manipulation
'this method copied from http://www.excel-easy.com/vba/examples/read-data-from-text-file.html
        Open myDir & myFile For Input As #1
        Do Until EOF(1)
            Line Input #1, textline
            FullFileText = FullFileText & textline
        Loop
        Close #1

        Call subs.GetDataSetInfo(FullFileText, myFile)
        Call subs.GetDataSourceInfo(FullFileText, myFile)

'set vars empty
        FullFileText = ""
        myFile = ""
        textline = ""

    Next cell

    MsgBox "Success."
End Sub


Sub GetDataSourceInfo(ByVal FullFileText As String, myFile As String)

'get the number of Data Sources in the .rdl file
    dSourceCount = Len(FullFileText) - Len(Replace(FullFileText, "</DataSource>", ""))
    dSourceCount = (dSourceCount / Len("</DataSource>"))
'dynamically size the virtual array to remember info for each of the data sources
    Dim dSourceArray() As String
    ReDim dSourceArray(1 To dSourceCount, 1 To 8) As String

'set vars empty
    TextStartNum = 1
    dSourceName = ""
    dSourceType = ""
    ServerName = ""
    DbName = ""
    dSourceRefName = ""
'iterate through all Data Sources
    For i = 1 To dSourceCount

'extract all text for this data source
        posTextStart = InStr(TextStartNum, FullFileText, "<DataSource Name=") - 1
        posTextEnd = InStr(posTextStart, FullFileText, "</DataSource>") + Len("</DataSource>")
        dSourceText = Mid(FullFileText, posTextStart + 1, posTextEnd - posTextStart)
        TextStartNum = posTextStart + Len(dSourceText)
'get Name for this data source
        posTextStart = InStr(dSourceText, "<DataSource Name=") + Len("<DataSource Name=")
        posTextEnd = InStr(posTextStart, dSourceText, ">")
        dSourceName = Mid(dSourceText, posTextStart + 1, posTextEnd - posTextStart - 2)
'extract conditional data for the data source
        If InStr(dSourceText, "<ConnectString>") > 0 Then 'this is an embedded dSource. get server & Db from connect string
            dSourceType = "Embedded"
'get the server name
            posTextStart = InStr(dSourceText, "<ConnectString>Data Source=") + Len("<ConnectString>Data Source=")
            posTextEnd = InStr(posTextStart, dSourceText, ";")
            ServerName = Mid(dSourceText, posTextStart, posTextEnd - posTextStart)
'get the initial catalog name
            posTextStart = InStr(dSourceText, "Initial Catalog=") + Len("Initial Catalog=")
            posTextEnd = InStr(posTextStart, dSourceText, "</ConnectString>")
            DbName = Mid(dSourceText, posTextStart, posTextEnd - posTextStart)
        Else 'this is a shared data source. just get the DataSourceReference name
            dSourceType = "Shared"
'get the shared data source name
            posTextStart = InStr(dSourceText, "<DataSourceReference>") + Len("<DataSourceReference>")
            posTextEnd = InStr(posTextStart, dSourceText, "</DataSourceReference>")
            dSourceRefName = Mid(dSourceText, posTextStart, posTextEnd - posTextStart)
        End If

'log DataSource info into virtual array
        dSourceArray(i, 1) = dSourceName
        dSourceArray(i, 2) = dSourceType
        dSourceArray(i, 3) = ServerName
        dSourceArray(i, 4) = DbName
        dSourceArray(i, 5) = dSourceRefName
        dSourceArray(i, 6) = dSourceText
        dSourceArray(i, 7) = myFile
        dSourceArray(i, 8) = dSourceCount
'set vars empty
        dSourceName = ""
        dSourceType = ""
        ServerName = ""
        DbName = ""
        dSourceRefName = ""

    Next

'find the next empty row on the logging worksheet
    StartRow = Sheets("dataSource").Range("A1048576").End(xlUp).Row
'write the data source array to the worksheet
    PrintArray dSourceArray, "dataSource", StartRow + 1, 1

End Sub


Sub GetDataSetInfo(ByVal FullFileText As String, myFile As String)

'get the number of Data Sets in the .rdl file
    dSetCount = Len(FullFileText) - Len(Replace(FullFileText, "</DataSet>", ""))
    dSetCount = (dSetCount / Len("</DataSet>"))
'dynamically size the virtual array to remember info for each of the data Sets
    Dim dSetArray() As String
    ReDim dSetArray(1 To dSetCount, 1 To 11) As String

'set vars empty
    dSetText = ""
    dSetName = ""
    ParamCount = 0
    Param = ""
    dSetType = ""
    EmbeddedDsetName = "" 'embedded only
    CmdText = "" 'embedded only
    dSetRefName = "" 'shared only
    dSetServerName = "" 'shared only

    TextStartNum = 1
'iterate through all Data Sets
    For i = 1 To dSetCount

'extract all text for this data Set
        posTextStart = InStr(TextStartNum, FullFileText, "<DataSet Name=") - 1
        posTextEnd = InStr(posTextStart, FullFileText, "</DataSet>") + Len("</DataSet>")
        dSetText = Mid(FullFileText, posTextStart + 1, posTextEnd - posTextStart)
        TextStartNum = posTextStart + Len(dSetText)
'get Name for this data Set
        posTextStart = InStr(dSetText, "<DataSet Name=") + Len("<DataSet Name=")
        posTextEnd = InStr(posTextStart, dSetText, ">")
        dSetName = Mid(dSetText, posTextStart + 1, posTextEnd - posTextStart - 2)
'extract parameter data if it exists
        ParamCount = Len(dSetText) - Len(Replace(dSetText, "<QueryParameter Name=", ""))
        ParamCount = (ParamCount / Len("<QueryParameter Name="))
        'TextStartNum2 = 1 'for the inner param loop
        posTextStart = 0
        Param = "" 'set empty
        If ParamCount > 0 Then
            For j = 1 To ParamCount
                TextStartNum2 = posTextStart + 1
                'Debug.Print Param
                posTextStart = InStr(TextStartNum2, dSetText, "<QueryParameter Name=") + Len("<QueryParameter Name=")
                posTextEnd = InStr(posTextStart, dSetText, ">") + Len(">")
                Param = Param + ";" + Mid(dSetText, posTextStart + 1, posTextEnd - posTextStart - 2)
                Param = Replace(Param, Chr(34), "") 'eliminate double quote chars
            Next
        End If
'extract conditional data for the data Set
        If InStr(dSetText, "<SharedDataSet>") = 0 Then 'this is an embedded dSet. get server & Db from command text
            dSetType = "Embedded"
'get the data source name. only embedded data sets have this
            'Debug.Print dSetText
            posTextStart = InStr(dSetText, "<DataSourceName>") + Len("<DataSourceName>")
            posTextEnd = InStr(posTextStart, dSetText, "</DataSourceName>")
            EmbeddedDsetName = Mid(dSetText, posTextStart, posTextEnd - posTextStart)
'get the command text
            posTextStart = InStr(dSetText, "<CommandText>") + Len("<CommandText>")
            posTextEnd = InStr(posTextStart, dSetText, "</CommandText>")
            CmdText = Mid(dSetText, posTextStart, posTextEnd - posTextStart)
        Else 'this is a shared data Set. just get the DataSetReference name
            dSetType = "Shared"
'get the shared data Set name
            posTextStart = InStr(dSetText, "<SharedDataSetReference>") + Len("<SharedDataSetReference>")
            posTextEnd = InStr(posTextStart, dSetText, "</SharedDataSetReference>")
            dSetRefName = Mid(dSetText, posTextStart, posTextEnd - posTextStart)
'get the reportServer address of the shared data set
            posTextStart = InStr(dSetText, "<rd:ReportServerUrl>") + Len("<rd:ReportServerUrl>")
            posTextEnd = InStr(posTextStart, dSetText, "</rd:ReportServerUrl>")
            dSetServerName = Mid(dSetText, posTextStart, posTextEnd - posTextStart)
        End If

'log DataSet info into virtual array
        dSetArray(i, 1) = myFile
        dSetArray(i, 2) = dSetCount
        dSetArray(i, 3) = dSetText
        dSetArray(i, 4) = dSetName
        dSetArray(i, 5) = ParamCount
        dSetArray(i, 6) = Param
        dSetArray(i, 7) = dSetType
        dSetArray(i, 8) = EmbeddedDsetName 'embedded only
        dSetArray(i, 9) = CmdText 'embedded only
        dSetArray(i, 10) = dSetRefName 'shared only
        dSetArray(i, 11) = dSetServerName 'shared only
'set vars empty
        dSetText = ""
        dSetName = ""
        ParamCount = 0
        Param = ""
        dSetType = ""
        EmbeddedDsetName = "" 'embedded only
        CmdText = "" 'embedded only
        dSetRefName = "" 'shared only
        dSetServerName = "" 'shared only

    Next

'find the next empty row on the logging worksheet
    StartRow = Sheets("dataSet").Range("A1048576").End(xlUp).Row
'write the data Set array to the worksheet
    PrintArray dSetArray, "dataSet", StartRow + 1, 1

End Sub

Sub PrintArray(Data, SheetName, StartRow, StartCol)
'copied from http://stackoverflow.com/questions/6063672/excel-vba-function-to-print-an-array-to-the-workbook
    Dim Row As Integer
    Dim Col As Integer

    Row = StartRow

    For i = LBound(Data, 1) To UBound(Data, 1)
        Col = StartCol
        For j = LBound(Data, 2) To UBound(Data, 2)
            Sheets(SheetName).Cells(Row, Col).Value = Data(i, j)
            Col = Col + 1
        Next j
            Row = Row + 1
    Next i

End Sub




'
'Sub TestSub()
'    Dim myFile As String
'    'myFile = "C:\Users\pvandivier\Desktop\Db_Pdb_Bv\Home.rdl"
'    myFile = "C:\Users\pvandivier\Desktop\Closing Calendar.rdl"
'
''extract text of the target file to read into string manipulation
''this method copied from http://www.excel-easy.com/vba/examples/read-data-from-text-file.html
'    Open myFile For Input As #1
'    Do Until EOF(1)
'        Line Input #1, textline
'        FullFileText = FullFileText & textline
'    Loop
'    Close #1
'
'    'Call GetDataSourceInfo(FullFileText, myFile)
'    Call GetDataSetInfo(FullFileText, myFile)
'End Sub



