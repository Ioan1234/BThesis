package com.project.newsScraper;

import com.project.entities.DatabaseConnector;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;

public class ContentFetcher {
    private final String url;
    Connection conn = DatabaseConnector.getConnection();

    public ContentFetcher(String url) {
        this.url = url;
    }

    public List<ContentBlock> fetchContent(String url) {
        List<ContentBlock> contentBlocks = new ArrayList<>();
        try {
            Document doc = Jsoup.connect(url).get();
            String unwantedText = "Autorul comentariului va fi singurul responsabil de conținutul comentariului și își va asuma eventualele daune, în cazul unor acțiuni legale împotriva celor publicate. Prin apasarea butonului \"Trimite comentariu\", sunteți de acord cu \"Termenii și condițiile de utilizare ale site-ului HotNews.ro\". Dacă nu sunteți de acord, apăsați butonul \"Renunță\".";

            Elements bodyElements;
            if (url.contains("biziday.ro")) {
                bodyElements = doc.select("div.post-content p:not([id=app]), div.post-content ul:not(:last-of-type):not([id=app]), div.post-content img:not([id=app])");
            } else if (url.contains("hotnews.ro")) {
                bodyElements = doc.select("p:not(.footer-row p):not([id=app]), ul:not(:last-of-type):not([id=app]), img.lead-img:not([id=app]), p img:not([id=app])");
            } else {
                return contentBlocks; // Not a recognized URL
            }

            for (Element bodyElement : bodyElements) {
                if (bodyElement.tagName().equals("img")) {
                    String src = bodyElement.attr("src");
                    contentBlocks.add(new ContentBlock("image", src));
                } else {
                    String text = bodyElement.text();
                    if (!text.contains(unwantedText)) {  // Exclude if unwanted text is contained
                        contentBlocks.add(new ContentBlock("text", text));
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return contentBlocks;
    }



    public String fetchTitle (String articleUrl){
            String title = "";
            try {
                Document doc = Jsoup.connect(articleUrl).get();
                Element titleElement;
                if (url.contains("biziday.ro")) {
                    titleElement = doc.select("h1.post-title").first();
                } else if (url.contains("hotnews.ro")) {
                    titleElement = doc.select("h1.title").first();
                } else {
                    return title; // Not a recognized URL
                }

                if (titleElement != null) {
                    title = titleElement.text();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
            return title;
        }
    }



