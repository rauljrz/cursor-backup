# CURSOR Git Sync Tool

Sistema completo de sincronización de configuración de CURSOR usando Git, basado en la metodología de **Dre Dyson** ([artículo original](https://dredyson.com/how-i-fixed-keybindings-settings-sync-in-cursor-ide-complete-guide/)).

## 📁 Configuración del Sistema

- **Repositorio GitHub**: `git@github.com:rauljrz/cursor-backup.git`
- **Carpeta local**: `O:\My Drive\cursor_backup`
- **Configuración CURSOR**: `%APPDATA%\Cursor\User\`

## 📋 Prerequisitos

### 1. Instalar Git
- Descarga desde: https://git-scm.com/
- Asegúrate de que `git` esté en el PATH del sistema

### 2. Configurar SSH para GitHub
```bash
# Generar clave SSH (si no tienes una)
ssh-keygen -t rsa -b 4096 -C "tu-email@example.com"

# Añadir la clave a GitHub
# Copia el contenido de: ~/.ssh/id_rsa.pub
# Y pégala en GitHub > Settings > SSH Keys
```

### 3. Verificar acceso al repositorio
```bash
git clone git@github.com:rauljrz/cursor-backup.git
```

## 🚀 Scripts Incluidos

### 1. `cursor_git_sync.bat` - Backup y Sincronización
**Función**: Respalda tu configuración actual y la sube al repositorio Git

**Qué incluye**:
- ✅ `settings.json` - Configuraciones generales
- ✅ `keybindings.json` - Atajos de teclado personalizados  
- ✅ `snippets/` - Fragmentos de código personalizados
- ✅ Lista de extensiones instaladas
- ✅ README.md con información del backup
- ✅ Script de instalación automática de extensiones

### 2. `cursor_git_restore.bat` - Restauración
**Función**: Restaura tu configuración desde el repositorio Git

**Proceso**:
- Clona/actualiza el repositorio automáticamente
- Crea backup de configuración actual antes de restaurar
- Restaura todos los archivos de configuración
- Opción de instalar extensiones automáticamente

### 3. `cursor_auto_sync_setup.bat` - Automatización
**Función**: Configura sincronización automática usando Programador de Tareas

**Opciones**:
- 📅 Sincronización diaria (recomendado)
- 📅 Sincronización semanal
- 🔄 Sincronización al iniciar sesión
- ⚡ Script de sincronización rápida en el escritorio

## 💡 Uso Paso a Paso

### Primera Vez - Configuración Inicial

1. **Descargar los scripts** en una carpeta (ej: `C:\tools\cursor-sync\`)

2. **Ejecutar el primer backup**:
   ```cmd
   cursor_git_sync.bat
   ```

3. **Configurar sincronización automática**:
   ```cmd
   cursor_auto_sync_setup.bat
   # Selecciona opción 1 para sincronización diaria
   ```

### En una Nueva PC - Restauración

1. **Clonar los scripts** desde tu repositorio o copia USB

2. **Restaurar configuración**:
   ```cmd
   cursor_git_restore.bat
   ```

3. **Verificar** que CURSOR tiene tu configuración personalizada

4. **Configurar sincronización automática** en la nueva PC

### Uso Diario

- **Automático**: El sistema sincroniza según la programación configurada
- **Manual**: Ejecuta `cursor_git_sync.bat` cuando quieras
- **Rápido**: Usa el acceso directo `Sync_CURSOR.bat` en el escritorio

## 🔧 Estructura del Repositorio

```
cursor_backup/
├── config/
│   ├── settings.json      # Configuraciones principales
│   ├── keybindings.json   # Atajos de teclado
│   └── snippets/          # Fragmentos de código
├── extensions/
│   └── extensions.txt     # Lista de extensiones
├── README.md              # Información del backup
├── install-extensions.bat # Instalador automático
└── .git/                  # Control de versiones
```

## ⚙️ Comandos Útiles

### Gestión de Tareas Programadas
```cmd
# Ver estado de la sincronización automática
schtasks /query /tn "CursorAutoSync"

# Ejecutar sincronización manualmente
schtasks /run /tn "CursorAutoSync"

# Eliminar tarea automática
schtasks /delete /tn "CursorAutoSync" /f
```

### Comandos Git Manuales
```cmd
# En la carpeta: O:\My Drive\cursor_backup
cd "O:\My Drive\cursor_backup"

# Ver estado del repositorio
git status

# Ver historial de cambios
git log --oneline

# Sincronizar manualmente
git add .
git commit -m "Manual sync"
git push origin main
```

## 🛡️ Características de Seguridad

### Backup Automático de Configuración Actual
- Antes de restaurar, se crea un backup en `%APPDATA%\Cursor\User\backups\`
- Formato: `settings_backup_AAAAMMDD.json`

### Control de Versiones
- Historial completo de cambios en Git
- Posibilidad de revertir a versiones anteriores
- Múltiples puntos de restauración

### Verificaciones de Integridad
- Los scripts verifican que existan los archivos necesarios
- Validación de rutas y permisos antes de proceder
- Manejo de errores con mensajes informativos

## 🔄 Metodología Dre Dyson Implementada

Siguiendo el artículo original, este sistema implementa:

✅ **Backup de archivos críticos**: settings.json, keybindings.json, snippets  
✅ **Lista de extensiones**: Generada automáticamente con `cursor --list-extensions`  
✅ **Repositorio Git privado**: Control de versiones completo  
✅ **Automatización**: Programador de Tareas de Windows  
✅ **Restauración fácil**: Scripts automatizados para nuevas PCs  
✅ **Sincronización multiplataforma**: Funciona en cualquier PC con Git  

## 🚨 Solución de Problemas

### Error: "Git no encontrado"
**Solución**: Instala Git y asegúrate de que esté en el PATH

### Error: "No se puede conectar al repositorio"
**Solución**: 
1. Verifica tu configuración SSH
2. Prueba: `ssh -T git@github.com`
3. Asegúrate de tener permisos en el repositorio

### Error: "No se puede crear la carpeta de backup"
**Solución**: 
1. Verifica que existe `O:\My Drive\`
2. Ejecuta como administrador si es necesario
3. Modifica la ruta en los scripts si es necesaria

### Las extensiones no se instalan
**Solución**:
1. Verifica que `cursor` esté en el PATH
2. Ejecuta manualmente: `cursor --install-extension [nombre-extension]`
3. Instala desde el marketplace de CURSOR

### La tarea programada no se ejecuta
**Solución**:
1. Verifica permisos de administrador
2. Comprueba que la ruta del script sea correcta
3. Usa Task Scheduler para revisar la configuración

## 📞 Comandos de Emergencia

### Restaurar desde backup local
```cmd
copy "%APPDATA%\Cursor\User\backups\settings_backup_*.json" "%APPDATA%\Cursor\User\settings.json"
```

### Reinstalar todas las extensiones
```cmd
cd "O:\My Drive\cursor_backup"
for /f %i in (extensions\extensions.txt) do cursor --install-extension "%i"
```

### Reset completo de configuración
```cmd
# CUIDADO: Esto elimina TODA la configuración de CURSOR
rmdir /s /q "%APPDATA%\Cursor"
# Luego restaurar desde Git
cursor_git_restore.bat
```

## 🎯 Mejores Prácticas

1. **Sincroniza regularmente**: Configura sincronización diaria
2. **Verifica los backups**: Revisa ocasionalmente que se estén subiendo al repositorio
3. **Documenta cambios importantes**: Usa commits descriptivos
4. **Mantén múltiples copias**: Git + backups locales + cloud storage
5. **Prueba la restauración**: Verifica que puedes restaurar en una PC limpia

---

**¡Tu configuración de CURSOR está ahora protegida y sincronizada!** 🎉

Para más consejos y actualizaciones, visita: https://dredyson.com/