@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view Transportation Orders'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZC_TRANSPORTATION_ORDERS_API00 
  as select from ZC_TRANSPORTATION_ORDERS00
{
  key DestinationCity      as destination_city,
  key DepartureCity        as departure_city,
  key TransportationGroup  as transportation_group,
  Quantity                 as quantity
}
