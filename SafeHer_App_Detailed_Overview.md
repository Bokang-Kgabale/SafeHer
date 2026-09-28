# SafeHer — Detailed App Overview

**Purpose:** a single, complete reference for exactly what SafeHer is, what it does, how each part works, and — honestly — what's actually built versus what's still on the roadmap. Sourced from `SafeHer_SRS.md` and `SafeHer_SDLC.docx`; nothing here claims more than those documents support.

---

## 1. What SafeHer is, in one paragraph

SafeHer is a mobile safety app that turns the crime knowledge women already carry — the street avoided after dark, the shortcut abandoned since something happened to a friend — into a shared, live map. Women pin the areas they know to be dangerous; anyone nearby sees those hotspots and can be routed around them. As a user approaches a flagged area, her phone vibrates and gives her a 60-second window to stand the alert down — if she doesn't, it escalates on its own, sending her live location to the people she trusts. Getting help never requires unlocking the phone: a spoken word, a fall, or a tap of the panic button all fire the same response.

---

## 2. The problem it exists to solve

- **Information gap** — generic mapping apps (Google Maps, Waze) surface traffic and directions, not crowd-sourced danger data, and offer no route that actively avoids it.
- **Response gap** — when an incident happens, women often lack a fast, low-friction way to alert someone, and have no way to know where the nearest police station, clinic, or hospital is.
- **The opportunity** — a crowd-sourced, geofenced safety layer (pinned by women, for women) combined with automatic, hands-free emergency escalation closes both gaps at once.

The scale of the problem: South Africa's intimate-partner femicide rate is roughly **5× the global average**; **3 women** are killed by a partner every day; **1 in 3 women** will experience physical or sexual violence in her lifetime (South African Medical Research Council).

---

## 3. Who uses it

| Role | Who they are | What they get |
|---|---|---|
| **Primary users** | Women and girls navigating on foot, by taxi, or by public transport — students, commuters, residents of high-risk neighbourhoods | Hotspot map, geofence alerts, panic pipeline, safer routing |
| **Next of kin** | Emergency contacts a user nominates in advance | Live coordinates and alerts the moment a panic event fires |
| **Community moderators** | Trusted users who review flagged/disputed pins | Keep the map accurate, prevent abuse |
| **Response partners** | SAPS, private security, GBV-focused NGOs | May consume aggregated, anonymised hotspot data to target interventions |
| **Prospects / reviewers** | Anyone evaluating the app without an account | Full Preview Mode walkthrough, zero real data or permissions |

---

## 4. Feature-by-feature breakdown

### 4.1 Hotspot Reporting
A user drops a pin at a location, picks a category (robbery, harassment, assault, no lighting, etc.), can add a free-text description, and it's stamped with a timestamp and the reporter's ID (for moderation only, never shown publicly). The pin publishes **immediately** to the public map — there's no pre-publication approval gate, since a real danger sitting unflagged while awaiting review would defeat the point. Every submission is validated and sanitised server-side to block spam or malicious content.

### 4.2 Map & Location
The map shows the user's live location, every nearby published hotspot in real time, and — always — the nearest police station, clinic, and hospital, so a woman knows where to go, not just what to avoid. Map tiles and the last-known hotspot set are cached locally, so the app stays usable on poor connectivity.

### 4.3 Geofencing & the 60-Second Countdown
A background service checks the user's live location against nearby hotspot radii — **without continuous GPS polling**, so it doesn't drain the battery. On entering a flagged zone, the phone vibrates and a 60-second on-screen countdown starts with a prominent "False Alarm" button. If she doesn't tap it, the panic pipeline fires automatically. Repeat entries into the same hotspot are debounced so it doesn't spam the same alert over and over.

### 4.4 The Panic Pipeline
One outcome, four independent ways to trigger it:

1. **Manual button** — a one-tap in-app panic button.
2. **Voice trigger** — an on-device listener recognises the spoken or screamed word "help" and fires the pipeline without unlocking the phone. Keyword-spotting runs entirely on-device; raw audio is never uploaded or stored.
3. **Power-button triple-press** — three rapid presses, even while locked.
4. **Fall detection** — accelerometer/gyroscope thresholds detect a fall, with a short cancellable countdown to avoid false positives from a dropped phone.

On trigger, the outcome is always the same: the system sends the user's live GPS coordinates and attempts a call and/or WhatsApp message to her **next of kin only**, escalating to the next contact in priority order if unacknowledged. **The system never contacts, or claims to contact, police or emergency services automatically** — an earlier draft implied this and was corrected, since a phone call to a public number that no one is monitoring is indistinguishable, from the user's side, from a false promise that help was notified. Every panic surface states this plainly and prompts her to call emergency services herself if she safely can. If no next-of-kin contact is configured, the app warns her immediately rather than failing silently. The UI never visibly reveals to anyone else holding the phone that a panic event is in-flight — an explicit abuse-case protection for a partner with physical access to the device.

### 4.5 Next-of-Kin Management
A user can add, edit, remove, and re-order a prioritised list of emergency contacts. Viewing or editing that list — and viewing panic history — requires re-authentication, so a partner with casual phone access can't silently view or tamper with it.

### 4.6 Routing
Calculates a route between the user's location and a destination; if the default route passes through an active hotspot, it calculates and offers an alternative that avoids it.

### 4.7 Moderation
Any user can flag or dispute a published hotspot. Flagged/disputed pins go to community moderators for review, and every moderation action (who reviewed, what decision, when) is recorded in an audit trail.

### 4.8 Notifications
Push notifications fire when a new hotspot publishes nearby, and confirm panic-alert status back to the triggering user where connectivity allows. Push payloads never carry raw location or personal data — only a prompt to open the app, which then pulls data over an authenticated channel.

### 4.9 Public/NGO Web Map
A read-only, browser-based map reading the same live hotspot data as the mobile app — useful for a community or NGO-facing dashboard. It never exposes any individual user's live location or next-of-kin data.

### 4.10 Subscriptions & Payments
- **Free tier**: the map, hotspot reporting, geofence alerts, and the full panic pipeline — never paywalled.
- **Premium Individual**: priority support, family sharing, advanced safe-route preferences.
- **Institutional Licences**: per residence complex, corporate, or retailer/BID — a white-label dashboard, staff/resident analytics, priority moderation queueing.
- **"SafeHer Active Zone" sponsorships**: recurring or once-off, for local retailers/BIDs.
- Card and banking details are captured only on the payment provider's own hosted page — SafeHer never receives or stores raw card/bank details.
- If a subscription lapses, the account drops to the free tier at the next billing boundary — geofence alerts and the panic pipeline **stay available regardless of payment status.**

### 4.11 Preview Mode
Reachable from the app's first screen with no account, login, or sensitive permission grant. It renders a fixed, seeded mock dataset — mock hotspots across real Bloemfontein areas, mock emergency facilities, a simulated (non-GPS) position — and lets anyone walk through the full geofence countdown and every panic-trigger path with every "send" simulated and clearly labelled as such. A role switcher lets a reviewer, pilot partner, or institutional buyer see the primary-user, next-of-kin, moderator, and institutional-admin views before any real account exists.

---

## 5. What's honestly built vs. planned

This project has a binding rule from an external moderator review: *scope down, treat panic and data as safety-critical, and never claim a capability that hasn't been proven on real hardware.* That rule shapes the tiering below.

| Tier | Features | What that means in practice |
|---|---|---|
| **Core (claimed as working)** | Hotspot map + reporting, geofence alert + 60s countdown, manual panic button → next-of-kin only, next-of-kin management, Preview Mode | These are demoed and judged as working today. They must be reliable, honestly described, and fail loudly, not silently. |
| **Experimental (built, not claimed)** | Voice trigger, fall detection, live GPS-driven geofencing | Present in the build, off by default, always labelled as unverified on real hardware wherever shown in the UI. |
| **Not built for MVP (roadmap)** | Power-button triple-press, routing, moderation tooling, push notifications, subscriptions/PayFast, the web dashboard, the FastAPI backend | Specified as the product roadmap. Never implied to exist in a pilot or a judged submission. |

---

## 6. Data model, at a glance

- **Hotspot** — location, category, severity, reporter, timestamp, verification status.
- **User** — account and profile data.
- **Emergency Contact** — the next-of-kin list, priority-ordered.
- **PanicEvent** — location, timestamp, trigger type, status.
- **EmergencyFacility** — police/hospital/clinic, location, contact number.

---

## 7. Non-functional commitments (the promises that don't show up as a feature)

- **Battery** — background geofencing never relies on continuous GPS polling.
- **Privacy** — the voice trigger's keyword spotting runs entirely on-device; no raw audio is ever streamed or persisted. Live location is opt-in only, and visible to next of kin only during an active alert — never persistent tracking.
- **Resilience** — the app degrades gracefully offline (cached map, WhatsApp fallback instead of a failed call).
- **Security** — access control is enforced in backend security rules, never trusted to client-side checks alone; API keys and telephony credentials live server-side, never bundled into the client.
- **Compliance** — location and personal data handling is built around South Africa's POPIA requirements: opt-in sharing, minimal retention, no persistent tracking.
- **Honesty as a system property** — every failure mode (e.g. no next-of-kin configured) is surfaced to the user immediately, not just logged for later discovery.

---

## 8. What makes it different from a generic mapping or SOS app

- It's a **push model, not a pull model** — it warns automatically as you approach danger, rather than waiting for you to open the app or press a button.
- It's **hands-free by design** — voice, fall detection, and (planned) power-button triggers all work without unlocking the phone, for the moment when reaching for a screen isn't safe.
- It **never overclaims** — the app states plainly, in the same screen as the panic trigger, that it reaches next-of-kin only and does not notify police, and prompts the user to do that herself.
- It's **hyperlocal by design** — built and tuned for Bloemfontein's specific corridors first, rather than spread thin across a whole country.
