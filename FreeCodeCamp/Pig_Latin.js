/* Pig Latin - FreeCodeCamp
Translate the provided string to pig latin.

Pig Latin takes the first consonant (or consonant cluster) of an English word, moves it to the end of the word and suffixes an "ay".

If a word begins with a vowel you just add "way" to the end.
*/

function translatePigLatin(str) {
var vowels = ['a', 'e', 'i', 'o', 'u'];
  
    for(var x = 0; x < str.length; x++){
      for(var y = 0; y < vowels.length; y++){
        if(str.charAt(0) === vowels[y]){
          return str + 'way';
        } else if(str.charAt(x) === vowels[y]){
          return str.substr(x, str.length) + str.substr(0, x) + 'ay';
        } 
      } 
    }  
}
translatePigLatin("consonant");

/*
onsonantcay
*/


/* update 2017/08/12 !!!  removed nested loop */

function pigLatin(str){
    var vowels = {
        a: true, e: true, i: true,
        o: true, u: true
    };
    var len = str.length;
  
    if(str.charAt(0) in vowels){
        return str + 'way';
    }
  
    for(var i = 0; i < len; i++){
        if(str.charAt(i) in vowels){
            return str.substr(i, len) + str.substr(0, i) + 'ay';
        }
    }
}
       
       
       
