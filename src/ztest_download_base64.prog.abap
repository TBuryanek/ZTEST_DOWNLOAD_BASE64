*&---------------------------------------------------------------------*
*& Report ZTEST_DOWNLOAD_BASE64
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztest_download_base64.

*---------------------------------------------------------------------*
PARAMETERS: p_file TYPE string.
PARAMETERS: p_http RADIOBUTTON GROUP r1 DEFAULT 'X',
            p_scms RADIOBUTTON GROUP r1.
*---------------------------------------------------------------------*

INITIALIZATION.
  p_file = 'C:\Users\' && sy-uname && '\Desktop\test.pdf'.

*---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM decode_base64_to_file.

*&---------------------------------------------------------------------*
*&      Form  DECODE_BASE64_TO_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM decode_base64_to_file.

  DATA: lt_base   TYPE string_table,
        ls_base   LIKE LINE OF lt_base,
        l_string  TYPE string,
        l_xstring TYPE xstring,
        lt_solix  TYPE solix_tab,
        l_size    TYPE i.

  CALL FUNCTION 'TERM_CONTROL_EDIT'
    EXPORTING
      titel          = 'Enter BASE64 string'
    TABLES
      textlines      = lt_base
    EXCEPTIONS
      user_cancelled = 1
      OTHERS         = 2.
  IF sy-subrc <> 0 OR lt_base IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT lt_base INTO ls_base.
    l_string = l_string && ls_base.
  ENDLOOP.

  IF p_http = abap_true.
    l_xstring = cl_http_utility=>decode_x_base64( encoded = l_string ).
  ELSEIF p_scms = abap_true.
    CALL FUNCTION 'SCMS_BASE64_DECODE_STR'
      EXPORTING
        input  = l_string
      IMPORTING
        output = l_xstring
      EXCEPTIONS
        failed = 1
        OTHERS = 2.
  ENDIF.
  lt_solix = cl_bcs_convert=>xstring_to_solix( iv_xstring = l_xstring ).
  l_size = xstrlen( l_xstring ).

  cl_gui_frontend_services=>gui_download(
    EXPORTING
      bin_filesize              = l_size
      filename                  = p_file
      filetype                  = 'BIN'
    CHANGING
      data_tab                  = lt_solix
    EXCEPTIONS
      file_write_error          = 1
      no_batch                  = 2
      gui_refuse_filetransfer   = 3
      invalid_type              = 4
      no_authority              = 5
      unknown_error             = 6
      header_not_allowed        = 7
      separator_not_allowed     = 8
      filesize_not_allowed      = 9
      header_too_long           = 10
      dp_error_create           = 11
      dp_error_send             = 12
      dp_error_write            = 13
      unknown_dp_error          = 14
      access_denied             = 15
      dp_out_of_memory          = 16
      disk_full                 = 17
      dp_timeout                = 18
      file_not_found            = 19
      dataprovider_exception    = 20
      control_flush_error       = 21
      not_supported_by_gui      = 22
      error_no_gui              = 23
      OTHERS                    = 24
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
