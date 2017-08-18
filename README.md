![](https://dl.dropboxusercontent.com/u/12733424/github/delphi-preview-handler/logo.png)
The **Delphi Preview Handler**, is a [preview handler](http://msdn.microsoft.com/en-us/magazine/cc163487.aspx) 
for Windows Vista, 7, 8 and 10 which allows you to read your source code with syntax highlighting 
without having to open it in an editor.

### Features ###
* Supports Windows Vista, 7, 8 and 10 on 32 and 64 bits.
* +50 syntax highlight themes.
* +60 source code extensions supported.
* Themes compatibles with the [Delphi IDE Theme Editor](https://github.com/RRUZ/delphi-ide-theme-editor)

This preview handler can render the following file extensions:

Extensions | Description| Preview
------------ | ------------- | -------------
.pp , .pas, .lpr, .lpk, .lfm, .inc | Free Pascal/Lazarus Files | [![](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/fpc-Sample%20Files.png)](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/fpc-Sample%20Files.png)
.pas, .dpr, .dpk, .inc, .dproj, .bdsproj  | Delphi  Files | [![](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/Delphi-Sample%20Files.png)](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/Delphi-Sample%20Files.png)
.c, .cpp,. cc,.h, .hpp,.hh, .cxx, .hxx, . cu | C and C++ source Files | [![](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/c-Sample%20Files.png)](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/c-Sample%20Files.png)
.asm | Assembler source files | [![](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/Asm-Sample%20Files.png)](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/Asm-Sample%20Files.png)
.e, .ace | Eiffel files | .
.f, .for | Fortran files | .
.java | Java files | .
 .csproj, .xaml, .sln, .vcxproj, .vbproj, .jsproj, .appxmanifest | Visual Studio files |
.bas, .vb | Visual Basic files | .
.cbl, .cob | COBOL files | .
.cs | C# files | [![](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/cs-Sample%20Files.png)](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/cs-Sample%20Files.png)
.css | Cascading Stylesheet files |
.htm, .html | HTML Documents |
.js | Javascript files | [![](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/JScript-Sample%20Files.png)](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/JScript-Sample%20Files.png)
.php, .php3, .phtml | PHP files | [![](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/php-Sample%20Files.png)](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/php-Sample%20Files.png)
.vbs | VBScript files | .
.bat, .cmd | MS-DOS Batch Files | .
.dfm, .xfm | Borland Form Files | .
.pl, .pm, .cgi | Perl Files | [![](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/perl-Sample%20Files.png)](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/perl-Sample%20Files.png)
.py | Python files | [![](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/python-Sample%20Files.png)](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/python-Sample%20Files.png)
.rb, .rbw | Ruby files | [![](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/ruby-Sample%20Files.png)](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/ruby-Sample%20Files.png)
.sh | UNIX Shell Scripts | .
.sql | SQL files | [![](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/sql-Sample%20Files.png)](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/sql-Sample%20Files.png)
.iss | Inno Setup Scripts | [![](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/Inno-Sample%20Files.png)](https://dl.dropboxusercontent.com/u/12733424/Blog/Delphi%20Preview%20Handler/Images/Inno-Sample%20Files.png)
.ini | INI files | .

### Important Note about installing a new version ###
In order to avoid problems you must follow these steps when you install or register a new 
version of the preview handler.

  1. Close all the windows explorer instances which have the preview handler active or the
     preview handler was used (remember the dll remains in memory until the windows explorer 
     was closed).
  2. Unregister the previous version executing the uninstaller located in 
     `C:\Program Files (x86)\TheRoadToDelphi\DelphiPreviewHandler` or 
     `C:\Program Files\TheRoadToDelphi\DelphiPreviewHandler`
  3. If you install the preview handler manually you must unregister using the `UnRegister.bat`
     running as admin.
  4. Now proceed with the installation of the new version.


Looking for the installer? Check the [Release Area](https://github.com/RRUZ/delphi-preview-handler/releases/latest) 
