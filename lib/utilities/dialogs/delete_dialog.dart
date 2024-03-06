import 'package:flutter/cupertino.dart';
import 'package:notesly/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog({required BuildContext context}) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this item?',
    optionsBuilder: () => {
      'Cancel': false,
      'Yes': true,
    },
  ).then((value) => value ?? false);
}
