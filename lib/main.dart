import 'package:flutter/material.dart';
import 'particle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Particles Demo',
      theme: ThemeData.dark(),
      home: const ParticlesDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ParticlesDemo extends StatefulWidget {
  const ParticlesDemo({super.key});

  @override
  State<ParticlesDemo> createState() => _ParticlesDemoState();
}

class _ParticlesDemoState extends State<ParticlesDemo> {
  Color _particleColor = Colors.white;
  int _count = 300;
  double _spread = 8;
  double _speed = 0.05;
  double _baseSize = 1.5;
  double _parallaxStrength = 30.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // Space gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF001122),
                  Color(0xFF000000),
                ],
              ),
            ),
          ),

          // Particles background
          Positioned.fill(
            child: ParticlesWidget(
              count: _count,
              spread: _spread,
              speed: _speed,
              baseSize: _baseSize,
              color: _particleColor,
              minOpacity: 0.2,
              maxOpacity: 1.0,
              parallaxStrength: _parallaxStrength,
            ),
          ),

          // Instructions
          const Positioned(
            top: 20,
            right: 20,
            child: Text(
              'Move your mouse to explore the stars',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Controls panel
          Positioned(
            left: 20,
            top: 50,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Space Particles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Color picker
                  const Text('Color', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _colorButton(Colors.white),
                      _colorButton(Colors.blue),
                      _colorButton(Colors.purple),
                      _colorButton(Colors.pink),
                      _colorButton(Colors.cyan),
                      _colorButton(Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Count slider
                  _buildSlider(
                    'Count',
                    _count.toDouble(),
                    50,
                    500,
                    (value) => setState(() => _count = value.round()),
                  ),

                  // Parallax strength slider
                  _buildSlider(
                    'Parallax Strength',
                    _parallaxStrength,
                    0,
                    100,
                    (value) => setState(() => _parallaxStrength = value),
                  ),

                  // Spread slider
                  _buildSlider(
                    'Spread',
                    _spread,
                    1,
                    20,
                    (value) => setState(() => _spread = value),
                  ),

                  // Speed slider
                  _buildSlider(
                    'Speed',
                    _speed,
                    0.01,
                    0.5,
                    (value) => setState(() => _speed = value),
                  ),

                  // Base Size slider
                  _buildSlider(
                    'Base Size',
                    _baseSize,
                    0.5,
                    5,
                    (value) => setState(() => _baseSize = value),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorButton(Color color) {
    final isSelected = _particleColor == color;
    return GestureDetector(
      onTap: () => setState(() => _particleColor = color),
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        SizedBox(
          width: 200,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.1),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
