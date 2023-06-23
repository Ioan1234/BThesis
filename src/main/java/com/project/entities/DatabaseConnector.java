package com.project.entities;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
public class DatabaseConnector {
    public static Connection getConnection() {
        JSONParser jsonParser = new JSONParser();
        JSONObject jsonObject=null;
        try {
            jsonObject = (JSONObject) jsonParser.parse(new FileReader("C:/Users/gogul/IdeaProjects/project/src/main/webapp/newjson.json"));
        } catch (ParseException | IOException e) {
            throw new RuntimeException(e);
        }

        String User = (String) jsonObject.get("username");
        String Pass = (String) jsonObject.get("password");
        String Driver = (String) jsonObject.get("driverName");
        String Drive = (String) jsonObject.get("driver");
        if (Driver != null) {
            try {
                Class.forName(Driver);
            } catch (ClassNotFoundException e) {
                throw new RuntimeException(e);
            }
        }

        try {
            Class.forName(Driver);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        Connection conn=null;
        try {
            conn = DriverManager.getConnection(Drive, User, Pass);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return conn;
    }
}


