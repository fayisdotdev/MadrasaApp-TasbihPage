import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/tasbih_card.dart';

class TasbihCounter extends StatefulWidget {
  const TasbihCounter({super.key, required this.title});

  final String title;

  @override
  State<TasbihCounter> createState() => _TasbihCounterState();
}

class _TasbihCounterState extends State<TasbihCounter> {
  final Map<int, int> _cardCounters = {};
  final Map<int, int?> _cardLimits = {}; // Store limits for each card
  int _counter = 0;
  int? _selectedLimit;
  int _selectedCardIndex = -1;
  final List<TasbihCard> _cards = TasbihCards.cards;
  int _currentCardIndex = 0;

  void _incrementCounter() {
    if (_selectedCardIndex == -1) return;
    setState(() {
      int? currentLimit = _cardLimits[_selectedCardIndex];
      if (currentLimit != null && _counter >= currentLimit) {
        return;
      }
      _counter++;
      _cardCounters[_selectedCardIndex] = _counter;
    });
  }

  void _setCounterLimit(int? limit) {
    if (_selectedCardIndex == -1) return;
    setState(() {
      _cardLimits[_selectedCardIndex] = limit;
      _selectedLimit = limit;
    });
  }

  // void _selectCard(int index) {
  //   setState(() {
  //     _selectedCardIndex = index;
  //     _counter = _cardCounters[index] ?? 0;
  //     _selectedLimit = _cardLimits[index]; // Load card-specific limit
  //   });
  // }

  void _nextCard() {
    setState(() {
      _currentCardIndex = (_currentCardIndex + 1) % _cards.length;
      _selectedCardIndex = _currentCardIndex;
      _counter = _cardCounters[_currentCardIndex] ?? 0;
      _selectedLimit = _cardLimits[_currentCardIndex];
    });
  }

  void _previousCard() {
    setState(() {
      _currentCardIndex =
          (_currentCardIndex - 1 + _cards.length) % _cards.length;
      _selectedCardIndex = _currentCardIndex;
      _counter = _cardCounters[_currentCardIndex] ?? 0;
      _selectedLimit = _cardLimits[_currentCardIndex];
    });
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Counter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Reset Current Counter'),
                onTap: () {
                  _resetCurrentCounter();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Reset All Counters'),
                onTap: () {
                  _resetAllCounters();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _resetCurrentCounter() {
    setState(() {
      _counter = 0;
      if (_selectedCardIndex != -1) {
        _cardCounters[_selectedCardIndex] = 0;
        // Don't reset the limit as it should persist
      }
    });
  }

  void _resetAllCounters() {
    setState(() {
      _cardCounters.clear();
      _cardLimits.clear(); // Clear all limits
      _counter = 0;
      _selectedLimit = null;
    });
  }

  // Error handling helper methods
  // void _showError(String message) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text(message)));
  //   });
  // }

  // bool _validateCardSelection() {
  //   return _selectedCardIndex != -1;
  // }

  // Replace _buildCardSelectionWindow with _buildCardDetailWindow
  Widget _buildCardDetailWindow() {
    final card = _cards[_currentCardIndex];
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: _previousCard,
                ),
                Text(
                  '${_currentCardIndex + 1}/${_cards.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: _nextCard,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        card.arabicText,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        card.text,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card.translation,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        card.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
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

  // Window Two - Counter Display Section
  Widget _buildCounterDisplayWindow() {
    return Expanded(
      flex: 3,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _selectedCardIndex == -1
                  ? 'Select a card to start'
                  : _selectedLimit != null
                  ? '$_counter/$_selectedLimit'
                  : '$_counter',
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(color: AppTheme.primaryColor),
            ),
            if (_selectedLimit != null && _counter >= _selectedLimit!)
              const Text(
                'Counter limit reached',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  // Window Three - Counter Controls Section
  Widget _buildCounterControlsWindow() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _counterButton('11', () => _setCounterLimit(11)),
              _counterButton('33', () => _setCounterLimit(33)),
              _counterButton('99', () => _setCounterLimit(99)),
              _counterButton('∞', () => _setCounterLimit(null)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _showResetDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCardDetailWindow(),
          _buildCounterDisplayWindow(),
          _buildCounterControlsWindow(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _counterButton(String text, VoidCallback onPressed) {
    final currentCardLimit =
        _selectedCardIndex != -1 ? _cardLimits[_selectedCardIndex] : null;
    return ElevatedButton(
      onPressed: _selectedCardIndex != -1 ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            currentCardLimit == (text == '∞' ? null : int.parse(text))
                ? AppTheme.primaryColor
                : Colors.grey[300],
        foregroundColor:
            currentCardLimit == (text == '∞' ? null : int.parse(text))
                ? Colors.white
                : Colors.black,
      ),
      child: Text(text),
    );
  }
}
