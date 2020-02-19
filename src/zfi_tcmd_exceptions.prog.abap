*&---------------------------------------------------------------------*
*&  Include exceptions
*&---------------------------------------------------------------------*

class lcx_exception definition inheriting from cx_dynamic_check  ##CLASS_FINAL.
  public section.
    data: mv_message type string read-only.
    methods: constructor importing i_message type string.
endclass.

class lcx_exception implementation.
  method constructor.
    super->constructor( ).
    mv_message = i_message.
  endmethod.
endclass.
