CLASS zcl_integration DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    " CONSTANTS
    CONSTANTS: base_url             TYPE string VALUE 'https://leldvdmd0m.execute-api.eu-west-1.amazonaws.com/api/1'.


    " STRUCTURE TYPES
    TYPES: ty_material              TYPE zmaterials00.
    TYPES: ty_plant                 TYPE zplants00.
    TYPES: ty_route                 TYPE zroutes00.
    TYPES: ty_order                 TYPE zorders00.
    TYPES: ty_transportation_order  TYPE zc_transportation_orders_api00.


    " TABLE TYPES
    TYPES: tt_materials             TYPE STANDARD TABLE OF ty_material             WITH DEFAULT KEY.
    TYPES: tt_plants                TYPE STANDARD TABLE OF ty_plant                WITH DEFAULT KEY.
    TYPES: tt_routes                TYPE STANDARD TABLE OF ty_route                WITH DEFAULT KEY.
    TYPES: tt_orders                TYPE STANDARD TABLE OF ty_order                WITH DEFAULT KEY.
    TYPES: tt_transportation_orders                TYPE STANDARD TABLE OF ty_transportation_order                WITH DEFAULT KEY.


    " GENERIC METHODS
    METHODS: get_api                    IMPORTING url         TYPE string
                                        RETURNING VALUE(data) TYPE string
                                        RAISING cx_web_http_client_error
                                                cx_http_dest_provider_error.

    " API TYPES
    TYPES: BEGIN OF ty_materials_api,
              materials              TYPE tt_materials,
            END OF ty_materials_api.

    TYPES: BEGIN OF ty_plants_api,
              plants                 TYPE tt_plants,
            END OF ty_plants_api.

    TYPES: BEGIN OF ty_routes_api,
              routes                 TYPE tt_routes,
            END OF ty_routes_api.

    TYPES: BEGIN OF ty_orders_api,
              orders                 TYPE tt_orders,
            END OF ty_orders_api.

    " API METHODS
    METHODS: get_materials              RETURNING VALUE(data) TYPE tt_materials
                                        RAISING cx_web_http_client_error
                                                cx_http_dest_provider_error.
    METHODS: get_plants                 RETURNING VALUE(data) TYPE tt_plants
                                        RAISING cx_web_http_client_error
                                                cx_http_dest_provider_error.
    METHODS: get_routes                 RETURNING VALUE(data) TYPE tt_routes
                                        RAISING cx_web_http_client_error
                                                cx_http_dest_provider_error.
    METHODS: get_orders                 RETURNING VALUE(data) TYPE tt_orders
                                        RAISING cx_web_http_client_error
                                                cx_http_dest_provider_error.

    METHODS: post_transportation_orders IMPORTING data TYPE tt_transportation_orders
                                        RETURNING VALUE(text) TYPE string
                                        RAISING cx_web_http_client_error
                                                cx_http_dest_provider_error.

    " DATA MODELLING METHODS
    METHODS: get_transportation_orders  IMPORTING orders      TYPE tt_orders
                                                  plants      TYPE tt_plants
                                                  routes      TYPE tt_routes
                                                  materials   TYPE tt_materials
                                        RETURNING VALUE(data) TYPE tt_transportation_orders.

    METHODS: get_transportation_orders_cds RETURNING VALUE(data) TYPE tt_transportation_orders.

    " SAVE METHODS
    METHODS: save_materials           IMPORTING data         TYPE tt_materials.
    METHODS: save_plants              IMPORTING data         TYPE tt_plants.
    METHODS: save_routes              IMPORTING data         TYPE tt_routes.
    METHODS: save_orders              IMPORTING data         TYPE tt_orders.
ENDCLASS.



CLASS zcl_integration IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TRY.
        FINAL(materials) = get_materials( ).
        FINAL(plants) = get_plants( ).
        FINAL(routes) = get_routes( ).
        FINAL(orders) = get_orders( ).

        save_materials( materials ).
        save_plants( plants ).
        save_routes( routes ).
        save_orders( orders ).

        " choose either via CDS or via LOOP
*        FINAL(transportation_orders) = get_transportation_orders( materials = materials
*                                                                  plants    = plants
*                                                                  routes    = routes
*                                                                  orders    = orders ).

        FINAL(transportation_orders) = get_transportation_orders_cds( ).

        FINAL(result) = post_transportation_orders( transportation_orders ).

        out->write( result ).
      CATCH cx_web_http_client_error cx_http_dest_provider_error into DATA(lx).
        out->write( lx ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_api.
    FINAL(destination) = cl_http_destination_provider=>create_by_url( url ).
    FINAL(client) = cl_web_http_client_manager=>create_by_http_destination( destination ).
    FINAL(response) = client->execute( if_web_http_client=>get ).
    FINAL(text) = response->get_text( ).
    RETURN text.
  ENDMETHOD.

  METHOD save_materials.
    DELETE FROM zmaterials00.
    MODIFY zmaterials00 FROM TABLE @data.
  ENDMETHOD.

  METHOD save_orders.
    DELETE FROM zorders00.
    MODIFY zorders00 FROM TABLE @data.
  ENDMETHOD.

  METHOD save_plants.
    DELETE FROM zplants00.
    MODIFY zplants00 FROM TABLE @data.
  ENDMETHOD.

  METHOD save_routes.
    DELETE FROM zroutes00.
    MODIFY zroutes00 FROM TABLE @data.
  ENDMETHOD.

  METHOD get_materials.
    FINAL(url) = |{ base_url }/materials|.
    FINAL(response_json) = get_api( url ).

    DATA: response TYPE ty_materials_api.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json = response_json
      CHANGING
        data = response
    ).

    RETURN response-materials.
  ENDMETHOD.

  METHOD get_orders.
    FINAL(url) = |{ base_url }/orders|.
    FINAL(response_json) = get_api( url ).

    DATA: response TYPE ty_orders_api.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json = response_json
      CHANGING
        data = response
    ).

    RETURN response-orders.
  ENDMETHOD.

  METHOD get_plants.
    FINAL(url) = |{ base_url }/plants|.
    FINAL(response_json) = get_api( url ).

    DATA: response TYPE ty_plants_api.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json = response_json
      CHANGING
        data = response
    ).

    RETURN response-plants.
  ENDMETHOD.

  METHOD get_routes.
    FINAL(url) = |{ base_url }/routes|.
    FINAL(response_json) = get_api( url ).

    DATA: response TYPE ty_routes_api.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json = response_json
      CHANGING
        data = response
    ).

    RETURN response-routes.
  ENDMETHOD.

  METHOD post_transportation_orders.
    FINAL(url) = |{ base_url }/transportation_orders|.
    FINAL(destination) = cl_http_destination_provider=>create_by_url( url ).
    FINAL(client) = cl_web_http_client_manager=>create_by_http_destination( destination ).


    FINAL(request) = client->get_http_request( ).
    FINAL(json) = /ui2/cl_json=>serialize( pretty_name = /ui2/cl_json=>pretty_mode-low_case
                                            data        = data ).

    request->set_text( json ).
    request->set_content_type( 'application/json' ).

    FINAL(response) = client->execute( if_web_http_client=>post ).
    FINAL(response_text) = response->get_text( ).

    RETURN response_text.
  ENDMETHOD.

  METHOD get_transportation_orders.
    DATA: transportation_orders TYPE tt_transportation_orders.

    LOOP AT orders INTO FINAL(order).
      FINAL(quantity) = order-quantity.

      FINAL(destination_plant) = plants[ id = order-plant_id ].
      FINAL(destination_city) = destination_plant-city.

      FINAL(route) = routes[ destination = order-plant_id ].
      FINAL(departure_plant_id) = route-departure.
      FINAL(departure_plant) = plants[ id = departure_plant_id ].
      FINAL(departure_city) = departure_plant-city.

      FINAL(material) = materials[ id = order-material_id ].
      FINAL(transportation_group) = material-transportation_group.

      READ TABLE transportation_orders ASSIGNING FIELD-SYMBOL(<transportation_order>)
            WITH KEY departure_city       = departure_city
                    destination_city     = destination_city
                    transportation_group = transportation_group.

      IF sy-subrc = 0.
        <transportation_order>-quantity = <transportation_order>-quantity + quantity.
      ELSE.
        APPEND VALUE #(
                  departure_city       = departure_city
                  destination_city     = destination_city
                  transportation_group = transportation_group
                  quantity             = quantity )
                TO transportation_orders.
      ENDIF.
    ENDLOOP.

    RETURN transportation_orders.
  ENDMETHOD.

  METHOD get_transportation_orders_cds.
    SELECT * FROM zc_transportation_orders_api00
    INTO TABLE @data.
  ENDMETHOD.

ENDCLASS.
