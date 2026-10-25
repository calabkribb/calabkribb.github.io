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
    개요는 research.qmd 본문: 리드 문장(`.page-lead`) + 설명 2문장(`.page-intro`), 이어서 개요 그림.
    BioArt 출처 문장도 research.qmd 본문. (front matter `description`은 서식을 못 넣어 쓰지 않음)
    그림 4개 모두 본문(문단) 폭 — 2026-10-19 사용자 요청으로 `.column-page` 해제.
    Research 페이지만 `date-modified: ""`로 수정일 숨김.
  - `data/methods.yml` → methods.qmd (2026-10-19 개편). yml에는 반복 데이터만: `data_cards`(6, 아이콘·제목·
    태그{label, kind}·설명), `assay_cards`(4), `papers`(fini, computation). 섹션 제목·문단·그림·Models 목록은
    methods.qmd에 직접 씀. 그림 `assets/methods/mt_*.webp`(본문 폭), 아이콘 `assets/methods/icons/`(장식용, `fig-alt=""`).
    섹션 anchor: `#fini-seq`, `#data-we-generate`, `#models`, `#functional-assays`, `#computation`.
    협력 기관·연구자 이름은 쓰지 않고 "Collaboration" 태그만 씀.
  - Key papers 표기는 두 페이지 공통 함수 `paper_list()` (제목+DOI 링크, 다음 줄 "Author et al., **Journal**, Year").
  - `data/publications.csv` → publications.qmd (`key=TRUE`→Selected 탭, `topics`(;구분)→주제 탭,
    주제 목록·순서는 `R/site.R`의 `PUB_TOPICS`, 굵게 표시할 PI 이름은 `PI_NAME`)
  - `data/news.csv` → news.qmd 전체, index.qmd 최근 3건
  - `data/lectures.csv` → outreach.qmd 강연 카드 (YouTube 주소에서 썸네일 자동, date는 YouTube 게시월)
  - `data/collaborators.yml` → team.qmd의 Collaborators 탭 (2026-10-19). `korea`(city별 people: name·institution·
    department), `international`(name·detail). 이름·소속은 yml 그대로, 순서도 yml 순서. 도시 배지 숫자는 yml에서 계산.
    지도 `assets/team/korea_map.svg`(도시 원 숫자 고정), `world_map.svg`.
    **인원이 바뀌면 korea_map.svg의 해당 `<text>` 숫자도 고칠 것. 새 도시는 지도에 원·선을 새로 그려야 하므로
    직접 고치지 말고 사용자에게 알릴 것.** render 후 배지 숫자와 지도 숫자가 같은지 확인.
    Team 페이지는 탭 전체를 `.column-page`(넓은 폭)로 감쌈. 수정일 숨김(`date-modified: ""`).
  - `team/<이름>.qmd` 1인 1파일 → team.qmd Members 탭(listing, `order` 순) + 개인 페이지(about: trestles).
    PI: Research interests·Employment·Education & Training·Awards / 구성원: Research interests·Education & Training·Awards·Fellowship.
    Awards는 한글로 작성. 사진은 컬러.
  - `photos/<YYYY-MM-DD>_<이름>/01.jpg …` → photos.qmd (2026-10-25 개편). 폴더 하나 = 이벤트 하나, 연도 → 이벤트 최신순.
    제목·사진 설명은 `data/photos.yml`(폴더 이름 → title, captions). 목록은 3열(휴대폰 2열)·4:3 크롭, 누르면 lightbox.
    날짜는 사진 파일 날짜 기준. 올리기 전에 EXIF 제거·회전 처리, 긴 변 1600px 이하.
  - `data/news.csv`(date, text): News 페이지는 연도별 소제목(`show_news(by_year = TRUE)`), Home은 최근 5건.
- `R/site.R` 페이지 공통 R 함수 (`show_pubs()`, `show_projects()`, `show_cards()`, `paper_list()`, `show_news()`, `show_collaborators()`, `show_photos()`)
- `styles.scss` 공통 클래스 (Research·Models & Tools): `section.page-sec`(섹션 구분선), `.label-sm`(작은 대문자 라벨,
  제목 안 `.kicker`는 머리말), `.paper-list`, `.box-card`(테두리 카드), `.tag` + `.tag-rna/-space/-protein/-metabolite/-house/-collab`,
  `.page-lead`/`.page-intro`(페이지 도입 리드 문장 + 설명), `.num-badge`(원형 숫자 배지: Research 주제 번호·Team 도시 인원).
  페이지 전용은 `.theme-*`(Research), `.mt-*`(Models & Tools), `.cb-*`(Team Collaborators).
- `assets/` 로고, 홈 배너 배경(`hero-bg.jpg`), `team/` 구성원 사진, `projects/` 모식도
- `docs/` = render 산출물

## 구성원 사진 규격
- 세로 3:4, 최소 600×800 px(권장 900×1200), JPG, 단색 배경, 어깨 위 정면, 머리 위 여백 약간.
- 파일명 `assets/team/<이름-성>.jpg`(소문자·하이픈), 해당 `team/<이름>.qmd`의 `image:`에 경로 지정.
- 사이트에서는 CSS로 3:4 크롭(위쪽 기준), 컬러 그대로 표시. 비율이 달라도 찌그러지지 않지만
  아래쪽이 잘리므로 3:4로 받는 것이 안전. 사진 없으면 `assets/team/placeholder.png`.
- **사진을 올리기 전 반드시 EXIF 메타데이터를 제거할 것** (2026-10-25 확인: 휴대폰 사진 2장에 촬영 위치 위도·경도가 들어 있었음).
  sips는 EXIF를 보존하므로 sips만으로는 지워지지 않음. 회전 정보(orientation=6 등)가 있는 사진은 픽셀을 직접 돌린 뒤
  EXIF를 지워야 브라우저에서 옆으로 눕지 않음. 처리: 회전 → 얼굴 중심 3:4 자르기 → 1200px보다 크면 축소(작은 사진은 확대 금지)
  → APP1(Exif) 구간 제거. 올린 뒤 `docs/assets/team/*.jpg`에 orientation·GPS가 없는지 확인.
- 표기 통일: 학위 B.S./M.S./Ph.D., 통합과정 "Integrated M.S./Ph.D.", 박사후연구원 "Postdoctoral Researcher".
  영문 이름은 본인이 준 표기 우선, 없으면 사이트 기존 표기 유지.

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

## 페이지 배치 메모 (2026-10-26)
- 수정일(Modified) 표시는 사이트 전체에서 없앰 (`_quarto.yml`의 `date-modified` 삭제).
- Research, Models & Tools: 왼쪽 목차(`toc: true`, `toc-location: left`, `toc-depth: 2`). 목차에서는 제목 안 머리말(`.kicker`) 숨김.
  휴대폰에서는 Quarto가 목차를 숨김 (Research는 본문 주제 카드로 이동 가능).
- Team, Publications: 넓은 폭. 자동 제목 영역을 끄고(`title-block-style: none`, `pagetitle`) `.column-page` 안에 `# 제목 {.title}`을 직접 써서
  제목과 내용의 왼쪽 끝을 맞춤.
- Publications: 연구실 구성원 저자는 `publications.csv` authors에서 `[[이름]]`으로 감싸 굵게 (PubMed 저자 전체 이름·소속으로 확인한 경우만).
  저널명은 굵게.
- 메뉴바 로고 높이 56px.
- (2026-10-26) **페이지 폭**: `_quarto.yml`의 `page-layout: full` + `styles.scss`의 `$grid-body-width: 1200px`
  (Quarto는 full 배치에서도 본문 최대 폭을 이 변수로 제한함). 여백 비교 캡처 4종 중 B안 채택 (2000px 화면에서 양옆 약 225px).
  Team 구성원 목록: 한 줄 5명(992px 이상) / 3명(태블릿) / 2명(휴대폰).
- Home: About 6/12 · Latest news 6/12, 최근 소식 5건 (`show_news(5)`). 배너 안쪽 여백 2.5rem, Home 전용 여백 축소 규칙
  (`body:has(.hero)`)으로 1440×900에서 스크롤 없이 전체가 보임 (여백 2안, 2026-10-26).
- Join us(한국어): 도입 리드 → 연구실 문화(호기심 / Team Chemistry / 소통 카드) → 모집 분야(박사과정·박사후연구원, 인원 표기 없음)
  → 입학 방법(UST, 학연과정) → 지원 방법. 방문자 지도 위젯은 넣지 않기로 함 (외부 계정·방문자 추적 문제).
