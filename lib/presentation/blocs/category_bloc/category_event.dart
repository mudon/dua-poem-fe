abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {}

class CreateCategory extends CategoryEvent {
  final String name;
  final String? description;
  CreateCategory(this.name, this.description);
}

class UpdateCategory extends CategoryEvent {
  final int id;
  final String name;
  final String? description;
  UpdateCategory(this.id, this.name, this.description);
}

class DeleteCategory extends CategoryEvent {
  final int id;
  DeleteCategory(this.id);
}
