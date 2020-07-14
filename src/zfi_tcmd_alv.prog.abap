*&---------------------------------------------------------------------*
*&  Include for ALV routines
*&---------------------------------------------------------------------*
define add_exclude.
  ls_excluding = &1.
  append ls_excluding to rt_excluding.
end-of-definition.

class lcl_view definition inheriting from cl_gui_alv_grid.
  public section.
    methods: constructor importing iv_parent   type ref to cl_gui_container.
    methods: setup_alv   importing iv_set_mode type abap_bool
                         changing  ct_data     type standard table.
  private section.
    constants: c_settings_mode     type char1 value 'S'.
    constants: c_translations_mode type char1 value 'T'.

    data: av_display_mode type char1.

    methods: build_fieldcatalog returning value(rt_fieldcat)  type lvc_t_fcat.
    methods: build_layout       returning value(rs_layout)    type lvc_s_layo.
    methods: build_variant      returning value(rs_variant)   type disvariant.
    methods: exclude_buttons    returning value(rt_excluding) type ui_functions.
    methods: display_tax_code   importing iv_mwskz type mwskz raising lcx_exception.

    methods: handle_double_click for event double_click of cl_gui_alv_grid importing e_row e_column.

endclass.

class lcl_view implementation.
  method constructor.
    call method super->constructor
      exporting
        i_parent = iv_parent.
  endmethod.

  method setup_alv.
    data:
      lt_fieldcat  type lvc_t_fcat,
      ls_layout    type lvc_s_layo,
      ls_variant   type disvariant,
      lt_excluding type ui_functions.

    " Set display mode
    if iv_set_mode = abap_true.
      av_display_mode = c_settings_mode.
    else.
      av_display_mode = c_translations_mode.
    endif.

    " Prepare technical components of ALV-view
    ls_layout    = me->build_layout( ).
    ls_variant   = me->build_variant( ).
    lt_fieldcat  = me->build_fieldcatalog( ).
    lt_excluding = me->exclude_buttons( ).

    " Pass data for ALV-display
    call method me->set_table_for_first_display
      exporting
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = ls_layout
        is_variant           = ls_variant
        it_toolbar_excluding = lt_excluding
      changing
        it_outtab            = ct_data
        it_fieldcatalog      = lt_fieldcat.

    set handler me->handle_double_click for me.
  endmethod.

  method build_fieldcatalog.
    constants:
      lc_tc_name_str type slis_tabname value 'T007S',
      lc_tc_sets_str type slis_tabname value 'ZFI_TCMD_TC_SETTINGS'.

    data:
      lv_structure type slis_tabname,
      lt_fieldcat  type lvc_t_fcat.

    if av_display_mode = c_settings_mode.
      lv_structure = lc_tc_sets_str.
    else.
      lv_structure = lc_tc_name_str.
    endif.

    call function 'LVC_FIELDCATALOG_MERGE'
      exporting
        i_structure_name = lv_structure
      changing
        ct_fieldcat      = lt_fieldcat.

    rt_fieldcat = lt_fieldcat.
  endmethod.

  method build_layout.
    rs_layout-sel_mode    = 'A'.         " User can select the lines
    rs_layout-zebra       = 'X'.         " Zebra display
    rs_layout-cwidth_opt  = 'X'.         " Optimization of columns width
    rs_layout-ctab_fname  = 'COLORCELL'. " Cells coloring
  endmethod.

  method build_variant.
    rs_variant-report   = sy-repid.
    rs_variant-username = sy-uname.
  endmethod.

  method exclude_buttons.
    data: ls_excluding like line of rt_excluding.

    add_exclude cl_gui_alv_grid=>mc_fc_graph.
    add_exclude cl_gui_alv_grid=>mc_fc_info.
    add_exclude cl_gui_alv_grid=>mc_fc_loc_copy.
    add_exclude cl_gui_alv_grid=>mc_fc_loc_copy_row.
    add_exclude cl_gui_alv_grid=>mc_fc_loc_cut.
    add_exclude cl_gui_alv_grid=>mc_fc_loc_delete_row.
    add_exclude cl_gui_alv_grid=>mc_fc_loc_insert_row.
    add_exclude cl_gui_alv_grid=>mc_fc_loc_move_row.
    add_exclude cl_gui_alv_grid=>mc_fc_loc_paste.
    add_exclude cl_gui_alv_grid=>mc_fc_loc_undo.
    add_exclude cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
    add_exclude cl_gui_alv_grid=>mc_fc_loc_append_row.
    add_exclude cl_gui_alv_grid=>mc_fc_check.
    add_exclude cl_gui_alv_grid=>mc_fc_refresh.
    add_exclude cl_gui_alv_grid=>mc_fc_subtot.
    add_exclude cl_gui_alv_grid=>mc_fc_sum.
  endmethod.

  method handle_double_click.
    data:
          lv_msg type string,
          lo_ex  type ref to lcx_exception.

    field-symbols:
                   <data_table> type standard table,
                   <tc_md> type zfi_tcmd_tc_settings.

    assign me->mt_outtab->* to <data_table>.

    if sy-subrc is not initial or e_row-rowtype is not initial.
      return.
    endif.

    read table <data_table> assigning <tc_md> index e_row-index.

    try.
      me->display_tax_code( <tc_md>-mwskz ).
    catch lcx_exception into lo_ex.
      message lo_ex->mv_message type 'S'.
    endtry.
  endmethod.

  method display_tax_code.
    call function 'AUTHORITY_CHECK_TCODE'
      exporting
        tcode  = 'FTXP'
      exceptions
        ok     = 0
        not_ok = 1
        others = 2.
    if sy-subrc is not initial.
      raise exception type lcx_exception
        exporting
          i_message = 'Missing authorization for transaction FTXP'.
    endif.

    set parameter id 'LND' field 'UA'.
    set parameter id 'TAX' field iv_mwskz.
    call transaction 'FTXP' and skip first screen.
  endmethod.
endclass.
