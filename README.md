# LPT Driver and Demos #

This repo contains material for using the inpoutx64.dll to send markers through a PC's parallel (LPT) port.

The inpoutx64 library is a self-installing DLL that must be called for the first time with admin privileges. Subsequent calls can be done without any special privileges, but the DLL must always be on the path of the environment calling it.

The install_inpoutx64.py script is a helper script that copies the inpout\inpoutx64.dll to the local C:\Windows\System32 folder, which is usually on the standard path of most environments. It also loads the inpoutx64 DLL, which registers it with the operating system. As such, the install_inpoutx64.py script must be run with admin privileges in 64-bit python.

The \PowerShell_Remote_Installer\remote_install.ps1 script is a helper script that can be used to install the driver and demos on remote PCs using remote PowerShell sessions. To use the script, admin rights are necessary on each remote PC in question. The script requires that Git and 64-bit Python 3 be installed on the remote PC. It will use git to clone this repo on the remote PC, then run the install_inpoutx64.py in admin mode to install the driver.

The demo folders contain various demos on using the inpoutx64.dll to send markers.
