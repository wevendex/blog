import 'dart:math';
import 'dart:typed_data';

class ToneGenerator {
  static Uint8List generateTone({required int freq, double durationSeconds = 0.2, int sampleRate = 44100}) {
    final sampleCount = (durationSeconds * sampleRate).toInt();
    final bytes = BytesBuilder();

    // WAV header (PCM 16bit, mono)
    final dataChunkSize = sampleCount * 2;
    final fileSize = 36 + dataChunkSize;

    void writeString(String s) => bytes.add(s.codeUnits);
    void writeInt32LE(int value) => bytes.add([value & 0xFF, (value >> 8) & 0xFF, (value >> 16) & 0xFF, (value >> 24) & 0xFF]);
    void writeInt16LE(int value) => bytes.add([value & 0xFF, (value >> 8) & 0xFF]);

    writeString('RIFF');
    writeInt32LE(fileSize);
    writeString('WAVE');
    writeString('fmt ');
    writeInt32LE(16); // Subchunk1Size for PCM
    writeInt16LE(1); // AudioFormat PCM
    writeInt16LE(1); // NumChannels
    writeInt32LE(sampleRate);
    writeInt32LE(sampleRate * 2); // ByteRate = SampleRate*NumChannels*BitsPerSample/8
    writeInt16LE(2); // BlockAlign = NumChannels*BitsPerSample/8
    writeInt16LE(16); // BitsPerSample
    writeString('data');
    writeInt32LE(dataChunkSize);

    // Samples
    for (int i = 0; i < sampleCount; i++) {
      final t = i / sampleRate;
      final amplitude = (sin(2 * pi * freq * t) * 0x7FFF).toInt();
      writeInt16LE(amplitude);
    }

    return bytes.toBytes();
  }
}