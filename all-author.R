# app.R  (FULL VERSION — right-side legends + cleaned Impact bullets + reference formatting)
# IMPORTANT FOR DEPLOYMENT:
# - Save this file as EXACTLY: app.R
# - Keep this app.R and the Excel file in the SAME FOLDER.
# - Deploy that folder as a Shiny app.

library(shiny)
library(readxl)
library(dplyr)
library(stringr)

b <- tags$b

# ===== PATH =====
DATA_FILE <- "Shiny-hazard_energy_shortref.xlsx"

# ===== READ NOTES ONLY (MATCHES YOUR FILE'S HEADERS) =====
notes <- read_excel(DATA_FILE, sheet = "notes") %>%
  mutate(
    grid_id          = str_trim(as.character(`Grid-Id`)),
    hazard           = str_trim(as.character(`Hazard`)),
    energy_component = str_trim(as.character(`Energy component`)),
    impact_note      = str_trim(as.character(`Details of the impact types`)),
    case_study       = str_trim(as.character(`Description of the impact mechanism & event`)),
    citation         = str_trim(as.character(`References`)),
    relation_code    = str_trim(tolower(as.character(`Hazard energy relationship`))),
    case_mode        = str_trim(as.character(`Case study/model based`))
    # NOTE: ignore `link`
  ) %>%
  filter(!is.na(grid_id), grid_id != "")

# Parse row/col from grid_id (e.g., 12C) ---- KEEP EXCEL grid_id AS "12C" FORMAT
notes <- notes %>%
  mutate(
    row_num    = suppressWarnings(as.integer(str_extract(grid_id, "^[0-9]+"))),
    col_letter = str_extract(grid_id, "[A-Za-z]+$") %>% toupper()
  )

# ===== MATRIX LABELS (DISPLAY) =====
# Row headers MUST be replaced by the following full hazard names (in sequence 1..30)
row_labels <- c(
  "Atmospheric River",
  "Extreme Cold",
  "Extreme Heat",
  "Fog",
  "Hailstorm",
  "Tropical Cyclone",
  "Ice & Snow Storm",
  "Lightning",
  "Thunderstorm",
  "Windstorm / Tornado",
  "Dust / Sandstorm",
  "Soil Erosion & Degradation",
  "Urban Fire",
  "Wildfire",
  "Coastal & River Erosion",
  "Earthquake",
  "Landslide & Subsidence",
  "Permafrost Thaw",
  "Snow Avalanche",
  "Tsunami",
  "Volcanic Eruption",
  "Drought",
  "Flood",
  "Glacial Lake Outburst Flood",
  "Ice / Debris Jam Flood",
  "Sea Level Rise",
  "Storm Surge",
  "Geomagnetic Disturbance",
  "Impact Event (Meteor/Asteroid)",
  "Solar Flare & Energetic Particles"
)

# Column headers stay as A-HP ... M-HD
col_labels <- c(
  "A-HP","B-NP","C-SP","D-TP","E-WP","F-DL","G-ES","H-SS","I-TI","J-TL","K-UC","L-CD","M-HD"
)

all_rows_num    <- 1:30
all_cols_letter <- LETTERS[1:13]  # A..M

row_num_to_label    <- setNames(row_labels, all_rows_num)
col_letter_to_label <- setNames(col_labels, all_cols_letter)

# Filter invalid grid IDs
notes <- notes %>%
  filter(!is.na(row_num), !is.na(col_letter), row_num %in% all_rows_num, col_letter %in% all_cols_letter)

# Normalize relation_code + clean text fields
notes <- notes %>%
  mutate(
    relation_code = case_when(
      relation_code %in% c("direct", "d") ~ "direct",
      relation_code %in% c("triggered", "increased", "i", "indirect") ~ "triggered",
      relation_code %in% c("both", "d+i", "di", "direct+triggered") ~ "both",
      relation_code %in% c("hypothetical", "hypo", "h") ~ "hypothetical",
      relation_code %in% c("no_impact", "no impact", "none", "n", "") ~ "no_impact",
      TRUE ~ "no_impact"
    ),
    hazard = ifelse(is.na(hazard) | hazard == "", "Unknown", hazard),
    energy_component = ifelse(is.na(energy_component) | energy_component == "", "Unknown", energy_component),
    impact_note = ifelse(is.na(impact_note) | impact_note == "" | impact_note == "NA", "", impact_note),
    case_study = ifelse(is.na(case_study) | case_study == "" | case_study == "NA", "", case_study),
    citation = ifelse(is.na(citation) | citation == "" | citation == "NA", "", citation),
    case_mode = ifelse(is.na(case_mode) | case_mode == "" | case_mode == "NA", "", case_mode)
  )

# ===== Formatting helpers =====

# Clean Impact type details:
# - remove stray bullets
# - bold ONLY these headings:
#   • Direct impact:
#   • Increased probability / triggered impact:
format_impact_details <- function(txt) {
  if (is.na(txt) || trimws(txt) == "") return(HTML("Not provided in notes sheet."))
  
  txt <- trimws(txt)
  txt <- gsub("\r\n", "\n", txt, fixed = TRUE)
  txt <- gsub("\r", "\n", txt, fixed = TRUE)
  
  # Remove standalone bullet lines: "•"
  txt <- gsub("(^|\\n)\\s*•\\s*(?=\\n|$)", "\\1", txt, perl = TRUE)
  
  # Remove bullet-only artifacts like "•  •"
  txt <- gsub("•\\s*•+", "•", txt)
  
  # Bold headings (accept bullet or no bullet)
  txt <- gsub("(?i)\\s*•?\\s*Direct\\s*impact\\s*:", "\n\n<b>• Direct impact:</b>\n", txt, perl = TRUE)
  txt <- gsub("(?i)\\s*•?\\s*Increased\\s*probability\\s*/\\s*triggered\\s*impact\\s*:",
              "\n\n<b>• Increased probability / triggered impact:</b>\n", txt, perl = TRUE)
  
  # Collapse too many blank lines
  txt <- gsub("\n{3,}", "\n\n", txt, perl = TRUE)
  
  txt <- trimws(txt)
  HTML(gsub("\n", "<br/>", txt))
}

# References:
# Handles:
#  - "[\n1] ..." (weird stray "[" lines)
#  - "[1] ..."
#  - "1] ..."
# Ensures each reference appears as its own paragraph (blank line between)
format_references <- function(ref) {
  if (is.na(ref) || trimws(ref) == "") return(HTML("Not provided in notes sheet."))
  
  ref <- trimws(ref)
  ref <- gsub("\r\n", "\n", ref, fixed = TRUE)
  ref <- gsub("\r", "\n", ref, fixed = TRUE)
  
  # Remove stray "[" that appears alone or before numbers: "[\n1]" -> "1]"
  ref <- gsub("\\[\\s*\\n\\s*", "", ref, perl = TRUE)
  
  # Convert [1] -> 1.
  ref <- gsub("\\[\\s*([0-9]+)\\s*\\]\\s*", "\\1. ", ref, perl = TRUE)
  
  # Convert "1]" at line starts -> 1.
  ref <- gsub("(^|\\n)\\s*([0-9]+)\\s*\\]\\s*", "\\1\\2. ", ref, perl = TRUE)
  
  # Force newline before "N." if it's not already at start of line
  ref <- gsub("(?<!^)(?<!\\n)\\s+([0-9]+\\.)\\s+", "\n\\1 ", ref, perl = TRUE)
  
  # Split into items at lines starting with N.
  parts <- unlist(strsplit(ref, "\n(?=\\s*[0-9]+\\.)", perl = TRUE))
  parts <- trimws(parts)
  parts <- parts[parts != ""]
  
  if (length(parts) == 0) return(HTML("Not provided in notes sheet."))
  if (length(parts) == 1 && !grepl("^\\s*[0-9]+\\.", parts[1])) parts[1] <- paste0("1. ", parts[1])
  
  HTML(paste(parts, collapse = "<br/><br/>"))
}

# ===== HEADER COLOR HELPERS (ONLY headers get color) =====
row_head_color <- function(rn) {
  if (rn >= 1  && rn <= 10) return("#FF6347")
  if (rn >= 11 && rn <= 14) return("#4E9258")
  if (rn >= 15 && rn <= 21) return("#FCBBBB")
  if (rn >= 22 && rn <= 27) return("#87CEEB")
  if (rn >= 28 && rn <= 30) return("#FCF4BB")
  "#f2f2f2"
}

col_head_color <- function(letter) {
  idx <- match(letter, all_cols_letter)
  if (!is.na(idx) && idx >= 1  && idx <= 5)  return("#DFF0E1")
  if (!is.na(idx) && idx >= 6  && idx <= 11) return("#E6B2A2")
  if (!is.na(idx) && idx >= 12 && idx <= 13) return("#FADEA7")
  "#f2f2f2"
}

# ===== Build full matrix =====
cells_full <- expand.grid(row_num = all_rows_num, col_letter = all_cols_letter, stringsAsFactors = FALSE) %>%
  mutate(grid_id = paste0(row_num, col_letter)) %>%
  left_join(notes %>% select(grid_id, relation_code), by = "grid_id") %>%
  mutate(category = ifelse(is.na(relation_code), "no_impact", relation_code))

get_cat <- function(gid) {
  x <- cells_full$category[cells_full$grid_id == gid]
  if (length(x) == 0 || is.na(x[1])) return("no_impact")
  x[1]
}

relation_label <- function(x) {
  x <- tolower(trimws(as.character(x)))
  dplyr::case_when(
    x == "direct" ~ "Natural hazard directly impacts the energy component.",
    x == "triggered" ~ "Natural hazard increased the probability of the energy component failing or being influenced",
    x == "both" ~ "Natural hazard directly impacts the energy component and increased the probability of the energy component failing or being influenced",
    x %in% c("no_impact", "hypothetical", "", NA) ~ "No published case or modelling study, but interaction might occur",
    TRUE ~ "No published case or modelling study, but interaction might occur"
  )
}

# ===== ENERGY LEGEND (MOVE TO BOTTOM OF METADATA) =====
energy_legend <- list(
  "HP" = "Hydropower Generation System",
  "NP" = "Nuclear Generation System",
  "SP" = "Solar Power Generation System",
  "TP" = "Thermal Power Generation System",
  "WP" = "Wind Power Generation System",
  "DL" = "Distribution Lines & Poles",
  "ES" = "Energy Storage",
  "SS" = "Substations",
  "TI" = "Transformers & Insulators",
  "TL" = "Transmission Lines",
  "UC" = "Underground Cabling",
  "CD" = "Cooling Demand",
  "HD" = "Heating Demand"
)

# ===== UI =====
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { font-family: Arial, sans-serif; }

      .grid-wrap { overflow-x: auto; padding: 8px; border: 1px solid #ddd; border-radius: 10px; }
      .grid { display: grid; grid-template-columns: 220px repeat(13, 60px); gap: 2px; align-items: center; }

      .colhead, .rowhead {
        font-weight: 700; font-size: 12px; text-align: center;
        padding: 8px 6px; border-radius: 6px; background: #f2f2f2; color: #222;
        white-space: nowrap;
      }

      .cell {
        width: 60px; height: 44px; border-radius: 6px;
        cursor: pointer; border: 1px solid #444; user-select: none;
        background-color: #ffffff;
      }

      .no_impact { background-color: #ffffff; }
      .hypothetical { background-color: #ffffff; }

      .direct {
        background: linear-gradient(135deg, #000000 0%, #000000 50%, #ffffff 50%, #ffffff 100%);
      }

      .triggered {
        background: linear-gradient(135deg, #ffffff 0%, #ffffff 50%, #000000 50%, #000000 100%);
      }

      .both {
        background-color: #1a1a1a;
        background-image: linear-gradient(135deg,
          rgba(255,255,255,0) 0%,
          rgba(255,255,255,0) 48%,
          #ffffff 48%,
          #ffffff 52%,
          rgba(255,255,255,0) 52%,
          rgba(255,255,255,0) 100%
        );
      }

      .cell:hover { outline: 2px solid #00000055; }
      .selected { outline: 3px solid #000000; outline-offset: -3px; }

      .legend { display:flex; gap:10px; flex-wrap:wrap; margin-top:10px; }
      .legitem { display:flex; align-items:center; gap:6px; font-size: 12px; }
      .swatch { width: 18px; height: 18px; border-radius: 4px; border: 1px solid #444; }

      .meta-box { padding: 10px; border: 1px solid #ddd; border-radius: 10px; background: #fafafa; }
      .meta-title { font-weight: 700; margin-bottom: 8px; }
      .meta-field { margin: 6px 0; }
      .meta-field b { display:inline-block; min-width: 170px; }
      .note-card { background:#fff; border:1px solid #e6e6e6; border-radius: 10px; padding: 10px; margin: 10px 0; }
      .small { color:#666; font-size: 12px; }

      /* Footer / project credit */
      .proj-footer {
        margin-top: 12px;
        padding-top: 10px;
        border-top: 1px solid #e0e0e0;
        color: #444;
        font-size: 12px;
        line-height: 1.35;
      }

      /* Mini legend table inside metadata (bottom) */
      .mini-legend {
        margin-top: 12px;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 10px;
        background: #ffffff;
      }
      .mini-legend h4 { margin: 0 0 8px 0; font-size: 13px; }
      .kv { display:flex; gap:8px; margin: 4px 0; }
      .kv .k { min-width: 42px; font-weight: 700; }
      .kv .v { color:#222; }
    "))
  ),
  
  titlePanel("Hazard–Energy Interrelationship Matrix (Interactive)"),
  
  fluidRow(
    column(
      width = 7,
      div(class = "grid-wrap", uiOutput("matrixUI")),
      div(class = "legend",
          div(class="legitem", div(class="swatch direct"),
              span("Natural hazard directly impacts the energy component.")),
          div(class="legitem", div(class="swatch triggered"),
              span("Natural hazard increased the probability of the energy component failing or being influenced")),
          div(class="legitem", div(class="swatch both"),
              span("Natural hazard directly impacts the energy component and increased the probability of the energy component failing or being influenced")),
          div(class="legitem", div(class="swatch no_impact"),
              span("No published case or modelling study, but interaction might occur"))
      )
    ),
    
    column(
      width = 5,
      div(class="meta-box", uiOutput("detailsUI"))
    )
  )
)

# ===== SERVER =====
server <- function(input, output, session) {
  
  selected <- reactiveVal(NULL)
  
  observeEvent(input$cell_click, {
    selected(input$cell_click)
  })
  
  output$matrixUI <- renderUI({
    gid_selected <- selected()
    
    header_row <- c(
      list(div(class="colhead", "")),
      lapply(all_cols_letter, function(cl) {
        div(
          class = "colhead",
          style = paste0("background:", col_head_color(cl), ";"),
          col_letter_to_label[[cl]]
        )
      })
    )
    
    grid_rows <- lapply(all_rows_num, function(rn) {
      
      rowhead <- div(
        class = "rowhead",
        style = paste0("background:", row_head_color(rn), ";"),
        row_num_to_label[[as.character(rn)]]
      )
      
      row_cells <- lapply(all_cols_letter, function(cl) {
        gid <- paste0(rn, cl)
        cat <- get_cat(gid)
        extra <- if (!is.null(gid_selected) && gid == gid_selected) " selected" else ""
        
        div(
          class = paste0("cell ", cat, extra),
          onclick = sprintf("Shiny.setInputValue('cell_click', '%s', {priority: 'event'})", gid),
          title = paste0("Cell: ", row_num_to_label[[as.character(rn)]], " × ", col_letter_to_label[[cl]], "  (", gid, ")")
        )
      })
      
      c(list(rowhead), row_cells)
    })
    
    div(class="grid",
        header_row,
        do.call(tagList, lapply(grid_rows, function(x) do.call(tagList, x)))
    )
  })
  
  output$detailsUI <- renderUI({
    gid <- selected()
    
    # Project credit block (always shown at the bottom)
    project_credit <- div(
      class = "proj-footer",
      div(b("SAT-Guard Project")),
      div("Aschale T.M. · Malamud B.D. · Donoghue D.N."),
      div("Durham University, Funded by UK Research & Innovation (UKRI)"),
      div("Satellite-Aided Technologies for advancing resilience - Guarding energy services under climate hazards, risks, and disasters (SAT-Guard). Project Ref: MR/Z50578X/1.  Cite as: Aschale, T. M., Malamud, B. D., & Donoghue, D. N. (2026). Hazard–Energy Interrelationship Matrix (Interactive) [Shiny web application]. Shinyapps.io. https://tageleaschale.shinyapps.io/deploy-app-3/")
    )
    
    # Energy legend (always shown at bottom of metadata panel)
    energy_legend_box <- div(
      class = "mini-legend",
      tags$h4("Energy component legend (HP … HD)"),
      lapply(names(energy_legend), function(k) {
        div(class="kv", div(class="k", k), div(class="v", energy_legend[[k]]))
      })
    )
    
    if (is.null(gid) || gid == "") {
      return(tagList(
        div(class="meta-title", "Cell metadata"),
        div(class="small", "Click any matrix cell to view its literature information."),
        energy_legend_box,
        project_credit
      ))
    }
    
    sub <- notes %>% filter(grid_id == gid)
    
    if (nrow(sub) == 0) {
      return(tagList(
        div(class="meta-title", paste0("Cell: ", gid)),
        div(class="meta-field", b("Status:"), "No record found in notes sheet for this cell."),
        energy_legend_box,
        project_credit
      ))
    }
    
    rn <- suppressWarnings(as.integer(str_extract(gid, "^[0-9]+")))
    cl <- str_extract(gid, "[A-Za-z]+$") %>% toupper()
    pretty_cell <- paste0(row_num_to_label[[as.character(rn)]], " × ", col_letter_to_label[[cl]], "  (", gid, ")")
    
    tagList(
      div(class="meta-title", paste0("Cell: ", pretty_cell)),
      div(class="small", paste0("Records found: ", nrow(sub))),
      
      lapply(seq_len(nrow(sub)), function(i) {
        
        missing <- c()
        if (sub$impact_note[i] == "") missing <- c(missing, "Details of the impact types")
        if (sub$case_study[i] == "") missing <- c(missing, "Description of the impact mechanism & event")
        if (sub$citation[i] == "") missing <- c(missing, "References")
        if (sub$case_mode[i] == "") missing <- c(missing, "Case study/model based")
        
        div(class="note-card",
            div(class="meta-field", b("Category:"), relation_label(sub$relation_code[i])),
            div(class="meta-field", b("Hazard:"), sub$hazard[i]),
            div(class="meta-field", b("Energy component:"), sub$energy_component[i]),
            div(class="meta-field", b("Impact type details:"),
                div(style="margin-top:4px;", format_impact_details(sub$impact_note[i]))
            ),
            div(class="meta-field", b("Mechanism & event:"),
                ifelse(sub$case_study[i] == "", "No available information recorded.", sub$case_study[i])
            ),
            div(class="meta-field", b("Case mode:"),
                ifelse(sub$case_mode[i] == "", "No available information recorded.", sub$case_mode[i])
            ),
            div(class="meta-field", b("References:"),
                div(style="margin-top:4px;", format_references(sub$citation[i]))
            ),
            if (length(missing) > 0)
              div(class="small", paste0("Missing in Excel: ", paste(missing, collapse = ", "), "."))
        )
      }),
      
      # legend at bottom of metadata + project credits
      energy_legend_box,
      project_credit
    )
  })
}

shinyApp(ui, server)
