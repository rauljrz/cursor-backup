# CURSOR Configuration Backup

**Fecha de backup:** Thu 09/04/2025 14:22:36.91
**Usuario:** rauljrz
**PC:** HP-DESK

## Archivos incluidos:

- `config/settings.json` - Configuraciones generales de CURSOR
- `config/keybindings.json` - Atajos de teclado personalizados
- `config/snippets/` - Fragmentos de codigo personalizados
- `config/cli/cli-config.json` - Configuracion global de CLI
- `config/globalStorage/storage.json` - Estado global de extensiones
- `config/History/` - Historial de busquedas y comandos
- `config/workspaceStorage/` - Configuraciones de workspaces (opcional)
- `extensions/extensions.txt` - Lista de extensiones instaladas

## Como restaurar:

### 1. Copiar configuraciones:
```cmd
copy config\settings.json "%%APPDATA%%\Cursor\User\"
copy config\keybindings.json "%%APPDATA%%\Cursor\User\"
xcopy config\snippets "%%APPDATA%%\Cursor\User\snippets\" /e /i
copy config\cli\cli-config.json "%%USERPROFILE%%\.cursor\"
mkdir "%%APPDATA%%\Cursor\User\globalStorage" ^>nul 2^>nul
copy config\globalStorage\storage.json "%%APPDATA%%\Cursor\User\globalStorage\"
xcopy config\History "%%APPDATA%%\Cursor\User\History\" /e /i
REM Opcional: xcopy config\workspaceStorage "%%APPDATA%%\Cursor\User\workspaceStorage\" /e /i
```

### 2. Instalar extensiones:
```cmd
for /f %%i in ^(extensions\extensions.txt^) do cursor --install-extension "%%i"
```

---
**Generado automaticamente por CURSOR Git Sync Tool**

rauljrz[at]factorcodelab.com
