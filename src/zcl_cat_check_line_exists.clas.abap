CLASS zcl_cat_check_line_exists DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_constraint.

    CONSTANTS c_not_initial TYPE c LENGTH 1 VALUE '*'.
    CONSTANTS c_initial     TYPE c LENGTH 1 VALUE '!'.

    METHODS constructor
      IMPORTING
        exp_data   TYPE REF TO data
        key_fields TYPE string_table OPTIONAL.

  PRIVATE SECTION.
    DATA exp_data        TYPE REF TO data.
    DATA info            TYPE string_table.
    DATA struct_info_exp TYPE REF TO cl_abap_structdescr.
    DATA struct_info_act TYPE REF TO cl_abap_structdescr.
    DATA key_fields      TYPE string_table.

    METHODS get_info
      IMPORTING
        i_table       TYPE any
      RETURNING
        VALUE(result) TYPE REF TO cl_abap_structdescr.
ENDCLASS.


CLASS zcl_cat_check_line_exists IMPLEMENTATION.
  METHOD constructor.
    me->exp_data   = exp_data.
    me->key_fields = key_fields.
  ENDMETHOD.

  METHOD if_constraint~is_valid.
* FIELD-SYMBOLS <t_exp> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <t_act> TYPE STANDARD TABLE.
    DATA where_clause TYPE string_table.

    " TODO:
    " FUNKTIONIERT BISHER NUR MIT TABELLEN
    " SOLLTE ABER GERNE AUCH MIT STRUKTUREN FUNKTIONIEREN!
    " STRUKTUREN WURDEN BISHER NICHT BENÖTIGT

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

    struct_info_act = get_info( <t_act> ).
    struct_info_exp = get_info( <exp> ).

    DATA(row_index) = 0.

    row_index = row_index + 1.

    IF key_fields IS INITIAL.
      APPEND |Key fields empty!!| TO info ##NO_TEXT.
    ELSE.
      CLEAR where_clause.
      LOOP AT key_fields INTO DATA(key_field).
        ASSIGN COMPONENT key_field OF STRUCTURE <exp> TO FIELD-SYMBOL(<key>).
        APPEND |{ key_field } = '{ <key> }'| TO where_clause.
      ENDLOOP.
      LOOP AT <t_act> ASSIGNING FIELD-SYMBOL(<act>) WHERE (where_clause).
      ENDLOOP.
      IF sy-subrc > 0.
        DATA(key_field_values) = REDUCE string( INIT res = || FOR entry IN key_fields NEXT res = |{ res }{ entry }/| ).
        APPEND |Access with key failed: { key_field_values }| TO info.
        RETURN.
      ENDIF.
    ENDIF.
    LOOP AT struct_info_exp->components INTO DATA(component).
      ASSIGN COMPONENT component-name OF STRUCTURE <exp> TO FIELD-SYMBOL(<exp_val>).
      IF <exp_val> IS INITIAL.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT component-name OF STRUCTURE <act> TO FIELD-SYMBOL(<act_val>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE <exp_val>.
        WHEN c_initial.
          IF <act_val> IS NOT INITIAL.
            APPEND |Index { row_index }: field value of { component-name } should be empty but has a value: { <act_val> }| TO info.
          ENDIF.
        WHEN c_not_initial.
          IF <act_val> IS INITIAL.
            APPEND |Index { row_index }: field value of { component-name } should be filled but is empty: { <act_val> }| TO info.
          ENDIF.
        WHEN OTHERS.
          IF <exp_val> <> <act_val>.
            APPEND |Index { row_index }: field values of { component-name } differs: act = { <act_val> }, exp = { <exp_val> }| TO info.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    IF info IS INITIAL.
      result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD if_constraint~get_description.
    result = info.
  ENDMETHOD.

  METHOD get_info.
    DATA tabl_info TYPE REF TO cl_abap_tabledescr.

    TRY.
        tabl_info ?= cl_abap_typedescr=>describe_by_data( i_table ).
        result ?= tabl_info->get_table_line_type( ).
      CATCH cx_sy_move_cast_error.
        result ?= cl_abap_typedescr=>describe_by_data( i_table ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
