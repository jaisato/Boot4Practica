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
2. Si no están ahí, de `Info.plist`, cuyas entradas se rellenan desde *build
   settings* del mismo nombre. Defínelas en un `.xcconfig` local que no esté en
   git, no en el `project.pbxproj`.

Sin ninguna de las dos la app no se conecta y lo dice por consola, en vez de
intentarlo con una credencial vacía.

## Limitación

Una clave que viaja dentro del bundle de una app es extraíble, la guarde quien
la guarde: basta descomprimir el `.ipa`. Lo correcto para una app que habla con
Blob Storage es que un backend emita un **SAS token** de alcance y caducidad
limitados y que la app nunca vea la clave de la cuenta. Lo de arriba resuelve el
problema inmediato -que la clave estuviera en el control de versiones-, no ese.
