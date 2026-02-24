Epic + Story + Sub-task 계층을 생성하는 **ZenHub Create Epic** 커맨드를 실행합니다.

## Command Overview

**Purpose:** Create a single Epic with its Stories and optional Sub-tasks in ZenHub, with preview/confirm flow

**Agent:** Scrum Master / Product Manager

**Inputs:** Epic description (text, or image for requirements extraction), story breakdown

**Output:** ZenHub issues created (Epic + Stories + Sub-tasks), sprint-status.yaml updated

**Prerequisite:** ZenHub MCP available

---

## Pre-Flight

1. **Load ZenHub context** per `helpers.md#Load-ZenHub-Context`
2. **If zh_available = false:**
   ```
   ZenHub MCP unavailable. This command requires an active ZenHub MCP connection
   to create issues.

   Check your MCP server configuration and try again.
   ```
   **Stop command.**
3. **Load sprint status** per `helpers.md#Load-Sprint-Status` (if exists)
4. **Load project config** per `helpers.md#Combined-Config-Load`
5. **Check sub-task support:**
   - zh_sub_tasks_enabled from conventions or MCP discovery
   - If enabled: Sub-task creation will be offered

---

## Step 1: Gather Epic Information

**Option A: Text-based input**

Ask user:
```
Let's create an Epic. Please provide:

1. Epic name (short title)
2. Epic description (what does this epic deliver?)
3. Stories within this epic (list of story titles and brief descriptions)

Or provide a requirements document/image and I'll extract the structure.
```

**Option B: Image-based requirements extraction**

If user provides an image (screenshot, mockup, whiteboard photo):
1. Analyze the image for:
   - Feature areas → map to Stories
   - UI components → map to implementation tasks
   - User flows → map to acceptance criteria
2. Generate proposed Epic/Story structure from image analysis
3. Present for user review

**Option C: From sprint plan**

If user references existing sprint plan:
1. Load sprint plan document
2. Extract specified epic and its stories
3. Pre-populate all fields

---

## Step 2: Build Issue Hierarchy

**Structure the hierarchy:**

```
Epic: {epic_name}
├── Story 1: {story_title} ({points} pts)
│   ├── Sub-task 1.1: {sub_task_title}  (if sub-tasks enabled)
│   ├── Sub-task 1.2: {sub_task_title}
│   └── Sub-task 1.3: {sub_task_title}
├── Story 2: {story_title} ({points} pts)
│   ├── Sub-task 2.1: {sub_task_title}
│   └── Sub-task 2.2: {sub_task_title}
└── Story 3: {story_title} ({points} pts)
```

**For each story, prepare:**
- Title with [Story] prefix
- Body using `helpers.md#Generate-Story-Body`
- Story points estimate
- Acceptance criteria

**For each sub-task (if enabled), prepare:**
- Title with [Sub-task] prefix
- Body using `helpers.md#Generate-Sub-task-Body`
- Parent story reference

---

## Step 3: Preview and Confirm

**Display full preview before creating anything:**

```
=== ZenHub Issue Creation Preview ===

Epic: [Epic] {epic_name}
  Body: {first_100_chars}...
  Sprint: {sprint_name}
  Dates: {start_date} → {end_date}

Stories ({count}):
  1. [Story] {title_1} - {points} pts
     AC: {criteria_count} criteria
     Sub-tasks: {sub_task_count}  (if enabled)

  2. [Story] {title_2} - {points} pts
     AC: {criteria_count} criteria
     Sub-tasks: {sub_task_count}

  3. [Story] {title_3} - {points} pts
     AC: {criteria_count} criteria
     Sub-tasks: {sub_task_count}

Sub-tasks ({total_count}):  (if enabled)
  1.1 [Sub-task] {sub_task_title}
  1.2 [Sub-task] {sub_task_title}
  ...

Total Issues to Create: {epic + stories + sub_tasks count}
Total Story Points: {sum}

=== Actions ===
[C]onfirm - Create all issues
[E]dit - Modify before creating
[S]kip sub-tasks - Create epic + stories only
[A]bort - Cancel
```

**Wait for user confirmation before proceeding.**

---

## Step 4: Batch Create Issues

**Execute creation in dependency order:**

**Step 4.1: Create Epic**
1. Generate epic body per `helpers.md#Generate-Epic-Body`
2. Call `helpers.md#Sync-Epic-to-ZenHub`:
   - epic_name, epic_description, sprint dates
3. Store zh_epic_id
4. Log: `[1/{total}] Epic created: #{issue_number}`

**Step 4.2: Create Stories**

For each story:
1. Generate story body per `helpers.md#Generate-Story-Body`
2. Call `helpers.md#Sync-Story-to-ZenHub`:
   - story_title, story_body, story_points
   - zh_epic_id (parent)
   - sprint_id, pipeline_id
3. Store zh_story_id
4. Log: `[{n}/{total}] Story created: #{issue_number} (parent: Epic #{epic_number})`

**Step 4.3: Create Sub-tasks** (if confirmed)

For each sub-task:
1. Generate sub-task body per `helpers.md#Generate-Sub-task-Body`
2. Call `helpers.md#Sync-Sub-task-to-ZenHub`:
   - sub_task_title, sub_task_body
   - zh_story_id (parent)
3. Store zh_sub_task_id
4. Log: `[{n}/{total}] Sub-task created: #{issue_number} (parent: Story #{story_number})`

**Progress display:**
```
Creating ZenHub issues...
[1/12] Epic created: #42 [Epic] User Authentication
[2/12] Story created: #43 [Story] User Registration (parent: #42)
[3/12] Story created: #44 [Story] User Login (parent: #42)
[4/12] Sub-task created: #45 [Sub-task] Implement registration form (parent: #43)
...
[12/12] Sub-task created: #53 [Sub-task] Test login flow (parent: #44)
```

---

## Step 5: Update Local State

1. **Update sprint-status.yaml** (if exists):
   - Add/update epic entry with zh_issue_id, zh_issue_number, zh_issue_url
   - Add/update story entries with zh_issue_id, zh_issue_number, zh_issue_url
   - Add sub_tasks arrays to stories (if sub-tasks created)
   - Pre-compute branch names per `helpers.md#Resolve-Branch-Names`

2. **Store cross-references** per `helpers.md#Store-ZenHub-Cross-Reference`

---

## Step 6: Display Results

```
ZenHub Epic Created Successfully!

Epic: #{epic_number} {epic_name}
  URL: {epic_url}

Stories ({count}):
  #{story_1_number} {title_1} ({points} pts) → Sprint Backlog
  #{story_2_number} {title_2} ({points} pts) → Sprint Backlog
  #{story_3_number} {title_3} ({points} pts) → Sprint Backlog

Sub-tasks ({count}):  (if created)
  #{sub_1_number} {title} → parent #{story_number}
  #{sub_2_number} {title} → parent #{story_number}
  ...

Branch Names (pre-computed):
  epic/EPIC-{epic_number}-{slug}
    ├── story/STORY-{id_1}-{slug}
    ├── story/STORY-{id_2}-{slug}
    └── story/STORY-{id_3}-{slug}

Total Issues Created: {count}
Total Story Points: {sum}

Next Steps:
  1. /dev-story STORY-{first_id} - Start implementing
  2. /zenhub:workflow status - View pipeline status
  3. /zenhub:sequential - Process stories one by one
```

---

## Error Handling

**Partial failure:**
- If epic creation fails: Abort all (no orphan stories)
- If a story creation fails: Log error, continue with remaining stories
- If a sub-task creation fails: Log error, continue with remaining sub-tasks
- Display partial results with clear indication of what succeeded/failed

**Rate limiting:**
- If MCP returns rate limit errors: Wait and retry (up to 3 attempts)
- Between batch creates: No artificial delay needed (MCP handles rate limiting)

---

## Helper References

- **Load ZenHub context:** `helpers.md#Load-ZenHub-Context`
- **Sync epic:** `helpers.md#Sync-Epic-to-ZenHub`
- **Sync story:** `helpers.md#Sync-Story-to-ZenHub`
- **Sync sub-task:** `helpers.md#Sync-Sub-task-to-ZenHub`
- **Generate epic body:** `helpers.md#Generate-Epic-Body`
- **Generate story body:** `helpers.md#Generate-Story-Body`
- **Generate sub-task body:** `helpers.md#Generate-Sub-task-Body`
- **Store xref:** `helpers.md#Store-ZenHub-Cross-Reference`
- **Resolve branches:** `helpers.md#Resolve-Branch-Names`
- **Load sprint status:** `helpers.md#Load-Sprint-Status`
- **Update sprint status:** `helpers.md#Update-Sprint-Status`

---

## Notes for LLMs

- Always show preview and wait for confirmation before creating issues
- Create issues in dependency order: Epic first, then Stories, then Sub-tasks
- Each issue needs its parent ID from the previous step
- Use Generate Body helpers for consistent issue formatting
- Sub-tasks are only offered if zh_sub_tasks_enabled = true
- Update sprint-status.yaml after successful batch creation
- On partial failure: report what succeeded and what failed clearly
- Image analysis (Option B) should extract UI components, user flows, and features
- This command works independently — no BMAD sprint plan required (but integrates if available)

**Remember:** The preview/confirm flow is non-negotiable. Never create ZenHub issues without explicit user approval of the plan.
