# Mobile Orvexis

Guía de instalación y puesta en marcha del proyecto para cualquier desarrollador del equipo.

---

## 1. Descripción

Este proyecto está construido con:

* Flutter
* Drift
* SQLite local
* go_router
* helpers y theming centralizado

La app está pensada para correr localmente en simulador iOS, emulador Android o desktop macOS durante desarrollo.

---

## 2. Requisitos previos

Antes de ejecutar el proyecto, instala lo siguiente:

### Obligatorio

* Flutter SDK
* Dart SDK
* Xcode (para iOS en Mac)
* Android Studio (para Android)
* CocoaPods
* Git
* VS Code o Android Studio

### Recomendado

* Extensión Flutter para VS Code
* Extensión Dart para VS Code
* Pubspec Assist
* Error Lens

---

## 3. Verificar instalación del entorno

Ejecuta:

```bash
flutter doctor
```

Debes tener correcto al menos:

* Flutter
* Xcode
* Android toolchain
* Connected device

Si falta algo, corrígelo antes de continuar.

---

## 4. Clonar el proyecto

```bash
git clone <URL_DEL_REPOSITORIO>
cd mobile_orvexis
```

---

## 5. Instalar dependencias del proyecto

Dentro del proyecto ejecuta:

```bash
flutter pub get
```

---

## 6. Dependencias principales usadas en el proyecto

Estas son las librerías base que debe tener el proyecto:

### Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  drift:
  sqlite3_flutter_libs:
  path_provider:
  path:
  go_router:
  intl:
  uuid:
```

### Dependencias de desarrollo

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner:
  drift_dev:
```

Si hace falta instalar alguna manualmente:

```bash
flutter pub add drift
flutter pub add sqlite3_flutter_libs
flutter pub add path_provider
flutter pub add path
flutter pub add go_router
flutter pub add intl
flutter pub add uuid
flutter pub add build_runner --dev
flutter pub add drift_dev --dev
```

---

## 7. Generación de archivos de Drift

Después de instalar dependencias o modificar tablas de la base de datos, ejecutar:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Esto genera archivos como:

```text
lib/core/database/app_database.g.dart
```

### Importante

Cada vez que cambies tablas Drift o DAOs, vuelve a ejecutar ese comando.

---

## 8. Estructura base del proyecto

```text
lib/
├── config/
│   ├── router/
│   └── theme/
├── core/
│   ├── database/
│   │   ├── app_database.dart
│   │   └── tables/
│   └── helpers/
├── feature/
└── main.dart
```

### Carpetas principales

* `config/router`: configuración de rutas con `go_router`
* `config/theme`: tema, colores y modo oscuro
* `core/database`: SQLite + Drift
* `core/helpers`: utilidades globales
* `feature`: módulos funcionales de la app

---

## 9. Base de datos local

La aplicación usa:

* SQLite local en el dispositivo
* Drift como capa de acceso y tipado

### Consideraciones

* No se requiere backend para correr la app actualmente
* La base se crea localmente al ejecutar la app
* Los IDs se manejan como `String` para UUIDs
* Las tablas están separadas por archivo dentro de `lib/core/database/tables/`

---

## 10. Ejecución en iOS

### Abrir simulador

```bash
open -a Simulator
```

### Ver dispositivos disponibles

```bash
flutter devices
```

### Ejecutar proyecto

```bash
flutter run
```

O directamente:

```bash
flutter run -d ios
```

### Si hay problemas con pods

```bash
cd ios
pod install
cd ..
flutter run
```

---

## 11. Ejecución en Android

### Abrir emulador desde Android Studio

O usar:

```bash
flutter emulators
flutter emulators --launch <NOMBRE_DEL_EMULADOR>
```

### Ejecutar proyecto

```bash
flutter run
```

---

## 12. Ejecución en macOS

También puede correr como app desktop para pruebas rápidas:

```bash
flutter run -d macos
```

### Nota

Para pruebas reales de mobile se recomienda iOS Simulator o emulador Android.

---

## 13. Helpers disponibles

Actualmente el proyecto contempla helpers como:

* `currency_helper.dart`
* `date_helper.dart`
* `log_helper.dart`
* `snackbar_helper.dart`
* `uuid_helper.dart`
* `validators_helper.dart`

Estos helpers viven en:

```text
lib/core/helpers/
```

---

## 14. Theme y modo oscuro

El proyecto usa theming centralizado.

Ubicación:

```text
lib/config/theme/
```

Archivos esperados:

* `app_colors.dart`
* `app_theme.dart`
* `theme_controller.dart`

Incluye:

* tema claro
* tema oscuro
* personalización global de botones
* personalización de inputs
* personalización de cards y app bars

---

## 15. Router

La navegación se maneja con `go_router`.

Ubicación:

```text
lib/config/router/
```

Archivo principal esperado:

* `app_router.dart`

---

## 16. Comandos útiles

### Instalar dependencias

```bash
flutter pub get
```

### Limpiar proyecto

```bash
flutter clean
```

### Regenerar archivos Drift

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Correr proyecto

```bash
flutter run
```

### Ver dispositivos

```bash
flutter devices
```

### Ver estado del entorno

```bash
flutter doctor
```

---

## 17. Solución de problemas comunes

### Error: Could not find package build_runner

Instalar:

```bash
flutter pub add build_runner --dev
flutter pub add drift_dev --dev
flutter pub get
```

### Error con archivos generados de Drift

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Error de entorno o caché

```bash
flutter clean
rm -rf .dart_tool
rm -rf build
flutter pub get
```

### Error con iOS pods

```bash
cd ios
pod install
cd ..
flutter run
```

### Verificar versiones

```bash
flutter --version
flutter doctor
```

---

## 18. Flujo recomendado para nuevos cambios

1. Crear o modificar tablas Drift
2. Ejecutar generación de código
3. Probar en simulador o emulador
4. Validar navegación
5. Revisar logs y helpers

---

## 19. Recomendaciones para el equipo

* No escribir todas las tablas en un solo archivo
* Mantener una tabla por archivo en Drift
* Centralizar colores y tema
* Usar helpers globales para formatos, logs y validaciones
* Probar siempre después de cambiar tablas o router
* No correr en web para módulos que dependan de SQLite local

---

## 20. Primer arranque recomendado para un nuevo dev

Ejecutar en este orden:

```bash
git clone <URL_DEL_REPOSITORIO>
cd mobile_orvexis
flutter pub get
dart run build_runner build --delete-conflicting-outputs
open -a Simulator
flutter run
```

---

## 21. Pendientes recomendados del proyecto

* persistencia de preferencia de tema
* seed inicial de catálogos
* DAOs por módulo
* primeros módulos funcionales
* settings
* formularios y listados por feature
