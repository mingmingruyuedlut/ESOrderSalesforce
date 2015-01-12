function getDependentOptions(objName, ctrlFieldName, depFieldName) {
  // Isolate the Describe info for the relevant fields
  var objDesc = sforce.connection.describeSObject(objName);
  var ctrlFieldDesc, depFieldDesc;
  var found = 0;
  for (var i = 0; i < objDesc.fields.length; i++) {
    var f = objDesc.fields[i];
    if (f.name == ctrlFieldName) {
      ctrlFieldDesc = f;
      found++;
    } else if (f.name == depFieldName) {
      depFieldDesc = f;
      found++;
    }
    if (found == 2) break;
  }

  // Set up return object
  var dependentOptions = {};
  var ctrlValues = ctrlFieldDesc.picklistValues;
  for (var i = 0; i < ctrlValues.length; i++) {
    dependentOptions[ctrlValues[i].label] = [];
  }

  var base64 = new sforce.Base64Binary("");
  function testBit(validFor, pos) {
    var byteToCheck = Math.floor(pos / 8);
    var bit = 7 - (pos % 8);
    return ((Math.pow(2, bit) & validFor.charCodeAt(byteToCheck)) >> bit) == 1;
  }
  // For each dependent value, check whether it is valid for each controlling value
  var depValues = depFieldDesc.picklistValues;
  for (var i = 0; i < depValues.length; i++) {
    var thisOption = depValues[i];
    var validForDec = base64.decode(thisOption.validFor);
    for (var ctrlValue = 0; ctrlValue < ctrlValues.length; ctrlValue++) {
      if (testBit(validForDec, ctrlValue)) {
        dependentOptions[ctrlValues[ctrlValue].label].push(thisOption.label);
      }
    }
  }
  return dependentOptions;
}
