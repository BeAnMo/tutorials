/* DNA Pairing - FreeCodeCamp
The DNA strand is missing the pairing element. Take each character, get its pair, and return the results as a 2d array.

Base pairs are a pair of AT and CG. Match the missing element to the provided character.

Return the provided character as the first element in each array.

For example, for the input GCG, return [["G", "C"], ["C","G"],["G", "C"]]

The character and its pair are paired up in an array, and all the arrays are grouped into one encapsulating array.
*/

function pairElement(str) {
  var dna = str.split('');
  
  var multiArr = new Array(dna.length);
  for (var x = 0; x < dna.length; x++) {
	  multiArr[x] = [dna[x], ' '];
	
    switch (dna[x][0]){
      case 'G':
        multiArr[x][1] = 'C';
        break;
      case 'C':
        multiArr[x][1] = 'G';
        break;
      case 'A':
        multiArr[x][1] = 'T';
        break;
      case 'T':
        multiArr[x][1] = 'A';
        break;
	}
}
  
  
  
  return multiArr;
}

pairElement("GCG");

/*
G,C,C,G,G,C
*/
