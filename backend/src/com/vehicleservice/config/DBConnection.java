package com.vehicleservice.config;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnection {
    private static Properties properties = new Properties();

    static {
        try (InputStream input = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input == null) {
                System.err.println("Sorry, unable to find db.properties. Using default fallback configuration.");
                // Fallback default properties
                properties.setProperty("db.driver", "com.mysql.cj.jdbc.Driver");
                properties.setProperty("db.url", "jdbc:mysql://localhost:3306/vehicleservicesystem");
                properties.setProperty("db.user", "root");
                properties.setProperty("db.password", "Root");
            } else {
                properties.load(input);
            }
            // Load driver class
            Class.forName(properties.getProperty("db.driver"));
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
            properties.getProperty("db.url"),
            properties.getProperty("db.user"),
            properties.getProperty("db.password")
        );
    }
}
