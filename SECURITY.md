# Aviso de seguridad: rotar la clave de Azure Storage

`Boot4Practica/ViewController.swift` llevaba escrita en el código la clave de
la cuenta de Azure Storage (`setupAzureStorageConnect`). Una *account key* de
Azure Storage no es una credencial de cliente: da **lectura, escritura y
borrado sobre todos los contenedores de la cuenta**.

Este repositorio es público, así que esa clave debe considerarse comprometida:

1. Entra al portal de Azure → la cuenta de almacenamiento → *Access keys*.
2. Regenera **key1** (y **key2**, si alguna vez se usó).
3. Cualquier cosa que siguiera usando la clave anterior dejará de funcionar; es
   el efecto que se busca.

Quitarla del código **no la despublica**: sigue en el historial de git y en
cualquier clon o fork existente. Rotarla es lo único que la invalida.

## Cómo se configura ahora

`setupAzureStorageConnect()` lee `AZURE_STORAGE_ACCOUNT_NAME` y
`AZURE_STORAGE_ACCOUNT_KEY`:

1. Primero de las variables de entorno del *scheme* (Product → Scheme → Edit
   Scheme → Run → Arguments → Environment Variables). Es lo cómodo para
   desarrollar.

   > **Cuidado.** Xcode guarda ese valor **en claro** dentro de
   > `Boot4Practica.xcodeproj/xcuserdata/<usuario>.xcuserdatad/xcschemes/Boot4Practica.xcscheme`.
   > Ese directorio estaba versionado — había dos, `jairo` y `byjuanmn` —, así
   > que seguir este paso habría devuelto la clave a git en el commit
   > siguiente. Ahora `xcuserdata/` está en `.gitignore` y los ficheros que
   > había se han dejado de versionar. Si alguna vez lo quitas del `.gitignore`,
   > mira el `git status` antes de commitear.

2. Si no están ahí, de `Info.plist`, cuyas entradas se rellenan desde *build
   settings* del mismo nombre.

   **Crear un `.xcconfig` no basta**: Xcode no lo lee hasta que se referencia.
   Hay dos formas de que estos ajustes lleguen de verdad al `Info.plist`:

   - En Xcode: Project → Info → Configurations, y elegir el `.xcconfig` como
     configuración base de *Debug* y *Release*. Hoy ninguna de las dos
     configuraciones del `project.pbxproj` tiene `baseConfigurationReference`.
   - O pasándolos en la línea de órdenes, sin tocar el proyecto:

     ```sh
     xcodebuild -project Boot4Practica.xcodeproj -scheme Boot4Practica \
       AZURE_STORAGE_ACCOUNT_NAME=... AZURE_STORAGE_ACCOUNT_KEY=... build
     ```

   Mientras no hagas una de las dos, las entradas del `Info.plist` se quedan
   con el literal `$(AZURE_STORAGE_ACCOUNT_NAME)` sin expandir, que
   `configurationValue()` descarta a propósito.

Sin ninguna de las dos la app no se conecta y lo dice por consola, en vez de
intentarlo con una credencial vacía. Los controles que necesitan el cliente de
Blob Storage tampoco hacen nada en ese estado, en lugar de romper la app.

## Limitación

Una clave que viaja dentro del bundle de una app es extraíble, la guarde quien
la guarde: basta descomprimir el `.ipa`. Lo correcto para una app que habla con
Blob Storage es que un backend emita un **SAS token** de alcance y caducidad
limitados y que la app nunca vea la clave de la cuenta. Lo de arriba resuelve el
problema inmediato -que la clave estuviera en el control de versiones-, no ese.
