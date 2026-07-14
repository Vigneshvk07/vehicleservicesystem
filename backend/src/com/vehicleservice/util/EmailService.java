package com.vehicleservice.util;

public class EmailService {
    
    /**
     * Simulates sending a booking confirmation email.
     */
    public static void sendBookingConfirmation(String recipientEmail, String customerName, String bookingId, String date, String time) {
        System.out.println("----- EMAIL SENT -----");
        System.out.println("To: " + recipientEmail);
        System.out.println("Subject: Booking Confirmed - VSS Service Booking #" + bookingId);
        System.out.println("Hello " + customerName + ",");
        System.out.println("Your service booking has been registered successfully!");
        System.out.println("Booking Reference: #" + bookingId);
        System.out.println("Date: " + date);
        System.out.println("Time Slot: " + time);
        System.out.println("Thank you for choosing Vehicle Service System!");
        System.out.println("----------------------");
    }

    /**
     * Simulates sending a booking status update email.
     */
    public static void sendStatusUpdate(String recipientEmail, String customerName, String bookingId, String oldStatus, String newStatus) {
        System.out.println("----- EMAIL SENT -----");
        System.out.println("To: " + recipientEmail);
        System.out.println("Subject: Service Status Update - Booking #" + bookingId);
        System.out.println("Hello " + customerName + ",");
        System.out.println("The status of your service booking #" + bookingId + " has changed from " + oldStatus + " to " + newStatus + ".");
        System.out.println("You can view progress on your Customer Dashboard.");
        System.out.println("Thank you for choosing Vehicle Service System!");
        System.out.println("----------------------");
    }

    /**
     * Simulates sending an invoice notification email.
     */
    public static void sendInvoiceNotification(String recipientEmail, String customerName, String bookingId, double totalCost) {
        System.out.println("----- EMAIL SENT -----");
        System.out.println("To: " + recipientEmail);
        System.out.println("Subject: Invoice Generated - Booking #" + bookingId);
        System.out.println("Hello " + customerName + ",");
        System.out.println("Your vehicle service is complete, and the invoice has been generated.");
        System.out.println("Total Amount Due: ₹" + totalCost);
        System.out.println("You can download the invoice PDF from your dashboard.");
        System.out.println("Thank you for choosing Vehicle Service System!");
        System.out.println("----------------------");
    }
}
