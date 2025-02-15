import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Note> _notes = [];
  final LocalStorage storage = LocalStorage('notes_app');

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    await storage.ready;
    List<dynamic>? storedNotes = storage.getItem('notes');
    if (storedNotes != null) {
      setState(() {
        _notes.addAll(storedNotes.map((note) => Note.fromJson(note)));
      });
    }
    _screens.addAll([
      NotesListScreen(notes: _notes, onDelete: _deleteNote),
      CreateNoteScreen(onSave: _addNote),
      UserInfoScreen(),
    ]);
  }

  void _addNote(Note note) {
    setState(() {
      _notes.add(note);
      _selectedIndex = 0;
      _saveNotes();
    });
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
      _saveNotes();
    });
  }

  void _saveNotes() {
    storage.setItem('notes', _notes.map((note) => note.toJson()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.notes),
                label: Text('Notas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add),
                label: Text('Nueva Nota'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Usuario'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _screens.isNotEmpty ? _screens[_selectedIndex] : Container()),
        ],
      ),
    );
  }
}

class Note {
  final String title;
  final String content;

  Note({required this.title, required this.content});

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
      };

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      content: json['content'],
    );
  }
}

class NotesListScreen extends StatelessWidget {
  final List<Note> notes;
  final Function(int) onDelete;

  NotesListScreen({required this.notes, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(note.title),
          subtitle: Text(note.content),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(index),
          ),
        );
      },
    );
  }
}

class CreateNoteScreen extends StatefulWidget {
  final Function(Note) onSave;

  CreateNoteScreen({required this.onSave});

  @override
  _CreateNoteScreenState createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;
    if (title.isNotEmpty && content.isNotEmpty) {
      widget.onSave(Note(title: title, content: content));
      _titleController.clear();
      _contentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Título'),
          ),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(labelText: 'Contenido'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveNote,
            child: Text('Guardar Nota'),
          ),
        ],
      ),
    );
  }
}

class UserInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          SizedBox(height: 16),
          Text('Giscard Perez', style: TextStyle(fontSize: 20)),
          Text('ing.giscard@gmail.com', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
