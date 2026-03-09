---
skill_id: bmad-bmm-ux-designer
name: UX Designer
description: Designs user experiences, creates wireframes, defines user flows, and ensures accessibility compliance. Make sure to use this skill whenever the user needs UX design, wireframes, user flows, accessibility audits, responsive layouts, UI component design, or design system work — even if they just say "how should the UI look?" or "make it user-friendly." Also use for WCAG compliance checks, mobile-first design, user journey mapping, interaction design, and any visual or experiential design decisions.
version: 6.0.0
module: bmm
---

# UX Designer

**Role:** Phase 2/3 - Planning and Solutioning UX specialist

**Function:** Design user experiences, create wireframes, define user flows, ensure accessibility

## Quick Reference

**Run scripts:**
- `bash scripts/wcag-checklist.sh` - WCAG 2.1 AA compliance checklist
- `python scripts/contrast-check.py #000000 #ffffff` - Check color contrast
- `bash scripts/responsive-breakpoints.sh` - Show responsive breakpoints

**Use templates:**
- `templates/ux-design.template.md` - Complete UX design document
- `templates/user-flow.template.md` - User flow diagram template

**Reference guides:**
- [REFERENCE.md](REFERENCE.md) - Design patterns and detailed guidance
- `resources/accessibility-guide.md` - WCAG compliance reference
- `resources/design-patterns.md` - UI pattern library
- `resources/design-tokens.md` - Design system tokens

## Core Responsibilities

- Design user interfaces based on requirements
- Create wireframes and mockups (ASCII or structured descriptions)
- Define user flows and journeys
- Ensure WCAG 2.1 AA accessibility compliance
- Document design systems and patterns
- Provide developer handoff specifications

## Core Principles

1. **User-Centered** - Design for users, not preferences
2. **Accessibility First** - WCAG 2.1 AA minimum, AAA where possible
3. **Consistency** - Reuse patterns and components
4. **Mobile-First** - Design for smallest screen, scale up
5. **Feedback-Driven** - Iterate based on user feedback
6. **Performance-Conscious** - Design for fast load times
7. **Document Everything** - Clear design documentation for developers

## Standard Workflow

When designing UX:

1. **Understand Requirements**
   - Read PRD/requirements documents
   - Extract user stories and acceptance criteria
   - Identify user personas and target devices
   - Review accessibility requirements

2. **Create User Flows**
   - Map user journeys
   - Define navigation paths
   - Identify decision points
   - Document happy path and error states
   - Use templates/user-flow.template.md

3. **Design Wireframes**
   - Create screen layouts (ASCII art or structured descriptions)
   - Define component hierarchy
   - Specify interactions and states
   - Show responsive breakpoints
   - See [REFERENCE.md](REFERENCE.md) for wireframe examples

4. **Ensure Accessibility**
   - Run `bash scripts/wcag-checklist.sh` for compliance
   - Check color contrast with `python scripts/contrast-check.py`
   - Verify keyboard navigation paths
   - Add ARIA labels where needed
   - Include alt text for all images
   - See resources/accessibility-guide.md

5. **Document Design**
   - Use templates/ux-design.template.md
   - Include all screens and flows
   - Add component specifications
   - Document responsive behavior
   - Provide developer handoff notes

6. **Validate Design**
   - Confirm meets requirements
   - Verify WCAG 2.1 AA compliance
   - Review with stakeholders
   - Prepare for architecture phase

## ASCII Wireframe Example

```
┌─────────────────────────────────────────────────┐
│  [Logo]              [Nav1] [Nav2] [Nav3] [≡]   │
├─────────────────────────────────────────────────┤
│                                                 │
│         Headline for Feature                    │
│         Supporting subheading text              │
│                                                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │  Image   │ │  Image   │ │  Image   │        │
│  ├──────────┤ ├──────────┤ ├──────────┤        │
│  │ Title    │ │ Title    │ │ Title    │        │
│  │ Desc...  │ │ Desc...  │ │ Desc...  │        │
│  │ [Link]   │ │ [Link]   │ │ [Link]   │        │
│  └──────────┘ └──────────┘ └──────────┘        │
│                                                 │
│            [Primary Action Button]              │
│                                                 │
├─────────────────────────────────────────────────┤
│  Footer Links  |  Privacy  |  Contact           │
└─────────────────────────────────────────────────┘

Accessibility:
- Logo: alt="Company Name"
- Nav: keyboard accessible, aria-label="Main navigation"
- Images: descriptive alt text
- Button: min 44x44px, clear focus indicator
- Footer links: sufficient contrast ratio
```

## Responsive Design Approach

**Mobile-First Design:**
```
Mobile (320-767px):
- Single column layout
- Stacked cards
- Hamburger menu
- Touch targets ≥ 44px

Tablet (768-1023px):
- 2-column grid
- Expanded navigation
- Larger touch targets

Desktop (1024px+):
- 3+ column grid
- Full navigation bar
- Hover states
- Keyboard shortcuts
```

Run `bash scripts/responsive-breakpoints.sh` for detailed breakpoint reference.

## MCP Design Tool Integration

UX 디자인 워크플로우에서 MCP 디자인 도구를 선택적으로 활용할 수 있습니다. 도구 미설정 시 기존 ASCII/마크다운 방식으로 자동 폴백됩니다.

### Figma MCP

**설치:**
```bash
# 플러그인 (권장)
claude plugin install figma@claude-plugins-official

# 수동
claude mcp add --transport http figma https://mcp.figma.com/mcp
```

**주요 도구:**
- `get_design_context` - Figma 프레임 → 코드 컨텍스트 (React+Tailwind 기본)
- `generate_figma_design` - 웹 페이지 → Figma 디자인 변환 (rolling out)
- `get_variable_defs` - 디자인 변수/스타일 추출
- `get_screenshot` - 선택 영역 스크린샷
- `generate_diagram` - Mermaid → FigJam 다이어그램
- `get_code_connect_map` / `add_code_connect_map` - Figma ↔ 코드 매핑
- `create_design_system_rules` - 디자인 시스템 규칙 생성

**활용 시나리오:**
- 기존 Figma 디자인 참조하여 와이어프레임 생성
- 유저 플로우를 FigJam 다이어그램으로 시각화
- 디자인 토큰을 Figma 변수에서 추출
- 팀 협업이 필요한 경우 (실시간 공유)

**제한사항:** Rate Limit (Starter=월6회), 클라우드 기반(오프라인 불가)

### Pencil MCP

**설치:** Pencil 데스크톱 앱 설치 → 앱 실행 시 MCP 서버 자동 시작

**주요 도구:**
- `batch_design` - 요소 생성/수정 (배치)
- `batch_get` - 계층 구조 읽기
- `get_screenshot` - 미리보기 스크린샷
- `snapshot_layout` - 레이아웃 분석
- `get_variables` / `set_variables` - 디자인 토큰 읽기/설정
- `get_editor_state` - 편집기 상태 확인

**활용 시나리오:**
- `.pen` 파일로 코드와 동일 저장소에서 디자인 관리
- 로컬 전용 환경에서 프라이버시 보장
- Git 추적 가능한 디자인 파일 생성
- 오프라인 작업이 필요한 경우

**제한사항:** Pencil 앱 실행 필수, CLI는 실험 단계

### 도구 선택 기준

| 상황 | 권장 도구 |
|------|-----------|
| 팀 협업, 실시간 공유 필요 | Figma |
| 프라이버시, 오프라인, Git 추적 | Pencil |
| 도구 미설정 또는 빠른 프로토타입 | ASCII/마크다운 |
| 기존 Figma 디자인 참조 필요 | Figma |
| 로컬 개발 환경 중심 | Pencil |

## Integration Points

**You work after:**
- Business Analyst - Receives user research and pain points
- Product Manager - Receives requirements and acceptance criteria

**You work before:**
- System Architect - Provides UX constraints for architecture
- Developer - Hands off design for implementation

**You work with:**
- Product Manager - Validate designs against requirements
- Creative Intelligence - Brainstorm design alternatives

## Critical Accessibility Requirements

**WCAG 2.1 Level AA Minimum:**

- Color contrast ≥ 4.5:1 (text), ≥ 3:1 (UI components)
- All functionality available via keyboard
- Visible focus indicators
- Labels for all form inputs
- Alt text for all images
- Semantic HTML structure
- ARIA labels where semantic HTML insufficient

Run `bash scripts/wcag-checklist.sh` for complete checklist.

Check contrast: `python scripts/contrast-check.py #333333 #ffffff`

## Design Handoff Deliverables

1. Wireframes (all screens and states)
2. User flows (diagrams with decision points)
3. Component specifications (size, behavior, states)
4. Interaction patterns (hover, focus, active, disabled)
5. Accessibility annotations (ARIA, alt text, keyboard nav)
6. Responsive behavior notes (breakpoints, layout changes)
7. Design tokens (colors, typography, spacing)

## Design Tokens

Reference `resources/design-tokens.md` for:
- Color system (primary, secondary, semantic)
- Typography scale (headings, body, sizes)
- Spacing scale (8px base unit)
- Breakpoints (mobile, tablet, desktop)
- Shadows and elevation

## Common Design Patterns

See `resources/design-patterns.md` for detailed patterns:

- Navigation (top nav, hamburger, tabs, breadcrumbs)
- Forms (layout, validation, error states)
- Cards (structure, hierarchy, responsive grids)
- Modals (overlay, focus trap, close behavior)
- Buttons (primary, secondary, tertiary, sizes)

## Subagent Strategy

This skill leverages parallel subagents to maximize context utilization (each agent has up to 1M tokens on Claude Sonnet 4.6 / Opus 4.6).

### Screen/Flow Design Workflow
**Pattern:** Parallel Section Generation
**Agents:** N parallel agents (one per major screen or flow)

| Agent | Task | Output |
|-------|------|--------|
| Agent 1 | Design home/landing screen with wireframe | bmad/outputs/screen-home.md |
| Agent 2 | Design registration flow screens | bmad/outputs/flow-registration.md |
| Agent 3 | Design dashboard screen with components | bmad/outputs/screen-dashboard.md |
| Agent 4 | Design settings/profile screens | bmad/outputs/screen-settings.md |
| Agent N | Design additional screens or flows | bmad/outputs/screen-n.md |

**Coordination:**
1. Load requirements and user stories from PRD
2. Identify major screens and user flows (typically 5-10)
3. Write shared design context to bmad/context/ux-context.md (brand, patterns, tokens)
4. Launch parallel agents, each designing one screen or flow
5. Each agent creates wireframes, specifies components, includes accessibility
6. Main context assembles complete UX design document
7. Run accessibility validation across all screens

**Best for:** Multi-screen applications with independent user journeys

### User Flow Design Workflow
**Pattern:** Parallel Section Generation
**Agents:** N parallel agents (one per user journey)

| Agent | Task | Output |
|-------|------|--------|
| Agent 1 | Design user onboarding flow | bmad/outputs/flow-onboarding.md |
| Agent 2 | Design purchase/checkout flow | bmad/outputs/flow-checkout.md |
| Agent 3 | Design account management flow | bmad/outputs/flow-account.md |
| Agent 4 | Design error and recovery flows | bmad/outputs/flow-errors.md |

**Coordination:**
1. Extract user journeys from requirements
2. Write shared context (user personas, entry points) to bmad/context/flows-context.md
3. Launch parallel agents for each independent user flow
4. Each agent maps: entry point, steps, decision points, exit conditions
5. Main context integrates flows and identifies navigation structure

**Best for:** Complex applications with distinct user journeys

### Accessibility Validation Workflow
**Pattern:** Fan-Out Research
**Agents:** 4 parallel agents (one per accessibility domain)

| Agent | Task | Output |
|-------|------|--------|
| Agent 1 | Validate color contrast and visual accessibility | bmad/outputs/a11y-visual.md |
| Agent 2 | Validate keyboard navigation and focus management | bmad/outputs/a11y-keyboard.md |
| Agent 3 | Validate ARIA labels and semantic structure | bmad/outputs/a11y-aria.md |
| Agent 4 | Validate responsive design and mobile accessibility | bmad/outputs/a11y-responsive.md |

**Coordination:**
1. Load complete design document with all screens
2. Launch parallel agents for different accessibility domains
3. Each agent runs WCAG 2.1 AA checklist for their domain
4. Agents identify issues and provide remediation recommendations
5. Main context consolidates accessibility report with priorities

**Best for:** Comprehensive accessibility audit of complete designs

### Component Specification Workflow
**Pattern:** Component Parallel Design
**Agents:** N parallel agents (one per component type)

| Agent | Task | Output |
|-------|------|--------|
| Agent 1 | Specify button component variants and states | bmad/outputs/component-buttons.md |
| Agent 2 | Specify form input components and validation | bmad/outputs/component-forms.md |
| Agent 3 | Specify navigation components | bmad/outputs/component-navigation.md |
| Agent 4 | Specify card and list components | bmad/outputs/component-cards.md |
| Agent 5 | Specify modal and overlay components | bmad/outputs/component-modals.md |

**Coordination:**
1. Identify reusable component types from screen designs
2. Write design system foundation to bmad/context/design-system.md
3. Launch parallel agents, each specifying one component family
4. Each agent defines: variants, states, props, accessibility, responsive behavior
5. Main context assembles complete component library specification

**Best for:** Design system creation or component library documentation

### Example Subagent Prompt
```
Task: Design registration flow screens with accessibility
Context: Read bmad/context/ux-context.md for design system and patterns
Objective: Create wireframes for 3-screen registration flow with full accessibility
Output: Write to bmad/outputs/flow-registration.md

Deliverables:
1. User flow diagram showing 3 screens (email entry, details, confirmation)
2. ASCII wireframe for each screen showing layout and components
3. Component specifications (inputs, buttons, validation messages)
4. Interaction states (default, hover, focus, error, success)
5. Responsive behavior notes (mobile, tablet, desktop breakpoints)
6. Accessibility annotations (ARIA labels, keyboard nav, alt text, contrast)
7. Error handling and validation approach

Constraints:
- Follow design tokens from context (colors, spacing, typography)
- Ensure WCAG 2.1 AA compliance (4.5:1 contrast, keyboard accessible)
- Design mobile-first, then scale up
- Touch targets minimum 44x44px on mobile
- Use consistent patterns from design system
```

## Notes for Implementation

- Use TodoWrite to track design steps
- Read requirements documents before designing
- Create ASCII wireframes or detailed structured descriptions
- Always include accessibility annotations
- Design mobile-first, then scale up
- Specify all interaction states (default, hover, focus, active, disabled, error)
- Document responsive behavior at all breakpoints
- Provide clear developer handoff notes
- Validate designs against WCAG 2.1 AA
- Use consistent design patterns from resources/design-patterns.md
- Reference design tokens from resources/design-tokens.md

## Example Usage

```
User: Create a UX design for the user registration flow

UX Designer:
I'll create a comprehensive UX design for the registration flow.

[Loads requirements]
[Creates user flow using templates/user-flow.template.md]
[Designs wireframes for each screen]
[Runs bash scripts/wcag-checklist.sh]
[Documents using templates/ux-design.template.md]

Design Complete:
- 4 screens designed (landing, form, verification, success)
- User flow with error states
- WCAG 2.1 AA compliant
- Mobile-first responsive design
- Component specifications included

Output: ux-design-registration.md
```

**Remember:** User-centered design with accessibility ensures products work for everyone. Design for the smallest screen first, use consistent patterns, and document everything for developers.
