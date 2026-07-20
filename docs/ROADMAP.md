# WardReady — Product Survival Roadmap
*Updated 2026-07-21 based on Senior Engineer Critique*

**OVERVIEW:**
All "Heavy/Medium" over-engineering tasks (Crash cages, LogService, App Doctor) are PAUSED. Focus is strictly on clinical safety, distribution survival, and content completion (missing 2,172 questions).

## 🚨 P0 - Clinical & Distribution (Launch Blockers)
*   **The "Emergency" Disclaimer:** Mandatory, non-skippable modal on first launch ("Not a clinical guideline. Educational use only.").
*   **Sideload Survival Guide:** Visual PDF/graphic for Telegram on bypassing Android "Unknown Sources" warnings.
*   **Support Contact on Paywall:** Clear Telegram handle for failed manual Telebirr payments.
*   **Clinical Content Peer Review:** Core content must be reviewed by a licensed physician.

## 🚧 P1 - Infrastructure & UX
*   **"Report Error" Button:** Add UI to Articles/Questions for students to report medical inaccuracies.
*   **"True Offline" Boot Test:** Prove app boots instantly with zero cell signal (no `dio` timeout hangs).
*   **Data Budget Audit:** Measure MB cost of a full sync (determine if Wi-Fi-only toggle is needed).

## ✨ P2 - Final Polish
*   **Empty State UI:** "You haven't saved any articles yet" (replace blank white screens).
*   **Haptic Feedback:** Subtle vibrations for Correct/Incorrect quiz answers.
*   **Loading Skeletons:** Replace CircularProgressIndicators with shimmering boxes.
