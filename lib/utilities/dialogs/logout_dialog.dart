import 'package:flutter/cupertino.dart';
import 'package:notesly/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog({required BuildContext context}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Log out',
    content: 'Are you sure you want to log out?',
    optionsBuilder: () => {
      'Cancel': false,
      'Log out': true,
    },
  ).then((value) => value ?? false);
}
