/*
  Project Euler # 2 - Even Fibonacci Numbers
  
Each new term in the Fibonacci sequence is generated by adding the previous two terms. By starting with 1 and 2, the first 10 terms will be:

1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ...

By considering the terms in the Fibonacci sequence whose values do not exceed four million, find the sum of the even-valued terms.

/*

var x = 0;
var x1 = 1;
var x2 = 1;
var sum = 0;

while (x < 4000000){
  if(x % 2 === 0){
    sum += x;
  }
  x = x1 + x2;
  x1 = x2;
  x2 = x;
}

sum;

/*
4613732
*/
