import 'package:flutter/material.dart';

class DisplayTiempo extends StatelessWidget {
  final Duration duration;
  final TextStyle? style;

  const DisplayTiempo({
    super.key,
    required this.duration,
    this.style,
  });

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDecimals(int n) => (n / 100).toStringAsFixed(2).split('.').last.padLeft(2, '0');

    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    final centiseconds = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');

    return '$minutes:$seconds.$centiseconds';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(duration),
      style: style ?? const TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
      textAlign: TextAlign.center,
    );
  }
}
