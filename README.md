# Flutter Space Particles

A beautiful, interactive 3D particle system for Flutter, perfectly mimicking the mathematical rendering logic of popular WebGL particle effects. Built entirely with Flutter's native `CustomPainter`—no external shaders or complex GLSL required!

[**View Live Demo**](https://rohu069.github.io/space_particles_effect)

## ✨ Features
- **True 3D Projection**: Simulates Z-depth, FOV, and perspective dynamically on the Canvas.
- **Sine-Wave Animation**: Particles oscillate organically based on a 4-dimensional random noise algorithm.
- **Mouse Parallax**: The entire particle mesh reacts and shifts instantly to mouse hover movements.
- **Zero Dependencies**: Uses only pure Dart math and Flutter rendering.

## 🚀 How to use it in your app

This effect uses the "copy-paste" component philosophy (similar to `shadcn/ui` in the React ecosystem). You do not need to install any messy pub packages!

### 1. Copy the code
Copy the entire contents of [`lib/particle.dart`](lib/particle.dart) from this repository. 
Create a new file in your own project (e.g., `lib/widgets/particle.dart`) and paste the code inside. You can now close that file and forget about the 300 lines of complex math!

### 2. Import and Use
In your main UI screen, simply import your new file and drop the `ParticlesWidget()` wherever you want it. It's fully customizable!

```dart
import 'package:flutter/material.dart';
// Import the file you just pasted!
import 'package:your_app_name/widgets/particle.dart'; 

class MyCoolScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Drop the particles in the background
          Positioned.fill(
            child: ParticlesWidget(
              particleCount: 200,
              speed: 0.1,
              particleColors: const [Colors.white, Colors.blue],
              moveParticlesOnHover: true,
              cameraDistance: 20.0,
            ),
          ),
          
          // 2. Put your own App UI on top!
          const Center(
            child: Text(
              "Welcome to My App!", 
              style: TextStyle(color: Colors.white, fontSize: 32),
            ),
          ),
        ],
      ),
    );
  }
}
```

## ⚙️ Properties
You can customize the following properties on `ParticlesWidget`:

| Property | Type | Default | Description |
|---|---|---|---|
| `particleCount` | `int` | `200` | Total number of particles to render. |
| `particleColors` | `List<Color>` | `[Colors.white]` | Array of colors randomly assigned to particles. |
| `speed` | `double` | `0.1` | How fast the particles oscillate. |
| `moveParticlesOnHover`| `bool` | `false` | Whether the mesh shifts when the mouse moves. |
| `particleSpread` | `double` | `10.0` | How far apart the particles spawn. |
| `particleBaseSize` | `double` | `100.0` | Base size multiplier for particles. |
| `sizeRandomness` | `double` | `1.0` | How much particle sizes randomly vary. |
| `cameraDistance` | `double` | `20.0` | Distance of the virtual 3D camera. |
| `disableRotation`| `bool` | `false` | Stop the global mesh rotation. |
| `alphaParticles` | `bool` | `false` | Switch between hard circles or soft glowing radial gradients. |
