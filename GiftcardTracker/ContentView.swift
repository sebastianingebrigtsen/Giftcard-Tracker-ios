import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GiftCard.expiryDate) private var giftCards: [GiftCard]

    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(giftCards) { card in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.storeName)
                            .font(.headline)

                        Text("Beløp: \(Int(card.amount)) kr")
                            .font(.subheadline)

                        Text("Utløper: \(card.expiryDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let card = giftCards[index]
                        NotificationManager.shared.cancelNotifications(for: card)
                        modelContext.delete(card)
                    }
                }
            }
            .navigationTitle("Gavekort")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                // DEBUG-knapp (kan slettes senere)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("DBG") {
                        do {
                            let all = try modelContext.fetch(FetchDescriptor<GiftCard>())
                            print("FETCH COUNT =", all.count)
                            print(all.map { $0.storeName })
                        } catch {
                            print("FETCH ERROR:", error)
                        }
                    }
                }

            }
            .onAppear {
                NotificationManager.shared.requestPermissionIfNeeded()
                print("GiftCards in DB:", giftCards.count)
            }
            .sheet(isPresented: $showingAddSheet) {
                AddGiftCardView()
            }
        }
    }
}

struct AddGiftCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var storeName: String = ""
    @State private var amountText: String = ""
    @State private var expiryDate: Date =
        Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()

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

                        modelContext.insert(card)
                        try? modelContext.save()

                        NotificationManager.shared.scheduleNotifications(for: card)
                        dismiss()
                    }
                    .disabled(
                        storeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        (Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0) <= 0
                    )
                }
            }
        }
    }
}
