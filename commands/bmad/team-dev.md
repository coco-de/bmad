You are the Team Lead, executing the **Team Dev** workflow.

## Workflow Overview

**Goal:** Develop multiple stories in parallel using Agent Teams

**Phase:** 4 - Implementation (Parallel Execution)

**Agent:** Team Lead

**Inputs:** Sprint plan with stories, architecture document

**Output:** Working code for multiple stories, PRs created, sprint status updated

**Duration:** Varies by story count and complexity

**Required for:** Projects with 2+ independent stories ready for development

**Prerequisite:** Agent Teams must be enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)

---

## Pre-Flight

1. **Load context** per `helpers.md#Combined-Config-Load`
2. **Load sprint status** per `helpers.md#Load-Sprint-Status`
3. **Check Agent Teams** per `helpers.md#Check-Agent-Teams-Available`
4. **If teams_available = false:**
   - Output:
     ```
     ⚠ Agent Teams not available.

     Agent Teams is an experimental feature that requires:
       CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

     Sequential alternative:
       Use /dev-story STORY-{ID} to develop stories one at a time.
     ```
   - **Stop workflow** (do not proceed)
5. **Load architecture** (if Level 2+): Read `docs/architecture-*.md`
6. **Load ZenHub context** per `helpers.md#Load-ZenHub-Context`
7. **Identify candidate stories:**
   - Find all stories with status "not_started" or "defined" in sprint status
   - If no stories available: inform user and stop
8. **Load max_teammates** from config `agent_teams.max_teammates` (default: 3)

---

## Part 1: Parallelization Analysis

**Analyze stories for parallel execution:**

1. **Group stories by epic:**
   ```
   Epic 1: [STORY-001, STORY-002, STORY-003]
   Epic 2: [STORY-004, STORY-005]
   ```

2. **Check dependencies:**
   - Read each story's dependencies from sprint status or story documents
   - Build dependency graph
   - Identify independent groups (no cross-dependencies)

3. **Calculate file ownership boundaries:**
   - From architecture document, map epics to source directories
   - Ensure no overlap between teammate file sets
   - If overlap detected: move overlapping stories to sequential queue

4. **Determine optimal teammate count:**
   - Count independent story groups
   - Cap at max_teammates
   - If only 1 group: suggest `/dev-story` instead and ask user

5. **Display analysis:**
   ```
   Parallelization Analysis:

   Independent Groups: {count}
   Total Stories: {count}
   Sequential Queue: {count} (due to dependencies or file overlap)

   Group 1: Epic "{name}"
     Stories: STORY-001, STORY-002
     Files: src/auth/*, src/middleware/auth/*
     Points: {total}

   Group 2: Epic "{name}"
     Stories: STORY-004, STORY-005
     Files: src/catalog/*, src/api/products/*
     Points: {total}

   Teammates needed: {count}
   ```

---

## Part 2: Assignment Plan

**Present assignment plan to user:**

```
Proposed Teammate Assignments:

Teammate 1 (Developer):
  Stories: STORY-001, STORY-002
  Epic: {epic_name}
  File Ownership: src/auth/*, tests/auth/*
  Branch: story/STORY-001-{slug}, story/STORY-002-{slug}
  Epic Branch: epic/EPIC-{num}-{slug}

Teammate 2 (Developer):
  Stories: STORY-004, STORY-005
  Epic: {epic_name}
  File Ownership: src/catalog/*, tests/catalog/*
  Branch: story/STORY-004-{slug}, story/STORY-005-{slug}
  Epic Branch: epic/EPIC-{num}-{slug}

Sequential Queue (after parallel phase):
  STORY-003 (depends on STORY-001)

Proceed with this plan? (y/n)
```

**Wait for user confirmation before proceeding.**

If `config.agent_teams.auto_approve_plans` = true, skip confirmation.

---

## Part 3: Branch Creation

**Create branch hierarchy for all stories:**

For each epic in the plan:
1. **Resolve branch names** per `helpers.md#Resolve-Branch-Names`
2. **Create branch hierarchy** per `helpers.md#Create-Branch-Hierarchy`
   - Create epic branch from main (if not exists)
   - Create story branches from epic branch

**Display branch structure:**
```
Branch Hierarchy:
main
├── epic/EPIC-001-user-auth
│   ├── story/STORY-001-registration ← Teammate 1
│   └── story/STORY-002-login ← Teammate 1
└── epic/EPIC-002-product-catalog
    ├── story/STORY-004-listing ← Teammate 2
    └── story/STORY-005-detail ← Teammate 2
```

---

## Part 4: Task List & Teammate Spawn

**Step 1: Create shared task list** per `helpers.md#Create-Team-Task-List`:

For each teammate assignment:
```
TaskCreate:
  subject: "Developer: Implement {story_ids} ({epic_name})"
  description: Full context including stories, file ownership, branches
  activeForm: "Implementing {story_ids}"
```

Set up dependencies if any stories are sequential.

**Step 2: Spawn teammates** per `helpers.md#Spawn-BMAD-Teammate`:

For each teammate:
- role: "developer"
- context: Story documents, architecture summary, file ownership, branch info

**Step 3: Move stories to In Progress on ZenHub:**
```
If zh_available:
  For each story being developed:
    Call helpers.md#Move-Pipeline-with-Context(zh_story_id, "In Progress")
  For each epic with first story starting:
    Call helpers.md#Move-Pipeline-with-Context(zh_epic_id, "In Progress")
```

---

## Part 5: Plan Approval

**Review teammate implementation plans:**

Each teammate produces an implementation plan before coding.

If `config.agent_teams.auto_approve_plans` = false (default):
1. Collect plans from teammates
2. Present each plan to user for review
3. User approves or requests changes
4. On approval: teammates proceed with implementation
5. On rejection: teammate revises plan

If `config.agent_teams.auto_approve_plans` = true:
- Teammates proceed directly after planning

---

## Part 6: Progress Monitoring

**Poll teammate progress:**

1. **Check task status:**
   ```
   Call TaskList
   Display: {completed}/{total} teammates done
   ```

2. **On teammate completion:**
   a. Run quality gate per `helpers.md#Team-Quality-Gate`:
      ```
      Call Team-Quality-Gate(story_branch)
      If passed: Accept work
      If failed: Report failures to user for decision
      ```

   b. Update sprint status per `helpers.md#Update-Sprint-Status`:
      - Update story status to "dev-complete"
      - Update branch, epic_branch fields
      - Increment completed_points

   c. Move ZenHub pipeline:
      ```
      If zh_available:
        Call helpers.md#Move-Pipeline-with-Context(zh_story_id, "Review/QA")
      ```

3. **On teammate failure:**
   - Log the issue
   - Continue monitoring remaining teammates
   - Report failed stories to user

4. **Display progress:**
   ```
   Team Progress:

   Teammate 1: ✓ Complete (STORY-001, STORY-002)
     Quality Gate: ✓ Passed (lint ✓, typecheck ✓, tests ✓)

   Teammate 2: 🔄 In Progress (STORY-004, STORY-005)
     Current: Implementing STORY-004...

   Overall: 2/4 stories complete
   ```

---

## Part 7: Results Summary

**After all teammates complete:**

1. **Collect results** per `helpers.md#Collect-Team-Results`

2. **Handle sequential queue** (if any):
   - Inform user about remaining dependent stories
   - Suggest `/dev-story STORY-{ID}` for each

3. **Create story → epic PRs** per `helpers.md#Create-PR-and-Merge`:
   ```
   For each completed story:
     Call Create-PR-and-Merge(
       source: story_branch,
       target: epic_branch,
       title: "feat: STORY-{ID} {title}",
       merge_strategy: "merge"
     )
   ```

4. **Display summary:**
   ```
   ✓ Team Development Complete!

   Stories Completed: {count}/{total}
   Total Points: {points}

   Results:
     STORY-001: ✓ Dev Complete, PR open
       Quality: lint ✓, typecheck ✓, tests ✓ ({count} tests)
       PR: {pr_url}

     STORY-002: ✓ Dev Complete, PR open
       Quality: lint ✓, typecheck ✓, tests ✓ ({count} tests)
       PR: {pr_url}

   ZenHub Pipeline:
     STORY-001 → Review/QA
     STORY-002 → Review/QA

   Sequential Queue:
     STORY-003 (depends on STORY-001) → Run /dev-story STORY-003

   Sprint Progress: {completed}/{total} points
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
- **Quality gate:** `helpers.md#Team-Quality-Gate`
- **Resolve branches:** `helpers.md#Resolve-Branch-Names`
- **Create branch hierarchy:** `helpers.md#Create-Branch-Hierarchy`
- **Create PR:** `helpers.md#Create-PR-and-Merge`
- **ZenHub context:** `helpers.md#Load-ZenHub-Context`
- **Move pipeline:** `helpers.md#Move-Pipeline-with-Context`

---

## Notes for LLMs

- **ALWAYS** check Agent Teams availability first (Pre-Flight step 3-4)
- If teams not available, suggest `/dev-story` and STOP — do not attempt workarounds
- Present parallelization plan to user and wait for confirmation
- Sprint-status.yaml is Lead-only: batch all updates after teammates complete
- File ownership boundaries must be explicit and non-overlapping
- Quality gates run automatically on each teammate's completed work
- ZenHub pipeline moves are best-effort (warn and continue on failure)
- Each teammate works on its own branch — no shared branches between teammates
- Sequential queue handles stories with dependencies (run after parallel phase)
- If `gh` CLI unavailable, output manual PR instructions (do not block)

**Remember:** The value of `/team-dev` is parallelization. If there's only 1 independent story group, recommend `/dev-story` instead. The overhead of team coordination should be justified by parallel execution gains.
