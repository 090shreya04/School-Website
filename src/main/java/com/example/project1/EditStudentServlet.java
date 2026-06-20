package com.example.project1;

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

@WebServlet("/EditStudentServlet")
public class EditStudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Auth guard ──────────────────────────────────────────────────
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("signin");
            return;
        }

        // ── Read form parameters ─────────────────────────────────────────
        String studentId = request.getParameter("student_id");
        String name      = request.getParameter("name");
        String email     = request.getParameter("email");
        String rollNo    = request.getParameter("roll_no");
        String cls       = request.getParameter("class");
        String section   = request.getParameter("section");

        if (studentId == null || studentId.trim().isEmpty()) {
            response.sendRedirect("adashboard?page=students&error=1");
            return;
        }

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3308/project1", "root", "");
            conn.setAutoCommit(false);

            // ── 1. Update students table (name, email, roll, class, section) ─────
            String updateStudent =
                    "UPDATE students SET name=?, email=?, roll_no=?, class=?, section=? " +
                    "WHERE student_id=?";
            PreparedStatement ps1 = conn.prepareStatement(updateStudent);
            ps1.setString(1, name);
            ps1.setString(2, email);
            ps1.setString(3, rollNo);
            ps1.setString(4, cls);
            ps1.setString(5, section);
            ps1.setString(6, studentId);
            ps1.executeUpdate();
            ps1.close();

            // ── 2. Update name in user table (user table lacks 'email' col) ──
            String updateUser =
                    "UPDATE users SET name=? WHERE user_id = " +
                    "(SELECT user_id FROM students WHERE student_id=?)";
            PreparedStatement ps2 = conn.prepareStatement(updateUser);
            ps2.setString(1, name);
            ps2.setString(2, studentId);
            ps2.executeUpdate();
            ps2.close();

            conn.commit();
            response.sendRedirect("adashboard?page=students&success=1");

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) { /* ignore */ }
            }
            e.printStackTrace();
            response.sendRedirect("adashboard?page=students&error=1");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (Exception e) { /* ignore */ }
            }
        }
    }
}
