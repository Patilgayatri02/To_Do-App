import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart'; 
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.light(),
      themeMode: ThemeMode.system,
      home: ToDoListScreen(),
    );
  }
}

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  List<Map<String, dynamic>> toDoItems = [];
  final List<Color> cardColors = [
    Color.fromRGBO(250, 232, 232, 1),
    Color.fromRGBO(232, 237, 250, 1),
    Color.fromRGBO(250, 249, 232, 1),
    Color.fromRGBO(250, 232, 250, 1),
    Color.fromRGBO(250, 232, 232, 1),
  ];

  @override
  void initState() {
    super.initState();
    _loadToDoList();
  }

  Future<void> _loadToDoList() async {
    List<Map<String, dynamic>> data = await DatabaseHelper.instance.getToDoList();
    setState(() {
      toDoItems = data;
    });
  }

  Future<void> _addOrUpdateToDo(String title, String description, String date, {int? id}) async {
    if (id == null) {
      await DatabaseHelper.instance.insertToDo({
        'title': title,
        'description': description,
        'date': date,
      });
    } else {
      await DatabaseHelper.instance.updateToDo({
        'id': id,
        'title': title,
        'description': description,
        'date': date,
      });
    }
    _loadToDoList();
  }

  Future<void> _deleteToDo(int id) async {
    await DatabaseHelper.instance.deleteToDo(id);
    _loadToDoList();
  }

  void _showToDoBottomSheet(BuildContext context, {int? index}) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    if (index != null) {
      titleController.text = toDoItems[index]['title'];
      descriptionController.text = toDoItems[index]['description'];
      selectedDate = DateTime.parse(toDoItems[index]['date']);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Create To-Do",
                 style: GoogleFonts.quicksand(fontSize:22 ,fontWeight: FontWeight.w600,color: Color.fromRGBO(0, 0, 0, 1),
                 ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
              const SizedBox(height: 12),
              TextField(controller: descriptionController, decoration: InputDecoration(labelText: "Description")),
              const SizedBox(height: 12),

              
              InkWell(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Date",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat("dd MMMM yyyy").format(selectedDate), 
                  ),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                    _addOrUpdateToDo(
                      titleController.text,
                      descriptionController.text,
                      selectedDate.toIso8601String(),
                      id: index != null ? toDoItems[index]['id'] : null,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text(index == null ? "Submit" : "Update"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To-do list",style: GoogleFonts.quicksand(fontSize:26 ,fontWeight: FontWeight.w700,color: Color.fromRGBO(255, 255, 255, 1),

        ),
        ), backgroundColor: Color.fromRGBO(2, 167, 177, 1)),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: toDoItems.length,
        itemBuilder: (context, index) {
          return Card(
            color: cardColors[index % cardColors.length],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                        radius: 24,
                        child: Icon(Icons.image, color: Colors.grey.shade600, size: 28),
                      ),
                      const SizedBox(height: 6), 
                      Text(
                        DateFormat("dd MMMM yyyy").format(DateTime.parse(toDoItems[index]['date'])), 
                        style: GoogleFonts.quicksand(
                          color: Color.fromRGBO(0, 0, 0, 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                 
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toDoItems[index]['title'],
                          style: GoogleFonts.quicksand(fontSize:12 ,fontWeight: FontWeight.w600,color: Color.fromRGBO(0, 0, 0, 1),   ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          toDoItems[index]['description'],
                          style: GoogleFonts.quicksand(fontSize:10 ,fontWeight: FontWeight.w500,color: Color.fromRGBO(84,84,84, 1),
        ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color:Color.fromRGBO(0, 139, 148, 1),  size: 18), onPressed: () => _showToDoBottomSheet(context, index: index)),
                      IconButton(icon: const Icon(Icons.delete, color: Color.fromRGBO(0, 139, 148, 1), size: 18), onPressed: () => _deleteToDo(toDoItems[index]['id'])),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(0, 139, 148, 1),
        onPressed: () => _showToDoBottomSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
