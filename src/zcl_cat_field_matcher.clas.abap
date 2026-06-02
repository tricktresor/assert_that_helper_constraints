CLASS zcl_cat_field_matcher DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS c_not_initial TYPE c LENGTH 1 VALUE '*'.
    CONSTANTS c_initial     TYPE c LENGTH 1 VALUE '!'.

    CLASS-METHODS compare_field_values
      IMPORTING
        i_struct_info_exp TYPE REF TO cl_abap_structdescr
        i_index_info      TYPE string OPTIONAL
        i_exp             TYPE any
        i_act             TYPE any
      CHANGING
        ct_info           TYPE string_table.

    CLASS-METHODS get_info
      IMPORTING
        i_data        TYPE any
      RETURNING
        VALUE(result) TYPE REF TO cl_abap_structdescr.
ENDCLASS.


CLASS zcl_cat_field_matcher IMPLEMENTATION.
  METHOD compare_field_values.
    LOOP AT i_struct_info_exp->components INTO DATA(component).
      ASSIGN COMPONENT component-name OF STRUCTURE i_exp TO FIELD-SYMBOL(<exp_val>).
      IF <exp_val> IS INITIAL.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT component-name OF STRUCTURE i_act TO FIELD-SYMBOL(<act_val>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF    component-type_kind = cl_abap_typedescr=>typekind_int
         OR component-type_kind = cl_abap_typedescr=>typekind_int1
         OR component-type_kind = cl_abap_typedescr=>typekind_int2
         OR component-type_kind = cl_abap_typedescr=>typekind_int8
         OR component-type_kind = cl_abap_typedescr=>typekind_num
         OR component-type_kind = cl_abap_typedescr=>typekind_numeric
         OR component-type_kind = cl_abap_typedescr=>typekind_decfloat16
         OR component-type_kind = cl_abap_typedescr=>typekind_decfloat34
         OR component-type_kind = cl_abap_typedescr=>typekind_packed
         OR component-type_kind = cl_abap_typedescr=>typekind_float.
        IF <exp_val> <> <act_val>.
          APPEND |{ i_index_info }field values of { component-name } differs: act = { <act_val> }, exp = { <exp_val> }| TO ct_info.
        ENDIF.
      ELSE.
        CASE <exp_val>.
          WHEN c_initial.
            IF <act_val> IS NOT INITIAL.
              APPEND |{ i_index_info }field value of { component-name } should be empty but has a value: { <act_val> }| TO ct_info.
            ENDIF.
          WHEN c_not_initial.
            IF <act_val> IS INITIAL.
              APPEND |{ i_index_info }field value of { component-name } should be filled but is empty: { <act_val> }| TO ct_info.
            ENDIF.
          WHEN OTHERS.
            IF <exp_val> <> <act_val>.
              APPEND |{ i_index_info }field values of { component-name } differs: act = { <act_val> }, exp = { <exp_val> }| TO ct_info.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_info.
    DATA tabl_info TYPE REF TO cl_abap_tabledescr.

    TRY.
        tabl_info ?= cl_abap_typedescr=>describe_by_data( i_data ).
        result ?= tabl_info->get_table_line_type( ).
      CATCH cx_sy_move_cast_error.
        result ?= cl_abap_typedescr=>describe_by_data( i_data ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
