import 'dart:io';

import 'package:afl/controller/home_vc.dart';
import 'package:afl/models/model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPlayerVC extends StatefulWidget {
  final String title;
  final Function(Player) onSave;
  final Player? existingPlayer;

  const AddPlayerVC({
    super.key,
    required this.title,
    required this.onSave,
    this.existingPlayer,
  });

  @override
  AddPlayerVCState createState() => AddPlayerVCState();
}

class AddPlayerVCState extends State<AddPlayerVC> {
  final ImagePicker picker = ImagePicker();

  // Controllers for name and each AFL stat
  final TextEditingController nameController = TextEditingController();
  final TextEditingController goalsController = TextEditingController();
  final TextEditingController behindsController = TextEditingController();
  final TextEditingController kicksController = TextEditingController();
  final TextEditingController handballsController = TextEditingController();
  final TextEditingController marksController = TextEditingController();
  final TextEditingController tacklesController = TextEditingController();

  bool isCaptain = false;
  File? selectedImage;

  @override
  void initState() {
    super.initState();

    if (widget.existingPlayer != null) {
      final p = widget.existingPlayer!;
      nameController.text = p.name ?? '';
      isCaptain = p.isCaptain;
      goalsController.text = p.goals.toString();
      behindsController.text = p.behinds.toString();
      kicksController.text = p.kicks.toString();
      handballsController.text = p.handballs.toString();
      marksController.text = p.marks.toString();
      tacklesController.text = p.tackles.toString();
    }
  }

  Future<void> pickImage() async {
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      setState(() {
        selectedImage = File(image.path);
      });
    } on Exception catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  void savePlayer() {
    if (nameController.text.trim().isEmpty) {
      showAlert('Alert', 'Please enter a player name.');
      return;
    }

    // Parse each stat, defaulting to 0 if empty or invalid
    int parseStat(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

    final player = Player(
      documentID: widget.existingPlayer?.documentID,
      name: nameController.text.trim(),
      isCaptain: isCaptain,
      image: selectedImage,
      goals: parseStat(goalsController),
      behinds: parseStat(behindsController),
      kicks: parseStat(kicksController),
      handballs: parseStat(handballsController),
      marks: parseStat(marksController),
      tackles: parseStat(tacklesController),
    );

    widget.onSave(player);
    Navigator.pop(context);
  }

  void showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Widget buildStatField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Image picker
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!) as ImageProvider
                      : const AssetImage('assets/userIcon.png'),
                ),
              ),
              const SizedBox(height: 16),
        
              // Name field
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Player Name',
                  border: OutlineInputBorder(),
                ),
              ),
        
              const SizedBox(height: 16),
        
              // Captain toggle
              SwitchListTile(
                title: const Text('Is Captain?'),
                value: isCaptain,
                onChanged: (v) => setState(() => isCaptain = v),
              ),
        
              const SizedBox(height: 16),
        
              // Stats inputs
              buildStatField('Goals', goalsController),
              buildStatField('Behinds', behindsController),
              buildStatField('Kicks', kicksController),
              buildStatField('Handballs', handballsController),
              buildStatField('Marks', marksController),
              buildStatField('Tackles', tacklesController),
        
              const SizedBox(height: 24),
              AFLButtonWidget(
                  title: widget.existingPlayer != null ? 'Update Player' : 'Add Player',
                  onTap: savePlayer
              )
            ],
          ),
        ),
      ),
    );
  }
}
