import 'package:flutter/material.dart';
import 'package:madrasaapp/screens/full_duas_page.dart';
import '../theme/app_theme.dart';
import '../models/tasbih_card.dart';
import 'package:flutter/services.dart'
    show
        FilteringTextInputFormatter,
        HapticFeedback,
        LengthLimitingTextInputFormatter;
import 'package:vibration/vibration.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class TasbihCounter extends StatefulWidget {
  const TasbihCounter({super.key, required this.title});

  final String title;

  @override
  State<TasbihCounter> createState() => _TasbihCounterState();
}

class _TasbihCounterState extends State<TasbihCounter> {
  final Map<int, int> _cardCounters = {};
  final Map<int, int?> _cardLimits = {};
  final Map<int, int> _cardRounds = {};
  int _counter = 0;
  int? _selectedLimit;
  int _selectedCardIndex = -1;
  final List<TasbihCard> _cards = TasbihCards.cards;
  int _currentCardIndex = 0;
  bool _isVibrationEnabled = true;
  bool _isSoundEnabled = true;
  bool _hasVibrator = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initAudio();
    _selectedCardIndex = _currentCardIndex;
    _counter = _cardCounters[_currentCardIndex] ?? 0;
    _selectedLimit = _cardLimits[_currentCardIndex];
    _checkVibrationCapability();
  }

  Future<void> _initAudio() async {
    try {
      // Configure audio session
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());

      // Load the audio file
      await _audioPlayer.setAsset('assets/audio/click.mp3');

      // Set default volume
      await _audioPlayer.setVolume(0.5);
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkVibrationCapability() async {
    try {
      _hasVibrator = await Vibration.hasVibrator();
    } catch (e) {
      debugPrint('Error checking vibration capability: $e');
      _hasVibrator = false;
    }
  }

  // Error handling helper methods
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validateCardSelection() {
    if (_selectedCardIndex == -1) {
      _showError('Please select a card first');
      return false;
    }
    return true;
  }

  Future<void> _vibrateDevice({int duration = 50}) async {
    if (!_isVibrationEnabled || !_hasVibrator) return;

    try {
      // Try pattern vibration first for better feedback
      await Vibration.vibrate(
        pattern: [0, duration, 50, duration],
        intensities: [0, 255, 0, 255], // Maximum intensity
        amplitude: 255,
      );
    } catch (e) {
      debugPrint('Pattern vibration failed: $e');
      try {
        // Fallback to simple vibration
        await Vibration.vibrate(duration: duration * 2, amplitude: 255);
      } catch (e) {
        debugPrint('Simple vibration failed: $e');
        try {
          // Last resort - use system haptic feedback
          await HapticFeedback.heavyImpact();
        } catch (e) {
          debugPrint('Haptic feedback failed: $e');
          _hasVibrator = false;
        }
      }
    }
  }

  Future<void> _playSound({bool isReset = false}) async {
    if (!_isSoundEnabled) return;

    try {
      if (isReset) {
        await _audioPlayer.setVolume(1.0);
      } else {
        await _audioPlayer.setVolume(0.5);
      }
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _incrementCounter() {
    if (!_validateCardSelection()) return;

    try {
      setState(() {
        int? currentLimit = _cardLimits[_selectedCardIndex];

        if (currentLimit == null) {
          _counter++;
          _vibrateDevice(duration: 100); // Stronger feedback for normal count
          _playSound();
        } else {
          if (_counter >= currentLimit) {
            _counter = 0;
            _vibrateDevice(duration: 200); // Extra strong feedback for reset
            _playSound(isReset: true);
            _cardRounds[_selectedCardIndex] =
                (_cardRounds[_selectedCardIndex] ?? 0) + 1;
          } else {
            _counter++;
            _vibrateDevice(duration: 100);
            _playSound();
          }
        }
        _cardCounters[_selectedCardIndex] = _counter;
      });
    } catch (e) {
      _showError('Error incrementing counter: $e');
    }
  }

  void _setCounterLimit(int? limit) {
    if (!_validateCardSelection()) return;

    if (limit != null && limit <= 0) {
      _showError('Limit must be greater than zero');
      return;
    }

    try {
      setState(() {
        _cardLimits[_selectedCardIndex] = limit;
        _selectedLimit = limit;
      });
    } catch (e) {
      _showError('Error setting counter limit: $e');
    }
  }

  void _nextCard() {
    try {
      if (_cards.isEmpty) {
        _showError('No cards available');
        return;
      }

      setState(() {
        _currentCardIndex = (_currentCardIndex + 1) % _cards.length;
        _selectedCardIndex = _currentCardIndex;
        _counter = _cardCounters[_currentCardIndex] ?? 0;
        _selectedLimit = _cardLimits[_currentCardIndex];
      });
    } catch (e) {
      _showError('Error navigating to next card: $e');
    }
  }

  void _previousCard() {
    try {
      if (_cards.isEmpty) {
        _showError('No cards available');
        return;
      }

      setState(() {
        _currentCardIndex =
            (_currentCardIndex - 1 + _cards.length) % _cards.length;
        _selectedCardIndex = _currentCardIndex;
        _counter = _cardCounters[_currentCardIndex] ?? 0;
        _selectedLimit = _cardLimits[_currentCardIndex];
      });
    } catch (e) {
      _showError('Error navigating to previous card: $e');
    }
  }

  void _resetCurrentCounter() {
    if (!_validateCardSelection()) return;

    try {
      setState(() {
        _counter = 0;
        _cardCounters[_selectedCardIndex] = 0;
        _cardRounds[_selectedCardIndex] = 0;
      });
    } catch (e) {
      _showError('Error resetting counter: $e');
    }
  }

  void _resetAllCounters() {
    try {
      setState(() {
        _cardCounters.clear();
        _cardLimits.clear();
        _cardRounds.clear();
        _counter = 0;
        _selectedLimit = null;
      });
    } catch (e) {
      _showError('Error resetting all counters: $e');
    }
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

  // Window One - Card Detail Section
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
                  '${_currentCardIndex + 1}/${_cards.length}', //index
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
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
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
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => FullDuasPage(
                                  cards: _cards,
                                  onDuaSelected: (index) {
                                    setState(() {
                                      _currentCardIndex = index;
                                      _selectedCardIndex = index;
                                      _counter = _cardCounters[index] ?? 0;
                                      _selectedLimit = _cardLimits[index];
                                    });
                                  },
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book),
                      label: const Text('View Full Duas'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
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
        child: GestureDetector(
          onTap: _incrementCounter,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.1),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _incrementCounter,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tasbih Counter',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedLimit != null
                            ? '$_counter/$_selectedLimit'
                            : '$_counter',
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontSize: 48,
                        ),
                      ),
                      if (_selectedLimit != null)
                        Text(
                          'Round ${(_cardRounds[_selectedCardIndex] ?? 0) + 1}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                elevation: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: const Text('Select Counter Limit'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () {
                            _setCounterLimit(11);
                            Navigator.pop(context);
                          },
                          child: const Text('11 counts'),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            _setCounterLimit(33);
                            Navigator.pop(context);
                          },
                          child: const Text('33 counts'),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            _setCounterLimit(99);
                            Navigator.pop(context);
                          },
                          child: const Text('99 counts'),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            Navigator.pop(context);
                            Future.delayed(Duration(milliseconds: 100), () {
                              _showCustomLimitDialog();
                            });
                          },
                          child: const Text('Custom limit'),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            _setCounterLimit(null);
                            Navigator.pop(context);
                          },
                          child: const Text('Infinite'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Counter (${_selectedLimit ?? "∞"})',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _showResetDialog,
            color: AppTheme.primaryColor,
          ),
          Container(
            margin: const EdgeInsets.only(left: 8),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withOpacity(0.2),
              border: Border.all(color: AppTheme.primaryColor, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final controller = TextEditingController();
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            const Text(
                              'Custom Counter',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: '',
                            labelText: 'Custom Limit',
                            errorText: errorText,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.numbers),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => controller.clear(),
                            ),
                            helperText: 'This will be your new counter limit',
                            helperMaxLines: 2,
                            errorMaxLines: 2,
                          ),
                          onChanged: (value) {
                            setState(() {
                              final number = int.tryParse(value);
                              if (value.isEmpty) {
                                errorText = null;
                              } else if (number == null) {
                                errorText = 'Please enter a valid number';
                              } else if (number <= 0) {
                                errorText = 'Number must be greater than 0';
                              } else if (number > 9999999999) {
                                errorText = 'Number must be 9999 or less';
                              } else {
                                errorText = null;
                              }
                            });
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          onSubmitted:
                              (value) => _handleCustomLimitSubmission(
                                context,
                                controller.text,
                                errorText,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('CANCEL'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed:
                                  () => _handleCustomLimitSubmission(
                                    context,
                                    controller.text,
                                    errorText,
                                  ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                              ),
                              child: const Text('SET'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleCustomLimitSubmission(
    BuildContext context,
    String value,
    String? errorText,
  ) {
    if (errorText != null) {
      return;
    }

    final limit = int.tryParse(value);
    if (limit != null && limit > 0 && limit <= 9999999999) {
      _setCounterLimit(limit);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Counter limit set to $limit'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => _setCounterLimit(null),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number between 1 and 999'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
              _isVibrationEnabled ? Icons.vibration : Icons.do_not_disturb_on,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isVibrationEnabled = !_isVibrationEnabled;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isVibrationEnabled
                        ? 'Vibration feedback enabled'
                        : 'Vibration feedback disabled',
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Toggle vibration',
          ),
          IconButton(
            icon: Icon(
              _isSoundEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSoundEnabled = !_isSoundEnabled;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isSoundEnabled
                        ? 'Sound feedback enabled'
                        : 'Sound feedback disabled',
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Toggle sound',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCardDetailWindow(),
          _buildCounterDisplayWindow(),
          _buildControlPanel(),
        ],
      ),
    );
  }
}
