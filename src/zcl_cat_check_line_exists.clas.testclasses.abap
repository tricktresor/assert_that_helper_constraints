class ltcl_table definition final for testing
  duration short
  risk level harmless.

  private section.

    TYPES: BEGIN OF ts_demo,
             intg TYPE i,
             char TYPE c LENGTH 10,
             date TYPE d,
             time TYPE t,
             numc TYPE n LENGTH 5,
           END OF ts_demo,
           tt_demo TYPE STANDARD TABLE OF ts_demo WITH DEFAULT KEY.
    methods:
      sorted_intg for testing raising cx_static_check.
endclass.


class ltcl_table implementation.

  method sorted_intg.

    DATA(act_demo) = VALUE tt_demo(
        ( intg = 1 char = 'test1' date = '20240601' time = '120000' numc = '12345' )
        ( intg = 2 char = 'test2' date = '20240602' time = '130000' numc = '54321' ) ).

    DATA(exp_data) = value ts_demo( intg = 1 char = '*' ).

    DATA cut TYPE REF TO if_constraint.
    cut = NEW zcl_cat_check_line_exists( exp_data = REF #( exp_data ) key_fields = value #( ( |INTG| ) ) ).
    cl_abap_unit_assert=>assert_that( exp = cut act = act_demo ).


  endmethod.

endclass.
