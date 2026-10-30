import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_due.dart';
import 'admin_payment_stats_screen.dart'; // Created below

class AdminPaymentsDashboard extends StatelessWidget {
  const AdminPaymentsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payments Panel Management"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00674F),
        onPressed: () => _showCreatePaymentDialog(context),
        icon: const Icon(CupertinoIcons.add, color: Colors.white),
        label: const Text("New Contribution",
            style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payment_dues')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
                child: Text(
                    "No contributions created yet. Tap '+' to create one."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final due = PaymentDue.fromMap(
                  docs[index].data() as Map<String, dynamic>, docs[index].id);

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('payments_transactions')
                    .where('paymentDueId', isEqualTo: due.id)
                    .snapshots(),
                builder: (context, txSnapshot) {
                  double totalCollected = 0.0;
                  if (txSnapshot.hasData) {
                    for (var doc in txSnapshot.data!.docs) {
                      totalCollected += (doc['amountPaid'] as num).toDouble();
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(due.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                            "Collected: MWK ${totalCollected.toStringAsFixed(0)} / Target Per Member: MWK ${due.amount.toStringAsFixed(0)}"),
                      ),
                      trailing: const Icon(CupertinoIcons.graph_square_fill,
                          color: Color(0xFF00674F)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AdminPaymentStatsScreen(
                                  paymentDue: due,
                                  totalCollected: totalCollected)),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showCreatePaymentDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Create New Required Payment",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    labelText: "Payment Title (e.g., Choir Uniforms)"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration:
                    const InputDecoration(labelText: "Description / Purpose"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Required Amount per Member (MWK)"),
                validator: (v) => double.tryParse(v ?? '') == null
                    ? "Enter a valid amount"
                    : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00674F),
                      foregroundColor: Colors.white),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    await FirebaseFirestore.instance
                        .collection('payment_dues')
                        .add({
                      'title': titleCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                      'amount': double.parse(amountCtrl.text.trim()),
                      'createdAt': Timestamp.now(),
                      'dueDate': Timestamp.fromDate(
                          DateTime.now().add(const Duration(days: 30))),
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Publish Required Payment"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
