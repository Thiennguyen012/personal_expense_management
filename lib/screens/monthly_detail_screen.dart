import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../utils/app_utils.dart';
import '../widgets/transaction_card.dart';

class MonthlyDetailScreen extends StatefulWidget {
  final DateTime selectedMonth;

  const MonthlyDetailScreen({
    Key? key,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  State<MonthlyDetailScreen> createState() => _MonthlyDetailScreenState();
}

class _MonthlyDetailScreenState extends State<MonthlyDetailScreen> {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedMonth;
  }

  Future<String> _getCategoryIcon(String categoryName) async {
    final categories = await _categoryRepository.getAllCategories();
    final category =
        categories.firstWhere((c) => c.name == categoryName, orElse: () {
      return Category(name: categoryName, type: 'expense', icon: '💰');
    });
    return category.icon;
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
    DateTime endDate = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy', 'vi_VN').format(_currentMonth)),
        elevation: 2,
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month - 1,
                        );
                      });
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy', 'vi_VN').format(_currentMonth),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Monthly Summary
              FutureBuilder<List<TransactionModel>>(
                future: _transactionRepository.getTransactionsByDateRange(
                  startDate,
                  endDate,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final transactions = snapshot.data ?? [];
                  double income = 0;
                  double expense = 0;

                  for (var tx in transactions) {
                    if (tx.type == 'income') {
                      income += tx.amount;
                    } else {
                      expense += tx.amount;
                    }
                  }

                  return Column(
                    children: [
                      // Income Card
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade700
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Thu Nhập',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_downward,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppUtils.formatCurrency(income),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Expense Card
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade400, Colors.red.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Chi Tiêu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppUtils.formatCurrency(expense),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Balance Card
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade700
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Số Dư',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.wallet,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppUtils.formatCurrency(income - expense),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Transactions List
                      if (transactions.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giao Dịch (${transactions.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                return FutureBuilder<String>(
                                  future: _getCategoryIcon(tx.category),
                                  builder: (context, iconSnapshot) {
                                    final icon = iconSnapshot.data ?? '💰';
                                    return TransactionCard(
                                      title: tx.title,
                                      amount: tx.amount,
                                      category: tx.category,
                                      icon: icon,
                                      date: AppUtils.formatDate(tx.date),
                                      type: tx.type,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Không có giao dịch nào trong tháng này',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
