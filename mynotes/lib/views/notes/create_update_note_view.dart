import 'package:flutter/material.dart';
import 'package:mynotes/Utilities/extension/build_context_ext.dart';
import 'package:mynotes/services/auth/auth_services.dart';
import 'package:mynotes/services/curd/note_service.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
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

  Future<DatabaseNote> createOrGetExistNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textEditingController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthServices.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _noteService.getUser(email: email);
    final newNote = await _noteService.createNote(owner: owner);
    _note = newNote;
    return newNote;
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
        future: createOrGetExistNote(context),
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
