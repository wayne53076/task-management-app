import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management_app/view_models/all_todos_vm.dart';
import 'package:task_management_app/models/todo.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _assigneeController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  String _importance = 'Low';
  late List<Todo> _todos;

  @override
  void initState() {
    super.initState();
    _todos = [];
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(
      BuildContext context, void Function(DateTime) onDateTimePicked) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onDateTimePicked(pickedDateTime);
      }
    }
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        Todo newTodo = Todo(
          taskName: _taskController.text,
          description: _descriptionController.text,
          startTime: _startTime != null ? _startTime! : DateTime.now(),
          endTime: _endTime != null ? _endTime! : DateTime.now(),
          importance: _importance,
          assignee: _assigneeController.text,
          isDone: false,
        );
        Provider.of<AllTodosViewModel>(context, listen: false).addTodo(newTodo);
        _taskController.clear();
        _descriptionController.clear();
        _startTime = null;
        _endTime = null;
        _assigneeController.clear();
        _importance = 'Low';
      });
    }
  }

  void _toggleCompletion(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
      Provider.of<AllTodosViewModel>(context, listen: false)
          .updateTodoById(_todos[index].id!, _todos[index]);
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _todos.removeAt(index);
      Provider.of<AllTodosViewModel>(context, listen: false)
          .deleteTodoById(_todos[index].id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    _todos = Provider.of<AllTodosViewModel>(context, listen: true).todos!;
    if( Provider.of<AllTodosViewModel>(context, listen: false).isInitializing){
      return const CircularProgressIndicator();
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(hintText: 'Enter a task'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                              hintText: 'Enter description'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _importance,
                          items: ['Low', 'Medium', 'High'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _importance = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _assigneeController,
                          decoration:
                              const InputDecoration(hintText: 'Enter assignee'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTask,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _pickDateTime(context, (picked) {
                          setState(() {
                            _startTime = picked;
                          });
                        }),
                      ),
                      Text(_startTime == null
                          ? 'Start Time: Not set'
                          : 'Start Time: ${_startTime!.toString()}'),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _pickDateTime(context, (picked) {
                          setState(() {
                            _endTime = picked;
                          });
                        }),
                      ),
                      Text(_endTime == null
                          ? 'End Time: Not set'
                          : 'End Time: ${_endTime!.toString()}'),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '''Total tasks: ${_todos.length}  
                Remaining tasks: ${_todos.length - _todos.where((task) => task.isDone).length}   
                Complete ratio: ${(_todos.isNotEmpty ?
                 (_todos.where((task) => task.isDone).length / _todos.length) * 100 : 0)
                 .toStringAsFixed(1)}%''',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  200, // Adjust height as needed
              child: _todos.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks available.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _todos.length,
                      itemBuilder: (context, index) {
                        final task = _todos[index];
                        return ListTile(
                          title: Text(
                            task.taskName,
                            style: TextStyle(
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Description: ${task.description}'),
                              Text('Start Time: ${_showTime(task.startTime)}'),
                              Text('End Time: ${_showTime(task.endTime)}'),
                              Text('Importance: ${task.importance}'),
                              Text('Assignee: ${task.assignee}'),
                            ],
                          ),
                          leading: Checkbox(
                            value: task.isDone,
                            onChanged: (value) => _toggleCompletion(index),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteTask(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _showTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  }
}
