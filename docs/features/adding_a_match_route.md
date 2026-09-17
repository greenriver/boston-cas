# Adding a Match Route

A match route is the ordered set of decisions a match moves through, who acts on each one, and who gets notified. Routes are Ruby classes; the database row (`match_routes`, STI on `type`) only holds admin-editable toggles. This document lists every file a new route needs, using route fourteen (built 2026-09) as the worked example. Copy route fourteen, or the route named as the template in each section.

## Mental model

```
MatchRoutes::<Name>              ordered steps, actor labels, reveal rules
  └─ MatchDecisions::<Name>::*   one class per step (+ one *Decline class per declinable step)
       ├─ Notifications::<Name>::*   who is emailed when a step starts
       │    └─ NotificationsMailer#<notification_type> + text.haml template
       └─ app/views/match_decisions/<name>/_<step>.haml   the decision page
db/seeds/match_decision_reason_assignments.csv           decline/cancel reasons per step
StalledResponse.all_responses                            stall responses per stallable step
```

The route row is created inactive by `MatchRoutes::Base.ensure_all` (run by `rake cas_seeds:seed_match_decision_reason_assignments` and by `spec_helper`). Activate it and pick a prioritization in Admin → Match Routes. No migration is needed unless a step adds a new column.

## Checklist

| # | What | Path | Copy from | Route 14 count |
|---|---|---|---|---|
| 1 | Route class | `app/models/match_routes/<name>.rb` | `fourteen.rb` | 1 |
| 2 | Register it | `MatchRoutes::Base.all_routes` in `app/models/match_routes/base.rb` | append one line | 1 line |
| 3 | Decision base | `app/models/match_decisions/<name>/base.rb` | `fourteen/base.rb` (route-wide `accessible_by?`) | 1 |
| 4 | Forward steps | `app/models/match_decisions/<name>/<name>_<step>.rb` | `fourteen_initiate_match.rb` (DND start), `fourteen_match_acknowledgement.rb` (shelter agency ack), `fourteen_eligibility_screening.rb` (declinable + stallable), `fourteen_confirm_match_success.rb` (end) | 7 |
| 5 | Decline review steps | `app/models/match_decisions/<name>/<name>_<step>_decline.rb` | `fourteen_eligibility_screening_decline.rb` | 5 |
| 6 | Match accessors | `app/models/concerns/route_<name>_decisions.rb` + `include Route<Name>Decisions` in `app/models/client_opportunity_match.rb` | `route_fourteen_decisions.rb` | 12 `has_decision` lines |
| 7 | Notifications | `app/models/notifications/<name>/*.rb` | `fourteen/fourteen_eligibility_screening_hsp.rb` (actor), `..._fyi.rb` (everyone else), `..._decline.rb` | 18 |
| 8 | Mailer methods | `app/mailers/route_<name>_mailer_methods.rb` + `include` in `app/mailers/notifications_mailer.rb` | `route_fourteen_mailer_methods.rb` | 18 methods |
| 9 | Mail templates | `app/views/notifications_mailer/<notification_type>.text.haml` (flat, no subfolder) | `fourteen_eligibility_screening_hsp.text.haml` | 18 |
| 10 | Decision pages | `app/views/match_decisions/<name>/_<partial>.haml`, one per `to_partial_path` | see "Views" below | 12 |
| 11 | Reasons | rows in `db/seeds/match_decision_reason_assignments.csv`, then `rake cas_seeds:seed_match_decision_reason_assignments` | route 14 rows | 12 |
| 12 | Stall responses | add stallable step class names to `steps:` arrays in `app/models/stalled_response.rb`, then `StalledResponse.ensure_all` | route 14 entries | 10 arrays |
| 13 | Docs | this file: add a "Route N specifics" section | | |

## The route class

Required overrides (`MatchRoutes::Base` raises `NotImplementedError` otherwise): `title`, `untranslated_title`, `initial_decision`, `success_decision`, `initial_contacts_for_match`, `status_declined?(match)`, and class methods `match_steps`, `match_steps_for_reporting`, `available_sub_types_for_search`.

- `match_steps` lists forward steps only, numbered from 1. `MatchDecisions::Base#next_step` walks it.
- `match_steps_for_reporting` interleaves each `*Decline` step directly after the step it reviews and must be gap-free; the current-step and client-reveal logic index into it.
- `status_declined?` is one `declined && paired decline step != 'decline_overridden'` pair per declinable step.
- `contact_label_for(type)` returns `Translation.translate('<Role> <Name>')`. Translation keys self-register on first use; do not add them to `Translation.all`.

## Decisions

Each step class sets `to_partial_path`, `step_name`, `actor_type`, `contact_actor_type`, `notifications_for_this_step`, `statuses`, `label_for_status`, `initialize_decision!`, and a private `StatusCallbacks` class whose method names are the statuses. `Base#initialize_decision!` resets the stall clock, so always call `super`.

Knobs:

- **Declinable**: `include MatchDecisions::AcceptsDeclineReason`, add `declined` to `statuses`, add a `declined` callback that creates `Notifications::MatchDeclined` and initializes the paired `*Decline` decision. Also add `skipped: 'Skipped'` to `statuses`, or the decline step's `decline_overridden` callback cannot mark the step skipped (`ensure_status_allowed` rejects unknown statuses silently through `update`).
- **Cancelable**: every step's `permitted_params` already includes the cancel fields. Whether a user sees the cancel tab is decided in the view by `can_reject_matches?` (a DND permission), which is how "only DND can cancel" works.
- **Stallable**: override `stallable?` to `true` and `stalled_contact_types` to the list of contact types who get stall notices. Then add the class name to `StalledResponse.all_responses` (step 12).
- **Expiring**: `expires?` true on the early steps lets the shelter-expiration banner and cancel path work.
- **Move-in date**: the route's admin toggle `show_move_in_date` is read through `MatchDecisions::Base#show_move_in_date?`. On the step that records it, add `:client_move_in_date` to `permitted_params`, validate presence on the completing status when the flag is on, and render the date picker inside `- if @decision.show_move_in_date?` (see `fourteen_confirm_match_success.rb` and its partial). The date is stored on the decision row and read by `Warehouse::BuildReport`.
- **Required contacts**: copy `ensure_required_contacts_present_on_accept` and check each contact type the route needs before accepting. To let DND fill contacts in on the first step, render `matches/match_contacts_form` above the decision form and `init_select2` at the bottom of the partial (see `fourteen/_initiate_match.haml`). Pass `required_contact_types:` (an array of contact-type symbols) to mark those fields required; define the same list as a public `required_contact_types` method on the decision so the ajax re-render in `app/views/match_contacts/*.js.erb` keeps the marks.

Decline review steps copy `fourteen_eligibility_screening_decline.rb`: statuses `pending / decline_overridden / decline_overridden_returned / decline_confirmed / canceled / back`; `decline_overridden` marks the reviewed step `skipped` and initializes the next forward step; `decline_overridden_returned` re-initializes the reviewed step and uninitializes itself; `decline_confirmed` rejects the match.

## Client-name visibility

`ClientOpportunityMatch#show_client_info_to?(contact)` decides per contact type:

- Shelter agency sees the client from `route.first_client_step` onward (a `match_steps_for_reporting` key).
- Any other contact type can be given its own reveal step by overriding `client_reveal_step_for(contact_type)` on the route (route 14: HSP from Eligibility Screening, HSA from Subsidy Administrator Screening). Return `nil` to fall back to the default rules (`contacts_editable_by_hsa`, `client_info_approved_for_release?`, the release-of-information gate used by routes Default and Thirteen).

## Notifications and mail

`Notifications::Base#notification_type` is the demodulized underscored class name. It is used three ways, so names must be globally unique across routes:

1. `NotificationsMailer#<notification_type>(notification)` must exist (the `Route<Name>MailerMethods` concern).
2. `app/views/notifications_mailer/<notification_type>.text.haml` must exist, flat in that directory. Rails resolves templates by mailer method name; a per-route subfolder does not work.
3. `has_decision ... notification_class_name:` in the route decisions concern names the actor notification for each step.

Route 14 uses one actor notification (action required) and one FYI notification (everyone else) per step, plus one DND notification per decline step. Recipients come from `self.contact_types_for_notification`.

## Views

One partial per decision under `app/views/match_decisions/<name>/`. Shared partials to compose from:

- `match_decisions/cancel_actions` — cancel/park/backup tabs for a DND-only step (Initiate Match).
- `match_decisions/decline_and_cancel_backup_actions` — decline + cancel + park + backup tabs; the cancel tab hides itself unless `can_reject_matches?`.
- `match_decisions/decline_overrides` — the DND review-decline form.
- `match_decisions/reject_actions` — Confirm Match Success's reject tab.
- `match_decisions/shelter_agency_expiration`, `match_decisions/shelter_agency_agreement`, `match_decisions/continue_button`.

Shelter-agency "indicate interest" steps must keep the standard acceptance flow: the `jNeedsToAgree` button opens `#shelter-agency-modal` and the modal's Accept button submits. Strip route-specific inputs, not the modal.

A decision with no partial passes every model spec and returns 500 in the browser. The request spec below catches that.

## Reasons and stall responses

Decline and cancel reasons are data: `MatchDecisionReasonAssignment` rows keyed on route, decision type and kind, seeded from `db/seeds/match_decision_reason_assignments.csv` (header `route_type,decision_type,kind,reason_name,position,requires_explanation,audience`; `reason_name` must exist in `db/seeds/match_decision_reasons.csv`). The seeder is create-only, so removed rows must be deleted by hand in existing databases. Admins can edit reasons afterward in Admin → Match Routes → the route → reasons.

Stall responses come from `StalledResponse.all_responses`; a step with no rows falls back to `decision_type: 'DEFAULT'`.

## Tests to copy

| Spec | What it proves |
|---|---|
| `spec/models/match_routes/fourteen_spec.rb` | step tables, registration, reveal steps |
| `spec/models/match_decisions/fourteen/flow_spec.rb` | full accept chain, decline → override / return / confirm, cancel, which steps stall and decline, stall responses exist |
| `spec/models/notifications/fourteen_spec.rb` | recipient targeting; every notification has a mailer method and template; every notification is wired to a step |
| `spec/mailers/notifications_mailer_route_fourteen_spec.rb` | one real email renders |
| `spec/requests/route_fourteen_decision_views_spec.rb` | every decision page renders; decline control present/absent where expected |
| `spec/models/client_opportunity_match_route_fourteen_visibility_spec.rb` | reveal boundaries per contact type; an existing route unchanged |

Specs use `MatchRoutes::<Name>.first` (seeded by `spec_helper`), not a factory. Do not run two rspec processes at once: `after(:suite)` truncates `match_routes`, so a finishing run wipes the other's route.

## Route 14 specifics

| Step | Decision | Actor | Decline | Stall | Client visible to |
|---|---|---|---|---|---|
| 1 | Initiate Match | CoC (DND staff) | no | no | admins only |
| 2 | Acknowledge Match | Shelter Agency | yes | no | + shelter agency |
| 3 | Client Review | Shelter Agency | yes | no | |
| 4 | Eligibility Screening | Housing Search Provider | yes | yes | + HSP |
| 5 | Subsidy Administrator Screening | HSA | yes | yes | + HSA |
| 6 | Offer Unit or Client Approved for Unit | Housing Search Provider | yes | yes | |
| 7 | Confirm Match Success | CoC (DND staff) | no | yes | |

Initiate Match embeds the contact picker and cannot be accepted without a shelter agency, HSA, and HSP contact. Cancel is available on every step for users with `can_reject_matches?`. Translation keys: `CoC Fourteen`, `Shelter Agency Fourteen`, `HSA Fourteen`, `Housing Search Provider Fourteen`, `Stabilization Service Providers Fourteen`, `Match Route Fourteen`. Decline and cancel reasons are seeded as a single `Other` placeholder per step pending curation. Route 14 has no release-of-information gate on the client reveal.
