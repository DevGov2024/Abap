FORM zf_add_node  USING p_v_node_key
                        p_v_relative_node_key
                        p_v_isfolder
                        p_v_text.
  o_tree_9000->add_node(
    EXPORTING
      node_key                = p_v_node_key "Código do Node Atual
      relative_node_key       = p_v_relative_node_key "Código do Node PAI
      relationship            = 1
      isfolder                = p_v_isfolder
      text                    = p_v_text
*      hidden                  =                  " 'X': Node is Invisible
*      disabled                =                  " 'X': Node Cannot be Selected
*      style                   =                  " See Method Documentation
*      no_branch               =                  " 'X': Do Not Draw Hierarchy Lines
      expander                = p_v_isfolder
*      image                   =                  " See Method Documentation
*      expanded_image          =                  " See Method Documentation
*      drag_drop_id            =                  " See Method Documentation
*      user_object             =                  " User Object
*    EXCEPTIONS
*      node_key_exists         = 1                " Node Key Already Exists
*      illegal_relationship    = 2                " RELATIONSHIP Contains Invalid Value
*      relative_node_not_found = 3                " The RELATIVE_NODE Node Does Not Belong to This Tree
*      node_key_empty          = 4                " NODE_KEY is Initial or Contains Only Blanks
*      others                  = 5
  ).
  IF p_v_isfolder EQ 'X'.
    o_tree_9000->expand_node( node_key = p_v_node_key ).
  ENDIF.
ENDFORM.



FORM zf_seleciona .

  DATA: tl_fieldcat TYPE lvc_t_fcat.

  FREE: tg_par, tl_fieldcat.

  CASE vg_screen.
    WHEN '9100'.

      SELECT *
        FROM  ZTBSICORC_SP_PAR
        INTO TABLE tg_par
          WHERE id_app IN s_app
            AND app_type IN s_type.

      IF o_alv_9100 IS NOT BOUND.
      CREATE OBJECT o_alv_9100
        EXPORTING
*         i_shellstyle      = 0                " Control Style
*         i_lifetime        =                  " Lifetime
          i_parent          = o_cont_9100
*         i_appl_events     = space            " Register Events as Application Events
*         i_parentdbg       =                  " Internal, Do not Use
*         i_applogparent    =                  " Container for Application Log
*         i_graphicsparent  =                  " Container for Graphics
*         i_name            =                  " Name
*         i_fcat_complete   = space            " Boolean Variable (X=True, Space=False)
*         o_previous_sral_handler =
        EXCEPTIONS
          error_cntl_create = 1                " Error when creating the control
          error_cntl_init   = 2                " Error While Initializing Control
          error_cntl_link   = 3                " Error While Linking Control
          error_dp_create   = 4                " Error While Creating DataProvider Control
          OTHERS            = 5.
      IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
*         I_BUFFER_ACTIVE  =
          i_structure_name = 'ZTBSICORC_SP_PAR'
*         I_CLIENT_NEVER_DISPLAY       = 'X'
*         I_BYPASSING_BUFFER           =
*         I_INTERNAL_TABNAME           =
        CHANGING
          ct_fieldcat      = tl_fieldcat
*   EXCEPTIONS
*         INCONSISTENT_INTERFACE       = 1
*         PROGRAM_ERROR    = 2
*         OTHERS           = 3
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      o_alv_9100->set_table_for_first_display(
*    EXPORTING
*      i_buffer_active               =                  " Buffering Active
*      i_bypassing_buffer            =                  " Switch Off Buffer
*      i_consistency_check           =                  " Starting Consistency Check for Interface Error Recognition
*      i_structure_name              =                  " Internal Output Table Structure Name
*      is_variant                    =                  " Layout
*      i_save                        =                  " Save Layout
*      i_default                     = 'X'              " Default Display Variant
*      is_layout                     =                  " Layout
*      is_print                      =                  " Print Control
*      it_special_groups             =                  " Field Groups
*      it_toolbar_excluding          =                  " Excluded Toolbar Standard Functions
*      it_hyperlink                  =                  " Hyperlinks
*      it_alv_graphics               =                  " Table of Structure DTC_S_TC
*      it_except_qinfo               =                  " Table for Exception Quickinfo
*      ir_salv_adapter               =                  " Interface ALV Adapter
        CHANGING
          it_outtab                     = tg_par
          it_fieldcatalog               = tl_fieldcat
*      it_sort                       =                  " Sort Criteria
*      it_filter                     =                  " Filter Criteria
*    EXCEPTIONS
*      invalid_parameter_combination = 1                " Wrong Parameter
*      program_error                 = 2                " Program Errors
*      too_many_lines                = 3                " Too many Rows in Ready for Input Grid
*      others                        = 4
      ).
      IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      ELSE.
        o_alv_9100->refresh_table_display(
*          EXPORTING
*            is_stable      =                  " With Stable Rows/Columns
*            i_soft_refresh =                  " Without Sort, Filter, etc.
*          EXCEPTIONS
*            finished       = 1                " Display was Ended (by Export)
*            others         = 2
        ).
        IF SY-SUBRC <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDIF.


    WHEN '9101'.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form zf_seleciona
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

FORM subcreen_9201.
  DATA: tl_fldcat_9201 TYPE lvc_t_fcat,
        wl_layout_9201 TYPE lvc_s_layo.

  SELECT *
     FROM ztbsicorc_md_seq
     INTO TABLE tg_md.

  IF o_alv_md_9201 IS NOT BOUND.
    CREATE OBJECT o_alv_md_9201
      EXPORTING
        i_parent          = o_cont_md_9201                " Parent Container
      EXCEPTIONS
        error_cntl_create = 1                " Error when creating the control
        error_cntl_init   = 2                " Error While Initializing Control
        error_cntl_link   = 3                " Error While Linking Control
        error_dp_create   = 4                " Error While Creating DataProvider Control
        OTHERS            = 5.
    IF sy-subrc <> 0.
*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    IF o_handler_button IS NOT BOUND.
      CREATE OBJECT o_handler_button.
    ENDIF.

    SET HANDLER o_handler_button->on_toolbar      FOR o_alv_md_9201.
    SET HANDLER o_handler_button->on_user_command FOR o_alv_md_9201.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = 'ZTBSICORC_MD_SEQ'
      CHANGING
        ct_fieldcat            = tl_fldcat_9201
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    LOOP AT tl_fldcat_9201 ASSIGNING FIELD-SYMBOL(<field>) WHERE fieldname = 'REQUIRED'.
      <field>-checkbox  = 'X'.
      <field>-outputlen = '4'.
    ENDLOOP.

    LOOP AT tl_fldcat_9201 ASSIGNING <field>.
      <field>-scrtext_l = <field>-fieldname.
    ENDLOOP.

    wl_layout_9201-zebra = 'X'.
    wl_layout_9201-cwidth_opt = 'X'.


    o_alv_md_9201->set_table_for_first_display(
      EXPORTING
        is_layout                     = wl_layout_9201
      CHANGING
        it_outtab                     =  tg_md               " Output Table
        it_fieldcatalog               =  tl_fldcat_9201                " Field Catalog
*          it_sort                       =                  " Sort Criteria
*          it_filter                     =                  " Filter Criteria
      EXCEPTIONS
        invalid_parameter_combination = 1                " Wrong Parameter
        program_error                 = 2                " Program Errors
        too_many_lines                = 3                " Too many Rows in Ready for Input Grid
        OTHERS                        = 4
    ).
    IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    o_alv_md_9201->refresh_table_display( ).
  ENDIF.
ENDFORM.

FORM  subcreen_9202.
  DATA: tl_fldcat_9202 TYPE lvc_t_fcat,
        wl_layout_9202 TYPE lvc_s_layo.

  SELECT *
      FROM ztbsicorc_app_sq
      INTO TABLE tg_app.

  IF o_alv_app_9202 IS NOT BOUND.
    CREATE OBJECT o_alv_app_9202
      EXPORTING
        i_parent          = o_cont_app_9202                " Parent Container
      EXCEPTIONS
        error_cntl_create = 1                " Error when creating the control
        error_cntl_init   = 2                " Error While Initializing Control
        error_cntl_link   = 3                " Error While Linking Control
        error_dp_create   = 4                " Error While Creating DataProvider Control
        OTHERS            = 5.
    IF sy-subrc <> 0.
*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    IF o_handler_button IS NOT BOUND.
      CREATE OBJECT o_handler_button.
    ENDIF.


    SET HANDLER o_handler_button->on_toolbar      FOR o_alv_app_9202.
    SET HANDLER o_handler_button->on_user_command FOR o_alv_app_9202.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = 'ZTBSICORC_APP_SQ'
      CHANGING
        ct_fieldcat            = tl_fldcat_9202
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    LOOP AT tl_fldcat_9202 ASSIGNING FIELD-SYMBOL(<field>) WHERE fieldname = 'PARALLEL'
                                                              OR fieldname = 'OFFLOAD'
                                                              OR fieldname = 'ZSEND'
                                                              OR fieldname = 'ACTIVE'
                                                              OR fieldname = 'BP'.
      <field>-checkbox  = 'X'.
      <field>-outputlen = '4'.
    ENDLOOP.

    LOOP AT tl_fldcat_9202 ASSIGNING <field>.
      <field>-scrtext_l = <field>-fieldname.
    ENDLOOP.

    wl_layout_9202-zebra = 'X'.
    wl_layout_9202-cwidth_opt = 'X'.

    o_alv_app_9202->set_table_for_first_display(
      EXPORTING
        is_layout                     =  wl_layout_9202                " Layout
      CHANGING
        it_outtab                     =  tg_app               " Output Table
        it_fieldcatalog               =  tl_fldcat_9202                " Field Catalog
      EXCEPTIONS
        invalid_parameter_combination = 1                " Wrong Parameter
        program_error                 = 2                " Program Errors
        too_many_lines                = 3                " Too many Rows in Ready for Input Grid
        OTHERS                        = 4
    ).
    IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    o_alv_app_9202->refresh_table_display( ).
  ENDIF.
ENDFORM.