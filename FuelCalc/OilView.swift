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

    // Валідація
    @State private var cgValid = true, hgValid = true, ogValid = true, sgValid = true
    @State private var qdafValid = true, wrValid = true, adValid = true, vValid = true
    @State private var showInvalidAlert = false

    private enum Field: Hashable { case cg, hg, og, sg, qdaf, wr, ad, v }
    @FocusState private var focusedField: Field?

    // MARK: - Helpers
    private func isNumeric(_ text: String) -> Bool {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
        return t.isEmpty || Double(t) != nil
    }
    private func parsedOptionalDouble(_ text: String) -> Double? {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
        return Double(t)
    }
    private func parsedDouble(_ text: String) -> Double {
        parsedOptionalDouble(text) ?? 0
    }
    private var allValid: Bool {
        cgValid && hgValid && ogValid && sgValid && qdafValid && wrValid && adValid && vValid &&
        !cg.isEmpty && !hg.isEmpty && !og.isEmpty && !sg.isEmpty && !wr.isEmpty && !ad.isEmpty
        // qdaf та v можемо вважати опційними; якщо хочеш зробити обов'язковими — додай !qdaf.isEmpty && !v.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Склад горючої маси, %")
                        .font(.title2).bold()

                    TextField("Cg", text: $cg)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                        .focused($focusedField, equals: .cg)
                        .onChange(of: cg) { cgValid = isNumeric($0) }
                        .foregroundColor(cgValid ? .primary : .red)

                    TextField("Hg", text: $hg)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                        .focused($focusedField, equals: .hg)
                        .onChange(of: hg) { hgValid = isNumeric($0) }
                        .foregroundColor(hgValid ? .primary : .red)

                    TextField("Og", text: $og)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                        .focused($focusedField, equals: .og)
                        .onChange(of: og) { ogValid = isNumeric($0) }
                        .foregroundColor(ogValid ? .primary : .red)

                    TextField("Sg", text: $sg)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                        .focused($focusedField, equals: .sg)
                        .onChange(of: sg) { sgValid = isNumeric($0) }
                        .foregroundColor(sgValid ? .primary : .red)
                }

                Section {
                    Text("Параметри")
                        .font(.title2).bold()

                    TextField("Qdaf (МДж/кг)", text: $qdaf)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                        .focused($focusedField, equals: .qdaf)
                        .onChange(of: qdaf) { qdafValid = isNumeric($0) }
                        .foregroundColor(qdafValid ? .primary : .red)

                    TextField("Wr (волога, %)", text: $wr)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                        .focused($focusedField, equals: .wr)
                        .onChange(of: wr) { wrValid = isNumeric($0) }
                        .foregroundColor(wrValid ? .primary : .red)

                    TextField("Ad (зола, %)", text: $ad)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                        .focused($focusedField, equals: .ad)
                        .onChange(of: ad) { adValid = isNumeric($0) }
                        .foregroundColor(adValid ? .primary : .red)

                    TextField("V (мг/кг)", text: $v)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                        .focused($focusedField, equals: .v)
                        .onChange(of: v) { vValid = isNumeric($0) }
                        .foregroundColor(vValid ? .primary : .red)
                }

                HStack {
                    Spacer()
                    Button {
                        if !allValid {
                            showInvalidAlert = true
                            return
                        }
                        focusedField = nil
                        let input = OilInput(
                            Cg: parsedDouble(cg), Hg: parsedDouble(hg), Og: parsedDouble(og), Sg: parsedDouble(sg),
                            QdafProvided: parsedOptionalDouble(qdaf),
                            Wr: parsedDouble(wr), Ad: parsedDouble(ad),
                            VmgPerKg: parsedOptionalDouble(v)
                        )
                        do {
                            oilResults = try Calculator.computeOil(input: input)
                            showSheet = true
                        } catch {
                            showInvalidAlert = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "function")
                            Text("Розрахувати")
                        }
                        .foregroundColor(.blue)
                    }
                    .disabled(!allValid)
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        focusedField = nil
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .padding(.trailing, 12)
                    }
                }
            }
            .alert("Дані введено некоректно", isPresented: $showInvalidAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Перевір, щоб обов’язкові поля були числами (можна крапку або кому) і не порожні.")
            }
            .sheet(isPresented: $showSheet) {
                if let r = oilResults {
                    ResultSheet(content: .oil(r))
                } else {
                    Text("Немає даних").padding()
                }
            }
        }
    }
}

#Preview { OilView() }
