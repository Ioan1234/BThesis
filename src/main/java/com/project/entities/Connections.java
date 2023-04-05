package com.project.entities;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.Statement;
public class Connections {
    private static String dbUrl = "jdbc:mysql://localhost:3306/news_website";
    private static String dbUsername = "root";
    private static String dbPassword = "Goaga123";

    public static Connection getConnection() throws SQLException
    {
        return DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
    }
}
