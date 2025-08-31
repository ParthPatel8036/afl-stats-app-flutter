import 'package:afl/controller/home_vc.dart';
import 'package:afl/models/model.dart';
import 'package:flutter/material.dart';

class OverlayDialog extends StatelessWidget {
  final String? title;
  final Team? teamObj;
  final Function(String, Team?) onSave;
  final Function onCancel;

  const OverlayDialog({
    super.key,
    this.title,
    this.teamObj,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController textController =
        TextEditingController(text: teamObj?.name ?? "");

    return GestureDetector(
      onTap: () {
        onCancel();
      },
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 288,
            height: 288,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Center(
                    child: Text(
                      title!,
                      style: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 15),
                const Text(
                  "Team Name",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 50,
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Team Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AFLButtonWidget(
                      title: 'Save',
                      onTap: () {
                        onSave(textController.text, teamObj);
                      },
                    ),
                    const SizedBox(height: 10),
                    AFLButtonWidget(
                      title: 'Cancel',
                      onTap: () {
                        onCancel();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
