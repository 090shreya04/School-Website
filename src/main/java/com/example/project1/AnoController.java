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
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Controller
public class AnoController {

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

    @PostMapping("/save_user")
    public String saveUser(@RequestParam("name") String uname,
            @RequestParam("role") String role,
            @RequestParam("password") String password,
            @RequestParam("confirmpassword") String confirm_password,
            Model m) {
        // Server-side validation: ensure passwords match
        if (!password.equals(confirm_password)) {
            m.addAttribute("error", "Password and Confirm Password do not match.");
            return "signup";
        }

        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String encryptedPassword = encoder.encode(password);
        String encryptedConfirmPassword = encoder.encode(confirm_password);

        // Use parameterized update to avoid SQL injection
        String sql = "INSERT INTO user(name, role, password, confirmpassword) VALUES(?, ?, ?, ?)";
        jdbc.update(sql, uname, role, encryptedPassword, encryptedConfirmPassword);
        m.addAttribute("msg", "Registered Successfully");
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

        // If user does not exist
        if (users.isEmpty()) {
            model.addAttribute("error", "Invalid name or password");
            return "signin";
        }

        // Get stored data from DB
        Map<String, Object> user = users.get(0);
        Object userId = user.get("user_id");
        String dbPassword = user.get("password").toString();
        String role = user.get("role").toString();

        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

        // Compare raw password with encrypted password
        if (passwordEncoder.matches(password, dbPassword)) {
            // Optional: Store user info in session
            HttpSession session = request.getSession();
            session.setAttribute("user_id", userId);
            session.setAttribute("role", role);
            session.setAttribute("userName", name);
            session.setAttribute("userRole", role);

            // Redirect based on role
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
        // Server-side validation: ensure passwords match
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

        // Get user_id before deletion
        List<Map<String, Object>> res = jdbc.queryForList("SELECT user_id FROM students WHERE student_id = ?", id);
        if (!res.isEmpty()) {
            Object userId = res.get(0).get("user_id");
            jdbc.update("DELETE FROM students WHERE student_id = ?", id);
            jdbc.update("DELETE FROM user WHERE user_id = ?", userId);
        }
        return "redirect:/adashboard?page=students&deleted=1";
    }

}
