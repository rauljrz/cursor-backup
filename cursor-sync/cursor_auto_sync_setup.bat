@echo off
setlocal enabledelayedexpansion
title CURSOR Auto-Sync Setup

REM Configurar codificación de consola
chcp 65001 >nul 2>&1

echo ========================================
echo    CURSOR Auto-Sync Setup Tool
echo ========================================
echo.
echo Este script configurara la sincronizacion automatica
echo de tu configuracion de CURSOR siguiendo la metodologia
echo de Dre Dyson (dredyson.com)
echo.

REM Definir rutas
set "SCRIPT_DIR=%~dp0"
set "TASK_NAME=CursorAutoSync"
set "BACKUP_SCRIPT=%SCRIPT_DIR%cursor_git_sync.bat"

echo Verificando prerequisitos...

REM Verificar que existe el script de backup
if not exist "%BACKUP_SCRIPT%" (
    echo ERROR: No se encontro cursor_git_sync.bat
    echo Asegurate de que ambos scripts esten en la misma carpeta
    pause
    exit /b 1
)

echo [OK] Script de backup encontrado
echo.

echo ========================================
echo OPCIONES DE SINCRONIZACION AUTOMATICA
echo ========================================
echo.
echo 1. Configurar tarea diaria (recomendado)
echo 2. Configurar tarea semanal  
echo 3. Configurar tarea al iniciar sesion
echo 4. Ver estado de tareas existentes
echo 5. Eliminar tarea automatica
echo 6. Solo crear script rapido (sin programar)
echo.

set /p "OPTION=Selecciona una opcion (1-6): "

if "%OPTION%"=="1" goto :daily
if "%OPTION%"=="2" goto :weekly  
if "%OPTION%"=="3" goto :startup
if "%OPTION%"=="4" goto :status
if "%OPTION%"=="5" goto :remove
if "%OPTION%"=="6" goto :quickscript
goto :invalid

:daily
set "SCHEDULE=/sc daily /st 09:00"
set "DESCRIPTION=Sincronizacion diaria de configuracion CURSOR a las 9:00 AM"
goto :create_task

:weekly
set "SCHEDULE=/sc weekly /d MON /st 09:00"
set "DESCRIPTION=Sincronizacion semanal de configuracion CURSOR los Lunes a las 9:00 AM"
goto :create_task

:startup
set "SCHEDULE=/sc onlogon"
set "DESCRIPTION=Sincronizacion de configuracion CURSOR al iniciar sesion"
goto :create_task

:create_task
echo.
echo Creando tarea programada...
echo Nombre: %TASK_NAME%
echo Descripcion: %DESCRIPTION%
echo Script: %BACKUP_SCRIPT%
echo.

REM Crear tarea programada
schtasks /create /tn "%TASK_NAME%" /tr "\"%BACKUP_SCRIPT%\"" %SCHEDULE% /f /rl highest >nul 2>nul

if %errorlevel% equ 0 (
    echo [OK] Tarea programada creada exitosamente
    echo.
    echo CONFIGURACION COMPLETADA:
    echo - La sincronizacion se ejecutara automaticamente
    echo - Puedes ver las tareas en "Programador de tareas"
    echo - Para ejecutar manualmente: schtasks /run /tn "%TASK_NAME%"
) else (
    echo [ERROR] No se pudo crear la tarea programada
    echo Verifica que tengas permisos de administrador
)
goto :end

:status
echo.
echo Estado de tareas de CURSOR:
schtasks /query /tn "%TASK_NAME%" 2>nul
if %errorlevel% neq 0 (
    echo No hay tareas automaticas configuradas para CURSOR
)
goto :end

:remove
echo.
echo Eliminando tarea automatica...
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Tarea automatica eliminada
) else (
    echo [AVISO] No se encontro tarea automatica para eliminar
)
goto :end

:quickscript
echo.
echo Creando script de sincronizacion rapida...

REM Crear script rapido en el escritorio
set "DESKTOP=%USERPROFILE%\Desktop"
set "QUICK_SCRIPT=%DESKTOP%\Sync_CURSOR.bat"

(
echo @echo off
echo title Sincronizacion Rapida CURSOR
echo echo Sincronizando configuracion de CURSOR...
echo call "%BACKUP_SCRIPT%"
echo echo.
echo echo Sincronizacion completada!
echo timeout /t 3 >nul
) > "%QUICK_SCRIPT%"

if exist "%QUICK_SCRIPT%" (
    echo [OK] Script rapido creado en el escritorio
    echo Archivo: Sync_CURSOR.bat
    echo.
    echo Haz doble clic en este archivo para sincronizar rapidamente
) else (
    echo [ERROR] No se pudo crear el script rapido
)
goto :end

:invalid
echo Opcion invalida. Por favor selecciona 1-6.
timeout /t 2 >nul
goto :start

:end
echo.
echo ========================================
echo CONFIGURACION ADICIONAL RECOMENDADA
echo ========================================
echo.
echo 1. BACKUP AUTOMATICO:
if "%OPTION%"=="1" echo    [✓] Configurado - sincronizacion diaria
if "%OPTION%"=="2" echo    [✓] Configurado - sincronizacion semanal  
if "%OPTION%"=="3" echo    [✓] Configurado - sincronizacion al inicio
if "%OPTION%"=="4" echo    [ ] Ver estado arriba
if "%OPTION%"=="5" echo    [✓] Tarea eliminada
if "%OPTION%"=="6" echo    [✓] Script rapido creado
echo.
echo 2. MONITOREO EN TIEMPO REAL (opcional):
echo    - Instala un monitor de archivos como FileWatcher
echo    - Configura para observar: %%APPDATA%%\Cursor\User\
echo    - Ejecuta sync automatico cuando detecte cambios
echo.
echo 3. RESPALDO ADICIONAL:
echo    - Considera sincronizar tambien con Dropbox/OneDrive
echo    - Mantén copias locales en otra unidad
echo.
echo 4. RESTAURACION RAPIDA:
echo    - Usa cursor_git_restore.bat en nuevos equipos
echo    - Mantén los scripts sincronizados en todos tus dispositivos
echo.
echo COMANDOS UTILES:
echo - Ejecutar sync manual: "%BACKUP_SCRIPT%"
echo - Ver tareas programadas: schtasks /query /tn "%TASK_NAME%"
echo - Ejecutar tarea ahora: schtasks /run /tn "%TASK_NAME%"
echo.

REM Crear archivo de configuración con información
set "CONFIG_FILE=%SCRIPT_DIR%sync_config.txt"
(
echo CURSOR Auto-Sync Configuration
echo ==============================
echo Created: %date% %time%
echo User: %USERNAME%
echo Computer: %COMPUTERNAME%
echo.
echo Backup Script: %BACKUP_SCRIPT%
echo Task Name: %TASK_NAME%
echo Repository: git@github.com:rauljrz/cursor-backup.git
echo Local Path: O:\My Drive\cursor_backup
echo.
echo Schedule: %DESCRIPTION%
echo.
echo Files monitored:
echo - settings.json
echo - keybindings.json  
echo - snippets/
echo - extensions list
echo.
) > "%CONFIG_FILE%"

if exist "%CONFIG_FILE%" (
    echo [INFO] Configuracion guardada en: sync_config.txt
)

echo.
echo Presiona cualquier tecla para salir...
pause >nul