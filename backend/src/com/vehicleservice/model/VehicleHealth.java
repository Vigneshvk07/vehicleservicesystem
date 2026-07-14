package com.vehicleservice.model;

public class VehicleHealth {
    private int id;
    private int vehicleId;
    private int batteryHealth;
    private int engineCondition;
    private int brakeStatus;
    private int oilLevel;
    private int tyreCondition;
    private int coolantLevel;
    private int overallHealth;

    public VehicleHealth() {}

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getVehicleId() {
        return vehicleId;
    }

    public void setVehicleId(int vehicleId) {
        this.vehicleId = vehicleId;
    }

    public int getBatteryHealth() {
        return batteryHealth;
    }

    public void setBatteryHealth(int batteryHealth) {
        this.batteryHealth = batteryHealth;
    }

    public int getEngineCondition() {
        return engineCondition;
    }

    public void setEngineCondition(int engineCondition) {
        this.engineCondition = engineCondition;
    }

    public int getBrakeStatus() {
        return brakeStatus;
    }

    public void setBrakeStatus(int brakeStatus) {
        this.brakeStatus = brakeStatus;
    }

    public int getOilLevel() {
        return oilLevel;
    }

    public void setOilLevel(int oilLevel) {
        this.oilLevel = oilLevel;
    }

    public int getTyreCondition() {
        return tyreCondition;
    }

    public void setTyreCondition(int tyreCondition) {
        this.tyreCondition = tyreCondition;
    }

    public int getCoolantLevel() {
        return coolantLevel;
    }

    public void setCoolantLevel(int coolantLevel) {
        this.coolantLevel = coolantLevel;
    }

    public int getOverallHealth() {
        return overallHealth;
    }

    public void setOverallHealth(int overallHealth) {
        this.overallHealth = overallHealth;
    }
}
