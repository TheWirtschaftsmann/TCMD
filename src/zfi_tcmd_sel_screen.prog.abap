*&---------------------------------------------------------------------*
*&  Include for selection screen elementss
*&---------------------------------------------------------------------*
selection-screen begin of block b1 with frame title text-001.
parameters:     p_land type t005-land1 obligatory.
select-options: s_mwskz for t007a-mwskz.
selection-screen end of block b1.

selection-screen begin of block b2 with frame title text-002.
parameters:     p_set radiobutton group rb1 user-command act default 'X'.
parameters:     p_trn radiobutton group rb1.
select-options: s_lang for t007s-spras.
selection-screen end of block b2.
