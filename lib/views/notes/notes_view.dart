import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:notesly/constants/routes.dart';
import 'package:notesly/model/entities/database_note.dart';
import 'package:notesly/services/auth/auth_service.dart';
import 'package:notesly/services/notes/notes_service.dart';
import 'package:notesly/views/notes/notes_list_view.dart';

import '../../enums/menu_actions.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;

  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    _notesService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.home, color: Colors.white),
        title: const Text(
          'My notes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrangeAccent,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  newNoteRoute,
                );
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              )),
          PopupMenuButton<MenuActionsEnum>(
            onSelected: (selected) async {
              devtools.log(selected.name);
              switch (selected) {
                case MenuActionsEnum.logout:
                  bool shouldLogout = await showLogoutDialog(context: context);
                  devtools.log(shouldLogout.toString());
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    );
                  }
                case MenuActionsEnum.addNewNote:
                  Navigator.of(context).pushNamed(
                    newNoteRoute,
                  );
              }
            },
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            itemBuilder: (BuildContext context) {
              return const [
                PopupMenuItem<MenuActionsEnum>(
                  value: MenuActionsEnum.logout,
                  child: Text('Log Out'),
                ),
                PopupMenuItem<MenuActionsEnum>(
                  value: MenuActionsEnum.addNewNote,
                  child: Text('Create note'),
                )
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (
          context,
          snapshot,
        ) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (
                  context,
                  snapshot,
                ) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        /*for(final note in allNotes)
                          print(note.toString());*/
                        return NotesListView(
                            notes: allNotes,
                            onDeleteNote: (note) async {
                              await _notesService.deleteNote(id: note.id);
                            });
                      } else {
                        return const CircularProgressIndicator();
                      }
                    // return const Text('waiting for all notes ...');
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
