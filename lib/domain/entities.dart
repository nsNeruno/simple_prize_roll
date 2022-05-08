class RollEntry implements Comparable {

  RollEntry({required this.id, this.fixedPrize,});

  final String id;
  final String? fixedPrize;
  String? wonPrize;

  @override
  int compareTo(other) {
    if (other is RollEntry) {
      return id.compareTo(other.id,);
    }
    return -1;
  }
}

class RollPrize {

  RollPrize({
    required this.name,
    int? count,
    this.fixedEntries,
  }): count = count?.abs() ?? 1;

  final String name;
  final int count;
  final List<String>? fixedEntries;
}