import 'dart:math' as math;
import 'package:flutter/material.dart';

class Vector3 {
  double x, y, z;
  Vector3(this.x, this.y, this.z);
}

class Vector4 {
  double x, y, z, w;
  Vector4(this.x, this.y, this.z, this.w);
}

class Particle {
  Vector3 position;
  Vector4 random;
  Color color;

  Particle({
    required this.position,
    required this.random,
    required this.color,
  });
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double time;
  final Offset mouseOffset;
  final double particleSpread;
  final double particleBaseSize;
  final double sizeRandomness;
  final bool alphaParticles;
  final double cameraDistance;
  final bool disableRotation;

  ParticlesPainter({
    required this.particles,
    required this.time,
    required this.mouseOffset,
    required this.particleSpread,
    required this.particleBaseSize,
    required this.sizeRandomness,
    required this.alphaParticles,
    required this.cameraDistance,
    required this.disableRotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    double rx = 0;
    double ry = 0;
    double rz = 0;

    if (!disableRotation) {
      rx = math.sin(time * 0.0002) * 0.1;
      ry = math.cos(time * 0.0005) * 0.15;
      rz = time * 0.01;
    }

    final double cxRx = math.cos(rx);
    final double sxRx = math.sin(rx);
    final double cyRy = math.cos(ry);
    final double syRy = math.sin(ry);
    final double czRz = math.cos(rz);
    final double szRz = math.sin(rz);

    final double fovFactor =
        size.height / (math.tan(15.0 * math.pi / 360.0) * 2.0);

    for (final particle in particles) {
      double px = particle.position.x * particleSpread;
      double py = particle.position.y * particleSpread;
      double pz = particle.position.z * particleSpread * 10.0;

      double x1 = px * czRz - py * szRz;
      double y1 = px * szRz + py * czRz;
      double z1 = pz;

      double x2 = x1 * cyRy + z1 * syRy;
      double y2 = y1;
      double z2 = -x1 * syRy + z1 * cyRy;

      double x3 = x2;
      double y3 = y2 * cxRx - z2 * sxRx;
      double z3 = y2 * sxRx + z2 * cxRx;

      double mixFactor(double r) => 0.1 + r * (1.5 - 0.1);

      x3 += math.sin(time * 0.001 * particle.random.z + 6.28 * particle.random.w) *
          mixFactor(particle.random.x);
      y3 += math.sin(time * 0.001 * particle.random.y + 6.28 * particle.random.x) *
          mixFactor(particle.random.w);
      z3 += math.sin(time * 0.001 * particle.random.w + 6.28 * particle.random.y) *
          mixFactor(particle.random.z);

      x3 += mouseOffset.dx;
      y3 += mouseOffset.dy;

      double viewZ = z3 - cameraDistance;

      if (viewZ >= 0) continue;

      double distance = math.sqrt(x3 * x3 + y3 * y3 + viewZ * viewZ);

      double projX = cx + (x3 / -viewZ) * fovFactor;
      double projY = cy - (y3 / -viewZ) * fovFactor;

      double pSize = (particleBaseSize *
              (1.0 + sizeRandomness * (particle.random.x - 0.5))) /
          distance;

      if (pSize < 0.1) continue;

      double shimmer =
          0.2 * math.sin(time * 0.001 + particle.random.y * 6.28);
      int r = (particle.color.red + (shimmer * 255).toInt()).clamp(0, 255);
      int g = (particle.color.green + (shimmer * 255).toInt()).clamp(0, 255);
      int b = (particle.color.blue + (shimmer * 255).toInt()).clamp(0, 255);

      Color shimmerColor = Color.fromARGB(255, r, g, b);

      if (alphaParticles) {
        final paint = Paint()
          ..shader = RadialGradient(
            colors: [
              shimmerColor.withValues(alpha: 0.8),
              shimmerColor.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 1.0],
          ).createShader(
              Rect.fromCircle(center: Offset(projX, projY), radius: pSize));
        canvas.drawCircle(Offset(projX, projY), pSize, paint);
      } else {
        final paint = Paint()
          ..color = shimmerColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(projX, projY), pSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticlesWidget extends StatefulWidget {
  final int particleCount;
  final double particleSpread;
  final double speed;
  final List<Color> particleColors;
  final bool moveParticlesOnHover;
  final double particleHoverFactor;
  final bool alphaParticles;
  final double particleBaseSize;
  final double sizeRandomness;
  final double cameraDistance;
  final bool disableRotation;

  const ParticlesWidget({
    super.key,
    this.particleCount = 200,
    this.particleSpread = 10.0,
    this.speed = 0.1,
    this.particleColors = const [Colors.white],
    this.moveParticlesOnHover = false,
    this.particleHoverFactor = 1.0,
    this.alphaParticles = true,
    this.particleBaseSize = 100.0,
    this.sizeRandomness = 1.0,
    this.cameraDistance = 20.0,
    this.disableRotation = true,
  });

  @override
  State<ParticlesWidget> createState() => _ParticlesWidgetState();
}

class _ParticlesWidgetState extends State<ParticlesWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Particle> particles;
  late Size _size;
  Offset _mousePosition = Offset.zero;
  Offset _smoothMouseOffset = Offset.zero;
  double _elapsed = 0;
  double _lastTime = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _animationController.addListener(() {
      final t = _animationController.lastElapsedDuration?.inMilliseconds.toDouble() ?? 0.0;
      final delta = t - _lastTime;
      _lastTime = t;
      _elapsed += delta * widget.speed;
    });

    _size = Size.zero;
    particles = [];
  }

  void _initializeParticles() {
    final random = math.Random();

    particles = List.generate(widget.particleCount, (index) {
      double x, y, z, len;
      do {
        x = random.nextDouble() * 2 - 1;
        y = random.nextDouble() * 2 - 1;
        z = random.nextDouble() * 2 - 1;
        len = x * x + y * y + z * z;
      } while (len > 1 || len == 0);

      final r = math.pow(random.nextDouble(), 1.0 / 3.0).toDouble();
      final pos = Vector3(x * r, y * r, z * r);

      final rands = Vector4(
        random.nextDouble(),
        random.nextDouble(),
        random.nextDouble(),
        random.nextDouble(),
      );

      final color = widget.particleColors[
          (random.nextDouble() * widget.particleColors.length).floor()];

      return Particle(
        position: pos,
        random: rands,
        color: color,
      );
    });
  }

  void _updateMouse() {
    if (_size.width <= 0 || _size.height <= 0) return;

    if (widget.moveParticlesOnHover) {
      final double targetX = -((_mousePosition.dx / _size.width) * 2 - 1) * widget.particleHoverFactor;
      final double targetY = ((_mousePosition.dy / _size.height) * 2 - 1) * widget.particleHoverFactor;

      _smoothMouseOffset = Offset(targetX, targetY);
    } else {
      _smoothMouseOffset = Offset.zero;
    }
  }

  void _onPointerMove(PointerEvent event) {
    setState(() {
      _mousePosition = event.localPosition;
    });
  }

  @override
  void didUpdateWidget(ParticlesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.particleCount != widget.particleCount ||
        oldWidget.particleColors != widget.particleColors) {
      _initializeParticles();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        if (_size != size) {
          _size = size;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeParticles();
          });
        }

        return MouseRegion(
          onHover: (event) => _onPointerMove(event),
          child: Listener(
            onPointerMove: _onPointerMove,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                _updateMouse();
                return CustomPaint(
                  size: size,
                  painter: ParticlesPainter(
                    particles: particles,
                    time: _elapsed,
                    mouseOffset: _smoothMouseOffset,
                    particleSpread: widget.particleSpread,
                    particleBaseSize: widget.particleBaseSize,
                    sizeRandomness: widget.sizeRandomness,
                    alphaParticles: widget.alphaParticles,
                    cameraDistance: widget.cameraDistance,
                    disableRotation: widget.disableRotation,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
