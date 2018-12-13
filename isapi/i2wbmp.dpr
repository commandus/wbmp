library i2wbmp;
(*##*)
(*******************************************************************************
*                                                                             *
*   i  2  w  b  m  p                                                           *
*                                                                             *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.                       *
*   wbmp image convertor ISAPI/NSAPI DLL                                      *
*   Conditional defines:                                                       *
*                                                                             *
*   How to debug: Run: e:\windows\system32\inetsrv\inetinfo.exe                *
*   Parameters: -e w3svc                                                      *
*   If you are using version 4 or later, you must first make some changes to   *
*   the Registry and the IIS Administration service:                          *
*   1 Use DCOMCnfg to change the identity of the IIS Admin Service to your     *
*     user account.                                                           *
*   2 Use the Registry Editor (REGEDIT) or other utility to remove the         *
*     УLocalServiceФ keyword from all IISADMIN-related subkeys under          *
*     HKEY_CLASSES_ROOT/AppID and HKEY_CLASSES_ROOT/CLSID. This keyword        *
*     appears in the following subkeys:                                       *
*     {61738644-F196-11D0-9953-00C04FD919C1} // IIS WAMREG admin Service       *
*     {9F0BD3A0-EC01-11D0-A6A0-00A0C922E752} // IIS Admin Crypto Extension    *
*     {A9E69610-B80D-11D0-B9B9-00A0C922E750} // IISADMIN Service               *
*     In addition, under the AppID node, remove the УRunAsФ keyword from the  *
*     first two of these subkeys. To the last subkey listed, add УInteractive  *
*     UserФs the value of the УRunAsФ keyword.                                *
*                                                                              *
*   3 Add УLocalService32Ф subkeys to all IISADMIN-related subkeys under the  *
*     CLSID node. That is, for every subkey listed in step 2 (and any others   *
*     under which you found the УLocalServiceФ keyword), add УLocalService32Ф *
*     subkey under the CLSID/<subkey> node. Set the default value of these new *
*     keys to c:\\winnt\\system32\\inetsrv\\inetinfo.exe -e w3svc             *
*   4 Add a value of Уdword:3Ф to the УStartФ keyword for the following subkeys*
*     [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\IISADMIN]         *
*     [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MSDTC]             *
*     [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W3SVC]            *
*   5 Stop the WWW, FTP, and IISAdmin services                                 *
*                                                                             *
*   You must disable restart IIS:                                              *
*                                                                             *
*   в службе IIS Admin выберите команду —войства, вкладка ¬осстановление       *
*   выберите параметр Ќичего не делать в каждом раскрывающемс€ списке.        *
*   Ќажмите кнопку OK.                                                         *
                                                                              *
*                                                                              *
*   Revisions    : Apr 15 2002                                                *
*   Last fix     : Apr 15 2002                                                 *
*   Lines        : 53                                                         *
*   History      :                                                             *
*   Printed      : ---                                                        *
*                                                                              *
********************************************************************************)
(*##*)

uses
{$IFNDEF READPORTIONS}
  HTTPApp, ISAPIApp, webbroker,
{$ELSE}
  WebBroker, ISAPIThreadPool, ISAPIApp,
{$ENDIF}  
  fmain in 'fmain.pas' {WebModule1: TWebModule};

{$R *.RES}

{
  To debug an dll, choose Run|Parameters and set your app's run par..s:
  Microsoft IIS server:
    Host Application: c:\winnt\system32\inetsrv\inetinfo.exe
    Run Parameters:   -e w3svc
  Personal Web Server:
    Host Application: C:\Program Files\WEBSVR\SYSTEM\Inetsw95.exe
    Run Parameters:   -w3svc
  Then navigate in browser:
    http://localhost/scripts/i2wbmp.dll?src=/help.gif
  Netscape webs:
  see "Debugging ISAPI and NSAPI applications" in Delphi help (too many steps)
  TestISAPI.dpr - simple utility calls ISAPI/NSAPI DLL (source included)
    Host Application: C:\Source\ISAPITest\testisapi.exe
    Run Parameters:
    Choose DLL file name
}
exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  Application.Initialize;
  Application.CreateForm(TWebModule1, WebModule1);
  Application.Run;
end.
