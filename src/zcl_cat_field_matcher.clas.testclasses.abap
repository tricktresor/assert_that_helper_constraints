CLASS ltcl_match_fields DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES: BEGIN OF ts_demo,
             field1 TYPE i,
             field2 TYPE string,
             field3 TYPE c LENGTH 10,
           END OF ts_demo,
           tt_demo TYPE STANDARD TABLE OF ts_demo WITH DEFAULT KEY.

    METHODS fields_match           FOR TESTING RAISING cx_static_check.
    METHODS fields_no_match_filled FOR TESTING RAISING cx_static_check.
    METHODS fields_no_match_empty  FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_match_fields IMPLEMENTATION.
  METHOD fields_match.
    DATA struct_info TYPE REF TO cl_abap_structdescr.
    DATA info        TYPE string_table.
    DATA exp         TYPE ts_demo.

    DATA(act) = VALUE tt_demo( ( field1 = 1 field2 = 'test1' field3 = 'abc' )
                               ( field1 = 2 field2 = 'test2' field3 = 'def' )
                               ( field1 = 3 field2 = 'test3' field3 = 'ghi' ) ).

    struct_info ?= cl_abap_structdescr=>describe_by_data( exp ).
    LOOP AT VALUE tt_demo( field2 = '*'
                           field3 = '*'
                           ( field1 = 3 )
                           ( field1 = 2 )
                           ( field1 = 1 ) )
         INTO exp.
      zcl_cat_field_matcher=>compare_field_values(
        EXPORTING
          i_struct_info_exp = struct_info
          i_index_info      = ``
          i_exp             = exp
          i_act             = act
        CHANGING
          ct_info           = info ).

      cl_abap_unit_assert=>assert_initial( info ).
    ENDLOOP.
  ENDMETHOD.

  METHOD fields_no_match_filled.
    DATA struct_info TYPE REF TO cl_abap_structdescr.
    DATA info        TYPE string_table.
    DATA exp         TYPE ts_demo.

    DATA(act) = VALUE ts_demo( field1 = 1 field2 = '     ' field3 = 'abc' ).

    struct_info ?= cl_abap_structdescr=>describe_by_data( exp ).
    exp = VALUE ts_demo( field1 = 1  field2 = '*'  field3 = '*' ).
    zcl_cat_field_matcher=>compare_field_values(
      EXPORTING
        i_struct_info_exp = struct_info
        i_index_info      = ||
        i_exp             = exp
        i_act             = act
      CHANGING
        ct_info           = info ).

    cl_abap_unit_assert=>assert_not_initial( info ).
  ENDMETHOD.

  METHOD fields_no_match_empty.
    DATA struct_info TYPE REF TO cl_abap_structdescr.
    DATA info        TYPE string_table.
    DATA exp         TYPE ts_demo.

    DATA(act) = VALUE ts_demo( field1 = 1 field2 = '     ' field3 = 'abc' ).

    struct_info ?= cl_abap_structdescr=>describe_by_data( exp ).
    exp = VALUE ts_demo( field1 = 1  field2 = '!'  field3 = '!' ).
    zcl_cat_field_matcher=>compare_field_values(
      EXPORTING
        i_struct_info_exp = struct_info
        i_index_info      = ||
        i_exp             = exp
        i_act             = act
      CHANGING
        ct_info           = info ).

    cl_abap_unit_assert=>assert_not_initial( info ).
  ENDMETHOD.
ENDCLASS.
