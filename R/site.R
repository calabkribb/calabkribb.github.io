# 페이지에서 source("R/site.R")로 불러 쓰는 공통 함수.
# 모든 show_*() 함수는 마크다운 문자열을 cat()으로 출력하므로 chunk에 `results: asis`가 필요함.
# 데이터 경로는 프로젝트 루트 기준 (모든 페이지가 루트에 있음).

# ---- 공통: 빈 칸을 ""로 통일 ----
# 열이 전부 비면 read.csv가 NA(논리형)로 읽고, nzchar(NA)는 TRUE라서 빈 링크가 생김
blank_na <- function(df, cols) {
  for (col in cols) df[[col]] <- ifelse(is.na(df[[col]]), "", as.character(df[[col]]))
  df
}

# ---- Publications ----
# 주제 탭 순서. publications.csv의 topics 열에 ;로 구분해 적은 이름과 정확히 같아야 함
PUB_TOPICS <- c("Aging", "Cellular Senescence", "Omics", "Inflammation", "Review")
PI_NAME <- "Kim, C."   # 저자 목록에서 굵게 표시할 이름

read_pubs <- function() {
  p <- read.csv("data/publications.csv", stringsAsFactors = FALSE)
  p <- blank_na(p, c("volume", "doi", "topics"))
  p[order(-p$year), ]
}

pub_topics <- function(p) {
  t <- trimws(strsplit(p$topics, ";")[[1]])
  t[nzchar(t)]
}

pub_entry <- function(p) {
  # 공동 제1저자 표시 *가 마크다운 기울임으로 해석되지 않도록 \* 로 이스케이프한 뒤 PI 이름을 굵게
  authors <- gsub("*", "\\*", p$authors, fixed = TRUE)
  authors <- gsub(PI_NAME, paste0("**", PI_NAME, "**"), authors, fixed = TRUE)
  vol <- if (nzchar(p$volume)) paste0(" ", p$volume) else ""
  doi <- if (nzchar(p$doi)) paste0(" · [doi](https://doi.org/", p$doi, ")") else ""
  tags <- pub_topics(p)
  tags <- if (length(tags)) paste0(" · ", paste0("`", tags, "`", collapse = " ")) else ""
  paste0("- **", p$title, "** \\\n  ", authors, " \\\n  *", p$journal, "*", vol,
         " (", p$year, ")", doi, tags, "\n")
}

pub_list <- function(pubs) {
  for (y in unique(pubs$year)) {
    cat("\n### ", y, "\n\n", sep = "")
    sub <- pubs[pubs$year == y, ]
    for (i in seq_len(nrow(sub))) cat(pub_entry(sub[i, ]))
  }
}

# All / Selected / 주제별 탭
show_pubs <- function() {
  pubs <- read_pubs()
  has <- function(t) vapply(seq_len(nrow(pubs)), function(i) t %in% pub_topics(pubs[i, ]), logical(1))
  tabs <- c(list(All = rep(TRUE, nrow(pubs)), Selected = pubs$key),
            setNames(lapply(PUB_TOPICS, has), PUB_TOPICS))
  cat("\n::: {.panel-tabset}\n\n")
  for (nm in names(tabs)) {
    sel <- pubs[tabs[[nm]], ]
    cat("\n## ", nm, " (", nrow(sel), ")\n\n", sep = "")
    pub_list(sel)
  }
  cat("\n:::\n")
}

# ---- News ----
show_news <- function(n = Inf) {
  news <- read.csv("data/news.csv", stringsAsFactors = FALSE)
  news <- head(news[order(news$date, decreasing = TRUE), ], n)
  for (i in seq_len(nrow(news))) cat("- **", news$date[i], "** — ", news$text[i], "\n", sep = "")
}

# ---- 공통: Key papers 목록 (Research, Models & Tools) ----
# papers: list(title, authors, journal, year, doi). 제목은 일반 굵기 + DOI 링크, 다음 줄 "Author et al., **Journal**, Year"
paper_list <- function(papers) {
  items <- vapply(papers, function(p) paste0("- [", p$title, "](https://doi.org/", p$doi, ")<br>",
                                             p$authors, ", **", p$journal, "**, ", p$year), "")
  paste0("::: {.paper-list}\n", paste(items, collapse = "\n"), "\n:::\n\n")
}

# Research 페이지: 카드형 목차 → 주제마다 [번호+이름 → 핵심 질문 → 그림(본문 폭) → What we do | Key papers]
# 논문 서지정보는 projects.yml에 직접 적음 (PubMed 제목·DOI를 쓰기 위해 publications.csv와 연결하지 않음)
show_projects <- function() {
  projects <- yaml::read_yaml("data/projects.yml")
  # 카드형 목차 (모바일에서도 3칸)
  cat("::: {.grid .theme-toc}\n\n")
  for (i in seq_along(projects)) {
    cat("::: {.g-col-4}\n[[", i, "]{.num-badge} ", projects[[i]]$title, "](#", projects[[i]]$id,
        "){.box-card}\n:::\n\n", sep = "")
  }
  cat(":::\n\n")
  for (i in seq_along(projects)) {
    pr <- projects[[i]]
    cat("## [", i, "]{.num-badge} ", pr$title, " {#", pr$id, " .page-sec}\n\n", sep = "")
    cat("::: {.theme-question}\n", pr$question, "\n:::\n\n", sep = "")
    cat("![](", pr$figure, "){fig-alt=\"", pr$alt, "\"}\n\n", sep = "")   # 그림은 본문 폭 (2026-10-19)
    cat("::: {.grid}\n\n::: {.g-col-12 .g-col-md-7}\n[What we do]{.label-sm}\n\n", pr$what_we_do, "\n:::\n\n", sep = "")
    cat("::: {.g-col-12 .g-col-md-5}\n[Key papers]{.label-sm}\n\n", paper_list(pr$papers), sep = "")
    if (length(pr$funding)) {
      cat("[Funding]{.label-sm}\n\n")
      for (f in pr$funding) cat("- ", f, "\n", sep = "")
      cat("\n")
    }
    cat(":::\n\n:::\n\n")
  }
}

# ---- Models & Tools 카드 (data/methods.yml의 data_cards / assay_cards) ----
# 카드 = [아이콘 | 제목·태그·설명]. cols: 데스크톱 열 수 (3 = 3열·태블릿 2열·모바일 1열, 2 = 2열·모바일 1열)
show_cards <- function(set, cols = 3) {
  cards <- yaml::read_yaml("data/methods.yml")[[set]]
  cat("::: {.mt-cards .mt-cols-", cols, "}\n\n", sep = "")
  for (cd in cards) {
    tags <- vapply(cd$tags, function(t) paste0("[", t$label, "]{.tag .tag-", t$kind, "}"), "")
    cat("::: {.box-card .mt-card}\n![](assets/methods/icons/", cd$icon, ".webp){.mt-icon fig-alt=\"\"}\n\n",   # 장식용 아이콘: 빈 alt
        "::: {.mt-card-body}\n", "[", cd$title, "]{.mt-card-title}\n\n",
        if (length(tags)) paste0(paste(tags, collapse = " "), "\n\n") else "",
        cd$text, "\n:::\n\n:::\n\n", sep = "")
  }
  cat(":::\n")
}

# ---- Outreach: 강연 영상 (data/lectures.csv) ----
# YouTube 썸네일 카드 격자. 카드를 누르면 YouTube로 이동 (영상 9개를 페이지에 직접 넣으면 무거워서)
youtube_id <- function(url) sub("&.*", "", sub(".*[?&]v=", "", url))

show_lectures <- function() {
  lec <- read.csv("data/lectures.csv", stringsAsFactors = FALSE)
  lec <- lec[order(lec$date, decreasing = TRUE), ]
  cat("::: {.grid .lectures}\n\n")
  for (i in seq_len(nrow(lec))) {
    thumb <- paste0("https://img.youtube.com/vi/", youtube_id(lec$url[i]), "/hqdefault.jpg")
    cat("::: {.g-col-12 .g-col-sm-6 .g-col-lg-4}\n",
        "[![](", thumb, "){fig-alt=\"", lec$title[i], "\"}](", lec$url[i], ")\n\n",
        "**[", lec$title[i], "](", lec$url[i], ")** \\\n",
        "[", lec$host[i], " · ", lec$date[i], "]{.meta}\n:::\n\n", sep = "")
  }
  cat(":::\n")
}

# ---- Collaborators (data/collaborators.yml) ----
# Korea: [한국 지도(데스크톱에서 sticky) | 도시 카드 2열], International: [세계 지도 | 카드].
# 이름·소속은 yml 그대로. 도시 순서·사람 순서도 yml 순서. 도시 배지 숫자 = 그 도시 인원 수 (yml에서 계산)
# 주의: 인원이 바뀌면 assets/team/korea_map.svg의 숫자도 고칠 것 (새 도시는 지도에 원을 새로 그려야 함)
show_collaborators <- function() {
  co <- yaml::read_yaml("data/collaborators.yml")
  inst <- function(p) if (nzchar(p$department)) paste0(p$institution, " · ", p$department) else p$institution
  cat("### Korea\n\n::: {.grid .cb-korea}\n\n::: {.g-col-12 .g-col-md-5}\n::: {.cb-sticky}\n",
      "![](assets/team/korea_map.svg){.cb-map fig-alt=\"Map of South Korea showing collaborating labs in Seoul, Suwon, Daejeon, Daegu, Pohang and Jinju, connected to CALab at KRIBB in Daejeon\"}\n",
      ":::\n:::\n\n::: {.g-col-12 .g-col-md-7}\n::: {.cb-cities}\n\n", sep = "")
  for (ct in co$korea) {
    cat("::: {.box-card .cb-city}\n[[", length(ct$people), "]{.num-badge} ", ct$city, "]{.cb-city-title}\n\n", sep = "")
    for (p in ct$people) cat("- **", p$name, "**<br>[", inst(p), "]{.cb-inst}\n", sep = "")
    cat("\n:::\n\n")
  }
  cat(":::\n:::\n\n:::\n\n")
  cat("### International\n\n::: {.grid .cb-intl}\n\n::: {.g-col-12 .g-col-md-7}\n",
      "![](assets/team/world_map.svg){.cb-map fig-alt=\"Map showing international collaborations in Madrid, Spain, and in China and Japan through the A3 Foresight Program\"}\n",
      ":::\n\n::: {.g-col-12 .g-col-md-5}\n", sep = "")
  for (it in co$international) cat("::: {.box-card .cb-intl-card}\n**", it$name, "**<br>[", it$detail, "]{.cb-inst}\n:::\n\n", sep = "")
  cat(":::\n\n:::\n")
}

# ---- Lab photos (photos/<행사종류>/YYYY-MM_설명.jpg) ----
# 폴더 = 섹션, 파일 이름 = 날짜와 설명. 사진 파일만 넣으면 자동으로 페이지에 추가됨
show_photos <- function() {
  for (d in sort(list.dirs("photos", recursive = FALSE))) {
    files <- sort(list.files(d, pattern = "\\.(jpe?g|png)$", ignore.case = TRUE), decreasing = TRUE)
    if (length(files) == 0) next
    section <- tools::toTitleCase(gsub("-", " ", basename(d)))
    cat("\n## ", section, "\n\n::: {layout-ncol=3}\n\n", sep = "")
    for (f in files) {
      stem <- tools::file_path_sans_ext(f)
      date <- sub("_.*", "", stem)
      desc <- gsub("-", " ", sub("^[^_]*_", "", stem))
      cat("![", date, " · ", desc, "](", file.path(d, f), "){group=\"", basename(d), "\"}\n\n", sep = "")
    }
    cat(":::\n")
  }
}
