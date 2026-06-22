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
      title: 'Flutter Space Particles',
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
  // Particle properties
  int _particleCount = 200;
  double _particleSpread = 10.0;
  double _speed = 0.1;
  double _particleBaseSize = 100.0;
  bool _moveParticlesOnHover = true;
  double _particleHoverFactor = 1.0;
  bool _alphaParticles = false;
  double _sizeRandomness = 1.0;
  double _cameraDistance = 20.0;
  bool _disableRotation = false;
  
  final List<Color> _particleColors = [Colors.white, Colors.white, Colors.white];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // Particles background
          Positioned.fill(
            child: ParticlesWidget(
              particleCount: _particleCount,
              particleSpread: _particleSpread,
              speed: _speed,
              particleColors: _particleColors,
              moveParticlesOnHover: _moveParticlesOnHover,
              particleHoverFactor: _particleHoverFactor,
              alphaParticles: _alphaParticles,
              particleBaseSize: _particleBaseSize,
              sizeRandomness: _sizeRandomness,
              cameraDistance: _cameraDistance,
              disableRotation: _disableRotation,
            ),
          ),

          // Controls panel
          Positioned(
            left: 20,
            top: 20,
            bottom: 20,
            child: SingleChildScrollView(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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

                    // Sliders
                    _buildSlider('Count', _particleCount.toDouble(), 50, 1000, (v) => setState(() => _particleCount = v.round())),
                    _buildSlider('Spread', _particleSpread, 1, 30, (v) => setState(() => _particleSpread = v)),
                    _buildSlider('Speed', _speed, 0, 1, (v) => setState(() => _speed = v)),
                    _buildSlider('Base Size', _particleBaseSize, 10, 300, (v) => setState(() => _particleBaseSize = v)),
                    _buildSlider('Size Randomness', _sizeRandomness, 0, 2, (v) => setState(() => _sizeRandomness = v)),
                    _buildSlider('Camera Distance', _cameraDistance, 10, 50, (v) => setState(() => _cameraDistance = v)),
                    _buildSlider('Hover Factor', _particleHoverFactor, 0, 5, (v) => setState(() => _particleHoverFactor = v)),

                    // Switches
                    _buildSwitch('Move on Hover', _moveParticlesOnHover, (v) => setState(() => _moveParticlesOnHover = v)),
                    _buildSwitch('Alpha Particles', _alphaParticles, (v) => setState(() => _alphaParticles = v)),
                    _buildSwitch('Disable Rotation', _disableRotation, (v) => setState(() => _disableRotation = v)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white70)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.white54,
          ),
        ],
      ),
    );
  }
}
