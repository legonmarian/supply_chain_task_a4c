@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Composite for Orders'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZC_ORDERS00 
  as select from zi_orders00
    association [0..1] to zi_plants00 as _DestinationPlant
      on  $projection.PlantId = _DestinationPlant.Id
    association [0..1] to zI_materials00 as _Material
      on  $projection.MaterialId = _Material.Id
{
  key UserId,
  key PlantId,
  key MaterialId,
  Quantity,
  
  _Material,
  _DestinationPlant
}
