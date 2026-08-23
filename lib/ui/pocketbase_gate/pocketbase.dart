import 'package:flutter/material.dart';
import 'package:hmis/controllers/pocketbase_gate.dart';
import 'package:hmis/utils/router.dart';

// ---------------------------------------------------------------------------
// Terminal-style dark theme
// ---------------------------------------------------------------------------

const _termBg = Color(0xFF0A0E0A);
const _termSurface = Color(0xFF10160F);
const _termGreen = Color(0xFF39FF6A);
const _termGreenDim = Color(0xFF1E8E42);
const _termRed = Color(0xFFFF4444);
const _termAmber = Color(0xFFFFB300);

final _terminalTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _termBg,
  fontFamily: 'monospace',
  colorScheme: const ColorScheme.dark(
    surface: _termBg,
    primary: _termGreen,
    onPrimary: Colors.black,
    error: _termRed,
    onError: Colors.black,
    surfaceContainerHighest: _termSurface,
    onSurface: _termGreen,
    onSurfaceVariant: _termGreenDim,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: _termGreen, fontFamily: 'monospace'),
    headlineSmall: TextStyle(
      color: _termGreen,
      fontFamily: 'monospace',
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  ),
);

// ---------------------------------------------------------------------------
// Gate
// ---------------------------------------------------------------------------

class PocketBaseGate extends SignalConsumer {
  const PocketBaseGate({super.key, required this.child});
  final Widget child;

  @override
  void init(BuildContext context) => pocketbaseGateProvider(context).restoreHost();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _terminalTheme,
      home: _GateBody(child: child),
    );
  }
}

class _GateBody extends SignalConsumer {
  const _GateBody({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final pocketBaseGate = pocketbaseGateProvider(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.98, end: 1.0).animate(anim),
          child: child,
        ),
      ),
      child: pocketBaseGate.pbIsLive()
          ? Stack(
              key: const ValueKey('live'),
              children: [child, const _ReconnectBanner()],
            )
          : const _ConnectScreen(key: ValueKey('gate')),
    );
  }
}

// ---------------------------------------------------------------------------
// Reconnect banner
// ---------------------------------------------------------------------------

class _ReconnectBanner extends SignalConsumer {
  const _ReconnectBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final pocketBaseGate = pocketbaseGateProvider(context);
    final visible = pocketBaseGate.pbDegraded();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        offset: visible ? Offset.zero : const Offset(0, -1.2),
        child: SafeArea(
          bottom: false,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: _termAmber),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66FFB300),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulsingLed(color: _termAmber, fast: true),
                  SizedBox(width: 8),
                  Text(
                    'CONNECTION UNSTABLE — retrying...',
                    style: TextStyle(
                      color: _termAmber,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Connect / reconnect screen
// ---------------------------------------------------------------------------

class _ConnectScreen extends SignalConsumer {
  const _ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pocketBaseGate = pocketbaseGateProvider(context);
    final connecting = pocketBaseGate.pbIsConnecting();
    final ledColor = pocketBaseGate.pbStatus() == PbStatus.error
        ? _termRed
        : _termGreen;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _ScanlineOverlay()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _PulsingLed(color: ledColor, fast: connecting),
                          const SizedBox(width: 10),
                          const Text(
                            '> SYSTEM OFFLINE',
                            style: TextStyle(
                              color: _termGreen,
                              fontFamily: 'monospace',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  color: Color(0x8839FF6A),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                          ),
                          const _BlinkingCursor(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Padding(
                        padding: EdgeInsets.only(left: 26),
                        child: Text(
                          '_ awaiting server handshake',
                          style: TextStyle(
                            color: _termGreenDim,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _termSurface,
                          border: Border.all(color: _termGreenDim, width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x2239FF6A),
                              blurRadius: 20,
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'HOST:',
                              style: TextStyle(
                                color: _termGreenDim,
                                fontFamily: 'monospace',
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const _HostField(),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: PocketbaseGate.pbPresets.entries.map((
                                e,
                              ) {
                                return InkWell(
                                  onTap: connecting
                                      ? null
                                      : () => pocketBaseGate.pbHostInput.value =
                                            e.value,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: _termGreenDim),
                                    ),
                                    child: Text(
                                      e.key,
                                      style: const TextStyle(
                                        color: _termGreenDim,
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      const SizedBox(height: 48, child: _ConnectButton()),
                      const _ErrorPanel(),

                      const SizedBox(height: 16),
                      const Text(
                        '// preset LAN / local hosts reserved above',
                        style: TextStyle(
                          color: _termAmber,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Host field — TextEditingController is imperative, so this one stays
// StatefulWidget. The effect pushes preset taps and restoreHost() into the
// field without echoing the user's own keystrokes back.
// ---------------------------------------------------------------------------

class _HostField extends StatefulWidget {
  const _HostField();

  @override
  State<_HostField> createState() => _HostFieldState();
}

class _HostFieldState extends State<_HostField> {
  late final TextEditingController _controller;
  VoidCallback? _sync;
  late final pocketBaseGate = pocketbaseGateProvider(context);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: pocketBaseGate.pbHostInput.peek(),
    );
    _sync = effect(() {
      final v = pocketBaseGate.pbHostInput();
      if (_controller.text != v) {
        _controller.value = TextEditingValue(
          text: v,
          selection: TextSelection.collapsed(offset: v.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _sync?.call();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: !pocketBaseGate.pbIsConnecting(),
      onChanged: (v) => pocketBaseGate.pbHostInput.value = v,
      onSubmitted: (_) {
        if (pocketBaseGate.pbCanConnect.peek()) pocketBaseGate.connectPb();
      },
      style: const TextStyle(color: _termGreen, fontFamily: 'monospace'),
      cursorColor: _termGreen,
      keyboardType: TextInputType.url,
      autocorrect: false,
      decoration: const InputDecoration(
        hintText: '192.168.0.111',
        hintStyle: TextStyle(color: _termGreenDim),
        filled: true,
        fillColor: Colors.black,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: _termGreenDim),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: _termGreenDim),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: _termGreen, width: 2),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Button + error panel
// ---------------------------------------------------------------------------

class _ConnectButton extends SignalConsumer {
  const _ConnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    final pocketBaseGate = pocketbaseGateProvider(context);

    return ElevatedButton(
      onPressed: pocketBaseGate.pbCanConnect()
          ? () => pocketBaseGate.connectPb()
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _termGreen,
        foregroundColor: Colors.black,
        disabledBackgroundColor: _termGreenDim,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: pocketBaseGate.pbIsConnecting()
          ? const _ConnectingLabel()
          : const Text(
              '[ CONNECT ]',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
    );
  }
}

class _ErrorPanel extends SignalConsumer {
  const _ErrorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final pocketBaseGate = pocketbaseGateProvider(context);
    final error = pocketBaseGate.pbError();
    if (error == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: _termRed, width: 1),
          boxShadow: const [
            BoxShadow(color: Color(0x55FF4444), blurRadius: 12),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: _termRed,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(
                  color: _termRed,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectingLabel extends StatelessWidget {
  const _ConnectingLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
        ),
        SizedBox(width: 10),
        Text(
          'CONNECTING',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        _BlinkingCursor(color: Colors.black),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Animated flourishes — AnimationController is imperative, same category as
// ScrollController and TextEditingController. Unchanged.
// ---------------------------------------------------------------------------

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor({this.color = _termGreen});
  final Color color;

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c.drive(CurveTween(curve: Curves.easeInOutSine)),
      child: Text(
        ' _',
        style: TextStyle(
          color: widget.color,
          fontFamily: 'monospace',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PulsingLed extends StatefulWidget {
  const _PulsingLed({required this.color, this.fast = false});
  final Color color;
  final bool fast;

  @override
  State<_PulsingLed> createState() => _PulsingLedState();
}

class _PulsingLedState extends State<_PulsingLed>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: _duration)
    ..repeat(reverse: true);

  Duration get _duration => Duration(milliseconds: widget.fast ? 500 : 1300);

  @override
  void didUpdateWidget(_PulsingLed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fast != widget.fast) {
      _c
        ..duration = _duration
        ..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_c.value);
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4 + 0.5 * t),
                blurRadius: 4 + 8 * t,
                spreadRadius: 1 + 2 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScanlineOverlay extends StatefulWidget {
  const _ScanlineOverlay();

  @override
  State<_ScanlineOverlay> createState() => _ScanlineOverlayState();
}

class _ScanlineOverlayState extends State<_ScanlineOverlay>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _ScanlinePainter(progress: _c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  _ScanlinePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const lineGap = 4.0;
    final offset = progress * lineGap;
    final paint = Paint()
      ..color = _termGreen.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    for (double y = -lineGap + offset; y < size.height; y += lineGap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
