import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome> with TickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';
  bool showBalloons = false;
  
  // Pulse control
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPulsing = false;
  
  // Sparkle animation
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation setup
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() => setState(() {}));
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Sparkle animation setup
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }
  
  void _togglePulse() {
    if (_isPulsing) {
      _pulseController.stop();
      _pulseController.reset();
    } else {
      _pulseController.repeat(reverse: true);
    }
    setState(() {
      _isPulsing = !_isPulsing;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid\'s Canvas')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: selectedEmoji,
                items: emojiOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => selectedEmoji = value ?? selectedEmoji),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _togglePulse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[100],
                  foregroundColor: Colors.red[900],
                ),
                child: Text(_isPulsing ? 'Stop Pulse' : 'Start Pulse'),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    showBalloons = !showBalloons;
                  });
                },
                icon: const Icon(Icons.celebration),
                label: Text(showBalloons ? 'Hide Balloons' : 'Drop Balloons!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[100],
                  foregroundColor: Colors.red[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: AnimatedBuilder(
                    animation: _sparkleController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(300, 300),
                        painter: HeartEmojiPainter(
                          type: selectedEmoji,
                          sparkleProgress: _sparkleController.value,
                          scaleFactor: _pulseAnimation.value,
                        ),
                      );
                    },
                  ),
                ),
                if (showBalloons)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BalloonPainter(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({
    required this.type,
    required this.sparkleProgress,
    this.scaleFactor = 1.0,
  });
  
  final String type;
  final double sparkleProgress;
  final double scaleFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // GRADIENT BACKGROUND - soft pink to red radial gradient
    final backgroundGradient = RadialGradient(
      colors: [
        const Color(0xFFFCE4EC), // Light pink
        const Color(0xFFF8BBD0), // Medium pink
        const Color(0xFFF48FB1), // Darker pink
        const Color(0xFFE91E63), // Red
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );
    
    final backgroundPaint = Paint()
      ..shader = backgroundGradient.createShader(
        Rect.fromCircle(center: center, radius: size.width / 2),
      );
    canvas.drawRect(Offset.zero & size, backgroundPaint);
    
    // Apply pulse scaling
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scaleFactor);
    canvas.translate(-center.dx, -center.dy);
    
    // LOVE TRAIL - faint heart outline behind main emoji for glowing aura
    _drawLoveTrail(canvas, center);

    // Heart base with LINEAR GRADIENT
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10, center.dx + 60, center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120, center.dx - 110, center.dy - 10, center.dx, center.dy + 60)
      ..close();

    // Linear gradient for heart
    final heartGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: type == 'Party Heart' 
        ? [
            const Color(0xFFFFD54F), // Yellow
            const Color(0xFFF48FB1), // Pink
            const Color(0xFFE91E63), // Deep pink
          ]
        : [
            const Color(0xFFFF6B9D), // Light red
            const Color(0xFFE91E63), // Main red
            const Color(0xFFC2185B), // Dark red
          ],
    );

    final heartPaint = Paint()
      ..shader = heartGradient.createShader(
        Rect.fromLTRB(
          center.dx - 120,
          center.dy - 120,
          center.dx + 120,
          center.dy + 70,
        ),
      );
    canvas.drawPath(heartPath, heartPaint);

    // Draw the appropriate emoji type
    if (type == 'Party Heart') {
      _drawPartyHeart(canvas, center);
    } else {
      _drawSweetHeart(canvas, center);
    }

    // Draw animated sparkles around the heart
    _drawAnimatedSparkles(canvas, center);
    
    canvas.restore();
  }

  void _drawPartyHeart(Canvas canvas, Offset center) {
    // Eyes - bigger and more excited
    final eyeWhitePaint = Paint()..color = Colors.white;
    final eyeBlackPaint = Paint()..color = Colors.black;
    
    // Left eye
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 12, eyeWhitePaint);
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 6, eyeBlackPaint);
    
    // Right eye
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 12, eyeWhitePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 6, eyeBlackPaint);

    // Big excited smile
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 15), radius: 35),
      0,
      3.14,
      false,
      mouthPaint,
    );

    // Party hat
    final hatPaint = Paint()..color = const Color(0xFFFFD54F);
    final hatPath = Path()
      ..moveTo(center.dx, center.dy - 120)
      ..lineTo(center.dx - 40, center.dy - 40)
      ..lineTo(center.dx + 40, center.dy - 40)
      ..close();
    canvas.drawPath(hatPath, hatPaint);

    // Hat stripes for detail
    final stripePaint = Paint()
      ..color = const Color(0xFFFF6F00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(center.dx - 20, center.dy - 60),
      Offset(center.dx + 20, center.dy - 60),
      stripePaint,
    );
    canvas.drawLine(
      Offset(center.dx - 30, center.dy - 50),
      Offset(center.dx + 30, center.dy - 50),
      stripePaint,
    );

    // Pom-pom on top of hat
    final pomPaint = Paint()..color = const Color(0xFFFF5252);
    canvas.drawCircle(Offset(center.dx, center.dy - 120), 8, pomPaint);

    // Draw enhanced confetti!
    _drawEnhancedConfetti(canvas, center);
  }

  void _drawSweetHeart(Canvas canvas, Offset center) {
    // Eyes - cute and simple
    final eyeWhitePaint = Paint()..color = Colors.white;
    final eyeBlackPaint = Paint()..color = Colors.black;
    
    // Left eye
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 15), 10, eyeWhitePaint);
    canvas.drawCircle(Offset(center.dx - 28, center.dy - 15), 5, eyeBlackPaint);
    
    // Right eye
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 15), 10, eyeWhitePaint);
    canvas.drawCircle(Offset(center.dx + 32, center.dy - 15), 5, eyeBlackPaint);

    // Rosy cheeks
    final blushPaint = Paint()..color = const Color(0xFFFFAB91).withOpacity(0.6);
    canvas.drawCircle(Offset(center.dx - 55, center.dy + 5), 15, blushPaint);
    canvas.drawCircle(Offset(center.dx + 55, center.dy + 5), 15, blushPaint);

    // Cute gentle smile
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 25),
      0,
      3.14,
      false,
      mouthPaint,
    );

    // Little sparkles around the heart
    final sparklePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    // Top right sparkle
    canvas.drawLine(Offset(center.dx + 80, center.dy - 60), Offset(center.dx + 80, center.dy - 50), sparklePaint);
    canvas.drawLine(Offset(center.dx + 75, center.dy - 55), Offset(center.dx + 85, center.dy - 55), sparklePaint);
    
    // Top left sparkle
    canvas.drawLine(Offset(center.dx - 80, center.dy - 60), Offset(center.dx - 80, center.dy - 50), sparklePaint);
    canvas.drawLine(Offset(center.dx - 85, center.dy - 55), Offset(center.dx - 75, center.dy - 55), sparklePaint);
    
    // Bottom sparkle
    canvas.drawLine(Offset(center.dx, center.dy + 90), Offset(center.dx, center.dy + 100), sparklePaint);
    canvas.drawLine(Offset(center.dx - 5, center.dy + 95), Offset(center.dx + 5, center.dy + 95), sparklePaint);
  }

  void _drawEnhancedConfetti(Canvas canvas, Offset center) {
    final confettiPaint = Paint()..style = PaintingStyle.fill;
    
    // ENHANCED: More vibrant and varied confetti colors!
    final confettiColors = [
      const Color(0xFFFFEB3B), // Bright Yellow
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF5722), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFFCA28), // Amber
    ];

    // ENHANCED: Rectangle confetti strips with more variety
    for (int i = 0; i < 15; i++) {
      confettiPaint.color = confettiColors[i % confettiColors.length];
      final angle = (i * 25.0) * 3.14159 / 180;
      final x = center.dx + (i % 2 == 0 ? 60 : -60) + ((i % 4) * 12);
      final y = center.dy - 80 + (i * 7.0);
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      // Varying sizes for more dynamic look
      final width = i % 2 == 0 ? 6.0 : 5.0;
      final height = i % 3 == 0 ? 18.0 : 16.0;
      canvas.drawRect(Rect.fromLTWH(-width / 2, -height / 2, width, height), confettiPaint);
      canvas.restore();
    }

    // ENHANCED: Circle confetti dots - more of them!
    for (int i = 0; i < 12; i++) {
      confettiPaint.color = confettiColors[(i + 2) % confettiColors.length];
      final x = center.dx + (i % 2 == 0 ? 70 : -70) + ((i % 3) * 8);
      final y = center.dy - 60 + (i * 9);
      // Varying sizes
      final radius = i % 2 == 0 ? 5.0 : 4.0;
      canvas.drawCircle(Offset(x, y), radius, confettiPaint);
    }

    // ENHANCED: Triangle confetti - more variety
    for (int i = 0; i < 10; i++) {
      confettiPaint.color = confettiColors[(i + 4) % confettiColors.length];
      final x = center.dx + (i % 2 == 0 ? -75 : 75) + ((i % 3) * 5);
      final y = center.dy - 90 + (i * 15);
      
      // Varying triangle sizes
      final size = i % 2 == 0 ? 8.0 : 6.0;
      final trianglePath = Path()
        ..moveTo(x, y - size)
        ..lineTo(x - size, y + size)
        ..lineTo(x + size, y + size)
        ..close();
      canvas.drawPath(trianglePath, confettiPaint);
    }

    // NEW: Star-shaped confetti!
    for (int i = 0; i < 6; i++) {
      confettiPaint.color = confettiColors[(i + 6) % confettiColors.length];
      final x = center.dx + (i % 2 == 0 ? -85 : 85);
      final y = center.dy - 70 + (i * 20);
      _drawStar(canvas, Offset(x, y), 6, confettiPaint);
    }

    // NEW: Squiggly streamers!
    final streamerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    for (int i = 0; i < 4; i++) {
      streamerPaint.color = confettiColors[(i + 1) % confettiColors.length];
      final startX = center.dx + (i % 2 == 0 ? -90 : 90);
      final startY = center.dy - 100;
      
      final path = Path()..moveTo(startX, startY);
      for (int j = 0; j < 5; j++) {
        final y = startY + (j * 15);
        final x = startX + (j % 2 == 0 ? 10 : -10);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, streamerPaint);
    }
  }

  // LOVE TRAIL - faint heart outlines behind main emoji
  void _drawLoveTrail(Canvas canvas, Offset center) {
    final trailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw 3 fading heart outlines
    for (int i = 0; i < 3; i++) {
      final scale = 1.0 + (i * 0.15); // Each trail is bigger
      final opacity = 0.3 - (i * 0.1); // Each trail is fainter
      
      trailPaint.color = const Color(0xFFE91E63).withOpacity(opacity);
      
      final trailPath = Path()
        ..moveTo(center.dx, center.dy + 60 * scale)
        ..cubicTo(
          center.dx + 110 * scale, center.dy - 10 * scale,
          center.dx + 60 * scale, center.dy - 120 * scale,
          center.dx, center.dy - 40 * scale,
        )
        ..cubicTo(
          center.dx - 60 * scale, center.dy - 120 * scale,
          center.dx - 110 * scale, center.dy - 10 * scale,
          center.dx, center.dy + 60 * scale,
        )
        ..close();
      
      canvas.drawPath(trailPath, trailPaint);
    }
  }

  // ANIMATED SPARKLES - star bursts using lines and dots
  void _drawAnimatedSparkles(Canvas canvas, Offset center) {
    final sparklePaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Create 8 sparkles around the heart
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45.0 + sparkleProgress * 360) * 3.14159 / 180;
      final distance = 120.0 + (10 * sin(sparkleProgress * 6.28)); // Pulsing distance
      
      final x = center.dx + distance * cos(angle);
      final y = center.dy + distance * sin(angle);
      
      // Fade in and out based on progress
      final opacity = (sin(sparkleProgress * 6.28 + i) + 1) / 2;
      sparklePaint.color = Colors.white.withOpacity(opacity * 0.8);
      
      // Draw star burst (4 lines forming a star)
      final lineLength = 8.0;
      // Vertical line
      canvas.drawLine(
        Offset(x, y - lineLength),
        Offset(x, y + lineLength),
        sparklePaint,
      );
      // Horizontal line
      canvas.drawLine(
        Offset(x - lineLength, y),
        Offset(x + lineLength, y),
        sparklePaint,
      );
      // Diagonal lines
      canvas.drawLine(
        Offset(x - lineLength * 0.7, y - lineLength * 0.7),
        Offset(x + lineLength * 0.7, y + lineLength * 0.7),
        sparklePaint,
      );
      canvas.drawLine(
        Offset(x - lineLength * 0.7, y + lineLength * 0.7),
        Offset(x + lineLength * 0.7, y - lineLength * 0.7),
        sparklePaint,
      );
      
      // Center dot
      canvas.drawCircle(Offset(x, y), 3, sparklePaint..style = PaintingStyle.fill);
      sparklePaint.style = PaintingStyle.stroke; // Reset for next iteration
    }
  }

  // Helper method to draw a star
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * 3.14159 / 5) - 3.14159 / 2;
      final x = center.dx + radius * (i % 2 == 0 ? 1 : 0.5) * cos(angle);
      final y = center.dy + radius * (i % 2 == 0 ? 1 : 0.5) * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double cos(double radians) => radians.isNaN ? 0 : (radians == 0 ? 1 : _cos(radians));
  double sin(double radians) => radians.isNaN ? 0 : (radians == 0 ? 0 : _sin(radians));
  
  double _cos(double x) {
    // Taylor series approximation for cos
    double result = 1;
    double term = 1;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }
  
  double _sin(double x) {
    // Taylor series approximation for sin
    double result = x;
    double term = x;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) {
    return oldDelegate.type != type || 
           oldDelegate.sparkleProgress != sparkleProgress ||
           oldDelegate.scaleFactor != scaleFactor;
  }
}

// NEW: Balloon Painter for the celebration feature!
class BalloonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final balloonPaint = Paint()..style = PaintingStyle.fill;
    final stringPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Balloon colors
    final balloonColors = [
      const Color(0xFFE91E63), // Pink
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFFEB3B), // Yellow
      const Color(0xFF4CAF50), // Green
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFF5722), // Orange
    ];

    // Draw 6 balloons at different positions
    final balloonPositions = [
      Offset(size.width * 0.15, size.height * 0.3),
      Offset(size.width * 0.30, size.height * 0.5),
      Offset(size.width * 0.45, size.height * 0.2),
      Offset(size.width * 0.60, size.height * 0.4),
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width * 0.85, size.height * 0.45),
    ];

    for (int i = 0; i < balloonPositions.length; i++) {
      final pos = balloonPositions[i];
      balloonPaint.color = balloonColors[i % balloonColors.length];
      
      // Draw balloon string
      canvas.drawLine(
        Offset(pos.dx, pos.dy + 50),
        Offset(pos.dx + 5, pos.dy + 120),
        stringPaint,
      );
      
      // Draw balloon body (oval)
      final balloonRect = Rect.fromCenter(
        center: pos,
        width: 50,
        height: 65,
      );
      canvas.drawOval(balloonRect, balloonPaint);
      
      // Draw balloon knot (small triangle)
      final knotPaint = Paint()..color = balloonColors[i % balloonColors.length].withOpacity(0.7);
      final knotPath = Path()
        ..moveTo(pos.dx - 5, pos.dy + 50)
        ..lineTo(pos.dx + 5, pos.dy + 50)
        ..lineTo(pos.dx, pos.dy + 58)
        ..close();
      canvas.drawPath(knotPath, knotPaint);
      
      // Add a shine/highlight to balloon
      final shinePaint = Paint()..color = Colors.white.withOpacity(0.5);
      canvas.drawCircle(Offset(pos.dx - 10, pos.dy - 15), 8, shinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}