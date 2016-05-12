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
