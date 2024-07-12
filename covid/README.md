## Covid in ASEAN Countries + Top 3 Largest Populations

[Data Viz (in Tableau)](https://public.tableau.com/app/profile/ning.chang7904/viz/CovidASEAN_17195593903840/Dashboard1#1)

[SQL (done in BigQuery)](https://github.com/ningstas/PortfolioProjects/blob/main/covid_202001_to_202406.sql)

Scope of this project:
- I decided to focus on ASEAN countries (Association of SouthEast Asian Nations) because I'm from Singapore and I thought it'll be interesting to look at our neighbours. :)

Some questions or ideas I wanted to explore:
- How did ASEAN countries fare? (Comparison done against the top 3 largest global populations)
- Did vaccines reduce the spread of the disease?
- Did vaccines reduce severity?
- Did population density affect the spread of the disease?

Steps taken:
- Retrieved data on cases, deaths and hospitalization from ourworldindata.org, and data on population (2022) and density (2021) from worldbank.org
- Imported them into Google Sheets to explore and clean and export as CSV
- Imported CSV into BigQuery and filtered according to scope of project and did further exploration (e.g. checking if the country names match across data sources)
- Joined tables to calculate percentages, numbers per million (for comparison across countries of different population sizes)
- Imported the results into Tableau for visualisation
