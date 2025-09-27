//
//  OilView.swift
//  FuelCalc
//
//  Created by Максим Гайдук on 26.09.2025.
//

import SwiftUI

struct OilView: View {
    @State private var cg = ""
    @State private var hg = ""
    @State private var og = ""
    @State private var sg = ""
    @State private var qdaf = ""
    @State private var wr = ""
    @State private var ad = ""
    @State private var v = ""

    @State private var showSheet = false
    @State private var oilResults: OilResults?
    @State private var showInvalidAlert = false
    @State private var alertMessage = "Данні введено некоректно"

    private enum Field: Hashable { case cg, hg, og, sg, qdaf, wr, ad, v }
    @FocusState private var focusedField: Field?
    @State private var editedFields = Set<Field>()
    @State private var lastFocused: Field?

    // MARK: - Helpers
    private func toDouble(_ s: String) -> Double? {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        return Double(t)
    }
    private func isNumber(_ s: String) -> Bool {
        guard !s.isEmpty else { return false }
        return toDouble(s) != nil
    }
    private func inPercentRange(_ s: String) -> Bool {
        guard let x = toDouble(s) else { return false }
        return x >= 0 && x <= 100
    }
    private func nonNegative(_ s: String) -> Bool {
        guard let x = toDouble(s) else { return false }
        return x >= 0
    }
    private func color(for field: Field, isValid: Bool) -> Color {
        editedFields.contains(field) && !isValid ? .red : .primary
    }

    // MARK: - Per-field validity
    private var cgValid: Bool { isNumber(cg) && inPercentRange(cg) }
    private var hgValid: Bool { isNumber(hg) && inPercentRange(hg) }
    private var ogValid: Bool { isNumber(og) && inPercentRange(og) }
    private var sgValid: Bool { isNumber(sg) && inPercentRange(sg) }
    private var qdValid: Bool { isNumber(qdaf) && nonNegative(qdaf) }  // МДж/кг ≥ 0
    private var wrValid: Bool { isNumber(wr) && inPercentRange(wr) }
    private var adValid: Bool { isNumber(ad) && inPercentRange(ad) }
    private var vValid:  Bool { isNumber(v)  && nonNegative(v) }       // мг/кг ≥ 0

    private let sumTolerance: Double = 0.5
    private var fieldsValid: Bool { cgValid && hgValid && ogValid && sgValid && qdValid && wrValid && adValid && vValid }

    // daf сума має бути 100±tol
    private var dafSum: Double {
        (toDouble(cg) ?? .nan) +
        (toDouble(hg) ?? .nan) +
        (toDouble(og) ?? .nan) +
        (toDouble(sg) ?? .nan)
    }
    private var dafSumValid: Bool {
        guard dafSum.isFinite else { return false }
        return abs(dafSum - 100.0) <= sumTolerance
    }
    private var allValid: Bool { fieldsValid && dafSumValid }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Склад горючої маси, %")
                        .font(.title2).bold()

                    TextField("Cg", text: $cg)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.cg); focusedField = nil }
                        .focused($focusedField, equals: .cg)
                        .foregroundColor(color(for: .cg, isValid: cgValid))

                    TextField("Hg", text: $hg)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.hg); focusedField = nil }
                        .focused($focusedField, equals: .hg)
                        .foregroundColor(color(for: .hg, isValid: hgValid))

                    TextField("Og", text: $og)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.og); focusedField = nil }
                        .focused($focusedField, equals: .og)
                        .foregroundColor(color(for: .og, isValid: ogValid))

                    TextField("Sg", text: $sg)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.sg); focusedField = nil }
                        .focused($focusedField, equals: .sg)
                        .foregroundColor(color(for: .sg, isValid: sgValid))
                }

                Section {
                    Text("Параметри")
                        .font(.title2).bold()

                    TextField("Qdaf (МДж/кг)", text: $qdaf)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.qdaf); focusedField = nil }
                        .focused($focusedField, equals: .qdaf)
                        .foregroundColor(color(for: .qdaf, isValid: qdValid))

                    TextField("Wr (волога, %)", text: $wr)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.wr); focusedField = nil }
                        .focused($focusedField, equals: .wr)
                        .foregroundColor(color(for: .wr, isValid: wrValid))

                    TextField("Ad (зола, %)", text: $ad)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.ad); focusedField = nil }
                        .focused($focusedField, equals: .ad)
                        .foregroundColor(color(for: .ad, isValid: adValid))

                    TextField("V (мг/кг)", text: $v)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.v); focusedField = nil }
                        .focused($focusedField, equals: .v)
                        .foregroundColor(color(for: .v, isValid: vValid))
                }

                HStack {
                    Spacer()
                    Button {
                        focusedField = nil

                        guard fieldsValid else {
                            alertMessage = "Поля % мають бути 0…100. Qdaf та V — числа ≥ 0."
                            showInvalidAlert = true
                            return
                        }
                        guard dafSumValid else {
                            alertMessage = String(format: "Сума Cg+Hg+Og+Sg повинна бути 100±%.1f. Зараз: %.3f", sumTolerance, dafSum)
                            showInvalidAlert = true
                            return
                        }

                        do {
                            let input = OilInput(
                                Cg: toDouble(cg) ?? 0, Hg: toDouble(hg) ?? 0,
                                Og: toDouble(og) ?? 0, Sg: toDouble(sg) ?? 0,
                                QdafProvided: toDouble(qdaf),
                                Wr: toDouble(wr) ?? 0, Ad: toDouble(ad) ?? 0,
                                VmgPerKg: toDouble(v)
                            )
                            oilResults = try Calculator.computeOil(input: input)
                            showSheet = true
                        } catch {
                            alertMessage = "Помилка розрахунку."
                            showInvalidAlert = true
                        }

                    } label: {
                        HStack {
                            Image(systemName: "function")
                            Text("Розрахувати")
                        }
                        .foregroundColor(.blue)
                    }
                    .opacity(allValid ? 1.0 : 0.5)
                    Spacer()
                }
            }
            .onChange(of: focusedField) { newFocus in
                if let last = lastFocused { editedFields.insert(last) }
                lastFocused = newFocus
            }
            .alert("Данні введено некоректно", isPresented: $showInvalidAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showSheet) {   
                if let r = oilResults {
                    ResultSheet(content: .oil(r))
                        .presentationDetents([.large])
                        .presentationContentInteraction(.scrolls)   // ← додай це
                        .presentationDragIndicator(.visible)
                        .presentationBackground(.ultraThinMaterial)
                } else {
                    Text("Немає даних").padding()
                        .presentationDetents([.large])
                        .presentationContentInteraction(.scrolls)   // ← і тут
                        .presentationBackground(.ultraThinMaterial)
                }
            }
        }
    }
}

#Preview { OilView() }
