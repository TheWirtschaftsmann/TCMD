*&---------------------------------------------------------------------*
*& Report on master data of tax codes
*& Developed by: Bohdan Petrushchak, 2020
*&---------------------------------------------------------------------*

report zfi_tcmd_analysis.

include zfi_tcmd_top.
include zfi_tcmd_exceptions.
include zfi_tcmd_sel_screen.
include zfi_tcmd_model.
include zfi_tcmd_alv.
include zfi_tcmd_controller.

form main.
  data: lo_ex type ref to lcx_exception.

  gs_selopt-land1 = p_land.
  gs_selopt-ktopl = p_ktopl.
  gs_selopt-mwskz = s_mwskz[].
  gs_selopt-spras = s_lang[].
  gs_selopt-lang  = p_lang.
  gs_selopt-p_set = p_set.
  gs_selopt-p_trn = p_trn.

  perform check_input_values.

  try.
      create object go_controller exporting is_selopts = gs_selopt.
      call screen 0100.
    catch lcx_exception into lo_ex.
      message lo_ex->mv_message type 'I' display like 'E'.
      leave list-processing.
  endtry.
endform.

start-of-selection.
  perform main.

  include zfi_tcmd_sel_screen_events.
