// Genera los efectos de sonido de la app en `assets/sounds/` (WAV mono,
// 22 050 Hz, 16 bits). Son tonos sintetizados: propios, livianos y sin
// licencias de terceros.
//
// Uso (desde la raíz del proyecto):  dart run tool/generate_sounds.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const int sampleRate = 22050;

/// Una nota: frecuencia (Hz), inicio y duración (s), volumen 0–1.
typedef Note = ({double freq, double start, double length, double volume});

Note n(double freq, double start, double length, [double volume = 0.6]) =>
    (freq: freq, start: start, length: length, volume: volume);

/// Mezcla las notas con una envolvente suave (sin "clics") y armónicos
/// leves para que no suene a pitido plano.
Float64List render(List<Note> notes, {bool buzzy = false}) {
  final total = notes.map((x) => x.start + x.length).reduce(max) + 0.05;
  final out = Float64List((total * sampleRate).ceil());
  for (final note in notes) {
    final first = (note.start * sampleRate).round();
    final count = (note.length * sampleRate).round();
    for (var i = 0; i < count && first + i < out.length; i++) {
      final t = i / sampleRate;
      final attack = min(1.0, t / 0.008);
      final release = min(1.0, (note.length - t) / 0.06);
      final env = max(0.0, min(attack, release)) * exp(-t * 2.2);
      final phase = 2 * pi * note.freq * t;
      final wave = buzzy
          ? (sin(phase) + sin(3 * phase) / 3 + sin(5 * phase) / 5)
          : (sin(phase) + 0.3 * sin(2 * phase) + 0.12 * sin(3 * phase));
      out[first + i] += wave * env * note.volume * 0.55;
    }
  }
  return out;
}

void writeWav(String path, Float64List samples) {
  final data = ByteData(44 + samples.length * 2);
  void ascii(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  data.setUint32(4, 36 + samples.length * 2, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little); // tamaño del bloque fmt
  data.setUint16(20, 1, Endian.little); // PCM
  data.setUint16(22, 1, Endian.little); // mono
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    final v = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    data.setInt16(44 + i * 2, v, Endian.little);
  }
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(data.buffer.asUint8List());
}

void main() {
  const dir = 'assets/sounds';
  final sounds = <String, Float64List>{
    // Acierto: dos notas que suben.
    'correct': render([n(784, 0, 0.12), n(1175, 0.09, 0.22)]),
    // Pasar / fallar: dos notas que bajan.
    'pass': render([n(392, 0, 0.12, 0.5), n(294, 0.1, 0.2, 0.5)]),
    // 3-2-1 y ¡ya!
    'countdown': render([
      n(880, 0, 0.16),
      n(880, 1, 0.16),
      n(880, 2, 0.16),
      n(1319, 3, 0.4, 0.7),
    ]),
    // Se acabó el tiempo: zumbido grave.
    'time_up': render([n(196, 0, 0.7, 0.7)], buzzy: true),
    // Revelar al impostor: tres notas de suspenso.
    'reveal': render([
      n(294, 0, 0.18),
      n(370, 0.2, 0.18),
      n(440, 0.4, 0.18),
      n(587, 0.6, 0.6, 0.7),
    ]),
    // Fin de partida: arpegio de fanfarria.
    'win': render([
      n(523, 0, 0.16),
      n(659, 0.14, 0.16),
      n(784, 0.28, 0.16),
      n(1047, 0.42, 0.7, 0.7),
    ]),
    // Toque corto (pasar el celular, robar turno).
    'tap': render([n(1047, 0, 0.06, 0.4)]),
  };
  sounds.forEach((name, samples) => writeWav('$dir/$name.wav', samples));
  stdout.writeln('Generados ${sounds.length} sonidos en $dir/');
}
