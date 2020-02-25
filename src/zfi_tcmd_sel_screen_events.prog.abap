*&---------------------------------------------------------------------*
*&  Include for selection screen events
*&---------------------------------------------------------------------*
at selection-screen output.
  loop at screen.
    if screen-group1 = 'MDS'.
      if p_trn is initial.
        screen-active = 0.
      else.
        screen-active = 1.
      endif.
      modify screen.
    endif.
    if screen-group1 = 'MDP'.
      if p_set is initial.
        screen-active = 0.
      else.
        screen-active = 1.
      endif.
      modify screen.
    endif.
  endloop.

form check_input_values.
  if gs_selopt-p_set is not initial.
    if gs_selopt-ktopl is initial.
      message text-101 type 'I' display like 'E'.
      leave list-processing.
    endif.
  endif.
endform.

module handle_pbo output.
  data:
    lv_cont_name type scrfname value 'MAIN_CONTAINER',
    lv_cust_cont type ref to cl_gui_custom_container.

    go_controller->set_gui_status( ).

    if lv_cust_cont is initial.
      create object lv_cust_cont exporting container_name = lv_cont_name.
      go_controller->process_before_output( iv_container = lv_cust_cont ).
    endif.
endmodule.

module handle_pai input.
  case ok_code.
    when 'BACK' or 'EXIT'.
      leave to screen 0.
    when 'CANCEL'.
      leave program .
  endcase.
endmodule.
