import 'package:flutter/material.dart';

void main() {
  runApp(const XSplitterApp());
}

class XSplitterApp extends StatelessWidget {
  const XSplitterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EX-Splitter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplitterHome(),
    );
  }
}

class Person {
  String name;
  double spent;
  double balance; // +ve receive, -ve pay

  Person(this.name, this.spent, this.balance);
}

class SplitterHome extends StatefulWidget {
  const SplitterHome({super.key});

  @override
  State<SplitterHome> createState() => _SplitterHomeState();
}

class _SplitterHomeState extends State<SplitterHome> {
  final TextEditingController countController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  int totalPeople = 0;
  int currentIndex = 1;

  List<String> names = [];
  List<double> amounts = [];
  String result = '';

  void setPeopleCount() {
    if (countController.text.isNotEmpty) {
      setState(() {
        totalPeople = int.parse(countController.text);
      });
    }
  }

  void addPerson() {
    if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
      setState(() {
        names.add(nameController.text);
        amounts.add(double.parse(amountController.text));
        currentIndex++;
        nameController.clear();
        amountController.clear();
      });
    }
  }

  void calculateWhoPaysWhom() {
    double total = amounts.fold(0, (a, b) => a + b);
    double share = total / totalPeople;

    List<Person> people = [];
    for (int i = 0; i < totalPeople; i++) {
      people.add(Person(names[i], amounts[i], amounts[i] - share));
    }

    List<Person> payers = people.where((p) => p.balance < 0).toList();
    List<Person> receivers = people.where((p) => p.balance > 0).toList();

    StringBuffer buffer = StringBuffer();

    int i = 0, j = 0;
    while (i < payers.length && j < receivers.length) {
      double payAmount = -payers[i].balance;
      double receiveAmount = receivers[j].balance;

      double settled = payAmount < receiveAmount ? payAmount : receiveAmount;

      buffer.writeln(
        '${payers[i].name} pays ${receivers[j].name} ₹${settled.toStringAsFixed(2)}',
      );

      payers[i].balance += settled;
      receivers[j].balance -= settled;

      if (payers[i].balance == 0) i++;
      if (receivers[j].balance == 0) j++;
    }

    setState(() {
      result = buffer.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('X-Splitter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (totalPeople == 0) ...[
                TextField(
                  controller: countController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'How many people?',
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: setPeopleCount,
                  child: const Text('Next'),
                ),
              ] else if (currentIndex <= totalPeople) ...[
                Text(
                  'Person $currentIndex details',
                  style: const TextStyle(fontSize: 18),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Person Name'),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount Spent'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addPerson,
                  child: const Text('Add Person'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: calculateWhoPaysWhom,
                  child: const Text('Calculate Split'),
                ),
                const SizedBox(height: 20),
                Text(result, style: const TextStyle(fontSize: 16)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
