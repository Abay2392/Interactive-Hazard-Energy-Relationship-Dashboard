# Interactive-Hazard-Energy-Relationship-Dashboard
R Shiny dashboard and Excel literature database supporting the Hazard–Energy Interrelationship Matrix developed under the SAT-Guard project for climate hazard and energy infrastructure risk assessment.
# Hazard–Energy Interrelationship Matrix: Interactive R Shiny Dashboard and Literature Database

## Overview

This repository contains an interactive R Shiny dashboard and a comprehensive literature database developed to explore and visualize the relationships between natural hazards and energy systems.

The Hazard–Energy Interrelationship Matrix provides a structured framework for understanding how natural hazards directly impact energy infrastructure, indirectly trigger failures, and influence energy demand systems. The dashboard synthesizes published evidence from scientific literature and allows users to interactively explore hazard–energy relationships, impact pathways, documented case studies, and supporting references.

The repository was developed as part of the SAT-Guard Project at Durham University and supports climate risk assessment, infrastructure resilience research, disaster risk reduction, and energy system adaptation planning.

---

## Live Interactive Dashboard

The dashboard is publicly available at:

https://tageleaschale.shinyapps.io/deploy-app-3/

The web application allows users to interactively explore hazard–energy relationships through a dynamic matrix interface and access the supporting scientific evidence behind each interaction.

---

## Repository Contents

### 1. app.R

Main R Shiny application source code.

This file contains the complete dashboard implementation, including:

* Interactive Hazard–Energy Interrelationship Matrix
* User interface design
* Matrix visualization
* Interactive cell selection
* Literature retrieval functions
* Hazard metadata display
* Energy component information
* Impact mechanism descriptions
* Reference formatting and presentation

The dashboard dynamically retrieves information from the literature database and presents it through an interactive graphical interface.

---

### 2. Shiny-hazard_energy_shortref.xlsx

Literature database supporting the dashboard.

This Excel database contains:

* Natural hazard classifications
* Energy system components
* Hazard–energy relationships
* Impact type descriptions
* Impact mechanisms
* Historical case studies
* Modelling studies
* Scientific references
* Evidence classifications

The database serves as the knowledge base that populates the dashboard.

---

## Hazard Categories

The matrix includes 30 natural hazards grouped into major hazard classes.

### Atmospheric Hazards

* Atmospheric River
* Extreme Cold
* Extreme Heat
* Fog
* Hailstorm
* Tropical Cyclone
* Ice and Snow Storm
* Lightning
* Thunderstorm
* Windstorm and Tornado
* Dust and Sandstorm

### Environmental Hazards

* Soil Erosion and Degradation
* Urban Fire
* Wildfire

### Geophysical Hazards

* Coastal and River Erosion
* Earthquake
* Landslide and Subsidence
* Permafrost Thaw
* Snow Avalanche
* Tsunami
* Volcanic Eruption

### Hydrological Hazards

* Drought
* Flood
* Glacial Lake Outburst Flood
* Ice and Debris Jam Flood
* Sea Level Rise
* Storm Surge

### Space Hazards

* Geomagnetic Disturbance
* Impact Event (Meteor/Asteroid)
* Solar Flare and Energetic Particles

---

## Energy System Components

The matrix evaluates interactions with thirteen energy-system components.

| Code | Energy Component                |
| ---- | ------------------------------- |
| HP   | Hydropower Generation System    |
| NP   | Nuclear Generation System       |
| SP   | Solar Power Generation System   |
| TP   | Thermal Power Generation System |
| WP   | Wind Power Generation System    |
| DL   | Distribution Lines and Poles    |
| ES   | Energy Storage                  |
| SS   | Substations                     |
| TI   | Transformers and Insulators     |
| TL   | Transmission Lines              |
| UC   | Underground Cabling             |
| CD   | Cooling Demand                  |
| HD   | Heating Demand                  |

---

## Hazard–Energy Relationship Classification

Each matrix cell is classified according to the type of interaction documented in the scientific literature.

### Direct Impact

Natural hazard directly impacts the energy component.

Examples:

* Windstorm damaging transmission lines.
* Flooding of substations.
* Wildfire damage to distribution infrastructure.

### Triggered Impact

Natural hazard increases the probability of failure or disruption of the energy component.

Examples:

* Drought increasing wildfire risk that subsequently affects power infrastructure.
* Heatwaves increasing cooling demand and grid stress.

### Both Direct and Triggered Impact

Natural hazard directly impacts the energy component and simultaneously increases the likelihood of secondary failures.

### No Published Evidence

No documented case study or modelling evidence currently exists, although interaction may still be possible.

---

## Dashboard Functionality

Users can interactively:

* Select hazard–energy combinations.
* Explore documented interactions.
* View impact mechanisms.
* Access historical case studies.
* Examine modelling evidence.
* Review scientific references.
* Investigate infrastructure vulnerabilities.
* Explore cascading risk pathways.
* Support hazard and energy resilience planning.

---

## Scientific Applications

The dashboard can support:

### Climate Risk Assessment

Understanding climate-related risks to energy systems.

### Infrastructure Resilience

Identifying vulnerable energy infrastructure components.

### Disaster Risk Reduction

Supporting risk-informed planning and preparedness.

### Adaptation Planning

Evaluating energy system adaptation needs under changing climate conditions.

### Research and Education

Providing a literature-based resource for researchers, students, and practitioners.

### Energy Security Assessment

Investigating threats to energy supply and demand systems.

---

## Data Sources

The literature database compiles information from:

* Peer-reviewed journal articles
* Scientific reports
* Technical reports
* Historical disaster records
* Infrastructure failure analyses
* Climate impact studies
* Risk assessment studies
* Modelling investigations

Each hazard–energy interaction is linked to supporting references and documented evidence where available.

---

## Software Requirements

### R Packages

The dashboard requires:

```r
shiny
readxl
dplyr
stringr
```

Install packages using:

```r
install.packages(c(
  "shiny",
  "readxl",
  "dplyr",
  "stringr"
))
```

---

## Running the Dashboard Locally

Place the following files in the same directory:

```text
app.R
Shiny-hazard_energy_shortref.xlsx
```

Then run:

```r
shiny::runApp()
```

The dashboard will launch in your default web browser.

---

## Project Information

### SAT-Guard Project

Satellite-Aided Technologies for Advancing Resilience – Guarding Energy Services Under Climate Hazards, Risks, and Disasters

### Funding

UK Research and Innovation (UKRI)

Project Reference:

MR/Z50578X/1

### Institution

Durham University

---

## Authors

Dr. Tagele Mossie Aschale

Professor Bruce D. Malamud

Professor Daniel N. Donoghue

Department of Geography

Durham University

---

## Citation

If you use this repository, dashboard, or literature database in your research, please cite:

Aschale, T. M., Malamud, B. D., & Donoghue, D. N. (2026). Hazard–Energy Interrelationship Matrix: Interactive R Shiny Dashboard and Literature Database. Durham University, SAT-Guard Project.

Dashboard:

https://tageleaschale.shinyapps.io/deploy-app-3/

---

## License

This repository is provided for research, educational, and non-commercial purposes. Please acknowledge the authors and SAT-Guard Project when using the dashboard, database, or associated outputs.
