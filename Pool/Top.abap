
*& Include          ZTT0MOURAG_I_V2_TOP
*&---------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_scr_9101,
    ativo         TYPE c LENGTH 1,
    md            TYPE c LENGTH 1,
    data_fixa     TYPE c LENGTH 1,
    data          TYPE d,
    data_dinamica TYPE c LENGTH 1,
  END OF ty_scr_9101.

  DATA: scr_9101 TYPE ty_scr_9101.

CONTROLS: Control_tab TYPE TABSTRIP.


*--------------------------------------------------------------------*
* Tabela Interna                                                     *
*--------------------------------------------------------------------*
DATA: tg_par      TYPE TABLE OF ztbsicorc_sp_par,
      tg_md      TYPE TABLE OF ztbsicorc_md_seq,
      tg_app     TYPE TABLE OF ztbsicorc_app_sq.

*--------------------------------------------------------------------*
* Variáveis Globais                                                  *
*--------------------------------------------------------------------*
DATA: vg_ok_code  TYPE sy-ucomm,
      vg_screen   TYPE c LENGTH 4 VALUE '9001'.


*--------------------------------------------------------------------*
* Definição de Classes                                               *
*--------------------------------------------------------------------*
CLASS lcl_handler_tree_9000 DEFINITION.

  PUBLIC SECTION.

    METHODS: node_double_click FOR EVENT node_double_click OF cl_simple_tree_model
      IMPORTING
        node_key.

ENDCLASS.

CLASS lcl_handler_button DEFINITION.

  PUBLIC SECTION.

    METHODS:
      on_toolbar      FOR EVENT toolbar      OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,

      on_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm sender.

ENDCLASS.


*--------------------------------------------------------------------*
* Objetos Globais                                                    *
*--------------------------------------------------------------------*
DATA: o_cont_9000         TYPE REF TO cl_gui_custom_container,
      o_tree_9000         TYPE REF TO cl_simple_tree_model,
      o_handler_tree_9000 TYPE REF TO lcl_handler_tree_9000,
      o_cont_9100         TYPE REF TO cl_gui_custom_container,
      o_alv_9100          TYPE REF TO cl_gui_alv_grid,
     o_handler_button      TYPE REF TO lcl_handler_button.


DATA: o_cont_md_9201   TYPE REF TO cl_gui_custom_container,
      o_alv_md_9201    TYPE REF TO cl_gui_alv_grid,
      O_cont_app_9202   TYPE REF TO cl_gui_custom_container,
     o_alv_app_9202  TYPE REF TO cl_gui_alv_grid.