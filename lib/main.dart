import 'package:flutter/material.dart';
// firebase_core initialized in servicios/firebase_servicio.dart
import 'pantallas/landing_page.dart';
import 'pantallas/login.dart';
import 'pantallas/admin_socios.dart';
import 'pantallas/admin_eventos.dart';
import 'pantallas/admin_inicio.dart';
import 'pantallas/socio_inicio.dart';
import 'pantallas/socio_eventos.dart';
import 'pantallas/perfil_socio.dart';
import 'pantallas/contactar_admin.dart';
import 'pantallas/admin_asuntos.dart';
import 'servicios/firebase_servicio.dart';
import 'package:provider/provider.dart';
import 'servicios/auth_servicio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inicializarFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gestión Socios - Club',
          theme: ThemeData(
          // Palette basada en los tonos de azul que proporcionaste
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF0404B9), // #0404b9 (vibrante)
            onPrimary: Colors.white,
            secondary: Color(0xFF001D5A), // #001d5a
            onSecondary: Colors.white,
            error: Colors.red,
            onError: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0404B9),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0404B9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(88, 48),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF000187), // #000187
            foregroundColor: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Color(0xFF001D5A)),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LandingPage(),
          '/login': (context) => const LoginPantalla(),
          '/admin_inicio': (context) => const AdminInicioPantalla(),
          '/admin_socios': (context) => const AdminSociosPantalla(),
          '/admin_eventos': (context) => const AdminEventosPantalla(),
          '/socio_inicio': (context) => const SocioInicioPantalla(),
          '/socio_eventos': (context) => const SocioEventosPantalla(),
          '/perfil': (context) => const PerfilSocioPantalla(),
          '/contactar_admin': (context) => const ContactarAdminPantalla(),
          '/admin_asuntos': (context) => const AdminAsuntosPantalla(),
        },
      ),
    );
  }
}
