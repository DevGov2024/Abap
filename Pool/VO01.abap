MODULE status_9000 OUTPUT.

  DATA tl_fcode TYPE TABLE OF sy-ucomm.

  FREE: tl_fcode.
  IF vg_screen EQ '9001'.
    APPEND 'RUN' TO tl_fcode.
  ENDIF.

  SET PF-STATUS 'STATUS_9000' EXCLUDING tl_fcode.
  SET TITLEBAR 'TITLE_9000'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_CONTAINER_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_container_9000 OUTPUT.

  DATA: tl_events TYPE cntl_simple_events.

  DATA: wl_event  TYPE cntl_simple_event.

  CHECK o_cont_9000 IS NOT BOUND.

  CREATE OBJECT o_cont_9000
    EXPORTING
*     parent                      =                  " Parent container
      container_name              = 'CONT_9000'
*     style                       =                  " Windows Style Attributes Applied to this Container
*     lifetime                    = lifetime_default " Lifetime
*     repid                       =                  " Screen to Which this Container is Linked
*     dynnr                       =                  " Report To Which this Container is Linked
*     no_autodef_progid_dynnr     =                  " Don't Autodefined Progid and Dynnr?
    EXCEPTIONS
      cntl_error                  = 1                " CNTL_ERROR
      cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
      create_error                = 3                " CREATE_ERROR
      lifetime_error              = 4                " LIFETIME_ERROR
      lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CREATE OBJECT o_tree_9000
    EXPORTING
      node_selection_mode = cl_simple_tree_model=>node_sel_mode_multiple
*     hide_selection      =                  " Visibility of Selection
*    EXCEPTIONS
*     illegal_node_selection_mode = 1                " "
*     others              = 2
    .
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  o_tree_9000->create_tree_control(
    EXPORTING
*      lifetime                     =                  " "
      parent                       = o_cont_9000
*      shellstyle                   =                  " "
*    IMPORTING
*      control                      =                  " "
*    EXCEPTIONS
*      lifetime_error               = 1                " "
*      cntl_system_error            = 2                " "
*      create_error                 = 3                " "
*      failed                       = 4                " "
*      tree_control_already_created = 5                " Tree Control Has Already Been Created
*      others                       = 6
  ).
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  PERFORM zf_add_node USING 'ROOT'  ''      'X' 'Rule Control'.
  PERFORM zf_add_node USING 'MD'    'ROOT'  'X' 'Master Data'.
  PERFORM zf_add_node USING 'AM'    'MD'    '' 'Application Management'.
  PERFORM zf_add_node USING 'SH'    'MD'    '' 'Scheduller'.

  wl_event-eventid = cl_simple_tree_model=>eventid_node_double_click.
  wl_event-appl_event = 'X'.
  APPEND wl_event TO tl_events.
  o_tree_9000->set_registered_events( tl_events ).
*  APPEND VALUE cntl_simple_event( eventid = cl_simple_tree_model=>eventid_node_double_click appl_event = 'X' ) TO tl_events.

  CREATE OBJECT o_handler_tree_9000.
  SET HANDLER o_handler_tree_9000->node_double_click FOR o_tree_9000.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_container_9100 OUTPUT.

  CHECK o_cont_9100 IS NOT BOUND.

  CREATE OBJECT o_cont_9100
    EXPORTING
*      parent                      =                  " Parent container
      container_name              = 'CONT_9100'
*      style                       =                  " Windows Style Attributes Applied to this Container
*      lifetime                    = lifetime_default " Lifetime
*      repid                       =                  " Screen to Which this Container is Linked
*      dynnr                       =                  " Report To Which this Container is Linked
*      no_autodef_progid_dynnr     =                  " Don't Autodefined Progid and Dynnr?
    EXCEPTIONS
      cntl_error                  = 1                " CNTL_ERROR
      cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
      create_error                = 3                " CREATE_ERROR
      lifetime_error              = 4                " LIFETIME_ERROR
      lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      others                      = 6
    .
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module VALIDA_CAMPOS_9101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE valida_campos_9101 OUTPUT.

  IF scr_9101-data_fixa IS INITIAL AND scr_9101-data_dinamica IS INITIAL.
    scr_9101-data_dinamica = 'X'.
  ENDIF.

  LOOP AT SCREEN.
    IF scr_9101-data_fixa NE 'X' AND screen-group1 EQ 'FIX'.
      screen-active = 0.
*      screen-input = 0.
*      screen-invisible  = 1.Campo de senha
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.

MODULE set_container_9201 OUTPUT.
  CHECK o_cont_md_9201 IS NOT BOUND.
  CREATE OBJECT o_cont_md_9201
    EXPORTING
*     parent         =                  " Parent container
      container_name = 'CONT_9201'                " Name of the Screen CustCtrl Name to Link Container To
*     style          =                  " Windows Style Attributes Applied to this Container
*     lifetime       = lifetime_default " Lifetime
*     repid          =                  " Screen to Which this Container is Linked
*     dynnr          =                  " Report To Which this Container is Linked
*     no_autodef_progid_dynnr     =                  " Don't Autodefined Progid and Dynnr?
   EXCEPTIONS
     cntl_error     = 1                " CNTL_ERROR
     cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
     create_error   = 3                " CREATE_ERROR
     lifetime_error = 4                " LIFETIME_ERROR
     lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
     others         = 6
    .
  IF sy-subrc <> 0.
*  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  PERFORM subcreen_9201.

ENDMODULE.

MODULE set_container_9202 OUTPUT.
  CHECK o_cont_app_9202 IS NOT BOUND.
  CREATE OBJECT o_cont_app_9202
    EXPORTING
*     parent         =                  " Parent container
      container_name = 'CONT_APP'                 " Name of the Screen CustCtrl Name to Link Container To
*     style          =                  " Windows Style Attributes Applied to this Container
*     lifetime       = lifetime_default " Lifetime
*     repid          =                  " Screen to Which this Container is Linked
*     dynnr          =                  " Report To Which this Container is Linked
*     no_autodef_progid_dynnr     =                  " Don't Autodefined Progid and Dynnr?
   EXCEPTIONS
     cntl_error     = 1                " CNTL_ERROR
     cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
     create_error   = 3                " CREATE_ERROR
     lifetime_error = 4                " LIFETIME_ERROR
     lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
     others         = 6
    .
  IF sy-subrc <> 0.
*  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  PERFORM subcreen_9202.

ENDMODULE.