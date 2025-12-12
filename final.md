# 📱 Documentación Final - Gestión de Socios

## 1️⃣ Sistema de Respuesta de Asuntos

### Descripción General
El sistema permite que los socios envíen asuntos/consultas al administrador, y el administrador pueda responderlos. Una vez que el admin responde, el asunto se marca automáticamente como **leído**.

---

### 🔄 Flujo Completo de Asuntos

#### **PASO 1: El Socio Envía un Asunto**

**Archivo:** `lib/pantallas/contactar_admin.dart`

El socio completa un formulario con:
- Asunto (título)
- Descripción (detalle)

El código que crea el asunto:

```dart
// Líneas 54-64 en contactar_admin.dart
final asunto = ModeloAsunto(
  uidSocio: uid,                                    // ID del socio
  nombre: nombreSocio,                              // Nombre del socio
  apellido: apellidoSocio,                          // Apellido del socio
  email: email,                                     // Email del socio
  asunto: _asuntoCtrl.text.trim(),                 // Título del asunto
  descripcion: _descripcionCtrl.text.trim(),       // Descripción
  fotoBase64: fotoBase64.isNotEmpty ? fotoBase64 : null,  // Foto de perfil
);

await DBServicio.crearAsunto(asunto);
```

**Lo que pasa:**
- Se crea un objeto `ModeloAsunto` con los datos
- Se guarda en Firestore en la colección `asuntos`
- El asunto comienza con `leido: false` y `respondido: false`

---

#### **PASO 2: El Admin Ve el Asunto**

**Archivo:** `lib/pantallas/admin_asuntos.dart`

El admin ve una lista de asuntos sin responder.

```dart
// Líneas 46-47 en admin_asuntos.dart
StreamBuilder<List<ModeloAsunto>>(
  stream: DBServicio.streamAsuntos(),  // Obtiene TODOS los asuntos
  builder: (context, snapshot) {
    final asuntos = snapshot.data!;
    // Muestra cada asunto en una tarjeta
```

La lista muestra:
- ❌ Icono rojo si NO tiene respuesta
- ✅ Icono verde si YA tiene respuesta
- Nombre del socio
- Asunto (título)
- Fecha de envío

---

#### **PASO 3: El Admin Responde el Asunto**

**Archivo:** `lib/pantallas/admin_asuntos.dart` (líneas 410-640)

El admin hace clic en "Responder" y se abre un modal con:
- Asunto original
- Campo de texto para la respuesta
- Botón "Enviar Respuesta"

**El código que procesa la respuesta:**

```dart
// Líneas 614-632 en admin_asuntos.dart
try {
  // 1. Llamar a la función para guardar la respuesta
  await DBServicio.responderAsunto(
    asunto.id ?? '',
    respuestaCtrl.text.trim(),
  );

  // 2. AUTOMÁTICAMENTE marcar como leído
  await DBServicio.marcarLeido(asunto.id ?? '', true);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Respuesta enviada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
} catch (e) {
  // Mostrar error si algo falla
}
```

**Lo importante:** Después de responder, se ejecutan **DOS operaciones**:
1. `responderAsunto()` - Guarda la respuesta
2. `marcarLeido()` - Marca como leído

---

### 💾 Funciones de Base de Datos

**Archivo:** `lib/servicios/db_servicio.dart`

#### **1. Crear Asunto**
```dart
// Línea 74-81
static Future<void> crearAsunto(ModeloAsunto a) async {
  if (a.id != null && a.id!.isNotEmpty) {
    await _db.collection('asuntos').doc(a.id).set(a.toMap());
  } else {
    await _db.collection('asuntos').add(a.toMap());
  }
}
```
Guarda el asunto en Firestore con estado inicial `leido: false`.

#### **2. Responder Asunto**
```dart
// Línea 91-98
static Future<void> responderAsunto(String id, String respuesta) async {
  await _db.collection('asuntos').doc(id).update({
    'respuesta': respuesta,                    // Texto de la respuesta
    'fechaRespuesta': Timestamp.now(),        // Fecha/hora de la respuesta
    'respondido': true,                       // Marca como respondido
  });
}
```
Actualiza el asunto con la respuesta y marca `respondido: true`.

#### **3. Marcar Como Leído**
```dart
// Línea 84-85
static Future<void> marcarLeido(String id, bool leido) async {
  await _db.collection('asuntos').doc(id).update({'leido': leido});
}
```
Marca el asunto como `leido: true` después de que el admin responde.

#### **4. Obtener Todos los Asuntos (Admin)**
```dart
// Línea 68-72
static Stream<List<ModeloAsunto>> streamAsuntos() {
  return _db.collection('asuntos')
    .orderBy('fecha', descending: true)  // Más recientes primero
    .snapshots()
    .map((snap) => snap.docs
        .map((d) => ModeloAsunto.fromMap(d.data()..['id'] = d.id))
        .toList());
}
```
Devuelve todos los asuntos ordenados por fecha (más recientes primero).

#### **5. Obtener Asuntos del Socio**
```dart
// Línea 100-109
static Stream<List<ModeloAsunto>> streamAsuntosPorSocio(String uid) {
  return _db
    .collection('asuntos')
    .where('uidSocio', isEqualTo: uid)  // Solo los asuntos de ESTE socio
    .orderBy('fecha', descending: true)
    .snapshots()
    .map((snap) => snap.docs
        .map((d) => ModeloAsunto.fromMap(d.data()..['id'] = d.id))
        .toList());
}
```
Devuelve solo los asuntos enviados por un socio específico.

---

### 📊 Estado del Asunto en Firestore

Un asunto en Firestore se ve así:

```json
{
  "id": "abc123xyz",
  "uidSocio": "user_uid_001",
  "nombre": "Melani",
  "apellido": "Bustos",
  "email": "melanibustos@test.com",
  "asunto": "Problema con mi cuota",
  "descripcion": "No puedo pagar la cuota de diciembre",
  "fotoBase64": "data:image/png;base64,iVBORw0KG...",
  "fecha": "2025-12-08T19:30:00Z",
  "leido": true,                    // ✅ Se pone true al responder
  "respondido": true,               // ✅ Se pone true al responder
  "respuesta": "Revisamé que ya esté pagada",
  "fechaRespuesta": "2025-12-08T20:15:00Z"
}
```

---

---

## 2️⃣ Sistema de QR para Pago de Cuotas

### Descripción General
Cuando un socio quiere pagar una cuota, puede escanear un código QR desde su celular. El QR contiene un link que abre un navegador donde puede completar el pago.

---

### 🔄 Flujo Completo del QR

#### **PASO 1: El Socio Ve sus Cuotas**

**Archivo:** `lib/pantallas/mis_cuotas.dart`

El socio ve una lista de 4 cuotas:
- Diciembre 2025
- Enero 2026
- Febrero 2026
- Marzo 2026

Cada cuota tiene un estado:
- 🟠 **Pendiente** - Muestra botón "Ver QR Pago"
- 🟢 **Pagado** - Muestra fecha de pago
- 🔵 **Pagando** - Muestra mensaje "Tu pago está siendo procesado"

---

#### **PASO 2: El Socio Hace Clic en "Ver QR Pago"**

**Archivo:** `lib/pantallas/mis_cuotas.dart` (líneas 228-240)

El código que abre el QR:

```dart
if (isPendiente) ...[
  const SizedBox(height: 12),
  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () => _mostrarQR(context, cuota, uid),  // ← Abre el diálogo
      icon: const Icon(Icons.qr_code),
      label: const Text('Ver QR Pago'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0404B9),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  ),
],
```

---

#### **PASO 3: Se Genera y Muestra el QR**

**Archivo:** `lib/pantallas/mis_cuotas.dart` (líneas 254-304)

La función `_mostrarQR()` hace lo siguiente:

```dart
Future<void> _mostrarQR(BuildContext context, ModeloCuota cuota, String uid) async {
  // 1. GENERAR el link para el QR
  final qrData = "https://mpago.la/test-pago-${cuota.mes}-${uid.substring(0, 8)}";
  
  // 2. MOSTRAR el diálogo con el QR
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              const Text(
                'Código QR de Pago',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0404B9),
                ),
              ),
              const SizedBox(height: 16),
              
              // Información de la cuota
              Text(
                'Cuota ${cuota.mes}/${cuota.anio}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Monto: \$${cuota.monto.toStringAsFixed(0)} ARS',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              
              // 3. GENERAR el QR visualmente
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF0404B9), width: 2),
                ),
                child: QrImageView(
                  data: qrData,           // El link en formato QR
                  version: QrVersions.auto,
                  size: 280,              // Tamaño del QR
                  gapless: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              
              // Instrucción
              const Text(
                'Escanea este código QR con tu celular para completar el pago',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              // Botón cerrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0404B9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cerrar', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
```

---

#### **PASO 4: El Socio Escanea el QR**

Con la cámara del celular:
1. Apunta a la pantalla donde está el QR
2. Hace clic en el link que aparece
3. Se abre un navegador con el link de pago

---

### 🎯 Cómo Funciona el QR

#### **Generación del QR:**
```dart
final qrData = "https://mpago.la/test-pago-${cuota.mes}-${uid.substring(0, 8)}";
```

Esto genera un link como:
```
https://mpago.la/test-pago-12-a1b2c3d4
```

**Componentes:**
- `https://mpago.la/` - Dominio de Mercado Pago (testeo)
- `test-pago-` - Prefijo
- `${cuota.mes}` - Número de mes (01-12)
- `${uid.substring(0, 8)}` - Primeros 8 caracteres del ID del usuario

#### **Visualización del QR:**
Usamos la librería `qr_flutter`:

```dart
QrImageView(
  data: qrData,                    // El link a codificar
  version: QrVersions.auto,        // Tamaño automático
  size: 280,                       // Tamaño en píxeles
  gapless: true,                   // Sin espacios
  backgroundColor: Colors.white,   // Fondo blanco
  foregroundColor: Colors.black,   // Puntos negros
)
```

---

### 📱 Flujo en el Celular del Usuario

1. **Abre la app en web:** `https://gestionsociospintor.web.app`
2. **Va a "Mis Cuotas"**
3. **Hace clic en "Ver QR Pago"** → Se ve un QR en la pantalla
4. **Saca otro celular** (o pide prestado)
5. **Abre la cámara del celular** y apunta a la pantalla
6. **Toca el link** que detecta la cámara
7. **Se abre en Mercado Pago** donde puede pagar

---

### 📊 Estructura de Cuotas en Firestore

Las cuotas se guardan así:

```json
{
  "usuarios": {
    "uid_del_usuario": {
      "cuotas": {
        "12": {                    // Diciembre
          "mes": "12",
          "anio": 2025,
          "monto": 10,
          "estado": "pendiente",   // pendiente | pagado | pagando
          "fecha_vencimiento": "2025-12-31T23:59:59Z",
          "fecha_pago": null,
          "created_at": "2025-12-08T00:00:00Z"
        },
        "01": {                    // Enero
          "mes": "01",
          "anio": 2026,
          "monto": 10,
          "estado": "pendiente"
        }
        // ... febrero y marzo
      }
    }
  }
}
```

---

### 🔄 Orden de las Cuotas

En `lib/servicios/db_servicio.dart` (líneas 117-135):

```dart
static Stream<List<ModeloCuota>> streamCuotasPorSocio(String uid) {
  return _db
    .collection('usuarios')
    .doc(uid)
    .collection('cuotas')
    .snapshots()
    .map((snap) {
      final docs = snap.docs
        .map((d) => ModeloCuota.fromMap(d.data(), d.id))
        .toList();
      
      // ✨ Ordenar de más próximas a más lejanas
      docs.sort((a, b) {
        int yearCompare = a.anio.compareTo(b.anio);  // Año ascendente
        if (yearCompare != 0) return yearCompare;
        return int.parse(a.mes).compareTo(int.parse(b.mes));  // Mes ascendente
      });
      return docs;
    });
}
```

**Resultado:** Las cuotas se muestran en orden:
1. Diciembre 2025
2. Enero 2026
3. Febrero 2026
4. Marzo 2026

---

### 📚 Librerías Usadas

```yaml
# En pubspec.yaml
qr_flutter: ^4.1.0   # Para generar QR visualmente
```

La librería `QrImageView` genera el código QR que se ve en la pantalla.

---

### 🎨 UI del QR

```
┌─────────────────────────────────┐
│  Código QR de Pago              │
├─────────────────────────────────┤
│                                 │
│  Cuota 12/2025                  │
│  Monto: $10 ARS                 │
│                                 │
│  ┌──────────────────────────┐   │
│  │  ██████  ██  ██  ██████  │   │
│  │  ██         ██  ██       │   │
│  │  ██████  ██  ██  ██████  │   │
│  │          ██               │   │
│  └──────────────────────────┘   │
│                                 │
│  Escanea este código QR con     │
│  tu celular para completar...   │
│                                 │
│        [  Cerrar  ]             │
└─────────────────────────────────┘
```

---

## 📝 Resumen

### Sistema de Asuntos:
- ✅ Socio envía asunto → Se guarda en Firestore
- ✅ Admin ve lista de asuntos
- ✅ Admin responde → Se guarda respuesta + fecha
- ✅ **Automáticamente se marca como leído**
- ✅ Socio ve su respuesta en "Mis Asuntos"

### Sistema de QR:
- ✅ Socio ve 4 cuotas (Dic 2025 - Mar 2026)
- ✅ Hace clic en "Ver QR Pago" → Se genera QR
- ✅ El QR contiene un link de pago
- ✅ Se escanea desde el celular
- ✅ Abre Mercado Pago en navegador móvil

---

## 🔗 Enlaces Importantes

**App en vivo:** https://gestionsociospintor.web.app  
**Base de datos:** Firebase Firestore  
**Autenticación:** Firebase Auth  
**Cloud Functions:** 5 funciones activas  

---

## ✅ Estado Actual

- ✨ App limpia (sin código de Mercado Pago viejo)
- ✨ Cuotas reseteadas para todos los usuarios
- ✨ Sistema de respuesta automático funcionando
- ✨ QR generando correctamente
- ✨ Todo deployado en Firebase
