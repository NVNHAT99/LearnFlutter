import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_services.dart';
import 'package:mynotes/services/curd/note_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  late final NoteService _noteService;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _noteService = NoteService();
    _textEditingController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }

    final text = _textEditingController.text;
    await _noteService.updateNote(note: note, text: text);
  }

  void _setupTextControllerListener() {
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthServices.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _noteService.getUser(email: email);
    return await _noteService.createNote(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textEditingController.text.isEmpty && note != null) {
      await _noteService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textEditingController.text;
    if (text.isNotEmpty && note != null) {
      await _noteService.updateNote(note: note, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // _note = snapshot.data as DatabaseNote;
              // _setupTextControllerListener();
              // return TextField(
              //   controller: _textEditingController,
              //   keyboardType: TextInputType.multiline,
              //   maxLines: null,
              //   decoration: const InputDecoration(
              //     hintText: 'start typing your note...',
              //   ),
              // );
              if (snapshot.hasData) {
                _note = snapshot.data as DatabaseNote;
                _setupTextControllerListener();
                return TextField(
                  controller: _textEditingController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'start typing your note...',
                  ),
                );
              } else if (snapshot.hasError) {
                // Xử lý lỗi
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                // Data là null
                return const Center(child: Text('Could not create note'));
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
