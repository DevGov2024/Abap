*&---------------------------------------------------------------------*
*& Report ZTT0MOURAG_R_ARQUIVOZ
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztt0mourag_r_arquivoz.
TABLES: ztt0mourag_tm_v.

TYPES: BEGIN OF ty_s_alv_detal,
         nro        TYPE ztt0mourag_tm_v-nro,
         item       TYPE ztt0mourag_tm_v-item,
         matnr      TYPE ztt0mourag_tm_v-matnr,
         maktx      TYPE ztt0mourag_tm_v-maktx,
         data_venda TYPE ztt0mourag_tm_v-data_venda,
         bukrs      TYPE ztt0mourag_tm_v-bukrs,
         branch     TYPE ztt0mourag_tm_v-branch,
         kunnr      TYPE ztt0mourag_tm_v-kunnr,
         valor      TYPE ztt0mourag_tm_v-valor,
         unv        TYPE ztt0mourag_tm_v-unv,
         qtd        TYPE ztt0mourag_tm_v-qtd,
       END   OF ty_s_alv_detal.


TYPES: BEGIN OF ty_s_alv_filial,
         bukrs  TYPE ztt0mourag_tm_v-bukrs,
         branch TYPE ztt0mourag_tm_v-branch,
         valor  TYPE ztt0mourag_tm_v-valor,
       END OF ty_s_alv_filial.

TYPES: BEGIN OF ty_s_alv_matnr,
         matnr TYPE ztt0mourag_tm_v-matnr,
         maktx TYPE ztt0mourag_tm_v-maktx,
         valor TYPE ztt0mourag_tm_v-valor,
       END OF ty_s_alv_matnr.


TYPES: BEGIN OF ty_s_alv_kunnr,
         kunnr TYPE ztt0mourag_tm_v-kunnr,
         valor TYPE ztt0mourag_tm_v-valor,
       END OF ty_s_alv_kunnr.

TYPES: ty_t_alv_detal    TYPE STANDARD TABLE OF ty_s_alv_detal    WITH NON-UNIQUE KEY nro item.
TYPES: ty_t_alv_filial TYPE STANDARD TABLE OF ty_s_alv_filial WITH NON-UNIQUE KEY bukrs branch.
TYPES: ty_t_alv_matnr TYPE STANDARD TABLE OF ty_s_alv_matnr WITH NON-UNIQUE KEY matnr maktx.
TYPES: ty_t_alv_kunnr TYPE STANDARD TABLE OF ty_s_alv_kunnr WITH NON-UNIQUE KEY kunnr.

DATA: tg_alv_detal  TYPE ty_t_alv_detal,
      tg_alv_filial TYPE ty_t_alv_filial,
      tg_alv_matnr  TYPE ty_t_alv_matnr,
      tg_alv_kunnr  TYPE ty_t_alv_kunnr.



SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
  SELECT-OPTIONS: s_bukrs  FOR ztt0mourag_tm_v-bukrs  NO INTERVALS MATCHCODE OBJECT   ztt0mourag_ap_log ,
                  s_branch FOR ztt0mourag_tm_v-branch NO INTERVALS  MATCHCODE OBJECT  ztt0mourag_ap_log,
                  s_nro    FOR ztt0mourag_tm_v-nro         NO INTERVALS,
                  s_dats   FOR ztt0mourag_tm_v-data_venda,
                  s_kunnr  FOR ztt0mourag_tm_v-kunnr       NO INTERVALS.
SELECTION-SCREEN END OF BLOCK b02.


SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  PARAMETERS: p_arq TYPE string LOWER CASE OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b01.



SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-b03.
  PARAMETERS: p_detal RADIOBUTTON GROUP grp1,
              p_bukrs RADIOBUTTON GROUP grp1,
              p_matnr RADIOBUTTON GROUP grp1,
              p_kunnr RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK b03.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_arq.
  PERFORM zf_arq.

*--------------------------------------------------------------------*
* Evento de Execução                                                 *
*--------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM zf_processar.
  PERFORM zf_filtro.


*  IF p_detal = 'X'.
*    PERFORM zf_alv_detal.
*  ELSEIF p_bukrs = 'X'.
*
*
*    PERFORM zf_alv_filial.
*  ELSEIF p_matnr = 'X'.
*    PERFORM zf_alv_matnr.
*
*  ELSEIF p_kunnr = 'X'.
*    PERFORM zf_alv_kunnr.
*
*  ENDIF.

CASE 'X'.
  WHEN p_detal.
    PERFORM zf_alv_detal.
  WHEN p_bukrs.
    PERFORM zf_alv_filial.

  WHEN p_matnr.
    PERFORM zf_alv_matnr.

  WHEN p_kunnr.
      PERFORM zf_alv_kunnr.
ENDCASE.

*&---------------------------------------------------------------------*
*& Form zf_arq
*&---------------------------------------------------------------------*

FORM zf_processar.

IF p_arq IS INITIAL OR
   p_arq = space OR
   p_arq CP '* *' OR
   p_arq CP '*.*'.
  MESSAGE 'Informe um caminho de arquivo válido (ex: C:\arquivo.csv).' TYPE 'I' DISPLAY LIKE 'E'.
  STOP.
ENDIF.


  DATA: tl_arquivo TYPE TABLE OF string,
        tl_split   TYPE TABLE OF string.

  DATA: wl_alv_detal TYPE ty_s_alv_detal.

  DATA: vl_linha TYPE string,
        vl_split TYPE string.

  DATA: vl_cv_nro   TYPE c LENGTH 10,
        vl_cv_kunnr TYPE c LENGTH 10.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = p_arq
    TABLES
      data_tab                = tl_arquivo
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  DELETE tl_arquivo INDEX 1.

  LOOP AT tl_arquivo INTO vl_linha.


  TRY.

    SPLIT vl_linha AT ';' INTO TABLE tl_split.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = tl_split[ 1 ]
      IMPORTING
        output = vl_cv_nro.

    wl_alv_detal-nro   = vl_cv_nro.
    wl_alv_detal-item  = tl_split[ 2 ].
    wl_alv_detal-matnr = tl_split[ 3 ].
    wl_alv_detal-maktx = tl_split[ 4 ].

    vl_split = tl_split[ 5 ].
    TRANSLATE vl_split USING '/ '.
    CONDENSE  vl_split NO-GAPS.
    wl_alv_detal-data_venda = |{ vl_split+4(4) }{ vl_split+2(2) }{ vl_split(2) }|.

    wl_alv_detal-bukrs  = tl_split[ 6 ].
    wl_alv_detal-branch = tl_split[ 7 ].

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = tl_split[ 8 ]
      IMPORTING
        output = vl_cv_kunnr.

    wl_alv_detal-kunnr  = vl_cv_kunnr.

    vl_split = tl_split[ 9 ].
    TRANSLATE vl_split USING '. '.
    TRANSLATE vl_split USING ',.'.
    CONDENSE  vl_split NO-GAPS.
    wl_alv_detal-valor = vl_split.

    wl_alv_detal-qtd =  tl_split[ 10 ].
    wl_alv_detal-unv =  tl_split[ 11 ].

    APPEND wl_alv_detal TO tg_alv_detal.


 CATCH cx_sy_range_out_of_bounds cx_sy_itab_line_not_found.
      MESSAGE 'Erro: modelo do arquivo diferente do esperado. Verifique o número de colunas.' TYPE 'I' DISPLAY LIKE 'E'.
      STOP.


CATCH cx_sy_conversion_no_number cx_root.
   MESSAGE |Erro ao converter dados na linha { sy-tabix }. Verifique o conteúdo.| TYPE 'I' DISPLAY LIKE 'E'.
   STOP.

ENDTRY.
*
*lines( tl_split ) < 11: verifica se a linha tem menos colunas do que o esperado.
*cx_sy_range_out_of_bounds: erro ao acessar índice inexistente.
*cx_sy_itab_line_not_found: erro ao acessar linha que não existe.
*cx_sy_conversion_no_number: erro ao converter string para número.
*sy-tabix: retorna o índice atual do LOOP, útil para mostrar em qual linha ocorreu o erro.

  ENDLOOP.


ENDFORM.



FORM zf_arq.

  DATA tl_file_table TYPE filetable.
  DATA vl_rc TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
*    EXPORTING
*      window_title            =
*      default_extension       =
*      default_filename        =
*      file_filter             =
*      with_encoding           =
*      initial_directory       =
*      multiselection          =
    CHANGING
      file_table              = tl_file_table
      rc                      = vl_rc
*      user_action             =
*      file_encoding           =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      others                  = 5
  ).
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    READ TABLE tl_file_table INTO p_arq INDEX 1.
  ENDIF.

ENDFORM.



FORM zf_filtro.
  DELETE tg_alv_detal  WHERE bukrs NOT IN s_bukrs
  OR    branch      NOT IN s_branch
  OR    nro         NOT IN s_nro
  OR    data_venda  NOT IN s_dats
  OR    kunnr       NOT IN s_kunnr.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form zf_alv
*&---------------------------------------------------------------------*
FORM zf_alv_detal.
  DATA: tl_fldcat TYPE slis_t_fieldcat_alv,
        wl_fldcat TYPE slis_fieldcat_alv,
        wl_layout TYPE slis_layout_alv.

  wl_layout-zebra = 'X'.
  wl_layout-colwidth_optimize = 'X'.
  wl_layout-window_titlebar = 'Relatório Detalhado'.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'NRO'.
  wl_fldcat-seltext_s = 'N Ped'.
  wl_fldcat-seltext_m = 'N Pedido'.
  wl_fldcat-seltext_l = 'Numero do Pedido'.
  wl_fldcat-key       = 'X'.
  wl_fldcat-no_zero   = 'X'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'ITEM'.
  wl_fldcat-seltext_s = 'Item'.
  wl_fldcat-seltext_m = 'Item'.
  wl_fldcat-seltext_l = 'Item'.
  wl_fldcat-key       = 'X'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'MATNR'.
  wl_fldcat-rollname  = 'MATNR'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'MAKTX'.
  wl_fldcat-rollname  = 'MAKTX'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'DATA_VENDA'.
  wl_fldcat-seltext_s = 'Dt.Ve'.
  wl_fldcat-seltext_m = 'Data  venda'.
  wl_fldcat-seltext_l = 'Data de venda'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'BUKRS'.
  wl_fldcat-rollname  = 'BUKRS'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'BRANCH'.
  wl_fldcat-rollname  = 'J_1BBRANC_'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'KUNNR'.
  wl_fldcat-rollname  = 'KUNNR'.
  wl_fldcat-no_zero   = 'X'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'VALOR'.
  wl_fldcat-seltext_s = 'Valor'.
  wl_fldcat-seltext_m = 'Valor'.
  wl_fldcat-seltext_l = 'Valor'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'UNV'.
  wl_fldcat-seltext_s = 'Uni.vend'.
  wl_fldcat-seltext_m = 'Unid.vend'.
  wl_fldcat-seltext_l = 'Unidade de venda'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'qtd'.
  wl_fldcat-seltext_s = 'Qtd'.
  wl_fldcat-seltext_m = 'Qtd'.
  wl_fldcat-seltext_l = 'Quantidade'.
  APPEND wl_fldcat TO tl_fldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'ZF_PF_STATUS'
      i_callback_user_command  = 'ZF_USER_COMMAND'
      it_fieldcat              = tl_fldcat
      is_layout                = wl_layout
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab                 = tg_alv_detal.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form zf_alv_bukrs
*&---------------------------------------------------------------------*
FORM zf_alv_filial .
  DATA: tl_fldcat TYPE slis_t_fieldcat_alv,
        wl_fldcat TYPE slis_fieldcat_alv,
        wl_layout TYPE slis_layout_alv.

  PERFORM zf_collection.

  wl_layout-zebra = 'X'.
  wl_layout-colwidth_optimize = 'X'.
  wl_layout-window_titlebar = 'Relatório de Empresas'.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname     = 'BUKRS'.
  wl_fldcat-rollname      = 'BUKRS'.
  wl_fldcat-tabname       = 'tg_alv_filial'.
  wl_fldcat-ref_tabname   = 'ZTT0MOURAG_TM_V'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'BRANCH'.
  wl_fldcat-rollname  = 'BRANCH'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'VALOR'.
  wl_fldcat-seltext_s = 'VALOR'.
  wl_fldcat-seltext_m = 'Vl.vend'.
  wl_fldcat-seltext_l = 'Valor da venda'.
  wl_fldcat-do_sum    = 'X'.
  APPEND wl_fldcat TO tl_fldcat.



  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat = tl_fldcat
      is_layout   = wl_layout
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab    = tg_alv_filial.
ENDFORM.

FORM zf_alv_matnr .
  DATA: tl_fldcat TYPE slis_t_fieldcat_alv,
        wl_fldcat TYPE slis_fieldcat_alv,
        wl_layout TYPE slis_layout_alv.

  PERFORM zf_collection.

  wl_layout-zebra = 'X'.
  wl_layout-colwidth_optimize = 'X'.
  wl_layout-window_titlebar = 'Relatório de Materiais'.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname     = 'MATNR'.
  wl_fldcat-rollname      = 'MATNR'.
  wl_fldcat-tabname       = 'TG_ALV_MATNR'.
  wl_fldcat-ref_tabname   = 'ZTT0MOURAG_TM_V'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'MAKTX'.
  wl_fldcat-rollname  = 'MAKTX'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'VALOR'.
  wl_fldcat-seltext_s = 'Valor'.
  wl_fldcat-seltext_m = 'Valor'.
  wl_fldcat-seltext_l = 'Valor'.
  wl_fldcat-do_sum    = 'X'.
  APPEND wl_fldcat TO tl_fldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     i_callback_program       = sy-repid
*     i_callback_pf_status_set = 'ZF_PF_STATUS'
*     i_callback_user_command  = 'ZF_USER_COMMAND'
      it_fieldcat = tl_fldcat
      is_layout   = wl_layout
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab    = tg_alv_matnr.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form zf_alv_kunnr
*&---------------------------------------------------------------------*
FORM zf_alv_kunnr.
  DATA: tl_fldcat TYPE slis_t_fieldcat_alv,
        wl_fldcat TYPE slis_fieldcat_alv,
        wl_layout TYPE slis_layout_alv.

  PERFORM zf_collection.

  wl_layout-zebra = 'X'.
  wl_layout-colwidth_optimize = 'X'.
  wl_layout-window_titlebar = 'Relatório de Clientes'.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname     = 'KUNNR'.
  wl_fldcat-rollname      = 'KUNNR'.
  wl_fldcat-tabname       = 'TG_ALV_KUNNR'.
  wl_fldcat-ref_tabname   = 'ZTT0MOURAG_TM_V'.
  wl_fldcat-no_zero       = 'X'.
  APPEND wl_fldcat TO tl_fldcat.

  CLEAR wl_fldcat.
  wl_fldcat-fieldname = 'VALOR'.
  wl_fldcat-seltext_s = 'Valor'.
  wl_fldcat-seltext_m = 'Valor'.
  wl_fldcat-seltext_l = 'Valor'.
  wl_fldcat-do_sum    = 'X'.
  APPEND wl_fldcat TO tl_fldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     i_callback_program       = sy-repid
*     i_callback_pf_status_set = 'ZF_PF_STATUS'
*     i_callback_user_command  = 'ZF_USER_COMMAND'
      it_fieldcat = tl_fldcat
      is_layout   = wl_layout
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab    = tg_alv_kunnr.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form collect
*&---------------------------------------------------------------------*
FORM zf_collection.

  DATA: wl_alv_filial TYPE ty_s_alv_filial,
        wl_alv_matnr  TYPE ty_s_alv_matnr,
        wl_alv_kunnr  TYPE ty_s_alv_kunnr.

  CASE 'X'.
    WHEN p_bukrs.
      LOOP AT tg_alv_detal ASSIGNING FIELD-SYMBOL(<vd>).
        CLEAR wl_alv_filial.
        wl_alv_filial-bukrs  = <vd>-bukrs.
        wl_alv_filial-branch = <vd>-branch.
        wl_alv_filial-valor  = <vd>-valor.
        COLLECT wl_alv_filial INTO tg_alv_filial.
      ENDLOOP.
    WHEN p_matnr.
      LOOP AT tg_alv_detal ASSIGNING <vd>.
        CLEAR wl_alv_matnr.
        wl_alv_matnr-matnr = <vd>-matnr.
        wl_alv_matnr-maktx = <vd>-maktx.
        wl_alv_matnr-valor = <vd>-valor.
        COLLECT wl_alv_matnr INTO tg_alv_matnr.
      ENDLOOP.
    WHEN p_kunnr.
      LOOP AT tg_alv_detal ASSIGNING <vd>.
        CLEAR wl_alv_kunnr.
        wl_alv_kunnr-kunnr = <vd>-kunnr.
        wl_alv_kunnr-valor = <vd>-valor.
        COLLECT wl_alv_kunnr INTO tg_alv_kunnr.
      ENDLOOP.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ZF_PF_STATUS
*&---------------------------------------------------------------------*
FORM zf_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'PF_STATUS_ARQUIVOS'.
ENDFORM.
*--------------------------------------------------------------------*
* Form ZF_USER_COMMAND
*--------------------------------------------------------------------*
FORM zf_user_command USING ucomm TYPE sy-ucomm selfield TYPE kkblo_selfield.
  DATA: tl_vend      TYPE TABLE OF ztt0mourag_tm_v,
        wl_vend      TYPE ztt0mourag_tm_v,
        wl_alv_detal TYPE ty_s_alv_detal,
        msg          TYPE string,
        vl_answer    TYPE c.

  CASE ucomm.
    WHEN 'SAVE'.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          text_question         = 'Deseja gravar todos os dados?'
          text_button_1         = 'Sim'
          text_button_2         = 'Não'
          display_cancel_button = ''
        IMPORTING
          answer                = vl_answer.

      CASE vl_answer.
        WHEN 1.
          LOOP AT tg_alv_detal INTO wl_alv_detal.
            wl_vend-nro        = wl_alv_detal-nro.
            wl_vend-item       = wl_alv_detal-item.
            wl_vend-matnr      = wl_alv_detal-matnr.
            wl_vend-maktx      = wl_alv_detal-maktx.
            wl_vend-data_venda = wl_alv_detal-data_venda.
            wl_vend-bukrs       = wl_alv_detal-bukrs.
            wl_vend-branch      = wl_alv_detal-branch.
            wl_vend-kunnr      = wl_alv_detal-kunnr.
            wl_vend-valor      = wl_alv_detal-valor.
            wl_vend-unv        = wl_alv_detal-unv.
            wl_vend-qtd        = wl_alv_detal-qtd.
            APPEND wl_vend TO tl_vend.
*
          ENDLOOP.

          IF tl_vend[] IS NOT INITIAL.
            TRY.
                INSERT ztt0mourag_tm_v FROM TABLE tl_vend.
                IF sy-subrc = 0.
                  COMMIT WORK.
                  msg = |{ sy-dbcnt }  Inseridas  |.
                  MESSAGE msg TYPE 'S'.
                ENDIF.
              CATCH cx_sy_open_sql_db.
                MESSAGE 'Erro, Linhas duplicadas.' TYPE 'I' DISPLAY LIKE 'E'.
            ENDTRY.
          ENDIF.
        WHEN 2.
          MESSAGE 'Gravação Cancelada.' TYPE 'S' DISPLAY LIKE 'W'.
      ENDCASE.

  ENDCASE.
ENDFORM.