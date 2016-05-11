/*
Caeser's Cipher from FreeCodeCamp

Limits - A = 65, Z = 90
If the character code is equal to or less than 77, add 13.
Otherwise, subtract 13.
*/

function rot13(str) { // LBH QVQ VG!
  //Array for converted character codes
  var numConv = [];
  //Array for converted letters
  var newStrArr = [];
  
  //Looping through the original string to check its character code values
  //And pushing them to an array
  for(var x = 0; x < str.length; x++){
    var char = str.charCodeAt(x);
    if(char >= 65 && char <= 77){
      numConv.push(char + 13);
    } else if(char > 77 && char <= 90){
      numConv.push(char - 13);
    } else {
      numConv.push(char);
    }
  }
  
  //Looping through the character code array and converting them back into letters
  for(var y = 0; y < numConv.length; y++){
    newStrArr.push(String.fromCharCode(numConv[y]));
  }
  
  return newStrArr.join('');
}

// Change the inputs below to test
rot13("SERR PBQR PNZC");

/*
FREE CODE CAMP
*/
