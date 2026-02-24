Epic 내 스토리를 순차적으로 처리하는 **ZenHub Sequential** 커맨드를 실행합니다.

## Command Overview

**Purpose:** Process stories within an Epic sequentially: implement, create PR, review, then move to next story

**Agent:** Developer

**Inputs:** Epic identifier (epic ID, issue number, or epic name from sprint status)

**Output:** Implemented stories with PRs, ZenHub pipelines updated, sprint status tracked

**Duration:** Varies by story count and complexity

**When to use:** When you want guided, sequential story-by-story development within an epic

---

## Pre-Flight

1. **Load context** per `helpers.md#Combined-Config-Load`
2. **Load sprint status** per `helpers.md#Load-Sprint-Status`
3. **Load ZenHub context** per `helpers.md#Load-ZenHub-Context`
4. **Identify target epic:**
   - If user provides epic name/ID: Find in sprint status
   - If user provides ZenHub issue number: Match by zh_issue_number
   - If no input: Show available epics and ask user to choose
5. **Load stories for the epic:**
   - Get all stories under the identified epic from sprint status
   - Sort by: dependencies first, then story ID order
   - Identify already-completed stories (skip these)
6. **Load sub-tasks** (if sub_tasks enabled):
   - For each story, load sub_tasks array from sprint status
   - These guide the implementation checklist

---

## Sequential Processing Loop

**Display epic overview:**
```
Sequential Processing: {epic_name}

Stories to process ({remaining}/{total}):
  {status_icon} STORY-{id_1}: {title} ({points} pts) {pipeline}
  {status_icon} STORY-{id_2}: {title} ({points} pts) {pipeline}
  {status_icon} STORY-{id_3}: {title} ({points} pts) {pipeline}

Legend: [ ] Not Started  [>] In Progress  [PR] Review/QA  [x] Done

Processing order: STORY-{first} → STORY-{second} → STORY-{third}
```

### For Each Story (Loop):

**Step 1: Start Story**

```
=== Story {n}/{total}: STORY-{ID} ===
Title: {title}
Points: {points}
Dependencies: {dep_list or "None"}
Sub-tasks: {count or "None"}  (if sub-tasks enabled)

Starting implementation...
```

1. Move ZenHub to In Progress:
   ```
   If zh_available and zh_story_id:
     Call helpers.md#Move-Pipeline-with-Context(zh_story_id, "In Progress")
   ```

2. Set up branch hierarchy per `helpers.md#Create-Branch-Hierarchy`:
   - Create epic branch (if first story in epic)
   - Create story branch from epic branch

3. Update sprint-status.yaml: story status → "in_progress"

**Step 2: Implement Story**

Delegate to dev-story workflow logic (Parts 1-9 from `commands/bmad/dev-story.md`):

1. Read story document (if exists): `docs/stories/STORY-{ID}.md`
2. Plan implementation tasks using TodoWrite
3. If sub-tasks exist, use them as implementation checklist:
   ```
   Implementation Checklist (from Sub-tasks):
   - [ ] #{sub_num} {sub_task_title}
   - [ ] #{sub_num} {sub_task_title}
   - [ ] #{sub_num} {sub_task_title}
   ```
4. Implement code, write tests
5. Validate acceptance criteria
6. Run quality checks (lint, typecheck, tests)

**Step 3: Update Sub-task Pipelines** (if sub-tasks enabled)

As each sub-task is completed during implementation:
```
If zh_available and sub_task has zh_issue_id:
  Call helpers.md#Move-Pipeline-with-Context(zh_sub_task_id, "Done")
  Update sprint-status sub_task status → "done"
  Log: "  Sub-task #{sub_num} → Done"
```

**Step 4: Create PR**

Per `helpers.md#Create-PR-and-Merge`:
```
Create-PR-and-Merge(
  source: story_branch,
  target: epic_branch,
  title: "feat: STORY-{ID} {title}",
  body: {story_summary_with_ac_checklist},
  merge_strategy: "merge"
)
```

**Step 5: Move to Review**

```
If zh_available:
  Call helpers.md#Move-Pipeline-with-Context(zh_story_id, "Review/QA")
```

Update sprint-status.yaml:
- story status → "dev-complete"
- pr_url, pr_status: "open"

**Step 6: Review Decision**

Ask user:
```
STORY-{ID} implementation complete!

PR: {pr_url}
Pipeline: Review/QA

Options:
  [M]erge PR and continue to next story
  [R]eview PR first (pause sequential processing)
  [S]kip to next story (leave PR open)
```

If Merge:
1. Merge PR (via `gh pr merge`)
2. Move ZenHub to Done: `helpers.md#Move-Pipeline-with-Context(zh_story_id, "Done")`
3. Update sprint-status: status → "done", pr_status → "merged"
4. Continue to next story

If Review:
1. Pause loop
2. Output: "Review PR at {pr_url}. Run /zenhub:sequential {epic_name} to resume."
3. Stop command

If Skip:
1. Leave PR open
2. Continue to next story

---

## Completion

**When all stories are processed:**

```
Sequential Processing Complete!

Epic: {epic_name}

Results:
  STORY-{id_1}: {title} - Done (PR merged)
  STORY-{id_2}: {title} - Done (PR merged)
  STORY-{id_3}: {title} - Review/QA (PR open)

Points Completed: {completed}/{total}
Sub-tasks Completed: {sub_completed}/{sub_total}  (if sub-tasks)

Branch Status:
  epic/{branch} has {merged_count} stories merged

Next Steps:
  1. Review remaining open PRs
  2. When all PRs merged:
     Create epic → main PR:
     gh pr create --base main --head {epic_branch} --title "feat: {epic_name}"
  3. After epic PR merged: Move Epic → Done in ZenHub
```

---

## Resume Support

This command supports resuming from where it left off:

1. On start, check sprint-status.yaml for story statuses
2. Skip stories already in "done" status
3. Resume "in_progress" story (ask user: continue or restart?)
4. Start "not_started" stories normally

```
Resuming sequential processing for: {epic_name}

Previously completed:
  STORY-{id_1}: Done (PR merged)

Resuming from:
  STORY-{id_2}: In Progress (branch exists, partial implementation)

Continue where you left off? (y/n)
```

---

## Helper References

- **Load config:** `helpers.md#Combined-Config-Load`
- **Load sprint status:** `helpers.md#Load-Sprint-Status`
- **Update sprint status:** `helpers.md#Update-Sprint-Status`
- **Load ZenHub context:** `helpers.md#Load-ZenHub-Context`
- **Move pipeline:** `helpers.md#Move-Pipeline-with-Context`
- **Resolve branches:** `helpers.md#Resolve-Branch-Names`
- **Create branch hierarchy:** `helpers.md#Create-Branch-Hierarchy`
- **Create PR:** `helpers.md#Create-PR-and-Merge`

---

## Notes for LLMs

- Process stories strictly in order (dependencies first, then by story ID)
- For each story, follow the full dev-story implementation pattern (Parts 1-9)
- Sub-tasks (if present) serve as implementation checklist — move to Done as completed
- Always ask before merging PRs (the review decision point is critical)
- Support resume: check sprint-status for current state before starting loop
- ZenHub pipeline moves are best-effort (warn and continue on failure)
- If `gh` CLI unavailable: provide manual PR instructions and continue
- Update sprint-status.yaml after each story (not just at the end)
- This command bridges BMAD dev-story workflow with ZenHub pipeline management

**Remember:** Sequential processing is about focus and quality. One story at a time, fully implemented and reviewed, before moving on. This prevents context-switching overhead and ensures each story gets proper attention.
