@echo off
setlocal enabledelayedexpansion
title CURSOR Diagnostic Tool

REM Configurar codificación de consola
chcp 65001 >nul 2>&1

echo ========================================
echo    CURSOR Diagnostic Tool
echo ========================================
echo.
echo Este script diagnostica problemas comunes
echo con la sincronizacion de CURSOR
echo.

echo [1/10] Verificando rutas de CURSOR...
set "CURSOR_PATH=%APPDATA%\Cursor\User"
echo - Ruta configuracion: %CURSOR_PATH%

if exist "%CURSOR_PATH%" (
    echo [OK] Directorio de configuracion existe
    
    REM Verificar archivos de configuración
    if exist "%CURSOR_PATH%\settings.json" (
        echo [OK] settings.json encontrado
        for %%i in ("%CURSOR_PATH%\settings.json") do echo    Tamaño: %%~zi bytes
    ) else (
        echo [AVISO] settings.json no encontrado
    )
    
    if exist "%CURSOR_PATH%\keybindings.json" (
        echo [OK] keybindings.json encontrado
    ) else (
        echo [INFO] keybindings.json no existe ^(normal si no has personalizado atajos^)
    )
    
    if exist "%CURSOR_PATH%\snippets" (
        echo [OK] Carpeta snippets encontrada
    ) else (
        echo [INFO] Carpeta snippets no existe ^(normal si no tienes snippets personalizados^)
    )
) else (
    echo [ERROR] Directorio de configuracion no existe
    echo CURSOR no parece estar instalado o no se ha ejecutado nunca
)

echo.
echo [2/10] Verificando instalacion de CURSOR...

REM Buscar ejecutable de CURSOR en ubicaciones comunes
set "CURSOR_FOUND=0"
set "CURSOR_PATHS[0]=%LOCALAPPDATA%\Programs\Cursor\Cursor.exe"
set "CURSOR_PATHS[1]=%PROGRAMFILES%\Cursor\Cursor.exe"
set "CURSOR_PATHS[2]=%PROGRAMFILES(X86)%\Cursor\Cursor.exe"

for /l %%i in (0,1,2) do (
    if exist "!CURSOR_PATHS[%%i]!" (
        echo [OK] CURSOR encontrado en: !CURSOR_PATHS[%%i]!
        set "CURSOR_FOUND=1"
        
        REM Intentar obtener información del ejecutable
        for %%j in ("!CURSOR_PATHS[%%i]!") do echo    Tamaño: %%~zj bytes
        for %%j in ("!CURSOR_PATHS[%%i]!") do echo    Fecha: %%~tj
    )
)

if %CURSOR_FOUND% equ 0 (
    echo [AVISO] No se encontro el ejecutable de CURSOR en ubicaciones estandar
)

echo.
echo [3/10] Verificando comando 'cursor' en PATH...

where cursor >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Comando 'cursor' encontrado en PATH
    
    for /f "tokens=*" %%i in ('where cursor 2^>nul') do (
        echo    Ubicacion: %%i
    )
    
    REM Probar comando de versión con timeout
    echo    Probando cursor --version...
    
    REM Crear script temporal para probar con timeout
    set "TEMP_SCRIPT=cursor_test.bat"
    echo - Nombre del Script: !TEMP_SCRIPT!
    echo cursor --version > "!TEMP_SCRIPT!"
    
    REM Ejecutar script temporal
    call "%TEMP_SCRIPT%" >nul 2>&1
    
    if !errorlevel! equ 0 (
        echo [OK] Comando cursor --version funciona
    ) else (
        echo [AVISO] Comando cursor --version no responde o toma demasiado tiempo
    )
    
    REM Limpiar script temporal
    if exist "%TEMP_SCRIPT%" del "%TEMP_SCRIPT%"
    
) else (
    echo [AVISO] Comando 'cursor' no encontrado en PATH
    echo.
    echo SOLUCION: Agregar CURSOR al PATH del sistema
    echo 1. Busca la carpeta de instalacion de CURSOR
    echo 2. Agregala al PATH en Variables de Entorno
    echo 3. O crea un enlace simbolico en System32
)

echo.
echo [4/10] Verificando Git...

where git >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Git encontrado
    git --version 2>nul
) else (
    echo [ERROR] Git no encontrado
    echo SOLUCION: Instalar Git desde https://git-scm.com/
)

echo.
echo [5/10] Verificando carpetas de extensiones...

REM Buscar carpetas de extensiones en ubicaciones posibles
set "EXT_FOUND=0"
set "EXT_PATHS[0]=%USERPROFILE%\.cursor\extensions"
set "EXT_PATHS[1]=%APPDATA%\Cursor\extensions"  
set "EXT_PATHS[2]=%LOCALAPPDATA%\Cursor\extensions"

for /l %%i in (0,1,2) do (
    if exist "!EXT_PATHS[%%i]!" (
        echo [OK] Carpeta extensiones: !EXT_PATHS[%%i]!
        set "EXT_FOUND=1"
        
        REM Contar subcarpetas (extensiones)
        for /f %%j in ('dir "!EXT_PATHS[%%i]!" /ad /b 2^>nul ^| find /c /v ""') do (
            echo    Extensiones instaladas: %%j
        )
        
        REM Mostrar algunas extensiones
        echo    Primeras 5 extensiones:
        for /f "tokens=1" %%k in ('dir "!EXT_PATHS[%%i]!" /ad /b 2^>nul') do (
            echo      - %%k
        )
        break
    )
)

if %EXT_FOUND% equ 0 (
    echo [AVISO] No se encontraron carpetas de extensiones
    echo Posibles causas:
    echo - CURSOR no se ha ejecutado nunca
    echo - No hay extensiones instaladas
    echo - Ubicacion de extensiones diferente
)

echo.
echo [6/10] Verificando conexion a repositorio...

echo Probando conexion SSH a GitHub...
ssh -T git@github.com -o ConnectTimeout=10 -o BatchMode=yes >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Conexion SSH a GitHub exitosa
) else (
    echo [AVISO] Problema con conexion SSH a GitHub
    echo SOLUCION: Configurar claves SSH
    echo 1. ssh-keygen -t rsa -b 4096 -C "tu-email@example.com"
    echo 2. Agregar clave publica a GitHub
)

echo.
echo [7/10] Verificando ruta de backup...

set "BACKUP_LOCAL=O:\My Drive\Life_Management\cursor_backup"
echo - Ruta backup: %BACKUP_LOCAL%

if exist "%BACKUP_LOCAL%" (
    echo [OK] Directorio de backup existe
) else (
    echo [AVISO] Directorio de backup no existe
    
    REM Verificar directorio padre
    if exist "O:\My Drive\Life_Management\" (
        echo [INFO] Directorio padre existe, se puede crear la carpeta
    ) else (
        if exist "O:\My Drive\" (
            echo [INFO] Google Drive encontrado, falta crear Life_Management
        ) else (
            echo [ERROR] Unidad O: no accesible
            echo SOLUCION: Verificar que Google Drive este montado en O:
        )
    )
)

echo.
echo [8/10] Verificando permisos...

echo Probando creacion de archivo temporal...
set "TEST_FILE=%TEMP%\cursor_test_%RANDOM%.txt"
echo test > "%TEST_FILE%" 2>nul
if exist "%TEST_FILE%" (
    echo [OK] Permisos de escritura funcionan
    del "%TEST_FILE%" >nul 2>nul
) else (
    echo [ERROR] Problemas con permisos de escritura
)

echo.
echo [9/10] Verificando PowerShell...

powershell -Command "Write-Output 'PowerShell disponible'" >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] PowerShell disponible
) else (
    echo [AVISO] PowerShell no disponible
)

echo.
echo [10/10] Resumen del diagnostico...
echo.
echo ========================================
echo RESUMEN DE DIAGNOSTICO
echo ========================================

if exist "%CURSOR_PATH%" (
    echo [✓] CURSOR configuracion: OK
) else (
    echo [✗] CURSOR configuracion: FALTA
)

where cursor >nul 2>nul
if %errorlevel% equ 0 (
    echo [✓] Comando cursor: OK
) else (
    echo [✗] Comando cursor: FALTA
)

where git >nul 2>nul
if %errorlevel% equ 0 (
    echo [✓] Git: OK
) else (
    echo [✗] Git: FALTA
)

if %EXT_FOUND% equ 1 (
    echo [✓] Extensiones: ENCONTRADAS
) else (
    echo [?] Extensiones: NO DETECTADAS
)

echo.
echo RECOMENDACIONES:
echo.

where cursor >nul 2>nul
if %errorlevel% neq 0 (
    echo 1. AGREGAR CURSOR AL PATH:
    echo    - Encuentra la carpeta donde esta instalado CURSOR
    echo    - Agregala a las Variables de Entorno PATH
    echo    - Reinicia la terminal
    echo.
)

if not exist "%BACKUP_LOCAL%" (
    echo 2. CREAR CARPETA DE BACKUP:
    echo    - Verificar que Google Drive este montado
    echo    - Crear: O:\My Drive\Life_Management\cursor_backup
    echo.
)

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo 3. INSTALAR GIT:
    echo    - Descargar desde: https://git-scm.com/
    echo    - Instalar con opciones por defecto
    echo.
)

echo 4. CONFIGURAR SSH (si no esta configurado):
echo    ssh-keygen -t rsa -b 4096 -C "tu-email@example.com"
echo    Agregar clave publica a GitHub
echo.

echo ========================================
echo Diagnostico completado
echo ========================================
echo.
echo Presiona cualquier tecla para salir...
pause >nul