import 'package:flutter/material.dart';
import '../models/tasbih_card.dart';
import '../theme/app_theme.dart';

class FullDuasPage extends StatelessWidget {
  final List<TasbihCard> cards;
  final Function(int) onDuaSelected;

  const FullDuasPage({
    Key? key,
    required this.cards,
    required this.onDuaSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Duas'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                card.text,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                card.translation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                onDuaSelected(index);
                Navigator.pop(context);
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
    );
  }
}
