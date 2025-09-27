//
//  Calculator.swift
//  FuelCalc
//
//  Created by Максим Гайдук on 26.09.2025.
//

import Foundation

// MARK: - Моделі

public struct RawInput {
    public let H, C, S, N, O, W, A: Double // у відсотках
}

public struct Composition {
    public let H, C, S, N, O, W, A: Double // у відсотках (сума≈100 для відповідної бази)
}

public struct RawResults {
    public let kRS: Double        // 100/(100-W)
    public let kRG: Double        // 100/(100-W-A)
    public let dry: Composition   // dry (без W)
    public let daf: Composition   // dry ash free (без W та A)
    public let Qr: Double         // МДж/кг
    public let Qd: Double         // МДж/кг
    public let Qdaf: Double       // МДж/кг
}

public struct OilInput {
    // Горюча маса (daf)
    public let Cg, Hg, Og, Sg: Double // %
    // Додаткові параметри
    public let QdafProvided: Double?  // МДж/кг (якщо задано)
    public let Wr: Double             // %
    public let Ad: Double             // %
    public let VmgPerKg: Double?      // мг/кг (не впливає на розрахунок Q)
}

public struct OilResults {
    public let work: Composition  // склад робочої маси, %
    public let Qr: Double         // МДж/кг (за формулою Менделєєва)
    public let QdafFromComp: Double // МДж/кг, перераховано з daf-складу
    public let QdafProvided: Double? // що ввів користувач (для порівняння)
}

// MARK: - Обчислювач

enum CalculatorError: Error {
    case invalidPercentSum
    case invalidArguments
}

enum Calculator {
    // Формула Менделєєва (кДж/кг), далі ділимо на 1000 -> МДж/кг
    private static func mendeevQ_kJkg(C: Double, H: Double, O: Double, S: Double, W: Double) -> Double {
        // Q = 339*C + 1030*H - 108.8*(O - S) - 25*W, кДж/кг
        339.0*C + 1030.0*H - 108.8*(O - S) - 25.0*W
    }
    
    private static func mendeevQ_MJkg(C: Double, H: Double, O: Double, S: Double, W: Double) -> Double {
        mendeevQ_kJkg(C: C, H: H, O: O, S: S, W: W) / 1000.0
    }
    
    // Нормалізація до заданої суми (звичайно 100)
    private static func normalize(_ values: (H: Double, C: Double, S: Double, N: Double, O: Double, W: Double, A: Double), to total: Double) -> Composition {
        let sum = values.H + values.C + values.S + values.N + values.O + values.W + values.A
        guard sum != 0 else { return Composition(H: 0, C: 0, S: 0, N: 0, O: 0, W: 0, A: 0) }
        let k = total / sum
        return Composition(H: values.H*k, C: values.C*k, S: values.S*k, N: values.N*k, O: values.O*k, W: values.W*k, A: values.A*k)
    }
    
    // MARK: Завдання 1 (робоча -> суха/горюча; Qr/Qd/Qdaf)
    static func computeRaw(input: RawInput) throws -> RawResults {
        // базові коефіцієнти
        let kRS = 100.0 / max(0.0001, (100.0 - input.W))
        let kRG = 100.0 / max(0.0001, (100.0 - input.W - input.A))
        
        // Суха маса (без вологи): масштабуємо всі компоненти на kRS, але W=0
        let dry = Composition(
            H: input.H * kRS,
            C: input.C * kRS,
            S: input.S * kRS,
            N: input.N * kRS,
            O: input.O * kRS,
            W: 0,
            A: input.A * kRS
        )
        // Підчистимо до точно 100
        let dryNorm = normalize((dry.H, dry.C, dry.S, dry.N, dry.O, 0, dry.A), to: 100)
        
        // Горюча маса (без вологи та золи): масштабуємо на kRG; W=0, A=0
        let daf = Composition(
            H: input.H * kRG,
            C: input.C * kRG,
            S: input.S * kRG,
            N: input.N * kRG,
            O: input.O * kRG,
            W: 0,
            A: 0
        )
        let dafNorm = normalize((daf.H, daf.C, daf.S, daf.N, daf.O, 0, 0), to: 100)
        
        // Q для кожного стану — одна й та ж формула, але підставляємо склад відповідного стану
        let Qr  = mendeevQ_MJkg(C: input.C,     H: input.H,     O: input.O,     S: input.S,     W: input.W)
        let Qd  = mendeevQ_MJkg(C: dryNorm.C,   H: dryNorm.H,   O: dryNorm.O,   S: dryNorm.S,   W: 0)
        let Qdf = mendeevQ_MJkg(C: dafNorm.C,   H: dafNorm.H,   O: dafNorm.O,   S: dafNorm.S,   W: 0)
        
        return RawResults(kRS: kRS, kRG: kRG, dry: dryNorm, daf: dafNorm, Qr: Qr, Qd: Qd, Qdaf: Qdf)
    }
    
    // MARK: Завдання 2 (мазут): daf -> робоча маса; Qr
    static func computeOil(input: OilInput) throws -> OilResults {
        // Коефіцієнт переходу з daf до робочої маси (частка горючої у робочій)
        let f = max(0.0, (100.0 - input.Wr - input.Ad)) / 100.0
        
        // Переносимо елементи з daf до робочої, масштабуючи на f
        let work = Composition(
            H: input.Hg * f,
            C: input.Cg * f,
            S: input.Sg * f,
            N: 0,                 // якщо потрібно, можна окремо додати N_g у вхідні
            O: input.Og * f,
            W: input.Wr,
            A: input.Ad
        )
        let workNorm = normalize((work.H, work.C, work.S, work.N, work.O, work.W, work.A), to: 100)
        
        // Q_r з робочої маси
        let Qr = mendeevQ_MJkg(C: workNorm.C, H: workNorm.H, O: workNorm.O, S: workNorm.S, W: workNorm.W)
        
        // Q_daf на основі введеного daf-складу (для порівняння з наданим)
        let QdafFromComp = mendeevQ_MJkg(C: input.Cg, H: input.Hg, O: input.Og, S: input.Sg, W: 0)
        
        return OilResults(work: workNorm, Qr: Qr, QdafFromComp: QdafFromComp, QdafProvided: input.QdafProvided)
    }
}
