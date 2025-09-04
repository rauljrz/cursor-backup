@echo off
echo Instalando extensiones de CURSOR...
echo.
for /f %%i in (extensions\extensions.txt) do (
    echo Instalando: %%i
    cursor --install-extension "%%i"
)
echo.
echo Instalacion de extensiones completada.
pause
