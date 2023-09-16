import 'package:crud/sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
void main() {
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crud do gordolas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Jooj é muito top'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    List<Map<String, dynamic>> _items = [];

    bool isLoading = true;

    void _getDatas() async {
      final data = await SqlHelper.readAll();

      setState(() {
        _items = data;
        isLoading = false;
      });
    }

    @override
    void initState() {
      super.initState();
      _getDatas();
    }

    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    Future<void> addItem() async {
      await SqlHelper.createItem(
          titleController.text, descriptionController.text);
      _getDatas();
    }

    Future<void> removeItem(int id) async{
      await SqlHelper.delete(id);
      _getDatas();
    }

    Future<void> updateItem(int id) async{
      await SqlHelper.updateItem(id, titleController.text, descriptionController.text);
      _getDatas();
    }

    void _showForm(int? id) async {
      if (id != null) {
        final item = _items.firstWhere((element) => element['id'] == id);
        titleController.text = item['title'];
        descriptionController.text = item['description'];
      }

      showModalBottomSheet(
          context: context,
          elevation: 5,
          isScrollControlled: true,
          builder: (_) => Container(
                padding: EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 120,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(hintText: 'Title'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(hintText: 'Description'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await addItem();
                        }
                        if (id != null){
                          await updateItem(id);
                        }
                        titleController.text = '';
                        descriptionController.text = '';

                        if (!mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: Text(id != null ? "update":'Create New'),
                    )
                  ],
                ),
              ));
    }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('É O GRANDE SAPO'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) => Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(_items[index]['title']),
                    subtitle: Text(_items[index]['description']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_items[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async =>
                            await removeItem(_items[index]['id'])
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }

    
  }

