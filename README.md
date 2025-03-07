![Logo](https://github.com/Easy-Market-SPL/.github/blob/main/Banner.png?raw=true)

# EasyMarket Frontend

Aplicación móvil y web desarrollada en **Flutter** para la Línea de Productos de Software (**SPL**) de EasyMarket, orientada a la gestión eficiente de marketplaces en el sector comercio.

---
## Stack Tecnológico 🛠️

**Framework:** Flutter

![Flutter](https://skillicons.dev/icons?i=flutter)


---
## Variables de Entorno 🔒

Para ejecutar este proyecto, necesitarás agregar las siguientes variables de entorno a tu archivo `.env`:

* `ANDROID_CLIENT_ID` - ID de cliente para Android.
* `IOS_CLIENT_ID` - ID de cliente para iOS.
* `WEB_CLIENT_ID` - ID de cliente para aplicaciones web.
* `BASE_GOOGLE_PLACES_URL` - URL base para el servicio de Google Places.
* `BASE_PLACES_REVERSE_URL` - URL base para la búsqueda inversa de lugares.
* `BASE_PLACES_URL` - URL base para la API de lugares.
* `BASE_TRAFFIC_URL` - URL base para la API de tráfico.
* `MAPS_API_KEY` - Clave de API para servicios de mapas.
* `MAP_BOX_ACCESS_TOKEN` - Token de acceso para Mapbox.
* `SUPABASE_ANON_KEY` - Clave de acceso anónima para Supabase.
* `SUPABASE_URL` - URL del servicio Supabase.

### Configuracion con doppler 🚀

Como requisito para realizar el manejo de variables de entorno con doppler se debe tener instalado el CLI de doppler, para ello se debe seguir la guía de instalación en el siguiente [enlace](https://docs.doppler.com/docs/cli)

Debe ser parte del equipo de doppler para poder acceder a las variables de entorno del proyecto, para ello se debe enviar el correo de la cuenta de doppler al correo de alguno de los miembros del equipo para ser agregado.

Para obtener las variables de entorno del proyecto se debe ejecutar el siguiente comando en la terminal:

**1. Iniciar sesión en doppler**

```bash
doppler login
```

**2. Seleccionar el proyecto (spl-front) y el ambiente de desarrollo (dev)**

```bash
doppler setup
```
**3. Ejecutar el archivo por lotes para generar un archivo .env**

```bash
# windows
./env-vars.bat
```


---
## Ejecutar Localmente 💻

Clona el proyecto:

```bash
  git clone https://github.com/Easy-Market-SPL/spl-front
```

Accede al directorio del proyecto:

```bash
  cd spl-front
```

Instala las dependencias:

```bash
  flutter pub get
```

Ejecuta la aplicación:

```bash
  flutter run
```

---
## Autores 🧑🏻‍💻

* [@Estebans441](https://www.github.com/Estebans441)
* [@juanfra312003](https://www.github.com/juanfra312003)
* [@CaMoraG](https://www.github.com/CaMoraG)
* [@Moyano1711](https://www.github.com/Moyano1711)
