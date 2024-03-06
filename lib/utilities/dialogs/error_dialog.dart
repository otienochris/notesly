import 'package:flutter/cupertino.dart';
import 'package:notesly/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
    {required BuildContext context, required String text}) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occurred',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
