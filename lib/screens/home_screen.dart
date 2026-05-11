import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/expenses_db.dart';
import '../services/preferences_service.dart';
import '../models/expense.dart';
import 'add_edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Expense> _expenses = [];
  double _monthlyTotal = 0.0;
  String _currency = 'ETB';
  final _prefs = PreferencesService();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _loadCurrency();
    _refresh();
  }

  Future<void> _loadCurrency() async {
    final curr = await _prefs.getCurrency();
    setState(() => _currency = curr);
  }

  Future<void> _refresh() async {
    final expenses = await ExpensesDb.instance.getAll();
    final now = DateTime.now();
    final total = await ExpensesDb.instance.getTotalByMonth(now.year, now.month);
    setState(() {
      _expenses = expenses;
      _monthlyTotal = total;
    });
    _animationController.forward(from: 0);
  }

  Future<void> _deleteWithUndo(Expense expense) async {
    HapticFeedback.lightImpact();
    await ExpensesDb.instance.delete(expense.id!);
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: ${expense.note}'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () async {
            await ExpensesDb.instance.insert(expense);
            _refresh();
            HapticFeedback.heavyImpact();
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyMoney'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings').then((_) => _refresh()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            _buildMonthTotalCard(),
            _buildMonthlyChart(),
            Expanded(
              child: _expenses.isEmpty
                  ? _buildEmptyState()
                  : AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _animationController,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(_animationController),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              itemCount: _expenses.length,
                              itemBuilder: (context, index) {
                                final e = _expenses[index];
                                return Dismissible(
                                  key: ValueKey(e.id),
                                  background: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade400,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) => _deleteWithUndo(e),
                                  child: Hero(
                                    tag: 'expense_${e.id}',
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        leading: CircleAvatar(
                                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                          child: Text(
                                            e.category[0].toUpperCase(),
                                            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        title: Text(e.note, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        subtitle: Text('${e.category} • ${_formatDate(e.date)}'),
                                        trailing: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$_currency ${e.amount.toStringAsFixed(2)}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        onTap: () async {
                                          HapticFeedback.selectionClick();
                                          final refreshed = await Navigator.pushNamed(context, '/addEditExpense', arguments: e);
                                          if (refreshed == true) _refresh();
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          final refreshed = await Navigator.pushNamed(context, '/addEditExpense');
          if (refreshed == true) _refresh();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        elevation: 4,
      ),
    );
  }
  Widget _buildMonthTotalCard() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: _monthlyTotal),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total this month', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('All expenses', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Text(
                '$_currency ${value.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyChart() {
    return FutureBuilder<List<double>>(
      future: _getLast6MonthsTotals(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 100);
        final totals = snapshot.data!;
        final maxTotal = totals.reduce((a, b) => a > b ? a : b);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Last 6 months', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(6, (index) {
                  final total = totals[index];
                  final height = maxTotal == 0 ? 0 : (total / maxTotal) * 60;
                  return Column(
                    children: [
                      Text('$_currency ${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10)),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: height.clamp(4.0, 60.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(_getMonthName(index), style: const TextStyle(fontSize: 10)),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<double>> _getLast6MonthsTotals() async {
    final now = DateTime.now();
    List<double> totals = [];
    for (int i = 5; i >= 0; i--) {
      DateTime date = DateTime(now.year, now.month - i, 1);
      double total = await ExpensesDb.instance.getTotalByMonth(date.year, date.month);
      totals.add(total);
    }
    return totals;
  }
  String _getMonthName(int offsetFromNow) {
    final date = DateTime(DateTime.now().year, DateTime.now().month - (5 - offsetFromNow), 1);
    return '${date.month}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No expenses yet', style: TextStyle(fontSize: 20, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Tap + to add your first expense', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}