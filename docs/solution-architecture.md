# Architecture of solution

Overall architecture can be split into two logical components: extraction of source data and display of data as ALV-report.

## 1. Main program

Report can be called via transaction code **ZFI_TCMD** - *Report on tax codes master data*. Transaction code is linked to program `ZFI_TCMD_ANALYSIS`, which implements MVC-approach: initiates extraction of data and controls its output to ALV-report. 

Main processing logic within the program is centralized within instance of local class `LCL_CONTROLLER`, which accepts parameters from selection screen, passes them to extraction routines and routes resulting data for display.

## 2. Selection screen

Selection screen consists of the following selection blocks:

**General selection options**:

- `P_LAND` - *Country*  - mandatory parameter;
- `P_KTOPL` - *Chart of accounts* - mandatory parameter if the report mode is "Display settings";
- `S_MWSKZ` - *Tax code* - optional parameter with multiple selections option.

**Display options**:

This selection block controls output of data. It contains selection of report mode and input of selection values, which depend it. There are two modes:

- `P_SET` - *Display settings* 
- `P_TRN` - *Display translations*

Select of display mode should be implemented as radio buttons.

Display options also contains additional input fields:

- `P_LANG` - *Language*, parameter that controls which language will be used to display tax codes' names in the report of tax codes' settings.
- `S_LANG` - *Language*, optional parameter with multiple selections option that becomes visible once option "Display translations" was selected. 

## 3. Extraction of data

Extraction of data will be managed via class `LCL_TC_MASTER_DATA`. Selection of data directly depends on the chosen display options, but several routines will be shared. These routines will be displayed separately below.

### 3.1 Common routines

`set_tax_calc_procedure()` - static method that selects tax calculation procedure and saves it as attribute of class.  Tax calculation procedure is the procedure that specifies how tax amounts will be calculated and how they will be posted. This method will be executed in constructor.

Use the following logic to select tax calculation procedure: 

```abap
select single kalsm
  from t005
  where land1 = p_land
```

### 3.2 Retrieval of translations 

Public method `get_names()` will be implemented to return to calling program internal table with translations. The method should select all tax codes in tax calculation procedure for a country and their translations.

Use the following logic to select data:

```abap
select *
  from t007s
  where kalsm = lv_kalsm
  and spras in s_lang
  and mwskz in r_mwskz (range of selected tax codes)
```

### 3.3 Retrieval of settings

Public method `get_translations()` will be implemented to return to a calling program internal table with tax codes' settings. The method execution follows this execution logic:

- Retrieves all conditions and account determination keys that are used in tax calculation procedure and stores them as a range of values via method `get_tax_conditions()`;
- Retrieves all GL accounts determination from T030K for a combination of chart of accounts, account keys and tax codes via method `get_gl_accounts()`;
- Retrieves basic tax codes' attributes from table T007A via method `get_tax_keys()`;
- Retrieves condition number records for each unique combination of condition and tax code via method `get_tax_rates()`. Condition number records is a key, which will be used to extract tax code rate.

The following fields should be selected from table `T007A`:

- MWSKZ - tax code;
- MWART - tax code type;
- ZMWSK - target tax code;
- XINACT - inactive tax code;
- PRUEF - check ID;
- EGRKZ - EU tax code;
- MOSSC - MOSS tax reporting.

## 4. Display of report values

Separate class `LCL_VIEW` should implemented to handle display of report in ALV-format. ALV-report will be generated following OOP-approach inheriting functionality from standard class `cl_gui_alv_grid`.

### 4.1 Display of tax codes translations

Translations of tax codes should be displayed as a standard ALV-report with the following structure:

| Country | Procedure | Tax code | Language | Description            |
| :------ | --------- | -------- | -------- | ---------------------- |
| UA      | TAXUAC    | P1       | EN       | Purchase with VAT, 20% |
| UA      | TAXUAC    | P1       | UK       | Купівля з ПДВ, 20%     |
| UA      | TAXUAC    | P1       | RU       | Закупки с НДС, 20%     |

### 4.2 Display of tax codes settings

Tax codes settings should be displayed as a standard ALV-report with the following structure:

| Tax Code | Description     | Typ  | Target tax code | Condition | Account Key | Tax Rate, % | GL account |
| :------- | --------------- | ---- | --------------- | --------- | ----------- | ----------- | ---------- |
| P1       | Acqui. tax, 20% | V    |                 | MWAS      | MWS         | 20          | 176410     |
| P1       | Acqui. tax, 20% | V    |                 | MWVS      | VST         | 20          | 178410     |
| S1       | Sales, 20%      | A    | S2              | MWAS      | MWS         | 20          | 176410     |

## 5. Exceptions handling

Separate local class `LCX_EXCEPTION` will be implemented to handle exceptions.