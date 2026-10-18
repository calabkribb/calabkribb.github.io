# CALab 홈페이지 — Claude Code 작업 지침

## 프로젝트 개요
- KRIBB Cellular Agenomics Lab(CALab, PI 김천아) 연구실 홈페이지. **영어 기본** (`lang: en`), Join us만 한국어(`join.qmd`의 `lang: ko`). 연구실 개설 2020년.
- 엔진: Quarto website (`_quarto.yml`), 호스팅: GitHub Pages.
- GitHub 계정: `calabkribb`, 저장소: `calabkribb/calabkribb.github.io`
- 배포 방식: 로컬에서 `quarto render` → `docs/` 생성 → main(또는 기본) 브랜치에 push
  → GitHub Settings > Pages에서 Source를 "Deploy from a branch", 폴더 `/docs`로 설정.
- 목표 URL: https://calabkribb.github.io/
- 디자인 레퍼런스:
  - 상단 메뉴바(왼쪽 로고+이름, 오른쪽 메뉴)·홈 배너: https://caojunyuelab.org
  - Research(프로젝트별 설명+Key papers+모식도): https://joonanlab.github.io/research
  - Publications 주제 탭, Join us: https://joonanlab.github.io/publications , /join
  - Team 사진 격자(같은 크기·흑백): https://hostmicrobe.org/team/
  - Team > Collaborators 탭: https://shaleklab.com/team/?tab=collaborators
  - Models & Tools(내용 구성만 참고): https://shaleklab.com/technology/model/ , /resources/protocols/

## 현재 단계
- 호스팅 테스트 완료(2026-10-11). **콘텐츠 작성 단계.** 논문(CV 기반)·PI 정보는 실제 내용,
  나머지는 placeholder 또는 "(draft)" 표시된 초안.
- 로고 `assets/logo.png`: 2026-10-11 캡처본(432×170, 투명 배경)으로 교체. 고해상도 원본 받으면 같은 이름으로 교체.
- 대중강연·글쓰기는 Outreach 메뉴(`outreach.qmd`). PI 페이지에는 링크만.

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
  - 2026-10-11 호스팅 테스트 성공: main 브랜치 `/docs` 배포, https://calabkribb.github.io/ 정상 표시.

## 파일 구조
- `_quarto.yml` 사이트 설정(상단 navbar, footer, `site-url`, 최종 수정일), `styles.scss` 스타일
- 휴대폰(768px 미만) 메뉴바: 로고 숨기고 제목을 "CALab"으로 표시 (`styles.scss`의 `.navbar-title::after`).
- 메뉴(오른쪽): Research(`research.qmd`), Models & Tools(`methods.qmd`), Team(`team.qmd`), Publications, News,
  Photos, Outreach(`outreach.qmd`), Join us. 메뉴 8개라 `collapse-below: xl`(1200px 미만 햄버거 메뉴).
  검색 아이콘 없음(`search: false`), GitHub 아이콘 노출하지 않음.
  홈(`index.qmd`)은 로고/이름 클릭.
- 데이터 → 페이지 자동 생성 (페이지가 아니라 데이터 파일을 수정할 것):
  - `data/projects.yml` → research.qmd (2026-10-19 개편). 주제: Aging environments, Cell-fate decisions,
    From fate to disease (anchor `#aging-environments`, `#cell-fate-decisions`, `#fate-to-disease`).
    필드: `question`, `what_we_do`, `figure`·`alt`(`assets/research/`), `papers`(title·authors·journal·year·doi를
    직접 기입, PubMed 제목 기준. publications.csv와 연결 안 함), `funding`(과제번호 확정 전에는 `[]` → 미표시).
    개요는 research.qmd 본문: 리드 문장(`.research-lead`) + 설명 2문장(`.research-intro`), 이어서 개요 그림.
    BioArt 출처 문장도 research.qmd 본문. (front matter `description`은 서식을 못 넣어 쓰지 않음)
    그림 4개 모두 본문(문단) 폭 — 2026-10-19 사용자 요청으로 `.column-page` 해제.
    Research 페이지만 `date-modified: ""`로 수정일 숨김.
  - `key_paper()`(제목 앞부분으로 publications.csv 검색)는 이제 methods.yml에서만 사용.
  - `data/methods.yml` → methods.qmd (분야별 예시 이미지·설명·기법 목록(하위 항목 `{name, details}`)·대표 논문).
    이미지는 `assets/methods/` (현재 R로 만든 모의 데이터 예시 → 실제 이미지로 교체)
  - `data/publications.csv` → publications.qmd (`key=TRUE`→Selected 탭, `topics`(;구분)→주제 탭,
    주제 목록·순서는 `R/site.R`의 `PUB_TOPICS`, 굵게 표시할 PI 이름은 `PI_NAME`)
  - `data/news.csv` → news.qmd 전체, index.qmd 최근 3건
  - `data/lectures.csv` → outreach.qmd 강연 카드 (YouTube 주소에서 썸네일 자동, date는 YouTube 게시월)
  - `data/collaborators.csv` → team.qmd의 Collaborators 탭 (region별 묶음)
  - `team/<이름>.qmd` 1인 1파일 → team.qmd Members 탭(listing, `order` 순) + 개인 페이지(about: trestles).
    PI: Research interests·Employment·Education & Training·Awards / 구성원: Research interests·Education & Training·Awards·Fellowship.
    Awards는 한글로 작성. 사진은 컬러.
  - `photos/<행사종류>/YYYY-MM_설명.jpg` → photos.qmd (폴더=섹션, 최신순, lightbox)
- `R/site.R` 페이지 공통 R 함수 (`show_pubs()`, `show_projects()`, `show_methods()`, `show_news()`, `show_collaborators()`, `show_photos()`)
- `assets/` 로고, 홈 배너 배경(`hero-bg.jpg`), `team/` 구성원 사진, `projects/` 모식도
- `docs/` = render 산출물

## 구성원 사진 규격
- 세로 3:4, 최소 600×800 px(권장 900×1200), JPG, 단색 배경, 어깨 위 정면, 머리 위 여백 약간.
- 파일명 `assets/team/<이름-성>.jpg`(소문자·하이픈), 해당 `team/<이름>.qmd`의 `image:`에 경로 지정.
- 사이트에서는 CSS로 3:4 크롭(위쪽 기준), 컬러 그대로 표시. 비율이 달라도 찌그러지지 않지만
  아래쪽이 잘리므로 3:4로 받는 것이 안전. 사진 없으면 `assets/team/placeholder.png`.

## 반드시 지킬 규칙
1. `docs/`는 직접 수정하지 말 것. 전체 render 때마다 통째로 재생성되어 수동 추가 파일은 삭제됨.
2. `.gitignore`에 `docs/`를 넣지 말 것 (배포 대상).
3. `.nojekyll`은 프로젝트 루트에 두고 `_quarto.yml`의 `project: resources:`로 docs/에 복사됨. 지우지 말 것.
4. `styles.scss`의 `url()` 이미지 경로는 **scss 파일 위치 기준**(`assets/...`)으로 쓸 것.
   컴파일된 CSS 기준 경로(`../../assets/...`)는 render 실패를 일으킴(검증됨).
5. `styles.scss`의 구성원 카드 CSS는 Quarto listing 내부 DOM(`#listing-members`, `img.card-img`,
   인라인 height)에 의존함. Quarto 버전 변경 후 반드시 Team 페이지를 `quarto preview`로 확인.
6. 저장소는 public. 미공개 데이터·동의받지 않은 인물 사진을 넣지 말 것.
   공개 이메일은 PI의 `kimchuna@kribb.re.kr` 하나만 사용(사용자 지정, `_quarto.yml`·`team/chuna-kim.qmd`·`join.qmd`).
   구성원 개인 이메일은 넣지 말 것.
10. 글꼴은 `styles.scss`에서 Noto Sans KR로 통일(한글·영문 공용). 한글 텍스트가 섞여도 별도 글꼴 지정 불필요.
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
