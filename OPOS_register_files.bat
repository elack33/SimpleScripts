::batch file to re register all OPOS*.ocx files after installing Epson OPOS drivers
::run this instead of reinstalling MS RMS
Regsvr32 /s C:\Windows\SysWOW64\OPOSBumpbar.ocx
Regsvr32 /s C:\Windows\SysWOW64\OPOSCashDrawer.ocx
Regsvr32 /s C:\Windows\SysWOW64\OPOSLineDisplay.ocx
Regsvr32 /s C:\Windows\SysWOW64\OPOSMICR.ocx
Regsvr32 /s C:\Windows\SysWOW64\OPOSMSR.ocx
Regsvr32 /s C:\Windows\SysWOW64\OPOSPinPad.ocx
Regsvr32 /s C:\Windows\SysWOW64\OPOSPOSPrinter.ocx
Regsvr32 /s C:\Windows\SysWOW64\OPOSScale.ocx
Regsvr32 /s C:\Windows\SysWOW64\OPOSScanner.ocx
Regsvr32 /s C:\Windows\SysWOW64\OPOSSigCap.ocx