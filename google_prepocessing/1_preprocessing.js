///https://github.com/gee-community/gee_tools
//https://github.com/kongdd/gee_monkey
var starting_date = ee.Date('1990-08-01');
var end_date  = ee.Date('2019-01-01');
var folderl8 = "Ayuqila_l8"
var folderl7 = "Ayuqila_l7"
var folderl5 = "Ayuqila_l5"
var path = 29
var row = 46
var fc = ee.FeatureCollection('users/aquevedo/Extent_ayuquila');
var batch = require('users/fitoprincipe/geetools:batch');

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




var ndviVis = {
  min: -1,
  max: 1,
  palette: [
    'FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718', '74A901',
    '66A000', '529400', '3E8601', '207401', '056201', '004C00', '023B01',
    '012E01', '011D01', '011301'
  ],
};

Map.setCenter(-104.1360,19.6478, 9);
Map.addLayer(collectionL8.first(), ndviVis, 'NDVI')

/////////To export remove the comments in lines 95 and 114
/*
batch.Download.ImageCollection.toDrive(collectionL8, "L8_AYUQUILA", 
                {scale: 30, 
                 region: fc, 
                 maxPixels: 1e12,
                 type: 'float'})


batch.Download.ImageCollection.toDrive(collectionL7, "L7_AYUQUILA", 
                {scale: 30, 
                 region: fc, 
                 maxPixels: 1e12,
                 type: 'float'})
                 
batch.Download.ImageCollection.toDrive(collectionL5, "L5_AYUQUILA", 
                {scale: 30, 
                 region: fc, 
                 maxPixels: 1e12,
                 type: 'float'})
*/


