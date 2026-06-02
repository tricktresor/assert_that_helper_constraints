CLASS ltcl_table DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    TYPES: BEGIN OF ts_demo,
             intg TYPE i,
             char TYPE c LENGTH 10,
             date TYPE d,
             time TYPE t,
             numc TYPE n LENGTH 5,
           END OF ts_demo,
           tt_demo TYPE STANDARD TABLE OF ts_demo WITH DEFAULT KEY.

    METHODS table_equal                FOR TESTING RAISING cx_static_check.
    METHODS table_wildcards            FOR TESTING RAISING cx_static_check.
    METHODS struc_equal                FOR TESTING RAISING cx_static_check.
    METHODS struc_wildcard_initial     FOR TESTING RAISING cx_static_check.
    METHODS struc_wildcard_filled      FOR TESTING RAISING cx_static_check.
    METHODS struc_not_equal            FOR TESTING RAISING cx_static_check.
    METHODS struc_wildcard_not_initial FOR TESTING RAISING cx_static_check.
    METHODS struc_wildcard_not_filled  FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_table IMPLEMENTATION.
  METHOD table_equal.
    DATA(act_demo) = VALUE tt_demo(
        ( intg = 1 char = 'test1' date = '20240601' time = '120000' numc = '12345' )
        ( intg = 2 char = 'test2' date = '20240602' time = '130000' numc = '54321' ) ).

    DATA(exp_demo) = act_demo.

    DATA cut TYPE REF TO if_constraint.
    cut = NEW zcl_cat_match_fields( REF #( exp_demo ) ).
    cl_abap_unit_assert=>assert_that( exp = cut act = act_demo ).
  ENDMETHOD.

  METHOD table_wildcards.
    DATA(act_demo) = VALUE tt_demo(
        ( intg = 1 char = 'test1' date = '20240601' time = '120000' numc = '12345' )
        ( intg = 2 char = '     ' date = '20240602' time = '130000' numc = '54321' ) ).

    DATA(exp_demo) = VALUE tt_demo(
        ( intg = 1 char = '*' date = '20240601' time = '120000' numc = '12345' )
        ( intg = 2 char = '!' date = '20240602' time = '130000' numc = '54321' ) ).

    DATA cut TYPE REF TO if_constraint.
    cut = NEW zcl_cat_match_fields( REF #( exp_demo ) ).
    cl_abap_unit_assert=>assert_that( exp = cut act = act_demo ).
  ENDMETHOD.

  METHOD struc_equal.
    DATA(act_demo) = VALUE ts_demo( intg = 1
                                    char = 'test1'
                                    date = '20240601'
                                    time = '120000'
                                    numc = '12345'  ).

    DATA(exp_demo) = act_demo.

    DATA cut TYPE REF TO if_constraint.
    cut = NEW zcl_cat_match_fields( REF #( exp_demo ) ).
    cl_abap_unit_assert=>assert_that( exp = cut act = act_demo ).
  ENDMETHOD.

  METHOD struc_wildcard_initial.
    DATA(act_demo) = VALUE ts_demo( intg = 1
                                    char = ''
                                    date = '20240601'
                                    time = '120000'
                                    numc = '12345'  ).

    DATA(exp_demo) = VALUE ts_demo( intg = 1
                                    char = '!'
                                    date = '20240601'
                                    time = '120000'
                                    numc = '12345'  ).

    DATA cut TYPE REF TO if_constraint.
    cut = NEW zcl_cat_match_fields( REF #( exp_demo ) ).
    cl_abap_unit_assert=>assert_that( exp = cut act = act_demo ).
  ENDMETHOD.

  METHOD struc_wildcard_filled.
    DATA(act_demo) = VALUE ts_demo( intg = 1
                                    char = 'test1'
                                    date = '20240601'
                                    time = '120000'
                                    numc = '12345'  ).

    DATA(exp_demo) = VALUE ts_demo( intg = 1
                                    char = '*'
                                    date = '20240601'
                                    time = '120000'
                                    numc = '12345'  ).

    DATA cut TYPE REF TO if_constraint.
    cut = NEW zcl_cat_match_fields( REF #( exp_demo ) ).
    cl_abap_unit_assert=>assert_that( exp = cut act = act_demo ).
  ENDMETHOD.

  METHOD struc_not_equal.
    DATA(act_demo) = VALUE ts_demo( intg = 1
                                    char = 'test1'
                                    date = '20240601'
                                    time = '120000'
                                    numc = '12345'  ).

    DATA(exp_demo) = VALUE ts_demo( intg = 2
                                    char = 'test2'
                                    date = '20240602'
                                    time = '130000'
                                    numc = '54321'  ).

    DATA cut TYPE REF TO if_constraint.
    cut = NEW zcl_cat_match_fields( REF #( exp_demo ) ).
    cl_abap_unit_assert=>assert_false( cut->is_valid( act_demo ) ).
  ENDMETHOD.

  METHOD struc_wildcard_not_initial.
    DATA(act_demo) = VALUE ts_demo( intg = 1
                                    char = 'Test1'
                                    date = '20240601'
                                    time = '120000'
                                    numc = '12345'  ).

    DATA(exp_demo) = VALUE ts_demo( intg = 1
                                    char = '!'
                                    date = '20240601'
                                    time = '120000'
                                    numc = '12345'  ).

    DATA cut TYPE REF TO if_constraint.
    cut = NEW zcl_cat_match_fields( REF #( exp_demo ) ).
    cl_abap_unit_assert=>assert_false( cut->is_valid( act_demo ) ).
  ENDMETHOD.

  METHOD struc_wildcard_not_filled.
    DATA(act_demo) = VALUE ts_demo( intg = 1
                                    char = ''
                                    date = '20240601'
                                    time = '120000'
                                    numc = '12345'  ).

    DATA(exp_demo) = VALUE ts_demo( intg = 1
                                    char = '*'
                                    date = '20240601'
                                    time = '120000'
                                    numc = '12345'  ).

    DATA cut TYPE REF TO if_constraint.
    cut = NEW zcl_cat_match_fields( REF #( exp_demo ) ).
    cl_abap_unit_assert=>assert_false( cut->is_valid( act_demo ) ).
  ENDMETHOD.
ENDCLASS.
