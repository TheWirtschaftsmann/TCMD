# Report on tax codes master data

Report on tax codes master data (also referred to as *TCMD report*) is a report that displays tax codes master data. Report supports extraction of the following line item types:

- Tax codes descriptions - report extracts translations for tax code descriptions in all languages or in a particular language;
- Tax codes settings - report extracts tax codes settings i.e. transaction type, GL accounts etc.

Report values are displayed as ALV-report which can be saved as Excel-file. Both report modes support drill-down to tax code level i.e. to transaction `FTXP`.

**Note**: there is a standard SAP report `RF_STEUERINFO` (accessible via t-code `S_ALR_87012365`), but this report displays too much information at once and it is not possible to store the results as Excel-file for further analysis.

## Target audience

This report is intended for SAP consultants, working on implementation of VAT functionalities in SAP, but it can be used by end users' as well as a source of information on:

- The list of available tax codes for a country;
- GL accounts determination for these tax codes.

## Report screenshots

Selection screen of the report:

![selection_screen](https://github.com/TheWirtschaftsmann/TCMD/blob/master/docs/Pictures/selection_screen.jpg)

Examples of each report mode can be found below. 

***Translations mode:***

![translations_mode](https://github.com/TheWirtschaftsmann/TCMD/blob/master/docs/Pictures/translations_mode.jpg)

***Settings mode:***

![settings_mode](https://github.com/TheWirtschaftsmann/TCMD/blob/master/docs/Pictures/settings_mode.jpg)



### Installation

Report can be installed via [abapGit](https://github.com/larshp/abapGit).

## Supplementary documents

- [Technical architecture](docs/solution-architecture.md) - description of overall technical solution.
