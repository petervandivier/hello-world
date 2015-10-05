'http://www.mrexcel.com/forum/excel-questions/583091-write-microsoft-sql-db-excel-visual-basic-applications.html

Private Sub XLToADO()
Dim conn As ADODB.Connection
Dim cmd As ADODB.Command
Dim rs As ADODB.Recordset
Dim strConn As String
Dim strSRV As String
Dim strDB As String

    ' connect to SQL Server

    strSRV = "localhost"
    strDB = "Hambone"
    
    Set conn = New ADODB.Connection
    
    ' create connection string
    strConn = "Driver={SQL Server};Server=" & strSRV & ";Database=" & strDB
    
    conn.ConnectionString = strConn
    
    conn.Open


'    strConn = strConn & "Provider=SQLOLEDB;Data Source=" & strSRV & ";"
'    strConn = strConn & "Initial Catolog=" & strDB & ";Trusted_Connection=YES"

    cmd.Open "insert TestTableFromMacro ( Char1 ) values ('Y') ;", conn
    'rs.Open "select * from TestTableFromMacro ;", conn

    cmd.Close
    conn.Close

End Sub