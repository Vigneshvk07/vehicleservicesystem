package com.vehicleservice.model;

public class ServicePackage {
    private int id;
    private String name;
    private String description;
    private double cost;
    private int durationHours;

    public ServicePackage() {}

    public ServicePackage(int id, String name, String description, double cost, int durationHours) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.cost = cost;
        this.durationHours = durationHours;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getCost() {
        return cost;
    }

    public void setCost(double cost) {
        this.cost = cost;
    }

    public int getDurationHours() {
        return durationHours;
    }

    public void setDurationHours(int durationHours) {
        this.durationHours = durationHours;
    }
}
