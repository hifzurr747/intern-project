import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import 'add_edit_task_screen.dart';
import 'counter_screen.dart';
import 'todo_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? email;

  const HomeScreen({super.key, this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  // Filter: 'all' | 'pending' | 'completed'
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // ── Data Methods ──────────────────────────────────────────────────────────

  Future<void> _loadTasks() async {
    final saved = await StorageService.loadTasks();
    // FIX: mounted check after async gap
    if (!mounted) return;
    setState(() {
      _tasks = saved;
      _isLoading = false;
    });
  }

  Future<void> _persist() async {
    await StorageService.saveTasks(_tasks);
  }

  void _toggleComplete(String id) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] =
            _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      }
    });
    _persist();
  }

  void _deleteTask(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    final index = _tasks.indexWhere((t) => t.id == id);
    setState(() => _tasks.removeAt(index));
    _persist();

    // FIX: guard context use with mounted check
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() => _tasks.insert(index, task));
            _persist();
          },
        ),
      ),
    );
  }

  void _deleteCompleted() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Completed'),
        content: const Text('Delete all completed tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _tasks.removeWhere((t) => t.isCompleted));
              _persist();
              Navigator.pop(context);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> _openAddTask() async {
    final newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
    );
    // FIX: mounted check after async Navigator.push
    if (!mounted) return;
    if (newTask != null) {
      setState(() => _tasks.insert(0, newTask));
      _persist();
    }
  }

  Future<void> _openEditTask(Task task) async {
    final updated = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
          builder: (_) => AddEditTaskScreen(existingTask: task)),
    );
    // FIX: mounted check after async Navigator.push
    if (!mounted) return;
    if (updated != null) {
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == updated.id);
        if (index != -1) _tasks[index] = updated;
      });
      _persist();
    }
  }

  // ── Filtered list ─────────────────────────────────────────────────────────

  List<Task> get _filteredTasks {
    switch (_filter) {
      case 'pending':
        return _tasks.where((t) => !t.isCompleted).toList();
      case 'completed':
        return _tasks.where((t) => t.isCompleted).toList();
      default:
        return _tasks;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final total = _tasks.length;
    final completed = _tasks.where((t) => t.isCompleted).length;
    final pending = total - completed;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FF),

      // ── Custom App Bar ────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'TaskFlow',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          if (completed > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear completed',
              onPressed: _deleteCompleted,
            ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Task',
            onPressed: _openAddTask,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Stats Header ────────────────────────────────────────
                _StatsHeader(
                  total: total,
                  completed: completed,
                  pending: pending,
                  progress: progress,
                ),

                // ── Filter Chips ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _TaskFilterChip(
                        label: 'All ($total)',
                        selected: _filter == 'all',
                        onTap: () => setState(() => _filter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _TaskFilterChip(
                        label: 'Pending ($pending)',
                        selected: _filter == 'pending',
                        onTap: () =>
                            setState(() => _filter = 'pending'),
                      ),
                      const SizedBox(width: 8),
                      _TaskFilterChip(
                        label: 'Done ($completed)',
                        selected: _filter == 'completed',
                        onTap: () =>
                            setState(() => _filter = 'completed'),
                      ),
                    ],
                  ),
                ),

                // ── Task List ───────────────────────────────────────────
                Expanded(
                  child: _filteredTasks.isEmpty
                      ? _EmptyState(filter: _filter)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                              16, 4, 16, 100),
                          itemCount: _filteredTasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final task = _filteredTasks[index];
                            return _TaskCard(
                              task: task,
                              onToggle: () =>
                                  _toggleComplete(task.id),
                              onDelete: () => _deleteTask(task.id),
                              onEdit: () => _openEditTask(task),
                            );
                          },
                        ),
                ),
              ],
            ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTask,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Task',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 4,
      ),

      // ── Navigation Drawer ─────────────────────────────────────────────────
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3B37C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0x33FFFFFF),
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'TaskFlow',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  if (widget.email != null)
                    Text(
                      widget.email!,
                      style: const TextStyle(
                          color: Color(0xBFFFFFFF), fontSize: 12),
                    ),
                ],
              ),
            ),

            // ── Task Manager (current) ──────────────────────────────────
            ListTile(
              leading: const Icon(Icons.task_alt_rounded,
                  color: Color(0xFF6C63FF)),
              title: const Text('Task Manager',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              selected: true,
              selectedTileColor: const Color(0x1A6C63FF),
              onTap: () => Navigator.pop(context),
            ),

            const Divider(),

            // ── Counter App ─────────────────────────────────────────────
            ListTile(
              leading:
                  const Icon(Icons.exposure, color: Colors.teal),
              title: const Text('Counter App',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CounterScreen()),
                );
              },
            ),

            // ── To-Do List ──────────────────────────────────────────────
            ListTile(
              leading: const Icon(Icons.checklist_rounded,
                  color: Colors.teal),
              title: const Text('To-Do List',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TodoScreen()),
                );
              },
            ),

            const Divider(),

            // ── Login Screen ────────────────────────────────────────────
            ListTile(
              leading:
                  const Icon(Icons.login, color: Colors.deepPurple),
              title: const Text('Login Screen',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Header ──────────────────────────────────────────────────────────────
class _StatsHeader extends StatelessWidget {
  final int total, completed, pending;
  final double progress;

  const _StatsHeader({
    required this.total,
    required this.completed,
    required this.pending,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF6C63FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatBubble(value: '$total', label: 'Total'),
              _StatBubble(value: '$pending', label: 'Pending'),
              _StatBubble(value: '$completed', label: 'Done'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    // FIX: replaced Colors.white24 with explicit Color
                    backgroundColor: const Color(0x40FFFFFF),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final String value, label;
  const _StatBubble({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        Text(label,
            // FIX: replaced withOpacity with explicit Color
            style: const TextStyle(
                color: Color(0xBFFFFFFF), fontSize: 12)),
      ],
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────
// FIX: renamed from _FilterChip to _TaskFilterChip to avoid any confusion
class _TaskFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TaskFilterChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6C63FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF6C63FF)
                : Colors.grey.shade300,
          ),
          boxShadow: selected
              ? [
                  const BoxShadow(
                    // FIX: replaced withOpacity with Color value
                    color: Color(0x4D6C63FF),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ── Task Card ─────────────────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle, onDelete, onEdit;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline,
            color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // FIX: replaced withOpacity with Color value
            color: isDone
                ? const Color(0x4D6C63FF)
                : Colors.grey.shade200,
          ),
          boxShadow: const [
            BoxShadow(
              // FIX: replaced withOpacity with Color value
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? const Color(0xFF6C63FF)
                    : Colors.transparent,
                border: Border.all(
                  color: isDone
                      ? const Color(0xFF6C63FF)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check,
                      size: 15, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDone ? Colors.grey.shade400 : Colors.black87,
              decoration: isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: Text(
            _formatDate(task.createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    size: 19, color: Colors.grey.shade400),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 19, color: Colors.redAccent),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
          onTap: onToggle,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final messages = {
      'all': ['No tasks yet!', 'Tap "Add Task" to get started'],
      'pending': ['All caught up!', 'No pending tasks'],
      'completed': ['Nothing done yet', 'Complete a task to see it here'],
    };
    final msg = messages[filter]!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt_rounded,
              size: 80, color: Colors.purple.shade100),
          const SizedBox(height: 16),
          Text(msg[0],
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54)),
          const SizedBox(height: 8),
          Text(msg[1],
              style: const TextStyle(
                  color: Colors.black38, fontSize: 14)),
        ],
      ),
    );
  }
}
