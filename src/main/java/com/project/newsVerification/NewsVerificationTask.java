package com.project.newsVerification;
import java.util.TimerTask;
    public class NewsVerificationTask extends TimerTask {
        @Override
        public void run() {
            NewsVerificationUtil.verifyAndDeleteEmptyNews();
        }
    }

