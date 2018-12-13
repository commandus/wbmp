	i2wbmp
	======

This file contains last release notes to help you obtain maximum 
performance from your copy of i2wbmp bitmap image convertor.  

This version is intended for users of Windows 95, Windows 98, Windows Millennium, 
Windows NT Workstation 4.0 with Service Pack 3 or higher, Windows 2000 with 
Service Pack 1 or higher.

i2wmp is a ISAPI/NSAPI web server DLL for creating WAP enabled WBMP files
from any of your favorite images. It supports most popular image 
formats - BMP, GIF, JPEG, ICO, WMF and WBMP itsels.

i2wmp is a part of cvrt2wbmp.

	What's new
	----------

It is version 1.0

	System requirements
	-------------------

To run this program your computer must meet the following minimum requirements:

- Windows 95, 98, ME, NT, 2000, XP;
- 2 MB of available hard disk space;
- IIS, PWS or any other ISAPI/NSAPI web server extensions enabled web server.

	Overview
	--------

i2wbmp is a graphics tool for creating WAP enabled WBMP files
from any of your favorite images. It supports most popular image 
formats - BMP, GIF, JPEG, ICO, WMF and WBMP. 


	What WBMP is
	------------

Wireless Bitmap is a graphic format optimized for mobile computing
devices. 
A WBMP image is identified using a TypeField value, which describes
encoding information (such as pixel and palette organization,
compression, and animation) and determines image characteristics
according to WAP documentation.
TypeField values are represented by an Image Type Identifier. 
Currently, there is only one type of WMBP specified; the Image Type
Identifier label for this is 0.
0 has the following characteristics:

- No compression
- One bit color (white=1, black=0)
- One bit deep (monochrome)
Any WAP device that supports WBMPs can only support type 0.

WBMP is part of the Wireless Application Protocol, Wireless Application
Environment Specification Version 1.1.

	Supported formats
	-----------------

Format					File extensions

MS Windows Icon				ico	
Bitmap					bmp, dib
Joint Photographic Experts Group Format	jpeg, jpg
Wireless Bitmap (Level 0)		wbmp
Windows metafiles			wmf	
Enhanced metafiles			emf	

	Shareware version limitations
	-----------------------------
No.

	Download new versions
	---------------------

Not provided yet.


	Installation
	------------

Read license agreement (file license.txt) first before use of it. 

Note that for Windows NT and Windows 2000 machines, the user logged
in during the installation much have local (machine) administrator
rights.

Copy i2wbmp.dll to the /scripts folder of your web server or other folder.
Check the folder has rights to load ISAPI/NSAPI extension DLL. Open
a brower window, let try

	http://localhost/scripts/i2wbmp.dll/info

Information appears such current version. Check is web server aliases are
displayed.

Then check some bitmap images:

	http://ensen/scripts/i2wbmp.dll?dither=stucki&src=/icons/basket.gif

where	
	src=[alias|folder]filename,
	/icons is a web server alias,
	dither=Nearest|FloydSteinberg|Stucki|Sierra|JaJuNI|SteveArche|Burkes

Note: you must provide absolute file name path or use web server's virtual roots. 
	
Dither values are:

	Value		Description
	-----		-----------
	Nearest		Nearest color matching w/o error correction
	FloydSteinberg	Floyd Steinberg Error Diffusion dithering
	Stucki		Stucki Error Diffusion dithering
	Sierra		Sierra Error Diffusion dithering
	JaJuNI		Jarvis, Judice & Ninke Error Diffusion dithering
	SteveArche	Stevenson & Arche Error Diffusion dithering
	Burkes		Burkes Error Diffusion dithering

Default ISAPI/NSAPI path is /2wbmp/, therefore 

	http://ensen/scripts/i2wbmp.dll/2wbmp?dither=stucki&file=/icons/basket.gif

same as example given.

	Change settings
	---------------

Registry:

	You can set some parameters in registry at
	HKEY_LOCAL_MACHINE\Software\ensen\i2wbmp\1.0\

Parameter	Type	Description		Default value
---------	----	-----------		-------------
DefDitherMode	String	default dithering 	nearest
			mode, next modes
			available:
			Nearest|FloydSteinberg|
			Stucki|Sierra|JaJuNI|
			SteveArche|Burkes

DefWBMP		Binary	default wbmp image 	empty
			up to 4016 bytes 
			long

\Virtual Roots	Folder	contains aliases in	empty
			addition to IIS 
			(PWS) provided

IIS and PWS web server stores their aliases in registry at:
	HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W3SVC\



	How to register
	---------------
You can register your copy of CVRT2WBMP for $19 in four different ways:

1. On-Line:
   http://www.regsoft.net/purchase.php3?productid=38958

2. FAX: 1-208-279-3837 or try Toll Free fax line at 1-800-886-6030 
   (UK customers can fax to (0870)132-2485.)
   Please provide information:
   Product ID : 38958 
   Product Name : CVRT2WBMP, a graphics tool for creating WBMP 
   Price, quantity, email, full name, billing address, address, phone,
   type of credit card, card number and expiration date.


3. Mail with a Check or Money Order:

   RegSoft.com Inc. PMB 201
   10820 Abbotts Bridge Rd Suite 220
   Duluth, GA 30097 
   
   Please indicate:
   Product ID: 38958 
   Product Name: CVRT2WBMP, a graphics tool for creating WBMP 
   Price, quantity, email, full name, billing address, address, phone,
   type of credit card, card number and expiration date.

4. Phone ordering: 1-877-REGSOFT (1-877-734-7638), international orders 
   please call 1-770-319-2718 

For more information please visit
http://www.regsoft.net/purchase.php3?productid=38958


	Contacts
	--------
I have been constantly improving editor through your feedback. I appreciate 
and encourage your feedback.  
Should you have any questions concerning this program, please contact:
mailto:andy@sitc.ru or mailto:ensen_andy@yahoo.com

--------------------------------------------------------------
i2wbmp Copyright © 2002 by Andrei Ivanov. All rights reserved.