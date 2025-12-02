String buildAndWhereClause(List<String> columns) {
  return columns.map((c) => '$c = ?').join(' AND ');
}

String buildOrWhereClause(List<String> columns) {
  return columns.map((c) => '$c = ?').join(' OR ');
}

String buildInClause(String column, int count) {
  if (count <= 0) return '';
  return '$column IN (${List.filled(count, '?').join(',')})';
}
