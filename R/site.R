# 페이지에서 source("R/site.R")로 불러 쓰는 공통 함수.
# 모든 함수는 마크다운 문자열을 cat()으로 출력하므로 chunk에 `results: asis`가 필요함.

# 한국어/English 탭. group = "lang"이라 한 탭을 고르면 사이트 전체 탭이 같이 바뀌고
# 선택은 브라우저(localStorage)에 기억됨. 탭 안 소제목은 ### 이하를 쓸 것.
lang_tabs <- function(ko, en) {
  cat('\n::: {.panel-tabset group="lang"}\n\n## 한국어\n\n')
  ko()
  cat('\n\n## English\n\n')
  en()
  cat('\n\n:::\n')
}

# 데이터 파일 읽기 (경로는 프로젝트 루트 기준)
read_team <- function() yaml::read_yaml("data/team.yml")
read_pubs <- function() {
  p <- read.csv("data/publications.csv", stringsAsFactors = FALSE)
  # doi 열이 전부 비면 read.csv가 NA(논리형)로 읽고, nzchar(NA)는 TRUE라서 빈 링크가 생김
  for (col in c("volume", "doi", "topics")) p[[col]] <- ifelse(is.na(p[[col]]), "", as.character(p[[col]]))
  p[order(-p$year), ]
}
read_news <- function() {
  n <- read.csv("data/news.csv", stringsAsFactors = FALSE)
  n[order(n$date, decreasing = TRUE), ]
}

# ---- Publications ----
# 주제 탭 순서. publications.csv의 topics 열에 ;로 구분해 적은 이름과 정확히 같아야 함
PUB_TOPICS <- c("Aging", "Cellular Senescence", "Omics", "Inflammation", "Review")
PI_NAME <- "Kim, C."   # 저자 목록에서 굵게 표시할 이름

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
    cat("\n#### ", y, "\n\n", sep = "")
    sub <- pubs[pubs$year == y, ]
    for (i in seq_len(nrow(sub))) cat(pub_entry(sub[i, ]))
  }
}

# 전체 / 대표 논문 / 주제별 탭 (언어 탭 안에 들어가는 두 번째 탭셋)
show_pubs <- function(lang) {
  pubs <- read_pubs()
  has <- function(t) vapply(seq_len(nrow(pubs)), function(i) t %in% pub_topics(pubs[i, ]), logical(1))
  tabs <- c(list(rep(TRUE, nrow(pubs)), pubs$key), lapply(PUB_TOPICS, has))
  names(tabs) <- c(if (lang == "ko") c("전체", "대표 논문") else c("All", "Selected"), PUB_TOPICS)
  cat("\n::: {.panel-tabset}\n\n")
  for (nm in names(tabs)) {
    sel <- pubs[tabs[[nm]], ]
    cat("\n### ", nm, " (", nrow(sel), ")\n\n", sep = "")
    pub_list(sel)
  }
  cat("\n:::\n")
}

# ---- News ----
show_news <- function(lang, n = Inf) {
  news <- head(read_news(), n)
  txt <- if (lang == "ko") news$text_ko else news$text_en
  for (i in seq_len(nrow(news))) cat("- **", news$date[i], "** — ", txt[i], "\n", sep = "")
}

# ---- Team ----
orcid_link <- function(id) {
  if (is.null(id) || !nzchar(id)) return("")
  paste0("[ORCID](https://orcid.org/", id, ")")
}

# team.yml의 period가 "–"로 끝나면 재직 중: 탭 언어에 맞게 "현재"/"present"를 붙임
fmt_period <- function(p, lang) {
  if (endsWith(p, "–")) paste0(p, if (lang == "ko") "현재" else "present") else p
}

show_pi <- function(lang) {
  pi <- read_team()$pi
  g <- function(x) x[[lang]]
  cat("\n::: {.grid}\n\n::: {.g-col-12 .g-col-md-3}\n![](", pi$photo, "){width=160px}\n:::\n\n", sep = "")
  cat("::: {.g-col-12 .g-col-md-9}\n**", g(pi$name), "** \\\n", g(pi$title), "\n\n", g(pi$bio), "\n\n", sep = "")
  links <- c(orcid_link(pi$orcid), paste0("[", pi$email, "](mailto:", pi$email, ")"))
  cat(paste(links[nzchar(links)], collapse = " · "), "\n:::\n\n:::\n", sep = "")
  sections <- list(
    career  = c(ko = "경력", en = "Employment"),
    awards  = c(ko = "수상", en = "Awards"),
    service = c(ko = "학회·위원회 활동", en = "Committees & service")
  )
  for (s in names(sections)) {
    cat("\n#### ", sections[[s]][[lang]], "\n\n", sep = "")
    for (item in pi[[s]]) cat("- ", fmt_period(item$period, lang), " — ", g(item), "\n", sep = "")
  }
}

member_card <- function(m, lang) {
  g <- function(x) x[[lang]]
  links <- orcid_link(m$orcid)
  extra <- if (m$status == "alumni") g(m$now) else g(m$interests)
  paste0(
    "::: {.g-col-12 .g-col-md-4}\n![](", m$photo, "){width=120px}\n\n",
    "**", g(m$name), "** \\\n", g(m$role), " \\\n", extra,
    if (nzchar(links)) paste0(" \\\n", links) else "", "\n:::\n\n"
  )
}

show_members <- function(lang, status) {
  ms <- Filter(function(m) m$status == status, read_team()$members)
  if (status == "alumni") {
    for (m in ms) cat("- ", m$name[[lang]], " (", m$period, ", ", m$role[[lang]], ") — ",
                      m$now[[lang]], "\n", sep = "")
    return(invisible())
  }
  cat("::: {.grid}\n\n")
  for (m in ms) cat(member_card(m, lang))
  cat(":::\n")
}
