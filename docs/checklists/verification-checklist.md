# Manual QA Verification Checklist — Focus Flow 1.0.0

This checklist must be completed before submitting the release AAB to Google Play.
All items should be verified on the **release-signed APK** (not a debug build).

---

## 1. App Startup & Identity (Requirement 14.1)

- [ ] App displays the correct name "Focus Flow" in the device launcher
- [ ] App displays the correct launcher icon (not the default Flutter icon)
- [ ] Splash screen appears on cold start with correct branding
- [ ] No debug banner is visible at any point
- [ ] App reaches the home screen without crashes or ANR

---

## 2. Language Switching (Requirement 14.2)

- [ ] Change device language to Spanish → app displays all text in Spanish
- [ ] Change device language to English → app displays all text in English
- [ ] Navigation labels update correctly on language change
- [ ] Pomodoro timer labels update correctly on language change
- [ ] Settings section headers update correctly on language change
- [ ] No untranslated strings remain visible in either language

---

## 3. Todo CRUD Operations (Requirement 14.3)

- [ ] Create a new todo task with a title
- [ ] Created task appears in the task list immediately
- [ ] Read: task list displays all previously created tasks
- [ ] Update: edit an existing task's title and confirm the change persists
- [ ] Update: mark a task as complete and confirm visual state change
- [ ] Delete: remove a task and confirm it disappears from the list
- [ ] Delete: confirm deleted task does not reappear after navigating away and back

---

## 4. Pomodoro Timer (Requirement 14.4)

- [ ] Start a work session → timer counts down from configured duration
- [ ] Pause the timer → countdown stops, timer value is preserved
- [ ] Resume the timer after pause → countdown continues from where it stopped
- [ ] Complete a full work session → app transitions to break state
- [ ] Start and complete a break session → app returns to ready state
- [ ] Timer displays remaining time correctly (minutes and seconds)
- [ ] Timer continues counting when app is in foreground

---

## 5. Statistics Display (Requirement 14.5)

- [ ] Complete at least one Pomodoro work session
- [ ] Navigate to Statistics screen → completed session is reflected
- [ ] Total completed sessions count is accurate
- [ ] Per-task statistics display correctly (if tasks were associated)
- [ ] Statistics values do not reset on app restart
- [ ] Charts/visualizations render without overflow or visual glitches

---

## 6. Settings Persistence (Requirement 14.6)

- [ ] Change a setting (e.g., Pomodoro duration, theme)
- [ ] Force-close the app completely (remove from recent apps)
- [ ] Relaunch the app → changed setting retains its value
- [ ] Change theme → relaunch → theme is still applied
- [ ] All user-configurable settings survive app restart

---

## 7. Privacy Policy Link (Requirement 14.7)

- [ ] Open Settings screen → "Privacy Policy" option is visible
- [ ] Tap Privacy Policy → device's external browser opens
- [ ] The opened URL loads the correct privacy policy page
- [ ] Returning to the app from the browser works without issues
- [ ] If URL fails to open, a user-friendly error message (SnackBar) is shown

---

## 8. Offline Operation (Requirement 14.8)

- [ ] Enable airplane mode on the device
- [ ] Launch the app → app opens normally without errors
- [ ] Create a new todo task in airplane mode → task is saved
- [ ] Start and complete a Pomodoro session in airplane mode
- [ ] Navigate between all screens without network errors or loading spinners
- [ ] No "no internet" error messages or dialogs appear
- [ ] Disable airplane mode → app continues to work normally

---

## 9. Data Survival (Requirement 14.9)

- [ ] Create several todo tasks and complete a Pomodoro session
- [ ] Force-stop the app process (Settings → Apps → Focus Flow → Force Stop)
- [ ] Relaunch the app → all created tasks are still present
- [ ] Completed Pomodoro session count is preserved in statistics
- [ ] Settings values remain unchanged after process kill
- [ ] Restart the device → relaunch app → all data is intact

---

## 10. Layout Integrity — Small Screen (Requirement 14.10)

- [ ] Test on a device or emulator with 360dp screen width
- [ ] Home screen: no text overflow, no clipped widgets
- [ ] Todo list screen: tasks are fully readable, no horizontal overflow
- [ ] Pomodoro screen: timer and controls are fully visible without scrolling
- [ ] Statistics screen: charts and text fit within screen bounds
- [ ] Settings screen: all options are visible and tappable
- [ ] Navigation bar: all icons and labels are visible and tappable

---

## 11. Text Scaling (Requirement 14.11)

- [ ] Set system text scaling to 200% (Accessibility → Font size → Largest)
- [ ] Home screen: text remains readable, no overlapping elements
- [ ] Todo list: task titles are readable, list items don't overlap
- [ ] Pomodoro screen: timer digits are readable, buttons remain accessible
- [ ] Statistics screen: labels and values are readable
- [ ] Settings screen: all labels remain readable and sections distinguishable
- [ ] No text is truncated to the point of being unreadable

---

## 12. Themes (Requirement 14.12)

- [ ] Switch to light theme → all screens display correct light colors
- [ ] Switch to dark theme → all screens display correct dark colors
- [ ] Text contrast meets readability standards in light theme
- [ ] Text contrast meets readability standards in dark theme
- [ ] Interactive elements (buttons, cards, inputs) are distinguishable in both themes
- [ ] No hardcoded colors appear (elements that don't change with theme)
- [ ] Navigation bar adapts correctly to both themes

---

## 13. Device Coverage (Requirement 14.13)

- [ ] Test completed on at least one **physical Android device**
  - Device model: _______________
  - Android version: _______________
  - Screen size: _______________
- [ ] Test completed on at least one **Android emulator**
  - Emulator configuration: _______________
  - API level: _______________
  - Screen size: _______________
- [ ] No device-specific crashes or rendering issues found

---

## Sign-Off

| Verified By | Date | Result |
|---|---|---|
| | | Pass / Fail |

**Notes:**
- All items must be checked (pass) before the AAB is uploaded to Google Play.
- If any item fails, document the issue, fix it, rebuild the release APK, and re-verify the failed section.
- This checklist should be performed on the same signed APK/AAB that will be uploaded to the Play Console.
