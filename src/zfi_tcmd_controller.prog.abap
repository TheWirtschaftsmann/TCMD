*&---------------------------------------------------------------------*
*&  Include for controller
*&---------------------------------------------------------------------*
class lcl_controller definition.
  public section.
    methods: constructor  importing is_selopts   type ty_selopts.
    methods: process_before_output importing iv_container type ref to cl_gui_custom_container.
    methods: set_gui_status.

  private section.
    data:
      at_tc_names type ty_tt_tc_names,
      as_selopts  type ty_selopts,
      o_data      type ref to lcl_tc_master_data,
      o_view      type ref to lcl_view.
endclass.

class lcl_controller implementation.
  method constructor.
    as_selopts = is_selopts.
  endmethod.

  method set_gui_status.
    set titlebar  'GUI_TITLE'." with text-100.
    set pf-status 'MAIN_STATUS'.
  endmethod.

  method process_before_output.

    data: lv_message  type string.

    create object me->o_data
      exporting is_selopts = as_selopts.

    if as_selopts-p_trn = abap_true.
      at_tc_names = me->o_data->get_names( ).
    elseif as_selopts-p_set = abap_true.

    else.
      " Reserved for future cases
    endif.

    create object me->o_view
      exporting
        iv_parent = iv_container.

    me->o_view->setup_alv( changing ct_data = at_tc_names ).
  endmethod.
endclass.
