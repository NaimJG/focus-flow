import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/todo/data/models/category_model.dart';
import '../../features/todo/data/models/task_model.dart';

/// Opens the Isar database with all registered collection schemas.
///
/// Uses the application documents directory as the storage location.
/// Returns the opened [Isar] instance ready for use by repositories.
Future<Isar> openIsar() async {
  final dir = await getApplicationDocumentsDirectory();

  return Isar.open([TaskModelSchema, CategoryModelSchema], directory: dir.path);
}
