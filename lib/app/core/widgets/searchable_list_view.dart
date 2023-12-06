import 'package:flutter/material.dart';
import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

class SearchableListView extends StatefulWidget {
  const SearchableListView({
    super.key,
    required this.items,
    required this.onSearch,
    required this.onSelectedItem,
  });

  final List<BaseModel> items;
  final Function(String) onSearch;
  final Function(BaseModel) onSelectedItem;

  @override
  State<SearchableListView> createState() => _SearchableListViewState();
}

class _SearchableListViewState extends State<SearchableListView> {
  final TextEditingController searchController = TextEditingController();
  List<BaseModel> filteredItems = [];

  @override
  void initState() {
    super.initState();

    filteredItems = widget.items;
    searchController.addListener(() {
      final searchTerm = searchController.text.toLowerCase();
      widget.onSearch(searchTerm);

      setState(() {
        filteredItems = widget.items.where((item) {
          final itemName = item.name!.toLowerCase();
          return itemName.contains(searchTerm);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(filteredItems[index].name!.capitalize()),
                onTap: () {
                  widget.onSelectedItem(filteredItems[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
