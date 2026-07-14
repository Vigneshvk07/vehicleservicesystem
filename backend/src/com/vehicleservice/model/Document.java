package com.vehicleservice.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Document {
    private int id;
    private Integer userId; // Nullable
    private Integer vehicleId; // Nullable
    private String documentType; // 'DL', 'RC', 'INSURANCE', 'PUC', 'AADHAR', 'VEHICLE_PHOTO'
    private String fileName;
    private String filePath;
    private long fileSize;
    private Date expiryDate;
    private Timestamp uploadedAt;

    public Document() {}

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getVehicleId() {
        return vehicleId;
    }

    public void setVehicleId(Integer vehicleId) {
        this.vehicleId = vehicleId;
    }

    public String getDocumentType() {
        return documentType;
    }

    public void setDocumentType(String documentType) {
        this.documentType = documentType;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public long getFileSize() {
        return fileSize;
    }

    public void setFileSize(long fileSize) {
        this.fileSize = fileSize;
    }

    public Date getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }

    public Timestamp getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(Timestamp uploadedAt) {
        this.uploadedAt = uploadedAt;
    }

    /**
     * Checks if the document is still valid (not expired).
     */
    public boolean isValid() {
        if (expiryDate == null) return true;
        return expiryDate.after(new Date(System.currentTimeMillis()));
    }
}
