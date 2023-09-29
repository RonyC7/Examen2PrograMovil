import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Color.fromARGB(255, 52, 218, 11),
      hintColor: Color.fromARGB(255, 0, 0, 0),
      scaffoldBackgroundColor: Color.fromARGB(255, 248, 243, 230),
    ),
    home: TodoApp(),
  ));
}

class Todo {
  String title;
  String description;
  bool isCompleted;

  Todo({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List<Todo> todos = [];
  final StreamController<List<Todo>> _streamController =
      StreamController<List<Todo>>();

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  void _createTodoModal(BuildContext context, String cabezal, int orden,
      bool allowEdit, String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(cabezal),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                enabled: allowEdit,
                initialValue: title,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  title = value;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                enabled: allowEdit,
                initialValue: description,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  description = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            Visibility(
              visible: allowEdit,
              child: ElevatedButton(
                onPressed: () {
                  if (title.isNotEmpty && description.isNotEmpty) {
                    if (orden <= -1) {
                      todos.add(Todo(title: title, description: description));
                    } else {
                      todos[orden] =
                          Todo(title: title, description: description);
                    }

                    _streamController.add(todos);
                    Navigator.of(context).pop();
                    if (orden <= -1) {
                      _showSuccessMessage('Tarea creada con éxito');
                    } else {
                      _showSuccessMessage('Tarea modificada con éxito');
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text("Por favor, complete todos los datos"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cerrar'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white, // Cambia el color del botón a blanco
                  onPrimary: Colors
                      .blue, // Cambia el color del texto cuando se presiona
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // ... (el resto del código)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.check_circle),
            SizedBox(width: 8),
            Text('Lista de Tareas'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _createTodoModal(context, 'Nueva Tarea', -1, true, '', '');
              },
              child: Text(
                'Agregar Tarea',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue, // Cambia el color del texto a azul
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.white, // Cambia el color del botón a blanco
                onPrimary:
                    Colors.blue, // Cambia el color del texto cuando se presiona
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Todo>? todos = snapshot.data;
                  return ListView.builder(
                    itemCount: todos?.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          tileColor: todos![index].isCompleted
                              ? Colors.greenAccent
                              : Color.fromARGB(255, 228, 138, 138),
                          title: Text(
                            todos[index].title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            todos[index].description,
                            style: TextStyle(fontSize: 16),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _toggleTodoCompletion(index);
                                  if (todos[index].isCompleted) {
                                    _showCompletionMessage();
                                  }
                                },
                                icon: Icon(
                                  todos[index].isCompleted
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _createTodoModal(
                                    context,
                                    'Editar Tarea',
                                    index,
                                    true,
                                    todos[index].title,
                                    todos[index].description,
                                  );
                                },
                                icon: Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () {
                                  _showDeleteConfirmationDialog(index);
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
                          onTap: () {
                            _createTodoModal(
                              context,
                              'Detalles de Tarea',
                              -1,
                              false,
                              todos[index].title,
                              todos[index].description,
                            );
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ... (el resto del código)

  void _toggleTodoCompletion(int index) {
    todos[index].isCompleted = !todos[index].isCompleted;
    _streamController.add(todos);
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Tarea'),
          content: Text('¿Está seguro de que desea eliminar esta tarea?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _deleteTodo(index);
                Navigator.of(context).pop();
                _showSuccessMessage('Tarea eliminada con éxito');
              },
              child: Text('Sí'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTodo(int index) {
    todos.removeAt(index);
    _streamController.add(todos);
  }

  void _showCompletionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text('Tarea Completada '),
            Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
