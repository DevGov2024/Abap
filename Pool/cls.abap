*&---------------------------------------------------------------------*
*& Include          ZTT0MOURAG_I_V2_CLS
*&---------------------------------------------------------------------*
CLASS lcl_handler_tree_9000 IMPLEMENTATION.

  METHOD: node_double_click.

    CASE node_key.
      WHEN 'AM'.
        vg_screen = '9100'.
      WHEN 'SH'.
        vg_screen = '9101'.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
CLASS lcl_handler_button IMPLEMENTATION.

  METHOD on_toolbar.

    DATA: wl_button TYPE stb_button.

    CLEAR wl_button.
    wl_button-butn_type  = 3.
    APPEND wl_button TO e_object->mt_toolbar.

    " --- Botão Edit ---
    CLEAR wl_button.
    wl_button-function  = 'EDIT'.
    wl_button-icon      = icon_change.
    wl_button-quickinfo = 'Edit'.
    wl_button-text      = 'Edit'.
    wl_button-disabled  = space.
    APPEND wl_button TO e_object->mt_toolbar.

    " --- Botão Insert ---
    CLEAR wl_button.
    wl_button-function  = 'INSERT'.
    wl_button-icon      = icon_insert_row.
    wl_button-quickinfo = 'Insert'.
    wl_button-text      = 'Insert'.
    APPEND wl_button TO e_object->mt_toolbar.

    " --- Botão Delete ---
    CLEAR wl_button.
    wl_button-function  = 'DELETE'.
    wl_button-icon      = icon_delete_row.
    wl_button-quickinfo = 'Delete'.
    wl_button-text      = 'Delete'.
    APPEND wl_button TO e_object->mt_toolbar.

  ENDMETHOD.

  METHOD on_user_command.

    CASE sender.
      WHEN o_alv_md_9201.
        CASE e_ucomm.
          WHEN 'EDIT'.
            MESSAGE 'Edit no Master Data' TYPE 'I'.
          WHEN 'INSERT'.
            MESSAGE 'Insert no Master Data' TYPE 'I'.
          WHEN 'DELETE'.
            MESSAGE 'Delete no Master Data' TYPE 'I'.
        ENDCASE.
      WHEN o_alv_app_9202.
        CASE e_ucomm.
          WHEN 'EDIT'.
            MESSAGE 'Edit no Apps' TYPE 'I'.
          WHEN 'INSERT'.
            MESSAGE 'Insert no Apps' TYPE 'I'.
          WHEN 'DELETE'.
            MESSAGE 'Delete no Apps' TYPE 'I'.
        ENDCASE.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.