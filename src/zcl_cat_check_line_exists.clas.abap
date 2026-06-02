CLASS zcl_cat_check_line_exists DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_constraint.

    METHODS constructor
      IMPORTING
        exp_data   TYPE REF TO data
        key_fields TYPE string_table OPTIONAL.

  PRIVATE SECTION.
    DATA exp_data   TYPE REF TO data.
    DATA info       TYPE string_table.
    DATA key_fields TYPE string_table.
ENDCLASS.


CLASS zcl_cat_check_line_exists IMPLEMENTATION.
  METHOD constructor.
    me->exp_data   = exp_data.
    me->key_fields = key_fields.
  ENDMETHOD.

  METHOD if_constraint~is_valid.
    FIELD-SYMBOLS <t_act> TYPE STANDARD TABLE.
    DATA where_clause TYPE string_table.

    ASSIGN data_object TO <t_act>.
    IF sy-subrc > 0.
      APPEND |Failed to assign DATA_OBJECT| TO info ##NO_TEXT.
      RETURN.
    ENDIF.

    ASSIGN exp_data->* TO FIELD-SYMBOL(<exp>).
    IF sy-subrc > 0.
      APPEND |Failed to assign EXP_DATA| TO info ##NO_TEXT.
      RETURN.
    ENDIF.

    DATA(row_index) = 0.

    row_index = row_index + 1.

    IF key_fields IS INITIAL.
      APPEND |Key fields empty!!| TO info ##NO_TEXT.
    ELSE.
      CLEAR where_clause.
      LOOP AT key_fields INTO DATA(key_field).
        ASSIGN COMPONENT key_field OF STRUCTURE <exp> TO FIELD-SYMBOL(<key>).
        IF where_clause IS INITIAL.
          APPEND |{ key_field } = '{ <key> }'| TO where_clause.
        ELSE.
          APPEND |AND { key_field } = '{ <key> }'| TO where_clause.
        ENDIF.
      ENDLOOP.
      LOOP AT <t_act> ASSIGNING FIELD-SYMBOL(<act>) WHERE (where_clause).
      ENDLOOP.
      IF sy-subrc > 0.
        DATA(key_field_values) = REDUCE string( INIT res = || FOR entry IN key_fields NEXT res = |{ res }{ entry }/| ).
        APPEND |Access with key failed: { key_field_values }| TO info.
        RETURN.
      ENDIF.
    ENDIF.
    zcl_cat_field_matcher=>compare_field_values(
      EXPORTING
        i_struct_info_exp = zcl_cat_field_matcher=>get_info( <exp> )
        i_index_info      = |Index { row_index }: |
        i_exp             = <exp>
        i_act             = <act>
      CHANGING
        ct_info           = info ).

    IF info IS INITIAL.
      result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD if_constraint~get_description.
    result = info.
  ENDMETHOD.
ENDCLASS.
