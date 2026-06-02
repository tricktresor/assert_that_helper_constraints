CLASS zcl_cat_match_fields DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_constraint.

    CONSTANTS c_not_initial TYPE c LENGTH 1 VALUE '*'.
    CONSTANTS c_initial     TYPE c LENGTH 1 VALUE '!'.

    METHODS constructor
      IMPORTING
        i_expected_data TYPE REF TO data.

  PRIVATE SECTION.
    DATA expected_data   TYPE REF TO data.
    DATA info            TYPE string_table.
    DATA struct_info_exp TYPE REF TO cl_abap_structdescr.
    DATA struct_info_act TYPE REF TO cl_abap_structdescr.

    METHODS get_info
      IMPORTING
        i_data        TYPE any
      RETURNING
        VALUE(result) TYPE REF TO cl_abap_structdescr.

    METHODS is_valid_table
      IMPORTING
        data_object   TYPE data
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS is_valid_struc
      IMPORTING
        data_object   TYPE data
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS compare_field_values
      IMPORTING
        i_index_info TYPE string OPTIONAL
        i_exp        TYPE any
        i_act        TYPE any.
ENDCLASS.


CLASS zcl_cat_match_fields IMPLEMENTATION.
  METHOD constructor.
    expected_data = i_expected_data.
  ENDMETHOD.

  METHOD if_constraint~is_valid.
    DATA(data_object_descr) = cl_abap_typedescr=>describe_by_data( data_object ).
    CASE data_object_descr->type_kind.
      WHEN cl_abap_typedescr=>typekind_table.
        result = is_valid_table( data_object ).
      WHEN cl_abap_typedescr=>typekind_struct1.
        result = is_valid_struc( data_object ).
    ENDCASE.
  ENDMETHOD.

  METHOD is_valid_table.
    FIELD-SYMBOLS <t_act> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <t_exp> TYPE STANDARD TABLE.

    ASSIGN data_object TO <t_act>.
    IF sy-subrc > 0.
      APPEND |Failed to assign DATA_OBJECT| TO info ##NO_TEXT.
      RETURN.
    ENDIF.

    ASSIGN expected_data->* TO <t_exp>.
    IF sy-subrc > 0.
      APPEND |Failed to assign EXP_TABLE| TO info ##NO_TEXT.
      RETURN.
    ENDIF.

    IF lines( <t_act> ) <> lines( <t_exp> ).
      APPEND |number of lines differ! ACT = { lines( <t_act> ) }, EXP = { lines(
                                                                              <t_exp> ) }| TO info ##NO_TEXT.
      RETURN.
    ENDIF.

    struct_info_act = get_info( <t_act> ).
    struct_info_exp = get_info( <t_exp> ).

    DATA index_info TYPE string.

    DATA(row_index) = 0.

    LOOP AT <t_exp> ASSIGNING FIELD-SYMBOL(<exp>).
      row_index = row_index + 1.
      index_info = |Index { row_index }: |.

      ASSIGN <t_act>[ row_index ] TO FIELD-SYMBOL(<act>).
      IF sy-subrc > 0.
        APPEND |Failed to assign ACT_TABLE line { row_index }| TO info ##NO_TEXT.
        RETURN.
      ENDIF.

      compare_field_values( i_index_info = index_info
                            i_exp        = <exp>
                            i_act        = <act> ).
    ENDLOOP.

    IF info IS INITIAL.
      result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD compare_field_values.
    LOOP AT struct_info_exp->components INTO DATA(component).
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
        " keine Unterstützung von Wildcards bei numerischen Feldern
        IF <exp_val> <> <act_val>.
          APPEND |{ i_index_info }field values of { component-name } differs: act = { <act_val> }, exp = { <exp_val> }| TO info.
        ENDIF.
      ELSE.

        CASE <exp_val>.
          WHEN c_initial.
            IF <act_val> IS NOT INITIAL.
              APPEND |{ i_index_info }field value of { component-name } should be empty but has a value: { <act_val> }| TO info.
            ENDIF.
          WHEN c_not_initial.
            IF <act_val> IS INITIAL.
              APPEND |{ i_index_info }field value of { component-name } should be filled but is empty: { <act_val> }| TO info.
            ENDIF.
          WHEN OTHERS.
            IF <exp_val> <> <act_val>.
              APPEND |{ i_index_info }field values of { component-name } differs: act = { <act_val> }, exp = { <exp_val> }| TO info.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_constraint~get_description.
    result = info.
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

  METHOD is_valid_struc.
    FIELD-SYMBOLS <act> TYPE any.
    FIELD-SYMBOLS <exp> TYPE any.

    ASSIGN expected_data->* TO <exp>.
    ASSIGN data_object TO <act>.

    struct_info_exp = get_info( <exp> ).
    struct_info_act = get_info( <act> ).

    compare_field_values( i_exp = <exp>
                          i_act = <act> ).

    IF info IS INITIAL.
      result = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
