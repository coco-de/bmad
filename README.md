# BMAD Method v6

**Breakthrough Method for Agile AI-Driven Development**

BMAD는 Claude Code의 Skills & Commands 체계를 활용하여 소프트웨어 개발 전 과정을 구조화된 워크플로우로 관리하는 방법론입니다.

## 개요

BMAD Method는 4개의 Phase로 구성된 애자일 개발 프레임워크입니다:

| Phase | 이름 | 워크플로우 | 담당 에이전트 |
|-------|------|-----------|-------------|
| 1 | Analysis | product-brief, research, brainstorm | Business Analyst, Creative Intelligence |
| 2 | Planning | prd, tech-spec | Product Manager |
| 3 | Solutioning | architecture, create-ux-design, solutioning-gate-check | System Architect, UX Designer |
| 4 | Implementation | sprint-planning, create-story, dev-story | Scrum Master, Developer |

## 프로젝트 레벨

프로젝트 규모에 따라 필요한 워크플로우가 달라집니다:

| Level | 규모 | 스토리 수 | 필수 워크플로우 |
|-------|------|----------|---------------|
| 0 | 단일 변경 | 1 | tech-spec → dev-story |
| 1 | 소규모 기능 | 1-10 | tech-spec → sprint-planning → dev-story |
| 2 | 중규모 기능 | 5-15 | prd → architecture → sprint-planning → dev-story |
| 3 | 복잡한 통합 | 12-40 | prd → architecture → sprint-planning → dev-story |
| 4 | 엔터프라이즈 | 40+ | prd → architecture → sprint-planning → dev-story |

## 설치

### 1. 파일 복사

`~/.claude/` 디렉토리에 다음 구조로 복사합니다:

```bash
# 설정 파일
cp -r config/bmad/ ~/.claude/config/bmad/

# 커맨드 (슬래시 명령어)
cp -r commands/bmad/ ~/.claude/commands/bmad/

# 스킬 (에이전트 정의)
cp -r skills/bmad/ ~/.claude/skills/bmad/
```

### 2. 글로벌 설정

`~/.claude/config/bmad/config.yaml`을 열어 사용자 정보를 수정합니다:

```yaml
user_name: "your-name"
user_skill_level: "intermediate"  # beginner, intermediate, expert
communication_language: "English"
document_output_language: "English"
```

### 3. 프로젝트 초기화

프로젝트 루트에서 Claude Code를 실행하고:

```
/bmad:workflow-init
```

## 사용법

### 기본 워크플로우

```bash
# 프로젝트 상태 확인
/bmad:workflow-status

# Phase 1: 분석
/bmad:product-brief          # 제품 개요 작성
/bmad:research               # 시장/기술 리서치
/bmad:brainstorm             # 아이디어 브레인스토밍

# Phase 2: 기획
/bmad:prd                    # PRD(제품 요구사항 문서) 작성
/bmad:tech-spec              # 기술 명세서 작성

# Phase 3: 설계
/bmad:architecture           # 시스템 아키텍처 설계
/bmad:create-ux-design       # UX 디자인 생성
/bmad:solutioning-gate-check # 설계 품질 검증

# Phase 4: 구현
/bmad:sprint-planning        # 스프린트 계획 수립
/bmad:create-story STORY-001 # 개별 스토리 상세 작성
/bmad:dev-story STORY-001    # 스토리 구현
```

### 일반적인 흐름 예시

**Level 2 프로젝트 (중규모 기능):**

```
/bmad:workflow-init
  → /bmad:product-brief
    → /bmad:prd
      → /bmad:architecture
        → /bmad:sprint-planning
          → /bmad:dev-story STORY-001
          → /bmad:dev-story STORY-002
          → ...
```

## 디렉토리 구조

```
~/.claude/
├── config/bmad/
│   ├── config.yaml                  # 글로벌 설정
│   ├── helpers.md                   # 공용 헬퍼 유틸리티
│   ├── project-config.template.yaml # 프로젝트 설정 템플릿
│   └── templates/                   # 문서 템플릿
│       ├── architecture.md
│       ├── bmm-workflow-status.template.yaml
│       ├── prd.md
│       ├── product-brief.md
│       ├── sprint-status.template.yaml
│       └── tech-spec.md
│
├── commands/bmad/                   # 슬래시 커맨드 (15개)
│   ├── architecture.md
│   ├── brainstorm.md
│   ├── create-agent.md
│   ├── create-story.md
│   ├── create-ux-design.md
│   ├── create-workflow.md
│   ├── dev-story.md
│   ├── prd.md
│   ├── product-brief.md
│   ├── research.md
│   ├── solutioning-gate-check.md
│   ├── sprint-planning.md
│   ├── tech-spec.md
│   ├── workflow-init.md
│   └── workflow-status.md
│
└── skills/bmad/                     # 에이전트 스킬 (9개)
    ├── core/
    │   └── bmad-master/SKILL.md     # 코어 오케스트레이터
    ├── bmm/                         # BMad Method 에이전트
    │   ├── analyst/SKILL.md         # Business Analyst
    │   ├── architect/SKILL.md       # System Architect
    │   ├── developer/SKILL.md       # Developer
    │   ├── pm/SKILL.md              # Product Manager
    │   ├── scrum-master/SKILL.md    # Scrum Master
    │   └── ux-designer/SKILL.md     # UX Designer
    ├── bmb/                         # BMad Builder
    │   └── builder/SKILL.md         # Workflow Builder
    └── cis/                         # Creative Intelligence Suite
        └── creative-intelligence/SKILL.md
```

## ZenHub 연동

BMAD는 ZenHub MCP 서버와 연동하여 이슈를 자동 관리합니다.

### 지원 기능

| 워크플로우 | ZenHub 연동 내용 |
|-----------|----------------|
| `/bmad:sprint-planning` | Epic/Story 이슈 일괄 생성, 스프린트 할당, 의존성 설정 |
| `/bmad:create-story` | 개별 Story 이슈 생성, Epic 연결, 포인트 설정 |
| `/bmad:dev-story` | 파이프라인 자동 이동 (Sprint Backlog → In Progress → Review/QA) |

### 작동 방식

- **Additive**: 로컬 마크다운 문서 생성 후 ZenHub에 동기화 (추가 단계)
- **Graceful Degradation**: ZenHub MCP 미사용 환경에서는 경고 후 기존 로컬 흐름 유지
- **GitHub Issues**: `createGitHubIssue`로 `[Epic]`, `[Story]` 접두사 이슈 생성
- **Cross-Reference**: sprint-status.yaml에 `zh_issue_id`, `zh_issue_number`, `zh_issue_url` 저장

### ZenHub MCP 설정

Claude Code에서 ZenHub MCP 서버를 설정하면 자동으로 연동됩니다. 별도 BMAD 설정은 필요하지 않습니다.

## 프로젝트 산출물

BMAD 워크플로우를 실행하면 프로젝트 루트에 다음 파일들이 생성됩니다:

```
{project-root}/
├── bmad/
│   └── config.yaml              # 프로젝트 설정
├── docs/
│   ├── bmm-workflow-status.yaml # 워크플로우 진행 상태
│   ├── sprint-status.yaml       # 스프린트 상태 (ZenHub 크로스레퍼런스 포함)
│   ├── product-brief-*.md       # 제품 개요
│   ├── prd-*.md                 # PRD
│   ├── tech-spec-*.md           # 기술 명세
│   ├── architecture-*.md        # 아키텍처 문서
│   ├── sprint-plan-*.md         # 스프린트 계획
│   └── stories/
│       ├── STORY-001.md         # 개별 스토리 문서
│       ├── STORY-002.md
│       └── ...
```

## 모듈

| 모듈 | 설명 | 기본 활성화 |
|------|------|-----------|
| **core** | BMad Master 오케스트레이터 | O |
| **bmm** | BMad Method - 제품 개발 워크플로우 | O |
| **bmb** | BMad Builder - 커스텀 워크플로우/에이전트 생성 | X |
| **cis** | Creative Intelligence Suite - 리서치/브레인스토밍 | X |

모듈 활성화는 `~/.claude/config/bmad/config.yaml`의 `modules_enabled`에서 설정합니다.

## 라이선스

MIT
