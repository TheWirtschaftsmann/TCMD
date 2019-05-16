# Report on tax codes master data

Report on tax codes master data (also referred to as *TCMD report*) is a report that displays tax codes master data. Report supports extraction of the following line item types:

- Tax codes descriptions - report extracts translations for tax code descriptions in all languages or in a particular language;
- Tax codes settings - report extracts tax codes settings i.e. transaction type, GL accounts etc.

Report values are displayed as ALV-report which can be saved as Excel-file.

**Note**: there is a standard SAP report `RF_STEUERINFO` (accessible via t-code `S_ALR_87012365`), but this report displays too much information at once and it is not possible to store the results as Excel-file for further analysis.

## Supplementary documents

- [Technical architecture](docs/solution-architecture.md) - description of overall technical solution.