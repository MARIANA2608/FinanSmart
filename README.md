# FinanSmart

## Taller práctico – Semana 9
### Configuración, verificación y conexión del entorno de desarrollo móvil

## 1. Descripción del proyecto

FinanSmart es una aplicación móvil desarrollada como parte del proyecto integrador. La aplicación está orientada a funcionalidades relacionadas con financiamiento y se comunica con un backend propio mediante una API REST.

En este taller se configuró y verificó el entorno de desarrollo móvil, se ejecutó la aplicación en un dispositivo virtual Android y se comprobó la comunicación exitosa entre la aplicación Flutter y el backend del proyecto.

---

## 2. Framework seleccionado

Para el desarrollo de la aplicación móvil se seleccionó **Flutter**, utilizando el lenguaje de programación **Dart**.

### Justificación técnica

Flutter fue seleccionado porque permite desarrollar aplicaciones multiplataforma utilizando una única base de código. Esto facilita el mantenimiento del proyecto y permite utilizar el mismo desarrollo para diferentes plataformas.

Además, Flutter dispone de **Hot Reload**, característica que permite visualizar rápidamente los cambios realizados en el código sin reiniciar completamente la aplicación.

Para el desarrollo y las pruebas de FinanSmart se estableció **Android como plataforma móvil principal**.

---

## 3. Herramientas y versiones instaladas

El entorno utilizado para el desarrollo de FinanSmart cuenta con las siguientes herramientas:

- Sistema operativo: Windows 11 Home 64 bits
- Flutter: 3.47.0 Stable
- Dart: 3.13.0
- Flutter DevTools: 2.60.0
- Android SDK: 36.0.0
- Android SDK Platform: android-37.0
- Android SDK Build-Tools: 36.0.0
- Android Emulator: 37.1.11.0
- Android Studio: Quail 3
- Node.js: 24.19.0
- npm: 11.17.0
- Git: 2.49.0.windows.1
- Editor: Visual Studio Code
- Dispositivo virtual: Pixel 7
- Sistema del emulador: Android 15
- API del emulador: API 35

---

## 4. Verificación del entorno Flutter

Para comprobar la versión instalada de Flutter se utiliza:

```bash
flutter --version
```

Para verificar Dart:

```bash
dart --version
```

Para realizar el diagnóstico completo del entorno:

```bash
flutter doctor -v
```

El diagnóstico realizado confirmó correctamente:

- Flutter 3.47.0.
- Dart 3.13.0.
- Android SDK 36.0.0.
- Licencias de Android aceptadas.
- Chrome disponible.
- Dispositivo virtual Android disponible.
- Recursos de red disponibles.

El diagnóstico presenta una advertencia relacionada con los componentes de desarrollo de escritorio C++ de Visual Studio. Esta advertencia corresponde al desarrollo de aplicaciones Windows y no afecta la plataforma prevista para FinanSmart, debido a que el proyecto se ejecuta y prueba sobre Android.

---

## 5. Configuración de Android

Se instaló Android Studio junto con las herramientas necesarias para trabajar con Flutter y Android.

La ubicación utilizada para el Android SDK es:

```text
C:\Users\USZ\AppData\Local\Android\Sdk
```

Flutter fue configurado para utilizar este SDK mediante:

```bash
flutter config --android-sdk "C:\Users\USZ\AppData\Local\Android\Sdk"
```

También se instalaron las herramientas de línea de comandos de Android y se aceptaron las licencias correspondientes.

Para verificar las licencias:

```bash
flutter doctor --android-licenses
```

El diagnóstico final confirmó:

```text
All Android licenses accepted.
```

---

## 6. Destino de ejecución

Para ejecutar y probar la aplicación se configuró un dispositivo virtual mediante Android Studio Device Manager.

Configuración utilizada:

- Modelo: Pixel 7
- Tipo: Android Emulator
- Sistema operativo: Android 15
- API Level: 35
- Identificador utilizado por Flutter: emulator-5554

Para verificar los dispositivos disponibles se utiliza:

```bash
flutter devices
```

Flutter detectó correctamente el emulador Android.

### Justificación del destino

Se seleccionó un dispositivo virtual Pixel 7 porque permite realizar las pruebas directamente desde la computadora sin depender de un teléfono físico.

El emulador proporciona un entorno Android controlado y reproducible, adecuado para comprobar la ejecución de FinanSmart y su comunicación con el backend durante el desarrollo.

---

## 7. Creación del proyecto Flutter

El proyecto base fue creado mediante el siguiente comando:

```bash
cd %USERPROFILE%\Documents
flutter create --org com.finansmart finansmart
```

Para acceder posteriormente al proyecto:

```bash
cd %USERPROFILE%\Documents\finansmart
```

La aplicación principal se encuentra en:

```text
lib/main.dart
```

---

## 8. Dependencia HTTP

Para permitir que FinanSmart realice solicitudes HTTP hacia la API se agregó el paquete `http` de Flutter:

```bash
flutter pub add http
```

La versión instalada durante la configuración fue:

```text
http 1.6.0
```

Las dependencias del proyecto pueden restaurarse mediante:

```bash
flutter pub get
```

---

## 9. Backend FinanSmart

Para demostrar la conectividad con un backend propio se implementó una API utilizando **Node.js y Express**.

Las principales dependencias utilizadas son:

- Express
- CORS

El backend se encuentra dentro del repositorio en:

```text
backend/
```

Los archivos principales son:

```text
backend/
├── server.js
├── package.json
└── package-lock.json
```

La carpeta `node_modules` no se almacena en el repositorio. Las dependencias pueden reconstruirse utilizando npm.

Para instalar las dependencias del backend:

```bash
cd backend
npm install
```

Para iniciar el servidor:

```bash
node server.js
```

Cuando el servidor se inicia correctamente muestra:

```text
FinanSmart API ejecutándose en http://localhost:3000
```

---

## 10. Endpoint utilizado

Para comprobar la comunicación se implementó el endpoint:

```text
GET /api/financiamientos
```

Desde la computadora anfitriona puede comprobarse mediante:

```text
http://localhost:3000/api/financiamientos
```

La API devuelve una respuesta JSON con información de los tipos de financiamiento de FinanSmart.

Entre los datos de prueba disponibles se encuentran:

- Microcrédito personal
- Microcrédito emprendedor

La respuesta satisfactoria utiliza el código HTTP:

```text
200 OK
```

---

## 11. Configuración de la URL base de la API

La aplicación permite definir la URL base mediante una variable de entorno de compilación utilizando `--dart-define`.

En Flutter se utiliza:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);
```

La aplicación puede ejecutarse indicando explícitamente la URL mediante:

```bash
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Esto permite modificar la dirección del backend sin tener que cambiar manualmente la URL en diferentes partes del código.

---

## 12. Direccionamiento entre Android y el backend

El backend se ejecuta en la computadora mediante:

```text
http://localhost:3000
```

Sin embargo, desde el emulador Android no se utiliza `localhost` para acceder al servidor de la computadora anfitriona.

Para realizar esta comunicación se utiliza:

```text
10.0.2.2
```

Por esta razón, FinanSmart utiliza como URL base de desarrollo:

```text
http://10.0.2.2:3000
```

Y realiza la solicitud hacia:

```text
http://10.0.2.2:3000/api/financiamientos
```

De esta manera, el emulador Android puede acceder al backend Node.js que se está ejecutando en la computadora anfitriona.

---

## 13. Configuración de seguridad para tráfico HTTP local

El backend utilizado durante el desarrollo funciona mediante HTTP local.

Para permitir de manera acotada este tráfico durante las pruebas se creó el archivo:

```text
android/app/src/main/res/xml/network_security_config.xml
```

Su configuración autoriza el tráfico sin cifrar únicamente hacia el host utilizado durante el desarrollo:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="false">10.0.2.2</domain>
    </domain-config>
</network-security-config>
```

En `AndroidManifest.xml` se agregó el permiso de Internet:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Y la aplicación referencia la configuración mediante:

```xml
android:networkSecurityConfig="@xml/network_security_config"
```

Esta configuración se utiliza únicamente durante el desarrollo local. Para una distribución en producción debe utilizarse HTTPS y eliminarse la autorización de tráfico HTTP local que ya no sea necesaria.

---

## 14. Ejecución de FinanSmart

Primero se debe iniciar el backend.

Desde la raíz del repositorio:

```bash
cd backend
npm install
node server.js
```

El CMD donde se ejecuta el backend debe permanecer abierto.

En otra terminal se debe regresar a la raíz del proyecto Flutter y ejecutar:

```bash
flutter pub get
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

La aplicación se compila, se instala y posteriormente se ejecuta en el Pixel 7 virtual.

---

## 15. Hot Reload

Flutter permite aplicar cambios en la aplicación mientras se encuentra en ejecución mediante Hot Reload.

Cuando `flutter run` se encuentra activo, la terminal muestra:

```text
Flutter run key commands.
r Hot reload.
R Hot restart.
```

Para ejecutar Hot Reload se presiona:

```text
r
```

Durante las pruebas se verificó el funcionamiento de esta característica.

---

## 16. Prueba de conectividad con el backend

FinanSmart incluye una sección denominada:

```text
Prueba de conexión con el backend
```

La interfaz muestra la URL utilizada:

```text
http://10.0.2.2:3000
```

Al presionar:

```text
Probar conexión con API
```

la aplicación realiza una solicitud HTTP GET al endpoint:

```text
http://10.0.2.2:3000/api/financiamientos
```

Cuando la solicitud es satisfactoria, FinanSmart muestra:

```text
Conexión exitosa con FinanSmart API
```

Posteriormente se visualizan los datos recibidos desde el backend, incluyendo los financiamientos disponibles.

Esta prueba demuestra la comunicación efectiva entre:

```text
Aplicación Flutter
        ↓
Emulador Android
        ↓
10.0.2.2:3000
        ↓
API FinanSmart
        ↓
Node.js / Express
```

---

## 17. Procedimiento para reproducir el entorno

Para reproducir el entorno en otro equipo se deben seguir los siguientes pasos:

1. Instalar Git.
2. Instalar Flutter SDK.
3. Agregar Flutter al PATH del sistema.
4. Instalar Visual Studio Code.
5. Instalar las extensiones Flutter y Dart en Visual Studio Code.
6. Instalar Android Studio.
7. Instalar Android SDK.
8. Instalar Android SDK Command-line Tools.
9. Aceptar las licencias de Android.
10. Crear un dispositivo virtual Android.
11. Instalar Node.js y npm.
12. Clonar el repositorio FinanSmart.
13. Restaurar las dependencias de Flutter.
14. Restaurar las dependencias del backend.
15. Iniciar el backend.
16. Iniciar el emulador Android.
17. Ejecutar FinanSmart utilizando la URL del backend local.
18. Comprobar la comunicación mediante el botón de prueba de conexión.

---

## 18. Comandos de verificación

### Verificar Flutter

```bash
flutter --version
```

### Verificar Dart

```bash
dart --version
```

### Diagnosticar el entorno

```bash
flutter doctor -v
```

### Verificar dispositivos

```bash
flutter devices
```

### Restaurar dependencias Flutter

Desde la raíz del proyecto:

```bash
flutter pub get
```

### Instalar dependencias del backend

```bash
cd backend
npm install
```

### Ejecutar el backend

```bash
node server.js
```

### Ejecutar la aplicación

Desde la raíz del proyecto:

```bash
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

---

## 19. Estructura principal del proyecto

```text
finansmart/
├── android/
│   └── app/
│       └── src/
│           └── main/
│               ├── AndroidManifest.xml
│               └── res/
│                   └── xml/
│                       └── network_security_config.xml
├── backend/
│   ├── package.json
│   ├── package-lock.json
│   └── server.js
├── lib/
│   ├── main.dart
│   └── services/
│       └── api_service.dart
├── README.md
├── pubspec.yaml
└── pubspec.lock
```

---

## 20. Dificultades encontradas y soluciones

Durante la configuración del entorno se presentaron diferentes dificultades.

### Flutter no era reconocido en CMD

Inicialmente los comandos:

```bash
flutter --version
dart --version
```

no eran reconocidos.

Se localizó el SDK de Flutter en:

```text
C:\src\flutter\flutter
```

y posteriormente se configuró correctamente el PATH de Windows.

### Android SDK no detectado

Inicialmente `flutter doctor -v` indicó:

```text
Unable to locate Android SDK
```

Para solucionarlo se instaló Android Studio y se configuró Flutter con la ubicación del SDK.

### Android sdkmanager no encontrado

Durante la aceptación de licencias se detectó que no estaban instaladas las herramientas de línea de comandos.

Se instalaron **Android SDK Command-line Tools** desde Android Studio.

Después de la configuración, Flutter confirmó:

```text
All Android licenses accepted.
```

### Configuración del emulador

Se creó un dispositivo virtual Pixel 7 con Android 15 API 35, el cual fue detectado correctamente por Flutter como:

```text
emulator-5554
```

### Comunicación entre el emulador y el backend

El backend funcionaba correctamente mediante:

```text
http://localhost:3000
```

pero el emulador Android requiere una dirección especial para acceder al servidor de la computadora anfitriona.

La solución fue utilizar:

```text
http://10.0.2.2:3000
```

### Tráfico HTTP durante desarrollo

Debido a que la API local utiliza HTTP, se creó una configuración de seguridad de red específica para autorizar el host `10.0.2.2` durante el desarrollo.

---

## 21. Limitaciones del entorno

El entorno actual está orientado principalmente al desarrollo y pruebas sobre Android.

El backend se ejecuta localmente y utiliza HTTP exclusivamente para las pruebas de desarrollo.

La dirección `10.0.2.2` corresponde al escenario de ejecución mediante Android Emulator. En otros destinos de ejecución la dirección del backend puede requerir una configuración diferente.

Para un entorno de producción se deberá desplegar la API en un servidor accesible mediante HTTPS y eliminar las configuraciones locales de desarrollo que ya no sean necesarias.

La advertencia de Visual Studio detectada por `flutter doctor` corresponde al desarrollo de aplicaciones Windows y no impide el desarrollo Android previsto para este proyecto.

---

## 22. Resultado final

Se configuró correctamente el entorno de desarrollo móvil de FinanSmart utilizando Flutter.

Se logró:

- Instalar y verificar Flutter y Dart.
- Configurar Android Studio y Android SDK.
- Aceptar las licencias de Android.
- Configurar un Pixel 7 virtual con Android 15 API 35.
- Crear y ejecutar el proyecto FinanSmart.
- Verificar el funcionamiento de Hot Reload.
- Configurar una URL base para el backend.
- Configurar el acceso HTTP local de desarrollo.
- Implementar y ejecutar una API propia con Node.js y Express.
- Realizar una solicitud desde Flutter hacia el backend.
- Recibir y mostrar correctamente la información proporcionada por la API.

La prueba final mostró:

```text
Conexión exitosa con FinanSmart API
```

y permitió visualizar los financiamientos recibidos desde el backend.

Por lo tanto, se comprobó satisfactoriamente la integración entre la aplicación móvil y la API propia del proyecto.

---

## Autor

Proyecto Integrador: **FinanSmart**

Taller práctico – Semana 9  
Configuración, verificación y conexión del entorno de desarrollo móvil