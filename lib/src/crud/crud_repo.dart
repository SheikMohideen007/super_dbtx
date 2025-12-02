abstract class CrudRepo<T> {
  Future<int> save(T model);
  Future<int> update(T model);
  Future<int> deleteById(dynamic id);
  Future<int> deleteAll();

  Future<List<T>> getAll({String? orderBy});
  Future<T?> getOneById(dynamic id);

  Future<List<T>> getByColumn(String column, dynamic value);
  Future<List<T>> getByColumns(List<String> columns, List<dynamic> values);
}
