package com.project.summariser;

import java.io.Reader;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;


public class SummaryTool{
    ArrayList<Sentence> sentences, contentSummary;
    ArrayList<Paragraph> paragraphs;
    int noOfSentences, noOfParagraphs;

    double[][] intersectionMatrix;
    LinkedHashMap<Sentence,Double> dictionary;
    String content;

    public SummaryTool(){
        noOfSentences = 0;
        noOfParagraphs = 0;
    }

    public void init() {
        sentences = new ArrayList<Sentence>();
        paragraphs = new ArrayList<Paragraph>();
        contentSummary = new ArrayList<Sentence>();
        dictionary = new LinkedHashMap<Sentence,Double>();
        noOfSentences = 0;
        noOfParagraphs = 0;
    }


    /*Gets the sentences from the entire passage*/
    public void extractSentenceFromContext() {
        int nextChar, j = 0;
        int prevChar = -1;
        try {
            Reader reader = new StringReader(this.content);
            while((nextChar = reader.read()) != -1) {
                j = 0;
                char[] temp = new char[100000];
                while((char)nextChar != '.') {
                    temp[j] = (char)nextChar;
                    if((nextChar = reader.read()) == -1){
                        break;
                    }
                    if((char)nextChar == '\n' && (char)prevChar == '\n'){
                        noOfParagraphs++;
                    }
                    j++;
                    prevChar = nextChar;
                }
                sentences.add(new Sentence(noOfSentences,(new String(temp)).trim(),(new String(temp)).trim().length(),noOfParagraphs));
                noOfSentences++;
                prevChar = nextChar;
            }
        }catch(Exception e){
            e.printStackTrace();
        }
    }

    // Add a method to return the summary as a single string:
    public String summaryToString() {
        StringBuilder sb = new StringBuilder();
        for (Sentence sentence : contentSummary) {
            sb.append(sentence.value).append(". ");
        }
        return sb.toString();
    }
    public void groupSentencesIntoParagraphs(){
        int paraNum = 0;
        Paragraph paragraph = new Paragraph(0);

        for(int i=0;i<noOfSentences;i++){
            if(sentences.get(i).paragraphNumber == paraNum){
                //continue
            }else{
                paragraphs.add(paragraph);
                paraNum++;
                paragraph = new Paragraph(paraNum);

            }
            paragraph.sentences.add(sentences.get(i));
        }

        paragraphs.add(paragraph);
    }

    double noOfCommonWords(Sentence str1, Sentence str2){
        double commonCount = 0;

        for(String str1Word : str1.value.split("\\s+")){
            for(String str2Word : str2.value.split("\\s+")){
                if(str1Word.compareToIgnoreCase(str2Word) == 0){
                    commonCount++;
                }
            }
        }

        return commonCount;
    }
    public void setContent(String content) {
        this.content = content;
    }
    public void createIntersectionMatrix(){
        intersectionMatrix = new double[noOfSentences][noOfSentences];
        for(int i=0;i<noOfSentences;i++){
            for(int j=0;j<noOfSentences;j++){

                if(i<=j){
                    Sentence str1 = sentences.get(i);
                    Sentence str2 = sentences.get(j);
                    intersectionMatrix[i][j] = noOfCommonWords(str1,str2) / ((double)(str1.noOfWords + str2.noOfWords) /2);
                }else{
                    intersectionMatrix[i][j] = intersectionMatrix[j][i];
                }

            }
        }
    }

    public void createDictionary(){
        for(int i=0;i<noOfSentences;i++){
            double score = 0;
            for(int j=0;j<noOfSentences;j++){
                score+=intersectionMatrix[i][j];
            }
            dictionary.put(sentences.get(i), score);
            sentences.get(i).score = score;
        }
    }

    public void createSummary(){

        for(int j=0;j<=noOfParagraphs;j++){
            int primary_set = paragraphs.get(j).sentences.size()/5;

            //Sort based on score (importance)
            Collections.sort(paragraphs.get(j).sentences,new SentenceComparator());
            for(int i=0;i<=primary_set;i++){
                contentSummary.add(paragraphs.get(j).sentences.get(i));
            }
        }

        //To ensure proper ordering
        Collections.sort(contentSummary,new SentenceComparatorForSummary());

    }


}