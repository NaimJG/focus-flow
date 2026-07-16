# Focus Flow — UI & UX Philosophy

These principles define the user interface and experience standards for every screen in Focus Flow. They apply to all feature specifications, design documents, and implementation decisions. They are not visual designs — they are the criteria by which every UI decision is evaluated.

---

## Material Design

- Use Material 3 components whenever possible.
- Prefer native Flutter Material widgets (`FilledButton`, `Card`, `NavigationBar`, `TextField`, etc.) over custom-built equivalents.
- Only build custom widgets when a native component cannot be adapted to provide clear, demonstrable value.
- Keep Material 3 theming consistent — do not mix Material 2 and Material 3 patterns in the same screen.

---

## Theming

Focus Flow supports multiple user-selectable Material 3 themes.

Themes are a global application concern and must be defined centrally under:

app/theme/

Feature modules must consume colors using Flutter's Theme API (`Theme.of(context)`) and must never hardcode application colors.

Version 1.0 provides three built-in theme families:

- Warm
- Nature
- Ocean

Each theme must define a complete Material 3 `ColorScheme`, ensuring visual consistency and accessibility across the application.

The selected theme must be applied globally and persisted locally so it is restored automatically when the application is reopened.

Future versions may introduce additional themes, but existing features must automatically adapt to any global theme without requiring feature-specific changes.

---

## Consistency

- Maintain a uniform visual language across all screens. A user who has seen one screen should feel immediately oriented on any other.
- Before creating a new widget, check `shared/widgets/` first. Reuse existing components wherever possible.
- A given interaction (e.g., deleting an item, confirming an action, navigating back) must always look and behave the same way across the app.
- Do not introduce a second visual pattern for something that already has one.

---

## Simplicity

- Every screen has exactly one primary purpose. If a screen is trying to do two things, it should be two screens or one should be removed.
- Keep interfaces clean and uncluttered. When in doubt, leave it out.
- Avoid decorative UI elements that do not carry information or guide the user.
- If a UI element's purpose cannot be explained in one sentence, reconsider whether it belongs.

---

## Accessibility

- Typography must be readable at default system font sizes. Do not use font sizes below 12sp for any visible text.
- Maintain a minimum contrast ratio of 4.5:1 for body text and 3:1 for large text, following WCAG 2.1 AA guidelines.
- All interactive touch targets must be at least 48×48dp.
- Never rely solely on color to communicate information. Always pair color with an icon, label, or text alternative.
- Provide meaningful `Semantics` labels on interactive widgets that lack visible text (e.g., icon-only buttons).

---

## Responsive Design

- Design mobile-first. The primary target is Android phones in portrait orientation.
- Use flexible layout constructs (`Expanded`, `Flexible`, `FractionallySizedBox`, `LayoutBuilder`) instead of fixed pixel dimensions.
- Test on small screens (360dp width) and large screens (480dp+) to ensure layouts do not break or overflow.
- Avoid hardcoded widths and heights for content containers.

---

## Performance

- Use `const` constructors on all widgets that do not depend on runtime-variable state.
- Scope state as narrowly as possible to minimize widget rebuild surface area.
- Avoid placing heavy computations inside `build()` methods. Derive or cache values outside the build tree.
- Keep widget trees shallow. Deep nesting increases rebuild cost and reduces readability.
- Prefer `ListView.builder` and `SliverList` over `ListView` with children for any list that may grow beyond a handful of items.

---

## User Experience

- Prioritize fast and predictable interactions. The user should always know what will happen before they tap.
- Minimize the number of taps required to complete a common action. If a frequent action takes more than two taps from the relevant screen, reconsider the flow.
- Primary actions must be immediately visible and reachable without scrolling.
- Use animations only when they communicate a meaningful state change or spatial relationship. Never use animation purely as decoration.
- Animation durations should follow Material 3 motion guidelines: prefer durations in the 200–300ms range for transitions.

---

## Error and Feedback States

Every screen that can load, fail, or be empty must handle all three states explicitly.

| State | Requirement |
|---|---|
| **Empty** | Show a message that explains why the screen is empty and guides the user toward a first action. |
| **Loading** | Show a visual indicator (`CircularProgressIndicator`) for any operation that may take more than 300ms. |
| **Error** | Show a message that describes the problem in plain language and, where possible, offers a recovery action (e.g., a retry button). |

- Never leave a screen blank or frozen without feedback.
- Do not expose technical error messages (stack traces, exception names) to the user.
- Snackbars are for transient confirmations. Dialogs are for decisions that require explicit acknowledgment. Do not swap them.

---

## Future Compatibility

This document defines design principles only. It must never be interpreted as introducing requirements for features outside the v1.0 scope.

The following are explicitly out of scope and must not influence any UI decision made under these principles:

- Cloud synchronization UI
- Achievement or gamification screens
- AI-powered suggestions or overlays
- Premium upgrade flows
- Home screen or lock screen widgets

The purpose of this document is to ensure every future screen generated for Focus Flow follows the same user experience philosophy — simple, accessible, consistent, and purposeful.
