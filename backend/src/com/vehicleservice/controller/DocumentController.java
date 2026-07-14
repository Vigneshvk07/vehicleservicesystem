package com.vehicleservice.controller;

import com.vehicleservice.dao.DocumentDAO;
import com.vehicleservice.model.Document;
import com.vehicleservice.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.Date;

@WebServlet("/DocumentController")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
    maxFileSize = 1024 * 1024 * 5,       // 5 MB max file size
    maxRequestSize = 1024 * 1024 * 25    // 25 MB max request size
)
public class DocumentController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DocumentDAO documentDAO = new DocumentDAO();
    
    // Absolute workspace upload path for persistence, and local context path for immediate serving
    private static final String WORKSPACE_UPLOAD_DIR = "/Users/vignesh/Desktop/VehicleServiceSystem/frontend/uploads";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/profile.jsp");
            return;
        }

        if ("upload".equalsIgnoreCase(action)) {
            handleUpload(request, response, currentUser);
        } else if ("delete".equalsIgnoreCase(action)) {
            handleDelete(request, response, currentUser);
        }
    }

    private void handleUpload(HttpServletRequest request, HttpServletResponse response, User user) 
            throws ServletException, IOException {
        
        String docType = request.getParameter("documentType"); // 'DL', 'RC', 'INSURANCE', 'PUC', 'AADHAR', 'VEHICLE_PHOTO'
        String vehicleIdStr = request.getParameter("vehicleId");
        String expiryDateStr = request.getParameter("expiryDate");

        Integer vehicleId = (vehicleIdStr != null && !vehicleIdStr.isEmpty()) ? Integer.parseInt(vehicleIdStr) : null;
        Date expiryDate = (expiryDateStr != null && !expiryDateStr.isEmpty()) ? Date.valueOf(expiryDateStr) : null;

        Part filePart = request.getPart("documentFile");
        if (filePart == null || filePart.getSize() == 0) {
            redirectWithError(request, response, docType, "Please select a file to upload");
            return;
        }

        // File Size Validation (Max 5MB)
        long fileSize = filePart.getSize();
        if (fileSize > 1024 * 1024 * 5) {
            redirectWithError(request, response, docType, "File size exceeds maximum limit of 5MB");
            return;
        }

        // Allowed file type validation (PDF, JPG, PNG)
        String contentDisposition = filePart.getHeader("content-disposition");
        String fileName = getFileName(contentDisposition);
        String fileExt = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
        
        if (!fileExt.equals("pdf") && !fileExt.equals("jpg") && !fileExt.equals("jpeg") && !fileExt.equals("png")) {
            redirectWithError(request, response, docType, "Allowed file formats are PDF, JPG, JPEG, and PNG");
            return;
        }

        // Unique file name to prevent collision
        String uniqueFileName = docType + "_" + System.currentTimeMillis() + "_" + fileName;
        
        // Define directory paths
        String subFolder = docType.toLowerCase();
        String relativePath = "uploads/" + subFolder + "/" + uniqueFileName;
        
        // Save to project workspace uploads folder
        File workspaceDir = new File(WORKSPACE_UPLOAD_DIR + File.separator + subFolder);
        if (!workspaceDir.exists()) workspaceDir.mkdirs();
        filePart.write(workspaceDir.getAbsolutePath() + File.separator + uniqueFileName);

        // Also save to running deployment context so it is immediately visible
        String contextUploadDir = request.getServletContext().getRealPath("/") + "uploads";
        File contextDir = new File(contextUploadDir + File.separator + subFolder);
        if (!contextDir.exists()) contextDir.mkdirs();
        try {
            // Copy file to context location
            File source = new File(workspaceDir.getAbsolutePath() + File.separator + uniqueFileName);
            File dest = new File(contextDir.getAbsolutePath() + File.separator + uniqueFileName);
            java.nio.file.Files.copy(source.toPath(), dest.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Build document object
        Document doc = new Document();
        if (vehicleId != null) {
            doc.setVehicleId(vehicleId);
        } else {
            doc.setUserId(user.getId());
        }
        doc.setDocumentType(docType);
        doc.setFileName(fileName);
        doc.setFilePath(relativePath);
        doc.setFileSize(fileSize);
        doc.setExpiryDate(expiryDate);

        boolean success = documentDAO.uploadDocument(doc);
        if (success) {
            String redirectPage = (vehicleId != null) ? "/dashboard.jsp" : "/profile.jsp";
            response.sendRedirect(request.getContextPath() + redirectPage + "?msg=" + docType + " uploaded successfully!");
        } else {
            redirectWithError(request, response, docType, "Failed to register document in database");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, User user) 
            throws IOException {
        int docId = Integer.parseInt(request.getParameter("documentId"));
        Document doc = documentDAO.getDocumentById(docId);
        if (doc == null) {
            response.sendRedirect(request.getContextPath() + "/profile.jsp?error=Document not found");
            return;
        }

        // Validate ownership
        if (doc.getUserId() != null && doc.getUserId() != user.getId() && !"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/profile.jsp?error=Unauthorized deletion");
            return;
        }

        // Delete from file system
        try {
            File workspaceFile = new File("/Users/vignesh/Desktop/VehicleServiceSystem/frontend/" + doc.getFilePath());
            if (workspaceFile.exists()) workspaceFile.delete();

            File contextFile = new File(request.getServletContext().getRealPath("/") + doc.getFilePath());
            if (contextFile.exists()) contextFile.delete();
        } catch (Exception e) {
            e.printStackTrace();
        }

        boolean success = documentDAO.deleteDocument(docId);
        if (success) {
            String redirectPage = (doc.getVehicleId() != null) ? "/dashboard.jsp" : "/profile.jsp";
            response.sendRedirect(request.getContextPath() + redirectPage + "?msg=Document deleted successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/profile.jsp?error=Failed to delete document record");
        }
    }

    private String getFileName(String contentDisposition) {
        for (String content : contentDisposition.split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf("=") + 1).trim().replace("\"", "");
            }
        }
        return "unknown";
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, String docType, String errorMsg) 
            throws IOException {
        String vehicleIdStr = request.getParameter("vehicleId");
        String redirectPage = (vehicleIdStr != null && !vehicleIdStr.isEmpty()) ? "/dashboard.jsp" : "/profile.jsp";
        response.sendRedirect(request.getContextPath() + redirectPage + "?error=" + docType + " Upload: " + errorMsg);
    }
}
