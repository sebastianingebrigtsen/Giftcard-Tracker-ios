import SwiftUI

struct GiftCard: Identifiable {
    let id = UUID()
    var storeName: String
    var amount: Double
    var expiryDate: Date
}

struct ContentView: View {
    @State private var giftCards: [GiftCard] = [
        GiftCard(storeName: "IKEA", amount: 500, expiryDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!),
        GiftCard(storeName: "Elkjøp", amount: 250, expiryDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!)
    ]

    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(giftCards.sorted { $0.expiryDate < $1.expiryDate }) { card in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.storeName).font(.headline)
                        Text("Beløp: \(Int(card.amount)) kr").font(.subheadline)
                        Text("Utløper: \(card.expiryDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    giftCards.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Gavekort")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddGiftCardView { newCard in
                    giftCards.append(newCard)
                }
            }
        }
    }
}

struct AddGiftCardView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var storeName: String = ""
    @State private var amountText: String = ""
    @State private var expiryDate: Date = Date()

    let onSave: (GiftCard) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Butikk") {
                    TextField("F.eks. IKEA", text: $storeName)
                        .textInputAutocapitalization(.words)
                }

                Section("Beløp") {
                    TextField("F.eks. 500", text: $amountText)
                        .keyboardType(.decimalPad)
                }

                Section("Utløpsdato") {
                    DatePicker("Dato", selection: $expiryDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Legg til")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lagre") {
                        let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
                        let card = GiftCard(
                            storeName: storeName.trimmingCharacters(in: .whitespacesAndNewlines),
                            amount: amount,
                            expiryDate: expiryDate
                        )
                        onSave(card)
                        dismiss()
                    }
                    .disabled(storeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
