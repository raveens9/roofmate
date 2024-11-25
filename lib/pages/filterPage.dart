import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  final Map<String, dynamic> initialFilters;

  const FilterPage({Key? key, required this.initialFilters}) : super(key: key);

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late Map<String, dynamic> filters;

  @override
  void initState() {
    super.initState();
    filters = Map<String, dynamic>.from(widget.initialFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filters"),
        backgroundColor: Colors.blue[100],
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, filters); // Pass back the filters
            },
            child: const Text(
              "Apply",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          // Price Range Filter
          ListTile(
            title: const Text("Price Range"),
            trailing: DropdownButton<String>(
              value: filters['priceRange'] ?? "Any",
              items: const [
                DropdownMenuItem(value: "Any", child: Text("Any")),
                DropdownMenuItem(value: "<5000", child: Text("< 5000")),
                DropdownMenuItem(
                    value: "5000-10000", child: Text("5000-10000")),
                DropdownMenuItem(value: ">10000", child: Text("> 10000")),
              ],
              onChanged: (value) {
                setState(() {
                  filters['priceRange'] = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
