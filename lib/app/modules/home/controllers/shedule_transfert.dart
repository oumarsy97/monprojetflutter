import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

import '../../../data/models/schedule.dart';
import 'auth_controller.dart';


class ScheduledTransferController extends GetxController {
  final RxList<ScheduledTransfer> scheduledTransfers = <ScheduledTransfer>[].obs;
  final AuthController authController = Get.find<AuthController>();

  void addScheduledTransfer(ScheduledTransfer transfer) {
    scheduledTransfers.add(transfer);
    _scheduleTransferExecution(transfer);
  }

  void _scheduleTransferExecution(ScheduledTransfer transfer) {
    Workmanager().registerOneOffTask(
      transfer.id,
      'executeScheduledTransfer',
      inputData: {
        'transferId': transfer.id,
        'destinataire': transfer.destinataire,
        'montant': transfer.montant,
        'frais': transfer.frais,
        'emetteur': transfer.emetteur,
        
      },
      initialDelay: transfer.dateExecution.difference(DateTime.now()),
    );
  }

  Future<void> executeScheduledTransfer(String transferId) async {
     ScheduledTransfer transfer = scheduledTransfers.firstWhere((t) => t.id == transferId);
    
    try {
      final transaction = {
        'montant': transfer.montant,
        'frais': transfer.frais,
        'total': transfer.montant + transfer.frais,
        'destinataire': transfer.destinataire,
        'emetteur': authController.userPhone,
        'date': DateTime.now(),
        'type': 'TRANSFERT_PLANIFIE',
        'status': 'EFFECTUE'
      };

      await authController.addTransaction(transaction);
      
      // Marquer comme exécuté
      transfer.statut = 'EXECUTED';
      
      // Si récurrent, programmer le prochain
      if (transfer.type == 'RECURRENT' && transfer.recurrence != null) {
        _handleRecurrentTransfer(transfer);
      }
    } catch (e) {
      transfer.statut = 'FAILED';
      Get.snackbar('Erreur', 'Transfert planifié échoué: $e');
    }
  }

  void _handleRecurrentTransfer(ScheduledTransfer originalTransfer) {
    DateTime nextExecutionDate;
    
    switch (originalTransfer.recurrence!.frequence) {
      case 'DAILY':
        nextExecutionDate = originalTransfer.dateExecution.add(Duration(days: originalTransfer.recurrence!.interval!));
        break;
      case 'WEEKLY':
        nextExecutionDate = originalTransfer.dateExecution.add(Duration(days: 7 * originalTransfer.recurrence!.interval!));
        break;
      case 'MONTHLY':
        nextExecutionDate = DateTime(
          originalTransfer.dateExecution.year, 
          originalTransfer.dateExecution.month + originalTransfer.recurrence!.interval!, 
          originalTransfer.dateExecution.day
        );
        break;
      case 'YEARLY':
        nextExecutionDate = DateTime(
          originalTransfer.dateExecution.year + originalTransfer.recurrence!.interval!, 
          originalTransfer.dateExecution.month, 
          originalTransfer.dateExecution.day
        );
        break;
      default:
        return;
    }

    // Vérifier si la nouvelle date est avant la date de fin de récurrence
    if (originalTransfer.recurrence!.endDate == null || 
        nextExecutionDate.isBefore(originalTransfer.recurrence!.endDate!)) {
      final newTransfer = ScheduledTransfer(
        id: const Uuid().v4(),
        destinataire: originalTransfer.destinataire,
        montant: originalTransfer.montant,
        emetteur: originalTransfer.emetteur,
        frais: originalTransfer.frais,
        dateExecution: nextExecutionDate,
        type: 'RECURRENT',
        recurrence: originalTransfer.recurrence,
      );

      addScheduledTransfer(newTransfer);
    }
  }
}

// Configuration initiale du Workmanager
void initializeWorkmanager() {
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == 'executeScheduledTransfer') {
      final controller = Get.find<ScheduledTransferController>();
      await controller.executeScheduledTransfer(inputData?['transferId']);
      return Future.value(true);
    }
    return Future.value(false);
  });
}