import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:task_management_app/models/todo.dart';
import 'package:task_management_app/repositories/todo_repo.dart';

class AllTodosViewModel with ChangeNotifier {
  final TodoRepository _todoRepository;
  StreamSubscription<List<Todo>>? _todosSubscription;

  final StreamController<List<Todo>> _todoStreamController = StreamController<List<Todo>>();
  Stream<List<Todo>> get todoStream => _todoStreamController.stream;

  List<Todo>? _todos = [];
  List<Todo>? get todos => _todos;
  String _serverId;
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  AllTodosViewModel(String serverId,{TodoRepository? todoRepository})
      : _serverId = serverId, _todoRepository = todoRepository ?? TodoRepository() {
    _initialize();
  }

  void _initialize() {
    _todosSubscription = _todoRepository.streamTodo(_serverId).listen(
      (todos) {
        _isInitializing = false;
        _todos = todos;
        notifyListeners();
      },
    );

  }


  @override
  void dispose() {
    _todosSubscription?.cancel();
    _todoStreamController.close();
    super.dispose();
  }

  void updateServerId(String newServerId) {
    if (newServerId != _serverId) {
      _todosSubscription?.cancel();
      _serverId = newServerId;
      _isInitializing = true; 
      notifyListeners(); 
      _initialize();
    }
  }

  Future<void> addTodo(Todo newTodo) async {
    await _todoRepository.addTodo(_serverId, newTodo);
  }

  Future<void> deleteTodoById(String todoId) async {
    await _todoRepository.deleteTodo(_serverId, todoId);
  }

  Future<void> updateTodoById(String todoId, Todo todo) async {
    await _todoRepository.updateTodo(_serverId, todoId, todo);
  }
}
