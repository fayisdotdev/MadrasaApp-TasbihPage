class TasbihCard {
  final String text;
  final String arabicText;
  final String translation;
  final String description;

  const TasbihCard({
    required this.text,
    required this.arabicText,
    required this.translation,
    required this.description,
  });
}

class TasbihCards {
  static const List<TasbihCard> cards = [
    TasbihCard(
      text: 'SubhanAllah',
      arabicText: 'سُبْحَانَ ٱللَّٰهِ',
      translation: 'Glory be to Allah',
      description:
          'Glorifying Allah by declaring Him free from any imperfection',
    ),
    TasbihCard(
      text: 'Alhamdulillah',
      arabicText: 'ٱلْحَمْدُ لِلَّٰهِ',
      translation: 'All praise is due to Allah',
      description: 'Expressing gratitude and praise to Allah',
    ),
    TasbihCard(
      text: 'Allahu Akbar',
      arabicText: 'اللّٰهُ أَكْبَرُ',
      translation: 'Allah is the Greatest',
      description: 'Declaring the greatness of Allah',
    ),
    TasbihCard(
      text: 'La ilaha illallah',
      arabicText: 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ',
      translation:
          'There is no god but Allah', // There is no deity except Allah
      description: 'Affirming the oneness of Allah',
    ),
  ];
}
