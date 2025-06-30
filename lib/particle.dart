import 'dart:math' as math;
import 'package:flutter/material.dart';

class Particle {
  double baseX;
  double baseY;
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double baseSize;
  Color color;
  double opacity;
  double depth; // 0.0 (far) to 1.0 (close)
  double parallaxFactor;

  Particle({
    required this.baseX,
    required this.baseY,
    required this.vx,
    required this.vy,
    required this.baseSize,
    required this.color,
    required this.depth,
    this.opacity = 1.0,
  })  : x = baseX,
        y = baseY,
        size = baseSize,
        parallaxFactor = depth * 0.5; // How much this particle moves with mouse
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double time;
  final Offset mouseOffset;

  ParticlesPainter({
    required this.particles,
    required this.time,
    required this.mouseOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Sort particles by depth (far to near) for proper rendering
    particles.sort((a, b) => a.depth.compareTo(b.depth));

    for (final particle in particles) {
      // Apply parallax effect based on mouse position and particle depth
      final parallaxX = mouseOffset.dx * particle.parallaxFactor;
      final parallaxY = mouseOffset.dy * particle.parallaxFactor;

      final finalX = particle.x + parallaxX;
      final finalY = particle.y + parallaxY;

      // Adjust size and opacity based on depth for 3D effect
      final depthSize = particle.size * (0.3 + particle.depth * 0.7);
      final depthOpacity = particle.opacity * (0.2 + particle.depth * 0.8);

      final paint = Paint()
        ..color = particle.color.withOpacity(depthOpacity)
        ..style = PaintingStyle.fill;

      // Add a subtle glow effect for closer particles
      if (particle.depth > 0.7) {
        final glowPaint = Paint()
          ..color = particle.color.withOpacity(depthOpacity * 0.3)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(finalX, finalY),
          depthSize * 2,
          glowPaint,
        );
      }

      canvas.drawCircle(
        Offset(finalX, finalY),
        depthSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticlesWidget extends StatefulWidget {
  final int count;
  final double spread;
  final double speed;
  final double baseSize;
  final Color color;
  final double minOpacity;
  final double maxOpacity;
  final double parallaxStrength;

  const ParticlesWidget({
    super.key,
    this.count = 200,
    this.spread = 10,
    this.speed = 0.1,
    this.baseSize = 2,
    this.color = Colors.white,
    this.minOpacity = 0.3,
    this.maxOpacity = 1.0,
    this.parallaxStrength = 50.0,
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _size = Size.zero;
    particles = [];
  }

  void _initializeParticles(Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    _size = size;
    final random = math.Random();

    particles = List.generate(widget.count, (index) {
      final depth = random.nextDouble();
      final sizeVariation = 0.5 + depth * 1.5; // Closer particles are bigger

      return Particle(
        baseX: random.nextDouble() * size.width,
        baseY: random.nextDouble() * size.height,
        vx: (random.nextDouble() - 0.5) *
            widget.spread *
            widget.speed *
            (1 - depth * 0.5),
        vy: (random.nextDouble() - 0.5) *
            widget.spread *
            widget.speed *
            (1 - depth * 0.5),
        baseSize: widget.baseSize * sizeVariation,
        color: widget.color,
        depth: depth,
        opacity: widget.minOpacity +
            random.nextDouble() * (widget.maxOpacity - widget.minOpacity),
      );
    });
  }

  void _updateParticles() {
    if (_size.width <= 0 || _size.height <= 0) return;

    // Smooth mouse movement interpolation
    const lerpFactor = 0.05;
    final targetMouseOffset = Offset(
      (_mousePosition.dx - _size.width / 2) /
          _size.width *
          widget.parallaxStrength,
      (_mousePosition.dy - _size.height / 2) /
          _size.height *
          widget.parallaxStrength,
    );

    _smoothMouseOffset =
        Offset.lerp(_smoothMouseOffset, targetMouseOffset, lerpFactor)!;

    for (final particle in particles) {
      // Update base position with slow drift
      particle.baseX += particle.vx;
      particle.baseY += particle.vy;

      // Wrap around edges for base position
      if (particle.baseX < -particle.size) {
        particle.baseX = _size.width + particle.size;
      } else if (particle.baseX > _size.width + particle.size) {
        particle.baseX = -particle.size;
      }

      if (particle.baseY < -particle.size) {
        particle.baseY = _size.height + particle.size;
      } else if (particle.baseY > _size.height + particle.size) {
        particle.baseY = -particle.size;
      }

      // Update actual position (base + parallax will be applied in painter)
      particle.x = particle.baseX;
      particle.y = particle.baseY;

      // Subtle opacity animation based on depth and time
      final timeOffset = particle.baseX * 0.01 + particle.baseY * 0.01;
      particle.opacity = (widget.minOpacity +
              (widget.maxOpacity - widget.minOpacity) *
                  (0.5 +
                      0.5 *
                          math.sin(_animationController.value * 2 * math.pi +
                              timeOffset))) *
          (0.6 + particle.depth * 0.4); // Deeper particles are more visible
    }
  }

  void _onPointerMove(PointerEvent event) {
    setState(() {
      _mousePosition = event.localPosition;
    });
  }

  void _onPointerExit(PointerEvent event) {
    setState(() {
      _mousePosition = Offset(_size.width / 2, _size.height / 2);
    });
  }

  @override
  void didUpdateWidget(ParticlesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count ||
        oldWidget.color != widget.color ||
        oldWidget.baseSize != widget.baseSize) {
      _initializeParticles(_size);
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeParticles(size);
            _mousePosition = Offset(size.width / 2, size.height / 2);
          });
        }

        return MouseRegion(
          onHover: (event) => _onPointerMove(event),
          onExit: _onPointerExit,
          child: Listener(
            onPointerMove: _onPointerMove,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                _updateParticles();
                return CustomPaint(
                  size: size,
                  painter: ParticlesPainter(
                    particles: particles,
                    time: _animationController.value,
                    mouseOffset: _smoothMouseOffset,
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
