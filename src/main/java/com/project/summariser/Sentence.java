package com.project.summariser;

class Sentence{
    int paragraphNumber;
    int number;
    int stringLength;
    double score;
    int noOfWords;
    String value;

    Sentence(int number, String value, int stringLength, int paragraphNumber){
        this.number = number;
        this.value = value;
        this.stringLength = stringLength;
        noOfWords = value.split("\\s+").length;
        score = 0.0;
        this.paragraphNumber=paragraphNumber;
    }
}
