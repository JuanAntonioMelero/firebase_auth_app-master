import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  _GestionUsuariosScreenPageState createState() => _GestionUsuariosScreenPageState();
}

class _GestionUsuariosScreenPageState extends State<GestionUsuariosScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'user'; // valor por defecto

  Widget getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Text('👑', style: TextStyle(fontSize: 24));
      case 'user':
        return Text('👤', style: TextStyle(fontSize: 24));
      case 'guest':
        return Text('👻', style: TextStyle(fontSize: 24));
      default:
        return Text('❓', style: TextStyle(fontSize: 24));
    }
  }

  void createFullUse({
required BuildContext context,
  required String name,
  required String email,
  required String password,
  required String role,
  }

  ) async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    try {
 // 1. Crear usuario en Firebase Auth
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  // 2. Actualizar displayName
    await userCredential.user!.updateDisplayName(name);

    // 3. Guardar info adicional en Firestore
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      'name': name,
      'email': email,
      'role': role,
    });



      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Usuario creado: $name'), duration: Duration(seconds: 2)),
      );

      nameController.clear();
      setState(() {
        selectedRole = 'user';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Error al crear usuario: $e'), duration: Duration(seconds: 2)),
      );
    }
  }

  void updateUserRole(String userId, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'role': newRole});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rol actualizado a "$newRole"'), duration: Duration(seconds: 2)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar rol: $e'), duration: Duration(seconds: 2)),
      );
    }
  }

  void confirmDeleteUser(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('¿Eliminar usuario?'),
          content: Text('Esta acción no se puede deshacer. ¿Estás seguro?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await FirebaseFirestore.instance.collection('users').doc(userId).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Usuario eliminado'), duration: Duration(seconds: 2)),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('⚠️ Error al eliminar usuario: $e'), duration: Duration(seconds: 2)),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Usuarios')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 📋 Formulario para crear usuario
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crear nuevo usuario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                  ),
                   TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'email'),
                  ),
                   TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'password'),
                  ),
                  DropdownButton<String>(
                    value: selectedRole,
                    items: ['admin', 'user', 'guest'].map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedRole = value;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    child: Text('Crear usuario'),
                    onPressed: () {
                      // You should collect email and password from input fields (add controllers for them)
                      // For now, using placeholders:
                     
                      createFullUse(
                        context: context,
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        role: selectedRole,
                      );
                    },
                  ),
                  Divider(),
                ],
              ),
            ),

            // 🔍 Lista de usuarios
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final users = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userId = user.id;
                    final role = user['role'];
                    final name = user['name'] ?? 'Sin nombre';

                    return ListTile(
                      leading: getRoleIcon(role),
                      title: Text(name),
                      subtitle: Text('Rol: $role'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            value: role,
                            underline: Container(),
                            items: ['admin', 'user', 'guest'].map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newRole) {
                              if (newRole != null && newRole != role) {
                                updateUserRole(userId, newRole);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => confirmDeleteUser(userId),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
