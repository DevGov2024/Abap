*&---------------------------------------------------------------------*
*& Report ZTT0MOURAG_R_ARQUIVOS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztt0mourag_r_arquivos.

"  Existe um recurso muito utilizado que se chama 'Table control que serve
" pra mostra e edita dados de uma tabela dentro de uma tela, o 'Table control
" e tipo um quadro adicionado no 'Screen Painter ( akele botão chamado
" layout que fica do lado do 'pretty Printer na tela que vc tá mexendo ),
" para trabalhar com ela eh muito simples,

"Um Module Pool é um tipo de programa ABAP usado para criar aplicações interativas com telas personalizadas. Ele é diferente de um relatório (REPORT) porque é voltado para interfaces gráficas, onde o usuário interage com campos, botões, radiobuttons,
"listas, etc.
"

*OK_CODE é uma variável de controle usada em programas de Module Pool para capturar qual ação o usuário executou na tela, como:
*
*Clicar em um botão
*Pressionar Enter
*Selecionar uma função do menu
*Usar uma tecla de função (F1, F2, etc.)]


"  Include TOP - serve pra vc coloca todas as declarações que será usado no
" programa como variáveis, tipos, estrutura, tabelas internas, constantes etc.
"  Include PBO - Serão armazenados todos os Modules PBO que são todas as
" rotinas para a preparação das informações e/ou elementos da tela antes
" da sua exibição.
"  Include PAI - Serão armazenados todos os Modules PAI que são todas as
" rotinas de tratamento das ações ( comando do usuário ) que foram
" executados na tela.
" Include Performs - Onde vai fika todos os performs que vc cria.

TYPES:
  BEGIN OF ty_s_alv,
    sel      TYPE c,
    vbeln    TYPE vbak-vbeln, "Arquivo
    posnr    TYPE vbap-posnr, "Arquivo
    matnr    TYPE c LENGTH 18, "Arquivo
    maktx    TYPE makt-maktx, "Tabela Transparente MAKT
    menge    TYPE vbap-zmeng, "Arquivo
    meins    TYPE vbap-meins, "Arquivo
    vlr_tot  TYPE p LENGTH 8 DECIMALS 2, "Tabela Transparente
    vlr_unit TYPE p LENGTH 8 DECIMALS 2, "Tabela Transparente
    kunnr    TYPE kna1-kunnr, "Arquivo
    name1    TYPE kna1-name1, "Tabela Transparente KNA1
  END OF ty_s_alv.

TYPES: ty_t_alv  TYPE STANDARD TABLE OF ty_s_alv WITH NON-UNIQUE KEY vbeln posnr.

TYPES:
  BEGIN OF ty_scr_0101,
    arquivo  TYPE string,
    servidor TYPE c LENGTH 1,
    usuario  TYPE c LENGTH 1,
  END OF ty_scr_0101.



DATA: tg_alv TYPE ty_t_alv.



DATA: wg_vari   TYPE disvariant.

DATA: scr_0101 TYPE ty_scr_0101.


DATA: vg_ok_code  TYPE sy-ucomm.



SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.

  PARAMETERS: p_arq TYPE string LOWER CASE OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b01.
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.

  PARAMETERS: p_vari TYPE slis_vari LOWER CASE.

SELECTION-SCREEN END OF BLOCK b02.



AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_arq.

  PERFORM zf_f4_arquivo USING p_arq.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.

  PERFORM zf_f4_vari USING p_vari.



START-OF-SELECTION.

  PERFORM zf_processa_arquivo.

  PERFORM zf_apresenta_alv.


FORM zf_f4_arquivo  USING p_v_arq TYPE string.

  DATA: tl_file_table TYPE filetable.

  DATA: vl_rc TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
*    EXPORTING
*      window_title            =                  " Title Of File Open Dialog
*      default_extension       =                  " Default Extension
*      default_filename        =                  " Default File Name
*      file_filter             =                  " File Extension Filter String
*      with_encoding           =                  " File Encoding
*      initial_directory       =                  " Initial Directory
*      multiselection          =                  " Multiple selections poss.
    CHANGING
      file_table              = tl_file_table
      rc                      = vl_rc
*      user_action             =                  " User Action (See Class Constants ACTION_OK, ACTION_CANCEL)
*      file_encoding           =
    EXCEPTIONS
      file_open_dialog_failed = 1                " "Open File" dialog failed
      cntl_error              = 2                " Control error
      error_no_gui            = 3                " No GUI available
      not_supported_by_gui    = 4                " GUI does not support this
      OTHERS                  = 5
  ).

  IF sy-subrc EQ 0.
    READ TABLE tl_file_table INTO p_v_arq INDEX 1.
  ENDIF.

ENDFORM.

FORM zf_processa_arquivo .

  DATA: tl_arquivo TYPE TABLE OF string,
        tl_split   TYPE TABLE OF string.

  DATA: wl_alv  TYPE ty_s_alv.

  DATA: vl_linha TYPE string,
        vl_split TYPE string,
        vl_menge TYPE menge_d,
        vl_meins TYPE meins.

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
      dp_timeout              = 16.

  DELETE tl_arquivo INDEX 1.

  SELECT *
    FROM a118
    INTO TABLE @DATA(tl_a118).

  IF tl_a118[] IS NOT INITIAL.
    SELECT knumh, kbetr, kpein, kmein
      FROM konp
      INTO TABLE @DATA(tl_konp)
      FOR ALL ENTRIES IN @tl_a118
        WHERE knumh EQ @tl_a118-knumh.

    SELECT matnr, meinh, umrez, umren
      FROM marm
      INTO TABLE @DATA(tl_marm)
      FOR ALL ENTRIES IN @tl_a118
        WHERE matnr EQ @tl_a118-matnr.

  ENDIF.

  SORT tl_a118 BY matnr.
  SORT tl_marm BY matnr meinh.
  SORT tl_konp BY knumh.

  LOOP AT tl_arquivo INTO vl_linha.

    IF sy-tabix EQ 1.
      CONTINUE.
    ENDIF.

    SPLIT vl_linha AT ';' INTO TABLE tl_split.

    READ TABLE tl_split INTO vl_split INDEX 1.
    wl_alv-vbeln = vl_split.

    wl_alv-vbeln = tl_split[ 1 ].
    wl_alv-posnr = tl_split[ 2 ].

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = tl_split[ 3 ]
      IMPORTING
        output = wl_alv-matnr.

    SELECT SINGLE maktx
      FROM makt
      INTO wl_alv-maktx
        WHERE matnr EQ wl_alv-matnr.

    vl_split = tl_split[ 4 ].
    TRANSLATE vl_split USING '. '.
    TRANSLATE vl_split USING ',.'.
    CONDENSE vl_split NO-GAPS.

    wl_alv-menge = vl_split.
    wl_alv-meins = tl_split[ 5 ].

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = tl_split[ 6 ]
      IMPORTING
        output = wl_alv-kunnr.

    SELECT SINGLE name1
      FROM kna1
      INTO wl_alv-name1
        WHERE kunnr EQ wl_alv-kunnr.

    READ TABLE tl_a118 INTO DATA(wl_a118) WITH KEY matnr = wl_alv-matnr
                                                   BINARY SEARCH.
    IF sy-subrc EQ 0.
      READ TABLE tl_konp  INTO DATA(wl_konp) WITH KEY knumh = wl_a118-knumh
                                                      BINARY SEARCH.
      IF sy-subrc EQ 0.

        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
          EXPORTING
            input  = wl_alv-meins
          IMPORTING
            output = vl_meins
          EXCEPTIONS
            OTHERS = 1.

        READ TABLE tl_marm INTO DATA(wl_marm) WITH KEY matnr = wl_alv-matnr
                                                       meinh = vl_meins
                                                       BINARY SEARCH.
        IF sy-subrc EQ 0.
          IF wl_marm-umrez NE 1.
            vl_menge = wl_alv-menge * wl_marm-umrez.
          ELSE.
            vl_menge = wl_alv-menge.
          ENDIF.
        ENDIF.

        wl_alv-vlr_tot  = vl_menge * wl_konp-kbetr.
        wl_alv-vlr_unit = wl_konp-kbetr / wl_konp-kpein.

      ENDIF.
    ENDIF.

    APPEND wl_alv TO tg_alv.

  ENDLOOP.

ENDFORM.

FORM zf_apresenta_alv .

  DATA: tl_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: wl_layout TYPE slis_layout_alv.

  PERFORM zf_gera_fieldcat  USING tl_fieldcat.
  PERFORM zf_define_layout  USING wl_layout.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat              = tl_fieldcat
      is_layout                = wl_layout
      i_save                   = 'A'
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'ZF_PF_STATUS'
      i_callback_user_command  = 'ZF_USER_COMMAND'
      is_variant               = wg_vari
    TABLES
      t_outtab                 = tg_alv.

ENDFORM.

FORM zf_pf_status USING rt_extab  TYPE slis_t_extab.

  SET PF-STATUS 'PF_STATUS_ARQUIVO'.

ENDFORM.

FORM zf_user_command  USING r_ucomm     LIKE sy-ucomm
                            rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN 'EXPORT'.
      CALL SCREEN '0101' STARTING AT 10 10.
  ENDCASE.

ENDFORM.


FORM zf_define_layout  USING p_w_layout TYPE slis_layout_alv.

  p_w_layout-colwidth_optimize  = 'X'.
  p_w_layout-zebra              = 'X'.
  p_w_layout-box_fieldname      = 'SEL'.

ENDFORM.

FORM zf_gera_fieldcat  USING  p_t_fieldcat TYPE slis_t_fieldcat_alv.




  DATA: wl_fieldcat TYPE slis_fieldcat_alv.

  wl_fieldcat-fieldname = 'VBELN'.
  wl_fieldcat-rollname  = 'VBELN_VA'.
  wl_fieldcat-key       = 'X'.
  APPEND wl_fieldcat TO p_t_fieldcat.
  CLEAR: wl_fieldcat.

  wl_fieldcat-fieldname = 'POSNR'.
  wl_fieldcat-rollname  = 'POSNR_VA'.
  wl_fieldcat-key       = 'X'.
  APPEND wl_fieldcat TO p_t_fieldcat.
  CLEAR: wl_fieldcat.

  wl_fieldcat-fieldname = 'MATNR'.
  wl_fieldcat-rollname  = 'MATNR'.
  wl_fieldcat-no_zero   = 'X'.
  APPEND wl_fieldcat TO p_t_fieldcat.
  CLEAR: wl_fieldcat.

  wl_fieldcat-fieldname = 'MAKTX'.
  wl_fieldcat-rollname  = 'MAKTX'.
  APPEND wl_fieldcat TO p_t_fieldcat.
  CLEAR: wl_fieldcat.

  wl_fieldcat-fieldname = 'MENGE'.
  wl_fieldcat-do_sum    = 'X'.
  wl_fieldcat-rollname  = 'MENGE_D'.
  APPEND wl_fieldcat TO p_t_fieldcat.
  CLEAR: wl_fieldcat.

  wl_fieldcat-fieldname = 'MEINS'.
  wl_fieldcat-rollname  = 'MEINS'.
  APPEND wl_fieldcat TO p_t_fieldcat.
  CLEAR: wl_fieldcat.

  wl_fieldcat-fieldname = 'VLR_TOT'.
  wl_fieldcat-seltext_s = 'Vlr.Tot.'.
  wl_fieldcat-seltext_m = 'Valor Tot.'.
  wl_fieldcat-seltext_l = 'Valor Total'.
  APPEND wl_fieldcat TO p_t_fieldcat.
  CLEAR: wl_fieldcat.

  wl_fieldcat-fieldname = 'VLR_UNIT'.
  wl_fieldcat-seltext_s = 'Vlr.Unit.'.
  wl_fieldcat-seltext_m = 'Valor Unit.'.
  wl_fieldcat-seltext_l = 'Valor Unitário'.
  APPEND wl_fieldcat TO p_t_fieldcat.
  CLEAR: wl_fieldcat.

  wl_fieldcat-fieldname = 'KUNNR'.
  wl_fieldcat-no_zero   = 'X'.
  wl_fieldcat-rollname  = 'KUNNR'.
  APPEND wl_fieldcat TO p_t_fieldcat.
  CLEAR: wl_fieldcat.

  wl_fieldcat-fieldname = 'NAME1'.
  wl_fieldcat-rollname  = 'NAME1_GP'.
  wl_fieldcat-no_zero   = 'X'.
  APPEND wl_fieldcat TO p_t_fieldcat.
  CLEAR: wl_fieldcat.

ENDFORM.

FORM zf_f4_vari  USING p_vari TYPE slis_vari.

  wg_vari-report = sy-repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant    = wg_vari
      i_save        = 'A'
    IMPORTING
      es_variant    = wg_vari
    EXCEPTIONS
      not_found     = 1
      program_error = 2
      OTHERS        = 3.

  p_vari = wg_vari-variant.

ENDFORM.

MODULE status_0101 OUTPUT.

  SET PF-STATUS 'STATUS_0101'.
  SET TITLEBAR 'TITLE_0101'.

ENDMODULE.



MODULE user_command_0101 INPUT.
      DATA: tl_csv TYPE STANDARD TABLE OF string.
      DATA: wl_csv TYPE string.
      FIELD-SYMBOLS: <alv> TYPE ty_s_alv.

  CASE vg_ok_code.
    WHEN 'BACK' OR 'END' OR 'CANCEL' OR 'EXIT' OR 'Cancel'.
      LEAVE TO SCREEN 0.
    WHEN 'ENTER'.
      CASE 'X'.
        WHEN scr_0101-servidor.
          CLEAR tl_csv.
          CLEAR wl_csv.
          UNASSIGN <alv>.
          APPEND 'Sales Doc.;Item;Material;MaterialDescription;Target Qty;BUn;Valor Total;Vlr.Unit.;Customer;Name1'
          TO tl_csv.

          LOOP AT tg_alv ASSIGNING <alv>.
            wl_csv = |{ <alv>-vbeln };{ <alv>-posnr };{ <alv>-matnr };{ <alv>-maktx };{ <alv>-menge };{ <alv>-meins };{ <alv>-vlr_tot };{ <alv>-vlr_unit };{ <alv>-kunnr };{ <alv>-name1 }|.

            APPEND wl_csv TO tl_csv.
          ENDLOOP.


          IF scr_0101-arquivo NS '.csv' AND scr_0101-arquivo NS '.txt'.
            MESSAGE: 'Caminho precisa terminar em .csv ou .txt' TYPE 'I'.
            EXIT.
          ENDIF.


          IF scr_0101-arquivo CS 'C:\'.
            MESSAGE: 'Apenas diretórios UNIX são permitidos'
            TYPE 'I'.
            EXIT.
          ENDIF.


          IF scr_0101-arquivo NS '/usr/sap/trans/'.
            MESSAGE: 'Local precisa ser dentro do diretório usr > sap > trans'
            TYPE 'I'.
            EXIT.
          ENDIF.

          TRANSLATE scr_0101-arquivo TO LOWER CASE.

          OPEN DATASET scr_0101-arquivo FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

          IF sy-subrc EQ 0.
            LOOP AT tl_csv ASSIGNING FIELD-SYMBOL(<csv>).
              TRANSFER <csv> TO scr_0101-arquivo.
            ENDLOOP.

          ELSE.
            MESSAGE: 'Erro no OPEN DATASET' TYPE 'I' DISPLAY LIKE 'E'.
            EXIT.
          ENDIF.

          CLOSE DATASET scr_0101-arquivo.
          MESSAGE: 'File created successfully' TYPE 'S'.



            WHEN scr_0101-usuario.
          CLEAR tl_csv.
          CLEAR wl_csv.
          UNASSIGN <alv>.

          IF scr_0101-arquivo NS '.csv' AND scr_0101-arquivo NS '.txt'.
            MESSAGE: 'Caminho precisa terminar em .csv ou .txt' TYPE 'I'.
            EXIT.
          ENDIF.


          IF scr_0101-arquivo NS 'C:\'.
            MESSAGE: 'Diretório inválido para download' TYPE 'I'.
            EXIT.
          ENDIF.

           APPEND 'Sales Doc.;Item;Material;MaterialDescription;Target Qty;BUn;Valor Total;Vlr.Unit.;Customer;Name1'
          TO tl_csv.

          LOOP AT tg_alv ASSIGNING <alv>.
            wl_csv = |{ <alv>-vbeln };{ <alv>-posnr };{ <alv>-matnr };{ <alv>-maktx };{ <alv>-menge };{ <alv>-meins };{ <alv>-vlr_tot };{ <alv>-vlr_unit };{ <alv>-kunnr };{ <alv>-name1 }|.

            APPEND wl_csv TO tl_csv.
          ENDLOOP.

          CALL FUNCTION 'GUI_DOWNLOAD'
            EXPORTING
              filename                = scr_0101-arquivo
            TABLES
              data_tab                = tl_csv
            EXCEPTIONS
              file_write_error        = 1
              no_batch                = 2
              gui_refuse_filetransfer = 3
              invalid_type            = 4
              no_authority            = 5
              unknown_error           = 6
              header_not_allowed      = 7
              separator_not_allowed   = 8
              filesize_not_allowed    = 9
              header_too_long         = 10
              dp_error_create         = 11
              dp_error_send           = 12
              dp_error_write          = 13
              unknown_dp_error        = 14
              access_denied           = 15
              dp_out_of_memory        = 16
              disk_full               = 17
              dp_timeout              = 18
              file_not_found          = 19
              dataprovider_exception  = 20
              control_flush_error     = 21
              OTHERS                  = 22.
          IF sy-subrc <> 0.
            MESSAGE: 'ERROR IN GUI DOWNLOAD. TRY AGAIN' TYPE 'I' DISPLAY LIKE 'E'.
            EXIT.
          ENDIF.

          LEAVE TO SCREEN 0.
      ENDCASE.
  ENDCASE.

      CLEAR vg_ok_code.

ENDMODULE.



FORM zf_server .

  DATA: vl_directory TYPE string,
        vl_CSV      TYPE string,
        vl_full      TYPE string.

  vl_csv = |{ sy-uname }_{ sy-datum }_{ sy-uzeit }.csv|.

  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    EXPORTING
      directory        = '/usr/sap/trans/tmp/'
    IMPORTING
      serverfile       = vl_directory
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE: 'Error IN  F4_SERVER_FILE' TYPE 'I' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CONCATENATE vl_directory vl_csv INTO vl_full.

  scr_0101-arquivo = vl_full.

ENDFORM.




FORM zf_f4_0101_user  USING p_scr_0101_arquivo.

  DATA: vl_directory TYPE string,
        vl_csv      TYPE string,
        vl_full      TYPE string.

  vl_csv = |{ sy-uname }_{ sy-datum }_{ sy-uzeit }.csv|.

  cl_gui_frontend_services=>directory_browse(
    EXPORTING
      window_title    = 'Escolha somente um diretório'
    CHANGING
      selected_folder = vl_directory
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4
  ).

  IF sy-subrc <> 0.
    MESSAGE 'Error' TYPE 'I' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  vl_directory = vl_directory && '\'.

  CONCATENATE vl_directory vl_csv INTO vl_full.

  scr_0101-arquivo = vl_full.

ENDFORM.


MODULE f4_arquivo INPUT.

  IF scr_0101-servidor = 'X'.

    PERFORM zf_server.
  ELSEIF scr_0101-usuario = 'X'.

    PERFORM zf_f4_0101_user USING scr_0101-arquivo.
  ENDIF.

ENDMODULE.

MODULE radiobutton OUTPUT.
  IF scr_0101-servidor EQ '' AND scr_0101-usuario EQ ''.
    scr_0101-servidor = 'X'.
  ENDIF.
ENDMODULE..