CLASS zcl_cat_match_fields DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_constraint.

    METHODS constructor
      IMPORTING
        i_expected_data TYPE REF TO data.

  PRIVATE SECTION.
    DATA expected_data   TYPE REF TO data.
    DATA info            TYPE string_table.
    DATA struct_info_exp TYPE REF TO cl_abap_structdescr.

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

    struct_info_exp = zcl_cat_field_matcher=>get_info( <t_exp> ).

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

      zcl_cat_field_matcher=>compare_field_values(
        EXPORTING
          i_struct_info_exp = struct_info_exp
          i_index_info      = index_info
          i_exp             = <exp>
          i_act             = <act>
        CHANGING
          ct_info           = info ).
    ENDLOOP.

    IF info IS INITIAL.
      result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD if_constraint~get_description.
    result = info.
  ENDMETHOD.

  METHOD is_valid_struc.
    FIELD-SYMBOLS <act> TYPE any.
    FIELD-SYMBOLS <exp> TYPE any.

    ASSIGN expected_data->* TO <exp>.
    ASSIGN data_object TO <act>.

    struct_info_exp = zcl_cat_field_matcher=>get_info( <exp> ).

    zcl_cat_field_matcher=>compare_field_values(
      EXPORTING
        i_struct_info_exp = struct_info_exp
        i_exp             = <exp>
        i_act             = <act>
      CHANGING
        ct_info           = info ).

    IF info IS INITIAL.
      result = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
