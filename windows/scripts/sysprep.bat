net stop tiledatamodelsvc
if exist e:\unattend.xml (
  c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /unattend:e:\unattend.xml
) else (
  del /F \Windows\System32\Sysprep\unattend.xml
  c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /quiet
)