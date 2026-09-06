# Mockup generation prompts

Mode: built-in image generation, using the imagegen skill. No input/reference images were supplied. All three are new images. Originals remain in the generator's output directory; selected copies live beside this document.

## A: pay-audit-concept.png

```text
Use case: ui-mockup
Asset type: project product concept mockup for a mobile app proposal
Primary request: Create a polished high-fidelity product mockup showing three iPhone-like mobile screens side by side for a private flat-rate automotive technician pay logbook named "Flat Rate". The concept emphasizes rapid logging, explaining where time went, and reconciling a paycheck.
Scene/backdrop: clean neutral charcoal presentation board, no workshop scene
Style/medium: realistic modern mobile product design, crisp UI, practical rather than flashy
Composition/framing: landscape presentation, three complete portrait phone screens side by side, front-on, evenly spaced
Color palette: dark graphite UI with warm amber action accents, green for matched items, muted red only for discrepancies, high contrast for shop lighting
Screen 1 exact content: header "Today"; large stats "7.4 Flagged" and "8.2 At shop"; current item card "RO 18426  Brake job" with timer "01:18"; large action button "Stop job"; two secondary buttons "Scan RO" and "Log other time".
Screen 2 exact content: header "Where time went"; stacked summary labels "Jobs 6.7h", "Waiting on parts 0.6h", "Diagnosis 0.5h", "Shop duty 0.4h"; bottom insight card "1.5h not attached to paid work"; large button "Add time".
Screen 3 exact content: header "Paycheck check"; large status "79.1 of 82.4h matched"; discrepancy list "RO 18391  Missing 1.3h", "RO 18402  Paid next period 2.0h"; green row "46 ROs matched"; large button "Review differences".
Constraints: readable exact text, large glove-friendly controls, one-handed hierarchy, offline/private feel, no charts that imply fake precision, no employer dashboard, no legal claim, no brand logos, no watermark
Avoid: tiny text, neon cyberpunk, excessive gradients, glassmorphism, clutter, generic finance imagery
```

## B: simple-ledger-concept.png

```text
Use case: ui-mockup
Asset type: alternative B, high fidelity mobile app design concept for Flat Rate, a private automotive technician logbook.
Primary request: A wide presentation board with three complete mobile screens side by side, perfectly front-on, light warm neutral background. Screens have off-white surfaces, very dark readable typography, subtle gray rules, restrained deep teal accents. Calm, simple, practical ledger design with generous space and large touch targets. Minimal device frames, no props, no dramatic shadows.
Screen 1: title "Today", subtitle "Friday, Sep 4", discreet "Saved on device". Two large metrics "7.4" caption "Flagged hours", "8.2" caption "Hours worked". List titled "Recent jobs": "RO 18426" / "Brakes · Customer" / "2.4h flagged"; "RO 18425" / "Diagnosis · Warranty" / "1.0h flagged". Primary bottom button "Log a job". Bottom tabs "Today", "Time", "Pay".
Screen 2: title "Log a job". A focused form, visible labeled fields "RO number" value "18427"; "Flagged hours" value "1.7"; "Actual time" value "Add later". Segmented choice "Customer", "Warranty", "Internal", "Recall" with Customer selected. Row "Writer" value "Sam". Large bottom button "Save job". Strong hierarchy and sparse layout; no keyboard.
Screen 3: title "Pay period", subtitle "Aug 24 – Sep 6". Prominent "82.4h" caption "Recorded flags"; "79.1h" caption "On this statement". Separate neutral blue card "2.0h paid next period". Amber card "1.3h needs review". Main button "Review 1 difference". Smaller outlined button "Export my record". Bottom tabs same.
Constraints: exactly three complete distinct screens, all specified words correctly spelled, believable mobile design, no invented charts, no legal claims, no AI copy, no watermark. Label the board subtly "B / SIMPLE LEDGER". All data is illustrative.
```

## C: pay-review-concept.png

```text
Use case: ui-mockup
Asset type: alternative C, high fidelity mobile app design concept for Flat Rate.
Primary request: A landscape presentation board of three full mobile screens side by side on a neutral dark backdrop. Front-on narrow phone frames. Flat graphite surfaces, white typography, restrained teal actions and amber review statuses. Professional calm product UI, clear text, no metallic effects, no neon, no excessive cards. This design centers on reviewing a pay difference and preserving the recorded history.
Screen 1: header "My pay", subtitle "Aug 24 – Sep 6". A large headline "1.3h to review" with supporting text "82.4h recorded · 79.1h on statement". One amber list item "RO 18391" / "1.3h unmatched" and one blue list item "RO 18402" / "2.0h paid next period". Primary action "Review difference". Secondary action "Add statement". Bottom tabs "Log", "Time", "Pay" with Pay selected.
Screen 2: header "RO 18391", subtitle "Review difference". Clear two-column comparison: "Recorded" value "2.3h"; "On statement" value "1.0h". Amber horizontal strip "Difference 1.3h". Section "Record history" with a simple vertical timeline of two entries: "Sep 2 · You recorded 2.3h" and "Sep 4 · Statement shows 1.0h". Supporting text "Your original entry is kept." Large action "Add explanation", smaller "Leave unresolved". No lawsuit, wage theft, or debt language.
Screen 3: header "Log other time". Helper "What were you doing?". Five large one-handed tap rows: "Waiting on parts", "Waiting for work", "Shop duty", "Training", "Other". Waiting on parts selected in teal. Large field "Duration" value "30 min". Optional row "Related RO" value "18426". Primary bottom action "Save time". Quiet note "Time recorded, pay status unknown".
Constraints: readable correct exact text, three full screens, sparse layout with thumb-reachable actions, semantic distinction between unresolved and paid later; no accusations, no stock imagery, no watermark. Label board subtly "C / PAY REVIEW". All numbers are illustrative.
```
