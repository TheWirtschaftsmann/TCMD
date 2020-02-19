*&---------------------------------------------------------------------*
*&  Include for controller
*&---------------------------------------------------------------------*
class lcl_controller definition.
  public section.
    methods: constructor  importing is_selopts   type ty_selopts.

  private section.
    data:
      as_selopts type ty_selopts.
endclass.

class lcl_controller implementation.
  method constructor.
    as_selopts = is_selopts.
  endmethod.
endclass.
