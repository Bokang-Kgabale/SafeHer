# External API Research — Police, Protective Services & Telecom/ISP

**Purpose:** Identify what real external channels (police, private protective services, MTN/Vodacom/Telkom, other providers) SafeHer could actually integrate with for the MVP demo and pitch, without violating the §2.8 rule in `SafeHer_SRS.md` (no claiming automatic police/emergency dispatch until a real channel exists).

**Date:** 2026-09-25
**Bottom line up front:** There is no public SAPS API and no open "get a subscriber's live GPS location" API from any SA telco. There **is** a real, integrable dispatch layer — **AURA** — that already sits behind FNB, Outsurance, King Price, Momentum, Namola and Uber's panic features. That's the one channel worth pursuing for a genuine "escalates beyond next-of-kin" claim. Everything else below is either messaging plumbing (useful, low-risk) or data/precision add-ons (nice for the demo, not a dispatch channel).

---

## 1. Police / government

### SAPS (South African Police Service)
- **No public API.** No developer portal, no crime-reporting or dispatch endpoint.
- **Crime Stop** — anonymous tip-off line/app ("My SAPS", iOS/Android), not a machine-callable integration.
- **Crime statistics** are released quarterly as PDF/spreadsheet downloads at [saps.gov.za/services/crimestats.php](https://www.saps.gov.za/services/crimestats.php) — useful only as historical hotspot-seeding data (see §5), not real-time, not an incident API. Several community projects (e.g. [afrith/crime-stats](https://github.com/afrith/crime-stats), [looda-devv/docket](https://github.com/looda-devv/docket)) have already scraped/normalized these into CSV/GeoParquet if you want seed data for Preview Mode or the map's historical layer.
- **Integrated Justice System (IJS)** connects SAPS to courts/NPA/Home Affairs internally — not third-party accessible.
- **Conclusion:** confirms the SRS's existing position. There is nothing to integrate here; don't spend engineering time looking for one.

---

## 2. Private protective-services dispatch (the actually-viable channel)

### AURA — [aurasos.com](https://www.aurasos.com/en-za/technology/integrations)
This is the significant find. AURA is the backend response layer that already powers **Namola, FNB GuardMe, VodaSure, Outsurance, King Price, Miway, Momentum**, and Uber's in-app panic feature in South Africa. It aggregates armed response and medical responder networks so an app doesn't need its own fleet or MOU with every security company individually.

- **Integration models offered:**
  1. Custom API — you POST trigger/user/location/incident data, AURA dispatches, user stays in your branded UI.
  2. White-label app — AURA-built app with your branding.
  3. Pre-built components — web dispatch tracking, phone/SMS fallback for users without the app.
- **Access path:** book a demo → sandbox credentials + responder simulator → QA review → production. No public self-serve signup or published pricing.
- **Fit for SafeHer:** this is the one path that could honestly upgrade "escalate to next-of-kin" into "escalate to a monitored private-response network" — but it requires a commercial relationship (demo call, likely a contract/cost per user or per dispatch), not something wired up in an afternoon. **Worth a discovery call before the pitch**, even if MVP doesn't ship the integration — "in discussion with AURA" is a materially stronger pitch line than nothing, as long as it's stated as exactly that and not implied to be live.
- Namola itself (now owned by AURA, after MultiChoice sold it in 2025) is a direct competitor/reference product worth studying for UX, not itself a channel to integrate against.

### ER24 / Netcare 911 (medical/ambulance)
- No public developer API found. ER24's integration story with third parties (e.g. what3words, below) is done via direct partnership with their contact centre, not a documented REST API.
- **Conclusion:** same pattern as AURA — a phone call to their business development team, not a self-serve integration, and not realistic to land before an MVP demo unless already in motion.

---

## 3. Location precision — what3words

- SA's own ER24 already accepts what3words addresses in emergency calls, and Vodacom zero-rates what3words data for all subscribers (since 2020) — so a what3words location string is something SA emergency responders are already trained to use.
- **API exists and is developer-accessible**: [what3words.com/business/emergency](https://what3words.com/business/emergency) — free/discounted tier for emergency-response use cases historically; standard commercial API otherwise. Converts GPS ↔ 3-word address.
- **Fit for SafeHer:** cheap, low-risk, genuinely useful addition — display a what3words address alongside GPS in the panic payload sent to next-of-kin (and to AURA/ER24 if that integration ever lands). It's a real, working piece of SA emergency infrastructure you can cite honestly in the pitch, unlike a police API.

---

## 4. Telecom/ISP APIs (MTN, Vodacom, Telkom)

**Key finding, stated plainly for the pitch:** none of the three give third-party apps a "fetch this subscriber's live location" API. Real-time cell-tower/GPS location lookup by a random app is not something SA carriers expose publicly — that capability is normally reserved for lawful-interception requests from law enforcement, not consumer apps. Don't imply otherwise in the demo.

### MTN Developer Portal — [developers.mtn.com](https://developers.mtn.com/)
- SMS API (v1/v2/v3), USSD interface, and a "Locations API" (`mtn-customer-locations-api-v1`) whose actual scope isn't documented publicly (Swagger spec is gated behind app registration) — **needs a direct email to Madapi-apigeex@mtn.com to confirm what it actually returns before citing it as a capability.** Don't assume it's subscriber GPS.
- Self-serve developer registration exists; browsing docs doesn't require an account, creating an app does.

### Vodacom APIPulse — [apipulse.vodacom.co.za](https://apipulse.vodacom.co.za/)
- Communications/SMS API that can send to any SA network, not just Vodacom numbers, with delivery receipts.
- Self-serve "test drive" registration model, similar to MTN's.

### Telkom
- No equivalent modern self-serve developer portal was found; third-party aggregators (Messaggio, EasySendSMS, Celcom Africa) resell SMS/WhatsApp delivery onto Telkom Mobile numbers instead.

### GSMA Open Gateway (Cell C + MTN + Telkom, launched Feb 2024)
- **Number Verification** and **SIM Swap** APIs — fraud-prevention tools (confirm a number is genuinely active on that handset / hasn't just been SIM-swapped). Genuinely useful for **NOK phone-number verification at signup** (cheap anti-abuse check), but this is *not* a location or dispatch API — don't conflate the two in the pitch.

### Practical takeaway
For the MVP, the only telecom-API capability worth actually wiring up is **outbound SMS/WhatsApp delivery** for the next-of-kin fallback already specified in `FR-PANIC-2`. That's a solved, boring problem — Twilio (already named in the SRS) or a local reseller (Clickatell, BulkSMS) both work; there's no reason to build directly against MTN/Vodacom's raw SMS APIs unless cost at scale becomes the deciding factor later.

---

## 5. Messaging/SMS gateways (for the next-of-kin fallback, `FR-PANIC-2`)

| Provider | Notes |
|---|---|
| **Twilio** | Already the SRS's stated choice. International, well-documented, WhatsApp Business API + voice call + SMS in one integration. Best for an MVP demo — fastest to wire up, works today. |
| **Clickatell** | South African company, docs at [docs.clickatell.com](https://docs.clickatell.com/). Authorized WhatsApp Business Solution Provider. Worth a cost comparison for post-MVP if SA-only traffic makes Twilio pricier. |
| **BulkSMS.com / EasySendSMS / Celcom Africa** | Local SMS resellers with REST APIs across all SA networks. Fallback options, not differentiators. |

No reason to change the SRS's existing Twilio choice for MVP — this section just confirms local alternatives exist if pricing/reliability becomes an issue later.

---

## 6. What this means for the pitch/demo

Things you can **honestly claim** are backed by real, integrable APIs:
- Next-of-kin SMS/WhatsApp/call escalation (Twilio — live today).
- Optional what3words location string alongside GPS coordinates (real SA emergency-response convention, cheap to add).
- NOK phone-number sanity-check at signup via GSMA Open Gateway Number Verification (nice-to-have, not core).
- Historical SAPS crime-stats data as seed/context data for the map or Preview Mode (static download, not live).

Things that require an actual business conversation before they can be claimed as anything beyond roadmap:
- **AURA integration** — the one path to a genuine "beyond next-of-kin" escalation story. Recommend booking their demo call regardless of whether it lands before the hackathon deadline — "in active discussion with AURA, South Africa's private-response aggregator behind FNB/Outsurance/Namola" is a strong, honest, verifiable line for a pitch deck.
- ER24/Netcare 911 direct integration — same pattern, lower priority than AURA since AURA already aggregates medical response.

Things that **do not exist** and shouldn't be implied even loosely:
- A SAPS API of any kind.
- A telco API that hands a third-party app a subscriber's live location without that subscriber authenticating directly in your own app (your own GPS permission flow already solves this — you don't need a carrier API for it).

---

## Sources
- [MTN Developer Portal](https://developers.mtn.com/) / [SMS v3 API](https://developers.mtn.com/products/sms-v3-api) / [Locations API](https://developers.mtn.com/products/mtn-customer-locations-api-v1)
- [Vodacom APIPulse](https://apipulse.vodacom.co.za/) / [Communications API](https://apipulse.vodacom.co.za/api/26)
- [GSMA — SA operators Open Gateway fraud APIs](https://www.gsma.com/newsroom/press-release/south-african-mobile-operators-announce-new-services-to-combat-fraud-as-part-of-gsma-open-gateway-initiative/)
- [SAPS Crime Statistics](https://www.saps.gov.za/services/crimestats.php) / [My SAPS app](https://play.google.com/store/apps/details?id=co.za.vodacom.boxfusion.saps)
- [AURA — Emergency Response API & Platform Integrations](https://www.aurasos.com/en-za/technology/integrations) / [AURA People Protect](https://www.aurasos.com/en-za/people-protect)
- [MyBroadband — Namola/AURA panic button funding](https://mybroadband.co.za/news/security/601640-south-african-panic-button-company-that-saves-50-lives-a-month-secures-r439-million-for-us-expansion.html)
- [what3words Emergency & Recovery](https://what3words.com/business/emergency) / [ER24 partners with what3words](https://what3words.com/news/emergency/south-africas-national-emergency-service-partners-with-what3words-for-a-faster-response) / [Vodacom zero-rating](https://what3words.com/news/emergency/free-data-access-vodacom-south-africa)
- [Clickatell Developer Docs](https://docs.clickatell.com/)
- [RapidDeploy (SA-founded, now US-focused 911 CAD, acquired by Motorola Solutions 2025)](https://disruptafrica.com/2025/02/26/sa-founded-public-safety-startup-rapiddeploy-acquired-by-motorola-solutions/) — not SA-market relevant anymore, included for context only.
