*&---------------------------------------------------------------------*
*& Include          ZTT0MOURAG_I_V2_O01
*&---------------------------------------------------------------------*
MODULE user_command_9000 INPUT.

  CASE vg_ok_code.
    WHEN 'BACK' OR 'END' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'RUN'.
      PERFORM zf_seleciona.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9101 INPUT.

  CASE vg_ok_code.
    WHEN 'TAB_MD'.
      control_tab  = 'TAB_MD'.
    WHEN 'TAB_APP'.
      control_tab  = 'TAB_APP'.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.