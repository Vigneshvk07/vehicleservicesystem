package com.vehicleservice.model;

public class Vehicle {
    private int id;
    private int customerId;
    private String vehicleNumber;
    private String type; // 'Car', 'Bike'
    private String brand;
    private String model;
    private int year;

    public Vehicle() {}

    public Vehicle(int id, int customerId, String vehicleNumber, String type, String brand, String model, int year) {
        this.id = id;
        this.customerId = customerId;
        this.vehicleNumber = vehicleNumber;
        this.type = type;
        this.brand = brand;
        this.model = model;
        this.year = year;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getVehicleNumber() {
        return vehicleNumber;
    }

    public void setVehicleNumber(String vehicleNumber) {
        this.vehicleNumber = vehicleNumber;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }
}
