UX Designer로서 **UX 디자인 생성** 워크플로우를 실행합니다.

## Workflow Overview

**Goal:** Create comprehensive UX design with wireframes, user flows, and accessibility

**Phase:** Phase 2 (Planning) or Phase 3 (Solutioning)

**Agent:** UX Designer

**Inputs:** Requirements (PRD/tech-spec), user stories, target platforms

**Output:** UX design document with wireframes, flows, accessibility annotations, developer handoff

**Duration:** 60-120 minutes

---

## Pre-Flight

1. **Load context** per `helpers.md#Combined-Config-Load`
2. **Load requirements** per `helpers.md#Load-Documents`
   - Look for PRD (`prd.md`) or tech-spec (`tech-spec.md`)
   - Extract user stories, acceptance criteria, NFRs
3. **Explain purpose:**
   > "I'll create a comprehensive UX design for your project. This includes user flows, wireframes, accessibility annotations, and developer handoff documentation."

---

## UX Design Process

Use TodoWrite to track: Load Requirements → Define Scope → Create User Flows → Design Wireframes → Ensure Accessibility → Document Components → Generate Design Doc → Validate → Update Status

---

### Part 1: Analyze Requirements

**Load requirements document:**

Per `helpers.md#Load-Documents`:
- Read PRD or tech-spec from project
- Extract all user stories (US-XXX)
- Extract all NFRs related to UX:
  - Performance (page load times)
  - Usability (ease of use, learnability)
  - Accessibility (WCAG level)
  - Compatibility (browsers, devices)

**Ask user for additional context:**

**Q1: Target Platforms**
> "What platforms are we designing for?"
>
> Options (select multiple):
> - [ ] Web (desktop)
> - [ ] Web (mobile)
> - [ ] Web (tablet)
> - [ ] iOS native
> - [ ] Android native
> - [ ] Progressive Web App (PWA)

**Store as:** `{{target_platforms}}`

**Q2: Design Complexity**
> "What level of design detail?"
>
> 1. **High-level** - User flows and basic wireframes
> 2. **Detailed** - Full wireframes with interactions
> 3. **Comprehensive** - Wireframes, interactions, component specs, design system

**Store as:** `{{design_level}}`

**Q3: Accessibility Requirements**
> "What accessibility level?"
>
> 1. WCAG 2.1 Level A (minimum)
> 2. WCAG 2.1 Level AA (recommended)
> 3. WCAG 2.1 Level AAA (highest)

**Store as:** `{{wcag_level}}`

**Q4: Existing Design System**
> "Do you have an existing design system or brand guidelines?"
>
> If yes: Ask for link or file
> If no: Will create basic design tokens

**Store as:** `{{design_system_url}}`

---

### Part 2: Identify Design Scope

**From requirements, extract screens to design:**

**Group user stories by screen/flow:**
```
Flow 1: User Authentication
- US-001: User can sign up
- US-002: User can log in
- US-003: User can reset password
Screens needed: Sign up, Login, Forgot password

Flow 2: Dashboard
- US-004: User can view dashboard
- US-005: User can filter data
Screens needed: Dashboard (empty state), Dashboard (with data)

[Continue for all user stories...]
```

**Count total screens:** {{screen_count}}

**Inform user:**
> "I've identified {{screen_count}} screens across {{flow_count}} user flows."

---

### Part 3: Create User Flows

**For each major flow, create user flow diagram.**

**User flow format:**
```markdown
### Flow: {{flow_name}}

**Entry Point:** {{how_user_starts_flow}}

**Happy Path:**
1. {{screen_1}} → User {{action}} → {{screen_2}}
2. {{screen_2}} → User {{action}} → {{screen_3}}
3. {{screen_3}} → {{final_state}}

**Decision Points:**
- At {{screen}}: If {{condition}} → {{alternative_path}}

**Error Cases:**
- {{error_scenario}} → Show {{error_message}} → {{recovery_action}}

**Exit Points:**
- Success: {{success_screen}}
- Cancel: {{cancel_destination}}
- Error: {{error_screen}}

**Diagram:**
```
[Start]
   ↓
[Screen 1: {{name}}]
   ↓ {{action}}
[Screen 2: {{name}}]
   ↓ {{action}}
   ├─→ [Success: {{screen}}]
   └─→ [Error: {{screen}}]
```
```

**Create flows for:**
- Authentication flows
- Core feature flows
- Settings/configuration flows
- Error handling flows

**Typical count:** 3-10 flows depending on project complexity

---

### Part 3.5: Design Tool Selection (Optional)

**Check for available MCP design tools and offer integration:**

**Q: 디자인 도구를 사용하시겠습니까?**

> MCP 디자인 도구가 설정되어 있으면 와이어프레임 및 디자인 작업에 활용할 수 있습니다.
>
> 1. **Figma** - 클라우드 기반 디자인 (MCP: `figma`)
> 2. **Pencil** - 로컬 디자인, Git 추적 가능 (MCP: `pencil`)
> 3. **ASCII/마크다운** - 도구 불필요 (기본값)

**Store as:** `{{design_tool}}`

**Tool detection:** MCP 서버 연결 상태로 사용 가능 여부 확인. 미감지 시 옵션 3(ASCII/마크다운) 자동 선택.

#### Figma 선택 시 (`{{design_tool}}` = figma)

MCP 도구를 활용한 워크플로우:

1. **기존 디자인 참조:** `get_design_context`로 Figma 파일에서 기존 디자인 컨텍스트 로드
2. **디자인 변수 확인:** `get_variable_defs`로 디자인 시스템 변수/스타일 추출
3. **코드 매핑 조회:** `get_code_connect_map`으로 Figma ↔ 코드 컴포넌트 매핑 확인
4. **디자인 생성:** `generate_figma_design`으로 와이어프레임/디자인을 Figma에 생성 (지원 시)
5. **유저 플로우 다이어그램:** `generate_diagram`으로 Mermaid → FigJam 다이어그램 생성
6. **스크린샷 확인:** `get_screenshot`으로 결과물 미리보기
7. **디자인 시스템 규칙:** `create_design_system_rules`로 디자인 시스템 규칙 문서화

**Figma 제한사항:**
- Rate Limit 주의 (Starter = 월 6회, Dev/Full = 분당 제한)
- `generate_figma_design`은 일부 클라이언트만 지원 (rolling out)
- 클라우드 기반이므로 오프라인 불가
- 미지원 시 ASCII/마크다운으로 폴백

#### Pencil 선택 시 (`{{design_tool}}` = pencil)

MCP 도구를 활용한 워크플로우:

1. **기존 디자인 참조:** `batch_get`으로 .pen 파일 계층 구조 읽기
2. **편집기 상태 확인:** `get_editor_state`로 현재 편집 상태 파악
3. **와이어프레임 생성:** `batch_design`으로 요소 생성/수정 (배치 처리)
4. **디자인 토큰 동기화:** `get_variables` / `set_variables`로 디자인 토큰 읽기/설정
5. **레이아웃 분석:** `snapshot_layout`으로 레이아웃 구조 분석
6. **결과 확인:** `get_screenshot`으로 미리보기 스크린샷

**Pencil 장점:**
- `.pen` 파일이 코드와 동일 저장소에서 Git 추적 가능
- 완전 로컬 실행, 클라우드 미전송 (프라이버시)
- 오프라인 작업 가능

**Pencil 제한사항:**
- Pencil 데스크톱 앱 실행 필수
- CLI는 아직 실험 단계
- 미실행 시 ASCII/마크다운으로 폴백

#### ASCII/마크다운 선택 시 (기본값)

MCP 도구 없이 기존 방식대로 진행. 아래 Part 4의 Option 1(ASCII Art) 또는 Option 2(Structured Description) 사용.

---

### Part 4: Design Wireframes

**For each screen, create wireframe.**

**Wireframe approaches:**

#### Option 1: ASCII Art (quick visualization)

```
Screen: {{screen_name}}

Mobile (320-767px):
┌─────────────────────┐
│ ☰  Logo        [?]  │ ← Header (60px)
├─────────────────────┤
│                     │
│  Page Title         │ ← H1 (32px)
│  Subtitle           │ ← H2 (18px)
│                     │
│  ┌───────────────┐  │
│  │ Card 1        │  │ ← Card (full-width)
│  │ Title         │  │
│  │ Description   │  │
│  │ [Button]      │  │
│  └───────────────┘  │
│                     │
│  ┌───────────────┐  │
│  │ Card 2        │  │
│  └───────────────┘  │
│                     │
│  [Primary CTA]      │ ← Button (48px height)
│                     │
└─────────────────────┘

Desktop (1024px+):
┌─────────────────────────────────────────┐
│ Logo        Nav1   Nav2   Nav3    [?]   │ ← Header
├─────────────────────────────────────────┤
│                                         │
│  Page Title              Subtitle       │
│                                         │
│  ┌──────────┐  ┌──────────┐            │
│  │ Card 1   │  │ Card 2   │            │ ← 2-column grid
│  │          │  │          │            │
│  │ [Button] │  │ [Button] │            │
│  └──────────┘  └──────────┘            │
│                                         │
│         [Primary CTA]                   │
│                                         │
└─────────────────────────────────────────┘
```

#### Option 2: Structured Description (detailed specs)

```markdown
### Screen: {{screen_name}}

**Purpose:** {{what_user_does_here}}

**Layout Structure:**

**Header (fixed, 60px height):**
- Logo (left, 40px × 40px)
  - Click → Home page
- Navigation menu (center)
  - Nav Item 1, Nav Item 2, Nav Item 3
  - Active state: underline
- Help icon (right, 24px × 24px)
  - Click → Help modal

**Main Content (scrollable):**

**Hero Section (full-width, 400px height):**
- Headline (H1, 48px, center-aligned)
- Subheadline (H2, 24px, center-aligned)
- Background: gradient or image

**Card Grid (responsive):**
- Layout: 2 columns (desktop), 1 column (mobile)
- Gap: 24px between cards

**Card Component (300px × 250px):**
- Image (full-width, 150px height)
- Title (H3, 20px, 16px padding)
- Description (Body text, 14px, 16px padding)
- CTA Button (bottom, 16px padding)
  - Primary style
  - Full-width on mobile
  - Fixed-width on desktop (160px)

**CTA Section (center-aligned, 200px height):**
- Primary Button (200px × 56px)
  - Text: "{{cta_text}}"
  - Click → {{destination}}

**Footer (full-width, 120px height):**
- Links (horizontal, center-aligned)
- Copyright notice (center, 12px text)

**Interactions:**
- Card hover → Elevation shadow
- Button hover → Darken 10%
- Button click → {{action}}
- Links hover → Underline

**States:**
- Default
- Hover (for interactive elements)
- Focus (keyboard navigation)
- Active (click/tap)
- Disabled (when applicable)
- Loading (for async actions)

**Responsive Behavior:**
- **Mobile (320-767px):**
  - Single column layout
  - Stack cards vertically
  - Full-width buttons
  - Hamburger menu for navigation

- **Tablet (768-1023px):**
  - 2-column grid
  - Navigation visible
  - Moderate padding

- **Desktop (1024px+):**
  - 2-3 column grid
  - Maximum content width: 1200px
  - Centered with side margins
```

**Create wireframes for all {{screen_count}} screens.**

---

### Part 5: Ensure Accessibility

**For each screen, document accessibility features:**

```markdown
### Accessibility: {{screen_name}}

**WCAG {{wcag_level}} Compliance:**

**Perceivable:**
- [ ] All images have alt text: "{{alt_text}}"
- [ ] Color contrast checked:
  - Text on background: {{ratio}} (minimum 4.5:1)
  - UI components: {{ratio}} (minimum 3:1)
- [ ] Information not conveyed by color alone
- [ ] Text resizable to 200% without breaking layout
- [ ] No horizontal scrolling at 320px width

**Operable:**
- [ ] Tab order: {{tab_order_sequence}}
- [ ] Focus indicators visible (2px outline, primary color)
- [ ] No keyboard traps
- [ ] Skip navigation link: "Skip to main content"
- [ ] Touch targets minimum 44px × 44px
- [ ] Animations respect prefers-reduced-motion

**Understandable:**
- [ ] Page language: `lang="en"`
- [ ] Form labels for all inputs
- [ ] Error messages: "{{example_error}}" (clear and actionable)
- [ ] Consistent navigation across pages
- [ ] Predictable interactions (no surprise navigation)

**Robust:**
- [ ] Semantic HTML: `<header>`, `<nav>`, `<main>`, `<footer>`
- [ ] ARIA labels where needed:
  - Button: `aria-label="{{label}}"`
  - Icon-only: `aria-label="{{description}}"`
- [ ] Form validation: `aria-invalid`, `aria-describedby`
- [ ] Modal: `role="dialog"`, `aria-modal="true"`

**Keyboard Navigation:**
```
Tab → Focus next interactive element
Shift+Tab → Focus previous
Enter → Activate button/link
Space → Activate button, toggle checkbox
Escape → Close modal/dropdown
Arrow keys → Navigate within component (tabs, menus)
```

**Screen Reader Annotations:**
- Landmark regions: header, nav, main, footer
- Headings hierarchy: H1 (once), H2 (sections), H3 (subsections)
- Alternative text for images: descriptive, not decorative
- Live regions for dynamic content: `aria-live="polite"`
```

---

### Part 6: Define Components

**Extract reusable components from wireframes:**

```markdown
## Component Library

### Button Component

**Variants:**
- **Primary:** Main actions (e.g., Submit, Save)
  - Background: Primary color
  - Text: White
  - Padding: 12px 24px
  - Border-radius: 4px
  - Font: 16px, 600 weight

- **Secondary:** Less important actions (e.g., Cancel)
  - Background: Transparent
  - Text: Primary color
  - Border: 1px solid primary
  - Padding: 12px 24px

- **Tertiary:** Minimal emphasis (e.g., text links)
  - Background: Transparent
  - Text: Primary color
  - No border

**States:**
- Default
- Hover: Background darkens 10%
- Focus: 2px outline, offset 2px
- Active: Background darkens 20%
- Disabled: Opacity 50%, cursor not-allowed

**Accessibility:**
- Minimum size: 44px × 44px
- Focus indicator visible
- aria-disabled when disabled

---

### Card Component

**Structure:**
- Image (optional, 16:9 aspect ratio)
- Title (H3)
- Description (Body text)
- Action button (optional)

**Sizing:**
- Mobile: Full-width
- Tablet: 48% width (2 columns)
- Desktop: 32% width (3 columns)

**Spacing:**
- Internal padding: 16px
- Gap between cards: 24px

**States:**
- Default: elevation 1
- Hover: elevation 2
- Focus: outline

---

### Form Input Component

**Structure:**
- Label (above input, required)
- Input field
- Help text (optional)
- Error message (when invalid)

**Styling:**
- Border: 1px solid neutral-300
- Padding: 12px
- Border-radius: 4px
- Font: 16px (prevent zoom on mobile)

**States:**
- Default: neutral border
- Focus: primary border, 2px
- Error: error border, show error message
- Disabled: gray background, not-allowed cursor

**Accessibility:**
- Label linked to input: `for="{{id}}"`
- Required: `aria-required="true"`
- Error: `aria-invalid="true"`, `aria-describedby="{{error-id}}"`

[Define all reusable components...]
```

---

### Part 7: Define Design Tokens

**Create design system tokens:**

```markdown
## Design Tokens

### Colors

**Primary Palette:**
- Primary: #0066CC (contrast ratio: 4.57:1 on white)
- Primary-dark: #004C99
- Primary-light: #3385D6

**Semantic Colors:**
- Success: #00AA44 (WCAG AA compliant)
- Warning: #FF8800
- Error: #DD0000
- Info: #0066CC

**Neutral Palette:**
- Neutral-50: #F9F9F9 (backgrounds)
- Neutral-100: #F0F0F0
- Neutral-300: #CCCCCC (borders)
- Neutral-500: #999999 (secondary text)
- Neutral-700: #555555 (primary text)
- Neutral-900: #222222 (headings)

**Contrast Ratios (checked):**
- Neutral-700 on white: 7.5:1 ✓ (AAA)
- Primary on white: 4.57:1 ✓ (AA)
- Error on white: 6.2:1 ✓ (AA)

### Typography

**Font Family:**
- Primary: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif
- Monospace: "SF Mono", Monaco, monospace

**Type Scale:**
- H1: 48px / 600 / 1.2 line-height
- H2: 36px / 600 / 1.3
- H3: 24px / 600 / 1.4
- H4: 20px / 600 / 1.4
- Body: 16px / 400 / 1.6
- Small: 14px / 400 / 1.5
- Tiny: 12px / 400 / 1.4

**Responsive Type:**
- Mobile: Reduce by 20%
- Tablet: Reduce by 10%
- Desktop: Base scale

### Spacing

**Scale (based on 8px):**
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- 2xl: 48px
- 3xl: 64px

**Layout:**
- Container max-width: 1200px
- Gutter: 16px (mobile), 24px (desktop)
- Section spacing: 48px (mobile), 96px (desktop)

### Shadows

**Elevation:**
- Level 1: 0 1px 3px rgba(0,0,0,0.12)
- Level 2: 0 4px 6px rgba(0,0,0,0.16)
- Level 3: 0 10px 20px rgba(0,0,0,0.20)

### Border Radius

- Small: 4px (buttons, inputs)
- Medium: 8px (cards)
- Large: 16px (modals)
- Circle: 50% (avatars, icon buttons)

### Breakpoints

- Mobile: 320px - 767px
- Tablet: 768px - 1023px
- Desktop: 1024px+
```

---

### Part 8: Create Developer Handoff

**Document implementation details:**

```markdown
## Developer Handoff

### Implementation Priorities

**Phase 1 - Foundation:**
1. Set up design tokens (colors, spacing, typography)
2. Implement base components (Button, Input, Card)
3. Create responsive grid system
4. Set up accessibility infrastructure

**Phase 2 - Screens:**
1. {{highest_priority_screen}}
2. {{second_priority_screen}}
3. {{third_priority_screen}}

**Phase 3 - Polish:**
1. Animations and transitions
2. Loading states
3. Error states
4. Edge cases

### Component Implementation Notes

**Button Component:**
```css
/* Base button */
.btn {
  padding: 12px 24px;
  border-radius: 4px;
  font-size: 16px;
  font-weight: 600;
  min-width: 44px;
  min-height: 44px;
  cursor: pointer;
  transition: background 0.2s;
}

.btn:focus {
  outline: 2px solid var(--primary);
  outline-offset: 2px;
}

/* Primary variant */
.btn-primary {
  background: var(--primary);
  color: white;
}

.btn-primary:hover {
  background: var(--primary-dark);
}
```

### Responsive Implementation

**Mobile-first approach:**
```css
/* Base (mobile) */
.container {
  padding: 16px;
}

/* Tablet */
@media (min-width: 768px) {
  .container {
    padding: 24px;
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .container {
    max-width: 1200px;
    margin: 0 auto;
  }
}
```

### Accessibility Implementation

**Required attributes:**
- All images: `alt="{{description}}"`
- Form inputs: `id`, `aria-label` or `<label for>`
- Buttons: `aria-label` if icon-only
- Modals: `role="dialog"`, `aria-modal="true"`
- Live regions: `aria-live="polite"`

**Testing:**
- Keyboard navigation (Tab, Enter, Escape)
- Screen reader (test with NVDA/JAWS/VoiceOver)
- Color contrast (use Axe DevTools)
- Zoom to 200% (check layout)

### Assets Needed

**Images:**
- Logo (SVG preferred, PNG fallback)
- Icons (SVG, 24px × 24px)
- Placeholder images (16:9 ratio)

**Fonts:**
- System fonts (no web fonts for performance)

**Third-party:**
- None (using native HTML/CSS/JS)
```

---

### Part 9: Generate UX Design Document

**Create comprehensive design document per `helpers.md#Apply-Variables-to-Template`**

**Use template:** `ux-design.md` (or generate inline)

**Document structure:**
```markdown
# UX Design: {{project_name}}

**Date:** {{date}}
**Designer:** {{user_name}}
**Version:** 1.0

## Project Overview

**Project:** {{project_name}}
**Target Platforms:** {{target_platforms}}
**Accessibility:** WCAG {{wcag_level}}

## Design Scope

**Screens:** {{screen_count}}
**User Flows:** {{flow_count}}
**Components:** {{component_count}}

## User Flows

{{all_flows_from_part_3}}

## Wireframes

{{all_wireframes_from_part_4}}

## Accessibility

{{accessibility_annotations_from_part_5}}

## Component Library

{{components_from_part_6}}

## Design Tokens

{{design_tokens_from_part_7}}

## Developer Handoff

{{handoff_from_part_8}}

## Validation

**Requirements Coverage:**
- [ ] US-001: {{requirement}} → {{screen}}
- [ ] US-002: {{requirement}} → {{screen}}
[All user stories mapped to screens]

**Accessibility Checklist:**
- [ ] WCAG {{level}} compliance verified
- [ ] Keyboard navigation tested
- [ ] Screen reader compatible
- [ ] Color contrast verified
- [ ] Responsive on all target platforms

**Sign-off:**
- [ ] Product Manager approved
- [ ] System Architect reviewed
- [ ] Ready for implementation

---

*Generated by BMAD Method v6 - UX Designer*
*Design Date: {{date}}*
```

**Save to:** `{{output_folder}}/ux-design-{{project_name}}.md`

**Inform user:**
```
✓ UX Design Complete!

Screens: {{screen_count}}
User Flows: {{flow_count}}
Components: {{component_count}}
Accessibility: WCAG {{level}}

Document: {{file_path}}

Ready for developer handoff!
```

---

## Update Status

Per `helpers.md#Update-Workflow-Status`

Update `bmm-workflow-status.yaml`:
```yaml
phase_2_planning:
  ux_design_completed: true
  ux_design_date: {{current_date}}
  screens_designed: {{screen_count}}
  accessibility_level: {{wcag_level}}

last_workflow: create-ux-design
last_workflow_date: {{current_date}}
```

---

## Recommend Next Steps

```
✓ UX Design Complete!

Next Steps:

1. **Review with Product Manager**
   - Validate designs meet requirements
   - Confirm all user stories covered
   - Approve design direction

2. **Architecture Review**
   Run: /architecture
   - Architect should validate UX constraints
   - Ensure feasibility
   - Identify technical considerations

3. **Implementation Planning**
   Run: /sprint-planning
   - Break design into implementation stories
   - Prioritize screens
   - Estimate effort

4. **Begin Development**
   Run: /dev-story
   - Start with highest-priority screen
   - Implement design system tokens first
   - Build components before screens
```

---

## Helper References

- **Load config:** `helpers.md#Combined-Config-Load`
- **Load documents:** `helpers.md#Load-Documents`
- **Apply template:** `helpers.md#Apply-Variables-to-Template`
- **Save document:** `helpers.md#Save-Output-Document`
- **Update status:** `helpers.md#Update-Workflow-Status`
- **Determine next:** `helpers.md#Determine-Next-Workflow`

---

## Notes for LLMs

- Use TodoWrite to track UX design steps (Part 3.5 포함 시 10 steps)
- Load requirements (PRD/tech-spec) before starting
- **Part 3.5에서 디자인 도구를 선택하고, MCP 서버 감지 결과에 따라 적절한 워크플로우 분기**
- Create user flows for all major features
- Use ASCII art for quick wireframes or structured descriptions for detailed specs
- **Figma/Pencil MCP 사용 시에도 ASCII/마크다운 문서를 병행 생성 (폴백 및 Git 추적용)**
- Always include accessibility annotations for WCAG compliance
- Define design tokens for consistency
- Extract reusable components
- Provide detailed developer handoff notes
- Map all user stories to screens
- Design mobile-first, then scale up
- Check color contrast ratios
- Specify all interaction states (default, hover, focus, active, disabled)
- Document responsive behavior for all breakpoints
- Use semantic HTML in recommendations
- Reference helpers.md for all common operations
- Validate design against requirements before finalizing
- **MCP 도구 호출 실패 시 자동으로 ASCII/마크다운 폴백 진행**

**Remember:** User-centered, accessible design ensures products work for everyone. Design with developers in mind - clear specs, design tokens, and handoff notes make implementation smooth.
