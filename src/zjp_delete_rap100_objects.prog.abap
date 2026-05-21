*&---------------------------------------------------------------------*
*& Report zjp_delete_rap100_objects
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zjp_delete_rap100_objects.

  TABLES: tadir.

  TYPES: BEGIN OF ty_obj,
           pgmid    TYPE tadir-pgmid,
           object   TYPE tadir-object,
           obj_name TYPE tadir-obj_name,
         END OF ty_obj.

  DATA: lt_objects TYPE TABLE OF ty_obj.

 lt_objects = VALUE #(
      ( pgmid = 'R3TR' object = 'G4BA' obj_name = 'ZRAP100_UI_TRAVEL_O4_SOL' )
      ( pgmid = 'R3TR' object = 'SRVB' obj_name = 'ZRAP100_UI_TRAVEL_O4_SOL' )
      ( pgmid = 'R3TR' object = 'SRVD' obj_name = 'ZRAP100_UI_TRAVEL_SOL'    )
      ( pgmid = 'R3TR' object = 'TABL' obj_name = 'ZRAP100_ATRAVSOL'         )
      ( pgmid = 'R3TR' object = 'TABL' obj_name = 'ZRAP100_DTRAVSOL'         )
    ).

  DELETE tadir FROM TABLE lt_objects.

  COMMIT WORK.
