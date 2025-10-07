@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Composite for Routes'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZC_ROUTES00 as select from zi_routes00
    association [0..1] to zi_plants00 as _DestinationPlant
      on  $projection.Destination = _DestinationPlant.Id
    association [0..1] to zi_plants00 as _DeparturePlant
      on  $projection.Departure = _DeparturePlant.Id
{
  key Destination,
  Departure,
  
  _DestinationPlant,
  _DeparturePlant
}
