@echo off
setlocal enabledelayedexpansion
title CURSOR Git Sync Tool

REM Configurar codificación de consola
chcp 65001 >nul 2>&1

REM Guardar directorio actual
set "ORIGINAL_DIR=%CD%"

echo ========================================
echo    CURSOR Git Sync Tool
echo ========================================
echo.
echo Repositorio: git@github.com:rauljrz/cursor-backup.git
echo Carpeta local: O:\My Drive\cursor_backup
echo.

REM Definir rutas
set "CURSOR_PATH=%APPDATA%\Cursor\User"
set "BACKUP_LOCAL=O:\My Drive\cursor_backup"
REM set "BACKUP_LOCAL=E:\cursor_backup"
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

REM Verificar si CURSOR está instalado
if not exist "%CURSOR_PATH%" (
    echo ERROR: No se encontro la configuracion de CURSOR
    echo Ruta esperada: %CURSOR_PATH%
    echo.
    echo Asegurate de que CURSOR este instalado y ejecutado al menos una vez.
    pause
    exit /b 1
)

echo [OK] Configuracion de CURSOR encontrada

REM Debug: Mostrar información del sistema
echo.
echo [DEBUG] Informacion del sistema:
echo - Usuario: %USERNAME%
echo - PC: %COMPUTERNAME%  
echo - Ruta CURSOR: %CURSOR_PATH%
echo - Verificando comando cursor...

REM Verificar comando cursor con información detallada
where cursor >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Comando 'cursor' encontrado en PATH
    
    REM Intentar obtener versión usando un script temporal
    set "TEMP_SCRIPT=%TEMP%\cursor_test_%RANDOM%.bat"
    echo cursor --version > "%TEMP_SCRIPT%"
    call "%TEMP_SCRIPT%" >nul 2>nul
    if !errorlevel! equ 0 (
        echo [OK] Comando cursor funciona correctamente
        set "CURSOR_WORKS=1"
    ) else (
        echo [AVISO] Comando cursor encontrado pero no responde correctamente
        set "CURSOR_WORKS=0"
    )
    if exist "%TEMP_SCRIPT%" del "%TEMP_SCRIPT%"
) else (
    echo [AVISO] Comando 'cursor' no encontrado en PATH
    echo [INFO] Se usaran metodos alternativos para detectar extensiones
    set "CURSOR_WORKS=0"
)

echo [OK] Git disponible
echo.

REM Crear/verificar directorio local si no existe
if not exist "%BACKUP_LOCAL%" (
    echo Creando carpeta de backup local...
    mkdir "%BACKUP_LOCAL%" >nul 2>nul
    if !errorlevel! neq 0 (
        echo ERROR: No se pudo crear la carpeta de backup
        echo Verifica permisos y que la ruta existe: %BACKUP_LOCAL%
        pause
        exit /b 1
    )
    echo [OK] Carpeta de backup creada
)

REM Cambiar al directorio de backup
cd /d "%BACKUP_LOCAL%"

REM Inicializar repositorio si no existe
if not exist ".git" (
    echo Inicializando repositorio Git local...
    git init >nul 2>nul
    git remote add origin "%REPO_URL%" >nul 2>nul
    
    REM Intentar hacer pull del repositorio remoto
    echo Sincronizando con repositorio remoto...
    git pull origin main >nul 2>nul
    if !errorlevel! neq 0 (
        echo AVISO: No se pudo sincronizar con el repositorio remoto
        echo El repositorio podria estar vacio o requerir configuracion SSH
        echo Continuando con backup local...
    )
    echo [OK] Repositorio Git inicializado
)

echo.
echo Copiando configuraciones de CURSOR...

REM Crear estructura de carpetas
mkdir "config" >nul 2>nul
mkdir "extensions" >nul 2>nul
mkdir "config\cli" >nul 2>nul

REM Copiar archivos principales de configuración
if exist "%CURSOR_PATH%\settings.json" (
    copy "%CURSOR_PATH%\settings.json" "config\" >nul
    echo [OK] settings.json copiado
) else (
    echo [AVISO] settings.json no encontrado
)

if exist "%CURSOR_PATH%\keybindings.json" (
    copy "%CURSOR_PATH%\keybindings.json" "config\" >nul
    echo [OK] keybindings.json copiado
) else (
    echo [AVISO] keybindings.json no encontrado
)

REM Copiar snippets si existen
if exist "%CURSOR_PATH%\snippets" (
    if exist "config\snippets" rmdir /s /q "config\snippets" >nul 2>nul
    xcopy "%CURSOR_PATH%\snippets" "config\snippets\" /e /i /q >nul 2>nul
    echo [OK] snippets copiados
) else (
    echo [AVISO] snippets no encontrados
)

REM Respaldar configuración CLI global
if exist "%USERPROFILE%\.cursor\cli-config.json" (
    copy "%USERPROFILE%\.cursor\cli-config.json" "config\cli\" >nul
    echo [OK] Configuración CLI global copiada
) else (
    echo [INFO] Configuración CLI global no encontrada
)

mkdir "config\globalStorage" >nul 2>nul
copy "%CURSOR_PATH%\globalStorage\storage.json" "config\globalStorage\" >nul 2>nul
echo [OK] Estado global (storage.json) copiado

@REM REM Respaldar estado global (solo storage.json)
@REM if exist "%CURSOR_PATH%\globalStorage\storage.json" (
@REM     echo [INFO] Archivo storage.json encontrado, copiando...
    
@REM     REM Crear directorio de destino con manejo de errores
@REM     if not exist "config\globalStorage\" (
@REM         md "config\globalStorage" 2>nul
@REM         if !errorlevel! neq 0 (
@REM             echo [ERROR] No se pudo crear el directorio config\globalStorage
@REM             mkdir "config" 2>nul
@REM             mkdir "config\globalStorage" 2>nul
@REM         ) else (
@REM             echo [OK] Directorio config\globalStorage creado
@REM         )
@REM     )
    
@REM     REM Copiar el archivo
@REM     copy "%CURSOR_PATH%\globalStorage\storage.json" "config\globalStorage\" >nul 2>nul
@REM     if !errorlevel! equ 0 (
@REM         echo [OK] Estado global (storage.json) copiado
@REM     ) else (
@REM         echo [ERROR] No se pudo copiar storage.json
@REM     )
@REM ) else (
@REM     echo [INFO] Archivo storage.json no encontrado en %CURSOR_PATH%\globalStorage
@REM )


@REM REM Verificar si 7-Zip está instalado
@REM where 7z >nul 2>nul
@REM set "USE_7Z=0"
@REM if %errorlevel% equ 0 (
@REM     set "USE_7Z=1"
@REM     echo [INFO] 7-Zip encontrado, se usará para comprimir archivos
@REM ) else (
@REM     echo [AVISO] 7-Zip no encontrado, se usará copia normal
@REM     echo [INFO] Para comprimir archivos, instala 7-Zip desde https://www.7-zip.org/
@REM )

REM Respaldar historial
@REM if exist "%CURSOR_PATH%\History" (
@REM     echo [INFO] Historial encontrado...
@REM     if "!USE_7Z!" == "1" (
@REM         echo [INFO] Comprimiendo historial con 7-Zip...
@REM         if exist "config\History.7z" del "config\History.7z" >nul 2>nul
@REM         7z a -mx=9 "config\History.7z" "%CURSOR_PATH%\History\*" >nul 2>nul
@REM         echo [OK] Historial comprimido en History.7z
@REM     ) else (
@REM         if exist "config\History" rmdir /s /q "config\History" >nul 2>nul
@REM         echo [INFO] Copiando historial...
@REM         xcopy "%CURSOR_PATH%\History" "config\History\" /e /i /q >nul 2>nul
@REM         echo [OK] Historial copiado
@REM     )
@REM ) else (
@REM     echo [INFO] Historial no encontrado
@REM )

REM Respaldar workspaceStorage (opcional - puede ser grande)
@REM set /p "BACKUP_WORKSPACE=¿Respaldar workspaceStorage? (puede ser grande) (s/n): "
@REM if /i "%BACKUP_WORKSPACE%" equ "s" (
@REM     if exist "%CURSOR_PATH%\workspaceStorage" (
@REM         echo [INFO] Respaldando workspaceStorage (puede tardar)...
@REM         if "!USE_7Z!" == "1" (
@REM             echo [INFO] Comprimiendo workspaceStorage con 7-Zip...
@REM             if exist "config\workspaceStorage.7z" del "config\workspaceStorage.7z" >nul 2>nul
@REM             7z a -mx=9 "config\workspaceStorage.7z" "%CURSOR_PATH%\workspaceStorage\*" >nul 2>nul
@REM             echo [OK] workspaceStorage comprimido en workspaceStorage.7z
@REM         ) else (
@REM             if exist "config\workspaceStorage" rmdir /s /q "config\workspaceStorage" >nul 2>nul
@REM             xcopy "%CURSOR_PATH%\workspaceStorage" "config\workspaceStorage\" /e /i /q >nul 2>nul
@REM             echo [OK] workspaceStorage copiado
@REM         )
@REM     ) else (
@REM         echo [INFO] workspaceStorage no encontrado
@REM     )
@REM )

echo.
echo Generando lista de extensiones...

REM Generar lista de extensiones instaladas
if defined CURSOR_WORKS (
    if "!CURSOR_WORKS!" == "1" (
        REM Usar script temporal para evitar problemas con el comando directo
        set "EXT_SCRIPT=%TEMP%\cursor_ext_%RANDOM%.bat"
        echo cursor --list-extensions > "!EXT_SCRIPT!"
        call "!EXT_SCRIPT!" > extensions\extensions.txt 2>nul
        if !errorlevel! equ 0 (
            echo [OK] Lista de extensiones generada
            
            REM Mostrar extensiones encontradas
            echo.
            echo Extensiones instaladas:
            type extensions\extensions.txt
            echo.
        ) else (
            echo [AVISO] No se pudo generar la lista de extensiones
            echo Creando archivo de extensiones vacío...
            rem echo # Extensiones no detectadas > extensions\extensions.txt
        )
        if exist "!EXT_SCRIPT!" del "!EXT_SCRIPT!"
    ) else (
        echo [AVISO] Cursor no responde correctamente, no se pueden listar extensiones
        echo Creando archivo de extensiones vacío...
        echo # Extensiones no detectadas > extensions\extensions.txt
    )
) else (
    echo [AVISO] No se pudo generar la lista de extensiones
    echo Creando archivo de extensiones vacío...
    echo # Extensiones no detectadas > extensions\extensions.txt
)

echo.
echo Creando archivo README con instrucciones...

REM Crear README.md con información del backup
REM Eliminar README.md existente para recrearlo
if exist "README.md" (
    del "README.md" >nul 2>nul
    echo [OK] README.md anterior eliminado
)

(
echo # CURSOR Configuration Backup
echo.
echo **Fecha de backup:** %date% %time%
echo **Usuario:** %USERNAME%
echo **PC:** %COMPUTERNAME%
echo.
echo ## Archivos incluidos:
echo.
echo - `config/settings.json` - Configuraciones generales de CURSOR
echo - `config/keybindings.json` - Atajos de teclado personalizados
echo - `config/snippets/` - Fragmentos de codigo personalizados
echo - `config/cli/cli-config.json` - Configuracion global de CLI
echo - `config/globalStorage/storage.json` - Estado global de extensiones
echo - `config/History/` - Historial de busquedas y comandos
echo - `config/workspaceStorage/` - Configuraciones de workspaces (opcional^)
echo - `extensions/extensions.txt` - Lista de extensiones instaladas
echo.
echo ## Como restaurar:
echo.
echo ### 1. Copiar configuraciones:
echo ```cmd
echo copy config\settings.json "%%%%APPDATA%%%%\Cursor\User\"
echo copy config\keybindings.json "%%%%APPDATA%%%%\Cursor\User\"
echo xcopy config\snippets "%%%%APPDATA%%%%\Cursor\User\snippets\" /e /i
echo copy config\cli\cli-config.json "%%%%USERPROFILE%%%%\.cursor\"
echo mkdir "%%%%APPDATA%%%%\Cursor\User\globalStorage" ^^^>nul 2^^^>nul
echo copy config\globalStorage\storage.json "%%%%APPDATA%%%%\Cursor\User\globalStorage\"
echo xcopy config\History "%%%%APPDATA%%%%\Cursor\User\History\" /e /i
echo REM Opcional: xcopy config\workspaceStorage "%%%%APPDATA%%%%\Cursor\User\workspaceStorage\" /e /i
echo ```
echo.
echo ### 2. Instalar extensiones:
echo ```cmd
echo for /f %%%%i in ^^^(extensions\extensions.txt^^^) do cursor --install-extension "%%%%i"
echo ```
echo.
echo ---
echo **Generado automaticamente por CURSOR Git Sync Tool**
echo.
echo rauljrz[at]factorcodelab.com
) > README.md

echo [OK] README.md creado
echo.

REM Crear archivo de instalacion automatica de extensiones
if exist "extensions\extensions.txt" (
    (
    echo @echo off
    echo echo Instalando extensiones de CURSOR...
    echo echo.
    echo for /f %%%%i in ^(extensions\extensions.txt^) do ^(
    echo     echo Instalando: %%%%i
    echo     cursor --install-extension "%%%%i"
    echo ^)
    echo echo.
    echo echo Instalacion de extensiones completada.
    echo pause
    ) > install-extensions.bat
    
    echo [OK] Script de instalacion de extensiones creado
)

echo.
echo Realizando commit y push...

REM Asegurar que estamos en el directorio del repositorio
cd /d "%BACKUP_LOCAL%"
echo [INFO] Ubicacion actual: %CD%

REM Añadir archivos al repositorio explícitamente
echo [INFO] Añadiendo archivos al repositorio...
git add README.md >nul 2>nul
git add config/* >nul 2>nul
git add extensions/* >nul 2>nul
git add install-extensions.bat >nul 2>nul
git add . >nul 2>nul

REM Verificar si hay cambios
git diff --cached --quiet >nul 2>nul
if %errorlevel% equ 0 (
    echo [INFO] No hay cambios nuevos para sincronizar
) else (
    REM Hacer commit
    set "COMMIT_MSG=CURSOR backup - %date% %time%"
    echo [INFO] Realizando commit con mensaje: !COMMIT_MSG!
    git commit -m "!COMMIT_MSG!" >nul 2>nul
    
    if !errorlevel! equ 0 (
        echo [OK] Commit realizado exitosamente
        
        REM Hacer push al repositorio remoto
        echo [INFO] Enviando cambios al repositorio remoto...
        git push origin master
        if !errorlevel! equ 0 (
            echo [OK] Configuracion sincronizada con GitHub exitosamente
        ) else (
            echo [AVISO] No se pudo hacer push al repositorio remoto
            echo [INFO] Mostrando estado del repositorio:
            git status
            echo.
            echo [INFO] Posibles soluciones:
            echo 1. Verifica tu configuracion SSH y conexion a GitHub
            echo 2. Ejecuta 'git push origin master' manualmente
            echo 3. Comprueba que la rama 'master' exista en el repositorio remoto
            echo.
            echo Los archivos estan guardados localmente en:
            echo %BACKUP_LOCAL%
        )
    ) else (
        echo [ERROR] No se pudo hacer commit
        echo [INFO] Mostrando estado del repositorio:
        git status
        echo.
        echo [INFO] Posibles soluciones:
        echo 1. Verifica que git esté configurado correctamente
        echo 2. Configura tu nombre y correo con:
        echo    git config --global user.name "Tu Nombre"
        echo    git config --global user.email "tu.email@example.com"
    )
)

echo.
echo ========================================
echo [OK] SINCRONIZACION COMPLETADA
echo ========================================
echo.
echo Archivos guardados en: %BACKUP_LOCAL%
echo.
echo ARCHIVOS RESPALDADOS:
if exist "config\settings.json" echo - settings.json
if exist "config\keybindings.json" echo - keybindings.json  
if exist "config\snippets" echo - snippets personalizados
if exist "config\cli\cli-config.json" echo - configuración CLI global
if exist "config\globalStorage\storage.json" echo - estado global de extensiones (storage.json)
if exist "config\History" echo - historial de búsquedas y comandos
if exist "config\workspaceStorage" echo - configuraciones de workspaces
if exist "extensions\extensions.txt" echo - lista de extensiones
echo - README.md con instrucciones
echo - install-extensions.bat para instalacion automatica
echo.
echo PROXIMOS PASOS:
echo 1. Verifica que los archivos esten en GitHub
echo 2. En otras PCs, clona el repositorio y usa los scripts
echo 3. Ejecuta este script regularmente para mantener sincronizado
echo.

REM Regresar a la carpeta original
cd /d "%ORIGINAL_DIR%"
echo [INFO] Ubicacion final: %CD%
echo.

echo Presiona cualquier tecla para salir...
pause >nul