# BMAD v6 Helper Utilities

This document contains reusable utilities for BMAD workflows. Skills and commands can reference specific sections to avoid repetition.

## Config Loading

### Load Global Config
```
Path: ~/.claude/config/bmad/config.yaml
Purpose: Get user settings, enabled modules, defaults

Using Read tool:
1. Read ~/.claude/config/bmad/config.yaml
2. Parse YAML to extract:
   - user_name
   - communication_language
   - default_output_folder
   - modules_enabled
3. Store in memory for workflow
```

### Load Project Config
```
Path: {project-root}/bmad/config.yaml
Purpose: Get project-specific settings

Using Read tool:
1. Read bmad/config.yaml
2. Parse YAML to extract:
   - project_name
   - project_type
   - project_level
   - output_folder
3. Merge with global config (project overrides global)
```

### Combined Config Load
```
Execute in order:
1. Load global config (defaults)
2. Load project config (overrides)
3. Return merged config object
```

## Status File Operations

### Load Workflow Status
```
Path: {output_folder}/bmm-workflow-status.yaml (from project config)
Purpose: Check completed workflows, current phase

Using Read tool:
1. Read docs/bmm-workflow-status.yaml (or path from config)
2. Parse YAML to extract:
   - project metadata
   - workflow_status array
3. Determine current phase:
   - Find last completed workflow (status = file path)
   - Identify next required/recommended workflow
```

### Update Workflow Status
```
Purpose: Mark workflow as complete

Using Edit tool:
1. Load current status file
2. Find workflow by name
3. Update status field: "{file-path}"
4. Update last_updated: current timestamp
5. Save changes
```

### Load Sprint Status
```
Path: {output_folder}/sprint-status.yaml
Purpose: Check epic/story progress

Using Read tool:
1. Read docs/sprint-status.yaml
2. Parse YAML to extract:
   - sprint_number
   - epics array
   - stories within epics
   - metrics
```

### Update Sprint Status
```
Purpose: Add/update epics and stories

Using Edit tool:
1. Load current sprint status
2. Modify epics/stories array
3. Recalculate metrics
4. Update last_updated timestamp
5. Save changes
```

## Git Branch Strategy

### Resolve Branch Names
```
Purpose: Compute epic/story/task branch names from sprint-status story entry

Input: story entry (story_id, epic info, title)
Output: { epic_branch, story_branch, task_prefix }

Steps:
1. Extract epic identifier:
   - epic_number = epic's ZenHub issue number (e.g., 025)
   - epic_slug = epic name → lowercase, spaces/special → hyphens, max 40 chars
   - Example: "CoUI Flutter Maintenance" → "coui-flutter-maintenance"

2. Build epic branch name:
   - Format: epic/EPIC-{number}-{epic_slug}
   - Example: epic/EPIC-025-coui-flutter-maintenance

3. Extract story identifier:
   - story_id from sprint-status (e.g., "STORY-008")
   - story_slug = story title → lowercase, spaces/special → hyphens, max 40 chars
   - Example: "DCM Warning Zero" → "dcm-warning-zero"

4. Build story branch name:
   - Format: story/STORY-{id}-{story_slug}
   - Example: story/STORY-008-dcm-warning-zero

5. Build task prefix:
   - Format: task/STORY-{id}-
   - Example: task/STORY-008-

6. Return:
   epic_branch: "epic/EPIC-{number}-{epic_slug}"
   story_branch: "story/STORY-{id}-{story_slug}"
   task_prefix: "task/STORY-{id}-"
```

### Create Branch Hierarchy
```
Purpose: Create epic and story branches in correct hierarchy

Input: epic_branch, story_branch (from Resolve Branch Names)
Requires: git repository

Steps:
1. Check if epic branch exists:
   git branch -a | grep "{epic_branch}"

2. If epic branch does NOT exist:
   git checkout main
   git pull origin main
   git checkout -b {epic_branch}
   git push -u origin {epic_branch}
   Log: "✓ Created epic branch: {epic_branch}"

3. Check if story branch exists:
   git branch -a | grep "{story_branch}"

4. If story branch does NOT exist:
   git checkout {epic_branch}
   git pull origin {epic_branch}
   git checkout -b {story_branch}
   git push -u origin {story_branch}
   Log: "✓ Created story branch: {story_branch}"

5. If story branch already exists:
   git checkout {story_branch}
   git pull origin {story_branch}
   Log: "✓ Switched to existing story branch: {story_branch}"

Fallback:
  If any git operation fails:
  - Log warning: "⚠ Failed to create branch hierarchy. Falling back to flat branch."
  - git checkout main
  - git checkout -b feature/STORY-{ID}
  - Return fallback branch name
```

### Create Task Branch
```
Purpose: Create a task branch from the story branch for large tasks

Input: story_branch, task_slug (short description)
Output: task branch name

Steps:
1. Ensure on story branch:
   git checkout {story_branch}
   git pull origin {story_branch}

2. Build task branch name:
   - Format: task/STORY-{id}-{task_slug}
   - Example: task/STORY-008-fix-lint-rules

3. Create and push task branch:
   git checkout -b {task_branch}
   git push -u origin {task_branch}
   Log: "✓ Created task branch: {task_branch}"

4. Return task branch name
```

### Create PR and Merge
```
Purpose: Create a pull request and optionally merge it

Input: source_branch, target_branch, pr_title, pr_body, merge_strategy
  merge_strategy: "squash" (task→story) | "merge" (story→epic, epic→main)

Steps:
1. Push source branch:
   git push origin {source_branch}

2. Check if gh CLI is available:
   which gh

3. If gh CLI available:
   a. Create PR:
      gh pr create --base {target_branch} --head {source_branch} \
        --title "{pr_title}" --body "{pr_body}"
   b. Extract PR URL from output
   c. Log: "✓ PR created: {pr_url}"
   d. If auto-merge requested (task→story only):
      gh pr merge {pr_url} --squash --delete-branch
      Log: "✓ PR merged (squash): {source_branch} → {target_branch}"

4. If gh CLI NOT available:
   Log: "⚠ gh CLI not installed. Please create PR manually:"
   Log: "  Source: {source_branch}"
   Log: "  Target: {target_branch}"
   Log: "  Title: {pr_title}"
   Log: "  Merge strategy: {merge_strategy}"
   Return manual_pr_needed = true

5. Return { pr_url, merged, manual_pr_needed }

Merge strategy reference:
  - task → story: squash merge (clean commit history)
  - story → epic: merge commit (preserve story history)
  - epic → main: merge commit (preserve epic history)
```

## ZenHub Integration

### Load ZenHub Context
```
Purpose: Initialize ZenHub MCP connection and load workspace metadata

Steps:
1. Call getWorkspacePipelinesAndRepositories()
   - Extract GitHub repository ID (graphql ID for createGitHubIssue)
   - Extract ZenHub organization ID (for setDatesForIssue)
   - Extract pipeline IDs by name:
     - "Product Backlog" → zh_pipelines["Product Backlog"]
     - "Sprint Backlog" → zh_pipelines["Sprint Backlog"]
     - "In Progress" → zh_pipelines["In Progress"]
     - "Review/QA" → zh_pipelines["Review/QA"]
     - "Done" → zh_pipelines["Done"]

2. Call getIssueTypes(repositoryId: zh_github_repo_id)
   - Map issue type names to IDs:
     - "Epic" → zh_issue_types["Epic"]
     - "Feature" → zh_issue_types["Feature"]
     - "Task" → zh_issue_types["Task"]

3. Call getSprint() → zh_active_sprint (id, name, dates)
   Call getUpcomingSprint() → zh_next_sprint (id, name, dates)

4. Set zh_available = true

On any failure:
  - Set zh_available = false
  - Output warning: "⚠ ZenHub MCP unavailable. Continuing with local-only workflow."
  - Continue with existing workflow (no abort)
```

### Sync Epic to ZenHub
```
Purpose: Create a GitHub issue for an epic and set its ZenHub type

Input: epic_name, epic_description, sprint_start_date, sprint_end_date
Requires: zh_available = true, zh_github_repo_id, zh_issue_types["Epic"]

Steps:
1. Call createGitHubIssue:
   - repositoryId: zh_github_repo_id
   - title: "[Epic] {epic_name}"
   - body: epic_description (markdown)

2. Extract zh_epic_id from response

3. Call setIssueType:
   - issueIds: [zh_epic_id]
   - issueTypeId: zh_issue_types["Epic"]

4. If sprint dates available, call setDatesForIssue:
   - issueId: zh_epic_id
   - zenhubOrganizationId: zh_org_id
   - startDate: sprint_start_date (YYYY-MM-DD)
   - endDate: sprint_end_date (YYYY-MM-DD)

5. Return zh_epic_id and GitHub issue URL/number
```

### Sync Story to ZenHub
```
Purpose: Create a GitHub issue for a story, link to epic, set estimate and sprint

Input: story_title, story_body, story_points, zh_epic_id (optional),
       sprint_id (optional), pipeline_id
Requires: zh_available = true, zh_github_repo_id, zh_issue_types["Feature"]

Steps:
1. Call createGitHubIssue:
   - repositoryId: zh_github_repo_id
   - title: "[Story] {story_title}"
   - body: story_body (markdown - include user story, acceptance criteria, technical notes)
   - parentIssueId: zh_epic_id (if available)

2. Extract zh_story_id and issue number/URL from response

3. Call setIssueType:
   - issueIds: [zh_story_id]
   - issueTypeId: zh_issue_types["Feature"]

4. Call setIssueEstimate:
   - issueId: zh_story_id
   - estimate: story_points

5. If sprint_id available, call addIssuesToSprints:
   - issueIds: [zh_story_id]
   - sprintIds: [sprint_id]

6. Call moveIssueToPipeline:
   - issueId: zh_story_id
   - pipelineId: pipeline_id (Sprint Backlog or Product Backlog)

7. Return zh_story_id, issue number, GitHub issue URL
```

### Sync Story Dependencies to ZenHub
```
Purpose: Create blocking relationships between stories in ZenHub

Input: dependency_map (array of {blocking_story_id, blocked_story_id})
Requires: zh_available = true

Steps:
1. For each dependency in dependency_map:
   - Resolve local story IDs to zh_issue_ids (from cross-reference)
   - Call createBlockage:
     - blockingIssueId: zh_id of blocking story
     - blockedIssueId: zh_id of blocked story

2. Log each dependency created
3. Skip if either story has no zh_issue_id (warn and continue)
```

### Store ZenHub Cross-Reference
```
Purpose: Add ZenHub metadata to local documents for traceability

Input: local_doc_path, zh_issue_id, zh_issue_number, zh_issue_url

Steps:
1. If local story document exists (docs/stories/STORY-{ID}.md):
   - Add ZenHub reference section or update existing:
     **ZenHub:** #{zh_issue_number} ({zh_issue_url})

2. If sprint-status.yaml exists:
   - Find story entry by story_id
   - Add/update fields:
     zh_issue_id: "{zh_issue_id}"
     zh_issue_number: {zh_issue_number}
     zh_issue_url: "{zh_issue_url}"
```

### Move Pipeline with Context
```
Purpose: Move a ZenHub issue to a pipeline by name with error handling

Input: zh_issue_id, pipeline_name (e.g., "In Progress", "Review/QA", "Done")
Requires: zh_available = true, zh_pipelines map

Steps:
1. Resolve pipeline_name to pipeline_id:
   pipeline_id = zh_pipelines[pipeline_name]
   If not found: Log warning and return

2. Call moveIssueToPipeline:
   - issueId: zh_issue_id
   - pipelineId: pipeline_id

3. Log: "✓ ZenHub: #{issue_number} → {pipeline_name}"

On failure:
  - Log: "⚠ ZenHub pipeline move failed for #{issue_number} → {pipeline_name}. Continuing."
  - Do NOT abort workflow — pipeline moves are best-effort
```

## Template Operations

### Load Template
```
Purpose: Load document template for workflow

Using Read tool:
1. Read template from: ~/.claude/config/bmad/templates/{workflow-name}.md
2. Store template content
3. Extract variable placeholders: {{variable_name}}
```

### Apply Variables to Template
```
Purpose: Substitute {{variables}} with actual values

Process:
1. For each variable in template:
   - {{project_name}} → from config
   - {{date}} → current date (YYYY-MM-DD)
   - {{timestamp}} → current ISO timestamp
   - {{user_name}} → from global config
   - {{custom_var}} → from user input
2. Replace all {{variable}} with values
3. Return completed document
```

### Save Output Document
```
Purpose: Write completed document to output folder

Using Write tool:
1. Determine output path:
   - {output_folder}/{workflow-name}-{project-name}-{date}.md
   - Example: docs/prd-myapp-2025-01-11.md
2. Write content to path
3. Return file path for status update
```

## Variable Substitution

### Standard Variables
```
{{project_name}}           → config: project_name
{{project_type}}           → config: project_type
{{project_level}}          → config: project_level
{{user_name}}              → config: user_name
{{date}}                   → current date (YYYY-MM-DD)
{{timestamp}}              → current timestamp (ISO 8601)
{{output_folder}}          → config: output_folder
```

### Conditional Variables
```
{{PRD_STATUS}}             → "required" if level >= 2, else "recommended"
{{TECH_SPEC_STATUS}}       → "required" if level <= 1, else "optional"
{{ARCHITECTURE_STATUS}}    → "required" if level >= 2, else "optional"
```

### Level-Based Logic
```
Level 0 (1 story):         PRD optional, tech-spec required, no architecture
Level 1 (1-10 stories):    PRD recommended, tech-spec required, no architecture
Level 2 (5-15 stories):    PRD required, tech-spec optional, architecture required
Level 3 (12-40 stories):   PRD required, tech-spec optional, architecture required
Level 4 (40+ stories):     PRD required, tech-spec optional, architecture required
```

## Workflow Recommendations

### Determine Next Workflow
```
Input: workflow_status array
Output: recommended next workflow

Logic:
1. If no product-brief and project new → Recommend: /product-brief
2. If product-brief complete, no PRD/tech-spec → Recommend based on level:
   - Level 0-1: /tech-spec
   - Level 2+: /prd
3. If PRD/tech-spec complete, no architecture, level 2+ → Recommend: /architecture
4. If architecture complete (or not required) → Recommend: /sprint-planning
5. If sprint active → Recommend: /create-story or /dev-story
```

### Status Display Format
```
✓ = Completed (green)
⚠ = Required but not started (yellow)
→ = Current phase indicator
- = Optional/not required

Example:
✓ Phase 1: Analysis
  ✓ product-brief (docs/product-brief-myapp-2025-01-11.md)
  - research (optional)

→ Phase 2: Planning [CURRENT]
  ⚠ prd (required - NOT STARTED)
  - tech-spec (optional)

Phase 3: Solutioning
  - architecture (required)
```

## Path Resolution

### Resolve Project Root
```
Method: Use environment or detect
- Claude Code provides working directory
- Use `{project-root}` as placeholder
- Replace at runtime with actual path
```

### Resolve Config Paths
```
~/.claude/config/bmad/config.yaml           → Global config
{project-root}/bmad/config.yaml             → Project config
{project-root}/{output_folder}              → Output directory (usually docs/)
```

### Resolve Template Paths
```
~/.claude/config/bmad/templates/{name}.md   → Template files
```

## Error Handling

### File Not Found
```
If config file missing:
  - Use defaults
  - Prompt user to run /workflow-init

If status file missing:
  - Inform user project not initialized
  - Offer to run /workflow-init

If template missing:
  - Use inline template
  - Log warning
```

### Invalid YAML
```
If YAML parse error:
  - Show error message
  - Provide file path
  - Suggest manual fix or reinit
```

## Token Optimization Tips

### Reference vs. Embed
```
✓ Good: "Follow helper instructions in utils/helpers.md#Load-Global-Config"
✗ Bad: Embed full instructions in every command

✓ Good: "Use standard variables from helpers.md#Standard-Variables"
✗ Bad: List all variables in every template
```

### Lazy Loading
```
✓ Good: Load config only when needed
✗ Bad: Load all files upfront

✓ Good: Read status file when checking progress
✗ Bad: Keep status in memory throughout chat
```

### Reuse Patterns
```
✓ Good: "Execute Step 1-3 from helpers.md#Combined-Config-Load"
✗ Bad: Repeat config loading steps in every workflow
```

## Quick Reference Commands

### For Skills/Commands
```
To load config: See helpers.md#Combined-Config-Load
To check status: See helpers.md#Load-Workflow-Status
To update status: See helpers.md#Update-Workflow-Status
To use template: See helpers.md#Load-Template + helpers.md#Apply-Variables-to-Template
To save output: See helpers.md#Save-Output-Document
To recommend next: See helpers.md#Determine-Next-Workflow
To init ZenHub: See helpers.md#Load-ZenHub-Context
To sync epic: See helpers.md#Sync-Epic-to-ZenHub
To sync story: See helpers.md#Sync-Story-to-ZenHub
To sync deps: See helpers.md#Sync-Story-Dependencies-to-ZenHub
To store xref: See helpers.md#Store-ZenHub-Cross-Reference
To resolve branches: See helpers.md#Resolve-Branch-Names
To create branch hierarchy: See helpers.md#Create-Branch-Hierarchy
To create task branch: See helpers.md#Create-Task-Branch
To create PR: See helpers.md#Create-PR-and-Merge
To move pipeline: See helpers.md#Move-Pipeline-with-Context
To check Agent Teams: See helpers.md#Check-Agent-Teams-Available
To spawn teammate: See helpers.md#Spawn-BMAD-Teammate
To create team tasks: See helpers.md#Create-Team-Task-List
To collect results: See helpers.md#Collect-Team-Results
To run quality gate: See helpers.md#Team-Quality-Gate
```

## Agent Teams Integration

### Check Agent Teams Available
```
Purpose: Detect if Claude Code Agent Teams feature is available

Steps:
1. Check environment variable:
   CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS

2. If set and truthy:
   - Set teams_available = true
   - Log: "✓ Agent Teams available (experimental)"

3. If NOT set or falsy:
   - Set teams_available = false
   - Log: "⚠ Agent Teams not available. Use sequential workflows instead."
   - Provide guidance:
     "To enable Agent Teams, set the environment variable:
      CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
      Then restart Claude Code."

4. Return teams_available flag
```

### Spawn BMAD Teammate
```
Purpose: Launch a teammate with role-specific context and constraints

Input: role (developer|reviewer|story-creator), context_payload
Requires: teams_available = true

Role-specific prompt construction:

--- developer role ---
Prompt:
  "You are a BMAD Developer teammate. Your assignment:

   ## Story
   {story_document_content}

   ## Architecture Summary
   {architecture_key_sections}

   ## File Ownership
   You MUST only modify files in these paths:
   {owned_file_paths}
   Do NOT modify any files outside your ownership boundary.

   ## Branch
   Work on branch: {story_branch}
   Epic branch: {epic_branch}

   ## Quality Standards
   - All acceptance criteria must pass
   - Write tests alongside implementation
   - Run lint/typecheck before completing
   - Follow existing project conventions

   ## Constraints
   - Do NOT modify sprint-status.yaml (Lead only)
   - Report completion via task update
   - If blocked, update task with blocker description"

--- reviewer role ---
Prompt:
  "You are a BMAD Reviewer teammate. Your assignment:

   ## Review Target
   Document: {document_path}
   Type: {document_type}

   ## Review Perspective
   Role: {review_perspective} (PM|Architect|Developer|Scrum Master)
   Focus: {review_focus_description}

   ## Checklist
   {review_checklist_items}

   ## Output
   Write your review to: {review_output_path}
   Format:
   - Overall Assessment: (Pass/Conditional Pass/Fail)
   - Strengths: (bullet list)
   - Issues: (numbered, with severity: Critical/Major/Minor)
   - Recommendations: (bullet list)

   ## Constraints
   - Do NOT modify the reviewed document
   - Do NOT modify sprint-status.yaml (Lead only)
   - Report completion via task update"

--- story-creator role ---
Prompt:
  "You are a BMAD Story Creator teammate. Your assignment:

   ## Epic
   {epic_name}: {epic_description}

   ## Stories to Create
   {story_id_list_with_titles}

   ## Story Template
   Follow the standard BMAD story template:
   - User Story (As a... I want... So that...)
   - Description (Background, Scope, User Flow)
   - Acceptance Criteria (testable, specific)
   - Technical Notes (components, APIs, DB changes)
   - Dependencies
   - Definition of Done
   - Story Points (Fibonacci: 1,2,3,5,8,13)

   ## Architecture Context
   {architecture_key_sections}

   ## Output
   Write each story to: docs/stories/{story_id}.md
   Each teammate creates DIFFERENT story files — no conflicts.

   ## Constraints
   - Do NOT modify sprint-status.yaml (Lead only)
   - Do NOT modify other teammates' story files
   - Report completion via task update"

Common footer appended to ALL roles:
  "IMPORTANT CONSTRAINTS:
   - Never modify sprint-status.yaml — only the Lead updates status files
   - Complete your work and mark your task as completed
   - If you encounter issues, describe them in your task update"
```

### Create Team Task List
```
Purpose: Create shared task list for teammate coordination

Input: assignments (array of {teammate_role, description, context})
Output: task_ids array

Steps:
1. For each assignment:
   a. Call TaskCreate:
      - subject: "{role}: {short_description}"
      - description: Full assignment details including file ownership
      - activeForm: "{role_verb} {short_description}"
   b. Store returned task_id

2. Set up dependencies (if any):
   For each dependency pair (blocking_task_id, blocked_task_id):
     Call TaskUpdate:
       - taskId: blocked_task_id
       - addBlockedBy: [blocking_task_id]

3. Return array of task_ids for monitoring

Example:
  TaskCreate: "developer: Implement STORY-001 user registration"
  TaskCreate: "developer: Implement STORY-002 user login"
  TaskUpdate: task_2 addBlockedBy [task_1]  (if STORY-002 depends on STORY-001)
```

### Collect Team Results
```
Purpose: Gather and summarize teammate outputs after completion

Input: task_ids (from Create-Team-Task-List)
Output: results summary

Steps:
1. Poll task status:
   Call TaskList
   Filter to team task_ids
   Check status of each task

2. For each completed task:
   a. Call TaskGet(task_id) to retrieve final details
   b. Identify output artifacts:
      - developer: Modified files, test results
      - reviewer: Review document at {review_output_path}
      - story-creator: Story documents in docs/stories/

3. For each still-in-progress task:
   - Log: "⏳ {task_subject}: still in progress"

4. Build integrated summary:
   Completed: {count}/{total}
   Artifacts:
     - {file_path_1}: {description}
     - {file_path_2}: {description}
   Issues Reported:
     - {task_id}: {issue_description} (if any)

5. Return summary object
```

### Team Quality Gate
```
Purpose: Run automated quality checks on teammate work

Input: story_branch (branch to validate)
Output: { passed: boolean, results: object }

Steps:
1. Detect project type:
   - Check for package.json → Node.js/TypeScript
   - Check for pubspec.yaml → Flutter/Dart
   - Check for requirements.txt/pyproject.toml → Python
   - Check for Cargo.toml → Rust
   - Check for go.mod → Go

2. Switch to story branch:
   git checkout {story_branch}

3. Run quality checks based on project type:

   Node.js/TypeScript:
     lint: npm run lint (or npx eslint .)
     typecheck: npx tsc --noEmit (if tsconfig.json exists)
     test: npm test

   Flutter/Dart:
     lint: dart analyze (or melos run analyze)
     format: dart format --set-exit-if-changed .
     test: flutter test (or melos run test)

   Python:
     lint: pylint src/ (or ruff check .)
     typecheck: mypy src/ (if mypy installed)
     test: pytest

4. Collect results:
   lint_passed: boolean
   typecheck_passed: boolean
   tests_passed: boolean
   test_count: number
   coverage: percentage (if available)

5. Determine gate result:
   passed = lint_passed AND typecheck_passed AND tests_passed

6. Return:
   {
     passed: boolean,
     lint: { passed, output_summary },
     typecheck: { passed, output_summary },
     tests: { passed, count, coverage },
     branch: story_branch
   }

On failure:
  Log: "❌ Quality gate failed for {story_branch}"
  Log details of each failed check
  Return passed = false (do NOT auto-fix — report to Lead for decision)
```
