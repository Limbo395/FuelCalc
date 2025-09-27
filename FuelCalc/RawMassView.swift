//
//  RawMassView.swift
//  FuelCalc
//
//  Created by Максим Гайдук on 26.09.2025.
//

import SwiftUI

struct RawMassView: View {
    @State private var h = ""
    @State private var c = ""
    @State private var s = ""
    @State private var n = ""
    @State private var o = ""
    @State private var w = ""
    @State private var a = ""

    @State private var showSheet = false
    @State private var rawResults: RawResults?
    @State private var showInvalidAlert = false
    @State private var alertMessage = "Данні введено некоректно"

    private enum Field: Hashable { case h, c, s, n, o, w, a }
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
    private func color(for field: Field, isValid: Bool) -> Color {
        editedFields.contains(field) && !isValid ? .red : .primary
    }

    // MARK: - Per-field validity (numbers + 0…100%)
    private var hValid: Bool { isNumber(h) && inPercentRange(h) }
    private var cValid: Bool { isNumber(c) && inPercentRange(c) }
    private var sValid: Bool { isNumber(s) && inPercentRange(s) }
    private var nValid: Bool { isNumber(n) && inPercentRange(n) }
    private var oValid: Bool { isNumber(o) && inPercentRange(o) }
    private var wValid: Bool { isNumber(w) && inPercentRange(w) }
    private var aValid: Bool { isNumber(a) && inPercentRange(a) }

    private let sumTolerance: Double = 0.5
    private var fieldsValid: Bool { hValid && cValid && sValid && nValid && oValid && wValid && aValid }

    private var rawSum: Double {
        (toDouble(h) ?? .nan) +
        (toDouble(c) ?? .nan) +
        (toDouble(s) ?? .nan) +
        (toDouble(n) ?? .nan) +
        (toDouble(o) ?? .nan) +
        (toDouble(w) ?? .nan) +
        (toDouble(a) ?? .nan)
    }
    private var rawSumValid: Bool {
        guard rawSum.isFinite else { return false }
        return abs(rawSum - 100.0) <= sumTolerance
    }
    private var allValid: Bool { fieldsValid && rawSumValid }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Основні елементи, %")
                        .font(.title2).bold()

                    TextField("H", text: $h)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.h); focusedField = nil }
                        .focused($focusedField, equals: .h)
                        .foregroundColor(color(for: .h, isValid: hValid))

                    TextField("C", text: $c)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.c); focusedField = nil }
                        .focused($focusedField, equals: .c)
                        .foregroundColor(color(for: .c, isValid: cValid))

                    TextField("S", text: $s)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.s); focusedField = nil }
                        .focused($focusedField, equals: .s)
                        .foregroundColor(color(for: .s, isValid: sValid))

                    TextField("N", text: $n)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.n); focusedField = nil }
                        .focused($focusedField, equals: .n)
                        .foregroundColor(color(for: .n, isValid: nValid))

                    TextField("O", text: $o)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.o); focusedField = nil }
                        .focused($focusedField, equals: .o)
                        .foregroundColor(color(for: .o, isValid: oValid))
                }

                Section {
                    Text("Волога та зола, %")
                        .font(.title2).bold()

                    TextField("W (волога)", text: $w)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.w); focusedField = nil }
                        .focused($focusedField, equals: .w)
                        .foregroundColor(color(for: .w, isValid: wValid))

                    TextField("A (зола)", text: $a)
                        .keyboardType(.numbersAndPunctuation)
                        .submitLabel(.done)
                        .onSubmit { editedFields.insert(.a); focusedField = nil }
                        .focused($focusedField, equals: .a)
                        .foregroundColor(color(for: .a, isValid: aValid))
                }

                Section {
                    HStack {
                        Spacer()
                        Button {
                            focusedField = nil

                            guard fieldsValid else {
                                alertMessage = "Усі поля мають бути числами в діапазоні 0…100."
                                showInvalidAlert = true
                                return
                            }
                            guard rawSumValid else {
                                alertMessage = String(format: "Сума %% повинна дорівнювати 100±%.1f. Зараз: %.3f", sumTolerance, rawSum)
                                showInvalidAlert = true
                                return
                            }

                            do {
                                let input = RawInput(
                                    H: toDouble(h) ?? 0,
                                    C: toDouble(c) ?? 0,
                                    S: toDouble(s) ?? 0,
                                    N: toDouble(n) ?? 0,
                                    O: toDouble(o) ?? 0,
                                    W: toDouble(w) ?? 0,
                                    A: toDouble(a) ?? 0
                                )
                                rawResults = try Calculator.computeRaw(input: input)
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
            }
            .scrollDisabled(true)
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
                if let r = rawResults {
                    ResultSheet(content: .raw(r))
                        .presentationDetents([.large])              // одразу на весь екран
                        .presentationDragIndicator(.visible)
                        .presentationBackground(.ultraThinMaterial)
                } else {
                    Text("Немає даних").padding()
                        .presentationDetents([.large])
                        .presentationBackground(.ultraThinMaterial)
                }
            }
        }
    }
}

#Preview { RawMassView() }
