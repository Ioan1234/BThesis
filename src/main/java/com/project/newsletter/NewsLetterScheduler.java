package com.project.newsletter;

import com.project.entities.DatabaseConnector;

import java.sql.Connection;
import java.util.Calendar;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

public class NewsLetterScheduler {

    Timer timer;

    public NewsLetterScheduler() {

        Calendar calendar = Calendar.getInstance();
        // Set the time of the day the task is scheduled for
        calendar.set(Calendar.HOUR_OF_DAY, 19);
        calendar.set(Calendar.MINUTE, 35);
        calendar.set(Calendar.SECOND, 0);

        Date time = calendar.getTime();
        timer = new Timer();

        // If the scheduled time has passed today, schedule for next day
        if (time.before(new Date())) {
            calendar.add(Calendar.DATE, 1);
            time = calendar.getTime();
        }

        // Schedule the task
        //timer.schedule(new NewsletterTask(), time, 1000 * 60 * 60 * 24);
        timer.schedule(new NewsletterTask(), 0, 1000 * 60 * 60 * 24);

    }

    class NewsletterTask extends TimerTask {

        public void run() {
            System.out.println("Starting newsletter task...");
            Connection conn = DatabaseConnector.getConnection();
            // Call the method to send newsletters here
            Newsletter newsletterSender = new Newsletter(conn);
            try {
                newsletterSender.sendNewsletters();
            } catch (Exception e) {
                // Handle exception
                e.printStackTrace();
            }
            System.out.println("Newsletter task finished.");
        }
    }

}

