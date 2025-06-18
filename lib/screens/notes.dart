import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteWidget extends StatefulWidget {
  const NoteWidget({super.key});

  static Future<void> ensureNotesCollection() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes');

    final snapshot = await notesCollection.limit(1).get();

    if (snapshot.docs.isEmpty) {
      await notesCollection.add({
        'title': 'Welcome Note',
        'note': 'This is your first note!',
        'category': 'Personal',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  State<NoteWidget> createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = ['Personal', 'Work', 'Ideas'];
  String selectedCategory = 'Personal';
  String? filterCategory;

  late final String userId;
  late final CollectionReference notesCollection;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes');
  }

  void addOrUpdateNote({String? id}) async {
    final data = {
      'title': titleController.text.trim(),
      'note': noteController.text.trim(),
      'category': selectedCategory,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (id == null) {
      await notesCollection.add(data);
    } else {
      await notesCollection.doc(id).update(data);
    }

    titleController.clear();
    noteController.clear();
    selectedCategory = 'Personal';
  }

  void deleteNote(String id) async {
    await notesCollection.doc(id).delete();
  }

  void showNoteDialog(
      {String? id, String? title, String? note, String? category}) {
    if (title != null) titleController.text = title;
    if (note != null) noteController.text = note;
    String tempCategory = category ?? selectedCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              const Icon(Icons.note_add, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(
                id == null ? 'Add Note' : 'Edit Note',
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.title, color: Colors.deepPurple),
                    hintText: 'Title',
                    filled: true,
                    fillColor: Colors.deepPurple.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  maxLines: 60,
                  minLines: 1,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.notes, color: Colors.deepPurple),
                    hintText: 'Enter your note here',
                    filled: true,
                    fillColor: Colors.deepPurple.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Category',
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: tempCategory,
                      items: categories
                          .map((value) => DropdownMenuItem(
                              value: value, child: Text(value)))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() => tempCategory = newValue!);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                titleController.clear();
                noteController.clear();
                selectedCategory = 'Personal';
              },
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.deepPurple)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    noteController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                selectedCategory = tempCategory;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(id == null
                          ? 'Note added successfully'
                          : 'Note updated successfully')),
                );

                addOrUpdateNote(id: id);
                Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child:
                  const Text('Save', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.note_alt_outlined, color: Colors.white),
            SizedBox(width: 8),
            Flexible(
              child: Text('Note Recipe',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple.shade700,
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showNoteDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Note', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filter',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                    value: filterCategory,
                    items: [null, ...categories].map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat ?? 'All'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => filterCategory = val),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: notesCollection
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notes = snapshot.data?.docs.where((doc) {
                  final cat = doc['category'] as String?;
                  final title = doc['title'] as String?;
                  return (filterCategory == null || cat == filterCategory) &&
                      (searchController.text.isEmpty ||
                          (title?.toLowerCase().contains(
                                  searchController.text.toLowerCase()) ??
                              false));
                }).toList();

                if (notes == null || notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book_rounded,
                            color: Colors.deepPurple, size: 80),
                        const SizedBox(height: 16),
                        const Text('No notes found!',
                            style: TextStyle(
                                fontSize: 24, color: Colors.deepPurple)),
                        const SizedBox(height: 8),
                        Text('Try adding or searching for a note.',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.deepPurple.shade200)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final doc = notes[index];
                    final Timestamp? timestamp = doc['createdAt'];
                    final String formattedDate = timestamp != null
                        ? DateFormat.yMMMd().format(timestamp.toDate())
                        : '';
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc['title'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            const SizedBox(height: 6),
                            Text(doc['note']),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Category: ${doc['category']}',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600])),
                                Text(formattedDate,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.deepPurple),
                                  onPressed: () => showNoteDialog(
                                    id: doc.id,
                                    title: doc['title'],
                                    note: doc['note'],
                                    category: doc['category'],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Color.fromARGB(255, 165, 13, 2)),
                                  onPressed: () => deleteNote(doc.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
