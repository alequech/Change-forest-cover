///https://github.com/gee-community/gee_tools
//https://github.com/kongdd/gee_monkey
var starting_date = ee.Date('1985-11-01');
var end_date  = ee.Date('2019-01-01');
var folderl8 = "Chamelal8"
var folderl7 = "Chamelal7"
var folderl5 = "Chamelal5"
var path = 30
var row = 46
var fc = ee.FeatureCollection('users/aquevedo/chamela');
var tools = require('users/fitoprincipe/geetools:tools');
print(tools.options);

function maskL8sr(image) {
  // Bits 3 and 5 are cloud shadow and cloud, respectively.
  var cloudShadowBitMask = (1 << 3);
  var cloudsBitMask = (1 << 5);
  // Get the pixel QA band.
  var qa = image.select('pixel_qa');
  // Both flags should be set to zero, indicating clear conditions.
  var mask = qa.bitwiseAnd(cloudShadowBitMask).eq(0)
                 .and(qa.bitwiseAnd(cloudsBitMask).eq(0));
  return image.updateMask(mask);
}

function cloudMaskL457(image) {
  var qa = image.select('pixel_qa');
  // If the cloud bit (5) is set and the cloud confidence (7) is high
  // or the cloud shadow bit is set (3), then it's a bad pixel.
  var cloud = qa.bitwiseAnd(1 << 5)
                  .and(qa.bitwiseAnd(1 << 7))
                  .or(qa.bitwiseAnd(1 << 3));
  // Remove edge pixels that don't occur in all bands
  var mask2 = image.mask().reduce(ee.Reducer.min());
  return image.updateMask(cloud.not()).updateMask(mask2);
}

var addNDVI = function(image){
  var ndvi = image.normalizedDifference(['B4','B3']).rename('NDVI');
  return image.addBands(ndvi);
};

var addNDVI2 = function(image){
  var ndvi = image.normalizedDifference(['B5','B4']).rename('NDVI');
  return image.addBands(ndvi);
};
var collectionL8 = ee.ImageCollection('LANDSAT/LC08/C01/T1_SR')
                  .filterDate(starting_date, end_date)
                  .filter(ee.Filter.eq('WRS_PATH', path))
                  .filter(ee.Filter.eq('WRS_ROW', row))
                  .map(maskL8sr)
                  .map(addNDVI2).select('NDVI')
                  .map(function(image){return image.clip(fc)})
                  .sort('SENSING_TIME');
                  
var collectionL7 = ee.ImageCollection('LANDSAT/LE07/C01/T1_SR')
                  .filterDate(starting_date, end_date)
                  .filter(ee.Filter.eq('WRS_PATH', path))
                  .filter(ee.Filter.eq('WRS_ROW', row))
                  .map(cloudMaskL457)
                  .map(addNDVI).select('NDVI')
                  .map(function(image){return image.clip(fc)})
                  .sort('SENSING_TIME');  

var collectionL5 = ee.ImageCollection('LANDSAT/LT05/C01/T1_SR')
                  .filterDate(starting_date, end_date)
                  .filter(ee.Filter.eq('WRS_PATH', path))
                  .filter(ee.Filter.eq('WRS_ROW', row))
                  .map(cloudMaskL457)
                  .map(addNDVI).select('NDVI')
                  .map(function(image){return image.clip(fc)})
                  .sort('SENSING_TIME');  
                         
print('CollectionL8: ', collectionL8);
print('CollectionL7: ', collectionL7);
print('CollectionL5: ', collectionL5);
tools.col2drive(collectionL8, folderl8,{scale:30,region:fc});
tools.col2drive(collectionL7, folderl7,{scale:30,region:fc});
tools.col2drive(collectionL5, folderl5,{scale:30,region:fc});



