---
skill_id: bmad-core-master
name: BMad Master
description: Orchestrates BMAD workflows for structured AI-driven development. Use when initializing BMAD in projects, checking workflow status, or routing between 4 phases (Analysis, Planning, Solutioning, Implementation). Manages project configs, tracks progress through project levels 0-4, and coordinates with specialized workflows. Make sure to use this skill whenever the user mentions BMAD setup, project initialization, workflow status, phase transitions, or wants to start any structured development process — even if they don't explicitly say "BMAD". Also triggers on /workflow-init, /workflow-status, or any request about project progress tracking.
version: 6.1.0
module: core
---

# BMAD Orchestrator

**Purpose:** Core orchestrator for the BMAD Method (Breakthrough Method for Agile AI-Driven Development), managing workflows, tracking status, and routing users through structured development phases.

## Quick Start

```bash
# Initialize BMAD in your project
/workflow-init

# Start a full BMAD workflow
/bmad "Add user authentication"

# Check current progress
/workflow-status

# Run a specific persona review
/bmad:review --persona architect "Review current PR"

# Manually verify a phase gate
/bmad:gate --phase analysis
```

## When to Use This Skill

Use this skill when:
- User requests `/workflow-init` or `/init` - Initialize BMAD in a project
- User requests `/workflow-status` or `/status` - Check progress and get recommendations
- User mentions "BMAD setup" or "start BMAD workflow"
- Project needs structured development methodology
- Coordination between multiple development phases is required

## Core Responsibilities

1. **Project Initialization** - Set up BMAD directory structure and configuration
2. **Status Tracking** - Monitor progress across 4 development phases
3. **Workflow Routing** - Direct users to appropriate next steps based on project state
4. **Progress Management** - Maintain workflow status and completion tracking

## BMAD Method Overview

### 4 Development Phases

1. **Analysis** (Optional) - Research, brainstorming, product brief
2. **Planning** (Required) - PRD or Tech Spec based on project complexity
3. **Solutioning** (Conditional) - Architecture design for medium+ projects
4. **Implementation** (Required) - Sprint planning, stories, development

### Project Levels

- **Level 0:** Single atomic change (1 story) - Quick fixes, small tweaks
- **Level 1:** Small feature (1-10 stories) - Single feature additions
- **Level 2:** Medium feature set (5-15 stories) - Multiple related features
- **Level 3:** Complex integration (12-40 stories) - System integrations
- **Level 4:** Enterprise expansion (40+ stories) - Large-scale projects

**Planning Requirements by Level:**
- Level 0-1: Tech Spec required, PRD optional/recommended
- Level 2+: PRD required, Tech Spec optional
- Level 2+: Architecture required

## Persona Overview

BMAD uses 7 specialized personas across the 4 development phases:

| Persona | Phase | Role |
|---------|-------|------|
| Analyst | Analysis | Requirements analysis, **BDD Gherkin AC authoring** |
| Product Manager | Planning | Issue structuring, Story Point estimation |
| Architect | Solutioning | Architecture design review |
| UX Designer | Solutioning | UI/UX design review |
| Frontend Developer | Implementation | Frontend implementation |
| Backend Developer | Implementation | Backend implementation |
| Scrum Master | Implementation | Workflow management |

## Workflow Execution Flow

```
╔════════════════════════════════════════════════════════════════╗
║  BMAD Workflow                                                 ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Phase 1: ANALYSIS                                             ║
║  ├── Analyst review                                            ║
║  │   ├── Requirements analysis                                 ║
║  │   ├── BDD Gherkin AC authoring                              ║
║  │   └── Feasibility review                                    ║
║  └── Gate: Requirements clarity, scope, AC format              ║
║                                                                ║
║  Phase 2: PLANNING                                             ║
║  ├── Product Manager review                                    ║
║  │   ├── Epic/Story structuring                                ║
║  │   ├── Story Point estimation                                ║
║  │   └── Issue creation                                        ║
║  └── Gate: Structure, points, labeling, dependencies           ║
║                                                                ║
║  Phase 3: SOLUTIONING (parallel)                               ║
║  ├── Architect review                                          ║
║  │   ├── Clean Architecture                                    ║
║  │   ├── DI structure                                          ║
║  │   └── API design                                            ║
║  ├── UX Designer review                                        ║
║  │   ├── Design system compliance                              ║
║  │   ├── Layout                                                ║
║  │   └── Interactions                                          ║
║  └── Gate: All reviews passed                                  ║
║                                                                ║
║  Phase 4: IMPLEMENTATION                                       ║
║  ├── Frontend Developer                                        ║
║  ├── Backend Developer                                         ║
║  ├── Scrum Master (workflow management)                        ║
║  └── Gate: Lint, tests, code review                            ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

## Phase Gate System

All gates are **mandatory** - a failed gate blocks progression to the next phase.

```
Gate FAILED → Feedback provided → Fix issues → Re-review required
Gate PASSED → Automatic progression to next phase
```

### Gate Validation Items

| Gate | Required Validations |
|------|---------------------|
| Analysis | Requirements clarity, scope appropriateness, **AC in BDD Gherkin format**, AC completeness (happy-path + error-handling) |
| Planning | Epic/Story structure, Story Points (1-8), labeling, dependencies |
| Solutioning | Clean Architecture, DI structure, API design, design system compliance, layout, interactions |
| Implementation | Branch naming, lint passing, tests passing, code review completed |

### BDD Gherkin Acceptance Criteria

Acceptance criteria **must** be written in BDD Gherkin Given-When-Then format. The Analysis Gate validates AC format compliance.

```gherkin
Feature: User Authentication

  Scenario: Successful login with valid credentials
    Given the user is on the login page
    When they enter valid credentials
    And tap the login button
    Then they should be redirected to the home page

  Scenario: Login failure with invalid password
    Given the user is on the login page
    When they enter an invalid password
    And tap the login button
    Then an error message should be displayed
```

**Requirements:**
- Every story must have at least one happy-path scenario
- Error-handling scenarios are required for user-facing features
- Each scenario should be testable and unambiguous

## Feedback Loop

When a gate fails, the orchestrator provides structured feedback and requires re-review before proceeding.

```
╔════════════════════════════════════════════════════════════════╗
║  Phase 3 Gate: FAILED                                         ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Rejection reason:                                             ║
║  - Architect: Service layer bypasses domain abstractions       ║
║                                                                ║
║  Required actions:                                             ║
║  1. Introduce a use case / interactor for the operation        ║
║  2. Route service calls through the domain layer               ║
║                                                                ║
║  After fixes, re-review required:                              ║
║     /bmad:review --persona architect --retry                   ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

### Re-review Commands

```bash
# Re-review by specific persona
/bmad:review --persona architect --retry

# Re-review entire phase gate
/bmad:gate --phase solutioning --retry
```

## Emergency Mode

For production incidents or urgent situations, gates can be streamlined with user approval.

### Approval Flow

```
1. /bmad --emergency "Emergency fix description"
2. Claude requests approval via AskUserQuestion:
   ┌─────────────────────────────────────────────────────────────┐
   │  ⚠️ Emergency Mode Approval Request                         │
   │                                                             │
   │  Emergency mode skips Analysis and Planning gates.          │
   │  Implementation gate (lint, tests) remains mandatory.       │
   │                                                             │
   │  Do you approve?                                            │
   │  [Yes, approve] [No, use normal mode]                       │
   └─────────────────────────────────────────────────────────────┘
3. If approved: Streamlined workflow proceeds
4. If denied: Falls back to normal BMAD workflow
5. After completion: Post-incident review required within 48 hours
```

### Emergency Mode Constraints

| Item | Emergency Behavior |
|------|--------------------|
| Analysis Gate | Skipped |
| Planning Gate | Skipped |
| Solutioning Gate | Simplified (basic review only) |
| Implementation Gate | **Mandatory** (lint + tests required) |
| Post-incident Review | **Mandatory** (within 48 hours, Architect + PM) |

## Visual Progress Indicators

Use these ASCII box templates for workflow progress display:

### In-Progress Display

```
╔════════════════════════════════════════════════════════════════╗
║  BMAD Workflow: "Add user authentication"                      ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Phase 1: ANALYSIS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ✅        ║
║  Phase 2: PLANNING ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ✅         ║
║  Phase 3: SOLUTIONING ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 🔄        ║
║  Phase 4: IMPLEMENTATION ━━━━━━━━━━━━━━━━━━━━━━━━━━ ⏳        ║
║                                                                ║
║  Current: Architect review in progress (UX Designer complete)  ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

### Completion Display

```
╔════════════════════════════════════════════════════════════════╗
║  BMAD Workflow Complete: "Add user authentication"             ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  ✅ Phase 1: ANALYSIS - Approved                               ║
║  ✅ Phase 2: PLANNING - Issue #42 created                      ║
║  ✅ Phase 3: SOLUTIONING - Design approved                     ║
║  ✅ Phase 4: IMPLEMENTATION - PR #45 merged                    ║
║                                                                ║
║  Summary:                                                      ║
║     - Reviews passed: 7/7 personas                             ║
║     - Gates passed: 4/4 phases                                 ║
║     - Retries: 1 (Architect)                                   ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

## Available Commands

### /workflow-init or /init

Initialize BMAD structure in the current project.

**Steps:**
1. Create directory structure:
   ```
   bmad/
   ├── config.yaml
   └── agent-overrides/

   docs/
   ├── bmm-workflow-status.yaml
   └── stories/

   .claude/commands/bmad/ (if not exists)
   ```

2. Collect project information:
   - Project name
   - Project type (web-app, mobile-app, api, game, library, other)
   - Project level (0-4)

3. Create project config using [config.template.yaml](templates/config.template.yaml)

4. Create workflow status file with conditional requirements based on level:
   - Use [workflow-status template](templates/config.template.yaml)
   - Set PRD: required if level >= 2, else recommended
   - Set Tech-spec: required if level <= 1, else optional
   - Set Architecture: required if level >= 2, else optional

5. Display initialization summary and recommend next workflow

6. Offer to start recommended workflow

**Example interaction:**
```
User: /workflow-init

Orchestrator: I'll initialize BMAD for your project.
[Collects info, creates files...]

✓ BMAD Method initialized!

Project: MyApp
Type: web-app
Level: 2 (Medium feature set)

Configuration: bmad/config.yaml
Status tracking: docs/bmm-workflow-status.yaml

Recommended next step: Create Product Brief with /product-brief
This will help define your product vision and requirements.

Would you like to start with /product-brief?
```

### /workflow-status or /status

Check project status and get recommendations for next steps.

**Steps:**
1. Load project config (bmad/config.yaml)
2. Load workflow status (docs/bmm-workflow-status.yaml)
3. Determine current phase and next recommended workflow
4. Display status with visual indicators
5. Offer to execute recommended workflow

**Status Indicators:**
- ✓ = Completed (shows file path)
- ⚠ = Required but not started
- → = Current phase
- - = Optional/not required

**Example interaction:**
```
User: /status

Orchestrator: Checking your project status...

Project: MyApp (Web Application, Level 2)

✓ Phase 1: Analysis
  ✓ product-brief (docs/product-brief-myapp-2025-01-11.md)

→ Phase 2: Planning [CURRENT]
  ⚠ prd (required - NOT STARTED)
  - tech-spec (optional)

Phase 3: Solutioning
  - architecture (required)

Phase 4: Implementation
  - sprint-planning (required)

Recommended next step: Create PRD with /prd command

Would you like to run /prd to create your PRD?
```

**If project not initialized:**
- Inform user BMAD not detected
- Offer to run `/workflow-init`

## Workflow Routing Logic

After determining project status, route users to specialized workflows:

- **Analysis workflows:** `/product-brief`, `/brainstorm`, `/research`
- **Planning workflows:** `/prd`, `/tech-spec`
- **UX workflows:** `/create-ux-design`
- **Architecture workflows:** `/architecture`
- **Sprint workflows:** `/sprint-planning`, `/create-story`
- **Development workflows:** `/dev-story`, `/code-review`
- **Team workflows:** `/team-dev`, `/team-create-stories`, `/team-review`

**Recommendation logic:**
1. If no product-brief and project new → Recommend: `/product-brief`
2. If product-brief complete, no PRD/tech-spec:
   - Level 0-1 → Recommend: `/tech-spec`
   - Level 2+ → Recommend: `/prd`
3. If PRD/tech-spec complete, no architecture, level 2+ → Recommend: `/architecture`
4. If planning complete → Recommend: `/sprint-planning`
5. If sprint active → Recommend: `/create-story` or `/dev-story`

See [REFERENCE.md](REFERENCE.md) for detailed routing logic.

## Configuration Files

### Project Config (bmad/config.yaml)
```yaml
project_name: "MyApp"
project_type: "web-app"  # web-app, mobile-app, api, game, library, other
project_level: 2         # 0-4
output_folder: "docs"
communication_language: "English"

# Optional: docs site sync script (run after BMAD doc generation)
# docs_sync_script: "python3 scripts/sync_project_docs.py"
```

### Workflow Status (docs/bmm-workflow-status.yaml)
Tracks completion of each workflow with status values:
- `"optional"` - Can be skipped
- `"recommended"` - Strongly suggested
- `"required"` - Must be completed
- `"{file-path}"` - Completed (shows output file)
- `"skipped"` - Explicitly skipped

See [templates/config.template.yaml](templates/config.template.yaml) for full template.

## Project Docs Integration

BMAD-generated documents are stored in the `docs/` directory with a standardized naming pattern:

```
docs/{type}-{feature-slug}-{YYYY-MM-DD}.md

Examples:
  docs/prd-user-auth-2025-03-15.md
  docs/architecture-user-auth-2025-03-15.md
  docs/tech-spec-user-auth-2025-03-15.md
```

| Document Type | File Prefix |
|--------------|------------|
| Product Brief | `product-brief-` |
| PRD | `prd-` |
| Tech Spec | `tech-spec-` |
| UX Design | `ux-design-` |
| Architecture | `architecture-` |

### Docs Site Sync (Optional)

If your project has a docs site, configure automatic sync in `bmad/config.yaml`:

```yaml
# bmad/config.yaml
docs_sync_script: "python3 scripts/sync_project_docs.py"
```

When configured, the orchestrator will offer to run the sync script after generating BMAD documents. The sync script is project-specific and should handle copying docs to the appropriate location for your docs site.

## Helper Scripts

Execute via Bash tool:

- **init-project.sh** - Automated project initialization
  ```bash
  bash scripts/init-project.sh --name "MyApp" --type web-app --level 2
  ```

- **check-status.sh** - Display current workflow status
  ```bash
  bash scripts/check-status.sh
  ```

- **validate-config.sh** - Validate YAML configuration
  ```bash
  bash scripts/validate-config.sh bmad/config.yaml
  ```

See [scripts documentation](resources/workflow-phases.md) for details.

## Error Handling

**Config missing:**
- Suggest `/workflow-init`
- Explain BMAD not initialized

**Invalid YAML:**
- Show error location
- Offer to fix or reinitialize

**Template missing:**
- Use inline fallback
- Log warning
- Continue operation

**Status file inconsistent:**
- Validate against project level
- Offer to regenerate

## Integration with Other Skills

This orchestrator coordinates with specialized BMAD skills:
- `business-analyst` - Analysis phase workflows
- `product-manager` - Planning phase workflows
- `system-architect` - Architecture design
- `scrum-master` - Sprint and story management
- `developer` - Development workflows

When routing to these skills, pass context:
- Current project config
- Workflow status
- Project level
- Output folder location

## Token Optimization

- Use script automation for repetitive tasks
- Reference REFERENCE.md for detailed logic
- Load files only when needed
- Keep status displays concise
- Delegate detailed work to specialized skills

## Subagent Strategy

This skill leverages parallel subagents to maximize context utilization (each agent has up to 1M tokens on Claude Sonnet 4.6 / Opus 4.6).

### Subagent Types

| Type | Model | Tools | Use Case |
|------|-------|-------|----------|
| `general-purpose` | Inherited | All tools | Full-capability subagent (default) |
| `Explore` | Haiku (fast) | Read-only | Codebase exploration, search |
| `Plan` | Inherited | Read-only | Architecture design, planning |

### Token Budget Guidelines

| Category | Budget | Use Case |
|----------|--------|----------|
| Research/Exploration | ~500K | Codebase analysis, pattern investigation |
| Generation/Writing | ~300K | Code generation, document writing |
| Validation/Testing | ~80K | Lint, test execution |

### Parallel Execution: Solutioning Phase

Architect and UX Designer review simultaneously:

```
Agent({
  subagent_type: "general-purpose",
  description: "Architect review",
  prompt: "Review clean architecture, DI structure, API design...",
})
// simultaneously
Agent({
  subagent_type: "general-purpose",
  description: "UX Designer review",
  prompt: "Review design system compliance, layout, interactions...",
})
```

### Worktree Isolation: Implementation Phase

When backend and frontend work is independent, use **worktree isolation** to prevent file conflicts:

```
Agent({
  subagent_type: "general-purpose",
  description: "Backend implementation",
  prompt: "Implement API endpoints...",
  isolation: "worktree",  // Independent git worktree
})
// simultaneously
Agent({
  subagent_type: "general-purpose",
  description: "Frontend implementation",
  prompt: "Implement UI with mock data...",
  isolation: "worktree",  // Prevents file conflicts
})
```

> **`isolation: "worktree"`**: Creates a temporary git worktree for isolated work.
> If no changes are made, the worktree is auto-cleaned. Otherwise, the worktree path and branch are returned.

### Background Execution

For long-running research or analysis tasks:

```
Agent({
  subagent_type: "Explore",
  description: "Codebase exploration",
  prompt: "Analyze existing patterns...",
  run_in_background: true,  // Returns output_file path
})

// Check progress (non-blocking)
TaskOutput(task_id: "...", block: false)
```

### Workflow Status Check Workflow
**Pattern:** Fan-Out Research
**Agents:** 3-4 parallel agents

| Agent | Task | Output |
|-------|------|--------|
| Agent 1 | Check project config and validate structure | bmad/outputs/config-status.md |
| Agent 2 | Analyze workflow status file and phase completion | bmad/outputs/workflow-status.md |
| Agent 3 | Scan docs directory for completed artifacts | bmad/outputs/artifacts-status.md |
| Agent 4 | Generate recommendations based on project level | bmad/outputs/recommendations.md |

**Coordination:**
1. Launch all agents with shared project context
2. Each agent writes status findings to designated output
3. Main context synthesizes results into unified status report
4. Display visual status indicators and next steps

### Project Initialization Workflow
**Pattern:** Parallel Section Generation
**Agents:** 3 parallel agents

| Agent | Task | Output |
|-------|------|--------|
| Agent 1 | Create directory structure and validate paths | bmad/outputs/directory-setup.md |
| Agent 2 | Generate project config from template | bmad/config.yaml |
| Agent 3 | Generate workflow status file with level-based requirements | docs/bmm-workflow-status.yaml |

**Coordination:**
1. Gather project information from user (sequential)
2. Launch parallel agents to create structures and configs
3. Main context validates all outputs and displays summary

### Example Subagent Prompt
```
Task: Analyze workflow status and determine current phase
Context: Read bmad/config.yaml and docs/bmm-workflow-status.yaml
Objective: Identify completed workflows, current phase, and required next steps
Output: Write analysis to bmad/outputs/workflow-status.md

Deliverables:
1. List of completed workflows with file paths
2. Current phase determination
3. Required vs optional next workflows
4. Blocking issues or missing dependencies

Constraints:
- Use project level to determine requirements
- Flag any inconsistencies in status file
```

## Related Commands

| Command | Description |
|---------|-------------|
| `/bmad` | Full BMAD workflow |
| `/bmad:review` | Single persona review |
| `/bmad:team-review` | Parallel multi-persona review (Agent Teams) |
| `/bmad:status` | Check workflow status |
| `/bmad:gate` | Manual gate verification |
| `/workflow-init` | Initialize BMAD in project |
| `/workflow-status` | Check project progress |

## Notes for Claude

- This is the entry point for BMAD workflows
- Always check if project is initialized before operations
- Maintain phase-based progression (don't skip required phases)
- Use TaskCreate for multi-step initialization tracking
- Keep responses focused and actionable
- Hand off to specialized skills for detailed workflows
- Update workflow status after completing workflows
- Display visual progress indicators at workflow milestones
- Enforce phase gates - never allow progression past a failed gate
- When emergency mode is requested, always get explicit user approval first

## Quick Reference

- Detailed routing logic: [REFERENCE.md](REFERENCE.md)
- Workflow phases: [resources/workflow-phases.md](resources/workflow-phases.md)
- Config template: [templates/config.template.yaml](templates/config.template.yaml)
- Init script: [scripts/init-project.sh](scripts/init-project.sh)
- Status script: [scripts/check-status.sh](scripts/check-status.sh)
