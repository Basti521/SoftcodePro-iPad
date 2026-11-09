import SwiftUI

// Soft Code Pro – iPad-Prototyp
// Bluetooth-Verbindung zum Adapter, noch KEINE Fahrzeugdiagnose.
@main
struct SoftCodeProApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var bluetooth = BluetoothManager()

    private let background = Color(red: 0.075, green: 0.085, blue: 0.105)
    private let card = Color(red: 0.13, green: 0.15, blue: 0.18)
    private let accent = Color(red: 0.93, green: 0.19, blue: 0.24)

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    vehicleCard
                    bluetoothCard
                    safetyCard
                    diagnosticsCard
                }
                .padding(24)
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SOFT CODE PRO")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(accent)
            Text("Fahrzeugdiagnose · iPad-Testversion")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Bluetooth-Test · Noch keine Verbindung zum Fahrzeugsteuergerät")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var vehicleCard: some View {
        panel(title: "Fahrzeug", symbol: "car.fill") {
            Text("BMW X1 E84 · 2010")
                .font(.title3.bold())
            Text("Testfahrzeug · Angaben manuell hinterlegt")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var bluetoothCard: some View {
        panel(title: "OBDLink CX · Bluetooth", symbol: "antenna.radiowaves.left.and.right") {
            HStack(spacing: 10) {
                Circle()
                    .fill(bluetooth.istVerbunden ? accent : .orange)
                    .frame(width: 11, height: 11)
                Text(bluetooth.status)
                    .font(.body.weight(.medium))
                    .accessibilityLabel("Bluetooth-Status: \(bluetooth.status)")
            }

            if bluetooth.istVerbunden {
                Text("BLE-Verbindung hergestellt. Fahrzeugdaten werden noch nicht ausgelesen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button {
                    bluetooth.bluetoothStarten()
                } label: {
                    Label("Adapter suchen", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(accent)
                .foregroundStyle(.black)

                Button("Trennen") {
                    bluetooth.verbindungTrennen()
                }
                .buttonStyle(.bordered)
                .disabled(!bluetooth.istVerbunden)
            }
            .controlSize(.large)
        }
    }

    private var safetyCard: some View {
        panel(title: "Sicherheit", symbol: "lock.shield.fill") {
            Label("Schreibschutz aktiv", systemImage: "checkmark.shield.fill")
                .foregroundStyle(accent)
            Text("Diese Testversion sendet keine Codier-, Lösch- oder Flash-Befehle.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var diagnosticsCard: some View {
        panel(title: "Diagnose und Live-Daten", symbol: "waveform.path.ecg") {
            Text("Noch keine echten Messwerte")
                .font(.headline)
            Text("Als nächstes müssen die BLE-GATT-Kommunikation mit dem OBDLink CX und die OBD-II-Abfragen implementiert und am Fahrzeug getestet werden.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                Label("Fehlercodes", systemImage: "exclamationmark.triangle")
                Spacer()
                Text("Nicht verfügbar")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Label("Motordrehzahl", systemImage: "gauge.with.dots.needle.67percent")
                Spacer()
                Text("Nicht verfügbar")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func panel<Content: View>(
        title: String,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundStyle(accent)
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card, in: RoundedRectangle(cornerRadius: 18))
    }
}
