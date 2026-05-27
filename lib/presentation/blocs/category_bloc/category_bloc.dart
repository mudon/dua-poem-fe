import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepo;

  CategoryBloc(this._categoryRepo) : super(CategoryState()) {
    on<LoadCategories>(_onLoad);
    on<CreateCategory>(_onCreate);
    on<UpdateCategory>(_onUpdate);
    on<DeleteCategory>(_onDelete);
  }

  Future<void> _onLoad(LoadCategories event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _categoryRepo.getAll();
    if (result.isSuccess) {
      emit(state.copyWith(isLoading: false, categories: result.data!));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _onCreate(CreateCategory event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _categoryRepo.create(event.name, event.description);
    if (result.isSuccess) {
      final categories = [...state.categories, result.data!];
      emit(state.copyWith(isLoading: false, categories: categories));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _onUpdate(UpdateCategory event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _categoryRepo.update(event.id, event.name, event.description);
    if (result.isSuccess) {
      final categories = state.categories.map((c) => c.id == event.id ? result.data! : c).toList();
      emit(state.copyWith(isLoading: false, categories: categories));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }

  Future<void> _onDelete(DeleteCategory event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _categoryRepo.delete(event.id);
    if (result.isSuccess) {
      final categories = state.categories.where((c) => c.id != event.id).toList();
      emit(state.copyWith(isLoading: false, categories: categories));
    } else {
      emit(state.copyWith(isLoading: false, error: result.error));
    }
  }
}
