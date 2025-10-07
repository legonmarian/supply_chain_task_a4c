@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Base view for Transporation Orders'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZC_TRANSPORTATION_ORDERS00   
  as select from ZC_ORDERS00 
    association [0..1] to ZC_ROUTES00 as _Route
      on ZC_ORDERS00.PlantId = _Route.Destination
{
  
  key _Route._DeparturePlant.City as DepartureCity,
  key _Route._DestinationPlant.City as DestinationCity,
  key _Material.TransportationGroup as TransportationGroup,
  
  sum(Quantity) as Quantity,
  
  
  _Route.Departure,
  _Route.Destination,
  _Route._DeparturePlant,
  _Route._DestinationPlant
  
}
group by _Material.TransportationGroup, _Route._DeparturePlant.City, _Route._DestinationPlant.City, _Route.Departure, _Route.Destination
