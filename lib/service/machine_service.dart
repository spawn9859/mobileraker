import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobileraker/domain/printer_setting.dart';
import 'package:rxdart/rxdart.dart';

class MachineService {
  late final _boxPrinterSettings = Hive.box<PrinterSetting>('printers');
  late final _boxUuid = Hive.box<String>('uuidbox');

  late final BehaviorSubject<PrinterSetting?> selectedMachine;

  MachineService() {
    String? selectedUUID = _boxUuid.get('selectedPrinter');
    var fromBox = _boxPrinterSettings.get(selectedUUID);
    if (selectedUUID != null && fromBox != null) {
      selectedMachine = BehaviorSubject<PrinterSetting?>.seeded(fromBox);
    } else
      selectedMachine = BehaviorSubject<PrinterSetting?>();
  }

  Future<PrinterSetting> addMachine(PrinterSetting printerSetting) async {
    await _boxPrinterSettings.put(printerSetting.uuid, printerSetting);
    await setMachineActive(printerSetting);
    return printerSetting;
  }

  Future<void> removeMachine(PrinterSetting printerSetting) async {
    await printerSetting.delete();
    if (_boxUuid.get('selectedPrinter') == printerSetting.uuid) {
      var key = (_boxPrinterSettings.isEmpty)
          ? null
          : _boxPrinterSettings.values.first;

      await setMachineActive(key);
    }
  }

  Iterable<PrinterSetting> fetchAll() {
    return _boxPrinterSettings.values;
  }

  setMachineActive(PrinterSetting? printerSetting) async {
    if (printerSetting == selectedMachine.valueOrNull) return;
    // This case will be called when no printer is left! -> Select no printer as active printer
    if (printerSetting == null) {
      await _boxUuid.delete('selectedPrinter');
      selectedMachine.add(null);
      return;
    }

    await _boxUuid.put('selectedPrinter', printerSetting.key);
    selectedMachine.add(printerSetting);
  }

  bool machineAvailable() {
    return selectedMachine.valueOrNull != null;
  }

  bool isSelectedMachine(PrinterSetting toCheck) =>
      toCheck == selectedMachine.valueOrNull;

  dispose() {
    selectedMachine.close();
  }
}
