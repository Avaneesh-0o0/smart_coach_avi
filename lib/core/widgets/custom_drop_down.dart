import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/core/widgets/field_label_text_view.dart';

class CustomDropDown<T> extends StatelessWidget {
  final String label;
  final String hintText;
  final dynamic value;
  final List<T> items;
  final ValueChanged<dynamic> onChanged;
  final bool isRequired;
  final String Function(T)? displayText;
  final dynamic Function(T)? getValue;
  final bool showSearch;

  const CustomDropDown({
    super.key,
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.displayText,
    this.getValue,
    this.showSearch = false,
  });

  T? _getSelectedItem() {
    if (getValue == null || value == null) return value as T?;
    try {
      return items.firstWhere(
            (item) => getValue!(item) == value,
      );
    } catch (e) {
      return null;
    }
  }

  String _display(T item) {
    return displayText != null ? displayText!(item) : item.toString();
  }

  void _showSearchDialog(BuildContext context) {
    final filteredItems = List<T>.from(items);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(3.w)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final searchController = TextEditingController();
            List<T> localItems = List<T>.from(filteredItems);
            return Container(
              height: 70.h,
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 1.h),
                  CustomTextField(
                    controller: searchController,
                    hintText: 'Search $label...',
                    prefixIcon: Icons.search,
                    onChanged: (val) {
                      setSheetState(() {
                        localItems = filteredItems
                            .where((item) => _display(item)
                                .toLowerCase()
                                .contains(val.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  SizedBox(height: 1.h),
                  Expanded(
                    child: ListView.separated(
                      itemCount: localItems.length,
                      separatorBuilder: (_, __) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = localItems[index];
                        final isSelected = value != null &&
                            ((getValue != null && getValue!(item) == value) ||
                                item == value);
                        return ListTile(
                          title: Text(_display(item)),
                          trailing: isSelected
                              ? Icon(Icons.check, color: Colors.green)
                              : null,
                          tileColor:
                              isSelected ? Colors.green.withValues(alpha: 0.05) : null,
                          onTap: () {
                            final newValue =
                                getValue != null ? getValue!(item) : item;
                            onChanged(newValue);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final T? selectedItem = _getSelectedItem();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabelTextView(
          labelText: label,
          isRequired: isRequired,
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: showSearch ? () => _showSearchDialog(context) : null,
          child: Container(
            height: 6.2.h,
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 0.4.w),
              borderRadius: BorderRadius.circular(2.5.w),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: selectedItem,
                hint: Text(
                  hintText,
                  style: TextStyle(fontSize: 12.sp),
                  overflow: TextOverflow.ellipsis,
                ),
                isExpanded: true,
                onChanged: showSearch
                    ? null
                    : (item) {
                        if (item != null) {
                          final newValue =
                              getValue != null ? getValue!(item) : item;
                          onChanged(newValue);
                        } else {
                          onChanged(null);
                        }
                      },
                items: items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      displayText != null ? displayText!(item) : item.toString(),
                      style: TextStyle(fontSize: 12.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}