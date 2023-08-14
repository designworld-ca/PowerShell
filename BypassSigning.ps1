# Running a .ps1 PowerShell script will sometimes result in the following message:

# “<script>.ps1 is not digitally signed.  The script will not execute on the system.”
# works until the next reboot
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
