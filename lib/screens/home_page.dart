import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import '../services/db_helper.dart';
import '../utils/validators.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final DBHelper _dbHelper = DBHelper();
  List<Student> _students = [];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _classController = TextEditingController();
  final _deptController = TextEditingController();
  String _gender = 'Male';
  int? _editingId;

late DBHelper _dbHelper;

  @override
  void initState() {
  super.initState();
  _initializeDatabase();
  }
  Future<void> _initializeDatabase() async {
    _dbHelper = DBHelper();
    await _dbHelper.init();         // ✅ Initialize DB properly
    await _loadStudents();          // ✅ Now it's safe to fetch students
  }

  Future<void> _loadStudents() async {
    final data = await _dbHelper.getStudents();
    setState(() => _students = data);
  }

  void _resetForm() {
    _editingId = null;
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _classController.clear();
    _deptController.clear();
    _gender = 'Male';
  }

  void _showStudentForm({Student? student}) {
    if (student != null) {
      _editingId = student.id;
      _nameController.text = student.name;
      _emailController.text = student.email;
      _phoneController.text = student.phone;
      _classController.text = student.className;
      _deptController.text = student.department;
      _gender = student.gender;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_editingId == null ? 'Add Student' : 'Edit Student'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: Validators.validateRequired,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: Validators.validateEmail,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                TextFormField(
                  controller: _classController,
                  decoration: InputDecoration(labelText: 'Class'),
                  validator: Validators.validateRequired,
                ),
                TextFormField(
                  controller: _deptController,
                  decoration: InputDecoration(labelText: 'Department'),
                  validator: Validators.validateRequired,
                ),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: InputDecoration(labelText: 'Gender'),
                  items: ['Male', 'Female']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _gender = val);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _resetForm();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final student = Student(
                  id: _editingId,
                  name: _nameController.text,
                  email: _emailController.text,
                  phone: _phoneController.text,
                  className: _classController.text,
                  department: _deptController.text,
                  gender: _gender,
                  dateRegistered: DateFormat.yMd().format(DateTime.now()),
                  present: false,
                );
                if (_editingId == null) {
                  await _dbHelper.insertStudent(student);
                } else {
                  await _dbHelper.updateStudent(student);
                }
                _resetForm();
                Navigator.pop(context);
                _loadStudents();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dbHelper.deleteStudent(id);
              Navigator.pop(context);
              _loadStudents();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleAttendance(Student student) async {
    final updatedStudent = Student(
      id: student.id,
      name: student.name,
      email: student.email,
      phone: student.phone,
      className: student.className,
      department: student.department,
      gender: student.gender,
      dateRegistered: student.dateRegistered,
      present: !student.present,
    );
    await _dbHelper.updateStudent(updatedStudent);
    _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showStudentForm(),
          )
        ],
      ),
      body: _students.isEmpty
          ? const Center(child: Text('No students found.'))
          : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      student.present ? Icons.check_circle : Icons.cancel,
                      color: student.present ? Colors.green : Colors.red,
                    ),
                    title: Text(student.name),
                    subtitle: Text('${student.className} - ${student.department}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: student.present,
                          onChanged: (_) => _toggleAttendance(student),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showStudentForm(student: student),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDelete(student.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
