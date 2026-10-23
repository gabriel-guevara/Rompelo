import 'package:flutter/material.dart';

/// Muestra un aviso breve en las pantallas de configuración (p. ej. cuando
/// una regla impide quitar el último mazo). Reemplaza el anterior para que
/// los toques rápidos no encolen varios SnackBars.
void showConfigMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
