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

# ---- Key paper (Models & Tools 페이지용: data/methods.yml) ----
# papers에는 publications.csv 논문 제목의 앞부분을 적음 → 제목·저자·저널을 자동으로 가져옴
key_paper <- function(prefix, pubs) {
  hit <- pubs[startsWith(tolower(pubs$title), tolower(prefix)), ]
  if (nrow(hit) == 0) stop("methods.yml의 논문을 publications.csv에서 찾지 못함: ", prefix)
  p <- hit[1, ]
  first <- sub(",.*", "", p$authors)
  title <- if (nzchar(p$doi)) paste0("[", p$title, "](https://doi.org/", p$doi, ")") else p$title
  paste0("- **", title, "** \\\n  [", first, " et al., *", p$journal, "*, ", p$year, "]{.meta}\n")
}

# Research 페이지: 카드형 목차 → 주제마다 [번호+이름 → 핵심 질문 → 전체 폭 그림 → What we do | Key papers]
# 논문 서지정보는 projects.yml에 직접 적음 (PubMed 제목·DOI를 쓰기 위해 publications.csv와 연결하지 않음)
show_projects <- function() {
  projects <- yaml::read_yaml("data/projects.yml")
  # 카드형 목차 (모바일에서도 3칸)
  cat("::: {.grid .theme-toc}\n\n")
  for (i in seq_along(projects)) {
    cat("::: {.g-col-4}\n[[", i, "]{.theme-num} ", projects[[i]]$title, "](#", projects[[i]]$id,
        "){.theme-card}\n:::\n\n", sep = "")
  }
  cat(":::\n\n")
  for (i in seq_along(projects)) {
    pr <- projects[[i]]
    cat("## [", i, "]{.theme-num} ", pr$title, " {#", pr$id, " .theme}\n\n", sep = "")
    cat("::: {.theme-question}\n", pr$question, "\n:::\n\n", sep = "")
    cat("::: {.column-page}\n![](", pr$figure, "){fig-alt=\"", pr$alt, "\"}\n:::\n\n", sep = "")
    cat("::: {.grid}\n\n::: {.g-col-12 .g-col-md-7}\n[What we do]{.theme-label}\n\n", pr$what_we_do, "\n:::\n\n", sep = "")
    cat("::: {.g-col-12 .g-col-md-5}\n[Key papers]{.theme-label}\n\n::: {.theme-papers}\n", sep = "")
    for (p in pr$papers) {
      cat("- [", p$title, "](https://doi.org/", p$doi, ")<br>", p$authors, ", **", p$journal, "**, ", p$year, "\n", sep = "")
    }
    cat(":::\n\n")
    if (length(pr$funding)) {
      cat("[Funding]{.theme-label}\n\n")
      for (f in pr$funding) cat("- ", f, "\n", sep = "")
      cat("\n")
    }
    cat(":::\n\n:::\n\n")
  }
}

# ---- Models & Tools (data/methods.yml) ----
# 분야마다 왼쪽 예시 이미지, 오른쪽 설명·기법 목록·대표 논문
show_methods <- function() {
  methods <- yaml::read_yaml("data/methods.yml")
  pubs <- read_pubs()
  cat(paste0("[", vapply(methods, `[[`, "", "title"), "](#", vapply(methods, `[[`, "", "id"), ")",
             collapse = " · "), "\n\n")
  for (m in methods) {
    cat("::: {.grid .project .method}\n\n")
    cat("::: {.g-col-12 .g-col-md-5}\n![", m$caption, "](", m$image, ")\n:::\n\n", sep = "")
    cat("::: {.g-col-12 .g-col-md-7}\n## ", m$title, " {#", m$id, "}\n\n", m$description, "\n\n", sep = "")
    cat("::: {.techniques}\n")
    for (it in m$items) {
      if (is.character(it)) { cat("- ", it, "\n", sep = ""); next }
      cat("- ", it$name, "\n", sep = "")
      for (d in it$details) cat("    - ", d, "\n", sep = "")
    }
    cat(":::\n\n")
    if (length(m$papers)) {
      cat("**Key papers**\n\n::: {.key-papers}\n")
      for (k in m$papers) cat(key_paper(k, pubs))
      cat(":::\n\n")
    }
    cat(":::\n\n:::\n\n")
  }
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

# ---- Collaborators (data/collaborators.csv) ----
show_collaborators <- function() {
  co <- read.csv("data/collaborators.csv", stringsAsFactors = FALSE)
  co <- blank_na(co, c("url", "topic"))
  cat("::: {.grid}\n\n")
  for (r in unique(co$region)) {
    cat("::: {.g-col-12 .g-col-md-6}\n### ", r, "\n\n", sep = "")
    sub <- co[co$region == r, ]
    for (i in seq_len(nrow(sub))) {
      name <- if (nzchar(sub$url[i])) paste0("[", sub$name[i], "](", sub$url[i], ")") else sub$name[i]
      topic <- if (nzchar(sub$topic[i])) paste0(" — ", sub$topic[i]) else ""
      cat("- **", name, "**, ", sub$affiliation[i], topic, "\n", sep = "")
    }
    cat("\n:::\n\n")
  }
  cat(":::\n")
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
