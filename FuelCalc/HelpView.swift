//
//  HelpView.swift
//  FuelCalc
//
//  Created by Максим Гайдук on 26.09.2025.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        NavigationStack {
            ScrollView {                             // Скрол дозволено лише тут
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: Заголовок
                    Text("Довідка")
                        .font(.largeTitle).bold()
                        .padding(.top, 4)

                    // MARK: Визначення мас палива
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Визначення мас палива").font(.title3).bold()
                                Text("• **Робоча маса (Wr)** — склад палива з урахуванням **вологи W** і **золи A**.")
                                Text("• **Суха маса (Sd)** — склад **без вологи** (W = 0).")
                                Text("• **Горюча маса (Gd або daf)** — склад **без вологи та золи** (W = 0, A = 0).")
                            }
                            Spacer()
                        }
                    }
                    .groupBoxStyle(.automatic)

                    // MARK: Перерахунок складу між базами
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Перерахунок складу між базами").font(.title3).bold()
                                Text("Коефіцієнти переходу з робочої маси:")
                                VStack(alignment: .leading, spacing: 6) {
                                    monospaced("KRS = 100 / (100 − W)")
                                    monospaced("KRG = 100 / (100 − W − A)")
                                }
                                Text("Застосування (для кожного елементу H, C, S, N, O):")
                                VStack(alignment: .leading, spacing: 6) {
                                    monospaced("До сухої маси:  X_d = X_r · KRS;    W_d = 0;    A_d = A_r · KRS")
                                    monospaced("До горючої маси: X_daf = X_r · KRG;   W_daf = 0;  A_daf = 0")
                                }
                                Text("Після множення **нормалізуйте** суму до 100% (щоб уникати похибок округлення).")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }

                    // MARK: Нижча теплота згоряння
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Нижча теплота згоряння (формула Менделєєва)").font(.title3).bold()
                                Text("Для будь-якої бази (робоча/суха/горюча) підставляємо відповідний склад у формулу:")
                                monospaced("Q = 339·C + 1030·H − 108.8·(O − S) − 25·W   [кДж/кг]")
                                Text("У застосунку значення подаються в **МДж/кг** (поділено на 1000).")
                                    .foregroundColor(.secondary)
                                Text("Позначення теплоти:")
                                Text("• **Qr** — на робочу масу;  **Qd** — на суху масу;  **Qdaf** — на горючу (daf).")
                            }
                            Spacer()
                        }
                    }

                    // MARK: Алгоритм розрахунку (Завдання 1)
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Алгоритм розрахунку — Завдання 1 (робоча → суха/горюча)").font(.title3).bold()
                                numbered([
                                    "Ввести склад робочої маси: H, C, S, N, O, W, A (у %).",
                                    "Перевірити, що кожне поле — число у діапазоні 0…100.",
                                    "Перевірити суму: H + C + S + N + O + W + A ≈ 100%. Допуск у додатку: ±0.5%.",
                                    "Обчислити коефіцієнти: KRS, KRG.",
                                    "Перерахувати склад до сухої (W=0) та горючої (W=0, A=0) мас і нормалізувати до 100%.",
                                    "Обчислити Qr (робоча), Qd (суха), Qdaf (горюча) за формулою Менделєєва.",
                                    "Показати результати у вікні результатів."
                                ])
                            }
                            Spacer()
                        }
                    }

                    // MARK: Алгоритм розрахунку (Завдання 2)
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Алгоритм розрахунку — Завдання 2 (мазут, daf → робоча)").font(.title3).bold()
                                numbered([
                                    "Ввести склад горючої маси (daf): Cg, Hg, Og, Sg (у %). Сума має бути ≈ 100% (±0.5%).",
                                    "Ввести Qdaf (МДж/кг) — за потреби (необов’язково), Wr (%), Ad (%), V (мг/кг ≥ 0).",
                                    "Перевірити діапазони: % — 0…100, Qdaf ≥ 0, V ≥ 0.",
                                    "Обчислити частку горючої в робочій: f = (100 − Wr − Ad)/100.",
                                    "Перерахувати склад робочої маси: X_r = X_g · f; далі нормалізувати до 100%.",
                                    "Обчислити Qr із робочої маси за формулою Менделєєва.",
                                    "Порівняти введений Qdaf (якщо задано) з Qdaf, обчисленим із daf-складу."
                                ])
                            }
                            Spacer()
                        }
                    }

                    // MARK: Валідації в застосунку
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Валідації (як працює додаток)").font(.title3).bold()
                                bullet([
                                    "Поле підсвічується **червоним тільки після завершення редагування**, якщо значення не число або поза діапазоном.",
                                    "Для **відсотків** дозволений діапазон **0…100**.",
                                    "**Qdaf** (МДж/кг) та **V** (мг/кг) мають бути **≥ 0**.",
                                    "Завдання 1: **сума** H+C+S+N+O+W+A повинна бути **100 ± 0.5%**.",
                                    "Завдання 2: **сума** Cg+Hg+Og+Sg повинна бути **100 ± 0.5%**.",
                                    "Якщо валідація не пройдена — кнопка «Розрахувати» напівпрозора, натискання показує алерт із причиною."
                                ])
                            }
                            Spacer()
                        }
                    }

                    // MARK: Одиниці та форматування
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Одиниці та форматування").font(.title3).bold()
                                bullet([
                                    "% — масова частка елементів у відповідній базі (робочій/сухій/горючій).",
                                    "Q — в **МДж/кг** (у формулі спершу кДж/кг, потім ділення на 1000).",
                                    "В полі вводу можна використовувати **крапку або кому** як роздільник дробової частини."
                                ])
                            }
                            Spacer()
                        }
                    }

                    // MARK: Корисні поради
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Поради").font(.title3).bold()
                                bullet([
                                    "Якщо сумарний % трохи «пливе» через округлення — додаток усе одно нормалізує до 100%.",
                                    "Для перевірки своїх розрахунків скористайся контрольним прикладом із методички (можемо додати автозаповнення).",
                                    "На захисті підготуй: що таке бази (Wr/Sd/Gd), звідки беруться KRS/KRG, і як перераховуються Q."
                                ])
                            }
                            Spacer()
                        }
                    }

                    // MARK: Позначення
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Позначення").font(.title3).bold()
                                Text("""
                            • H, C, S, N, O — масові частки елементів, %  
                            • W — волога, %   • A — зола, %  
                            • Qr, Qd, Qdaf — нижча теплота згоряння (робоча/суха/горюча), МДж/кг  
                            • KRS, KRG — коефіцієнти переходу з робочої маси до сухої/горючої  
                            • f — частка горючої у робочій масі (для мазуту)
                            """)
                            }
                            Spacer()
                        }
                    }

                    // MARK: Посилання (заповниш у звіті)
                    GroupBox {
                        HStack {
                            Spacer()
                            Link("GitHub", destination: URL(string: "https://github.com/Limbo395/FuelCalc")!)
                                .foregroundColor(.blue)
                                .foregroundColor(.secondary)
                            Spacer()
                            
                        }
                    }
                }
                .padding(16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.visible)
        }
    }

    // MARK: - Small helpers

    @ViewBuilder
    private func monospaced(_ text: String) -> some View {
        Text(text)
            .font(.system(.body, design: .monospaced))
            .padding(.vertical, 2)
    }

    @ViewBuilder
    private func bullet(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(items, id: \.self) { line in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("•")
                    Text(LocalizedStringKey(line))
                }
            }
        }
    }

    @ViewBuilder
    private func numbered(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { (idx, line) in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(idx+1).").fontWeight(.semibold)
                    Text(LocalizedStringKey(line))
                }
            }
        }
    }
}

#Preview {
    HelpView()
}
