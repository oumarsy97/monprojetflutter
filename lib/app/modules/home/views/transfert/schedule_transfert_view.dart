import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/schedule.dart';
import '../../controllers/shedule_transfert.dart';


class PlannedTransferPage extends StatefulWidget {
  const PlannedTransferPage({Key? key}) : super(key: key);

  @override
  _PlannedTransferPageState createState() => _PlannedTransferPageState();
}

class _PlannedTransferPageState extends State<PlannedTransferPage> {
  final TextEditingController _destinataireController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isRecurrent = false;
  String _recurrenceFrequency = 'UNIQUE';
  int _recurrenceInterval = 1;
  DateTime? _recurrenceEndDate;

  final ScheduledTransferController _scheduledTransferController = 
      Get.find<ScheduledTransferController>();

  void _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  void _createScheduledTransfer() {
    if (_validate()) {
      final DateTime executionDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      RecurrencePattern? recurrence;
      if (_isRecurrent) {
        recurrence = RecurrencePattern(
          frequence: _recurrenceFrequency,
          interval: _recurrenceInterval,
          endDate: _recurrenceEndDate,
        );
      }

      final scheduledTransfer = ScheduledTransfer(
        id: const Uuid().v4(),
        destinataire: _destinataireController.text,
        emetteur: '',
        montant: double.parse(_montantController.text),
        frais: _calculateFees(double.parse(_montantController.text)),
        dateExecution: executionDateTime,
        type: _isRecurrent ? 'RECURRENT' : 'UNIQUE',
        recurrence: recurrence,
      );

      _scheduledTransferController.addScheduledTransfer(scheduledTransfer);

      Get.back();
      Get.snackbar(
        'Succès',
        'Transfert planifié créé avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  double _calculateFees(double amount) {
    return amount <= 500 ? 5 : (amount * 0.01).clamp(0, 5000);
  }

  bool _validate() {
    if (_destinataireController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez saisir un destinataire');
      return false;
    }
    if (_montantController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez saisir un montant');
      return false;
    }
    if (_selectedDate == null || _selectedTime == null) {
      Get.snackbar('Erreur', 'Veuillez sélectionner une date et une heure');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert Planifié'),
        backgroundColor: const Color(0xFF6C38CC),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _destinataireController,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone du destinataire',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _montantController,
              decoration: const InputDecoration(
                labelText: 'Montant',
                suffixText: 'FCFA',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectDateTime,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C38CC),
              ),
              child: Text(_selectedDate == null || _selectedTime == null
                  ? 'Sélectionner Date et Heure'
                  : 'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute))}'),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Transfert récurrent'),
              value: _isRecurrent,
              onChanged: (bool value) {
                setState(() {
                  _isRecurrent = value;
                });
              },
            ),
            if (_isRecurrent) ...[
              DropdownButton<String>(
                value: _recurrenceFrequency,
                items: ['DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY']
                    .map((freq) => DropdownMenuItem(
                          value: freq,
                          child: Text(freq),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _recurrenceFrequency = value!;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Interval de récurrence',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _recurrenceInterval = int.tryParse(value) ?? 1;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _recurrenceEndDate = pickedDate;
                    });
                  }
                },
                child: Text(_recurrenceEndDate == null
                    ? 'Sélectionner date de fin de récurrence'
                    : 'Date de fin: ${DateFormat('dd/MM/yyyy').format(_recurrenceEndDate!)}'),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createScheduledTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C38CC),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Créer Transfert Planifié'),
            ),
          ],
        ),
      ),
    );
  }
}