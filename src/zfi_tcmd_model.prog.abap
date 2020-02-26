*&---------------------------------------------------------------------*
*&  Include: Data management routines
*&---------------------------------------------------------------------*
class lcl_tc_master_data definition.
  public section.
    methods: constructor  importing is_selopts            type ty_selopts.
    methods: get_names    returning value(rt_tc_names)    type ty_tt_tc_names.
    methods: get_settings returning value(rt_tc_settings) type ty_tt_tc_settings .

  private section.
    types: ty_tt_conditions type standard table of t683s with default key.
    types: ty_r_kschl type range of kschl.
    types: ty_r_kvsl1 type range of kvsl1.

    constants:
      c_pricing type t683s-kvewe value 'A',
      c_taxes   type t683s-kappl value 'TX',
      c_english type spras       value 'E'.

    data: as_selopts      type ty_selopts.
    data: av_kalsm        type kalsm.
    data: at_tc_keys      type ty_tt_tc_keys.
    data: at_settings     type ty_tt_tc_settings.
    data: at_conditions   type ty_tt_conditions.
    data: at_cond_records type table of a003.
    data: ar_conditions   type ty_r_kschl.
    data: ar_acc_keys     type ty_r_kvsl1.
    data: at_gl_accounts  type table of t030k.

    methods: set_tax_calc_procedure.
    methods: get_tax_keys.
    methods: get_tax_conditions.
    methods: get_tax_rates.
    methods: get_tc_rate importing iv_knumh type knumh
                         returning value(rv_rate) type zfi_tcmd_rate.
    methods: get_tc_name importing iv_mwskz type mwskz returning value(rv_name) type text1.
    methods: get_acc_key importing iv_kschl type kschl returning value(rv_key) type kvsl1.
    methods: get_gl_accounts.
    methods: get_gl_account importing iv_mwskz type mwskz iv_key type ktosl returning value(rv_konts) type saknr.
endclass.

class lcl_tc_master_data implementation.
  method constructor.
    as_selopts = is_selopts.
    me->set_tax_calc_procedure( ).
  endmethod.

  method set_tax_calc_procedure.
    select single kalsm
      from t005
      into av_kalsm
      where land1 = as_selopts-land1.
  endmethod.

  method get_names.
    select *
      from t007s
      into corresponding fields of table rt_tc_names
      where spras in as_selopts-spras
      and   kalsm = av_kalsm
      and   mwskz in as_selopts-mwskz.
  endmethod.

  method get_settings.

    data: ls_settings like line of at_settings.

    field-symbols:
       <tc>   like line of at_tc_keys,
       <cond> like line of at_cond_records.

    me->get_tax_conditions( ).
    me->get_gl_accounts( ).
    me->get_tax_keys( ).
    me->get_tax_rates( ).

    loop at at_tc_keys assigning <tc>.
      clear: ls_settings.
      ls_settings-mwart  = <tc>-mwart.
      ls_settings-zmwsk  = <tc>-zmwsk.
      ls_settings-egrkz  = <tc>-egrkz.
      ls_settings-xinact = <tc>-xinact.

      " Retrieve tax code name
      ls_settings-name  = get_tc_name( <tc>-mwskz ).

      loop at at_cond_records assigning <cond> where mwskz = <tc>-mwskz.
        clear: ls_settings-mwskz, ls_settings-kschl,
               ls_settings-rate, ls_settings-kvsll,
               ls_settings-konts.

        " Write tax code and condition type
        ls_settings-mwskz = <cond>-mwskz.
        ls_settings-kschl = <cond>-kschl.
        ls_settings-kvsll = get_acc_key( <cond>-kschl ).

        " Retrieve tax rate
        ls_settings-rate  = get_tc_rate( <cond>-knumh ).

        " Retrieve GL account
        ls_settings-konts = get_gl_account( iv_key = ls_settings-kvsll iv_mwskz = ls_settings-mwskz ).

        append ls_settings to at_settings.
      endloop.
    endloop.

    rt_tc_settings = at_settings.
  endmethod.

  method get_tax_keys.
    select *
      from t007a
      into corresponding fields of table at_tc_keys
      where kalsm = av_kalsm
      and mwskz in as_selopts-mwskz[].
  endmethod.

  method get_tax_conditions.
    data:
      ls_condition like line of ar_conditions,
      ls_acc_key   like line of ar_acc_keys.

    field-symbols: <condition> like line of at_conditions.

    " Select conditions from tax calculation procedure
    select * from t683s
      into corresponding fields of table at_conditions
      where kvewe = c_pricing
      and   kappl = c_taxes
      and   kalsm = av_kalsm.

    " Transfer conditions and account keys to a range
    ls_condition-sign   = 'I'.
    ls_condition-option = 'EQ'.

    ls_acc_key-sign     = 'I'.
    ls_acc_key-option   = 'EQ'.

    loop at at_conditions assigning <condition>.
      clear: ls_condition-low, ls_acc_key-low.
      ls_condition-low = <condition>-kschl.
      append ls_condition to ar_conditions.

      if <condition>-kvsl1 is not initial.
        ls_acc_key-low = <condition>-kvsl1.
        append ls_acc_key to ar_acc_keys.
      endif.
    endloop.
  endmethod.

  method get_tax_rates.
    select * from a003
      into corresponding fields of table at_cond_records
      where kappl = c_taxes
      and   kschl in ar_conditions
      and   aland = as_selopts-land1
      and   mwskz in as_selopts-mwskz.
  endmethod.

  method get_tc_rate.
    data: lv_kbetr type kbetr.
    select single kbetr
      from konp
      into lv_kbetr
      where knumh = iv_knumh.

    if sy-subrc is initial.
      rv_rate = lv_kbetr / 10.
    endif.
  endmethod.

  method get_acc_key.
    data: ls_condition like line of at_conditions.

    read table at_conditions with key kschl = iv_kschl into ls_condition.

    if sy-subrc is initial.
      rv_key = ls_condition-kvsl1.
    endif.
  endmethod.

  method get_gl_accounts.
    select *
      from t030k
      into corresponding fields of table at_gl_accounts
      where ktopl = as_selopts-ktopl
      and ktosl in ar_acc_keys
      and mwskz in as_selopts-mwskz.
  endmethod.

  method get_gl_account.
    data: ls_gl_account like line of at_gl_accounts.

    read table at_gl_accounts into ls_gl_account with key ktopl = as_selopts-ktopl ktosl = iv_key mwskz = iv_mwskz.

    if sy-subrc is initial.
      rv_konts = ls_gl_account-konts.
    endif.
  endmethod.

  method get_tc_name.
    data: lv_spras type spras.

    if as_selopts-lang is initial.
      lv_spras = c_english.
    else.
      lv_spras = as_selopts-lang.
    endif.

    select single text1
      from t007s
      into rv_name
      where spras = lv_spras
      and mwskz = iv_mwskz
      and kalsm = av_kalsm.
  endmethod.
endclass.
