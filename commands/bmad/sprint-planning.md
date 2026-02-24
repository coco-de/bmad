Scrum Master로서 **스프린트 계획** 워크플로우를 실행합니다.

## Workflow Overview

**Goal:** Plan sprint iterations with detailed, estimated stories

**Phase:** 4 - Implementation (Planning)

**Agent:** Scrum Master

**Inputs:** PRD or tech-spec, architecture (if Level 2+), team capacity

**Output:** `docs/sprint-plan-{project-name}-{date}.md`, `.bmad/sprint-status.yaml`

**Duration:** 30-90 minutes (varies by project level)

**Required for:** All project levels (approach varies by level)

---

## Pre-Flight

1. **Load context** per `helpers.md#Combined-Config-Load`
2. **Check status** per `helpers.md#Load-Workflow-Status`
3. **Load planning documents:**
   - Check for PRD: `docs/prd-*.md`
   - If no PRD, check for tech-spec: `docs/tech-spec-*.md`
   - If Level 2+, load architecture: `docs/architecture-*.md`
4. **Check sprint status** per `helpers.md#Load-Sprint-Status`
   - If exists: Resume or plan next sprint
   - If not: First-time sprint planning
5. **Extract from planning docs:**
   - Project level (0-4)
   - Epics (if PRD) or high-level features (if tech-spec)
   - All functional requirements
   - Story estimates (if already present)
6. **Load ZenHub context** per `helpers.md#Load-ZenHub-Context`
   - This automatically loads conventions cache first (per `helpers.md#Load-ZenHub-Conventions`)
   - Check zh_sub_tasks_enabled for Sub-task support

---

## Sprint Planning Process

Use TodoWrite to track: Pre-flight → Extract Requirements → Break Into Stories → Estimate Stories → Calculate Capacity → Allocate to Sprints → Define Goals → Generate Plan → Update Status → ZenHub Batch Sync

Approach: **Organized, pragmatic, team-focused.**

---

### Part 1: Extract and Inventory

**From PRD (Level 2+):**
- Extract all epics (Epic-001, Epic-002, etc.)
- For each epic, extract associated FRs
- Note epic priorities (Must/Should/Could Have)
- Count total epics and FRs

**From Tech-Spec (Level 0-1):**
- Extract requirements list (simple features)
- Note priorities
- Count total requirements

**From Architecture (if exists):**
- Review component structure (guides story breakdown)
- Note technical dependencies
- Identify infrastructure stories needed

**Create inventory:**
```
Project Inventory:
- Level: {0|1|2|3|4}
- Epics: {count} (if PRD)
- Requirements: {count}
- Architecture: {exists|not needed}
- Estimated Stories: {rough count based on level}
```

---

### Part 2: Break Epics Into Stories

**For each epic (or feature group):**

1. **Identify user stories** within the epic
   - Each story should deliver incremental value
   - Stories should be independent where possible
   - Stories should be testable

2. **Apply story template:**
   ```markdown
   ### STORY-{number}: {Title}

   **Epic:** {Epic ID/name}
   **Priority:** {Must Have | Should Have | Could Have}

   **User Story:**
   As a {user type}
   I want to {capability}
   So that {benefit}

   **Acceptance Criteria:**
   - [ ] Criterion 1
   - [ ] Criterion 2
   - [ ] Criterion 3

   **Technical Notes:**
   {Implementation guidance, components involved, dependencies}

   **Dependencies:**
   {Other stories or external dependencies}
   ```

3. **Size appropriately:**
   - Level 0: 1 story total
   - Level 1: 1-10 stories
   - Level 2: 5-15 stories
   - Level 3: 12-40 stories
   - Level 4: 40+ stories

4. **Ensure completeness:**
   - All FRs are covered by at least one story
   - Stories map back to epics/requirements
   - No orphaned requirements

5. **Sub-task decomposition (if zh_sub_tasks_enabled):**
   - For stories estimated at 5+ points, suggest sub-task breakdown
   - Sub-tasks represent discrete implementation units within a story
   - Each sub-task should be completable in 1-4 hours
   - Present sub-task suggestions for user approval:
     ```
     STORY-001 (5 pts) suggested sub-tasks:
       - Implement data model and migration
       - Create API endpoint with validation
       - Build frontend component
       - Write unit and integration tests

     Add sub-tasks? (y/n/edit)
     ```
   - Store approved sub-tasks in sprint plan for later ZenHub sync

**Typical breakdown patterns:**

**Authentication Epic →**
- STORY-001: User registration
- STORY-002: User login
- STORY-003: Password reset
- STORY-004: Email verification
- STORY-005: Profile management

**Product Catalog Epic →**
- STORY-006: Product listing page
- STORY-007: Product search
- STORY-008: Product detail page
- STORY-009: Product categories
- STORY-010: Product images

**Infrastructure (if needed) →**
- STORY-000: Set up development environment
- STORY-INF-001: Database schema
- STORY-INF-002: CI/CD pipeline
- STORY-INF-003: Deployment infrastructure

---

### Part 3: Estimate Story Points

**For each story, assign points using Fibonacci scale:**

**Estimation guidelines:**
- **1 point:** Trivial (1-2 hours) - Config change, text update
- **2 points:** Simple (2-4 hours) - Basic CRUD, simple component
- **3 points:** Moderate (4-8 hours) - Complex component, business logic
- **5 points:** Complex (1-2 days) - Feature with multiple components
- **8 points:** Very Complex (2-3 days) - Full feature frontend + backend
- **13 points:** Epic-sized (3-5 days) - **BREAK THIS DOWN**

**Estimation factors:**
- Complexity of business logic
- Number of components/files to change
- Dependencies on other stories
- Testing complexity
- Unknowns or research needed

**Ask user for estimation input (if needed):**
> "I've estimated STORY-006 (Product listing page) at 8 points (2-3 days). Does this align with your expectations given it includes:
> - API endpoint for products
> - Frontend listing component
> - Pagination
> - Filtering
> - Unit and integration tests
>
> Adjust if your team's velocity differs."

**Store estimates:**
```
STORY-001: User registration - 5 points
STORY-002: User login - 3 points
STORY-003: Password reset - 3 points
...

Total Points: {sum} points
```

**Validate:**
- No story >8 points (break down if needed)
- Point distribution is balanced
- Infrastructure stories are included

**Story Point Correction Table:**
When sub-tasks are enabled, verify point estimates against sub-task count:

| Points | Expected Sub-tasks | If More | If Fewer |
|--------|-------------------|---------|----------|
| 1-2    | 0-2               | Bump to 3 pts | OK |
| 3      | 2-4               | Bump to 5 pts | OK |
| 5      | 3-6               | Bump to 8 pts | Consider removing sub-tasks |
| 8      | 5-10              | Break into 2 stories | OK |
| 13+    | **ALWAYS break down** | Split into 2-3 stories | Still split |

---

### Part 4: Calculate Team Capacity

**Ask user:**
> "Let's determine your sprint capacity.
>
> Questions:
> 1. How many developers on the team? (default: 1)
> 2. Sprint length in weeks? (default: 2 weeks)
> 3. Any holidays or PTO during sprint?
> 4. Team experience level? (Junior: 4h/day, Mid: 5h/day, Senior: 6h/day productive)"

**Calculate capacity:**
```
Team size: {developers}
Sprint length: {weeks} weeks = {days} workdays
Productive hours/day: {hours} (default: 6)
Holidays/PTO: {days} off
Total hours: {developers} × ({days} - {days_off}) × {hours}
```

**Convert to story points:**
```
Velocity (if known from past sprints): {points/sprint}

If no velocity:
- Junior team: 1 point = 4 hours
- Mid team: 1 point = 3 hours
- Senior team: 1 point = 2 hours

Capacity = Total hours ÷ hours per point
```

**Example:**
```
1 senior developer
2-week sprint = 10 workdays
6 productive hours/day
No holidays
Total: 1 × 10 × 6 = 60 hours
Velocity: 60 ÷ 2 = 30 points per sprint
```

**Store capacity:**
```
Sprint Capacity: {points} points
Team Size: {developers}
Sprint Length: {weeks} weeks
```

---

### Part 5: Allocate Stories to Sprints

**Level 0 (1 story):**
- No sprint allocation needed
- Just create the single story
- Proceed directly to /dev-story

**Level 1 (1-10 stories):**
- Single sprint
- Allocate all stories
- Order by priority and dependency
- Total points: {sum}

**Level 2+ (Multiple sprints):**

For each sprint:

1. **Start with Must Have stories**
2. **Respect dependencies** (don't schedule dependent stories in wrong order)
3. **Fill to capacity** (target: 80-90% of capacity for safety)
4. **Group related stories** (keep epic stories together when possible)
5. **Leave buffer** (10-20% for unknowns and bugs)

**Sprint allocation format:**
```markdown
### Sprint 1 (Weeks 1-2) - {points}/{capacity} points

**Goal:** {What this sprint delivers}

**Stories:**
- STORY-001: User registration (5 points) - Must Have
- STORY-002: User login (3 points) - Must Have
- STORY-003: Password reset (3 points) - Should Have
- STORY-000: Development environment setup (2 points) - Infrastructure
- STORY-INF-001: Database schema (5 points) - Infrastructure

**Total:** 18 points / 30 capacity (60% utilization)

**Risks:**
- {Any identified risks for this sprint}

**Dependencies:**
- {External dependencies}

---

### Sprint 2 (Weeks 3-4) - {points}/{capacity} points

**Goal:** {What this sprint delivers}

**Stories:**
...
```

**Validate allocation:**
- All Must Have stories are allocated
- Dependencies are respected
- Sprints are balanced (not overloaded)
- Each sprint has a clear goal
- Buffer exists for unknowns

---

### Part 6: Define Sprint Goals

**For each sprint, create a clear goal:**

**Good sprint goals:**
- "Complete user authentication with registration, login, and password reset"
- "Deliver product catalog with listing, search, and detail views"
- "Enable checkout flow from cart to order confirmation"

**Bad sprint goals:**
- "Do some stuff" (too vague)
- "Finish everything" (not specific)
- "STORY-001 through STORY-020" (not user-focused)

**SMART goals:**
- Specific: What exactly is being delivered
- Measurable: Clear success criteria
- Achievable: Fits within capacity
- Relevant: Delivers user value
- Time-bound: Fits within sprint timeframe

---

### Part 7: Create Traceability

**Epic to Story mapping:**
```markdown
## Epic Traceability

| Epic ID | Epic Name | Stories | Total Points | Sprint |
|---------|-----------|---------|--------------|--------|
| Epic-001 | User Authentication | STORY-001, 002, 003, 004, 005 | 21 points | Sprint 1 |
| Epic-002 | Product Catalog | STORY-006, 007, 008, 009, 010 | 28 points | Sprint 1-2 |
| Epic-003 | Shopping Cart | STORY-011, 012, 013 | 15 points | Sprint 2 |
| Epic-004 | Checkout | STORY-014, 015, 016, 017 | 20 points | Sprint 3 |
```

**FR to Story mapping:**
```markdown
## Functional Requirements Coverage

| FR ID | FR Name | Story | Sprint |
|-------|---------|-------|--------|
| FR-001 | User registration | STORY-001 | 1 |
| FR-002 | User login | STORY-002 | 1 |
| FR-003 | Password reset | STORY-003 | 1 |
...
```

**Ensures:**
- All FRs are covered
- All epics are broken down
- No requirements are forgotten
- Clear implementation path

---

### Part 8: Identify Risks and Dependencies

**For the overall plan:**

**Risks:**
- Technical risks (new technology, integration complexity)
- Resource risks (team availability, holidays)
- Dependency risks (external APIs, third-party services)
- Scope risks (unclear requirements, scope creep)

**Format:**
```markdown
## Risks

**High:**
- Integration with payment gateway (Stripe) - mitigation: prototype in Sprint 1
- Database performance at scale - mitigation: load testing in Sprint 2

**Medium:**
- Email delivery reliability - mitigation: use SendGrid, monitor bounces

**Low:**
- Browser compatibility issues - mitigation: test on major browsers
```

**Dependencies:**
- External teams or services
- Infrastructure provisioning
- Design assets
- Third-party API access

---

### Part 9: Generate Sprint Plan Document

**Load sprint plan template** (if exists) or use default structure:

```markdown
# Sprint Plan: {project_name}

**Date:** {date}
**Scrum Master:** {user_name} (Steve)
**Project Level:** {level}
**Total Stories:** {count}
**Total Points:** {sum}
**Planned Sprints:** {count}

---

## Executive Summary

{2-3 sentence overview of the sprint plan}

**Key Metrics:**
- Total Stories: {count}
- Total Points: {sum}
- Sprints: {count}
- Team Capacity: {points} points per sprint
- Target Completion: {date}

---

## Story Inventory

{All stories with estimates, acceptance criteria, dependencies}

---

## Sprint Allocation

{Sprint-by-sprint breakdown from Part 5}

---

## Epic Traceability

{Epic-to-story mapping from Part 7}

---

## Requirements Coverage

{FR-to-story mapping from Part 7}

---

## Risks and Mitigation

{Risks from Part 8}

---

## Dependencies

{Dependencies from Part 8}

---

## Definition of Done

For a story to be considered complete:
- [ ] Code implemented and committed
- [ ] Unit tests written and passing (≥80% coverage)
- [ ] Integration tests passing
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] Deployed to {environment}
- [ ] Acceptance criteria validated

---

## Next Steps

**Immediate:** Begin Sprint 1

Run /create-story to create detailed story documents for Sprint 1 stories, or run /dev-story {STORY-ID} to implement a specific story.

**Sprint cadence:**
- Sprint length: {weeks} weeks
- Sprint planning: Monday Week 1
- Sprint review: Friday Week 2
- Sprint retrospective: Friday Week 2

---

**This plan was created using BMAD Method v6 - Phase 4 (Implementation Planning)**
```

**Save document:**
- Path: `{output_folder}/sprint-plan-{project-name}-{date}.md`
- Use Write tool

---

### Part 10: Initialize Sprint Status

**Create or update** `.bmad/sprint-status.yaml`:

```yaml
version: "6.0.0"
project_name: "{project_name}"
project_level: {level}
current_sprint: 1
sprint_plan_path: "{path to sprint plan}"

# Epic Branch Tracking (populated by Part 11 Step 5)
epic_branches: []
  # - epic_id: "{zh_epic_id}"
  #   epic_name: "{epic_name}"
  #   branch: "epic/EPIC-{number}-{slug}"
  #   created: false       # lazy-created on first story start
  #   pr_url: ""           # epic → main PR URL
  #   pr_status: ""        # open | merged | closed

sprints:
  - sprint_number: 1
    start_date: "{date}"
    end_date: "{date + 2 weeks}"
    capacity_points: {capacity}
    committed_points: {committed}
    completed_points: 0
    status: "not_started"
    goal: "{sprint goal}"
    stories:
      - story_id: "STORY-001"
        title: "{title}"
        points: {points}
        status: "not_started"
        assigned_to: null
        zh_issue_id: ""        # ZenHub issue ID (populated by ZenHub sync)
        zh_issue_number: null  # GitHub issue number
        zh_issue_url: ""       # GitHub issue URL
        branch: ""             # story branch (populated by Part 11 Step 5 or dev-story)
        epic_branch: ""        # parent epic branch
        pr_url: ""             # story → epic PR URL
        pr_status: ""          # open | merged | closed

velocity:
  sprint_1: null  # Will be filled when sprint completes
  sprint_2: null
  rolling_average: null

team:
  size: {developers}
  sprint_length_weeks: {weeks}
  capacity_per_sprint: {points}
```

**Save per** `helpers.md#Update-Sprint-Status`

---

## Display Summary to User

Show concise summary:

```
✓ Sprint Plan Created!

Project: {project_name} (Level {level})

Summary:
- Total Stories: {count}
- Total Points: {sum}
- Planned Sprints: {count}
- Team Capacity: {points} points/sprint
- Target Completion: {date}

Sprint 1 Goal: {goal}
Sprint 1 Stories: {count} stories, {points} points

Full plan: {file_path}

ZenHub Sync: (if zh_available)
- Epics created: {count}/{total}
- Stories created: {count}/{total}
- Sprint assignments: {count}

Ready to begin implementation!
```

---

## Update Workflow Status

Per `helpers.md#Update-Workflow-Status`:
1. Update `sprint-planning` status to file path
2. Set current phase to "implementation"
3. Save status file

---

### Part 11: ZenHub Batch Sync

**Skip this part if `zh_available = false`.**

**Step 0: Preview and Confirm**

Before creating any ZenHub issues, display a full preview:

```
=== ZenHub Batch Sync Preview ===

Issues to create:
  Epics: {count}
  Stories: {count}
  Sub-tasks: {count}  (if zh_sub_tasks_enabled)

  [Epic] {epic_1_name}
    [Story] {story_1_title} ({points} pts)
      [Sub-task] {sub_1_title}  (if sub-tasks)
      [Sub-task] {sub_2_title}
    [Story] {story_2_title} ({points} pts)

  [Epic] {epic_2_name}
    [Story] {story_3_title} ({points} pts)
    ...

Sprint Assignment: {sprint_name}
Pipeline: Sprint Backlog (current sprint) / Product Backlog (future)

Total Issues: {total_count}
Total Points: {total_points}

[C]onfirm - Create all issues
[S]kip sub-tasks - Create epics + stories only
[A]bort - Skip ZenHub sync entirely
```

Wait for user confirmation. If abort, skip Part 11 entirely.

**Step 1: Sync Epics**

For each epic in the sprint plan:
1. Generate epic body per `helpers.md#Generate-Epic-Body`:
   - epic_name, epic_description, stories list, sprint info
2. Call `helpers.md#Sync-Epic-to-ZenHub` with:
   - epic_name: Epic title from plan
   - epic_description: Generated body (markdown)
   - sprint_start_date / sprint_end_date: From sprint dates
3. Collect `zh_epic_id` for each epic
4. Log: `✓ Epic synced: [Epic] {name} → #{issue_number}`

**Step 2: Sync Stories**

For each story in the sprint plan:
1. Generate story body per `helpers.md#Generate-Story-Body`:
   - story data (user story, AC, technical notes)
2. Call `helpers.md#Sync-Story-to-ZenHub` with:
   - story_title: Story title
   - story_body: Generated body (markdown)
   - story_points: Estimated points
   - zh_epic_id: Parent epic's ZenHub ID (from Step 1)
   - sprint_id: `zh_active_sprint.id` (current sprint) or `zh_next_sprint.id` (future sprint)
   - pipeline_id: `zh_pipelines["Sprint Backlog"]` (current sprint) or `zh_pipelines["Product Backlog"]` (future sprints)
2. Collect `zh_story_id`, issue number, URL for each story
3. Log: `✓ Story synced: [Story] {title} → #{issue_number}`

**Step 3: Sync Dependencies**

1. Build dependency_map from story dependencies identified in Part 8
2. Call `helpers.md#Sync-Story-Dependencies-to-ZenHub` with dependency_map
3. Log each dependency created

**Step 4: Store Cross-References**

1. For each synced epic/story, call `helpers.md#Store-ZenHub-Cross-Reference`:
   - Update sprint-status.yaml with zh_issue_id, zh_issue_number, zh_issue_url
   - Update sprint plan document with ZenHub cross-reference table:

```markdown
## ZenHub Cross-Reference

| Local ID | ZenHub # | Type | URL |
|----------|----------|------|-----|
| Epic-001 | #{number} | Epic | {url} |
| STORY-001 | #{number} | Story | {url} |
| STORY-002 | #{number} | Story | {url} |
```

**Step 5: Pre-compute Branch Names**

For each epic and story, compute branch names using `helpers.md#Resolve-Branch-Names`:

1. For each epic:
   - Compute: `epic/EPIC-{zh_issue_number}-{slug}`
   - Store in sprint-status.yaml `epic_branches` section:
     ```yaml
     epic_branches:
       - epic_id: "{zh_epic_id}"
         epic_name: "{epic_name}"
         branch: "epic/EPIC-{number}-{slug}"
         created: false
     ```
   - Note: Branch is NOT created here — lazy creation on first story start (dev-story Part 3)

2. For each story:
   - Compute: `story/STORY-{id}-{slug}`
   - Store in sprint-status.yaml story entry:
     ```yaml
     branch: "story/STORY-{id}-{slug}"
     epic_branch: "epic/EPIC-{number}-{slug}"
     ```

3. Log pre-computed branch names:
   ```
   Branch Names Pre-computed:
   epic/EPIC-025-coui-flutter-maintenance
     ├── story/STORY-008-dcm-warning-zero
     └── story/STORY-009-widgetbook-update
   ```

**Step 6: Sync Sub-tasks** (if zh_sub_tasks_enabled and user confirmed sub-tasks in Step 0)

For each story that has approved sub-tasks:
1. For each sub-task:
   a. Generate sub-task body per `helpers.md#Generate-Sub-task-Body`
   b. Call `helpers.md#Sync-Sub-task-to-ZenHub`:
      - sub_task_title, sub_task_body
      - zh_story_id (parent story from Step 2)
   c. Collect zh_sub_task_id, issue number
2. Update sprint-status.yaml story entry with sub_tasks array:
   ```yaml
   sub_tasks:
     - id: "sub-task-001"
       title: "{sub_task_title}"
       status: "not-started"
       zh_issue_id: "{zh_sub_task_id}"
       zh_issue_number: {issue_number}
       zh_issue_url: "{url}"
       zh_pipeline: "Sprint Backlog"
   ```
3. Update metrics: total_sub_tasks
4. Log: `✓ Sub-task synced: #{issue_number} (parent: #{story_number})`

**Display ZenHub sync results in summary:**
```
ZenHub Sync Results:
- Epics created: {count}/{total}
- Stories created: {count}/{total}
- Sub-tasks created: {count}/{total}  (if sub-tasks enabled)
- Sprint assignments: {count}
- Dependencies synced: {count}
- Branch names pre-computed: {count} epics, {count} stories
```

---

## Recommend Next Steps

**Level 0:**
```
✓ Sprint plan complete (1 story)

Next: Implement the story
Run /dev-story STORY-001 to begin implementation
```

**Level 1-2:**
```
✓ Sprint plan complete ({sprints} sprint{s})

Next: Begin Sprint 1
Options:
1. /create-story STORY-001 - Create detailed story document
2. /dev-story STORY-001 - Start implementing immediately
3. /sprint-status - Check current sprint status

Recommended: Start with /dev-story for first story
```

**Level 3-4:**
```
✓ Sprint plan complete ({sprints} sprints)

Implementation roadmap ready:
✓ Sprint 1: {goal}
✓ Sprint 2: {goal}
✓ Sprint 3: {goal}
...

Next: Begin Sprint 1
Run /dev-story STORY-001 to start first story

Or run /create-story STORY-XXX to generate detailed story docs
```

---

## Helper References

- **Load config:** `helpers.md#Combined-Config-Load`
- **Load status:** `helpers.md#Load-Workflow-Status`
- **Load sprint status:** `helpers.md#Load-Sprint-Status`
- **Save document:** `helpers.md#Save-Output-Document`
- **Update sprint status:** `helpers.md#Update-Sprint-Status`
- **Update workflow status:** `helpers.md#Update-Workflow-Status`
- **Recommend next:** `helpers.md#Determine-Next-Workflow`
- **ZenHub context:** `helpers.md#Load-ZenHub-Context`
- **ZenHub conventions:** `helpers.md#Load-ZenHub-Conventions`
- **Sync epic:** `helpers.md#Sync-Epic-to-ZenHub`
- **Sync story:** `helpers.md#Sync-Story-to-ZenHub`
- **Sync sub-task:** `helpers.md#Sync-Sub-task-to-ZenHub`
- **Sync deps:** `helpers.md#Sync-Story-Dependencies-to-ZenHub`
- **Store xref:** `helpers.md#Store-ZenHub-Cross-Reference`
- **Generate epic body:** `helpers.md#Generate-Epic-Body`
- **Generate story body:** `helpers.md#Generate-Story-Body`
- **Generate sub-task body:** `helpers.md#Generate-Sub-task-Body`
- **Resolve branches:** `helpers.md#Resolve-Branch-Names`

---

## Story Point Calibration

**Use these examples to calibrate estimates:**

**1 point (1-2 hours):**
- Update configuration value
- Change text/copy
- Add simple validation
- Fix typo in code

**2 points (2-4 hours):**
- Create basic CRUD endpoint
- Simple React component (no state)
- Add database index
- Write unit tests for existing code

**3 points (4-8 hours):**
- Complex React component with state
- Business logic function
- Integration test suite
- API endpoint with validation

**5 points (1-2 days):**
- Feature with frontend + backend
- Database migration with data transformation
- Complex business logic with edge cases
- Full test coverage for feature

**8 points (2-3 days):**
- Complete user flow (e.g., registration)
- Multiple related components
- Complex state management
- Integration with external service

**13 points (3-5 days):**
- **TOO BIG - BREAK IT DOWN**
- This is an epic, not a story

---

## Tips for Effective Sprint Planning

**Right-size stories:**
- Target: 2-5 points per story
- Avoid: 1-point stories (too granular) and 13-point stories (too large)
- Ideal sprint: Mix of 2, 3, 5, and 8-point stories

**Balance sprints:**
- Don't front-load all hard stories
- Mix Must/Should/Could priorities
- Leave buffer for unknowns (10-20%)

**Respect dependencies:**
- Infrastructure before features
- Foundation before extensions
- Backend before frontend (usually)

**Keep user value visible:**
- Each sprint should deliver something usable
- Demo-able progress at sprint end
- Incremental value delivery

---

## Notes for LLMs

- Maintain approach (organized, pragmatic, team-focused)
- Use TodoWrite to track 10 sprint planning parts
- Break stories systematically - don't skip any FRs
- Apply sizing guidelines strictly (no stories >8 points)
- Calculate realistic capacity based on team size and experience
- Create traceability tables to ensure coverage
- Reference helpers.md for all common operations
- Initialize sprint status YAML for tracking
- Hand off to Developer when ready for implementation

- After local plan is complete (Part 10), sync to ZenHub (Part 11) if zh_available
- Always show preview (Step 0) and wait for confirmation before creating ZenHub issues
- Use `createGitHubIssue` (not `createZenhubIssue`) per workspace convention
- Use Generate Body helpers for consistent issue formatting (Epic/Story/Sub-task bodies)
- Set issue types: Epic for epics, Feature for stories
- Assign stories to active sprint (Sprint Backlog) or future sprints (Product Backlog)
- Store ZenHub cross-references in sprint-status.yaml for downstream workflows
- Sub-tasks are opt-in: only suggest for 5+ point stories when zh_sub_tasks_enabled = true
- Sub-task sync (Step 6) happens after stories, as each sub-task needs parent zh_story_id
- If ZenHub sync fails partially, log what succeeded and continue
- After ZenHub sync, pre-compute branch names (Part 11 Step 5) using `helpers.md#Resolve-Branch-Names`
- Store branch names in sprint-status.yaml for dev-story to use (epic_branches + story branch/epic_branch fields)
- Branches are NOT created during sprint planning — only names are pre-computed for consistency

**Remember:** Good sprint planning = smooth implementation. Poor planning = chaos, delays, and frustration. Take time to break stories down properly and estimate accurately.
