*&---------------------------------------------------------------------*
*&  Include: Data management routines
*&---------------------------------------------------------------------*
class lcl_tc_master_data definition.
  public section.
    methods: constructor importing is_selopts       type ty_selopts.
    methods: get_names returning value(rt_tc_names) type ty_tt_tc_names.

  private section.
    data: as_selopts type ty_selopts.
    data: av_kalsm   type kalsm.

    methods: set_tax_calc_procedure.
endclass.

class lcl_tc_master_data implementation.
  method constructor.
    as_selopts = is_selopts.
    me->set_tax_calc_procedure( ).
  endmethod.

  method get_names.
    select *
      from t007s
      into corresponding fields of table rt_tc_names
      where spras in as_selopts-spras
      and   kalsm = av_kalsm
      and   mwskz in as_selopts-mwskz.
  endmethod.

  method set_tax_calc_procedure.
    select single kalsm
      from t005
      into av_kalsm
      where land1 = as_selopts-land1.
  endmethod.
endclass.
