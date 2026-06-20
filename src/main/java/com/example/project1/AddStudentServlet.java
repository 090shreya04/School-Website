ackage com.example.project1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

@WebServlet("/AddStudentServlet")
public class AddStudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("signin");
            return;
        }

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String studentClass = request.getParameter("class");
        String section = request.getParameter("section");
        String rollNo = request.getParameter("roll_no");

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
            conn.setAutoCommit(false);

            org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder encoder = new org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder();
            String encryptedPass = encoder.encode(password);

            // 1. Create user in 'user' table
            // Note: 'user' table does NOT have 'email' column, uses 'name' for login.
            // Also requires 'confirmpassword'.
            String userSql = "INSERT INTO user (name, password, confirmpassword, role, is_active) VALUES (?, ?, ?, 'student', 1)";
            PreparedStatement userPstmt = conn.prepareStatement(userSql, Statement.RETURN_GENERATED_KEYS);
            userPstmt.setString(1, name);
            userPstmt.setString(2, encryptedPass);
            userPstmt.setString(3, encryptedPass);
            userPstmt.executeUpdate();

            ResultSet rs = userPstmt.getGeneratedKeys();
            if (rs.next()) {
                int userId = rs.getInt(1);

                // 2. Create student in 'students' table
                String studentSql = "INSERT INTO students (user_id, name, email, class, section, roll_no, status) VALUES (?, ?, ?, ?, ?, ?, 'Active')";
                PreparedStatement studentPstmt = conn.prepareStatement(studentSql);
                studentPstmt.setInt(1, userId);
                studentPstmt.setString(2, name);
                studentPstmt.setString(3, email);
                studentPstmt.setString(4, studentClass);
                studentPstmt.setString(5, section);
                studentPstmt.setString(6, rollNo);
                studentPstmt.executeUpdate();
            }

            conn.commit();
            response.sendRedirect("adashboard?page=students&success=1");

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception ex) {
                }
            }
            e.printStackTrace();
            response.sendRedirect("adashboard?page=students&error=1");
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
