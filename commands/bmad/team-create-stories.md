You are the Team Lead, executing the **Team Create Stories** workflow.

## Workflow Overview

**Goal:** Create multiple story documents in parallel using Agent Teams

**Phase:** 4 - Implementation (Parallel Story Definition)

**Agent:** Team Lead

**Inputs:** Sprint plan with epic/story list, architecture document

**Output:** Multiple `docs/stories/STORY-{ID}.md` files, updated sprint status

**Duration:** 5-15 minutes (parallel vs 10-20 min per story sequential)

**When to use:** When you have 3+ stories to document across multiple epics

**Prerequisite:** Agent Teams must be enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)

---

## Pre-Flight

1. **Load context** per `helpers.md#Combined-Config-Load`
2. **Check sprint status** per `helpers.md#Load-Sprint-Status`
3. **Check Agent Teams** per `helpers.md#Check-Agent-Teams-Available`
4. **If teams_available = false:**
   - Output:
     ```
     ⚠ Agent Teams not available.

     Agent Teams is an experimental feature that requires:
       CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

     Sequential alternative:
       Use /create-story STORY-{ID} to create stories one at a time.
     ```
   - **Stop workflow** (do not proceed)
5. **Load sprint plan:** Read `docs/sprint-plan-*.md`
6. **Load architecture** (if Level 2+): Read `docs/architecture-*.md`
7. **Load ZenHub context** per `helpers.md#Load-ZenHub-Context`
8. **Identify stories to create:**
   - Find all stories without story documents (no `docs/stories/STORY-{ID}.md`)
   - Or accept user-specified story IDs as input
9. **Load max_teammates** from config `agent_teams.max_teammates` (default: 3)

---

## Part 1: Group Stories by Epic

**Organize stories for parallel creation:**

1. **Group by epic:**
   ```
   Epic 1 "{name}": STORY-001, STORY-002, STORY-003
   Epic 2 "{name}": STORY-004, STORY-005
   Epic 3 "{name}": STORY-006, STORY-007, STORY-008
   ```

2. **Assign epics to teammates:**
   - Each teammate handles one epic's stories
   - If more epics than max_teammates: combine smallest epics
   - No file conflicts: each teammate writes different STORY-{ID}.md files

3. **Display plan:**
   ```
   Story Creation Plan:

   Teammate 1 (Story Creator):
     Epic: "{epic_1_name}"
     Stories: STORY-001, STORY-002, STORY-003
     Output: docs/stories/STORY-001.md, STORY-002.md, STORY-003.md

   Teammate 2 (Story Creator):
     Epic: "{epic_2_name}"
     Stories: STORY-004, STORY-005
     Output: docs/stories/STORY-004.md, STORY-005.md

   Total: {count} stories across {count} teammates

   Proceed? (y/n)
   ```

**Wait for user confirmation.**

If `config.agent_teams.auto_approve_plans` = true, skip confirmation.

---

## Part 2: Spawn Story Creators

**Step 1: Create shared task list** per `helpers.md#Create-Team-Task-List`:

For each teammate:
```
TaskCreate:
  subject: "Story Creator: Create stories for Epic {epic_name}"
  description: Story IDs, epic context, architecture summary
  activeForm: "Creating stories for {epic_name}"
```

**Step 2: Spawn teammates** per `helpers.md#Spawn-BMAD-Teammate`:

For each teammate:
- role: "story-creator"
- context:
  - Epic details (name, description, goals)
  - Story IDs and titles from sprint plan
  - Architecture key sections (relevant to this epic)
  - Story template (standard BMAD format)

Each teammate creates stories independently — no file conflicts since each writes to unique `docs/stories/STORY-{ID}.md` paths.

---

## Part 3: Monitor & Collect

**Monitor teammate progress:**

1. **Poll task status:**
   ```
   Call TaskList
   Display progress: {completed}/{total} teammates done
   ```

2. **On teammate completion:**
   - Verify story documents exist at expected paths
   - Quick validation: check each story has required sections
     (User Story, Acceptance Criteria, Technical Notes, Story Points)

3. **Display progress:**
   ```
   Story Creation Progress:

   Teammate 1: ✓ Complete
     ✓ STORY-001.md (5 acceptance criteria, 3 points)
     ✓ STORY-002.md (4 acceptance criteria, 5 points)
     ✓ STORY-003.md (6 acceptance criteria, 8 points)

   Teammate 2: 🔄 In Progress
     ✓ STORY-004.md (3 acceptance criteria, 2 points)
     ⏳ STORY-005.md ...
   ```

---

## Part 4: Update Status & Sync

**After all teammates complete:**

**Step 1: Update sprint status** (Lead-only batch update):

Per `helpers.md#Update-Sprint-Status`:
```
For each created story:
  - Update status: "defined"
  - Add story_document path
  - Verify story_points match sprint plan
```

**Step 2: Sync to ZenHub** (if available):

```
If zh_available:
  For each created story:
    1. Build story body from document content
    2. Call helpers.md#Sync-Story-to-ZenHub:
       - story_title, story_body, story_points
       - zh_epic_id (parent epic)
       - pipeline_id: Sprint Backlog
    3. Call helpers.md#Store-ZenHub-Cross-Reference:
       - Update story document with ZenHub link
       - Update sprint-status.yaml with zh_issue_id
    4. Log: "✓ Synced STORY-{ID} → ZenHub #{issue_number}"
```

**Step 3: Display summary:**
```
✓ Team Story Creation Complete!

Stories Created: {count}/{total}

Epic "{name}":
  STORY-001: {title} ({points} pts, {criteria_count} AC)
  STORY-002: {title} ({points} pts, {criteria_count} AC)
  STORY-003: {title} ({points} pts, {criteria_count} AC)

Epic "{name}":
  STORY-004: {title} ({points} pts, {criteria_count} AC)
  STORY-005: {title} ({points} pts, {criteria_count} AC)

Total Story Points: {sum}
Documents: docs/stories/

ZenHub: {count} stories synced to Sprint Backlog  (if zh_available)

Next Steps:
  1. Review stories: Read docs/stories/STORY-{ID}.md
  2. Start development: /team-dev (parallel) or /dev-story STORY-{ID} (sequential)
```

---

## Helper References

- **Load config:** `helpers.md#Combined-Config-Load`
- **Load sprint status:** `helpers.md#Load-Sprint-Status`
- **Update sprint status:** `helpers.md#Update-Sprint-Status`
- **Check Agent Teams:** `helpers.md#Check-Agent-Teams-Available`
- **Spawn teammate:** `helpers.md#Spawn-BMAD-Teammate`
- **Create team tasks:** `helpers.md#Create-Team-Task-List`
- **Collect results:** `helpers.md#Collect-Team-Results`
- **ZenHub context:** `helpers.md#Load-ZenHub-Context`
- **Sync story:** `helpers.md#Sync-Story-to-ZenHub`
- **Store xref:** `helpers.md#Store-ZenHub-Cross-Reference`

---

## Notes for LLMs

- **ALWAYS** check Agent Teams availability first (Pre-Flight step 3-4)
- If teams not available, suggest `/create-story` and STOP
- No file conflicts possible: each teammate writes unique STORY-{ID}.md files
- Sprint-status.yaml updates are Lead-only: batch update after ALL teammates complete
- ZenHub sync is also batched after teammates complete (Lead handles all syncing)
- Story documents must follow standard BMAD template format
- Validate each story has required sections before accepting
- If a teammate fails, its stories can be created manually with `/create-story`

**Remember:** Story creation is inherently parallelizable since each story is an independent document. The main value is time savings when creating 3+ stories.
