import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  /// Reads the persisted counter value from SharedPreferences.
  Future<void> _loadCounter() async {
    final saved = await StorageService.loadCounter();
    // FIX: guard with mounted check before calling setState after async gap
    if (!mounted) return;
    setState(() {
      _counter = saved;
      _isLoading = false;
    });
  }

  /// Increases counter by 1 and saves immediately.
  void _increment() {
    setState(() => _counter++);
    StorageService.saveCounter(_counter);
  }

  /// Decreases counter by 1 (min 0) and saves immediately.
  void _decrement() {
    if (_counter > 0) {
      setState(() => _counter--);
      StorageService.saveCounter(_counter);
    }
  }

  /// Resets counter to 0 and saves.
  void _reset() {
    setState(() => _counter = 0);
    StorageService.saveCounter(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Counter App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: _reset,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE0F2F1), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Counter Display ─────────────────────────────────
                    Container(
                      width: 180,
                      height: 180,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            // FIX: replaced withOpacity with Color.fromRGBO
                            color: Color.fromRGBO(0, 128, 128, 0.2),
                            blurRadius: 24,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$_counter',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Value saved automatically',
                      style:
                          TextStyle(color: Colors.teal, fontSize: 13),
                    ),
                    const SizedBox(height: 48),

                    // ── Increment / Decrement Buttons ───────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CircleButton(
                          icon: Icons.remove,
                          color: Colors.redAccent,
                          onPressed: _decrement,
                          tooltip: 'Decrease',
                        ),
                        const SizedBox(width: 32),
                        _CircleButton(
                          icon: Icons.add,
                          color: Colors.teal,
                          onPressed: _increment,
                          tooltip: 'Increase',
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    Text(
                      'Counter persists after app restart\n(using SharedPreferences)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Reusable circular icon button ────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          elevation: 4,
        ),
        child: Icon(icon, size: 32),
      ),
    );
  }
}
