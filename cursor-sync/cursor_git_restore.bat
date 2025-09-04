@echo off
setlocal enabledelayedexpansion
title CURSOR Git Restore Tool

REM Configurar codificación de consola
chcp 65001 >nul 2>&1

echo ========================================
echo    CURSOR Git Restore Tool
echo ========================================
echo.
echo Repositorio: git@github.com:rauljrz/cursor-backup.git
echo Carpeta local: O:\My Drive\Life_Management\cursor_backup
echo.

REM Definir rutas
set "CURSOR_PATH=%APPDATA%\Cursor\User"
set "BACKUP_LOCAL=O:\My Drive\Life_Management\cursor_backup"
set "REPO_URL=git@github.com:rauljrz/cursor-backup.git"

REM Verificar si Git está instalado
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Git no esta instalado o no esta en el PATH
    echo Instala Git desde: https://git-scm.com/
    echo.
    pause
    exit /b 1
)

echo [OK] Git disponible
echo.

REM Verificar/crear directorio de backup local
if not exist "%BACKUP_LOCAL%" (
    echo Clonando repositorio desde GitHub...
    
    REM Crear directorio padre si no existe
    mkdir "O:\My Drive\Life_Management" >nul 2>nul
    
    REM Clonar repositorio
    cd /d "O:\My Drive\Life_Management"
    git clone "%REPO_URL%" "cursor_backup" >nul 2>nul
    
    if !errorlevel! neq 0 (
        echo ERROR: No se pudo clonar el repositorio
        echo Verifica tu configuracion SSH y conexion a GitHub
        echo URL: %REPO_URL%
        pause
        exit /b 1
    )
    
    echo [OK] Repositorio clonado exitosamente
) else (
    echo Actualizando repositorio local...
    cd /d "%BACKUP_LOCAL%"
    
    REM Hacer pull de los últimos cambios
    git pull origin master >nul 2>nul
    if !errorlevel! neq 0 (
        echo [AVISO] No se pudo actualizar desde el repositorio remoto
        echo Continuando con archivos locales...
    ) else (
        echo [OK] Repositorio actualizado
    )
)

cd /d "%BACKUP_LOCAL%"

REM Verificar que existen los archivos de configuración
if not exist "config" (
    echo ERROR: No se encontro la carpeta 'config' en el backup
    echo Verifica que el repositorio contenga los archivos de configuracion
    pause
    exit /b 1
)

echo.
echo ========================================
echo IMPORTANTE: Este proceso restaurara
echo tu configuracion de CURSOR
echo ========================================
echo.

REM Mostrar información del backup
if exist "README.md" (
    echo Informacion del backup:
    findstr /b "**Fecha" README.md 2>nul
    findstr /b "**Usuario" README.md 2>nul
    findstr /b "**PC" README.md 2>nul
    echo.
)

set /p "CONFIRM=¿Deseas continuar con la restauracion? (s/n): "
if /i "%CONFIRM%" neq "s" (
    echo Operacion cancelada.
    pause
    exit /b 0
)

echo.
echo Creando backup de configuracion actual...

REM Crear backup de configuración actual
set "BACKUP_CURRENT=%CURSOR_PATH%\backup_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "BACKUP_CURRENT=%BACKUP_CURRENT: =0%"

if exist "%CURSOR_PATH%\settings.json" (
    if not exist "%CURSOR_PATH%\backups" mkdir "%CURSOR_PATH%\backups" >nul 2>nul
    copy "%CURSOR_PATH%\settings.json" "%CURSOR_PATH%\backups\settings_backup_%date:~6,4%%date:~3,2%%date:~0,2%.json" >nul 2>nul
    echo [OK] Configuracion actual respaldada
)

echo.
echo Restaurando configuraciones...

REM Crear directorio User si no existe
if not exist "%CURSOR_PATH%" mkdir "%CURSOR_PATH%" >nul 2>nul

REM Restaurar settings.json
if exist "config\settings.json" (
    copy "config\settings.json" "%CURSOR_PATH%\" >nul
    echo [OK] settings.json restaurado
) else (
    echo [AVISO] settings.json no encontrado en el backup
)

REM Restaurar keybindings.json
if exist "config\keybindings.json" (
    copy "config\keybindings.json" "%CURSOR_PATH%\" >nul
    echo [OK] keybindings.json restaurado
) else (
    echo [AVISO] keybindings.json no encontrado en el backup
)

REM Restaurar snippets
if exist "config\snippets" (
    if exist "%CURSOR_PATH%\snippets" rmdir /s /q "%CURSOR_PATH%\snippets" >nul 2>nul
    xcopy "config\snippets" "%CURSOR_PATH%\snippets\" /e /i /q >nul
    echo [OK] snippets restaurados
) else (
    echo [AVISO] snippets no encontrados en el backup
)

REM Restaurar configuración CLI global
if exist "config\cli\cli-config.json" (
    if not exist "%USERPROFILE%\.cursor" mkdir "%USERPROFILE%\.cursor" >nul 2>nul
    copy "config\cli\cli-config.json" "%USERPROFILE%\.cursor\" >nul
    echo [OK] Configuración CLI global restaurada
) else (
    echo [AVISO] Configuración CLI global no encontrada en el backup
)

REM Restaurar estado global (solo storage.json)
if exist "config\globalStorage\storage.json" (
    echo [INFO] Archivo storage.json encontrado en el backup, restaurando...
    
    REM Crear directorio de destino con manejo de errores
    if not exist "%CURSOR_PATH%\globalStorage\" (
        md "%CURSOR_PATH%\globalStorage" 2>nul
        if !errorlevel! neq 0 (
            echo [ERROR] No se pudo crear el directorio %CURSOR_PATH%\globalStorage
            mkdir "%CURSOR_PATH%\globalStorage" 2>nul
        ) else (
            echo [OK] Directorio globalStorage creado
        )
    )
    
    REM Copiar el archivo
    copy "config\globalStorage\storage.json" "%CURSOR_PATH%\globalStorage\" >nul 2>nul
    if !errorlevel! equ 0 (
        echo [OK] Estado global (storage.json) restaurado
    ) else (
        echo [ERROR] No se pudo restaurar storage.json
    )
) else (
    echo [AVISO] Archivo storage.json no encontrado en el backup
)

REM Verificar si 7-Zip está instalado
where 7z >nul 2>nul
set "USE_7Z=0"
if %errorlevel% equ 0 (
    set "USE_7Z=1"
    echo [INFO] 7-Zip encontrado, se usará para descomprimir archivos
) else (
    echo [AVISO] 7-Zip no encontrado
    echo [INFO] Para descomprimir archivos, instala 7-Zip desde https://www.7-zip.org/
)

REM Restaurar historial
if exist "config\History.7z" (
    if "!USE_7Z!" == "1" (
        echo [INFO] Descomprimiendo historial...
        if exist "%CURSOR_PATH%\History" rmdir /s /q "%CURSOR_PATH%\History" >nul 2>nul
        7z x -y -o"%CURSOR_PATH%" "config\History.7z" >nul 2>nul
        echo [OK] Historial restaurado desde archivo comprimido
    ) else (
        echo [AVISO] Archivo comprimido de historial encontrado pero 7-Zip no está instalado
        echo [INFO] Instala 7-Zip para restaurar este componente
    )
) else if exist "config\History" (
    echo [INFO] Restaurando historial (sin comprimir)...
    if exist "%CURSOR_PATH%\History" rmdir /s /q "%CURSOR_PATH%\History" >nul 2>nul
    xcopy "config\History" "%CURSOR_PATH%\History\" /e /i /q >nul
    echo [OK] Historial restaurado
) else (
    echo [AVISO] Historial no encontrado en el backup
)

REM Restaurar workspaceStorage (opcional)
set "WORKSPACE_FOUND=0"
if exist "config\workspaceStorage.7z" set "WORKSPACE_FOUND=1"
if exist "config\workspaceStorage" set "WORKSPACE_FOUND=1"

if "!WORKSPACE_FOUND!" == "1" (
    set /p "RESTORE_WORKSPACE=¿Restaurar workspaceStorage? (puede sobrescribir configuraciones actuales) (s/n): "
    if /i "!RESTORE_WORKSPACE!" equ "s" (
        if exist "config\workspaceStorage.7z" (
            if "!USE_7Z!" == "1" (
                echo [INFO] Descomprimiendo workspaceStorage (puede tardar)...
                if exist "%CURSOR_PATH%\workspaceStorage" rmdir /s /q "%CURSOR_PATH%\workspaceStorage" >nul 2>nul
                7z x -y -o"%CURSOR_PATH%" "config\workspaceStorage.7z" >nul 2>nul
                echo [OK] workspaceStorage restaurado desde archivo comprimido
            ) else (
                echo [AVISO] Archivo comprimido de workspaceStorage encontrado pero 7-Zip no está instalado
                echo [INFO] Instala 7-Zip para restaurar este componente
            )
        ) else if exist "config\workspaceStorage" (
            echo [INFO] Restaurando workspaceStorage (sin comprimir)...
            if exist "%CURSOR_PATH%\workspaceStorage" rmdir /s /q "%CURSOR_PATH%\workspaceStorage" >nul 2>nul
            xcopy "config\workspaceStorage" "%CURSOR_PATH%\workspaceStorage\" /e /i /q >nul
            echo [OK] workspaceStorage restaurado
        )
    ) else (
        echo [INFO] Restauración de workspaceStorage omitida por el usuario
    )
) else (
    echo [AVISO] workspaceStorage no encontrado en el backup
)

echo.
echo Procesando extensiones...

REM Mostrar extensiones disponibles para instalar
if exist "extensions\extensions.txt" (
    echo.
    echo ========================================
    echo EXTENSIONES A INSTALAR:
    echo ========================================
    type extensions\extensions.txt
    echo.
    
    set /p "INSTALL_EXT=¿Instalar extensiones automaticamente? (s/n): "
    if /i "!INSTALL_EXT!" equ "s" (
        echo.
        echo Instalando extensiones...
        
        for /f "delims=" %%i in (extensions\extensions.txt) do (
            echo Instalando: %%i
            cursor --install-extension "%%i" >nul 2>nul
            if !errorlevel! equ 0 (
                echo [OK] %%i instalado
            ) else (
                echo [ERROR] No se pudo instalar %%i
            )
        )
        echo.
        echo [OK] Proceso de instalacion de extensiones completado
    ) else (
        echo.
        echo Puedes instalar las extensiones manualmente o ejecutar:
        echo install-extensions.bat
    )
) else (
    echo [AVISO] No se encontro lista de extensiones
)

echo.
echo ========================================
echo [OK] RESTAURACION COMPLETADA
echo ========================================
echo.
echo Tu configuracion de CURSOR ha sido restaurada exitosamente.
echo.
echo ARCHIVOS RESTAURADOS:
if exist "%CURSOR_PATH%\settings.json" echo - settings.json
if exist "%CURSOR_PATH%\keybindings.json" echo - keybindings.json
if exist "%CURSOR_PATH%\snippets" echo - snippets personalizados
if exist "%USERPROFILE%\.cursor\cli-config.json" echo - configuración CLI global
if exist "%CURSOR_PATH%\globalStorage\storage.json" echo - estado global de extensiones (storage.json)
if exist "%CURSOR_PATH%\History" echo - historial de búsquedas y comandos (restaurado)
if exist "%CURSOR_PATH%\workspaceStorage" echo - configuraciones de workspaces (restaurado)
echo.
echo PROXIMOS PASOS:
echo 1. Reinicia CURSOR para aplicar la configuracion
echo 2. Verifica que todos tus ajustes esten correctos
echo 3. Si faltan extensiones, ejecuta install-extensions.bat
echo.
echo BACKUP ACTUAL: %CURSOR_PATH%\backups\
echo.

echo Presiona cualquier tecla para salir...
pause >nul