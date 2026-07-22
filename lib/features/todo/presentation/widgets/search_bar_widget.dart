import 'package:flutter/material.dart';

/// A Material 3 search bar with a clear button for filtering tasks.
///
/// Fires [onChanged] on every keystroke. The [onClear] callback is invoked
/// when the user taps the clear icon.
class SearchBarWidget extends StatefulWidget {
  /// Creates a search bar widget.
  const SearchBarWidget({
    super.key,
    required this.initialQuery,
    required this.onChanged,
    required this.onClear,
  });

  /// The initial search text to display.
  final String initialQuery;

  /// Called on every keystroke with the current text value.
  final ValueChanged<String> onChanged;

  /// Called when the user clears the search field.
  final VoidCallback onClear;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialQuery != widget.initialQuery &&
        _controller.text != widget.initialQuery) {
      _controller.value = TextEditingValue(
        text: widget.initialQuery,
        selection: TextSelection.collapsed(offset: widget.initialQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search tasks...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? Semantics(
                label: 'Clear search',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear search',
                  onPressed: _clear,
                ),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
        filled: true,
      ),
      onChanged: widget.onChanged,
    );
  }
}
