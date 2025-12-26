# Requirements Manager

The Requirements Manager is a JavaScript-driven UI component that allows administrators to add, remove, and configure rules on various entities in the CAS system. Rules define eligibility criteria for matching clients to housing opportunities.

## Overview

Rules are conditions that can be applied to vouchers, programs, sub-programs, buildings, units, funding sources, and other entities. When a rule is added as a requirement, it can be set as either:
- **Must** (positive): Client must meet this criterion
- **Can't** (negative): Client must NOT meet this criterion

## Architecture

### Database Layer

#### Rules Table (`rules`)
Stores the rule definitions. Each rule has:
- `type`: STI column pointing to the rule class (e.g., `Rules::Bedroom`)
- `name`: Display name (e.g., "Minimum number of bedrooms")
- `alternate_name`: Optional alternate display name for specific contexts
- `verb`: The verb used in display (e.g., "have", "be")

#### Requirements Table (`requirements`)
Join table that associates rules with entities:
- `rule_id`: Reference to the rule
- `requirer_type` / `requirer_id`: Polymorphic reference to the entity (Voucher, Program, etc.)
- `positive`: Boolean indicating "Must" (true) or "Can't" (false)
- `variable`: Optional value for variable rules (e.g., number of bedrooms)

### Rule Classes

Located in `app/models/rules/`, each rule is a subclass of `Rule` (`app/models/rule.rb`).

#### Base Rule Class Methods

| Method | Purpose |
|--------|---------|
| `description` | Human-readable explanation of what the rule does |
| `selection_note(context:)` | Context-specific notes shown when rule is selected in UI |
| `variable_requirement?` | Returns `true` if the rule requires additional input |
| `display_for_variable(value)` | Formats the variable value for display |
| `clients_that_fit(scope, requirement, opportunity)` | Returns clients matching this rule |

#### Variable Rules

Some rules require additional input (e.g., number of bedrooms, income amount). These rules:
1. Override `variable_requirement?` to return `true`
2. Provide methods like `available_number_of_bedrooms` to list options
3. Have a corresponding view partial in `app/views/rules/<rule_name>/`

Example: `Rules::Bedroom` allows selecting 1-5 bedrooms.

### Seeding Rules

Rules are defined in `db/rules.csv` and seeded via rake task:

```bash
rake cas_seeds:create_rules
```

**CSV Format:**
```csv
Class Name,Rule Name,Alternate Name,Verb
Bedroom,Minimum number of bedrooms,Fit in bedrooms,have
ChronicallyHomeless,Chronically Homeless as defined by HUD,,be
```

The seeder (`app/models/cas_seeds/rules.rb`):
1. Reads `db/rules.csv`
2. Creates or updates rules based on `Class Name`
3. Removes rules not in the CSV (and their associated requirements)

### Adding a New Rule

1. Add entry to `db/rules.csv`
2. Create rule class in `app/models/rules/your_rule.rb`:

```ruby
class Rules::YourRule < Rule
  def description
    'Description of what this rule matches'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    if requirement.positive
      scope.where(your_condition: true)
    else
      scope.where(your_condition: false)
    end
  end
end
```

3. Run `rake cas_seeds:create_rules`

For variable rules, also:
- Override `variable_requirement?` to return `true`
- Create view partial at `app/views/rules/your_rules/_your_rule.haml`

## Frontend Components

Located in `app/assets/javascripts/requirement_manager/`:

| File | Purpose |
|------|---------|
| `controller.js.coffee` | Main controller, initializes components |
| `searcher.js.coffee` | Select2 dropdown for choosing rules |
| `requirement.js.coffee` | Model for a requirement instance |
| `requirement_row.js.coffee` | Renders selected requirements |
| `rule.js.coffee` | Model for available rules |
| `store.js.coffee` | Simple key-value store for rules/requirements |
| `add_button.js.coffee` | Handles the "Add Rule" button |
| `new_requirement_positivity_toggle.js.coffee` | Must/Can't toggle buttons |

### UI Flow

1. User clicks "Must" or "Can't" toggle
2. User selects a rule from the dropdown
3. If variable rule, additional input appears (e.g., bedroom count selector)
4. User clicks "Add Rule"
5. Requirement row is added to the selected requirements list
6. User submits form to save

## View Integration

The requirement manager is rendered via partial:

```haml
= render 'requirement_manager/form_fields',
  form: f,
  selected_requirements_heading: 'Rules for this Voucher',
  hide_inherited: true,
  note_context: :voucher
```

**Parameters:**
- `form`: SimpleForm form builder
- `selected_requirements_heading`: Label for the requirements section
- `help_text`: Optional help text
- `hide_inherited`: Hide inherited rules section
- `on_unit`: Use alternate names for unit context
- `section_header`: Override default "Rules" header
- `note_context`: Context symbol for `selection_note` (e.g., `:voucher`)

### Locations Used

The requirement manager appears on:
- `app/views/vouchers/edit.haml` - Individual voucher rules
- `app/views/programs/_form.html.haml` - Program-level rules
- `app/views/buildings/_form.html.haml` - Building rules
- `app/views/units/_form.html.haml` - Unit rules
- `app/views/funding_sources/edit.haml` - Funding source rules
- `app/views/services/_form.html.haml` - Service rules
- `app/views/subgrantees/_form.html.haml` - Subgrantee rules
- `app/views/admin/users/_form.html.haml` - User requirement overrides
- `app/views/admin/weighting_rules/_form.haml` - Weighting rules

## Selection Notes

Rules can provide context-specific notes via `selection_note(context:)`. This is useful when a rule behaves differently or needs explanation in certain contexts.

Example from `Rules::Bedroom`:

```ruby
def selection_note(context: nil)
  return unless context == :voucher

  <<~NOTE
    **Note:**
    If this voucher is attached to a 2 bedroom unit...
  NOTE
end
```

Notes support Markdown formatting and are rendered when the rule is selected in the UI.
