String normalizeOnTheWay(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[_\s]+'), '-');
