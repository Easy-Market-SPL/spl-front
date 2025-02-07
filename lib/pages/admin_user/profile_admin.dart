import 'package:flutter/material.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Fondo gris
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const AdminHeader(),

              const SizedBox(height: 20),

              // Lista de usuarios
              const Text(
                "Lista de usuarios",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // Lista de tarjetas de usuario
              Expanded(
                child: ListView(
                  children: const [
                    UserCard(
                      name: "Esteban Salazar",
                      role: "Administrador",
                      initial: "E",
                      onEdit: null,
                      onDelete: null,
                    ),
                    UserCard(
                      name: "Camilo Mora",
                      role: "Domiciliario",
                      initial: "C",
                      onEdit: null,
                      onDelete: null,
                    ),
                  ],
                ),
              ),

              // Botón para añadir usuario
              Center(
                child: AddUserButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AddUserDialog();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        CircleAvatar(
          backgroundColor: Colors.grey[400],
          radius: 40,
          child: Text(
            "JF", // Iniciales
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Título y subtítulo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Panel de Administración",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Gestiona los usuarios de tu empresa",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class UserCard extends StatelessWidget {
  final String name;
  final String role;
  final String initial;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserCard({
    super.key,
    required this.name,
    required this.role,
    required this.initial,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          role,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class AddUserButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddUserButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          "Añadir Usuario",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class AddUserDialog extends StatelessWidget {
  const AddUserDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Crear nuevo usuario",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Nombre
            const CustomInput(
              hintText: "Nombre completo",
              labelText: "Nombre",
            ),
            const SizedBox(height: 16),

            // Correo
            const CustomInput(
              hintText: "Correo Electrónico",
              labelText: "Correo",
            ),
            const SizedBox(height: 16),

            // Contraseña
            const CustomInput(
              hintText: "Tu contraseña",
              labelText: "Contraseña",
              isPassword: true,
            ),
            const SizedBox(height: 16),

            // Seleccionar Rol
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Rol",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                    value: "Administrador", child: Text("Administrador")),
                DropdownMenuItem(
                    value: "Gestor de productos",
                    child: Text("Gestor de productos")),
                DropdownMenuItem(
                    value: "Domiciliario", child: Text("Domiciliario")),
                DropdownMenuItem(value: "Soporte", child: Text("Soporte")),
              ],
              onChanged: (value) {
                // Manejar cambio de rol
                print("Rol seleccionado: $value");
              },
            ),
            const SizedBox(height: 24),

            // Botón Guardar cambios
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  print("Usuario creado");
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Guardar cambios",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomInput extends StatelessWidget {
  final String hintText;
  final String labelText;
  final bool isPassword;

  const CustomInput({
    super.key,
    required this.hintText,
    required this.labelText,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
