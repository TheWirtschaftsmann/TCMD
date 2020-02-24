*&---------------------------------------------------------------------*
*&  Include: Data management routines
*&---------------------------------------------------------------------*
class lcl_tc_master_data definition.
  public section.
    methods: constructor importing is_selopts       type ty_selopts.
    methods: get_names returning value(rt_tc_names) type ty_tt_tc_names.
    methods: get_settings.

  private section.
    types: ty_tt_conditions type standard table of t683s with default key.
    types: ty_r_kschl type range of kschl.

    constants:
      c_pricing type t683s-kvewe value 'A',
      c_taxes   type t683s-kappl value 'TX'.

    data: as_selopts    type ty_selopts.
    data: av_kalsm      type kalsm.
    data: at_tc_keys    type ty_tt_tc_keys.
    data: at_settings   type ty_tt_tc_settings.
    data: at_conditions type ty_tt_conditions.
    data: ar_conditions type ty_r_kschl.

    methods: set_tax_calc_procedure.
    methods: get_tax_keys.
    methods: get_tax_conditions.
    methods: get_tax_rates.
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
    data:
      ls_tc_keys type t007a.

    me->get_tax_conditions( ).
    me->get_tax_keys( ).
    me->get_tax_rates( ).

    loop at at_tc_keys into ls_tc_keys.

    endloop.

  endmethod.

  method get_tax_keys.
    select *
      from t007a
      into corresponding fields of table at_tc_keys
      where kalsm = av_kalsm
      and mwskz in as_selopts-mwskz[].
  endmethod.

  method get_tax_conditions.
    data: ls_condition like line of ar_conditions.
    field-symbols: <condition> like line of at_conditions.

    " Select conditions from tax calculation procedure
    select * from t683s
      into corresponding fields of table at_conditions
      where kvewe = c_pricing
      and   kappl = c_taxes
      and   kalsm = av_kalsm.

    " Transfer conditions to a range
    ls_condition-sign   = 'I'.
    ls_condition-option = 'EQ'.

    loop at at_conditions assigning <condition>.
      clear: ls_condition-low.
      ls_condition-low = <condition>-kschl.
      append ls_condition to ar_conditions.
    endloop.
  endmethod.

  method get_tax_rates.
    data: lt_cond_records type table of a003.

    select * from a003
      into corresponding fields of table lt_cond_records
      where kappl = c_pricing
      and   kschl in ar_conditions
      and   aland = as_selopts-land1
      and   mwskz in as_selopts-mwskz.
  endmethod.
endclass.
