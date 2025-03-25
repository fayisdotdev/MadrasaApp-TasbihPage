import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Beadstasbih extends StatefulWidget {
  @override
  _BeadstasbihState createState() => _BeadstasbihState();
}

class _BeadstasbihState extends State<Beadstasbih>
    with TickerProviderStateMixin {
  int _count = 0;
  int _lastTappedBead = -1;
  late AnimationController _scaleController;
  late AnimationController _fallController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _fallAnimation;
  int? _animatingBeadIndex;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fallController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _fallAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 1.5),
    ).animate(
      CurvedAnimation(parent: _fallController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fallController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    HapticFeedback.lightImpact();
    setState(() {
      _count++;
    });
  }

  void _resetCounter() {
    setState(() {
      _count = 0;
      _lastTappedBead = -1;
    });
  }

  Widget _buildBead(int index, bool isTopTier) {
    bool isCounted = _lastTappedBead >= index;
    bool isAnimating = _animatingBeadIndex == index;

    return SlideTransition(
      position:
          isAnimating ? _fallAnimation : AlwaysStoppedAnimation(Offset.zero),
      child: GestureDetector(
        onTap: isTopTier ? () => _handleBeadTap(index) : null,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 50,
            height: 50,
            margin: EdgeInsets.only(
              top: isTopTier ? 0 : 40,
              left: index % 2 == 0 ? 10 : 0,
            ),
            decoration: BoxDecoration(
              color: isCounted ? Colors.amber[600] : Colors.black87,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      isCounted
                          ? Colors.amber.withOpacity(0.6)
                          : Colors.black26,
                  blurRadius: isCounted ? 10 : 5,
                  spreadRadius: isCounted ? 3 : 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleBeadTap(int index) {
    if (_fallController.isAnimating) return;

    setState(() {
      _animatingBeadIndex = index;
      _incrementCounter();
    });

    _scaleController.forward().then((_) => _scaleController.reverse());
    _fallController.forward().then((_) {
      setState(() {
        _animatingBeadIndex = null;
        _lastTappedBead = index;
      });
      _fallController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text("Tasbih Counter"),
        backgroundColor: Colors.brown[300],
      ),
      body: Column(
        children: [
          SizedBox(height: 40),
          // Counter display with enhanced styling
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              '$_count',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top tier beads
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => _buildBead(index, true),
                    ),
                  ),
                ),
                // Bottom tier beads
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => _buildBead(index + 3, false),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: _resetCounter,
              icon: Icon(Icons.refresh),
              label: Text("Reset Counter"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[400],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
