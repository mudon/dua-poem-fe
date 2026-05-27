import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/tag_repository.dart';
import 'tag_event.dart';
import 'tag_state.dart';

class TagBloc extends Bloc<TagEvent, TagState> {
  final TagRepository _tagRepo;

  TagBloc(this._tagRepo) : super(TagState()) {
    on<LoadTags>(_onLoad);
    on<CreateTag>(_onCreate);
    on<UpdateTag>(_onUpdate);
    on<DeleteTag>(_onDelete);
  }

  Future<void> _onLoad(LoadTags event, Emitter<TagState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _tagRepo.getAll();
    if (result.isSuccess) {
      emit(state.copyWith(isLoading: false, tags: result.data!));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _onCreate(CreateTag event, Emitter<TagState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _tagRepo.create(event.name);
    if (result.isSuccess) {
      final tags = [...state.tags, result.data!];
      emit(state.copyWith(isLoading: false, tags: tags));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _onUpdate(UpdateTag event, Emitter<TagState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _tagRepo.update(event.id, event.name);
    if (result.isSuccess) {
      final tags = state.tags.map((t) => t.id == event.id ? result.data! : t).toList();
      emit(state.copyWith(isLoading: false, tags: tags));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _onDelete(DeleteTag event, Emitter<TagState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _tagRepo.delete(event.id);
    if (result.isSuccess) {
      final tags = state.tags.where((t) => t.id != event.id).toList();
      emit(state.copyWith(isLoading: false, tags: tags));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }
}
