import 'package:flutter/material.dart';
import 'core/constants/app_color.dart';
// 

class GameItem {
 final String id;
 final String title;
 final String description;
 final IconData icon;
 final String routeName;
 const GameItem({
 required this.id,
 required this.title,
 required this.description,
 required this.icon,
 required this.routeName,
 });
}

void main() {
 WidgetsFlutterBinding.ensureInitialized();
 runApp(const RompeloApp());
}

class RompeloApp extends StatelessWidget {
 const RompeloApp({super.key});
 @override
 Widget build(BuildContext context) {
 return MaterialApp(
 title: 'Rómpelo App',
 debugShowCheckedModeBanner: false,
 theme: ThemeData(
 useMaterial3: true,
 colorSchemeSeed: AppColors.primaryPurple,
 scaffoldBackgroundColor: AppColors.surfaceLight,
 fontFamily: 'Roboto',
 ),
 home: const MenuScreen(),
 );
 }
}

class MenuScreen extends StatelessWidget {
 const MenuScreen({super.key});
 // Lista mock de minijuegos basados en el documento del proyecto Rómpelo
 final List<GameItem> _juegosDisponibles = const [
 GameItem(
 id: '1',
 title: 'Charadas',
 description: 'Adivina palabras organizadas por categorías con límite de tiempo por turno.',
 icon: Icons.movie_creation_rounded,
 routeName: '/charades',
 ),
 GameItem(
 id: '2',
 title: 'Trivia',
 description: 'Preguntas y respuestas agrupadas por temas para evaluar conocimientos en grupo.',
 icon: Icons.quiz_rounded,
 routeName: '/trivia',
 ),
 GameItem(
 id: '3',
 title: 'Impostor',
 description: 'Pasa el celular de mano en mano de forma privada para descubrir quién es el impostor.',
 icon: Icons.security_rounded,
 routeName: '/impostor',
 ),
 ];
 @override
 Widget build(BuildContext context) {
 return Scaffold(
 appBar: AppBar(
 title: const Text(
 'Rómpelo | Menú Principal',
 style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
 ),
 backgroundColor: AppColors.primaryPurple,
 centerTitle: true,
 ),
 body: SafeArea(
 child: Padding(
 padding: const EdgeInsets.all(16.0),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const Text(
 'Selecciona una Dinámica',
 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
 ),
 const SizedBox(height: 6),
 const Text(
 'Usa un único dispositivo compartido para romper el hielo en grupo (100% Offline):',
 style: TextStyle(fontSize: 14, color: Colors.black54),
 ),
 const SizedBox(height: 20),
 
 // Listado interactivo de minijuegos
 Expanded(
 child: ListView.builder(
 itemCount: _juegosDisponibles.length,
 itemBuilder: (context, index) {
 final juego = _juegosDisponibles[index];
 return Card(
 margin: const EdgeInsets.only(bottom: 16),
 elevation: 2,
 color: AppColors.cardBackground,
 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
 child: Padding(
 padding: const EdgeInsets.all(16.0),
 child: Row(
 children: [
 Container(
 padding: const EdgeInsets.all(12),
 decoration: BoxDecoration(
 color: AppColors.primaryPurple,
borderRadius: BorderRadius.circular(12),
 ),
 child: Icon(juego.icon, color: Colors.white, size: 32),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
children: [
 Text(
 juego.title,
 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: 
AppColors.textDark),
 ),
const SizedBox(height: 4),
Text(
 juego.description,
style: const TextStyle(fontSize: 13, color: Colors.black87),
 ),
 ],
 ),
 ),
 IconButton(
 icon: const Icon(Icons.play_arrow_rounded, color: AppColors.accentOrange, 
size: 32),
 onPressed: () {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text('Configurando partida para: ${juego.title}'),
 duration: const Duration(seconds: 1),
 ),
 );
 },
 ),
 ],
 ),
 ),
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