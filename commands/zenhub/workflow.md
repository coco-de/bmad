ZenHub 파이프라인 관리 및 상태 운영을 위한 **ZenHub Workflow** 커맨드를 실행합니다.

## Command Overview

**Purpose:** Move issues between ZenHub pipelines, link PRs, check pipeline status

**Agent:** Developer / Scrum Master

**Inputs:** Issue identifier (ZenHub ID, GitHub issue number, or story ID), target action

**Output:** Updated ZenHub pipeline state, PR linkage confirmation

**Prerequisite:** ZenHub MCP available or conventions file with cached IDs

---

## Pre-Flight

1. **Load ZenHub context** per `helpers.md#Load-ZenHub-Context`
   - This loads conventions cache first, then attempts MCP connection
2. **If zh_available = false:**
   ```
   ZenHub MCP unavailable and no cached conventions found.

   To set up ZenHub integration:
     1. Ensure ZenHub MCP server is configured
     2. Run /zenhub:workflow to auto-discover workspace IDs
     3. Or manually create bmad/zenhub-conventions.yaml from template

   Template: ~/.claude/config/bmad/templates/zenhub-conventions.template.yaml
   ```
   **Stop command.**
3. **Load sprint status** per `helpers.md#Load-Sprint-Status` (if exists)
4. **Parse user input** to determine action (see Actions below)

---

## Actions

### Action: Move Pipeline

**Trigger:** User specifies issue + target pipeline (e.g., "move STORY-001 to In Progress")

**Steps:**
1. **Resolve issue ID:**
   - If STORY-{ID} provided: Look up zh_issue_id from sprint-status.yaml
   - If #{number} provided: Use directly as GitHub issue number
   - If ZenHub ID provided: Use directly

2. **Resolve target pipeline:**
   - Match user input to pipeline names (case-insensitive):
     - "backlog" / "product backlog" → Product Backlog
     - "sprint" / "sprint backlog" → Sprint Backlog
     - "progress" / "in progress" / "wip" → In Progress
     - "review" / "qa" / "review/qa" → Review/QA
     - "done" / "complete" → Done
   - Get pipeline ID from zh_pipelines map

3. **Call `helpers.md#Move-Pipeline-with-Context`:**
   - issueId: resolved zh_issue_id
   - pipeline_name: resolved target pipeline

4. **Update sprint-status.yaml** (if story found):
   - Update zh_pipeline field

5. **Display result:**
   ```
   ZenHub: #{issue_number} → {pipeline_name}
   ```

### Action: Link PR

**Trigger:** User wants to connect a PR to a ZenHub issue

**Steps:**
1. **Resolve issue ID** (same as Move Pipeline step 1)

2. **Get PR info:**
   - If PR URL provided: Extract PR number
   - If on a branch with open PR: Auto-detect via `gh pr view --json number`

3. **Call connectPullRequestWithIssue:**
   - issueId: zh_issue_id
   - pullRequestNumber: PR number

4. **Display result:**
   ```
   ZenHub: PR #{pr_number} linked to issue #{issue_number}
   ```

### Action: Status Check

**Trigger:** User asks for ZenHub status (e.g., "zenhub status", "pipeline status")

**Steps:**
1. **Load all stories from sprint-status.yaml**

2. **Group by pipeline:**
   ```
   ZenHub Pipeline Status:

   Sprint Backlog ({count}):
     #{num} STORY-001: {title} ({points} pts)
     #{num} STORY-002: {title} ({points} pts)

   In Progress ({count}):
     #{num} STORY-003: {title} ({points} pts)

   Review/QA ({count}):
     #{num} STORY-004: {title} ({points} pts)

   Done ({count}):
     #{num} STORY-005: {title} ({points} pts)

   Summary: {total} issues, {in_progress} in progress, {done} done
   ```

3. **If Sub-tasks enabled:**
   Add sub-task breakdown under each story:
   ```
   In Progress ({count}):
     #{num} STORY-003: {title} ({points} pts)
       Sub-tasks: {completed}/{total}
       #{sub_num} [Done] {sub_task_title}
       #{sub_num} [In Progress] {sub_task_title}
       #{sub_num} [Sprint Backlog] {sub_task_title}
   ```

### Action: Batch Move

**Trigger:** User wants to move multiple issues at once

**Steps:**
1. **Collect issue list** (e.g., "move STORY-001, STORY-002, STORY-003 to Sprint Backlog")
2. **Resolve all issue IDs**
3. **For each issue:**
   - Call `helpers.md#Move-Pipeline-with-Context`
   - Log result
4. **Display summary:**
   ```
   Batch Move Complete:
     #{num1} STORY-001 → Sprint Backlog
     #{num2} STORY-002 → Sprint Backlog
     #{num3} STORY-003 → Sprint Backlog
   Moved: {count}/{total}
   ```

---

## Helper References

- **Load ZenHub context:** `helpers.md#Load-ZenHub-Context`
- **Load conventions:** `helpers.md#Load-ZenHub-Conventions`
- **Load sprint status:** `helpers.md#Load-Sprint-Status`
- **Update sprint status:** `helpers.md#Update-Sprint-Status`
- **Move pipeline:** `helpers.md#Move-Pipeline-with-Context`

---

## Notes for LLMs

- This command works independently from BMAD workflows (no sprint plan required)
- Always try to resolve story IDs from sprint-status.yaml first
- Pipeline names should be matched case-insensitively with common aliases
- All pipeline moves are best-effort: log failures and continue
- Update sprint-status.yaml zh_pipeline field after successful moves
- If conventions file exists but MCP is unavailable, still show cached status from sprint-status.yaml

**Remember:** This is the quick-access ZenHub command. Keep interactions snappy and focused on the requested action.
