*&---------------------------------------------------------------------*
*&  Include for selection screen events
*&---------------------------------------------------------------------*
at selection-screen output.
  loop at screen.
    if screen-group1 = 'MOD'.
      if p_trn is initial.
        screen-active = 0.
      else.
        screen-active = 1.
      endif.
      modify screen.
    endif.
  endloop.
