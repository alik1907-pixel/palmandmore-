# KPI.md — Hedefler ve ölçümler

## Hedefler (brief + RESEARCH.md §1–2)
| Metrik | Hedef | Ara kapı (yumuşak lansman 1. iterasyon) | Pazar referansı |
|---|---|---|---|
| D1 | ≥ %40 | ≥ %35 | Medyan ~%22–27; en iyi %10 ~%40 |
| D7 | ≥ %15 | ≥ %10 | Medyan ~%4; en iyi %10 ~%12 |
| D30 | ≥ %5 | ≥ %3 | Medyan ~%0,7 |
| Günlük oynama | ≥ 15 dk | ≥ 10 dk | — |
| CPTD3 (3 gün toplam oynama) | ≥ 5000 sn | — | Homa hibrit-gündelik kapısı |
| CPI (yumuşak lansman pazarı) | < 1,0 $ | — | Homa kapısı |
| Çökme / ANR | < %0,5 / < %0,2 | — | Google eşikleri: %1,09 / %0,47 |

## Ölçümler
| Tarih | Kaynak | Metrik | Değer | Not |
|---|---|---|---|---|
| 2026-11-26 | Bot (greybox) | Bölüm başarı eğrileri | CONCEPTS.md | İnsan verisi değil |
| 2026-11-26 | Planlayıcı bot, 40 koşu (M2) | Bölüm 1→15 kazanma | %97,5 → %22,5 | media/m2/levels_validation_40runs.jsonl; insan verisi değil |
| 2026-11-26 | Planlayıcı bot | Bölüm süresi (kazananlar) | 9,7–26,4 sn | Hedef 15–40 sn; ilk bölümler kısa |

## Analitik olay şeması
M4'te tanımlanacak (tutorial_step, level_start/fail/complete, inflate_ms, pop_location, ad_offer/watch, share, iap...).
