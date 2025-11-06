REPORT ZTT0MOURAG_R_PARTNER.

--------------------------------------------------------------------

Tipos Internos *
--------------------------------------------------------------------
TABLES: but000, lfa1, kna1. " Vou utilizar na referência de SELECT-OPTIONS
TYPES:
BEGIN OF ty_s_but000,
partner TYPE but000-partner,
partner_guid TYPE but000-partner_guid,
END OF ty_s_but000.

TYPES: ty_t_but000 TYPE SORTED TABLE OF ty_s_but000 WITH UNIQUE KEY partner.

TYPES:
BEGIN OF ty_s_lfa1,
lifnr TYPE lfa1-lifnr,
name1 TYPE lfa1-name1,
END OF ty_s_lfa1.

TYPES: ty_t_lfa1 TYPE SORTED TABLE OF ty_s_lfa1 WITH UNIQUE KEY lifnr.

TYPES:
BEGIN OF ty_s_vend_link,
partner_guid TYPE cvi_vend_link-partner_guid,
lifnr TYPE cvi_vend_link-vendor,
END OF ty_s_vend_link.

TYPES: ty_t_vend_link TYPE SORTED TABLE OF ty_s_vend_link WITH UNIQUE KEY partner_guid.

TYPES:
BEGIN OF ty_s_kna1,
kunnr TYPE kna1-kunnr,
name1 TYPE kna1-name1,
END OF ty_s_kna1.

TYPES: ty_t_kna1 TYPE SORTED TABLE OF ty_s_kna1 WITH UNIQUE KEY kunnr.

TYPES:
BEGIN OF ty_s_cust_link,
partner_guid TYPE cvi_cust_link-partner_guid,
kunnr TYPE cvi_cust_link-customer,
END OF ty_s_cust_link.

TYPES: ty_t_cust_link TYPE SORTED TABLE OF ty_s_cust_link WITH UNIQUE KEY partner_guid.

TYPES:
BEGIN OF ty_s_alv,
partner TYPE but000-partner,
status TYPE icon_d,
kunnr TYPE kna1-kunnr,
namek TYPE kna1-name1,
kn_land1 TYPE kna1-land1,
kn_ort01 TYPE kna1-ort01,
kn_pstlz TYPE kna1-pstlz,
kn_sortl TYPE kna1-sortl,
kn_regio TYPE kna1-regio,
kn_stras TYPE kna1-stras,
kn_mcod1 TYPE kna1-mcod1,
kn_mcod3 TYPE kna1-mcod3,
kn_smtp_addr TYPE adr6-smtp_addr,
lifnr TYPE lfa1-lifnr,
namel TYPE lfa1-name1,
lf_land1 TYPE lfa1-land1,
lf_ort01 TYPE lfa1-ort01,
lf_pstlz TYPE lfa1-pstlz,
lf_sortl TYPE lfa1-sortl,
lf_regio TYPE lfa1-regio,
lf_stras TYPE lfa1-stras,
lf_mcod1 TYPE lfa1-mcod1,
lf_mcod3 TYPE lfa1-mcod3,
lf_smtp_addr TYPE adr6-smtp_addr,
END OF ty_s_alv.

TYPES: ty_t_alv TYPE STANDARD TABLE OF ty_s_alv WITH DEFAULT KEY.

--------------------------------------------------------------------

Tabelas Internas Globais *
--------------------------------------------------------------------
DATA: tg_alv TYPE ty_t_alv.
--------------------------------------------------------------------

Tela de Seleção *
--------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.

SELECT-OPTIONS: s_part FOR but000-partner NO INTERVALS,
s_lifnr FOR lfa1-lifnr NO INTERVALS,
s_kunnr FOR kna1-kunnr NO INTERVALS.

SELECTION-SCREEN END OF BLOCK b01.
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.

PARAMETERS: p_but RADIOBUTTON GROUP grp1,
p_lfa1 RADIOBUTTON GROUP grp1,
p_kna1 RADIOBUTTON GROUP grp1.

SELECTION-SCREEN END OF BLOCK b02.

--------------------------------------------------------------------

Eventos de Execução *
--------------------------------------------------------------------
START-OF-SELECTION.

CASE 'X'.
WHEN p_but.
PERFORM zf_monta_alv_bp.
WHEN p_lfa1.

 PERFORM zf_monta_alv_lfa1.
WHEN p_kna1.

 PERFORM zf_monta_alv_kna1.
ENDCASE.

PERFORM zf_apresenta_alv.

&---------------------------------------------------------------------
*& Form zf_monta_alv_bp
&---------------------------------------------------------------------
*& text
&---------------------------------------------------------------------
*& --> p1 text
*& <-- p2 text
&---------------------------------------------------------------------
FORM zf_monta_alv_bp .

DATA: tl_but000 TYPE ty_t_but000,
tl_vend_link TYPE ty_t_vend_link,
tl_lfa1 TYPE ty_t_lfa1,
tl_cust_link TYPE ty_t_cust_link,
tl_kna1 TYPE ty_t_kna1.

DATA: wl_alv TYPE ty_s_alv.

FIELD-SYMBOLS: TYPE ty_s_but000,
<vend_link> TYPE ty_s_vend_link,
TYPE ty_s_lfa1,
<cust_link> TYPE ty_s_cust_link,
TYPE ty_s_kna1.

IF s_lifnr[] IS NOT INITIAL.
SELECT partner_guid
 FROM cvi_vend_link
 INTO TABLE @DATA(tl_fil_vend)
   WHERE vendor IN @s_lifnr.
ENDIF.
IF s_kunnr[] IS NOT INITIAL.
SELECT partner_guid
 FROM cvi_cust_link
 APPENDING TABLE tl_fil_vend
   WHERE customer IN s_kunnr.
ENDIF.
SELECT partner partner_guid
FROM but000
INTO TABLE tl_but000

FOR ALL ENTRIES IN tl_fil_vend
WHERE partner IN s_part.

   AND partner_guid EQ tl_fil_vend-partner_guid.
IF tl_but000[] IS NOT INITIAL.
SELECT partner_guid vendor
FROM cvi_vend_link
INTO TABLE tl_vend_link
FOR ALL ENTRIES IN tl_but000
WHERE partner_guid EQ tl_but000-partner_guid
AND vendor IN s_lifnr.

IF tl_vend_link[] IS NOT INITIAL.
SELECT lifnr name1
FROM lfa1
INTO TABLE tl_lfa1
FOR ALL ENTRIES IN tl_vend_link
WHERE lifnr EQ tl_vend_link-lifnr.
ENDIF.

SELECT partner_guid customer
FROM cvi_cust_link
INTO TABLE tl_cust_link
FOR ALL ENTRIES IN tl_but000
WHERE partner_guid EQ tl_but000-partner_guid
AND customer IN s_kunnr.

IF tl_cust_link[] IS NOT INITIAL.
SELECT kunnr name1
FROM kna1
INTO TABLE tl_kna1
FOR ALL ENTRIES IN tl_cust_link
WHERE kunnr EQ tl_cust_link-kunnr.
ENDIF.

ENDIF.

LOOP AT tl_but000 ASSIGNING .
CLEAR: wl_alv.

wl_alv-partner = -partner.

READ TABLE tl_vend_link ASSIGNING <vend_link> WITH TABLE KEY partner_guid = -partner_guid.
IF sy-subrc EQ 0.
wl_alv-lifnr = <vend_link>-lifnr.
READ TABLE tl_lfa1 ASSIGNING WITH TABLE KEY lifnr = <vend_link>-lifnr.
IF sy-subrc EQ 0.
wl_alv-namel = -name1.
ENDIF.
ENDIF.

READ TABLE tl_cust_link ASSIGNING <cust_link> WITH TABLE KEY partner_guid = -partner_guid.
IF sy-subrc EQ 0.
wl_alv-kunnr = <cust_link>-kunnr.
READ TABLE tl_kna1 ASSIGNING WITH TABLE KEY kunnr = <cust_link>-kunnr.
IF sy-subrc EQ 0.
wl_alv-namek = -name1.
ENDIF.
ENDIF.

IF wl_alv-kunnr IS NOT INITIAL AND wl_alv-lifnr IS NOT INITIAL.
wl_alv-status = icon_complete.
ELSEIF wl_alv-kunnr IS NOT INITIAL OR wl_alv-lifnr IS NOT INITIAL.
wl_alv-status = icon_activity.
ELSEIF wl_alv-kunnr IS INITIAL AND wl_alv-lifnr IS INITIAL.
wl_alv-status = icon_initial.
ENDIF.

APPEND wl_alv TO tg_alv.

ENDLOOP.

DELETE tg_alv WHERE lifnr NOT IN s_lifnr. "Não é performático

DELETE tg_alv WHERE kunnr NOT IN s_kunnr.

ENDFORM.
&---------------------------------------------------------------------
*& Form zf_gera_field_cat
&---------------------------------------------------------------------
*& text
&---------------------------------------------------------------------
*& --> p1 text
*& <-- p2 text
&---------------------------------------------------------------------
FORM zf_gera_field_cat USING p_t_fieldcat TYPE slis_t_fieldcat_alv.

DATA: wl_fieldcat TYPE slis_fieldcat_alv.

wl_fieldcat-fieldname = 'PARTNER'.
wl_fieldcat-rollname = 'BU_PARTNER'.
wl_fieldcat-key = 'X'.
wl_fieldcat-hotspot = 'X'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

IF p_but EQ 'X'.
wl_fieldcat-fieldname = 'STATUS'.
wl_fieldcat-rollname = 'ICON_D'.
wl_fieldcat-key = 'X'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.
ENDIF.

wl_fieldcat-fieldname = 'KUNNR'.
wl_fieldcat-rollname = 'KUNNR'.
IF p_kna1 EQ 'X'.
wl_fieldcat-key = 'X'.
ENDIF.
wl_fieldcat-hotspot = 'X'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

IF p_lfa1 NE 'X'.
wl_fieldcat-fieldname = 'NAMEL'.
wl_fieldcat-rollname = 'NAME1'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.
ENDIF.

IF p_kna1 EQ 'X'.
wl_fieldcat-fieldname = 'KN_LAND1'.
wl_fieldcat-rollname = 'LAND1'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'KN_ORT01'.
wl_fieldcat-rollname  = 'ORT01'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'KN_PSTLZ'.
wl_fieldcat-rollname  = 'PSTLZ'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'KN_PSTLZ'.
wl_fieldcat-rollname  = 'PSTLZ'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'KN_SORTL'.
wl_fieldcat-rollname  = 'SORTL'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'KN_REGIO'.
wl_fieldcat-rollname  = 'REGIO'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'KN_STRAS'.
wl_fieldcat-rollname  = 'STRAS'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'KN_MCOD1'.
wl_fieldcat-rollname  = 'MCDK1'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'KN_MCOD3'.
wl_fieldcat-rollname  = 'MCDK3'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'KN_SMTP_ADDR'.
wl_fieldcat-rollname  = 'AD_SMTPADR'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.
ENDIF.

wl_fieldcat-fieldname = 'LIFNR'.
wl_fieldcat-rollname = 'LIFNR'.
IF p_lfa1 EQ 'X'.
wl_fieldcat-key = 'X'.
ENDIF.
wl_fieldcat-hotspot = 'X'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

IF p_kna1 NE 'X'.
wl_fieldcat-fieldname = 'NAMEL'.
wl_fieldcat-rollname = 'NAME1'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.
ENDIF.

IF p_lfa1 EQ 'X'.
wl_fieldcat-fieldname = 'LF_LAND1'.
wl_fieldcat-rollname = 'LAND1'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'LF_ORT01'.
wl_fieldcat-rollname  = 'ORT01'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'LF_PSTLZ'.
wl_fieldcat-rollname  = 'PSTLZ'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'LF_PSTLZ'.
wl_fieldcat-rollname  = 'PSTLZ'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'LF_SORTL'.
wl_fieldcat-rollname  = 'SORTL'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'LF_REGIO'.
wl_fieldcat-rollname  = 'REGIO'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'LF_STRAS'.
wl_fieldcat-rollname  = 'STRAS'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'LF_MCOD1'.
wl_fieldcat-rollname  = 'MCDK1'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'LF_MCOD3'.
wl_fieldcat-rollname  = 'MCDK3'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.

wl_fieldcat-fieldname = 'LF_SMTP_ADDR'.
wl_fieldcat-rollname  = 'AD_SMTPADR'.
APPEND wl_fieldcat TO p_t_fieldcat.
CLEAR: wl_fieldcat.
ENDIF.

ENDFORM.
&---------------------------------------------------------------------
*& Form zf_apresenta_alv
&---------------------------------------------------------------------
*& text
&---------------------------------------------------------------------
*& --> p1 text
*& <-- p2 text
&---------------------------------------------------------------------
FORM zf_apresenta_alv .

DATA: tl_fieldcat TYPE slis_t_fieldcat_alv.

DATA: wl_layout TYPE slis_layout_alv.

PERFORM zf_gera_field_cat USING tl_fieldcat.
PERFORM zf_define_layout USING wl_layout.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
EXPORTING
is_layout = wl_layout
it_fieldcat = tl_fieldcat
i_callback_user_command = 'USER_COMMAND'
i_callback_program = sy-repid
i_callback_pf_status_set = 'SET_PF_STATUS'
TABLES
t_outtab = tg_alv.

ENDFORM.

FORM set_pf_status USING rt_extab TYPE slis_t_extab.

SET PF-STATUS 'STATUS_RELATORIO'.

ENDFORM.

FORM user_command USING r_ucomm LIKE sy-ucomm
rs_selfield TYPE slis_selfield.

DATA: vl_answer TYPE c.

If r_ucomm EQ 'CREATE'.
CALL FUNCTION 'POPUP_TO_CONFIRM'
EXporting

text_question = 'Deseja criar um bp?'
text_button_1 = 'Sim'
text_button = 'NÃo '

IMPORTING answer = vl_answer.
ELSE.

CASE rs_selfield-fieldname.
WHEN 'PARTNER'.
SET PARAMETER ID 'BPA' FIELD rs_selfield-value.
CALL TRANSACTION 'BP'.
WHEN 'LIFNR'.
SET PARAMETER ID 'LIF' FIELD rs_selfield-value.
CALL TRANSACTION 'XK03' AND SKIP FIRST SCREEN.
WHEN 'KUNNR'.
SET PARAMETER ID 'KUN' FIELD rs_selfield-value.
CALL TRANSACTION 'XD03' AND SKIP FIRST SCREEN.
ENDCASE.

ENDIF.
ENDFORM.

&---------------------------------------------------------------------
*& Form zf_define_layout
&---------------------------------------------------------------------
*& text
&---------------------------------------------------------------------
*& --> WL_LAYOUT
&---------------------------------------------------------------------
FORM zf_define_layout USING p_w_layout TYPE slis_layout_alv.

p_w_layout-zebra = 'X'.
p_w_layout-colwidth_optimize = 'X'.

ENDFORM.