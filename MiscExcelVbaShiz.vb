Sub DimNulls()
    Cells.FormatConditions.Delete
    Range("Table1").Select
    Selection.FormatConditions.Add Type:=xlCellValue, Operator:=xlEqual, _
        Formula1:="=""NULL"""
    Selection.FormatConditions(Selection.FormatConditions.Count).SetFirstPriority
    With Selection.FormatConditions(1).Font
        .ThemeColor = xlThemeColorDark1
        .TintAndShade = -0.349986266670736
    End With
    Selection.FormatConditions(1).StopIfTrue = False
End Sub


Sub UnhideSheets()
  Dim ws As Worksheet
  For Each ws In Worksheets
    ws.Visible = True
  Next
End Sub

Sub rename()
    For Each c In Range("Table1[Column1]")
	Cells.Replace What:=(c.value) _
	, Replacement:=(c.offset(0,1).value) _
	, LookAt:=xlPart _
	, SearchOrder:=xlByRows _
	, MatchCase:=False _
	, SearchFormat:=False _
	, ReplaceFormat:=False
    Next c
    msgbox "success"
End Sub



Public Function rangeConcat(ByVal aRange As Range, Optional ByVal Delimiter As String, Optional DelimCatch As String) As String
    Dim ouputString As String, cVal As String
    For Each c In aRange.Cells
        cVal = c.Value
        
        If InStr(cVal, Delimiter) <> 0 And Not (IsEmpty(DelimCatch)) Then
            cVal = DelimCatch + cVal + DelimCatch
        End If
        
        outputString = outputString & cVal & Delimiter
    Next c
    If Delimiter = "" Then
        rangeConcat = outputString
    Else
        rangeConcat = Left(outputString, Len(outputString) - 1)
    End If
End Function

Function removeSpecial(sInput As String) As String
    Dim sSpecialChars As String
    Dim i As Long
    sSpecialChars = "\/:*?™""®<>|.&@#(_+`©~);-+=^$!,'" 'This is your list of characters to be removed
    For i = 1 To Len(sSpecialChars)
        sInput = Replace$(sInput, Mid$(sSpecialChars, i, 1), " ")
    Next
    removeSpecial = sInput
End Function

Function Reverse(Text As String) As String
    Dim i As Integer
    Dim StrNew As String
    Dim strOld As String
    strOld = Trim(Text)
    For i = 1 To Len(strOld)
      StrNew = Mid(strOld, i, 1) & StrNew
    Next i
    Reverse = StrNew
End Function

Function ReverseHex(Text As String) As String
    Dim i As Integer
    Dim StrNew As String
    Dim strOld As String
    strOld = Trim(Text)
    For i = 1 To Len(strOld)
      StrNew = Mid(strOld, ((i * 2) - 1), 2) & StrNew
    Next i
    ReverseHex = StrNew
End Function

Function getRGB1(rcell) As String
    Dim sColor As String

    sColor = Right("000000" & Hex(rcell.Interior.Color), 6)
    getRGB1 = Right(sColor, 2) & Mid(sColor, 3, 2) & Left(sColor, 2)
End Function

'all datatables must be unfiltered and all rows/columns must be unhidden
Sub MakeSimple()
  Dim ws As Worksheet
  For Each ws In Worksheets
    ws.Visible = True
    ws.Activate
    Cells.Select
    Selection.Copy
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    Application.CutCopyMode = False
  Next
  Msgbox "Complete"
End Sub

'Password Cracker fro Excel 97-03
Sub PasswordBreaker()
  'Author unknown but submitted by brettdj of www.experts-exchange.com
  
  Dim i As Integer, j As Integer, k As Integer
  Dim l As Integer, m As Integer, n As Integer
  Dim i1 As Integer, i2 As Integer, i3 As Integer
  Dim i4 As Integer, i5 As Integer, i6 As Integer
  On Error Resume Next
  For i = 65 To 66: For j = 65 To 66: For k = 65 To 66
  For l = 65 To 66: For m = 65 To 66: For i1 = 65 To 66
  For i2 = 65 To 66: For i3 = 65 To 66: For i4 = 65 To 66
  For i5 = 65 To 66: For i6 = 65 To 66: For n = 32 To 126
     
        
 ActiveSheet.Unprotect Chr(i) & Chr(j) & Chr(k) & _
      Chr(l) & Chr(m) & Chr(i1) & Chr(i2) & Chr(i3) & _
      Chr(i4) & Chr(i5) & Chr(i6) & Chr(n)
  If ActiveSheet.ProtectContents = False Then
      Debug.Print "One usable password is " & Chr(i) & Chr(j) & _
          Chr(k) & Chr(l) & Chr(m) & Chr(i1) & Chr(i2) & _
          Chr(i3) & Chr(i4) & Chr(i5) & Chr(i6) & Chr(n)
   'ActiveWorkbook.Sheets(1).Select
   PrintVal = Chr(i) & Chr(j) & _
          Chr(k) & Chr(l) & Chr(m) & Chr(i1) & Chr(i2) & _
          Chr(i3) & Chr(i4) & Chr(i5) & Chr(i6) & Chr(n)
    Debug.Print PrintVal
       Exit Sub
  End If
  Next: Next: Next: Next: Next: Next
  Next: Next: Next: Next: Next: Next


End Sub


'Function: The function will return the result for the first test that evaluates to true
'Usage: Enter this function into your spreadsheet with the required arguements
'Basic Syntax: Switch2(Test1, Result1, Test2, Result2, etc...)
'Rules: You must have at least one test/result pair.
'You'll have to add to the code if you want more than 14 tests.
'Example:'=Switch2(C4="Apple","Red",C4="Grape","Purple",C4="Orange","Orange", TRUE, "No Color Match")
'Note the use of the test/result combination "True, "No Color Match" so that the function will return
'something if none of the tests evaluate to true

Function Switch2(Test1 As String, Result1 As String, _
	Optional Test2 As String, Optional Result2 As String, _
	Optional Test3 As String, Optional Result3 As String, _
	Optional Test4 As String, Optional Result4 As String, _
	Optional Test5 As String, Optional Result5 As String, _
	Optional Test6 As String, Optional Result6 As String, _
	Optional Test7 As String, Optional Result7 As String, _
	Optional Test8 As String, Optional Result8 As String, _
	Optional Test9 As String, Optional Result9 As String, _
	Optional Test10 As String, Optional Result10 As String, _
	Optional Test11 As String, Optional Result11 As String, _
	Optional Test12 As String, Optional Result12 As String, _
	Optional Test13 As String, Optional Result13 As String, _
	Optional Test14 As String, Optional Result14 As String)
 
Switch2 = Switch(Test1, Result1, _
	Test2, Result2, _
	Test3, Result3, _
	Test4, Result4, _
	Test5, Result5, _
	Test6, Result6, _
	Test7, Result7, _
	Test8, Result8, _
	Test9, Result9, _
	Test10, Result10, _
	Test11, Result11, _
	Test12, Result12, _
	Test13, Result13, _
	Test14, Result14)
End Function


Sub highlightext()
'copied from http://stackoverflow.com/a/35438374/4709762
	Application.ScreenUpdating = False

	Dim ws As Worksheet
	Set ws = Worksheets("Sheet1")

	Dim oRange As Range
	Set oRange = ws.Range("A:A")

	Dim wordToFind As String
	wordToFind = InputBox(Prompt:="What word would you like to highlight?")

	Dim cellRange As Range
	Set cellRange = oRange.Find(What:=wordToFind, LookIn:=xlValues, _
						LookAt:=xlPart, SearchOrder:=xlByRows, SearchDirection:=xlNext, _
						MatchCase:=False, SearchFormat:=False)

	If Not cellRange Is Nothing Then

		Dim Foundat As String
		Foundat = cellRange.Address

		Do

			Dim textStart As Integer
			textStart = 1

			Do

				'to compare lower case only use this
				'textStart = InStr(textStart, LCase(cellRange.Value), LCase(wordToFind))
				textStart = InStr(textStart, cellRange.Value, wordToFind)
				If textStart <> 0 Then
					cellRange.Characters(textStart, Len(wordToFind)).Font.Color = RGB(250, 0, 0)
					textStart = textStart + 1
				End If


			Loop Until textStart = 0

			Set cellRange = oRange.FindNext(After:=cellRange)

		Loop Until cellRange Is Nothing Or cellRange.Address = Foundat

	End If

End Sub


'copied from http://stackoverflow.com/questions/4243036/levenshtein-distance-in-excel
'variants and optimized versions available at the link above
Option Explicit
Public Function Levenshtein(s1 As String, s2 As String)

Dim i As Integer
Dim j As Integer
Dim l1 As Integer
Dim l2 As Integer
Dim d() As Integer
Dim min1 As Integer
Dim min2 As Integer

l1 = Len(s1)
l2 = Len(s2)
ReDim d(l1, l2)
For i = 0 To l1
    d(i, 0) = i
Next
For j = 0 To l2
    d(0, j) = j
Next
For i = 1 To l1
    For j = 1 To l2
        If Mid(s1, i, 1) = Mid(s2, j, 1) Then
            d(i, j) = d(i - 1, j - 1)
        Else
            min1 = d(i - 1, j) + 1
            min2 = d(i, j - 1) + 1
            If min2 < min1 Then
                min1 = min2
            End If
            min2 = d(i - 1, j - 1) + 1
            If min2 < min1 Then
                min1 = min2
            End If
            d(i, j) = min1
        End If
    Next
Next
Levenshtein = d(l1, l2)
End Function
