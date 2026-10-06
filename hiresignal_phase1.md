# HireSignal — Phase 1 Plan: Signal Validation

## Goal

Prove that publicly available structured signals can predict hiring intent with useful accuracy. By Week 8, a working system tracks 50 Indian tech companies, collects signals daily, scores them, and shows matched results in a Flutter app.

## Repo Structure

Two repositories on `~/Desktop`:

| Path | Role |
|---|---|
| `~/Desktop/hiring_intent/` | **Flutter frontend** (this repo). Specs: `hiresignal_phase1.md`, `hiresignal_frontend.md`. |
| `~/Desktop/hiresignal_backend/` | **FastAPI backend**. Spec: `hiresignal_backend.md`. |

Database and auth live in **Supabase** (single project, shared by both).

## Success Criteria

- [ ] 50+ companies actively tracked with daily signal updates
- [ ] At least 4 signal sources producing data (ATS APIs, RSS, GitHub, HN)
- [ ] Validation harness reports `precision_at_10 ≥ 0.6` for 2 consecutive weeks
- [ ] Flutter app displays matches with ≥ 70% tech-fit accuracy for the user's stack
- [ ] End-to-end pipeline runs daily on GitHub Actions without manual intervention

---

## Architecture Overview

```
Flutter App  ──reads──▶  Supabase (DB + Auth + Realtime)
     │                        ▲
     └──writes──▶  FastAPI ───┘       (hosted: Render free tier, web only)
                     ▲
                     │ invokes jobs via HTTP admin endpoints (optional)
                     │
             GitHub Actions cron ──runs──▶  app/jobs/run_*.py
                                            (ATS, RSS, GitHub, HN, Wappalyzer, scoring)
```

**Hosting:**
- FastAPI → Render free tier (web only)
- Database + Auth + Realtime → Supabase free tier
- Scheduled collectors → GitHub Actions cron (free for public repo, 2,000 min/month for private)
- Claude API → pay-as-you-go (~$10–15/month)
- Flutter → local dev / TestFlight / internal track

> No Redis, no Celery, no Render worker. Phase 1 is designed to run at $0 infra cost outside the Claude API bill.

---

## Week-by-Week Plan

### Week 1 — Foundation

**Backend repo + database schema**

Tasks:
- [ ] Backend repo already exists at `~/Desktop/hiresignal_backend/`. Initialize FastAPI project per `hiresignal_backend.md`.
- [ ] Configure Supabase project
  - Create tables: `companies`, `intent_signals`, `stack_signals`, `company_scores`, `users`, `matches`, `validation_snapshots`
  - Enable Row Level Security (RLS) policies per the backend spec
  - Set up Supabase Auth (email + Google)
- [ ] Alembic baseline migration
- [ ] SQLAlchemy models for all 7 tables
- [ ] Pydantic schemas for request/response
- [ ] `GET /health` endpoint
- [ ] Supabase JWT verification dependency (`app/auth.py`)
- [ ] `docker-compose.yml` for local dev (FastAPI only, no Redis)
- [ ] Seed script `scripts/seed_companies.py` for 50 Indian tech companies
- [ ] ATS discovery helper `scripts/discover_ats.py` — fetches a careers URL and guesses which ATS (checks for `boards.greenhouse.io`, `jobs.lever.co`, `jobs.ashbyhq.com`, `apply.workable.com`, `jobs.smartrecruiters.com` patterns)

**Seed company list (50 companies):**
```
FinTech:     Razorpay, PhonePe, Cred, Zerodha, Groww, Jupiter, Rupeek
E-commerce:  Meesho, Flipkart, Myntra, Nykaa, Lenskart
Delivery:    Swiggy, Zomato, Dunzo, Blinkit, Zepto
EdTech:      Unacademy, PhysicsWallah, Vedantu, Scaler
SaaS:        Freshworks, Zoho, Postman, BrowserStack, Chargebee
Health:      Practo, PharmEasy, Healthkart
Mobility:    Ola, Rapido, Bounce
Social:      ShareChat, Koo, Josh
AI/ML:       Sarvam AI, Krutrim, Yellow.ai
Others:      Dream11, MPL, Urban Company, Licious
```

For each company, record:
`name`, `domain`, `careers_url`, `ats_type` (discovered), `ats_slug` (discovered), `github_org`, `industry`, `location`, `employee_count` (approximate).

> **Expect ~70–80% to map to a known ATS.** Workday / Darwinbox companies get `ats_type='other'` and are flagged for Phase 2.

**Deliverables:**
- Running FastAPI server locally
- Supabase with schema + RLS + 50 seeded companies (with ATS mapping)
- `GET /health` returns OK

---

### Week 2 — ATS Adapter Pipeline (replaces the old "Career Page Scraper" week)

**Build 5 ATS adapters + ingest + stack extraction.**

Tasks:
- [ ] `collectors/base.py` — `BaseCollector` abstract class with rate limiting (0.5 req/sec per domain)
- [ ] `collectors/ats/base.py` — `ATSAdapter` abstract class returning normalized job dicts
- [ ] Implement 5 adapters, one file each:
  - `greenhouse.py` — `boards-api.greenhouse.io/v1/boards/{slug}/jobs?content=true`
  - `lever.py` — `api.lever.co/v0/postings/{slug}?mode=json`
  - `ashby.py` — `api.ashbyhq.com/posting-api/job-board/{slug}?includeCompensation=true`
  - `workable.py` — `apply.workable.com/api/v3/accounts/{slug}/jobs`
  - `smartrecruiters.py` — `api.smartrecruiters.com/v1/companies/{slug}/postings`
- [ ] `collectors/ats/registry.py` — dispatches by `company.ats_type`
- [ ] `app/jobs/run_ats.py` — iterate active companies, call adapter, write to tables:
  - Count of open roles → one row in `intent_signals(signal_type='ats_job')` with `confidence=min(1.0, count/5)`
  - Each job description → Claude Haiku stack extraction → `stack_signals(source_type='ats_job_nlp')`
- [ ] `processors/llm_classifier.py` — Claude Haiku integration
  - `classify_signal()` and `extract_stack()` prompts (from backend spec)
  - Model IDs: `claude-haiku-4-5` default, `claude-sonnet-4-6` for descriptions > 2,000 chars
  - Retry 3× with exponential backoff, parse JSON, log failures
- [ ] API endpoints:
  - `GET /api/v1/companies` (list with scores)
  - `GET /api/v1/companies/{id}` (detail with joined signals)
  - `GET /api/v1/companies/{id}/signals`
- [ ] Manual test: run `python -m app.jobs.run_ats` locally against 10 companies, verify rows land in Supabase

**Why this replaces career-page scraping:** every modern ATS has a public JSON board. One `httpx.get()` returns structured data (title, department, location, description, posted_at) — no HTML parsing, no JS rendering, no CAPTCHA risk, no ToS gray area.

**Deliverables:**
- 5 working ATS adapters
- `intent_signals` and `stack_signals` populated for ≥ 30 companies (those with known ATS)
- API endpoints returning joined data

---

### Week 3 — RSS, HN, GitHub, Wappalyzer

**Add four more collectors in parallel.**

Tasks:
- [ ] `collectors/rss_scraper.py`
  - Feeds: `inc42.com/feed/`, `entrackr.com/feed/`, `yourstory.com/feed`
  - For each entry, fuzzy-match company name → send summary to Claude Haiku for `has_hiring_signal` classification
  - Write to `intent_signals` with `signal_type='funding'` or `'news'`
- [ ] `collectors/github_scraper.py`
  - PyGithub to list org repos
  - Parse dependency files via `DEPENDENCY_MAP` + `PACKAGE_TECH_MAP` (no LLM needed)
  - Write to `stack_signals(source_type='github')`
  - **Also write intent:** new repo in last 30 days OR contributor-count delta > 20% → `intent_signals(signal_type='github_activity')`
- [ ] `collectors/hn_whos_hiring.py`
  - HN Algolia API: find latest "Ask HN: Who is hiring?" story
  - Fetch all comments, pass each to Claude Haiku for company/location/remote/techs/roles extraction
  - Resolve-or-create companies, write intent + stack signals
- [ ] `collectors/wappalyzer_scraper.py`
  - `python-Wappalyzer` against `company.domain`
  - Write detected techs to `stack_signals(source_type='wappalyzer')` with confidence 0.7
- [ ] Standalone job entry points in `app/jobs/`
- [ ] GitHub Actions workflows (all under `.github/workflows/`):
  - `scrape-ats.yml` — daily 06:00 IST
  - `scrape-rss.yml` — daily 08:00 IST
  - `scrape-github.yml` — Mon + Thu 07:00 IST
  - `scrape-hn.yml` — monthly, 1st of month
  - `scrape-wappalyzer.yml` — monthly, 1st of month
- [ ] Deploy FastAPI to Render (`render.yaml`, web only — no worker)
- [ ] Verify at least one GitHub Actions run completes successfully end-to-end

**Deliverables:**
- 4 additional collectors live, writing to Supabase on cron
- FastAPI live on Render
- 50 companies accumulating signals from 5 sources (ATS + RSS + GitHub + HN + Wappalyzer)

---

### Week 4 — Scoring, Matching, Validation Harness

**Turn raw signals into actionable scores. Set up the Phase 1 success metric.**

Tasks:
- [ ] `processors/scoring_engine.py`
  - `calculate_intent_score(signals)` with weights `{ats_job: 40, funding: 30, hn_whos_hiring: 15, news: 10, github_activity: 5}`
  - Exponential decay per signal type (see backend spec)
  - Write to `company_scores.intent_score`
- [ ] `processors/stack_fingerprinter.py`
  - Aggregate `stack_signals` per technology
  - Take `max(confidence)` across sources, capped by source: `github ≤ 1.0`, `ats_job_nlp ≤ 0.9`, `wappalyzer ≤ 0.7`, `hn_whos_hiring ≤ 0.8`
  - Write to `company_scores.stack_fingerprint`
- [ ] `processors/match_engine.py`
  - `calculate_tech_fit()` = cosine similarity of user skill vector vs stack fingerprint
  - `compute_match_score()` = `0.4 × intent_score + 0.6 × tech_fit × 100`
  - Generate matches per user, write to `matches` with `top_signals` (top 3)
- [ ] `app/jobs/run_scoring.py` and `.github/workflows/score.yml` — daily 10:00 IST
- [ ] API endpoints:
  - `POST /api/v1/users/profile`
  - `GET /api/v1/matches?min_score=30&min_tech_fit=0.5&limit=20`
  - `POST /api/v1/matches/refresh`
- [ ] **Validation harness:**
  - `app/jobs/run_validation.py` — snapshot top-20 companies into `validation_snapshots` weekly
  - `.github/workflows/validate.yml` — Monday 08:30 IST
  - Document the manual labeling procedure (Supabase SQL editor, 14-day lag, fill `labels` and compute precision)
- [ ] First manual validation pass: label the Week 4 snapshot's companies against reality

**Deliverables:**
- Scoring + matching running on cron
- First `validation_snapshots` row with labels + precision numbers
- Match API returning real data for a test user

---

### Week 5 — Flutter App: Core + Auth

**Flutter frontend lives in this repo (`~/Desktop/hiring_intent/`). Clean architecture + flutter_bloc + go_router + get_it + http.**

Tasks:
- [ ] Replace `pubspec.yaml` dependencies per `hiresignal_frontend.md`
- [ ] Set up directory structure: `lib/core/` + `lib/features/{auth,onboarding,matches,company_detail,profile}/{data,domain,presentation}/`
- [ ] `core/` scaffolding:
  - `core/di/injection.dart` + `injection.config.dart` — `get_it` + `injectable` setup
  - `core/network/api_client.dart` — `http`-based client with Supabase JWT injection
  - `core/network/supabase_client.dart` — Supabase SDK instance
  - `core/router/app_router.dart` — `go_router` config with auth redirect
  - `core/theme/app_theme.dart` — Material 3 light + dark
  - `core/error/failures.dart` + `exceptions.dart`
- [ ] **Auth feature** (full clean-arch slice):
  - `data/datasources/auth_remote_datasource.dart` — Supabase auth calls
  - `data/repositories/auth_repository_impl.dart`
  - `domain/entities/auth_user.dart`
  - `domain/repositories/auth_repository.dart` (abstract)
  - `domain/usecases/sign_in_with_email.dart`, `sign_up_with_email.dart`, `sign_in_with_google.dart`, `sign_out.dart`, `watch_auth_state.dart`
  - `presentation/bloc/auth_bloc.dart` (events: `SignInRequested`, `SignUpRequested`, `GoogleSignInRequested`, `SignOutRequested`, `AuthStateChanged`; states: `AuthInitial`, `AuthLoading`, `Authenticated`, `Unauthenticated`, `AuthFailure`)
  - `presentation/pages/login_page.dart`, `signup_page.dart`, `splash_page.dart`
- [ ] **Onboarding feature** (skill setup):
  - `domain/entities/user_profile.dart`, `skill.dart`
  - `domain/usecases/save_profile.dart`
  - `data/datasources/profile_remote_datasource.dart` — POST to FastAPI
  - `presentation/bloc/onboarding_bloc.dart`
  - `presentation/pages/skill_setup_page.dart` with proficiency sliders
- [ ] Shared widgets: `score_badge.dart`, `tech_chip.dart`, `loading_shimmer.dart`

**Deliverables:**
- Flutter app with working auth (email + Google via Supabase)
- Skill-setup flow writing to FastAPI `/users/profile`
- Clean architecture scaffolding ready for subsequent features

---

### Week 6 — Flutter App: Matches

**Core screen — ranked company matches.**

Tasks:
- [ ] **Matches feature:**
  - `domain/entities/match.dart`, `company_summary.dart`, `signal_summary.dart`
  - `domain/repositories/matches_repository.dart`
  - `domain/usecases/get_matches.dart`, `watch_matches.dart`, `refresh_matches.dart`, `update_match_status.dart`
  - `data/models/*` — JSON serialization (`json_serializable`)
  - `data/datasources/matches_remote_datasource.dart` — Supabase realtime stream + FastAPI calls
  - `data/repositories/matches_repository_impl.dart`
  - `presentation/bloc/matches_bloc.dart` (streams-based)
  - `presentation/pages/matches_page.dart`
  - `presentation/widgets/match_card.dart`, `filter_sheet.dart`
- [ ] `HomeShell` with bottom nav (Matches / Profile; Feed is Phase 2 placeholder)
- [ ] Pull-to-refresh triggers `RefreshMatchesRequested`
- [ ] Swipe-to-dismiss updates match status via FastAPI
- [ ] Empty state + shimmer loading state

**Deliverables:**
- Matches screen showing real ranked companies via Supabase realtime
- Status updates (dismiss / save) syncing to backend
- Filter sheet for min score / min tech fit

---

### Week 7 — Flutter App: Company Detail + Profile

**Deep-dive screen and profile editor.**

Tasks:
- [ ] **Company detail feature:**
  - `domain/entities/company_detail.dart`, `intent_signal.dart`, `stack_signal.dart`
  - `domain/usecases/get_company_detail.dart`
  - `data/datasources/company_remote_datasource.dart` — Supabase joined query
  - `presentation/bloc/company_detail_bloc.dart`
  - `presentation/pages/company_detail_page.dart`
  - `presentation/widgets/signal_timeline.dart`, `stack_comparison.dart`, `score_bar.dart`
- [ ] **Profile feature:**
  - Reuse onboarding entities + usecases
  - `presentation/pages/profile_page.dart`, `edit_skills_page.dart`
  - `presentation/bloc/profile_bloc.dart`
- [ ] Navigation wiring: match card tap → `/company/:id`; profile → `/profile/edit-skills`

**Deliverables:**
- Full company detail view: header, stack comparison, signal timeline
- Profile view + edit flow
- Phase 1 app flow complete end-to-end: login → skills → matches → detail

---

### Week 8 — Validate, Harden, Document

**Measure accuracy. Fix the biggest gaps.**

Tasks:
- [ ] Second + third validation pass (we now have 3 snapshots: Week 4, Week 6, Week 8). Compute precision_at_10 and precision_at_20 across all three.
- [ ] For top-20 companies in the latest snapshot, manually verify:
  - Do they actually have open positions? (ATS board + LinkedIn Jobs cross-check)
  - Is the detected tech stack correct? (compare against ≥ 3 actual job listings)
- [ ] Tune based on validation:
  - If `precision_at_10 < 0.5`: adjust `SIGNAL_WEIGHTS`, or improve a weak collector
  - If stack accuracy < 70%: tune Claude extraction prompt or raise `source_type='github'` priority
- [ ] Hardening:
  - Error handling in every collector (log and continue, never crash the job)
  - Sentry on both FastAPI and Flutter
  - Retry logic in Claude calls (3× exponential backoff)
  - Idempotency: collectors must be safe to re-run on the same day
- [ ] READMEs:
  - Backend: setup, env vars, how to run a single collector, how to add a company
  - Frontend: setup, build with `--dart-define` env vars, architecture summary
- [ ] Phase 2 backlog documentation:
  - Workday / Darwinbox companies (need Playwright or paid scraping API)
  - LinkedIn headcount + key departures (need Apollo / PDL)
  - APK analysis (need APK sourcing solution)
  - Signal feed screen, push notifications, offline cache

**Deliverables:**
- Validation report with 3 weeks of precision data
- Both repos stable, documented, deployed
- Explicit Phase 2 backlog with cost/complexity notes

---

## Daily Pipeline Execution Order (GitHub Actions)

```
06:00 IST — scrape-ats.yml           (~15 min)
07:00 IST — scrape-github.yml        (Mon + Thu only, ~10 min)
08:00 IST — scrape-rss.yml           (~5 min)
10:00 IST — score.yml                (~2 min)
08:30 Mon — validate.yml             (~1 min, weekly)
1st of month, 10:30 IST — scrape-wappalyzer.yml
1st of month, 11:30 IST — scrape-hn.yml
```

Flutter app receives updates via Supabase realtime subscriptions — no polling needed.

---

## Risk Mitigation

| Risk | Mitigation |
|---|---|
| ATS adapter breaks (API change) | Each adapter is isolated; test suite hits a sample response fixture. One broken adapter doesn't block others. |
| Workday / Darwinbox companies unreachable | Explicitly flagged `ats_type='other'`; excluded from `ats_job` signal; move to Phase 2 with Playwright. |
| Claude API cost spikes | Use `claude-haiku-4-5` for bulk; cap at 1,500 calls/day via a counter in Redis-less in-process limit. |
| Render free tier sleeps | Only affects first request per 15 min cold-start. GitHub Actions scrapers don't depend on Render being awake. |
| Low signal accuracy | Validation harness surfaces this weekly. Tune weights or collectors. Exit criterion is explicit. |
| Supabase free tier limits | 500 MB DB, 2 GB bandwidth. 50 companies ≈ 50 MB. Headroom to 500+ companies. |
| GitHub Actions minute limit | 2,000 min/mo for private. All jobs together < 400 min/mo. Public repo = unlimited. |
| GitHub API rate limit (dependency reads) | 5,000 req/hr with token. 50 companies × 5 repos = 250 req. Safe. |
| HN Algolia API rate limits | None documented at low volume. Monthly use = < 50 requests. |

---

## Cost Summary (Phase 1)

| Service | Monthly Cost |
|---|---|
| Supabase | Free |
| Render (web only) | Free |
| GitHub Actions | Free (public) or 2,000 min included (private) |
| Claude API | ~₹800–1,200 ($10–15) |
| GitHub API | Free |
| Wappalyzer | Free (self-hosted) |
| Inc42 / Entrackr / YourStory RSS | Free |
| HN Algolia API | Free |
| **Total** | **~₹800–1,200 ($10–15) / month** |

> Previous plan budgeted ~₹5,500 (SerpAPI, Adzuna, worker dyno). Removing those saves ~₹4,000/month.

---

## What Phase 1 Does NOT Include (Deferred)

- APK binary analysis (`androguard`) — Phase 2 (blocker: APK sourcing)
- Playwright for Workday / Darwinbox career pages — Phase 2
- LinkedIn headcount + key-departure detection — Phase 2 (needs paid data provider: Apollo, PDL)
- Celery + Redis — not needed for Phase 1
- Push notifications — Phase 2
- Signal feed screen in Flutter — Phase 2
- Offline cache — Phase 2
- "Mark as Applied" workflow with tracking — Phase 2
- Multi-user onboarding — Phase 1 is single-user validation
- Admin dashboard — Phase 2
- Company logo fetching (Clearbit) — Phase 2
