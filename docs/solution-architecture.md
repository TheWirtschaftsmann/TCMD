# Architecture of solution

Overall architecture can be split into two logical components: extraction of source data and display of data as ALV-report. Each component will be implemented as separate class with naming convention that includes prefix "ZCL_TCMD_".

## 1. Main program

Report can be called via transaction code **ZTCMD** - *Report on tax codes master data*. Transaction code is linked to program `ZTCMD_ANALYSIS`, which implements MVC-approach: initiates extraction of data and controls its output to ALV-report. 

Main processing logic within the program is centralized within instance of local class `LCL_APP_TCMD`, which accepts parameters from selection screen and passes them to extraction routines.

## 2. Selection screen

Selection screen consists of the following selection blocks:

**General selection options**:

- `P_LAND` - *Country*  - mandatory parameter;
- `P_KTOPL` - *Chart of accounts* - mandatory parameter;
- `S_MWSKZ` - *Tax code* - optional parameter with multiple selections option.

**Display options**:

- `P_SET` - *Display settings* 
- `P_TRN` - *Display translations*
- `S_LANG` - *Language*, optional parameter with multiple selections option that becomes visible once option "Display translations" was selected.

Display options should be implemented as radio buttons.

## 3. Extraction of data

Extraction of data will be managed via class `ZCL_TCMD_EXTRACTOR`. Selection of data directly depends on the chosen display options, but several routines will be shared. These routines will be displayed separately below.

### 3.1 Common routines

`select_tax_procedure()` - static method that selects tax calculation procedure.  Tax calculation procedure is the procedure that specifies how tax amounts will be calculated and how they will be posted. Use the following logic to select tax calculation procedure:

```abap
select single kalsm
  from t005
  where land1 = p_land
```

`select_tax_codes()` - method that retrieves the list of tax codes and their basic attributes. Baseline table for selection is `T007A`. Use the following logic to select data:

```abap
select *
  from t007a
  where kalsm = lv_kalsm (tax calculation procedure)
  and mwskz in s_mwskz
```

The following fields should be selected from table `T007A`:

- MWSKZ - tax code;
- MWART - tax code type;
- ZMWSK - target tax code;
- XINACT - inactive tax code.

`select_tax_code_translations()` -  static method that retrieves translations of tax codes in all languages or in specific languages indicated on selection screen. Use the following logic to select data:

```abap
select *
  from t007s
  where kalsm = lv_kalsm
  and spras in s_lang
  and mwskz in r_mwskz (range of selected tax codes)
```

### 3.2 Retrieval of translations 

Public method `get_translations()` will be implemented to return to calling program internal table with translations. The method should:

- Initialize tax calculation procedure i.e. `select_tax_procedure()`;
- Select tax codes via `select_tax_codes()` and their translations `select_tax_code_translations()`;
- Apply necessary adjustments i.e. add technical key (see par. 4.1 "*Display of tax codes translations*") and return the data to calling program.

### 3.3 Retrieval of settings

To finalize. 

Some notes:

- Check T030K - table with GL accounts determination for tax codes;
- FM FI_TAX_GET_TAX_ACC_ASSIGNMENT might be used to retrieve tax codes account assignments;

## 4. Display of report values

Separate class `ZCL_TCMD_ALV` should implemented to handle display of report in ALV-format. ALV-report will be generated following OOP-approach inheriting functionality from standard class `cl_gui_alv_grid`.

### 4.1 Display of tax codes translations

Translations of tax codes should be displayed as a standard ALV-report with the following structure:

| Key  | Country | Procedure | Tax Code | Language | Description            |
| :--- | ------- | --------- | -------- | -------- | ---------------------- |
| P1EN | UA      | TAXUAC    | P1       | EN       | Purchase with VAT, 20% |
| P1UK | UA      | TAXUAC    | P1       | UK       | Купівля з ПДВ, 20%     |
| P1RU | UA      | TAXUAC    | P1       | RU       | Закупки с НДС, 20%     |

First column `KEY` represents unique key that is build as concatenation of tax code and language key. Technical key can be used by users to for `VLOOKUP()` functions in `MS Excel`.

### 4.2 Display of tax codes settings

Tax codes settings should be displayed as a standard ALV-report with the following structure:

| Key   | Condition | Account Key | Tax Code | Tax Rate, % | GL account | Description     |
| :---- | --------- | ----------- | -------- | ----------- | ---------- | --------------- |
| D1MWS | MWAS      | MWS         | P1       | 20          | 176410     | Acqui. tax, 20% |
| D1VST | MWVS      | VST         | P1       | 20          | 178410     | Acqui. tax, 20% |
| S1MWS | MWAS      | MWS         | S1       | 20          | 176410     | Sales, 20%      |

Descriptions for tax codes settings should be displayed in English (?).

## 6. Exceptions handling

Separate class ZCX_TCDM_ERROR will be implemented to handle exceptions.