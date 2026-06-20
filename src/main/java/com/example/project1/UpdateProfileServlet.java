ackage com.example.project1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/UpdateProfileServlet")
@MultipartConfig(maxFileSize = 1024 * 1024 * 2) // 2MB
public class UpdateProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("signin");
            return;
        }

        Object userId = session.getAttribute("user_id");
        String role = (String) session.getAttribute("role");

        String name = request.getParameter("name");
        String dob = request.getParameter("dob");
        String gender = request.getParameter("gender");
        String bloodGroup = request.getParameter("blood_group");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String address = request.getParameter("address");

        Part photoPart = request.getPart("photo");
        InputStream photoStream = null;
        if (photoPart != null && photoPart.getSize() > 0) {
            photoStream = photoPart.getInputStream();
        }

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
                        String dbUrl = System.getenv("SPRING_DATASOURCE_URL");
            if (dbUrl == null) dbUrl = "jdbc:mysql://localhost:3308/project1";
            String dbUser = System.getenv("SPRING_DATASOURCE_USERNAME");
            if (dbUser == null) dbUser = "root";
            String dbPass = System.getenv("SPRING_DATASOURCE_PASSWORD");
            if (dbPass == null) dbPass = "";
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // Update user table (common for all)
            String userSql = "UPDATE user SET name = ? WHERE user_id = ?";
            PreparedStatement userPstmt = conn.prepareStatement(userSql);
            userPstmt.setString(1, name);
            userPstmt.setObject(2, userId);
            userPstmt.executeUpdate();

            String checkSql = "";
            if ("student".equalsIgnoreCase(role)) {
                checkSql = "SELECT user_id FROM students WHERE user_id = ?";
            } else {
                checkSql = "SELECT user_id FROM teachers WHERE user_id = ?";
            }

            PreparedStatement checkPstmt = conn.prepareStatement(checkSql);
            checkPstmt.setObject(1, userId);
            ResultSet checkRs = checkPstmt.executeQuery();
            boolean exists = checkRs.next();

            String tableSql = ""; // Initialize tableSql here

            if ("admin".equalsIgnoreCase(role) || "teacher".equalsIgnoreCase(role)
                    || "faculty".equalsIgnoreCase(role)) {
                String department = request.getParameter("department");
                String designation = request.getParameter("designation");
                String employee_id = request.getParameter("employee_id");
                String joined_on = request.getParameter("joined_on");
                String subject = request.getParameter("subject");
                String qualification = request.getParameter("qualification");
                String experience = request.getParameter("experience");

                if (exists) {
                    tableSql = "UPDATE teachers SET name=?, dob=?, gender=?, blood_group=?, phone=?, email=?, address=?, department=?, employee_id=?, joined_on=?, subject=?, qualification=?, experience=?"
                            + (photoStream != null ? ", photo=?" : "") + " WHERE user_id=?";
                } else {
                    tableSql = "INSERT INTO teachers (name, dob, gender, blood_group, phone, email, address, department, employee_id, joined_on, subject, qualification, experience, user_id"
                            + (photoStream != null ? ", photo" : "")
                            + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?"
                            + (photoStream != null ? ", ?" : "") + ")";
                }

                PreparedStatement pstmt = conn.prepareStatement(tableSql);
                int idx = 1;
                pstmt.setString(idx++, name);
                pstmt.setString(idx++, dob);
                pstmt.setString(idx++, gender);
                pstmt.setString(idx++, bloodGroup);
                pstmt.setString(idx++, phone);
                pstmt.setString(idx++, email);
                pstmt.setString(idx++, address);
                pstmt.setString(idx++, department);
                pstmt.setString(idx++, employee_id);
                pstmt.setString(idx++, joined_on);
                pstmt.setString(idx++, subject);
                pstmt.setString(idx++, qualification);
                pstmt.setString(idx++, experience);

                if (exists) {
                    if (photoStream != null)
                        pstmt.setBlob(idx++, photoStream);
                    pstmt.setObject(idx++, userId);
                } else {
                    pstmt.setObject(idx++, userId);
                    if (photoStream != null)
                        pstmt.setBlob(idx++, photoStream);
                }
                pstmt.executeUpdate();

            } else if ("student".equalsIgnoreCase(role)) {
                String rollNo = request.getParameter("roll_no");
                String studentClass = request.getParameter("class");
                String section = request.getParameter("section");
                String status = request.getParameter("status");

                if (exists) {
                    tableSql = "UPDATE students SET name=?, dob=?, gender=?, blood_group=?, phone=?, email=?, address=?, roll_no=?, class=?, section=?, status=?"
                            + (photoStream != null ? ", photo=?" : "") + " WHERE user_id=?";
                } else {
                    tableSql = "INSERT INTO students (name, dob, gender, blood_group, phone, email, address, roll_no, class, section, status, user_id"
                            + (photoStream != null ? ", photo" : "") + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?"
                            + (photoStream != null ? ", ?" : "") + ")";
                }

                PreparedStatement pstmt = conn.prepareStatement(tableSql);
                int idx = 1;
                pstmt.setString(idx++, name);
                pstmt.setString(idx++, dob);
                pstmt.setString(idx++, gender);
                pstmt.setString(idx++, bloodGroup);
                pstmt.setString(idx++, phone);
                pstmt.setString(idx++, email);
                pstmt.setString(idx++, address);
                pstmt.setString(idx++, rollNo);
                pstmt.setString(idx++, studentClass);
                pstmt.setString(idx++, section);
                pstmt.setString(idx++, status);

                if (exists) {
                    if (photoStream != null)
                        pstmt.setBlob(idx++, photoStream);
                    pstmt.setObject(idx++, userId);
                } else {
                    pstmt.setObject(idx++, userId);
                    if (photoStream != null)
                        pstmt.setBlob(idx++, photoStream);
                }
                pstmt.executeUpdate();
            }

            // Forward back to dashboard based on role (Inside WEB-INF/views/)
            String target = "";
            if ("admin".equalsIgnoreCase(role))
                target = "/WEB-INF/views/adashboard.jsp";
            else if ("teacher".equalsIgnoreCase(role) || "faculty".equalsIgnoreCase(role))
                target = "/WEB-INF/views/tdashboard.jsp";
            else if ("student".equalsIgnoreCase(role))
                target = "/WEB-INF/views/sdashboard.jsp";

            if (!target.isEmpty()) {
                request.getRequestDispatcher(target).forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (Exception e) {
                }
            }
        }
    }
}
