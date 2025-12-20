import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GiftCard.expiryDate) private var giftCards: [GiftCard]

    @State private var showingAddSheet = false

    // On-screen debug
    @State private var fetchCountText: String = "Fetch: (trykk Fetch now)"
    @State private var lastSaveError: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // DEBUG PANEL (på skjermen)
                VStack(alignment: .leading, spacing: 8) {
                    Text("DEBUG ✅ \(Date().formatted(date: .omitted, time: .standard))")
                        .font(.headline)
                    Text("Query count: \(giftCards.count)")
                    Text(fetchCountText).font(.caption).foregroundStyle(.secondary)
                    if let lastSaveError {
                        Text("Save error: \(lastSaveError)")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    HStack {
                        Button("Fetch now") {
                            fetchCountText = "Fetching… \(Date().formatted(date: .omitted, time: .standard))"

                            do {
                                let all = try modelContext.fetch(FetchDescriptor<GiftCard>())
                                fetchCountText = "Fetch count: \(all.count) | Names: \(all.map { $0.storeName }.joined(separator: ", "))"
                            } catch {
                                fetchCountText = "Fetch error: \(error.localizedDescription)"
                            }
                        }


                        Button("Insert test") {
                            let test = GiftCard(storeName: "TEST", amount: 123, expiryDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date())
                            modelContext.insert(test)
                            do {
                                try modelContext.save()
                                lastSaveError = nil
                            } catch {
                                lastSaveError = error.localizedDescription
                            }
                        }

                        Button("Erase all") {
                            do {
                                let all = try modelContext.fetch(FetchDescriptor<GiftCard>())
                                for c in all { modelContext.delete(c) }
                                try modelContext.save()
                                lastSaveError = nil
                                fetchCountText = "Erased. Trykk Fetch now."
                            } catch {
                                lastSaveError = error.localizedDescription
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(.thinMaterial)

                List {
                    ForEach(giftCards) { card in
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
                        for index in indexSet {
                            modelContext.delete(giftCards[index])
                        }
                        do { try modelContext.save() } catch { lastSaveError = error.localizedDescription }
                    }
                }
            }
            .navigationTitle("Gavekort")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddSheet = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddGiftCardView(onSaveError: { err in
                    lastSaveError = err
                })
            }
        }
    }
}

struct AddGiftCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var storeName: String = ""
    @State private var amountText: String = ""
    @State private var expiryDate: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()

    let onSaveError: (String) -> Void

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
                        let name = storeName.trimmingCharacters(in: .whitespacesAndNewlines)

                        let card = GiftCard(storeName: name, amount: amount, expiryDate: expiryDate)
                        modelContext.insert(card)

                        do {
                            try modelContext.save()
                            dismiss()
                        } catch {
                            onSaveError(error.localizedDescription)
                        }
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
