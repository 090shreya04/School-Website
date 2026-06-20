package com.example.project1;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpSession;

@Controller
public class AdminController {

    @Autowired
    private JdbcTemplate jdbc;

    @GetMapping("/profile")
    public String profile(HttpSession session, Model m) {
        String email = (String) session.getAttribute("email");
        String sql = "select name, users.email,role,photo FROM users left join profile on users.email=profile.email where users.email='"
                + email + "'";
        List<Map<String, Object>> userprofile = jdbc.queryForList(sql);
        m.addAttribute("userprofile", userprofile);
        return "profile";
    }

    @PostMapping("upload")
    public String upload(@RequestParam("f") MultipartFile f,
            HttpSession session,
            Model m) throws IOException {
        String email = (String) session.getAttribute("email");
        String sql1 = "Delete from profile where email=?";
        jdbc.update(sql1, email);
        String sql2 = "insert into profile(email,photo) values(?,?)";
        jdbc.update(sql2, email, f.getBytes());// photo directly add nai hoga bytes me convert ho k hoga
        m.addAttribute("msg", "Profile updated successfully");
        return profile(session, m);
    }

    @GetMapping("/admin_logout")
    public String logout(HttpSession session) {
        if (session != null) {
            session.invalidate();
        }
        return "redirect:/signin";
    }
}
