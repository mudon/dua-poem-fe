abstract class TagEvent {}

class LoadTags extends TagEvent {}

class CreateTag extends TagEvent {
  final String name;
  CreateTag(this.name);
}

class UpdateTag extends TagEvent {
  final int id;
  final String name;
  UpdateTag(this.id, this.name);
}

class DeleteTag extends TagEvent {
  final int id;
  DeleteTag(this.id);
}
