//
//  ResultSheet.swift
//  FuelCalc
//
//  Created by Максим Гайдук on 26.09.2025.
//

import SwiftUI

enum ResultSheetContent {
    case raw(RawResults)
    case oil(OilResults)
}

struct ResultSheet: View {
    let content: ResultSheetContent
    
    var body: some View {
        // Головне: ScrollView усередині шторки
        ScrollView {
            VStack(spacing: 16) {
                switch content {
                case .raw(let r):
                    Text("Результати (робоча маса)")
                        .font(.title3).bold()
                    
                    GroupBox("Коефіцієнти") {
                        grid {
                            gridRow("KRS (→ суха)", r.kRS)
                            gridRow("KRG (→ горюча)", r.kRG)
                        }
                    }
                    
                    GroupBox("Суха маса (без W)") {
                        compositionGrid(r.dry)
                    }
                    
                    GroupBox("Горюча маса (без W, A)") {
                        compositionGrid(r.daf)
                    }
                    
                    GroupBox("Нижча теплота згоряння") {
                        grid {
                            gridRow("Qr, МДж/кг", r.Qr)
                            gridRow("Qd, МДж/кг", r.Qd)
                            gridRow("Qdaf, МДж/кг", r.Qdaf)
                        }
                    }
                    
                case .oil(let r):
                    Text("Результати (мазут)")
                        .font(.title3).bold()
                    
                    GroupBox("Склад робочої маси") {
                        compositionGrid(r.work)
                    }
                    
                    GroupBox("Нижча теплота згоряння") {
                        grid {
                            gridRow("Qr (робоча), МДж/кг", r.Qr)
                            gridRow("Qdaf (з daf-складу), МДж/кг", r.QdafFromComp)
                            if let qprov = r.QdafProvided {
                                gridRow("Qdaf (введено), МДж/кг", qprov)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.visible)
        .scrollBounceBehavior(.basedOnSize)
        // решта оформлення задається у .sheet у батьківських вʼю
    }
    
    // MARK: - Helpers
    @ViewBuilder
    private func compositionGrid(_ c: Composition) -> some View {
        grid {
            gridRow("H, %", c.H)
            gridRow("C, %", c.C)
            gridRow("S, %", c.S)
            gridRow("N, %", c.N)
            gridRow("O, %", c.O)
            gridRow("W, %", c.W)
            gridRow("A, %", c.A)
        }
    }
    
    @ViewBuilder
    private func grid<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 6) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func gridRow(_ title: String, _ value: Double) -> some View {
        GridRow {
            Text(title)
            Spacer(minLength: 12)
            Text(format(value))
                .monospacedDigit()
                .frame(alignment: .trailing)
        }
        .padding(.vertical, 2)
    }
    
    private func format(_ x: Double) -> String {
        let f = NumberFormatter()
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 3
        return f.string(from: NSNumber(value: x)) ?? "\(x)"
    }
}

#Preview {
    let raw = RawResults(
        kRS: 1.2, kRG: 1.5,
        dry: Composition(H: 5, C: 70, S: 1, N: 1, O: 20, W: 0, A: 3),
        daf: Composition(H: 5.2, C: 82, S: 1.1, N: 1.2, O: 10.5, W: 0, A: 0),
        Qr: 20.5, Qd: 23.7, Qdaf: 27.4
    )
    return ResultSheet(content: .raw(raw))
}
