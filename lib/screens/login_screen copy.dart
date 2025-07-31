// lib/screens/login_screen.dart
// Esta pantalla permite a los usuarios iniciar sesión o registrarse
// utilizando su correo electrónico y contraseña.

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Instancia del servicio de autenticación.
  final AuthService _auth = AuthService();
  // Clave global para el formulario, utilizada para validar los campos.
  final _formKey = GlobalKey<FormState>();

  // Variables para almacenar el correo electrónico y la contraseña ingresados por el usuario.
  String _email = '';
  String _password = '';
  // Variable para mostrar mensajes de error al usuario.
  String _error = '';
  // Bandera para alternar entre el modo de inicio de sesión y registro.
  bool _isLoginMode = true; // true para iniciar sesión, false para registrarse

  // Controladores y animaciones para el efecto de desvanecimiento
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Inicializa el AnimationController con una duración de 500 milisegundos.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Define la animación de desvanecimiento de 0.0 (transparente) a 1.0 (opaco).
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    // Inicia la animación cuando la pantalla se carga.
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant LoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinicia la animación cuando el modo de login/registro cambia.
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    // Libera los recursos del controlador de animación cuando el widget se elimina.
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo general del Scaffold
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Sección superior con el título
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40.0,
                  horizontal: 24.0,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDD835), // Color amarillo de la imagen
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(
                      10.0,
                    ), // Menos redondeado en la parte inferior para la transición
                    bottomRight: Radius.circular(10.0),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _isLoginMode ? 'Bienvenido de nuevo' : 'Crea tu cuenta',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isLoginMode
                          ? 'Inicia sesión para continuar'
                          : 'Regístrate para empezar',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Formulario de inicio de sesión/registro
              // Envuelto en FadeTransition para la animación de desvanecimiento
              FadeTransition(
                opacity: _animation,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // Campo de texto para el correo electrónico.
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            labelStyle: const TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide
                                  .none, // Elimina el borde predeterminado
                            ),
                            filled: true,
                            fillColor: Colors.grey[200], // Fondo gris claro
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Color(0xFFE53935),
                            ), // Icono rojo
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: Color(0xFF1976D2),
                                width: 2.0,
                              ), // Borde azul al enfocar
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => val!.isEmpty
                              ? 'Por favor, ingresa un correo electrónico'
                              : null,
                          onChanged: (val) {
                            setState(
                              () => _email = val.trim(),
                            ); // Eliminar espacios en blanco
                          },
                        ),
                        const SizedBox(height: 20),
                        // Campo de texto para la contraseña.
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: const TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(0xFFE53935),
                            ), // Icono rojo
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: Color(0xFF1976D2),
                                width: 2.0,
                              ), // Borde azul al enfocar
                            ),
                          ),
                          obscureText:
                              true, // Oculta el texto para la contraseña.
                          validator: (val) => val!.length < 6
                              ? 'La contraseña debe tener al menos 6 caracteres'
                              : null,
                          onChanged: (val) {
                            setState(
                              () => _password = val.trim(),
                            ); // Eliminar espacios en blanco
                          },
                        ),
                        const SizedBox(height: 30),
                        // Botón principal para iniciar sesión o registrarse.
                        ElevatedButton(
                          onPressed: () async {
                            // Valida el formulario antes de intentar la autenticación.
                            if (_formKey.currentState!.validate()) {
                              setState(
                                () => _error = '',
                              ); // Limpia errores anteriores.
                              User? user;
                              if (_isLoginMode) {
                                // Si está en modo de inicio de sesión, llama al método signIn.
                                user = await _auth.signIn(_email, _password);
                                if (user == null) {
                                  setState(
                                    () => _error =
                                        'Error al iniciar sesión. Verifica tus credenciales.',
                                  );
                                }
                              } else {
                                // Si está en modo de registro, llama al método signUp.
                                user = await _auth.signUp(_email, _password);
                                if (user == null) {
                                  setState(
                                    () => _error =
                                        'Error al registrarse. Intenta con otro correo.',
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            backgroundColor: const Color(
                              0xFF1976D2,
                            ), // Color azul de la imagen
                            foregroundColor: Colors.white,
                            elevation: 5,
                          ),
                          child: Text(
                            _isLoginMode ? 'Iniciar Sesión' : 'Registrarse',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Botón para alternar entre iniciar sesión y registrarse.
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLoginMode = !_isLoginMode; // Cambia el modo.
                              _formKey.currentState
                                  ?.reset(); // Limpia los campos del formulario.
                              _email = '';
                              _password = '';
                              _error = ''; // Limpia cualquier error.
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(
                              0xFFE53935,
                            ), // Color rojo de la imagen
                          ),
                          child: Text(
                            _isLoginMode
                                ? '¿No tienes una cuenta? Regístrate aquí.'
                                : '¿Ya tienes una cuenta? Inicia sesión aquí.',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Muestra el mensaje de error si existe.
                        Text(
                          _error,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
