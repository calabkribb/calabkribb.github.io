# CALab 홈페이지 — Claude Code 작업 지침

## 프로젝트 개요
- KRIBB Cellular Aging Laboratory(CALab) 연구실 홈페이지.
- 엔진: Quarto website (`_quarto.yml`), 호스팅: GitHub Pages.
- GitHub 계정: `calabkribb`, 저장소: `calabkribb/calabkribb.github.io`
- 배포 방식: 로컬에서 `quarto render` → `docs/` 생성 → main(또는 기본) 브랜치에 push
  → GitHub Settings > Pages에서 Source를 "Deploy from a branch", 폴더 `/docs`로 설정.
- 목표 URL: https://calabkribb.github.io/
- 디자인 레퍼런스: https://hostmicrobe.org/research/ (왼쪽 고정 사이드바 + 사진 배경, Research 카드 목록)

## 현재 단계
- **호스팅 테스트 단계.** 모든 콘텐츠는 placeholder. 실제 콘텐츠는 테스트 성공 후 작성.
- 정식 단계에서는 콘텐츠를 데이터 파일(team.yml, publications.csv, media.csv, photos/ 폴더)로
  관리하고, 페이지는 R chunk가 자동 생성하는 구조로 확장할 예정.

## 검증된 환경 (사용자 맥에서 실제 버전 확인 후 이 섹션 갱신)
- Quarto 1.10.19 (2026-10 기준 GitHub latest release)
- 골격은 Quarto 1.10.19 + R 4.3.3 + knitr 1.45 + rmarkdown 2.25 (Linux)에서 렌더링 검증됨.
- 맥에서는 `quarto --version`, `R --version`, `packageVersion("knitr")` 등으로 실제 버전을 확인할 것.
- 사용자 맥(macOS, Darwin 27.0.0, arm64) 확인 결과 (2026-10-11):
  - git 2.55.0, Homebrew 6.0.12
  - Quarto 1.10.19 (`/usr/local/bin/quarto`)
  - R 4.6.1 (2026-06-24), RStudio 설치됨 (`/Applications/RStudio.app`)
  - knitr 1.52, rmarkdown 2.32, usethis 3.2.2, gitcreds 0.1.2
  - 위 환경에서 `quarto render` 성공(10개 파일), docs/에 index.html·.nojekyll 생성 확인.
    사이드바 배경 이미지는 Quarto가 docs/site_libs/bootstrap/assets/로 복사함(경로 정상).

## 파일 구조
- `_quarto.yml` 사이트 설정(메뉴·사이드바), `styles.scss` 스타일
- `index.qmd`, `team.qmd`, `publications.qmd`(R chunk로 `data/publications.csv` 읽음),
  `tools.qmd`, `media.qmd`, `gallery.qmd`, `research/`(listing + topic*.qmd)
- `assets/` 로고·사이드바 배경, `photos/` 갤러리 이미지
- `docs/` = render 산출물

## 반드시 지킬 규칙
1. `docs/`는 직접 수정하지 말 것. 전체 render 때마다 통째로 재생성되어 수동 추가 파일은 삭제됨.
2. `.gitignore`에 `docs/`를 넣지 말 것 (배포 대상).
3. `.nojekyll`은 프로젝트 루트에 두고 `_quarto.yml`의 `project: resources:`로 docs/에 복사됨. 지우지 말 것.
4. `styles.scss`의 `url()` 이미지 경로는 **scss 파일 위치 기준**(`assets/...`)으로 쓸 것.
   컴파일된 CSS 기준 경로(`../../assets/...`)는 render 실패를 일으킴(검증됨).
5. 사이드바 순서(로고→이름→태그라인→검색→메뉴)를 바꾸는 CSS는 Quarto 내부 DOM 클래스에 의존함.
   Quarto 버전 변경 후 반드시 `quarto preview`로 확인.
6. 저장소는 public. 실제 이메일·미공개 데이터·동의받지 않은 인물 사진을 넣지 말 것.
7. GitHub 토큰·비밀번호는 사용자가 직접 입력. 토큰을 대화창에 붙여넣게 하거나 파일에 쓰지 말 것.
8. 대화형 입력이 필요한 명령(`gitcreds::gitcreds_set()`, `usethis::use_git()`의 선택 메뉴 등)은
   사용자에게 RStudio Console에서 직접 실행하도록 안내할 것.
9. git push, 저장소 생성처럼 외부에 반영되는 작업은 실행 전 사용자 확인을 받을 것.

## 응답 원칙 (사용자 선호)
- 한국어로 답할 것. 사용자가 편한 어조여도 엄밀함을 낮추지 말 것.
- 패키지·툴 버전을 명시할 것. 존재를 확신하지 못하는 함수·인자·옵션은 쓰지 말 것
  (필요하면 공식 문서를 확인하거나, 실제로 실행해 검증한 뒤 쓸 것).
- 답변 끝에 후속 작업 제안이나 유도형 질문을 붙이지 말 것.
  단, 현재 작업의 타당성에 직결되는 경고는 본문 안에서 반드시 지적할 것.
- 사용자는 R에 익숙하고 HTML에는 익숙하지 않음. HTML/CSS 수정은 최소화하고, 수정 시 이유를 설명할 것.

## 진행 단계 (호스팅 테스트)
1. 도구 확인: `git --version`, `quarto --version`(1.10.19 권장), R 패키지 knitr·rmarkdown·usethis·gitcreds 설치 여부.
2. `quarto render` 실행 후 `docs/`에 `index.html`, `.nojekyll` 존재 확인. 에러 시 원인 진단.
3. (사용자 직접) RStudio Console에서
   `usethis::use_git_config()`, `usethis::create_github_token()`(calabkribb 계정으로 로그인 상태에서),
   `gitcreds::gitcreds_set()` 실행.
4. Git 초기화·첫 commit(`docs/` 포함) → GitHub 저장소 `calabkribb.github.io` 생성 → push.
   (`usethis::use_git()` / `usethis::use_github()` 또는 git CLI. 실행 전 사용자 확인.)
5. (사용자 직접) GitHub Settings > Pages: Deploy from a branch, 기본 브랜치, `/docs` → Save.
6. Actions 탭 배포 완료 후 https://calabkribb.github.io/ 접속 확인.
