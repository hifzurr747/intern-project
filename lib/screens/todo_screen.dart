import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<String> _titles = [];
  List<bool> _dones = [];
  final _controller = TextEditingController();

  static const _key = 'simple_todos';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Save as "done~title" per item
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = List.generate(
      _titles.length,
      (i) => '${_dones[i] ? '1' : '0'}~${_titles[i]}',
    );
    await prefs.setStringList(_key, list);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (!mounted) return;
    setState(() {
      _titles = list.map((e) {
        final idx = e.indexOf('~');
        return idx == -1 ? e : e.substring(idx + 1);
      }).toList();
      _dones = list.map((e) => e.startsWith('1~')).toList();
    });
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _titles.add(text);
      _dones.add(false);
      _controller.clear();
    });
    _save();
  }

  void _toggle(int i) {
    setState(() => _dones[i] = !_dones[i]);
    _save();
  }

  void _delete(int i) {
    final title = _titles[i];
    setState(() {
      _titles.removeAt(i);
      _dones.removeAt(i);
    });
    _save();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$title" deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final done = _dones.where((d) => d).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('$done/${_titles.length} done',
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xB3FFFFFF))),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Input Row ───────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type a task and tap Add...',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.teal, width: 2),
                      ),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _add,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── List ────────────────────────────────────────────────────
          Expanded(
            child: _titles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist_rounded,
                            size: 80, color: Colors.teal.shade100),
                        const SizedBox(height: 16),
                        const Text('No tasks yet!',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54)),
                        const SizedBox(height: 8),
                        const Text('Type above and tap Add',
                            style: TextStyle(color: Colors.black38)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _titles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final isDone = _dones[i];
                      return Dismissible(
                        key: ValueKey('$i\_${_titles[i]}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _delete(i),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white, size: 28),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDone ? Colors.teal.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDone
                                  ? Colors.teal.shade200
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: ListTile(
                            leading: GestureDetector(
                              onTap: () => _toggle(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      isDone ? Colors.teal : Colors.transparent,
                                  border: Border.all(
                                    color: isDone
                                        ? Colors.teal
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isDone
                                    ? const Icon(Icons.check,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                            ),
                            title: Text(
                              _titles[i],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isDone
                                    ? Colors.grey.shade400
                                    : Colors.black87,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent, size: 20),
                              onPressed: () => _delete(i),
                            ),
                            onTap: () => _toggle(i),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
