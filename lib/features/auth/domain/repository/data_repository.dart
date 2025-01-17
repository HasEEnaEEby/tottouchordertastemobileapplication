abstract class DataRepository {
  Future<void> saveData(Map<String, dynamic> data);
  Future<void> syncData();
  Future<List<Map<String, dynamic>>> getPendingSync();
}