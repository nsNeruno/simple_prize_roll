final globalPrizes = <String>[
  ...List.generate(20, (index) => "Random${(20 - index).toString().padLeft(2, '0')}",),
  "Juara 3",
  "Juara 2",
  "Juara 1",
];

final globalEntries = List.generate(
  100, (index) => "JT123456789${index.toString().padLeft(3, '0',)}",
).toList(growable: false,);