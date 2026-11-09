import Foundation
import CoreBluetooth
import Combine

/// Bluetooth-Verwaltung für Soft Code Pro.
/// Diese Version sucht nach einem OBDLink-Adapter und baut eine BLE-Verbindung auf.
/// Sie liest noch keine Fahrzeugdaten und sendet keine OBD-Befehle.
final class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published private(set) var status = "Bluetooth wird vorbereitet"
    @Published private(set) var adapterGefunden = false
    @Published private(set) var istVerbunden = false

    private var centralManager: CBCentralManager?
    private var obdAdapter: CBPeripheral?
    private var sucheAngefordert = false

    func bluetoothStarten() {
        sucheAngefordert = true
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        } else {
            nachAdapterSuchen()
        }
    }

    func verbindungTrennen() {
        sucheAngefordert = false
        centralManager?.stopScan()
        if let obdAdapter = obdAdapter {
            centralManager?.cancelPeripheralConnection(obdAdapter)
        } else {
            status = "Kein Adapter verbunden"
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            status = "Bluetooth eingeschaltet"
            if sucheAngefordert { nachAdapterSuchen() }
        case .poweredOff:
            status = "Bluetooth ist ausgeschaltet"
            istVerbunden = false
        case .unauthorized:
            status = "Bluetooth-Berechtigung fehlt"
            istVerbunden = false
        case .unsupported:
            status = "Bluetooth LE wird nicht unterstützt"
            istVerbunden = false
        case .resetting:
            status = "Bluetooth wird zurückgesetzt"
            istVerbunden = false
        case .unknown:
            status = "Bluetooth-Status unbekannt"
            istVerbunden = false
        @unknown default:
            status = "Unbekannter Bluetooth-Zustand"
            istVerbunden = false
        }
    }

    private func nachAdapterSuchen() {
        guard let centralManager = centralManager,
              centralManager.state == .poweredOn else { return }

        centralManager.stopScan()
        adapterGefunden = false
        istVerbunden = false
        status = "Suche nach OBDLink CX ..."
        centralManager.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let name = peripheral.name
            ?? (advertisementData[CBAdvertisementDataLocalNameKey] as? String)
            ?? ""

        guard name.localizedCaseInsensitiveContains("OBDLink") else { return }
        guard obdAdapter == nil || !istVerbunden else { return }

        central.stopScan()
        adapterGefunden = true
        obdAdapter = peripheral
        peripheral.delegate = self
        status = "Verbinde mit \(name) ..."
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        istVerbunden = true
        status = "Bluetooth verbunden: \(peripheral.name ?? "OBDLink")"
        // Nur BLE-Verbindung. Für OBD-Kommunikation müssen die passenden
        // GATT-Dienste und Eigenschaften noch ermittelt und implementiert werden.
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        istVerbunden = false
        adapterGefunden = false
        obdAdapter = nil
        status = "Verbindung fehlgeschlagen: \(error?.localizedDescription ?? "Unbekannter Fehler")"
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        istVerbunden = false
        adapterGefunden = false
        obdAdapter = nil
        if let error = error {
            status = "Bluetooth getrennt: \(error.localizedDescription)"
        } else {
            status = "OBDLink CX wurde getrennt"
        }
    }
}
