*&---------------------------------------------------------------------*
*&  Definition of common types
*&---------------------------------------------------------------------*
  class lcl_controller definition deferred.

  types:
    ty_mwskz_range type range of mwskz,
    ty_spras_range type range of spras.

  types:
    begin of ty_selopts,
      land1 type land1,
      ktopl type ktopl,
      mwskz type ty_mwskz_range,
      spras type ty_spras_range,
      p_set type xfeld,
      p_trn type xfeld,
    end of ty_selopts.

  types:
    begin of ty_tc_settings,
     mwskz   type mwskz,       " Tax code
     text1   type t007s-text1, " Description
     mwart   type mwart,       " Tax type
     zmwsk   type dzmwsk,      " Target tax code
     kschl   type t683s-kschl, " Condition type
     rate(8) type c,           " Tax rate
     kvsll   type t683s-kvsl1, " Account determination key
     konts   type t030k-konts, " GL account
     egrkz   type egrkz,       " EU code
     xinact  type xinact,      " Is inactive
    end of ty_tc_settings.

  types: ty_tt_tc_names    type standard table of t007s with default key.
  types: ty_tt_tc_keys     type standard table of t007a with default key.
  types: ty_tt_tc_settings type standard table of ty_tc_settings with default key.


  tables: t005, t007a, t007s.

  data: ok_code       type sy-ucomm,
        gs_selopt     type ty_selopts,
        go_controller type ref to lcl_controller.
