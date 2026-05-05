package com.example.project1;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;

@Controller
public class AppController {

    @Autowired
    private JdbcTemplate jdbc;

    @GetMapping({ "/", "/home" })
    public String home() {
        return "home";
    }

    @GetMapping("/signin")
    public String signin() {
        return "signin";
    }

    @GetMapping("/signup")
    public String signup() {
        return "signup";
    }

    @GetMapping("/updatePassword")
    public String updatePassword() {
        return "updatePassword";
    }

    @GetMapping("/adashboard")
    public String adashboard() {
        return "adashboard";
    }

    @GetMapping("/tdashboard")
    public String tdashboard() {
        return "tdashboard";
    }

    @GetMapping("/sdashboard")
    public String sdashboard() {
        return "sdashboard";
    }

    @GetMapping("/feeStructure")
    public String feeStructure() {
        return "feeStructure";
    }

    @GetMapping("/generateReports")
    @ResponseBody
    public String generateReports(HttpSession session) {
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "Error: Unauthorized";
        }
        try {

            ProcessBuilder pb = new ProcessBuilder("python", "c:/project1/src/main/python/report_generator.py");
            pb.directory(new java.io.File("c:/project1"));
            pb.redirectErrorStream(true);
            Process p = pb.start();

            BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String line;
            StringBuilder output = new StringBuilder();
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }

            int exitCode = p.waitFor();
            if (exitCode == 0) {
                return "Success\n" + output.toString();
            } else {
                return "Error (Exit " + exitCode + ")\n" + output.toString();
            }
        } catch (Exception e) {
            return "Error: " + e.getMessage();
        }
    }

    @PostMapping("/feeStructure")
    public String postFeeStructure() {
        return "feeStructure";
    }

    @PostMapping("/save_user")
    public String saveUser(@RequestParam("name") String uname,
            @RequestParam("role") String role,
            @RequestParam("password") String password,
            @RequestParam("confirmpassword") String confirm_password,
            Model m) {

        if (!password.equals(confirm_password)) {
            m.addAttribute("error", "Password and Confirm Password do not match.");
            return "signup";
        }

        if ("admin".equalsIgnoreCase(role)) {
            Integer adminCount = jdbc.queryForObject("SELECT COUNT(*) FROM user WHERE role = 'admin'", Integer.class);
            if (adminCount != null && adminCount > 0) {
                m.addAttribute("error", "Administrator already exists. You cannot register as an admin.");
                return "signup";
            }
        }

        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String encryptedPassword = encoder.encode(password);
        String encryptedConfirmPassword = encoder.encode(confirm_password);

        try {
            String sql = "INSERT INTO user(name, role, password, confirmpassword) VALUES(?, ?, ?, ?)";
            jdbc.update(sql, uname, role, encryptedPassword, encryptedConfirmPassword);
            m.addAttribute("msg", "Registered Successfully");
        } catch (org.springframework.dao.DuplicateKeyException e) {
            if (e.getMessage() != null && e.getMessage().contains("idx_single_admin")) {
                m.addAttribute("error", "Administrator already exists.");
            } else {
                m.addAttribute("error", "Username already taken.");
            }
            return "signup";
        }
        return "signup";
    }

    @PostMapping("/check_login")
    public String checkLogin(
            @RequestParam String name,
            @RequestParam String password,
            HttpServletRequest request,
            HttpServletResponse response,
            Model model) {
        String sql = "SELECT * FROM user WHERE name = ?";

        List<Map<String, Object>> users = jdbc.queryForList(sql, name);

        if (users.isEmpty()) {
            model.addAttribute("error", "Invalid name or password");
            return "signin";
        }

        Map<String, Object> user = users.get(0);
        Object userId = user.get("user_id");
        String dbPassword = user.get("password").toString();
        String role = user.get("role").toString();

        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

        if (passwordEncoder.matches(password, dbPassword)) {

            HttpSession session = request.getSession();
            session.setAttribute("user_id", userId);
            session.setAttribute("role", role);
            session.setAttribute("userName", name);
            session.setAttribute("userRole", role);

            if ("admin".equalsIgnoreCase(role)) {
                return "redirect:/adashboard";
            } else if ("faculty".equalsIgnoreCase(role)) {
                return "redirect:/tdashboard";
            } else if ("student".equalsIgnoreCase(role)) {
                return "redirect:/sdashboard";
            } else {
                model.addAttribute("error", "Success, but Role not recognized.");
                return "signin";
            }
        } else {
            model.addAttribute("error", "Invalid name or password");
            return "signin";
        }
    }

    @PostMapping("/update_pass")
    public String update_pass(@RequestParam("name") String name,
            @RequestParam("password") String password,
            @RequestParam("confirm_password") String confirm_password,
            Model m) {

        if (!password.equals(confirm_password)) {
            m.addAttribute("error", "Password and Confirm Password do not match.");
            return "updatePassword";
        }

        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String encryptedPassword = encoder.encode(password);
        String encryptedConfirmPassword = encoder.encode(confirm_password);

        String sql = "UPDATE user SET password = ?, confirmPassword = ? WHERE name = ?";
        int rowsAffected = jdbc.update(sql, encryptedPassword, encryptedConfirmPassword, name);

        if (rowsAffected > 0) {
            m.addAttribute("msg", "Password updated successfully.");
        } else {
            m.addAttribute("error", "User not found.");
        }
        return "updatePassword";
    }

    @GetMapping("/deleteStudent")
    public String deleteStudent(@RequestParam("id") Integer id, HttpSession session) {
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        List<Map<String, Object>> res = jdbc.queryForList("SELECT user_id FROM students WHERE student_id = ?", id);
        if (!res.isEmpty()) {
            Object userId = res.get(0).get("user_id");
            jdbc.update("DELETE FROM students WHERE student_id = ?", id);
            jdbc.update("DELETE FROM user WHERE user_id = ?", userId);
        }
        return "redirect:/adashboard?page=students&deleted=1";
    }

    @GetMapping("/deleteTeacher")
    public String deleteTeacher(@RequestParam("id") Integer id, HttpSession session) {
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        List<Map<String, Object>> res = jdbc.queryForList("SELECT user_id FROM teachers WHERE teacher_id = ?", id);
        if (!res.isEmpty()) {
            Object userId = res.get(0).get("user_id");
            jdbc.update("DELETE FROM teachers WHERE teacher_id = ?", id);
            jdbc.update("DELETE FROM user WHERE user_id = ?", userId);
        }
        return "redirect:/adashboard?page=teachers&deleted=1";
    }

    @PostMapping("/addTeacher")
    public String addTeacher(
            @RequestParam("name") String name,
            @RequestParam("email") String email,
            @RequestParam("password") String password,
            @RequestParam("employee_id") String empId,
            @RequestParam("subject") String subject,
            @RequestParam("department") String dept,
            @RequestParam("experience") String experience,
            HttpSession session) {

        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String encryptedPass = encoder.encode(password);

        try {
            jdbc.update(
                    "INSERT INTO user (name, password, confirmpassword, role, is_active) VALUES (?, ?, ?, 'faculty', 1)",
                    name, encryptedPass, encryptedPass);

            Integer userId = jdbc.queryForObject("SELECT LAST_INSERT_ID()", Integer.class);

            long empIdLong = 0;
            if (empId != null) {
                String digits = empId.replaceAll("[^0-9]", "");
                if (!digits.isEmpty())
                    empIdLong = Long.parseLong(digits);
            }

            jdbc.update(
                    "INSERT INTO teachers (user_id, name, email, employee_id, subject, department, experience, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'Active')",
                    userId, name, email, empIdLong, subject, dept, experience);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=teachers&error=1";
        }

        return "redirect:/adashboard?page=teachers&success=1";
    }

    @PostMapping("/editTeacher")
    public String editTeacher(
            @RequestParam("teacher_id") Integer id,
            @RequestParam("name") String name,
            @RequestParam("email") String email,
            @RequestParam("employee_id") String empId,
            @RequestParam("subject") String subject,
            @RequestParam("department") String dept,
            @RequestParam("experience") String experience,
            @RequestParam("status") String status,
            HttpSession session) {

        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {
            long empIdLong = 0;
            if (empId != null) {
                String digits = empId.replaceAll("[^0-9]", "");
                if (!digits.isEmpty())
                    empIdLong = Long.parseLong(digits);
            }

            jdbc.update(
                    "UPDATE teachers SET name=?, email=?, employee_id=?, subject=?, department=?, experience=?, status=? WHERE teacher_id=?",
                    name, email, empIdLong, subject, dept, experience, status, id);

            List<Map<String, Object>> res = jdbc.queryForList("SELECT user_id FROM teachers WHERE teacher_id = ?", id);
            if (!res.isEmpty()) {
                Object userId = res.get(0).get("user_id");
                int isActive = "Active".equalsIgnoreCase(status) ? 1 : 0;
                jdbc.update("UPDATE user SET name=?, is_active=? WHERE user_id=?", name, isActive, userId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=teachers&error=1";
        }

        return "redirect:/adashboard?page=teachers&updated=1";
    }

    @PostMapping("/addTimetable")
    public String addTimetable(
            @RequestParam("teacher_id") Integer teacherId,
            @RequestParam("class") String cls,
            @RequestParam("section") String section,
            @RequestParam("subject") String subject,
            @RequestParam("day") String day,
            @RequestParam("start_time") String startTime,
            @RequestParam("end_time") String endTime,
            @RequestParam("room") String room,
            HttpSession session) {

        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {
            jdbc.update("INSERT INTO timetable (teacher_id, class, section, subject, day, start_time, end_time, room) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                    teacherId, cls, section, subject, day, startTime, endTime, room);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=timetable&error=1";
        }

        return "redirect:/adashboard?page=timetable&success=1";
    }

    @GetMapping("/deleteTimetable")
    public String deleteTimetable(@RequestParam("id") Integer id, HttpSession session) {
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {
            jdbc.update("DELETE FROM timetable WHERE tt_id = ?", id);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=timetable&error=1";
        }
        return "redirect:/adashboard?page=timetable&deleted=1";
    }

    @PostMapping("/addPayment")
    public String addPayment(
            @RequestParam("roll_no") String rollNo,
            @RequestParam("amount") Double amount,
            @RequestParam("transaction_id") String transactionId,
            @RequestParam("payment_date") String paymentDate,
            @RequestParam("status") String status,
            @RequestParam("month") String month,
            @RequestParam("year") Integer year,
            HttpSession session) {

        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {
            java.util.List<Integer> studentIds = jdbc.queryForList("SELECT student_id FROM students WHERE roll_no = ?", Integer.class, rollNo);
            if (studentIds.isEmpty()) {
                return "redirect:/adashboard?page=fees&error=student_not_found";
            }
            Integer studentId = studentIds.get(0);

            jdbc.update("INSERT INTO fees (student_id, amount, transaction_id, payment_date, status, month, year) VALUES (?, ?, ?, ?, ?, ?, ?)",
                    studentId, amount, transactionId, paymentDate, status, month, year);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=fees&error=1";
        }

        return "redirect:/adashboard?page=fees&success=1";
    }

    @GetMapping("/exportFees")
    public void exportFees(HttpServletResponse response, HttpSession session) throws Exception {
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("/signin");
            return;
        }

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"fees_report.csv\"");

        java.io.PrintWriter writer = response.getWriter();
        writer.println("Transaction ID,Student Name,Roll No,Class,Amount,Date,Status");

        List<Map<String, Object>> fees = jdbc.queryForList(
                "SELECT f.*, s.name, s.roll_no, s.class, s.section FROM fees f JOIN students s ON f.student_id = s.student_id ORDER BY f.payment_date DESC");

        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy");

        for (Map<String, Object> fee : fees) {
            writer.print(fee.get("transaction_id") + ",");
            writer.print(fee.get("name") + ",");

            writer.print("=\"" + fee.get("roll_no") + "\",");

            writer.print(fee.get("class") + "-" + fee.get("section") + ",");
            writer.print(fee.get("amount") + ",");

            Object dateObj = fee.get("payment_date");
            String dateStr = "";
            if (dateObj != null) {
                if (dateObj instanceof java.sql.Date || dateObj instanceof java.util.Date) {
                    dateStr = sdf.format((java.util.Date) dateObj);
                } else {
                    dateStr = dateObj.toString();
                }
            }
            writer.print(dateStr + ",");

            writer.println(fee.get("status"));
        }
        writer.flush();
        writer.close();
    }

    @GetMapping("/sendFeeReminder")
    public String sendFeeReminder(@RequestParam("id") Integer feeId, HttpSession session) {
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }
        return "redirect:/adashboard?page=fees&reminder_sent=1";
    }

    @GetMapping("/downloadReceipt")
    public void downloadReceipt(@RequestParam("id") Integer feeId, HttpServletResponse response, HttpSession session) throws Exception {
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("/signin");
            return;
        }

        Map<String, Object> fee = jdbc.queryForMap(
                "SELECT f.*, s.name, s.roll_no, s.class, s.section FROM fees f JOIN students s ON f.student_id = s.student_id WHERE f.fee_id = ?", feeId);

        response.setContentType("text/plain");
        response.setHeader("Content-Disposition", "attachment; filename=\"receipt_" + fee.get("transaction_id") + ".txt\"");

        java.io.PrintWriter writer = response.getWriter();
        writer.println("=========================================");
        writer.println("              FEE RECEIPT                ");
        writer.println("=========================================");
        writer.println("Transaction ID : " + fee.get("transaction_id"));
        writer.println("Student Name   : " + fee.get("name"));
        writer.println("Roll No        : " + fee.get("roll_no"));
        writer.println("Class          : " + fee.get("class") + "-" + fee.get("section"));
        writer.println("Amount Paid    : Rs. " + fee.get("amount"));
        writer.println("Date           : " + fee.get("payment_date"));
        writer.println("Status         : " + fee.get("status"));
        writer.println("=========================================");
        writer.println("Thank you!");

        writer.flush();
        writer.close();
    }

    @PostMapping("/assignLeave")
    public String assignLeave(
            @RequestParam("teacher_id") Integer teacherId,
            @RequestParam("leave_type") String leaveType,
            @RequestParam("from_date") String fromDate,
            @RequestParam("to_date") String toDate,
            @RequestParam("reason") String reason,
            @RequestParam("status") String status,
            HttpSession session) {

        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {
            java.time.LocalDate start = java.time.LocalDate.parse(fromDate);
            java.time.LocalDate end = java.time.LocalDate.parse(toDate);
            long days = java.time.temporal.ChronoUnit.DAYS.between(start, end) + 1;

            jdbc.update(
                    "INSERT INTO leave_applications (teacher_id, leave_type, from_date, to_date, days, reason, status, approved_by, applied_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())",
                    teacherId, leaveType.toLowerCase(), fromDate, toDate, days, reason, status, 0);

            if ("approved".equalsIgnoreCase(status)) {
                String balanceCol = "";
                String type = leaveType.toLowerCase();
                if ("casual".equals(type))
                    balanceCol = "casual_used";
                else if ("medical".equals(type))
                    balanceCol = "medical_used";
                else if ("earned".equals(type))
                    balanceCol = "earned_used";

                if (!balanceCol.isEmpty()) {
                    jdbc.update(
                            "UPDATE leave_balance SET " + balanceCol + " = " + balanceCol + " + ? WHERE teacher_id = ?",
                            days, teacherId);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=leavemgmt&error=1";
        }

        return "redirect:/adashboard?page=leavemgmt&success=1";
    }

    @PostMapping("/approveLeave")
    public String approveLeave(@RequestParam("id") Integer leaveId, HttpSession session) {
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {

            List<Map<String, Object>> leaveData = jdbc.queryForList(
                    "SELECT teacher_id, leave_type, days FROM leave_applications WHERE leave_id = ?", leaveId);
            if (!leaveData.isEmpty()) {
                Map<String, Object> leave = leaveData.get(0);
                Integer teacherId = (Integer) leave.get("teacher_id");
                String type = (String) leave.get("leave_type");
                Integer days = (Integer) leave.get("days");

                jdbc.update("UPDATE leave_applications SET status = 'approved' WHERE leave_id = ?", leaveId);

                String balanceCol = "";
                if ("casual".equalsIgnoreCase(type))
                    balanceCol = "casual_used";
                else if ("medical".equalsIgnoreCase(type))
                    balanceCol = "medical_used";
                else if ("earned".equalsIgnoreCase(type))
                    balanceCol = "earned_used";

                if (!balanceCol.isEmpty()) {
                    jdbc.update(
                            "UPDATE leave_balance SET " + balanceCol + " = " + balanceCol + " + ? WHERE teacher_id = ?",
                            days, teacherId);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=leavemgmt&error=1";
        }
        return "redirect:/adashboard?page=leavemgmt&approved=1";
    }

    @PostMapping("/rejectLeave")
    public String rejectLeave(@RequestParam("id") Integer leaveId, HttpSession session) {
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {
            jdbc.update("UPDATE leave_applications SET status = 'rejected' WHERE leave_id = ?", leaveId);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=leavemgmt&error=1";
        }
        return "redirect:/adashboard?page=leavemgmt&rejected=1";
    }

    @PostMapping("/updateLeaveBalance")
    public String updateLeaveBalance(
            @RequestParam("teacher_id") Integer teacherId,
            @RequestParam("casual_total") Integer casual,
            @RequestParam("medical_total") Integer medical,
            @RequestParam("earned_total") Integer earned,
            HttpSession session) {

        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {

            List<Map<String, Object>> exists = jdbc.queryForList("SELECT lb_id FROM leave_balance WHERE teacher_id = ?",
                    teacherId);
            if (exists.isEmpty()) {
                jdbc.update(
                        "INSERT INTO leave_balance (teacher_id, session_year, casual_total, medical_total, earned_total, casual_used, medical_used, earned_used) VALUES (?, '2026', ?, ?, ?, 0, 0, 0)",
                        teacherId, casual, medical, earned);
            } else {
                jdbc.update(
                        "UPDATE leave_balance SET casual_total = ?, medical_total = ?, earned_total = ? WHERE teacher_id = ?",
                        casual, medical, earned, teacherId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=leavemgmt&error=1";
        }

        return "redirect:/adashboard?page=leavemgmt&updated=1";
    }

    @PostMapping("/applyLeave")
    public String applyLeave(
            @RequestParam("leave_type") String leaveType,
            @RequestParam("from_date") String fromDate,
            @RequestParam("to_date") String toDate,
            @RequestParam("reason") String reason,
            HttpSession session) {

        if (session == null || session.getAttribute("user_id") == null) {
            return "redirect:/signin";
        }

        Object userId = session.getAttribute("user_id");

        try {

            Integer teacherId = jdbc.queryForObject("SELECT teacher_id FROM teachers WHERE user_id = ?", Integer.class,
                    userId);

            java.time.LocalDate start = java.time.LocalDate.parse(fromDate);
            java.time.LocalDate end = java.time.LocalDate.parse(toDate);
            long days = java.time.temporal.ChronoUnit.DAYS.between(start, end) + 1;

            jdbc.update(
                    "INSERT INTO leave_applications (teacher_id, leave_type, from_date, to_date, days, reason, status, approved_by, applied_at) VALUES (?, ?, ?, ?, ?, ?, 'pending', 0, NOW())",
                    teacherId, leaveType.toLowerCase(), fromDate, toDate, days, reason);

        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/tdashboard?page=leave&error=1";
        }
        return "redirect:/tdashboard?page=leave&success=1";
    }

    @PostMapping("/publishNotice")
    public String publishNotice(
            @RequestParam("title") String title,
            @RequestParam("message") String message,
            @RequestParam("target") String target,
            @RequestParam("priority") String priority,
            @RequestParam(value = "student_id", required = false) Integer studentId,
            HttpSession session) {

        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        Object userId = session.getAttribute("user_id");

        try {
            jdbc.update(
                    "INSERT INTO notices (title, message, target, priority, created_by, published_at, student_id) VALUES (?, ?, ?, ?, ?, NOW(), ?)",
                    title, message, target, priority, userId, studentId);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=notices&error=1";
        }

        return "redirect:/adashboard?page=notices&success=1";
    }

    @PostMapping("/updateWorkingDays")
    public String updateWorkingDays(@RequestParam("days") String days, HttpSession session) {
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {
            jdbc.update("UPDATE settings SET config_value = ? WHERE config_key = 'working_days_year'", days);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=attendance&error=1";
        }

        return "redirect:/adashboard?page=attendance&success=working_days_updated";
    }

    @GetMapping("/deleteNotice")
    public String deleteNotice(@RequestParam("id") Integer id, HttpSession session) {
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {
            jdbc.update("DELETE FROM notices WHERE notice_id = ?", id);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=notices&error=1";
        }
        return "redirect:/adashboard?page=notices&deleted=1";
    }

    @GetMapping("/markAttendance")
    public String markAttendanceView(HttpSession session) {
        if (session == null || session.getAttribute("user_id") == null) return "redirect:/signin";
        return "markAttendance";
    }

    @PostMapping("/saveAttendance")
    public String saveAttendance(
            @RequestParam("class") String cls,
            @RequestParam("section") String sec,
            @RequestParam("teacher_id") String teacherId,
            @RequestParam("student_ids") String[] studentIds,
            HttpServletRequest request,
            HttpSession session) {

        if (session == null || session.getAttribute("user_id") == null) return "redirect:/signin";

        try {
            for (String sid : studentIds) {
                String status = request.getParameter("status_" + sid);
                if (status == null) status = "absent";

                Integer exists = jdbc.queryForObject(
                        "SELECT COUNT(*) FROM attendance WHERE student_id = ? AND date = CURDATE()",
                        Integer.class, sid);

                if (exists != null && exists > 0) {
                    jdbc.update(
                            "UPDATE attendance SET status = ?, teacher_id = ?, marked_at = NOW() WHERE student_id = ? AND date = CURDATE()",
                            status, teacherId, sid);
                } else {
                    jdbc.update(
                            "INSERT INTO attendance (student_id, teacher_id, class, section, date, status, marked_at) VALUES (?, ?, ?, ?, CURDATE(), ?, NOW())",
                            sid, teacherId, cls, sec, status);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            String role = (String) session.getAttribute("role");
            String redirectPath = "admin".equalsIgnoreCase(role) ? "/adashboard" : "/tdashboard";
            return "redirect:" + redirectPath + "?page=attendance&error=1";
        }

        String role = (String) session.getAttribute("role");
        if ("admin".equalsIgnoreCase(role)) {
            return "redirect:/adashboard?page=attendance&success=attendance_marked";
        } else {
            return "redirect:/tdashboard?page=attendance&success=attendance_marked";
        }
    }

    @PostMapping(value = "/createAssignment", consumes = {"multipart/form-data"})
    public String createAssignment(
            @RequestParam("title") String title,
            @RequestParam("description") String description,
            @RequestParam("class") String cls,
            @RequestParam("section") String sec,
            @RequestParam("due_date") String dueDate,
            @RequestParam("subject") String subject,
            @RequestParam("teacher_id") String teacherId,
            @RequestParam(value = "document_link", required = false) String docLink,
            @RequestParam(value = "file", required = false) MultipartFile file,
            HttpSession session) {

        if (session == null || !"faculty".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {

            if (teacherId == null || teacherId.isEmpty()) {
                Object uid = session.getAttribute("user_id");
                try {
                    teacherId = jdbc.queryForObject("SELECT CAST(teacher_id AS CHAR) FROM teachers WHERE user_id = ?", String.class, uid);
                } catch (Exception e) {}
            }

            if (title == null || title.isEmpty()) return "redirect:/tdashboard?page=assignments&error=missing_title";
            if (cls == null || cls.isEmpty()) return "redirect:/tdashboard?page=assignments&error=missing_class";
            if (sec == null || sec.isEmpty()) return "redirect:/tdashboard?page=assignments&error=missing_section";
            if (dueDate == null || dueDate.isEmpty()) return "redirect:/tdashboard?page=assignments&error=missing_date";
            if (teacherId == null || teacherId.isEmpty()) return "redirect:/tdashboard?page=assignments&error=missing_teacher";

            String finalDoc = (docLink != null) ? docLink : "";

            if (file != null && !file.isEmpty()) {
                String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
                String baseDir = session.getServletContext().getRealPath("/");
                if (baseDir == null) baseDir = System.getProperty("user.dir") + "/src/main/webapp/";

                String uploadPath = "uploads/assignments/";
                java.io.File dir = new java.io.File(baseDir + uploadPath);
                if (!dir.exists()) dir.mkdirs();

                file.transferTo(new java.io.File(baseDir + uploadPath + fileName));
                finalDoc = uploadPath + fileName;
            }

            jdbc.update("INSERT INTO assignments (teacher_id, title, description, class, section, subject, due_date, documents, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())",
                    teacherId, title, description, cls, sec, subject, dueDate, finalDoc);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/tdashboard?page=assignments&error=1";
        }

        return "redirect:/tdashboard?page=assignments&success=assignment_created";
    }

    @PostMapping("/submitAssignment")
    public String submitAssignment(
            @RequestParam("assignment_id") int assignmentId,
            @RequestParam("student_id") int studentId,
            @RequestParam(value = "submission_text", required = false) String subText,
            @RequestParam(value = "file", required = false) MultipartFile file,
            HttpSession session) {

        if (session == null || !"student".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {
            String filePath = "";
            if (file != null && !file.isEmpty()) {
                String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
                String baseDir = session.getServletContext().getRealPath("/");
                if (baseDir == null) baseDir = System.getProperty("user.dir") + "/src/main/webapp/";

                String uploadPath = "uploads/submissions/";
                java.io.File dir = new java.io.File(baseDir + uploadPath);
                if (!dir.exists()) dir.mkdirs();

                file.transferTo(new java.io.File(baseDir + uploadPath + fileName));
                filePath = uploadPath + fileName;
            }

            jdbc.update("INSERT INTO assignment_submissions (assignment_id, student_id, submission_text, submission_file, submitted_at, status, marks) VALUES (?, ?, ?, ?, NOW(), 'submitted', 0.0)",
                    assignmentId, studentId, subText, filePath);

        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/sdashboard?page=assignments&error=1";
        }

        return "redirect:/sdashboard?page=assignments&success=submitted";
    }

    @GetMapping("/getAssignmentSubmissions")
    @ResponseBody
    public List<Map<String, Object>> getAssignmentSubmissions(@RequestParam("assignment_id") int assignmentId) {
        String sql = "SELECT s.*, u.name as student_name FROM assignment_submissions s " +
                    "JOIN students st ON s.student_id = st.student_id " +
                    "JOIN user u ON st.user_id = u.user_id " +
                    "WHERE s.assignment_id = ? ORDER BY s.submitted_at DESC";
        return jdbc.queryForList(sql, assignmentId);
    }

    @GetMapping("/reviewSubmissions")
    public String reviewSubmissions(@RequestParam("assignment_id") int assignmentId, Model model, HttpSession session) {
        if (session == null || !"faculty".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {
            String title = jdbc.queryForObject("SELECT title FROM assignments WHERE assignment_id = ?", String.class, assignmentId);
            model.addAttribute("assignmentTitle", title);
            model.addAttribute("assignmentId", assignmentId);

            String sql = "SELECT s.*, u.name as student_name FROM assignment_submissions s " +
                        "JOIN students st ON s.student_id = st.student_id " +
                        "JOIN user u ON st.user_id = u.user_id " +
                        "WHERE s.assignment_id = ? ORDER BY s.submitted_at DESC";
            List<Map<String, Object>> submissions = jdbc.queryForList(sql, assignmentId);
            model.addAttribute("submissions", submissions);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/tdashboard?page=assignments&error=load_failed";
        }

        return "reviewSubmissions";
    }

    @PostMapping("/gradeSubmission")
    public String gradeSubmission(
            @RequestParam("sub_id") int subId,
            @RequestParam("marks") Double marks,
            HttpSession session) {

        if (session == null || !"faculty".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {
            jdbc.update("UPDATE assignment_submissions SET marks = ?, status = 'graded' WHERE sub_id = ?", marks, subId);

            Integer asgnId = jdbc.queryForObject("SELECT assignment_id FROM assignment_submissions WHERE sub_id = ?", Integer.class, subId);
            return "redirect:/reviewSubmissions?assignment_id=" + asgnId + "&success=graded";
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/tdashboard?page=assignments&error=grade_failed";
        }
    }

    @GetMapping("/uploadResults")
    public String uploadResultsView(HttpSession session) {
        if (session == null || session.getAttribute("user_id") == null) return "redirect:/signin";
        return "uploadResults";
    }

    @PostMapping("/saveResults")
    public String saveResults(
            @RequestParam("class") String cls,
            @RequestParam("section") String sec,
            @RequestParam("subject") String subject,
            @RequestParam("exam_type") String examType,
            @RequestParam("total_marks") Double totalMarks,
            @RequestParam("exam_date") String examDate,
            @RequestParam("student_ids") String[] studentIds,
            HttpServletRequest request,
            HttpSession session) {

        if (session == null || session.getAttribute("user_id") == null) return "redirect:/signin";

        try {
            Object userId = session.getAttribute("user_id");
            Integer teacherId = 0;
            try {
                teacherId = jdbc.queryForObject("SELECT teacher_id FROM teachers WHERE user_id = ?", Integer.class, userId);
            } catch (Exception e) {}

            for (String sid : studentIds) {
                String marksStr = request.getParameter("marks_" + sid);
                if (marksStr == null || marksStr.isEmpty()) continue;

                Double marks = Double.parseDouble(marksStr);

                Integer exists = jdbc.queryForObject(
                        "SELECT COUNT(*) FROM results WHERE student_id = ? AND subject = ? AND exam_type = ? AND class = ? AND section = ?",
                        Integer.class, sid, subject, examType, cls, sec);

                if (exists != null && exists > 0) {
                    jdbc.update(
                            "UPDATE results SET marks_obtained = ?, total_marks = ?, exam_date = ?, teacher_id = ? WHERE student_id = ? AND subject = ? AND exam_type = ? AND class = ? AND section = ?",
                            marks, totalMarks, examDate, teacherId, sid, subject, examType, cls, sec);
                } else {
                    jdbc.update(
                            "INSERT INTO results (student_id, teacher_id, subject, class, section, exam_type, marks_obtained, total_marks, exam_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                            sid, teacherId, subject, cls, sec, examType, marks, totalMarks, examDate);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            String role = (String) session.getAttribute("role");
            if ("faculty".equalsIgnoreCase(role)) {
                return "redirect:/tdashboard?page=results&error=1";
            }
            return "redirect:/adashboard?page=results&error=1";
        }

        String role = (String) session.getAttribute("role");
        if ("faculty".equalsIgnoreCase(role)) {
            return "redirect:/tdashboard?page=results&success=results_uploaded";
        }
        return "redirect:/adashboard?page=results&success=results_uploaded";
    }

    @PostMapping("/saveSettings")
    public String saveSettings(
            @RequestParam("school_name") String schoolName,
            @RequestParam("academic_year") String academicYear,
            @RequestParam("school_code") String schoolCode,
            @RequestParam("board") String board,
            @RequestParam("medium") String medium,
            @RequestParam("school_address") String schoolAddress,
            @RequestParam("contact_email") String contactEmail,
            HttpSession session) {

        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {
            jdbc.update("UPDATE settings SET config_value = ? WHERE config_key = 'school_name'", schoolName);
            jdbc.update("UPDATE settings SET config_value = ? WHERE config_key = 'academic_year'", academicYear);
            jdbc.update("UPDATE settings SET config_value = ? WHERE config_key = 'school_code'", schoolCode);
            jdbc.update("UPDATE settings SET config_value = ? WHERE config_key = 'board'", board);
            jdbc.update("UPDATE settings SET config_value = ? WHERE config_key = 'medium'", medium);
            jdbc.update("UPDATE settings SET config_value = ? WHERE config_key = 'school_address'", schoolAddress);
            jdbc.update("UPDATE settings SET config_value = ? WHERE config_key = 'contact_email'", contactEmail);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=settings&error=1";
        }

        return "redirect:/adashboard?page=settings&updated=1";
    }

    @PostMapping("/changePassword")
    public String changePassword(
            @RequestParam("current_password") String currentPassword,
            @RequestParam("new_password") String newPassword,
            @RequestParam("confirm_password") String confirmPassword,
            HttpSession session) {

        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        if (!newPassword.equals(confirmPassword)) {
            return "redirect:/adashboard?page=settings&error=password_mismatch";
        }

        Object userId = session.getAttribute("user_id");

        try {

            String dbPass = jdbc.queryForObject("SELECT password FROM user WHERE user_id = ?", String.class, userId);
            BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

            if (encoder.matches(currentPassword, dbPass)) {
                String encryptedNewPass = encoder.encode(newPassword);
                jdbc.update("UPDATE user SET password = ?, confirmpassword = ? WHERE user_id = ?", 
                    encryptedNewPass, encryptedNewPass, userId);
            } else {
                return "redirect:/adashboard?page=settings&error=wrong_current_password";
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=settings&error=1";
        }

        return "redirect:/adashboard?page=settings&updated=1";
    }

    @PostMapping("/updateNotificationSettings")
    public String updateNotificationSettings(
            @RequestParam(value = "email_notifications", defaultValue = "false") String emailNotif,
            @RequestParam(value = "low_attendance_alerts", defaultValue = "false") String attendanceAlert,
            HttpSession session) {

        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            return "redirect:/signin";
        }

        try {
            jdbc.update("UPDATE settings SET config_value = ? WHERE config_key = 'email_notifications'", emailNotif);
            jdbc.update("UPDATE settings SET config_value = ? WHERE config_key = 'low_attendance_alerts'", attendanceAlert);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/adashboard?page=settings&error=1";
        }

        return "redirect:/adashboard?page=settings&updated=1";
    }
}
