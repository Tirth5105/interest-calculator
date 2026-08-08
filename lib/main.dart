import 'package:flutter/material.dart';

void main() {
  runApp(const InterestCalculatorApp());
}

class InterestCalculatorApp extends StatelessWidget {
  const InterestCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interest Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _capitalController = TextEditingController(text: '100');
  final _interestController = TextEditingController(text: '20');
  final _daysController = TextEditingController(text: '100');

  List<Map<String, dynamic>> _results = [];
  bool _calculated = false;

  void _calculate() {
    final capital = double.tryParse(_capitalController.text);
    final interest = double.tryParse(_interestController.text);
    final days = int.tryParse(_daysController.text);

    if (capital == null || interest == null || days == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    if (days > 3650) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max days allowed: 3650')),
      );
      return;
    }

    final rate = interest / 100;
    List<Map<String, dynamic>> results = [];
    double current = capital;

    for (int day = 1; day <= days; day++) {
      final previous = current;
      current = current * (1 + rate);
      results.add({
        'day': day,
        'previous': previous,
        'current': current,
      });
    }

    setState(() {
      _results = results;
      _calculated = true;
    });

    FocusScope.of(context).unfocus();
  }

  void _reset() {
    setState(() {
      _results = [];
      _calculated = false;
      _capitalController.text = '100';
      _interestController.text = '20';
      _daysController.text = '100';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: const Text(
          '💰 Interest Calculator',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_calculated)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _reset,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: Column(
        children: [
          // Input Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInputField(
                  controller: _capitalController,
                  label: 'Capital (₹)',
                  icon: Icons.currency_rupee,
                  hint: 'e.g. 100',
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _interestController,
                  label: 'Interest Rate (%)',
                  icon: Icons.percent,
                  hint: 'e.g. 20',
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _daysController,
                  label: 'Number of Days',
                  icon: Icons.calendar_today,
                  hint: 'e.g. 100',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Calculate',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Summary card
          if (_calculated && _results.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem('Capital', '₹${_capitalController.text}'),
                  _summaryItem('Rate', '${_interestController.text}%/day'),
                  _summaryItem(
                    'Final (Day ${_results.length})',
                    '₹${_results.last['current'].toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Results List
          if (_calculated)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final item = _results[index];
                  final day = item['day'] as int;
                  final prev = item['previous'] as double;
                  final curr = item['current'] as double;
                  final gain = curr - prev;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFA5D6A7),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Day badge
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$day',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Calculation text
                        Expanded(
                          child: Text(
                            '₹${prev.toStringAsFixed(2)} + ${_interestController.text}% = ₹${curr.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        // Gain
                        Text(
                          '+₹${gain.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          if (!_calculated)
            const Expanded(
              child: Center(
                child: Text(
                  'Enter values above and\ntap Calculate',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1B5E20)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2),
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ],
    );
  }

  @override
  void dispose() {
    _capitalController.dispose();
    _interestController.dispose();
    _daysController.dispose();
    super.dispose();
  }
}
