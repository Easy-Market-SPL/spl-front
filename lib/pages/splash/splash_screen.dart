import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spl_front/services/api/product_service.dart';
import 'package:spl_front/services/api/user_service.dart';
import 'package:spl_front/services/gui/stripe/stripe_service.dart';
import 'package:spl_front/services/supabase/supabase_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // Controlador de animación para efectos visuales
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Estado de inicialización de servicios
  bool _initialized = false;
  String _statusMessage = "Iniciando...";

  @override
  void initState() {
    super.initState();
    
    // Configurar animación
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.forward();
    
    // Iniciar la carga de servicios
    _initializeServices();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Método para inicializar todos los servicios
  Future<void> _initializeServices() async {
    int retryCount = 0;
    const maxRetries = 3;

    Future<bool> tryInitialize() async {
      try {
        setState(() => _statusMessage = "Cargando configuración...");
        await dotenv.load(fileName: '.env');

        setState(() => _statusMessage = "Conectando con Supabase...");
        await SupabaseConfig.initializeSupabase();

        setState(() => _statusMessage = "Configurando servicios de usuario...");
        await UserService.initializeUserService();

        setState(() => _statusMessage = "Configurando servicios de productos...");
        await ProductService.initializeProductService();

        setState(() => _statusMessage = "Configurando servicios de pago...");
        StripeService().init();

        return true;
      } catch (e) {
        debugPrint('Error en intento #${retryCount+1}: $e');
        return false;
      }
    }

    bool success = false;
    while (!success && retryCount < maxRetries) {
      success = await tryInitialize();
      if (!success) {
        retryCount++;
        setState(() => _statusMessage = "Reintentando ($retryCount de $maxRetries)...");
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (success) {
      setState(() {
        _initialized = true;
        _statusMessage = "¡Listo!";
      });

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('');
      }
    } else {
      // Mostrar error fatal
      setState(() => _statusMessage = "Error al inicializar la aplicación");
      _showFatalErrorDialog();
    }
  }

  void _showFatalErrorDialog() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Error de inicialización'),
          content: const Text('No se pudieron inicializar los servicios necesarios. Verifica tu conexión a Internet y vuelve a intentarlo.'),
          actions: [
            TextButton(
              onPressed: () {
                // Reintentar inicialización
                _initializeServices();
                Navigator.of(context).pop();
              },
              child: const Text('Reintentar'),
            ),
            TextButton(
              onPressed: () => exit(0), // import 'dart:io';
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: _animation,
                child: Image.asset(
                  'assets/images/logo.png', // Asegúrate de tener este archivo
                  width: 200,
                  height: 200,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Texto de Easy Market
            Text(
              'Easy Market',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Indicador de carga
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                value: _initialized ? 1.0 : null, // Determinado cuando termina
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Mensaje de estado
            Text(
              _statusMessage,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}