# Store Visual Assets Checklist — Focus Flow 1.0.0

## Overview

This document lists all visual assets required for Google Play Store submission, their specifications, and their current status.

---

## App Icon (Play Store)

| Requirement | Value |
|---|---|
| Size | 512×512 px |
| Format | PNG (32-bit, with alpha) |
| Source file | `assets/branding/app_icon.png` |
| Status | **Source available** — export/resize from branding asset |

**Notes:**
- The Play Store icon and the launcher icon are **different deliverables**. The launcher icon is generated via `flutter_launcher_icons` and includes adaptive icon layers. The Play Store icon is a single 512×512 PNG uploaded to the Console.
- Use `assets/branding/app_icon.png` as the source to produce the 512×512 version. Ensure it has no transparency issues at that size and meets Google's icon design guidelines (no rounded corners — the system applies masking).

---

## Feature Graphic

| Requirement | Value |
|---|---|
| Size | 1024×500 px |
| Format | PNG or JPEG |
| Source file | **Does not exist yet** |
| Status | **Needs to be designed** |

**Notes:**
- The feature graphic is displayed at the top of the Play Store listing on some device layouts.
- It should include the app name, a visual representation of the app's purpose, and use a color palette consistent with the app's themes.
- Avoid text smaller than 24sp equivalent and leave safe margins (the graphic may be cropped on smaller displays).

---

## Phone Screenshots

### Requirements

| Spec | Value |
|---|---|
| Minimum count | 2 (Google requires at least 2) |
| Recommended count | 6 |
| Aspect ratio | 16:9 or 9:16 (portrait recommended) |
| Resolution | Minimum 320px on shortest side, maximum 3840px on longest side |
| Format | PNG or JPEG |
| Status | **Not yet captured** |

### Recommended Screenshots (6 total)

| # | Screen | Description (es-AR) | Description (en-US) |
|---|---|---|---|
| 1 | Lista de tareas (Home/Todo) | Vista principal con tareas organizadas por categoría | Main view with tasks organized by category |
| 2 | Creación/edición de tarea | Formulario de creación con campos de nombre, categoría y descripción | Task creation form with name, category, and description fields |
| 3 | Pomodoro en ejecución | Temporizador activo mostrando progreso del ciclo actual | Active timer showing current cycle progress |
| 4 | Estadísticas generales | Métricas de productividad con sesiones completadas y tiempo total | Productivity metrics with completed sessions and total time |
| 5 | Estadísticas por tarea | Actividad Pomodoro detallada de una tarea individual | Detailed Pomodoro activity for an individual task |
| 6 | Configuración | Pantalla de ajustes con temas, idioma, sonido y política de privacidad | Settings screen with themes, language, sound toggle, and privacy policy |

### Language Priority

- **Primary screenshots:** Spanish (es-AR) — these are required and shown as default listing.
- **English screenshots:** Optional — can be added for the en-US localized listing if desired.

---

## Screenshot Capture Guidelines

### Build requirements
- Screenshots MUST be captured from a **release-like build** (`--release` or `--profile` flag).
- The `--release` build ensures no debug banner appears.
- The `--profile` build also lacks the debug banner and is suitable for capture.
- **Never** use a debug build for screenshots (the "DEBUG" banner will be visible).

### Content requirements
- Use **realistic sample data** that demonstrates the app's features clearly.
- **No real personal information** (names, emails, phone numbers) should appear in screenshots.
- Use fictional but believable task names (e.g., "Preparar presentación", "Estudiar Flutter", "Revisar código").
- Show a variety of task states (completed, pending, in-progress).

### Visual requirements
- **No emulator controls** visible (navigation bars, status bar icons are acceptable).
- Consistent color palette across all screenshots (use the same theme).
- Screenshots should show the app in a state that highlights the key feature of that screen.
- Ensure text is legible and UI elements are not truncated.

### Sound feature visibility
- The audio completion sound feature **cannot be shown visually** in a screenshot.
- However, the **Settings screen** (screenshot #6) naturally shows the sound toggle, which confirms the feature exists.
- Do not attempt to artificially demonstrate audio in screenshots.

---

## Deliverable Summary

| Asset | Spec | Source Exists | Ready |
|---|---|---|---|
| Play Store icon | 512×512 PNG | Yes (`assets/branding/app_icon.png`) | Resize needed |
| Feature graphic | 1024×500 PNG/JPEG | No | Design needed |
| Screenshot 1 — Task list | Portrait, phone res | No | Capture needed |
| Screenshot 2 — Task form | Portrait, phone res | No | Capture needed |
| Screenshot 3 — Pomodoro running | Portrait, phone res | No | Capture needed |
| Screenshot 4 — General stats | Portrait, phone res | No | Capture needed |
| Screenshot 5 — Per-task stats | Portrait, phone res | No | Capture needed |
| Screenshot 6 — Settings | Portrait, phone res | No | Capture needed |

---

## Additional Notes

- The launcher icon (adaptive, generated by `flutter_launcher_icons`) is already configured and does not need Play Store submission — it is baked into the APK/AAB.
- The Play Store 512×512 icon is a **separate upload** in the Play Console under "Store listing > Graphics."
- All screenshots should be captured **after** the release APK/AAB is verified as stable.
- If Spanish screenshots are the only set uploaded, they will display for all locales. English screenshots can be added later to the en-US localized listing.
