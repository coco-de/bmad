You are the Team Lead, executing the **Team Review** workflow.

## Workflow Overview

**Goal:** Review a document from multiple expert perspectives in parallel

**Phase:** Any (works across all phases)

**Agent:** Team Lead

**Inputs:** Document path, document type (auto-detected or user-specified)

**Output:** Individual review files + integrated review summary

**Duration:** 5-10 minutes (parallel vs 15-30 min sequential review)

**When to use:** When you want comprehensive multi-perspective review of a BMAD document

**Prerequisite:** Agent Teams must be enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)

---

## Pre-Flight

1. **Load context** per `helpers.md#Combined-Config-Load`
2. **Check Agent Teams** per `helpers.md#Check-Agent-Teams-Available`
3. **If teams_available = false:**
   - Output:
     ```
     ⚠ Agent Teams not available.

     Agent Teams is an experimental feature that requires:
       CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

     Sequential alternative:
       Review the document manually or ask for a single-perspective review.
     ```
   - **Stop workflow** (do not proceed)
4. **Read target document:**
   - Accept document path as argument (e.g., `/team-review docs/prd-myapp.md`)
   - If no argument: ask user for document path
5. **Detect document type** from filename or content:
   - `prd-*` or content has "Product Requirements" → PRD
   - `architecture-*` or content has "Architecture" → Architecture
   - `sprint-plan-*` or content has "Sprint" → Sprint Plan
   - `tech-spec-*` or content has "Technical Specification" → Tech Spec
   - Other → ask user for document type
6. **Load max_teammates** from config `agent_teams.max_teammates` (default: 3)

---

## Part 1: Select Review Perspectives

**Auto-select reviewers based on document type:**

**PRD (Product Requirements Document):**
| Reviewer | Perspective | Focus |
|----------|-------------|-------|
| PM | Requirements Completeness | User stories coverage, acceptance criteria quality, scope clarity |
| Architect | Technical Feasibility | Implementation complexity, technology fit, scalability concerns |
| Developer | Implementation Clarity | Enough detail to code from, ambiguities, missing edge cases |

**Architecture Document:**
| Reviewer | Perspective | Focus |
|----------|-------------|-------|
| PM | Requirements Coverage | All PRD requirements addressed, traceability |
| Architect | Technical Quality | Security, scalability, maintainability, patterns |
| Developer | Developer Experience | API clarity, integration complexity, testing strategy |

**Sprint Plan:**
| Reviewer | Perspective | Focus |
|----------|-------------|-------|
| Scrum Master | Story Quality | INVEST criteria, sizing accuracy, dependency completeness |
| Architect | Technical Depth | Technical notes accuracy, architecture alignment |
| PM | Scope Alignment | PRD coverage, priority correctness, MVP boundaries |

**Tech Spec:**
| Reviewer | Perspective | Focus |
|----------|-------------|-------|
| Architect | Architecture Alignment | Consistency with architecture doc, pattern compliance |
| Developer | Implementation Detail | Code examples clarity, API contracts, error handling |
| PM | Requirements Traceability | All requirements addressed, acceptance criteria mapping |

**Display plan:**
```
Review Plan for: {document_path}
Document Type: {type}

Reviewer 1 ({perspective}):
  Focus: {focus_description}
  Output: docs/reviews/{doc_name}-review-{perspective}.md

Reviewer 2 ({perspective}):
  Focus: {focus_description}
  Output: docs/reviews/{doc_name}-review-{perspective}.md

Reviewer 3 ({perspective}):
  Focus: {focus_description}
  Output: docs/reviews/{doc_name}-review-{perspective}.md

Proceed? (y/n)
```

**Wait for user confirmation.**

If `config.agent_teams.auto_approve_plans` = true, skip confirmation.

---

## Part 2: Spawn Reviewers

**Step 1: Ensure review output directory exists:**
```
Create docs/reviews/ directory if not exists
```

**Step 2: Create shared task list** per `helpers.md#Create-Team-Task-List`:

For each reviewer:
```
TaskCreate:
  subject: "Reviewer ({perspective}): Review {document_name}"
  description: Document content, review focus, checklist, output path
  activeForm: "Reviewing {document_name} as {perspective}"
```

**Step 3: Spawn teammates** per `helpers.md#Spawn-BMAD-Teammate`:

For each reviewer:
- role: "reviewer"
- context:
  - document_path: full path to document
  - document_type: detected type
  - review_perspective: PM / Architect / Developer / Scrum Master
  - review_focus: specific focus areas for this perspective
  - review_checklist: perspective-specific checklist items
  - review_output_path: `docs/reviews/{doc_name}-review-{perspective}.md`

**Review checklists by perspective:**

**PM Review Checklist:**
- [ ] All user personas identified and addressed
- [ ] User stories follow correct format (As a... I want... So that...)
- [ ] Acceptance criteria are specific, measurable, testable
- [ ] Scope is clearly defined (in-scope and out-of-scope)
- [ ] Priority levels are assigned and justified
- [ ] Dependencies are identified
- [ ] Success metrics defined

**Architect Review Checklist:**
- [ ] Technology choices are justified
- [ ] Security considerations addressed
- [ ] Scalability approach defined
- [ ] Data model is appropriate
- [ ] API design follows best practices
- [ ] Error handling strategy defined
- [ ] Performance requirements addressed
- [ ] Integration points documented

**Developer Review Checklist:**
- [ ] Enough detail to begin implementation
- [ ] No ambiguous requirements
- [ ] Edge cases identified
- [ ] Testing strategy clear
- [ ] API contracts fully specified
- [ ] Database migrations clear
- [ ] Third-party integrations documented
- [ ] No conflicting requirements

**Scrum Master Review Checklist:**
- [ ] Stories follow INVEST criteria
- [ ] Story points are reasonable (no >8 point stories)
- [ ] Dependencies clearly mapped
- [ ] Sprint capacity is realistic
- [ ] Priority order makes sense
- [ ] Acceptance criteria are testable
- [ ] Definition of Done is clear

---

## Part 3: Monitor & Collect Reviews

**Monitor reviewer progress:**

1. **Poll task status:**
   ```
   Call TaskList
   Display: {completed}/{total} reviewers done
   ```

2. **On reviewer completion:**
   - Verify review document exists at expected path
   - Quick validation: check review has required sections
     (Overall Assessment, Strengths, Issues, Recommendations)

3. **Display progress:**
   ```
   Review Progress:

   PM Review: ✓ Complete
     Assessment: Conditional Pass (2 issues)
     Output: docs/reviews/{doc_name}-review-pm.md

   Architect Review: ✓ Complete
     Assessment: Pass (1 minor issue)
     Output: docs/reviews/{doc_name}-review-architect.md

   Developer Review: 🔄 In Progress...
   ```

---

## Part 4: Integrated Review Summary

**After all reviewers complete:**

1. **Read all review documents**

2. **Build integrated summary:**

```markdown
# Integrated Review: {document_name}

**Document:** {document_path}
**Type:** {document_type}
**Reviewed:** {date}
**Reviewers:** {count} perspectives

---

## Overall Assessment

| Reviewer | Assessment | Critical | Major | Minor |
|----------|-----------|----------|-------|-------|
| PM | {Pass/Conditional/Fail} | {count} | {count} | {count} |
| Architect | {Pass/Conditional/Fail} | {count} | {count} | {count} |
| Developer | {Pass/Conditional/Fail} | {count} | {count} | {count} |

**Consensus:** {Pass / Conditional Pass / Needs Revision}

---

## Critical Issues (Must Fix)

1. [{Reviewer}] {Issue description}
   - Impact: {why this matters}
   - Suggestion: {how to fix}

---

## Major Issues (Should Fix)

1. [{Reviewer}] {Issue description}
   - Suggestion: {how to fix}

---

## Minor Issues (Consider)

1. [{Reviewer}] {Issue description}

---

## Strengths (Consensus)

- {Strength noted by multiple reviewers}
- {Another shared strength}

---

## Recommendations

### High Priority
- {Recommendation from critical/major issues}

### Medium Priority
- {Recommendation from major/minor issues}

### Low Priority
- {Nice-to-have improvements}

---

## Individual Reviews

- PM: docs/reviews/{doc_name}-review-pm.md
- Architect: docs/reviews/{doc_name}-review-architect.md
- Developer: docs/reviews/{doc_name}-review-developer.md
```

3. **Save integrated summary:**
   - Path: `docs/reviews/{doc_name}-review-integrated.md`

4. **Display summary to user:**
   ```
   ✓ Team Review Complete!

   Document: {document_path}
   Consensus: {Pass / Conditional Pass / Needs Revision}

   Issues Found:
     Critical: {count}
     Major: {count}
     Minor: {count}

   Strengths: {count} consensus strengths identified

   Review Files:
     docs/reviews/{doc_name}-review-pm.md
     docs/reviews/{doc_name}-review-architect.md
     docs/reviews/{doc_name}-review-developer.md
     docs/reviews/{doc_name}-review-integrated.md  ← Start here

   Next Steps:
     1. Read integrated review: docs/reviews/{doc_name}-review-integrated.md
     2. Address critical issues first
     3. Revise document and re-review if needed
   ```

---

## Helper References

- **Load config:** `helpers.md#Combined-Config-Load`
- **Check Agent Teams:** `helpers.md#Check-Agent-Teams-Available`
- **Spawn teammate:** `helpers.md#Spawn-BMAD-Teammate`
- **Create team tasks:** `helpers.md#Create-Team-Task-List`
- **Collect results:** `helpers.md#Collect-Team-Results`

---

## Notes for LLMs

- **ALWAYS** check Agent Teams availability first (Pre-Flight step 2-3)
- If teams not available, suggest manual review and STOP
- Each reviewer writes to a UNIQUE file path — no conflicts possible
- Reviewers must NOT modify the document being reviewed
- Sprint-status.yaml is NOT modified by this workflow
- Document type detection drives reviewer perspective selection
- Integrated summary should highlight cross-reviewer consensus and conflicts
- If a reviewer fails, include note in integrated summary and continue
- Review output directory (`docs/reviews/`) is created if it doesn't exist

**Remember:** Multi-perspective review catches issues that single-perspective review misses. The PM sees requirement gaps, the Architect sees technical risks, and the Developer sees implementation ambiguities. Together they provide comprehensive quality assurance.
