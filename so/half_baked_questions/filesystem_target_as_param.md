#SSRS placeholder values & parameter best practices
I have an SSRS report that reads data from an ETL of user files from a domain shared folder. For certain textboxes, I wanted to provide click-through from the report to the file that "caused" the value the user is currently seeing. 

Simple enough: I set the <kbd>Action</kbd> as <kbd>Go to URL</kbd> with expression value of `=Parameters!FileSystem.Value & Fields!LD1_Directory.Value & Fields!LD1_FileName.Value` where `LD1_Directory` & `LD1_FileName` are determined from the Dataset and  `FileSystem` is an internal text param with default value of `file:///`. 

Unfortunately, using this method spams the value to `ReportServer.dbo.ExecutionLogStorage`; which is not a huge issue at the moment, but it takes up space. I suppose I could just set the string literal `="file:///"` in the <kbd>Go to URL</kbd> expression, but that _feels_ messy...

###What is best practice for sharing this value across many expressions in my report?
I've considered the following

1. Suck it up and use the string literal across all instances of the param usage
2. Create a hidden named text box with the same value; likewise changing `Parameters!FileSystem.Value` to `ReportItems!FileSystem.Value`
3. Segregate the variable into custom code ( sample below) and call the value with `=Code.GetGlobalVar( "FileSystem" )`

<b></b>

    Public Function GetGlobalVar( VarName as String )
    	Dim RetStr as String
    	If VarName="FileSystem"
    		RetStr="File:///"
    	End If
    	Return RetStr
    End Function
     

###Keeping it as a Param causes the below behavior





