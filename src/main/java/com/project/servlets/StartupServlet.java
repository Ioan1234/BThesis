package com.project.servlets;

import com.project.newsScraper.NewsScraperTask;
import com.project.newsVerification.NewsVerificationTask;
import com.project.newsletter.NewsLetterScheduler;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;

import java.util.Timer;

@WebServlet(name = "StartupServlet", urlPatterns = {"/StartupServlet"}, loadOnStartup = 1)
public class StartupServlet extends HttpServlet {

    @Override
    public void init() throws ServletException {
        Timer timer = new Timer();
        timer.schedule(new NewsScraperTask(), 0, 60*1000); // execute every minute
        timer.schedule(new NewsVerificationTask(), 30*60*1000, 60*60*1000);
        NewsLetterScheduler scheduler=new NewsLetterScheduler();
    }
}
