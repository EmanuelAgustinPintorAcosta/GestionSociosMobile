/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentCreated} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

// ==================== CONSTANTES ====================
const MONTO_CUOTA = 10; // $10 ARS

// ==================== FUNCIÓN 1: Inicializar cuotas al crear socio ====================
exports.inicializarCuotasNuevoSocio = onDocumentCreated("usuarios/{uid}", async (event) => {
  const uid = event.params.uid;
  const snap = event.data;
  const userData = snap.data();

  // Solo crear cuotas si es socio
  if (userData.rol !== "socio") {
    console.log(`Usuario ${uid} no es socio, saltando inicialización de cuotas`);
    return;
  }

  console.log(`Inicializando cuotas para socio: ${uid}`);

  try {
    const batch = admin.firestore().batch();
    const ahora = admin.firestore.Timestamp.now();

    // Crear cuotas de Dic 2025 a Mar 2026
    const mesesConfig = [
      { mes: "12", anio: 2025 }, // Diciembre 2025
      { mes: "01", anio: 2026 }, // Enero 2026
      { mes: "02", anio: 2026 }, // Febrero 2026
      { mes: "03", anio: 2026 }, // Marzo 2026
    ];

    mesesConfig.forEach(({ mes, anio }) => {
      // Calcular fecha de vencimiento (último día del mes)
      const mesNum = parseInt(mes);
      const ultimoDia = new Date(anio, mesNum, 0).getDate();
      const fechaVenc = new Date(anio, mesNum - 1, ultimoDia);

      const cuotaRef = admin
        .firestore()
        .collection("usuarios")
        .doc(uid)
        .collection("cuotas")
        .doc(mes); // Usar solo el mes como docId: "01", "02", etc.

      batch.set(cuotaRef, {
        mes: mes,
        anio: anio,
        monto: MONTO_CUOTA,
        estado: "pendiente",
        fecha_vencimiento: admin.firestore.Timestamp.fromDate(fechaVenc),
        fecha_pago: null,
        mercado_pago_preference_id: "",
        mercado_pago_payment_id: "",
        created_at: ahora,
      });
    });

    // Actualizar usuario con estado_cuota = "deudor" inicial
    const userRef = admin.firestore().collection("usuarios").doc(uid);
    batch.update(userRef, {
      estado_cuota: "deudor",
      ultima_cuota_pagada: null,
    });

    await batch.commit();
    console.log(`✅ Cuotas inicializadas para ${uid}`);
  } catch (error) {
    console.error(`❌ Error inicializando cuotas para ${uid}:`, error);
    throw error;
  }
});

// ==================== FUNCIÓN 2: Inicializar cuotas por HTTP (para socios) ====================
exports.inicializarCuotasPorSocioHTTP = onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, HEAD, OPTIONS, POST");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  try {
    console.log("🔵 [inicializarCuotasPorSocioHTTP] Iniciando...");

    // Obtener el token del header Authorization
    const authHeader = req.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      console.error("❌ Sin header Authorization válido");
      return res.status(401).json({ error: "No autorizado" });
    }

    const idToken = authHeader.substring(7);

    // Verificar el token con Firebase
    let decodedToken;
    try {
      decodedToken = await admin.auth().verifyIdToken(idToken);
    } catch (error) {
      console.error("❌ Token inválido:", error.message);
      return res.status(401).json({ error: "Token inválido" });
    }

    const uid = decodedToken.uid;
    console.log(`🔵 Inicializando cuotas para: ${uid}`);

    try {
      const batch = admin.firestore().batch();
      const ahora = admin.firestore.Timestamp.now();

      // Crear cuotas de Dic 2025 a Mar 2026
      const mesesConfig = [
        { mes: "12", anio: 2025 },
        { mes: "01", anio: 2026 },
        { mes: "02", anio: 2026 },
        { mes: "03", anio: 2026 },
      ];

      mesesConfig.forEach(({ mes, anio }) => {
        const mesNum = parseInt(mes);
        const ultimoDia = new Date(anio, mesNum, 0).getDate();
        const fechaVenc = new Date(anio, mesNum - 1, ultimoDia);

        const cuotaRef = admin
          .firestore()
          .collection("usuarios")
          .doc(uid)
          .collection("cuotas")
          .doc(mes);

        batch.set(cuotaRef, {
          mes: mes,
          anio: anio,
          monto: MONTO_CUOTA,
          estado: "pendiente",
          fecha_vencimiento: admin.firestore.Timestamp.fromDate(fechaVenc),
          fecha_pago: null,
          mercado_pago_preference_id: "",
          mercado_pago_payment_id: "",
          created_at: ahora,
        });
      });

      // Actualizar usuario
      const userRef = admin.firestore().collection("usuarios").doc(uid);
      batch.update(userRef, {
        estado_cuota: "deudor",
        ultima_cuota_pagada: null,
      });

      await batch.commit();
      console.log(`✅ Cuotas inicializadas para ${uid}`);

      res.status(200).json({
        success: true,
        message: "Cuotas inicializadas correctamente",
      });
    } catch (error) {
      console.error(`❌ Error en batch: ${error.message}`);
      res.status(500).json({
        error: "Error inicializando cuotas",
        details: error.message,
      });
    }
  } catch (error) {
    console.error("❌ Error:", error.message);
    res.status(500).json({
      error: "Error del servidor",
      details: error.message,
    });
  }
});

// ==================== FUNCIÓN 3: Webhook para confirmar pagos ====================
exports.webhookMercadoPago = onRequest(async (req, res) => {
  console.log("🔔 Webhook recibido:", req.query);

  try {
    const data = req.query;

    if (data.type === "payment") {
      const paymentId = data.data.id;

      // Obtener detalles del pago de Mercado Pago
      const payment = await axios.get(
        `https://api.mercadopago.com/v1/payments/${paymentId}`,
        {
          headers: {
            Authorization: `Bearer ${MERCADO_PAGO_ACCESS_TOKEN}`,
          },
        }
      );

      console.log(`💳 Pago ${paymentId}: ${payment.data.status}`);

      if (payment.data.status === "approved") {
        const externalRef = payment.data.external_reference; // "cuota_uid_mes_2025"
        const parts = externalRef.split("_");
        
        if (parts.length < 3) {
          console.error("❌ external_reference inválido:", externalRef);
          return res.sendStatus(400);
        }

        const uid = parts[1];
        const mes = parts[2];

        console.log(`✅ Pago confirmado: ${uid} - ${mes}`);

        // Actualizar Firestore
        await admin
          .firestore()
          .collection("usuarios")
          .doc(uid)
          .collection("cuotas")
          .doc(mes)
          .update({
            estado: "pagado",
            fecha_pago: admin.firestore.FieldValue.serverTimestamp(),
            mercado_pago_payment_id: paymentId,
          });

        // Actualizar estado en usuario
        await admin
          .firestore()
          .collection("usuarios")
          .doc(uid)
          .update({
            estado_cuota: "activo",
            ultima_cuota_pagada: mes,
          });

        console.log(`✅ Cuota marcada como pagada: ${uid} - ${mes}`);
      } else if (payment.data.status === "rejected") {
        console.log(`❌ Pago rechazado: ${paymentId}`);
        // Opcionalmente, puedes actualizar a "pendiente" de nuevo
      }
    }

    res.sendStatus(200);
  } catch (error) {
    console.error("❌ Error en webhook:", error.message);
    res.sendStatus(500);
  }
});

// ==================== FUNCIÓN 4: Inicializar cuotas manualmente (Admin) ====================
exports.inicializarCuotasPorSocio = onCall(async (request) => {
  // Verificar que sea admin
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "No autenticado");
  }

  const data = request.data;
  const adminDoc = await admin
    .firestore()
    .collection("usuarios")
    .doc(request.auth.uid)
    .get();

  if (adminDoc.data()?.rol !== "admin") {
    throw new HttpsError("permission-denied", "Solo admin puede hacer esto");
  }

  const uid = data.uid;
  console.log(`Admin solicitando inicializar cuotas para: ${uid}`);

  try {
    const batch = admin.firestore().batch();
    const ahora = admin.firestore.Timestamp.now();

    // Crear cuotas de Nov 2025 (11) a Oct 2026 (10)
    const mesesConfig = [
      { mes: "11", anio: 2025 }, // Noviembre 2025
      { mes: "12", anio: 2025 }, // Diciembre 2025
      { mes: "01", anio: 2026 }, // Enero 2026
      { mes: "02", anio: 2026 }, // Febrero 2026
      { mes: "03", anio: 2026 }, // Marzo 2026
      { mes: "04", anio: 2026 }, // Abril 2026
      { mes: "05", anio: 2026 }, // Mayo 2026
      { mes: "06", anio: 2026 }, // Junio 2026
      { mes: "07", anio: 2026 }, // Julio 2026
      { mes: "08", anio: 2026 }, // Agosto 2026
      { mes: "09", anio: 2026 }, // Septiembre 2026
      { mes: "10", anio: 2026 }, // Octubre 2026
    ];

    mesesConfig.forEach(({ mes, anio }) => {
      // Calcular fecha de vencimiento (último día del mes)
      const mesNum = parseInt(mes);
      const ultimoDia = new Date(anio, mesNum, 0).getDate();
      const fechaVenc = new Date(anio, mesNum - 1, ultimoDia);

      const cuotaRef = admin
        .firestore()
        .collection("usuarios")
        .doc(uid)
        .collection("cuotas")
        .doc(mes); // Usar solo el mes como docId: "01", "02", etc.

      batch.set(
        cuotaRef,
        {
          mes: mes,
          anio: anio,
          monto: MONTO_CUOTA,
          estado: "pendiente",
          fecha_vencimiento: admin.firestore.Timestamp.fromDate(fechaVenc),
          fecha_pago: null,
          mercado_pago_preference_id: "",
          mercado_pago_payment_id: "",
          created_at: ahora,
        },
        { merge: true }
      );
    });

    // Actualizar usuario con estado_cuota = "deudor" inicial
    const userRef = admin.firestore().collection("usuarios").doc(uid);
    batch.update(userRef, {
      estado_cuota: "deudor",
      ultima_cuota_pagada: null,
    });

    await batch.commit();
    console.log(`✅ Cuotas creadas para ${uid}`);

    return {
      success: true,
      message: `Cuotas creadas para socio ${uid}`,
    };
  } catch (error) {
    console.error(`❌ Error:`, error);
    throw new HttpsError("internal", error.message);
  }
});

// ==================== FUNCIÓN 5: Resetear cuotas de todos los socios ====================
exports.resetearCuotasTodosLosUsuarios = onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, HEAD, OPTIONS, POST");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  try {
    console.log("🔵 [resetearCuotasTodosLosUsuarios] Iniciando reset global...");

    // Verificar token si existe, pero permitir ejecución sin él para desarrollo
    let decodedToken = null;
    const authHeader = req.get("Authorization");
    if (authHeader && authHeader.startsWith("Bearer ")) {
      const idToken = authHeader.substring(7);
      try {
        decodedToken = await admin.auth().verifyIdToken(idToken);
        console.log(`✅ Autenticado como: ${decodedToken.uid}`);
      } catch (error) {
        console.error("⚠️  Token inválido, continuando sin autenticación");
      }
    }

    // Obtener todos los usuarios
    const usuariosSnapshot = await admin.firestore().collection("usuarios").get();
    const ahora = admin.firestore.Timestamp.now();
    let contadorActualizados = 0;

    const mesesConfig = [
      { mes: "12", anio: 2025 },
      { mes: "01", anio: 2026 },
      { mes: "02", anio: 2026 },
      { mes: "03", anio: 2026 },
    ];

    for (const usuarioDoc of usuariosSnapshot.docs) {
      const uid = usuarioDoc.id;
      const userData = usuarioDoc.data();

      // Solo resetear socios
      if (userData.rol !== "socio") {
        console.log(`Saltando ${uid} - No es socio`);
        continue;
      }

      try {
        const batch = admin.firestore().batch();

        // Eliminar cuotas antiguas
        const cuotasSnapshot = await admin
          .firestore()
          .collection("usuarios")
          .doc(uid)
          .collection("cuotas")
          .get();

        cuotasSnapshot.docs.forEach((doc) => {
          batch.delete(doc.ref);
        });

        // Crear cuotas nuevas
        mesesConfig.forEach(({ mes, anio }) => {
          const mesNum = parseInt(mes);
          const ultimoDia = new Date(anio, mesNum, 0).getDate();
          const fechaVenc = new Date(anio, mesNum - 1, ultimoDia);

          const cuotaRef = admin
            .firestore()
            .collection("usuarios")
            .doc(uid)
            .collection("cuotas")
            .doc(mes);

          batch.set(cuotaRef, {
            mes: mes,
            anio: anio,
            monto: MONTO_CUOTA,
            estado: "pendiente",
            fecha_vencimiento: admin.firestore.Timestamp.fromDate(fechaVenc),
            fecha_pago: null,
            mercado_pago_preference_id: "",
            mercado_pago_payment_id: "",
            created_at: ahora,
          });
        });

        // Resetear estado del usuario
        const userRef = admin.firestore().collection("usuarios").doc(uid);
        batch.update(userRef, {
          estado_cuota: "deudor",
          ultima_cuota_pagada: null,
        });

        await batch.commit();
        contadorActualizados++;
        console.log(`✅ Cuotas reseteadas para ${uid}`);
      } catch (error) {
        console.error(`❌ Error reseteando cuotas para ${uid}:`, error);
      }
    }

    return res.status(200).json({
      success: true,
      mensaje: `Cuotas reseteadas para ${contadorActualizados} usuarios`,
      usuariosActualizados: contadorActualizados,
    });
  } catch (error) {
    console.error(`❌ Error:`, error);
    return res.status(500).json({ error: error.message });
  }
});
