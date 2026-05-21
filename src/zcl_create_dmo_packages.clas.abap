CLASS zcl_create_dmo_packages DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS : co_dmo_sap_package    TYPE if_xco_cp_gen_devc_s_fo_proper=>tv_software_component VALUE 'HOME',
                co_dmo_flight_package TYPE if_xco_cp_gen_devc_s_fo_proper=>tv_software_component VALUE '/DMO/FLIGHT',

                test_string           TYPE string VALUE '',
                create_packages       TYPE abap_boolean VALUE abap_true.



    TYPES : BEGIN OF t_dmo_packages,
              package_name       TYPE sxco_package,
              super_package_name TYPE sxco_package,
              short_description  TYPE if_xco_gen_devc_s_form=>tv_short_description,
            END OF t_dmo_packages.

    TYPES tt_dmo_packages TYPE STANDARD TABLE OF t_dmo_packages WITH DEFAULT KEY.

    DATA dmo_package TYPE t_dmo_packages.
    DATA dmo_packages TYPE tt_dmo_packages.
    DATA transport_request TYPE sxco_transport.


    METHODS create_package_in_dmo_sap IMPORTING
                                                i_transport          TYPE sxco_transport
                                                I_package_name       TYPE sxco_package
                                                i_super_package_name TYPE sxco_package
                                                i_short_description  TYPE if_xco_gen_devc_s_form=>tv_short_description OPTIONAL
                                      EXPORTING findings             TYPE sxco_t_gen_o_findings
                                                exception_text       TYPE string.

    METHODS get_package_information RETURNING VALUE(r_dmo_packages) TYPE tt_dmo_packages.

    METHODS create_transport      RETURNING VALUE(lo_transport) TYPE sxco_transport.

    METHODS create_put_operation RETURNING VALUE(r_put_operation)
                                             TYPE REF  TO if_xco_gen_devc_o_put.


*    type ref to if_xco_gen_o_mass_put.

*     if_xco_cp_gen_devc_d_o_put.


ENDCLASS.



CLASS zcl_create_dmo_packages IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    transport_request = create_transport( ).

    dmo_packages = get_package_information( ).

    LOOP AT dmo_packages INTO dmo_package.

      dmo_package-package_name = dmo_package-package_name && test_string.

      "super package /dmo/sap must not be changed
      IF dmo_package-super_package_name <> co_dmo_sap_package.
        dmo_package-super_package_name = dmo_package-super_package_name && test_string.
      ENDIF.

      DATA(dmo_flight_package) = xco_abap_repository=>object->devc->for( dmo_package-package_name  ).
      out->write( |check package { dmo_package-package_name }| ).

      IF dmo_flight_package->exists(  ) = abap_true.
        out->write( | package { dmo_package-package_name } does exist| ).
      ELSE.
        out->write( | package { dmo_package-package_name } does not exist| ).
        IF create_packages = abap_true.
          out->write( | create package { dmo_package-package_name } | ).

          create_package_in_dmo_sap(
            EXPORTING
             i_transport          = transport_request
             i_package_name       = dmo_package-package_name
             i_super_package_name = dmo_package-super_package_name
             i_short_description  = dmo_package-short_description
            IMPORTING
             findings             = DATA(findings)
             exception_text       = DATA(exception_text)
           ).
          IF findings IS NOT INITIAL.
            out->write( 'Findings:' ).
            out->write( findings ).
          ENDIF.
          IF exception_text IS NOT INITIAL.
            out->write( |exception occured  { exception_text } | ).
          ENDIF.
        ELSE.
          out->write( | demo mode | ).
        ENDIF.
      ENDIF.

    ENDLOOP.



  ENDMETHOD.

  METHOD create_package_in_dmo_sap.

*    DATA put_operation TYPE REF TO if_xco_cp_gen_devc_d_o_put.
    DATA(put_operation) = create_put_operation( ).

    DATA short_description TYPE if_xco_gen_devc_s_form=>tv_short_description.
    IF i_short_description IS NOT INITIAL.
      short_description = i_short_description.
    ELSE.
      short_description = i_package_name.
    ENDIF.
    TRY.
        DATA(lo_specification) = put_operation->add_object( i_package_name )->create_form_specification( ).
        lo_specification->set_short_description( short_description ).
        lo_specification->properties->set_super_package( i_super_package_name )->set_software_component( co_dmo_sap_package ).
        IF transport_request IS NOT INITIAL.
          lo_specification->properties->set_record_object_changes( ).
        ENDIF.
        DATA(lo_result) = put_operation->execute( ).
        " handle findings
        DATA(lo_findings) = lo_result->findings.
        findings = lo_findings->get( ).
      CATCH cx_xco_gen_put_exception INTO DATA(generation_exception).
        exception_text = generation_exception->get_text(  ).
        findings = generation_exception->findings->get( ).
    ENDTRY.



  ENDMETHOD.

  METHOD get_package_information.
    r_dmo_packages = VALUE #(
*    ( package_name = '/DMO/FLIGHT' super_package_name = '/DMO/SAP' short_description = 'Flight Reference Scenario' )
    ( package_name = '/DMO/FLIGHT' super_package_name = '' short_description = 'Flight Reference Scenario' )
    ( package_name = '/DMO/FLIGHT_ANA' super_package_name = '/DMO/FLIGHT' short_description =
    'Flight Reference Scenario - Analytical Table' )
    ( package_name = '/DMO/FLIGHT_ANA_DG' super_package_name = '/DMO/FLIGHT_ANA' short_description =
    'Analytical Table - Data Generator' )
    ( package_name = '/DMO/FLIGHT_COLLDRAFT' super_package_name = '/DMO/FLIGHT' short_description =
    'Flight Reference Scenario: Collaborative Draft' )
    ( package_name = '/DMO/FLIGHT_DRAFT' super_package_name = '/DMO/FLIGHT' short_description = 'Flight Reference Scenario: Draft Guide'
    )
    ( package_name = '/DMO/FLIGHT_HIERARCHY' super_package_name = '/DMO/FLIGHT' short_description =
    'Hiearchy Guides' )
    ( package_name = '/DMO/FLIGHT_HIERARCHY_DRAFT' super_package_name = '/DMO/FLIGHT_HIERARCHY' short_description =
    'Hierarchy: Draft' )
    ( package_name = '/DMO/FLIGHT_HIERARCHY_DRAFT_D' super_package_name = '/DMO/FLIGHT_HIERARCHY_DRAFT' short_description =
    'Hierarchy: Draft: Data Generator' )
    ( package_name = '/DMO/FLIGHT_HIERARCHY_RO' super_package_name = '/DMO/FLIGHT_HIERARCHY' short_description =
    'Hierarchy: Read Only' )
    ( package_name = '/DMO/FLIGHT_HIERARCHY_RO_D' super_package_name = '/DMO/FLIGHT_HIERARCHY_RO' short_description =
    'Hierarchy: Read Only: Data Generator' )
    ( package_name = '/DMO/FLIGHT_LEGACY' super_package_name = '/DMO/FLIGHT' short_description =
    'Flight Reference Scenario: Legacy Objects' )
    ( package_name = '/DMO/FLIGHT_MANAGED' super_package_name = '/DMO/FLIGHT' short_description =
    'Flight Reference Scenario: TX managed E2E Guide' )
    ( package_name = '/DMO/FLIGHT_READONLY' super_package_name = '/DMO/FLIGHT' short_description =
    'Flight Reference Scenario: Read-Only E2E Guide' )
    ( package_name = '/DMO/FLIGHT_REC' super_package_name = '/DMO/FLIGHT' short_description = 'Flight Reference Scenario: Recommendations'
    )
    ( package_name = '/DMO/FLIGHT_REC_DG' super_package_name = '/DMO/FLIGHT_REC' short_description =
    'Data Generator Recommendations' )
    ( package_name = '/DMO/FLIGHT_REC_H' super_package_name = '/DMO/FLIGHT_REC' short_description =
    'Helper Package Recommendations' )
    ( package_name = '/DMO/FLIGHT_REUSE' super_package_name = '/DMO/FLIGHT' short_description = 'Flight Reference Scenario: Reused Entities'
    )
    ( package_name = '/DMO/FLIGHT_REUSE_AGENCY' super_package_name = '/DMO/FLIGHT_REUSE' short_description =
    'Flight Reference Scenario: Agency' )
    ( package_name = '/DMO/FLIGHT_REUSE_AGENCY_CNTRY' super_package_name = '/DMO/FLIGHT_REUSE_AGENCY' short_description =
    'Agency Extension: Country (Behavior Extensibility)' )
    ( package_name = '/DMO/FLIGHT_REUSE_AGENCY_DATGN' super_package_name = '/DMO/FLIGHT_REUSE_AGENCY' short_description =
    'Agency Extension: Data Generator' )
    ( package_name = '/DMO/FLIGHT_REUSE_AGENCY_REV' super_package_name = '/DMO/FLIGHT_REUSE_AGENCY' short_description =
    'Agency Extension: Review (Node Extensibility)' )
    ( package_name = '/DMO/FLIGHT_REUSE_AGENCY_REV_A' super_package_name = '/DMO/FLIGHT_REUSE_AGENCY_REV' short_description
    = 'Agency Extension: Review - Average' )
    ( package_name = '/DMO/FLIGHT_REUSE_AGENCY_REV_D' super_package_name = '/DMO/FLIGHT_REUSE_AGENCY_REV' short_description
    = 'Agency Extension: Derived Events' )
    ( package_name = '/DMO/FLIGHT_REUSE_AGENCY_REV_E' super_package_name = '/DMO/FLIGHT_REUSE_AGENCY_REV' short_description
    = 'Agency Extension: Events for Review' )
    ( package_name = '/DMO/FLIGHT_REUSE_AGENCY_SLOGN' super_package_name = '/DMO/FLIGHT_REUSE_AGENCY' short_description =
    'Agency Extension: Slogan (Field Extensibility)' )
    ( package_name = '/DMO/FLIGHT_REUSE_CARRIER' super_package_name = '/DMO/FLIGHT_REUSE' short_description =
    'Flight Reference Scenario: Carrier' )
    ( package_name = '/DMO/FLIGHT_REUSE_SUPPLEMENT' super_package_name = '/DMO/FLIGHT_REUSE' short_description =
    'Flight Reference Scenario: Supplement' )
    ( package_name = '/DMO/FLIGHT_UNMANAGED' super_package_name = '/DMO/FLIGHT' short_description =
    'Flight Reference Scenario: TX unmanaged E2E Guide' )
     ( package_name = '/DMO/FLIGHT_XBO' super_package_name = '/DMO/FLIGHT' short_description =
    'Flight Reference Scenario - Draft Scope' )
    ( package_name = '/DMO/FLIGHT_XBO_DG' super_package_name = '/DMO/FLIGHT_XBO' short_description =
    'Analytical Table - Draft Scope - Data Generator' )


     ).
  ENDMETHOD.

  METHOD create_put_operation.
*    DATA(environment) = xco_cp_generation=>environment->dev_system( transport_request  )  .

    IF transport_request IS NOT INITIAL.
      DATA(environment) = xco_generation=>environment->transported( transport_request ).
    ELSE.
      environment = xco_generation=>environment->local.
    ENDIF.

*    r_put_operation = environment->create_mass_put_operation( ).
    r_put_operation = environment->for-devc->create_put_operation( ).
  ENDMETHOD.
  METHOD create_transport.
    "create transport for /dmo/sap if needed or not (whether software component /DMO/SAP is of type 'K' or 'J')
*    DATA(ls_package) = xco_abap_repository=>object->devc->for( co_dmo_sap_package  ).
    DATA(ls_package) = xco_abap_repository=>object->devc->for( co_dmo_flight_package ).
    IF ls_package->read( )-property-record_object_changes = abap_true.
      DATA(lv_transport_layer) = ls_package->read( )-property-transport_layer->value.
      DATA(lv_transport_target) = ls_package->read( )-property-transport_layer->get_transport_target( )->value.
      DATA(lo_transport_request) = xco_cts=>transports->workbench( lv_transport_target )->create_request( '#Generated RAP110 tutorial transport request' ).
      lo_transport = lo_transport_request->value.
    ENDIF.
  ENDMETHOD.


ENDCLASS.
