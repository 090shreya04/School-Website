<%@ page import="java.sql.*, java.util.*" %>
  <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <% if (session==null || session.getAttribute("user_id")==null) { response.sendRedirect("/signin"); return; } Object
      userId=session.getAttribute("user_id"); String adName="Admin User" ; String adDesignation="Super Administrator" ;
      String adInitials="A" ; String adPhotoBase64=null; String adDob="" , adGender="" , adBlood="" , adPhone="" ,
      adEmail="" , adAddress="" , adDept="" , adEmpId="" , adJoined="" , adSubject="" , adQual="" , adExp="" , adRole=""
      , adActive="" ; Connection conn=null; PreparedStatement pstmt=null; ResultSet rs=null; try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      conn=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root" , "" ); String
      sql="SELECT u.*, t.* FROM user u LEFT JOIN teachers t ON u.user_id = t.user_id WHERE u.user_id = ?" ;
      pstmt=conn.prepareStatement(sql); pstmt.setObject(1, userId); rs=pstmt.executeQuery(); if (rs.next()) {
      adName=rs.getString("name"); adRole=rs.getString("role"); int status=rs.getInt("is_active"); adActive=(status==1)
      ? "Active" : "Inactive" ; adDob=rs.getString("dob"); adGender=rs.getString("gender");
      adBlood=rs.getString("blood_group"); adPhone=rs.getString("phone"); adEmail=rs.getString("email");
      adAddress=rs.getString("address"); adDept=rs.getString("department"); adEmpId=rs.getString("employee_id");
      adJoined=rs.getString("joined_on"); adSubject=rs.getString("subject"); adQual=rs.getString("qualification");
      adExp=rs.getString("experience"); adDesignation=adDept; if (adDesignation==null || adDesignation.isEmpty())
      adDesignation="Super Administrator" ; byte[] photoBytes=rs.getBytes("photo"); if (photoBytes !=null &&
      photoBytes.length> 0) {
      adPhotoBase64 = java.util.Base64.getEncoder().encodeToString(photoBytes);
      }

      if (adName != null && !adName.isEmpty()) {
      String[] parts = adName.trim().split("\\s+");
      StringBuilder sb = new StringBuilder();
      for (int i = 0; i < Math.min(parts.length, 2); i++) { if (parts[i].length() > 0) sb.append(parts[i].charAt(0));
        }
        adInitials = sb.toString().toUpperCase();
        }
        }
        } catch (Exception e) {
        e.printStackTrace();
        } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
        }

        // ── Student Stats ──
        int totalStudents = 0, activeStudents = 0, inactiveStudents = 0, newStudentsThisMonth = 0;
        int totalTeachers = 0;
        int absentToday = 0, presentToday = 0;
        double feesCollected = 0;
        int feesPending = 0;
        int currentMonth = java.time.LocalDate.now().getMonthValue();
        int currentYear = java.time.LocalDate.now().getYear();
        String monthName = java.time.LocalDate.now().getMonth().name().substring(0, 1).toUpperCase() +
        java.time.LocalDate.now().getMonth().name().substring(1).toLowerCase();

        Connection conn2 = null;
        try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3308/project1","root","");

        // Total students
        ResultSet r1 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM students");
        if(r1.next()) totalStudents = r1.getInt(1);

        // Active students (Mapped from user table)
        ResultSet r2 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM students s JOIN user u " +
        "ON s.user_id = u.user_id WHERE u.is_active=1");
        if(r2.next()) activeStudents = r2.getInt(1);

        // Inactive students
        inactiveStudents = totalStudents - activeStudents;

        // New students this month
        ResultSet r3 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM students s JOIN user u " +
        "ON s.user_id = u.user_id WHERE MONTH(u.created_at)=MONTH(NOW()) AND " +
        "YEAR(u.created_at)=YEAR(NOW())");
        if(r3.next()) newStudentsThisMonth = r3.getInt(1);

        // Total teachers
        ResultSet r4 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM teachers");
        if(r4.next()) totalTeachers = r4.getInt(1);

        // Attendance Stats
        ResultSet r5 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM attendance WHERE " +
        "date = CURDATE() AND status='present'");
        if(r5.next()) presentToday = r5.getInt(1);
        ResultSet r6 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM attendance WHERE " +
        "date = CURDATE() AND status='absent'");
        if(r6.next()) absentToday = r6.getInt(1);

        // Fees Stats
        ResultSet r7 = conn2.createStatement().executeQuery("SELECT SUM(amount) FROM fees WHERE status='paid' AND " +
        "month='" + monthName + "' AND year=" + currentYear);
        if(r7.next()) feesCollected = r7.getDouble(1);
        ResultSet r8 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM fees WHERE status='pending' AND " +
        "month='" + monthName + "' AND year=" + currentYear);
        if(r8.next()) feesPending = r8.getInt(1);

        } catch(Exception e){ e.printStackTrace(); }
        finally { if(conn2!=null) try{conn2.close();}catch(Exception e){} }

        // Conditional Display Logic for Profile Sections
        boolean hasPersonalInfo = (adName != null && !adName.trim().isEmpty())
        && (adDob != null && !adDob.trim().isEmpty())
        && (adGender != null && !adGender.trim().isEmpty())
        && (adBlood != null && !adBlood.trim().isEmpty())
        && (adPhone != null && !adPhone.trim().isEmpty())
        && (adEmail != null && !adEmail.trim().isEmpty())
        && (adAddress != null && !adAddress.trim().isEmpty());

        boolean hasProfessionalInfo = (adSubject != null && !adSubject.trim().isEmpty())
        && (adDesignation != null && !adDesignation.trim().isEmpty())
        && (adDept != null && !adDept.trim().isEmpty())
        && (adEmpId != null && !adEmpId.trim().isEmpty())
        && (adQual != null && !adQual.trim().isEmpty())
        && (adExp != null && !adExp.trim().isEmpty());
        %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

          <!DOCTYPE html>
          <html lang="en">

          <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>Admin Dashboard</title>
            <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css"
              rel="stylesheet" />
            <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css"
              rel="stylesheet" />
            <link
              href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap"
              rel="stylesheet" />
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/adashboard.css" />
          </head>

          <body>

            <!-- ═══════ SIDEBAR ═══════ -->
            <aside class="sidebar" id="sidebar">
              <div class="s-brand">
                <div class="s-brand-icon"><i class="bi bi-shield-fill-check"></i></div>
                <div class="s-brand-text">
                  <h6>EduManage</h6>
                  <small>Admin Control Panel</small>
                </div>
              </div>

              <div class="s-admin-card">
                <div class="s-avatar">
                  <img src='<%= adPhotoBase64 != null ? "data:image/jpeg;base64," + adPhotoBase64
                    : "images/user_default_photo.webp" %>'
                  style="width:100%;height:100%;object-fit:cover;" id="sidebar-photo" />
                </div>
                <div class="s-admin-info">
                  <h6 id="sidebar-name">
                    <%= adName %>
                  </h6>
                  <small id="sidebar-sub">
                    <%= adDesignation %>
                  </small>
                </div>
                <div class="admin-badge-dot">Admin</div>
              </div>

              <nav class="s-nav">
                <div class="s-section-label">Main</div>
                <div class="s-nav-item">
                  <a class="s-nav-link active" onclick="showPage('dashboard', this)">
                    <i class="bi bi-grid-fill"></i> Dashboard
                  </a>
                </div>
                <div class="s-nav-item">
                  <a class="s-nav-link" onclick="showPage('profile', this)">
                    <i class="bi bi-person-fill"></i> My Profile
                  </a>
                </div>

                <div class="s-section-label">Management</div>
                <div class="s-nav-item">
                  <a class="s-nav-link" onclick="showPage('students', this)">
                    <i class="bi bi-people-fill"></i> Students
                    <span class="s-badge">248</span>
                  </a>
                </div>
                <div class="s-nav-item">
                  <a class="s-nav-link" onclick="showPage('teachers', this)">
                    <i class="bi bi-person-video3"></i> Teachers
                    <span class="s-badge">24</span>
                  </a>
                </div>
                <div class="s-nav-item">
                  <a class="s-nav-link" onclick="showPage('leavemgmt', this)">
                    <i class="bi bi-calendar2-x-fill"></i> Leave Management
                    <span class="s-badge alert">1</span>
                  </a>
                </div>
                <div class="s-nav-item">
                  <a class="s-nav-link" onclick="showPage('attendance', this)">
                    <i class="bi bi-calendar-check-fill"></i> Attendance
                  </a>
                </div>
                <div class="s-nav-item">
                  <a class="s-nav-link" onclick="showPage('results', this)">
                    <i class="bi bi-bar-chart-fill"></i> Results & Grades
                  </a>
                </div>
                <div class="s-nav-item">
                  <a class="s-nav-link" onclick="showPage('courses', this)">
                    <i class="bi bi-book-fill"></i> Courses
                    <span class="s-badge">12</span>
                  </a>
                </div>

                <div class="s-section-label">Finance & Comms</div>
                <div class="s-nav-item">
                  <a class="s-nav-link" onclick="showPage('fees', this)">
                    <i class="bi bi-cash-coin"></i> Fee Management
                  </a>
                </div>
                <div class="s-nav-item">
                  <a class="s-nav-link" onclick="showPage('notices', this)">
                    <i class="bi bi-megaphone-fill"></i> Notice Board
                    <span class="s-badge alert">3</span>
                  </a>
                </div>
                <div class="s-nav-item">
                  <a class="s-nav-link" onclick="showPage('reports', this)">
                    <i class="bi bi-file-earmark-bar-graph-fill"></i> Reports
                  </a>
                </div>

                <div class="s-section-label">System</div>
                <div class="s-nav-item">
                  <a class="s-nav-link" onclick="showPage('settings', this)">
                    <i class="bi bi-gear-fill"></i> Settings
                  </a>
                </div>
              </nav>

              <div class="s-bottom">
                <a href="/admin_logout" class="s-logout" style="text-decoration: none;">
                  <i class="bi bi-box-arrow-left" style="font-size:16px;"></i> Logout
                </a>
              </div>
            </aside>

            <!-- ═══════ MAIN ═══════ -->
            <div class="main">
              <div class="topbar">
                <button class="mobile-toggle" onclick="toggleSidebar()"><i class="bi bi-list"></i></button>
                <span class="topbar-page-title" id="page-title">Dashboard</span>
                <div class="topbar-right">
                  <span class="tb-date" id="topbar-date">Mon, 2 Mar 2026</span>
                  <div class="tb-search">
                    <i class="bi bi-search"></i>
                    <input type="text" placeholder="Search for Students, teachers..." />
                  </div>
                  <div class="tb-btn" onclick="showPage('notices', document.querySelector('[onclick*=notices]'))">
                    <i class="bi bi-bell"></i>
                    <span class="tb-notif"></span>
                  </div>
                  <a href="/admin_logout" class="tb-btn" style="text-decoration: none;">
                    <i class="bi bi-box-arrow-right"></i>
                  </a>
                </div>
              </div>

              <!-- ═══ DASHBOARD ═══ -->
              <div class="page active" id="page-dashboard">
                <div class="pg-header">
                  <div class="pg-header-left">
                    <h4>Good Morning, <%= adName %>! 👋</h4>
                    <p>Aaj ke school ka poora overview ek nazar mein</p>
                  </div>
                </div>

                <!-- Big stats -->
                <div class="row g-3 mb-4">
                  <div class="col-6 col-xl-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#ffedd5;color:#ea580c;"><i class="bi bi-people-fill"></i>
                      </div>
                      <h3>
                        <%= totalStudents %>
                      </h3>
                      <p>Total Students</p>
                      <span class="tag tag-orange">↑ <%= newStudentsThisMonth %> this month</span>
                    </div>
                  </div>
                  <div class="col-6 col-xl-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#dbeafe;color:#2563eb;"><i
                          class="bi bi-person-video3"></i>
                      </div>
                      <h3>
                        <%= totalTeachers %>
                      </h3>
                      <p>Total Teachers</p>
                      <span class="tag tag-blue">2 new joins</span>
                    </div>
                  </div>
                  <div class="col-6 col-xl-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#d1fae5;color:#059669;"><i
                          class="bi bi-calendar-check-fill"></i>
                      </div>
                      <h3>
                        <%= (totalStudents> 0 ? (presentToday*100/totalStudents) : 0) %>%
                      </h3>
                      <p>Today's Attendance</p>
                      <span class="tag tag-green">
                        <%= presentToday %> Present
                      </span>
                    </div>
                  </div>
                  <div class="col-6 col-xl-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#fef3c7;color:#d97706;"><i class="bi bi-cash-coin"></i>
                      </div>
                      <h3>2.4L</h3>
                      <p>Fees Collected (₹)</p>
                      <span class="tag tag-yellow">
                        <%= feesPending %> Pending
                      </span>
                    </div>
                  </div>
                </div>

                <!-- Mini stats -->
                <div class="row g-3 mb-4">
                  <div class="col-6 col-md-3">
                    <div class="mini-stat">
                      <div class="mini-stat-ico" style="background:#ede9fe;color:#7c3aed;"><i
                          class="bi bi-book-fill"></i>
                      </div>
                      <div class="mini-stat-info">
                        <p>12</p><small>Active Courses</small>
                      </div>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="mini-stat">
                      <div class="mini-stat-ico" style="background:#fee2e2;color:#dc2626;"><i
                          class="bi bi-x-circle-fill"></i>
                      </div>
                      <div class="mini-stat-info">
                        <p>
                          <%= absentToday %>
                        </p><small>Absent Today</small>
                      </div>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="mini-stat">
                      <div class="mini-stat-ico" style="background:#d1fae5;color:#059669;"><i
                          class="bi bi-trophy-fill"></i>
                      </div>
                      <div class="mini-stat-info">
                        <p>78.4%</p><small>Avg Score</small>
                      </div>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="mini-stat">
                      <div class="mini-stat-ico" style="background:#fef3c7;color:#d97706;"><i
                          class="bi bi-bell-fill"></i>
                      </div>
                      <div class="mini-stat-info">
                        <p>3</p><small>New Notices</small>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="row g-3">
                  <!-- Attendance by class -->
                  <div class="col-12 col-lg-6">
                    <div class="card-box">
                      <div class="card-head">
                        <i class="bi bi-calendar-check-fill" style="color:var(--accent);"></i>
                        <h6>Class-wise Attendance Today</h6>
                      </div>
                      <div class="card-body-p">
                        <div class="mb-3">
                          <div class="d-flex justify-content-between mb-1">
                            <span style="font-size:13px;font-weight:600;">Class 9</span>
                            <span
                              style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--green);">94%</span>
                          </div>
                          <div class="prog-bar-wrap">
                            <div class="prog-bar" style="width:94%;background:#10b981;"></div>
                          </div>
                        </div>
                        <div class="mb-3">
                          <div class="d-flex justify-content-between mb-1">
                            <span style="font-size:13px;font-weight:600;">Class 10</span>
                            <span
                              style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--accent);">91%</span>
                          </div>
                          <div class="prog-bar-wrap">
                            <div class="prog-bar" style="width:91%;background:#f97316;"></div>
                          </div>
                        </div>
                        <div class="mb-3">
                          <div class="d-flex justify-content-between mb-1">
                            <span style="font-size:13px;font-weight:600;">Class 11</span>
                            <span
                              style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--yellow);">86%</span>
                          </div>
                          <div class="prog-bar-wrap">
                            <div class="prog-bar" style="width:86%;background:#f59e0b;"></div>
                          </div>
                        </div>
                        <div>
                          <div class="d-flex justify-content-between mb-1">
                            <span style="font-size:13px;font-weight:600;">Class 12</span>
                            <span
                              style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--blue);">89%</span>
                          </div>
                          <div class="prog-bar-wrap">
                            <div class="prog-bar" style="width:89%;background:#3b82f6;"></div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Recent Activity -->
                  <div class="col-12 col-lg-6">
                    <div class="card-box">
                      <div class="card-head">
                        <i class="bi bi-activity" style="color:var(--purple);"></i>
                        <h6>Recent Activity</h6>
                      </div>
                      <div class="card-body-p">
                        <div class="activity-item">
                          <div class="act-ico" style="background:#d1fae5;color:#059669;"><i
                              class="bi bi-person-plus-fill"></i>
                          </div>
                          <div class="act-text">
                            <p>Naya student admit hua</p><small>Pooja Mehta — Class 9-B</small>
                          </div>
                          <span class="act-time">9:15 AM</span>
                        </div>
                        <div class="activity-item">
                          <div class="act-ico" style="background:#fef3c7;color:#d97706;"><i class="bi bi-cash-coin"></i>
                          </div>
                          <div class="act-text">
                            <p>Fee payment receive hua</p><small>Rohit Verma — ₹8,000</small>
                          </div>
                          <span class="act-time">8:48 AM</span>
                        </div>
                        <div class="activity-item">
                          <div class="act-ico" style="background:#fee2e2;color:#dc2626;"><i
                              class="bi bi-exclamation-triangle-fill"></i></div>
                          <div class="act-text">
                            <p>Low attendance warning</p><small>Suresh Patel — 62%</small>
                          </div>
                          <span class="act-time">8:30 AM</span>
                        </div>
                        <div class="activity-item">
                          <div class="act-ico" style="background:#dbeafe;color:#2563eb;"><i
                              class="bi bi-megaphone-fill"></i>
                          </div>
                          <div class="act-text">
                            <p>Notice publish kiya gaya</p><small>Sports Day — 10 March</small>
                          </div>
                          <span class="act-time">Yesterday</span>
                        </div>
                        <div class="activity-item">
                          <div class="act-ico" style="background:#ede9fe;color:#7c3aed;"><i
                              class="bi bi-file-earmark-check-fill"></i></div>
                          <div class="act-text">
                            <p>Result upload kiya</p><small>Class 10 — Half Yearly</small>
                          </div>
                          <span class="act-time">Yesterday</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Fee Collection Progress -->
                  <div class="col-12 col-md-5">
                    <div class="card-box">
                      <div class="card-head">
                        <i class="bi bi-cash-coin" style="color:var(--yellow);"></i>
                        <h6>Fee Collection — March 2026</h6>
                      </div>
                      <div class="card-body-p">
                        <div style="display:flex;align-items:baseline;gap:8px;margin-bottom:6px;">
                          <span
                            style="font-size:32px;font-weight:800;font-family:'JetBrains Mono',monospace;">₹2.4L</span>
                          <span style="color:var(--muted);font-size:13px;">of ₹2.88L</span>
                        </div>
                        <div class="prog-bar-wrap mb-3" style="height:10px;">
                          <div class="prog-bar" style="width:83%;background:linear-gradient(90deg,#f97316,#fbbf24);">
                          </div>
                        </div>
                        <div class="d-flex justify-content-between">
                          <div>
                            <div class="info-label">Collected</div>
                            <div style="font-weight:700;color:var(--green);">230 Students</div>
                          </div>
                          <div style="text-align:right;">
                            <div class="info-label">Pending</div>
                            <div style="font-weight:700;color:var(--red);">18 Students</div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Top performers -->
                  <div class="col-12 col-md-7">
                    <div class="card-box">
                      <div class="card-head">
                        <i class="bi bi-trophy-fill" style="color:var(--yellow);"></i>
                        <h6>Top Performers — Half Yearly</h6>
                      </div>
                      <div class="card-body-p" style="padding-top:12px;">
                        <table class="table tbl mb-0">
                          <thead>
                            <tr>
                              <th>Rank</th>
                              <th>Student</th>
                              <th>Class</th>
                              <th>Score</th>
                            </tr>
                          </thead>
                          <tbody>
                            <tr>
                              <td><span
                                  style="font-weight:800;font-family:'JetBrains Mono',monospace;color:#d97706;">#1</span>
                              </td>
                              <td>
                                <div class="d-flex align-items-center gap-2">
                                  <div class="av-sm" style="background:#fef3c7;color:#d97706;">PS</div>Priya Sharma
                                </div>
                              </td>
                              <td>12-A</td>
                              <td><span class="tag tag-yellow">96%</span></td>
                            </tr>
                            <tr>
                              <td><span
                                  style="font-weight:800;font-family:'JetBrains Mono',monospace;color:var(--muted);">#2</span>
                              </td>
                              <td>
                                <div class="d-flex align-items-center gap-2">
                                  <div class="av-sm" style="background:#d1fae5;color:#059669;">AK</div>Ananya Kumar
                                </div>
                              </td>
                              <td>12-B</td>
                              <td><span class="tag tag-green">93%</span></td>
                            </tr>
                            <tr>
                              <td><span
                                  style="font-weight:800;font-family:'JetBrains Mono',monospace;color:var(--muted);">#3</span>
                              </td>
                              <td>
                                <div class="d-flex align-items-center gap-2">
                                  <div class="av-sm" style="background:#dbeafe;color:#2563eb;">RV</div>Rohan Verma
                                </div>
                              </td>
                              <td>11-A</td>
                              <td><span class="tag tag-blue">91%</span></td>
                            </tr>
                          </tbody>
                        </table>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- ═══ PROFILE ═══ -->
              <div class="page" id="page-profile">
                <div class="profile-hero">
                  <button class="profile-edit-btn" onclick="openEditModal()">
                    <i class="bi bi-pencil-fill"></i><span>Profile Edit Karo</span>
                  </button>
                  <div class="profile-avatar-wrap">
                    <div class="profile-avatar">
                      <img src='<%= adPhotoBase64 != null ? "data:image/jpeg;base64," + adPhotoBase64
                        : "images/user_default_photo.webp" %>'
                      style="width:100%;height:100%;object-fit:cover;" id="profile-photo" />
                    </div>
                    <div class="avatar-edit-btn" onclick="document.getElementById('avatar-input-hero').click()">
                      <i class="bi bi-camera-fill"></i>
                    </div>
                    <input type="file" id="avatar-input-hero" accept="image/*" style="display:none"
                      onchange="handleAvatarChange(this)" />
                  </div>
                  <h3 id="profile-name">
                    <%= adName %>
                  </h3>
                  <div class="role-text" id="profile-role">
                    <%= adDesignation %> • EduManage System
                  </div>
                  <div class="profile-tags">
                    <span class="ptag" id="profile-dept-tag"><i class="bi bi-diagram-3-fill"></i>
                      <%= adDept %>
                    </span>
                    <span class="ptag"
                      style="background:rgba(249,115,22,.15);border-color:rgba(249,115,22,.3);color:var(--accent);">
                      Since <%= adJoined %>
                    </span>
                    <span class="ptag"
                      style="background:rgba(249,115,22,.15);border-color:rgba(249,115,22,.3);color:var(--accent);">
                      <%= adRole%>
                    </span>
                    <span class="ptag"
                      style="background:rgba(249,115,22,.15);border-color:rgba(249,115,22,.3);color:var(--accent);">
                      <%= adActive%>
                    </span>
                  </div>
                </div>

                <% if (!hasPersonalInfo && !hasProfessionalInfo) { %>
                  <div class="card-box p-5 text-center mb-4">
                    <i class="bi bi-person-exclamation"
                      style="font-size: 48px; color: var(--accent); opacity: 0.5;"></i>
                    <h5 class="mt-3" style="font-weight: 700;">Profile Incomplete Hai</h5>
                    <p class="text-muted">Your Profile is currently incomplete. Please, click on edit profile and fill
                      all the details.</p>
                    <button class="btn-accent mx-auto mt-2" onclick="openEditModal()">
                      <i class="bi bi-pencil-fill me-2"></i>Edit Profile
                    </button>
                  </div>
                  <% } %>

                    <div class="row g-3">
                      <% if (hasPersonalInfo) { %>
                        <div class="col-12 col-lg-7">
                          <div class="card-box">
                            <div class="card-head"><i class="bi bi-person-fill" style="color:var(--accent);"></i>
                              <h6>Personal Information</h6>
                            </div>
                            <div class="card-body-p">
                              <div class="row g-3">
                                <div class="col-6">
                                  <div class="info-label">Full Name</div>
                                  <div class="info-val" id="info-name">
                                    <%= adName %>
                                  </div>
                                </div>
                                <div class="col-6">
                                  <div class="info-label">Date of Birth</div>
                                  <div class="info-val" id="info-dob">
                                    <%= adDob %>
                                  </div>
                                </div>
                                <div class="col-6">
                                  <div class="info-label">Gender</div>
                                  <div class="info-val" id="info-gender">
                                    <%= adGender %>
                                  </div>
                                </div>
                                <div class="col-6">
                                  <div class="info-label">Blood Group</div>
                                  <div class="info-val" id="info-blood">
                                    <%= adBlood %>
                                  </div>
                                </div>
                                <div class="col-6">
                                  <div class="info-label">Phone Number</div>
                                  <div class="info-val" id="info-phone">
                                    <%= adPhone %>
                                  </div>
                                </div>
                                <div class="col-6">
                                  <div class="info-label">Email</div>
                                  <div class="info-val" id="info-email">
                                    <%= adEmail %>
                                  </div>
                                </div>
                                <div class="col-12">
                                  <div class="info-label">Address</div>
                                  <div class="info-val" id="info-address">
                                    <%= adAddress %>
                                  </div>
                                </div>
                              </div>
                            </div>
                          </div>
                        </div>
                        <% } %>

                          <% if (hasProfessionalInfo) { %>
                            <div class="col-12 col-lg-5">
                              <div class="card-box mb-3">
                                <div class="card-head"><i class="bi bi-briefcase-fill" style="color:var(--blue);"></i>
                                  <h6>Professional Details</h6>
                                </div>
                                <div class="card-body-p">
                                  <div class="col-12">
                                    <div class="info-label">Subject</div>
                                    <div class="info-val">
                                      <%= adSubject %>
                                    </div>
                                  </div>
                                  <div class="col-6">
                                    <div class="info-label">Department</div>
                                    <div class="info-val" id="info-dept">
                                      <%= adDept %>
                                    </div>
                                  </div>
                                  <div class="col-6">
                                    <div class="info-label">Employee ID</div>
                                    <div class="info-val" style="font-family:'JetBrains Mono',monospace;">
                                      <%= adEmpId %>
                                    </div>
                                  </div>
                                  <div class="col-6">
                                    <div class="info-label">Qualification</div>
                                    <div class="info-val">
                                      <%= adQual %>
                                    </div>
                                  </div>
                                  <div class="col-6">
                                    <div class="info-label">Experience</div>
                                    <div class="info-val">
                                      <%= adExp %>
                                    </div>
                                  </div>
                                  <div class="col-12">
                                    <div class="info-label">Joined On</div>
                                    <div class="info-val">
                                      <%= adJoined %>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </div>
                            <% } %>

                              <div class="col-12 col-lg-5">
                                <div class="card-box">
                                  <div class="card-head"><i class="bi bi-shield-lock-fill"
                                      style="color:var(--green);"></i>
                                    <h6>Access & Permissions</h6>
                                  </div>
                                  <div class="card-body-p">
                                    <div class="row g-2">
                                      <div class="col-12">
                                        <div class="d-flex align-items-center justify-content-between p-2 rounded-3"
                                          style="background:#f8fafc;"><span
                                            style="font-size:13px;font-weight:600;">Student
                                            Management</span><span class="tag tag-green">Full Access</span></div>
                                      </div>
                                      <div class="col-12">
                                        <div class="d-flex align-items-center justify-content-between p-2 rounded-3"
                                          style="background:#f8fafc;"><span style="font-size:13px;font-weight:600;">Fee
                                            Management</span><span class="tag tag-green">Full Access</span></div>
                                      </div>
                                      <div class="col-12">
                                        <div class="d-flex align-items-center justify-content-between p-2 rounded-3"
                                          style="background:#f8fafc;"><span
                                            style="font-size:13px;font-weight:600;">System
                                            Settings</span><span class="tag tag-orange">Admin Only</span></div>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                    </div>
              </div> <!-- FIX: page-profile closes here -->

              <!-- ═══ STUDENTS ═══ -->
              <div class="page" id="page-students">
                <div class="pg-header">
                  <div class="pg-header-left">
                    <h4>Students Management</h4>
                    <p>List of all students!! Add, edit and delete students</p>
                  </div>
                  <div class="d-flex gap-2">
                    <button class="btn-outline" onclick="exportStudentsToExcel()"><i class="bi bi-download"></i>
                      Export</button>
                    <button class="btn-accent" onclick="openAddStudentModal()"><i class="bi bi-person-plus-fill"></i>
                      Add New Student</button>
                  </div>
                </div>

                <!-- Stats row -->
                <div class="row g-3 mb-3">
                  <div class="col-6 col-md-3">
                    <div class="mini-stat">
                      <div class="mini-stat-ico" style="background:#ffedd5;color:#ea580c;"><i
                          class="bi bi-people-fill"></i>
                      </div>
                      <div class="mini-stat-info">
                        <p>
                          <%= totalStudents %>
                        </p><small>Total</small>
                      </div>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="mini-stat">
                      <div class="mini-stat-ico" style="background:#d1fae5;color:#059669;"><i
                          class="bi bi-person-check-fill"></i>
                      </div>
                      <div class="mini-stat-info">
                        <p>
                          <%= activeStudents %>
                        </p><small>Active</small>
                      </div>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="mini-stat">
                      <div class="mini-stat-ico" style="background:#fee2e2;color:#dc2626;"><i
                          class="bi bi-person-x-fill"></i>
                      </div>
                      <div class="mini-stat-info">
                        <p>
                          <%= inactiveStudents %>
                        </p><small>Inactive</small>
                      </div>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="mini-stat">
                      <div class="mini-stat-ico" style="background:#dbeafe;color:#2563eb;"><i
                          class="bi bi-person-plus-fill"></i>
                      </div>
                      <div class="mini-stat-info">
                        <p>
                          <%= newStudentsThisMonth %>
                        </p><small>New (March)</small>
                      </div>
                    </div>
                  </div>
                </div>

                <% String searchVal=(request.getParameter("search") !=null) ? request.getParameter("search") : "" ; %>
                  <div class="card-box">
                    <div class="card-head">
                      <i class="bi bi-people-fill" style="color:var(--accent);"></i>
                      <h6>All Students</h6>
                      <div class="ms-auto d-flex gap-2">
                        <form action="" method="get" class="d-flex gap-2" id="studentFilterForm"
                          onsubmit="event.preventDefault(); applyStudentFilters();">
                          <input type="hidden" name="page" value="students" />
                          <div class="position-relative">
                            <input type="text" name="search" id="studentSearchInput" class="form-control"
                              placeholder="Search students..." value="<%= searchVal %>" oninput="applyStudentFilters()"
                              onkeydown="if(event.key==='Enter') applyStudentFilters()"
                              style="width:180px;padding:7px 12px;font-size:13px;border-radius:9px;" />
                          </div>
                          <select name="classFilter" id="classFilterSelect" class="form-select"
                            onchange="applyStudentFilters()"
                            style="width:130px;font-size:13px;padding:7px 10px;border-radius:9px; transition:all 0.2s;">
                            <option value="">All Classes</option>
                            <% 
                              Connection connC=null; 
                              try { 
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                connC=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root" , "" );
                                String queryC="SELECT DISTINCT class FROM students WHERE class IS NOT NULL AND class != '' ORDER BY CAST(class AS UNSIGNED) ASC"; 
                                ResultSet rsC=connC.createStatement().executeQuery(queryC); 
                                String currentFilter=request.getParameter("classFilter"); 
                                while(rsC.next()){ 
                                  String cName=rsC.getString("class"); 
                            %>
                              <option value="<%= cName %>" <%=(cName !=null && cName.equals(currentFilter)) ? "selected"
                                : "" %>>Class <%= cName %>
                              </option>
                              <% 
                                } 
                              } catch(Exception e){ 
                                e.printStackTrace(); 
                              } finally { 
                                if(connC != null) try { connC.close(); } catch(Exception e) {} 
                              } 
                              %>
                          </select>
                          <button type="button" class="btn-icon" onclick="applyStudentFilters()"
                            style="background:var(--accent);color:#fff;border:none;">
                            <i class="bi bi-search"></i>
                          </button>
                        </form>
                      </div>
                    </div>
                    <div class="table-responsive">
                      <table class="table tbl mb-0">
                        <thead>
                          <tr>
                            <th>Student</th>
                            <th>Roll No.</th>
                            <th>Class</th>
                            <th>Attendance</th>
                            <th>Fees</th>
                            <th>Status</th>
                            <th>Actions</th>
                          </tr>
                        </thead>
                        <tbody>
                          <%
                            Connection connSt = null;
                            try {
                              connSt = DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root", "");
                              String search = (request.getParameter("search") != null) ? request.getParameter("search") : "";
                              String classFilter = (request.getParameter("classFilter") != null) ? request.getParameter("classFilter") : "";
                              
                              StringBuilder baseQuery = new StringBuilder("SELECT s.student_id, s.name, s.email, s.roll_no, s.class, s.section, u.is_active FROM students s JOIN user u ON s.user_id = u.user_id WHERE 1=1");
                              if (!search.isEmpty()) {
                                baseQuery.append(" AND (s.name LIKE '%").append(search).append("%' OR s.email LIKE '%").append(search).append("%' OR s.roll_no LIKE '%").append(search).append("%')");
                              }
                              if (!classFilter.isEmpty()) {
                                baseQuery.append(" AND s.class = '").append(classFilter).append("'");
                              }
                              baseQuery.append(" ORDER BY s.name");

                              String[] colors = {"#ffedd5", "#dbeafe", "#d1fae5", "#fef3c7", "#ede9fe", "#fee2e2"};
                              String[] textColors = {"#ea580c", "#2563eb", "#059669", "#d97706", "#7c3aed", "#dc2626"};

                              ResultSet stRs = connSt.createStatement().executeQuery(baseQuery.toString());
                              int idx = 0;
                              while (stRs.next()) {
                                String sid = stRs.getString("student_id");
                                String sName = stRs.getString("name");
                                if (sName == null) sName = "Unknown";
                                String sEmail = stRs.getString("email");
                                if (sEmail == null) sEmail = "";
                                String sRoll = stRs.getString("roll_no");
                                if (sRoll == null) sRoll = "0";
                                String sClassVal = stRs.getString("class");
                                String sSectVal = stRs.getString("section");
                                String sClass = (sClassVal != null ? sClassVal : "") + "-" + (sSectVal != null ? sSectVal : "");
                                
                                int sAtt = 92;
                                String sFees = "Paid";
                                int sActive = stRs.getInt("is_active");
                                String statusText = (sActive == 1) ? "Active" : "Inactive";
                                String statusClass = (sActive == 1) ? "tag-green" : "tag-red";
                                String feesTag = "Paid".equals(sFees) ? "tag-green" : "tag-red";

                                StringBuilder sbInit = new StringBuilder();
                                String[] parts = sName.trim().split("\\s+");
                                for (String part : parts) {
                                  if (part.length() > 0) sbInit.append(part.charAt(0));
                                }
                                String initials = sbInit.toString().toUpperCase();
                                if (initials.length() > 2) initials = initials.substring(0, 2);
                                if (initials.isEmpty()) initials = "??";

                                String rowBg = colors[idx % colors.length];
                                String rowTc = textColors[idx % textColors.length];
                                String rowStyle = "background-color:" + rowBg + ";color:" + rowTc + ";";
                                String attColor = sAtt >= 85 ? "var(--green)" : sAtt >= 70 ? "var(--yellow)" : "var(--red)";
                                String attStyle = "font-weight:700; color:" + attColor + ";";
                                String escapedName = sName.replace("'", "\\'");
                                String avatarHtml = "<div class=\"av-sm\" style=\"background-color:" + rowBg + ";color:" + rowTc + "\">" + initials + "</div>";
                                String attSpan = "<span style=\"font-weight:700;color:" + attColor + "\">" + sAtt + "%</span>";
                                String feesSpan = "<span class=\"tag " + feesTag + "\">" + sFees + "</span>";
                                String statusSpan = "<span class=\"tag " + statusClass + "\">" + statusText + "</span>";
                                idx++;
                          %>
                            <tr class="student-row"
                              data-id="<%= sid %>"
                              data-name="<%= sName.toLowerCase() %>"
                              data-email="<%= sEmail.toLowerCase() %>"
                              data-roll="<%= sRoll.toLowerCase() %>"
                              data-class="<%= sClassVal %>"
                              data-att="<%= sAtt %>%"
                              data-fees="<%= sFees %>"
                              data-status="<%= statusText %>"
                              data-name-val="<%= sName %>"
                              data-email-val="<%= sEmail %>"
                              data-class-val="<%= sClassVal %>"
                              data-section-val="<%= sSectVal != null ? sSectVal : "" %>"
                              data-roll-val="<%= sRoll %>">
                              <td>
                                <div class="d-flex align-items-center gap-2">
                                  <%= avatarHtml %>
                                  <div>
                                    <div style="font-weight:600;" class="search-name">
                                      <%= sName %>
                                    </div>
                                    <div style="font-size:11px;color:var(--muted);" class="search-email">
                                      <%= sEmail %>
                                    </div>
                                  </div>
                                </div>
                              </td>
                              <td style="font-family:'JetBrains Mono',monospace;" class="search-roll">#<%= sRoll %>
                              </td>
                              <td class="search-class">
                                <%= sClass %>
                              </td>
                              <td><%= attSpan %></td>
                              <td><%= feesSpan %></td>
                              <td><%= statusSpan %></td>
                              <td>
                                <div class=" d-flex gap-1">
                                    <button class="btn-icon" onclick="openEditStudentModal('<%= sid %>')"><i
                                        class="bi bi-pencil-fill"></i></button>
                                    <button class="btn-icon del"
                                      onclick="confirmDeleteStudent('<%= sid %>', '<%= escapedName %>')"><i
                                        class="bi bi-trash-fill"></i></button>
                                </div>
                              </td>
                            </tr>
                            <%
                              } // end while
                              String noRowStyle = (idx == 0) ? "" : "display:none;";
                            %>
                              <tr id="noStudentRow" <%= (idx > 0) ? "hidden" : "" %>>
                                <td colspan="7" style="text-align:center;padding:40px 20px;">
                                  <div style="font-size:36px;">😕</div>
                                  <div style="font-size:16px;font-weight:700;margin-top:8px;">Oops!! Data Not Found
                                  </div>
                                  <div style="font-size:13px;color:var(--muted);margin-top:4px;">
                                    <%= (idx==0) ? "No students records in database."
                                      : "Search ya filter change karke dobara try karein." %>
                                  </div>
                                </td>
                              </tr>
                            <%
                            } catch(Exception e) {
                              e.printStackTrace();
                            } finally {
                              if(connSt != null) try { connSt.close(); } catch(Exception ex) {}
                            }
                          %>
                        </tbody>
                      </table>
                    </div>
                  </div>
              </div> <!-- End of Page Students -->

              <!-- ═══ TEACHERS ═══ -->
              <div class="page" id="page-teachers">
                <div class="pg-header">
                  <div class="pg-header-left">
                    <h4>Teachers Management</h4>
                    <p>Staff ki poori details manage karo</p>
                  </div>
                  <button class="btn-accent"><i class="bi bi-person-plus-fill"></i> Naya Teacher Add</button>
                </div>
                <div class="row g-3 mb-3">
                  <div class="col-6 col-md-3">
                    <div class="mini-stat">
                      <div class="mini-stat-ico" style="background:#dbeafe;color:#2563eb;"><i
                          class="bi bi-people-fill"></i>
                      </div>
                      <div class="mini-stat-info">
                        <p>24</p><small>Total Staff</small>
                      </div>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="mini-stat">
                      <div class="mini-stat-ico" style="background:#d1fae5;color:#059669;"><i
                          class="bi bi-person-check-fill"></i>
                      </div>
                      <div class="mini-stat-info">
                        <p>22</p><small>Active</small>
                      </div>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="mini-stat">
                      <div class="mini-stat-ico" style="background:#fef3c7;color:#d97706;"><i
                          class="bi bi-hourglass-split"></i>
                      </div>
                      <div class="mini-stat-info">
                        <p>2</p><small>On Leave</small>
                      </div>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="mini-stat">
                      <div class="mini-stat-ico" style="background:#ffedd5;color:#ea580c;"><i
                          class="bi bi-award-fill"></i>
                      </div>
                      <div class="mini-stat-info">
                        <p>6</p><small>Departments</small>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="card-box">
                  <div class="card-head"><i class="bi bi-person-video3" style="color:var(--blue);"></i>
                    <h6>All Teachers</h6>
                  </div>
                  <div class="table-responsive">
                    <table class="table tbl mb-0">
                      <thead>
                        <tr>
                          <th>Teacher</th>
                          <th>Employee ID</th>
                          <th>Subject</th>
                          <th>Classes</th>
                          <th>Experience</th>
                          <th>Status</th>
                          <th>Actions</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td>
                            <div class="d-flex align-items-center gap-2">
                              <div class="av-sm" style="background:#ffedd5;color:#ea580c;">RG</div>
                              <div>
                                <div style="font-weight:600;">Ramesh Gupta</div>
                                <div style="font-size:11px;color:var(--muted);"><a href="/cdn-cgi/l/email-protection"
                                    class="__cf_email__"
                                    data-cfemail="7002111d150318301400035e151405">[email&#160;protected]</a>
                                </div>
                              </div>
                            </div>
                          </td>
                          <td style="font-family:'JetBrains Mono',monospace;">EMP-2015-004</td>
                          <td>Mathematics</td>
                          <td>9, 10, 11</td>
                          <td>11 yrs</td>
                          <td><span class="tag tag-green">Active</span></td>
                          <td>
                            <div class="d-flex gap-1"><button class="btn-icon"><i
                                  class="bi bi-pencil-fill"></i></button><button class="btn-icon del"><i
                                  class="bi bi-trash-fill"></i></button></div>
                          </td>
                        </tr>
                        <tr>
                          <td>
                            <div class="d-flex align-items-center gap-2">
                              <div class="av-sm" style="background:#d1fae5;color:#059669;">PJ</div>
                              <div>
                                <div style="font-weight:600;">Priya Joshi</div>
                                <div style="font-size:11px;color:var(--muted);"><a href="/cdn-cgi/l/email-protection"
                                    class="__cf_email__"
                                    data-cfemail="95e5e7fcecf4d5f1e5e6bbf0f1e0">[email&#160;protected]</a>
                                </div>
                              </div>
                            </div>
                          </td>
                          <td style="font-family:'JetBrains Mono',monospace;">EMP-2018-009</td>
                          <td>Science</td>
                          <td>9, 10</td>
                          <td>8 yrs</td>
                          <td><span class="tag tag-green">Active</span></td>
                          <td>
                            <div class="d-flex gap-1"><button class="btn-icon"><i
                                  class="bi bi-pencil-fill"></i></button><button class="btn-icon del"><i
                                  class="bi bi-trash-fill"></i></button></div>
                          </td>
                        </tr>
                        <tr>
                          <td>
                            <div class="d-flex align-items-center gap-2">
                              <div class="av-sm" style="background:#dbeafe;color:#2563eb;">DA</div>
                              <div>
                                <div style="font-weight:600;">David Abraham</div>
                                <div style="font-size:11px;color:var(--muted);"><a href="/cdn-cgi/l/email-protection"
                                    class="__cf_email__"
                                    data-cfemail="b8dcd9ced1dcf8dcc8cb96dddccd">[email&#160;protected]</a>
                                </div>
                              </div>
                            </div>
                          </td>
                          <td style="font-family:'JetBrains Mono',monospace;">EMP-2020-012</td>
                          <td>English</td>
                          <td>10, 11, 12</td>
                          <td>5 yrs</td>
                          <td><span class="tag tag-yellow">On Leave</span></td>
                          <td>
                            <div class="d-flex gap-1"><button class="btn-icon"><i
                                  class="bi bi-pencil-fill"></i></button><button class="btn-icon del"><i
                                  class="bi bi-trash-fill"></i></button></div>
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>

              <!-- ═══ ATTENDANCE ═══ -->
              <div class="page" id="page-attendance">
                <div class="pg-header">
                  <div class="pg-header-left">
                    <h4>Attendance Management</h4>
                    <p>Class-wise attendance mark karo aur reports dekho</p>
                  </div>
                  <button class="btn-accent"><i class="bi bi-clipboard-check-fill"></i> Attendance Mark Karo</button>
                </div>
                <div class="row g-3 mb-3">
                  <div class="col-6 col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#d1fae5;color:#059669;"><i
                          class="bi bi-check-circle-fill"></i>
                      </div>
                      <h3>226</h3>
                      <p>Present Today</p><span class="tag tag-green">91%</span>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#fee2e2;color:#dc2626;"><i
                          class="bi bi-x-circle-fill"></i>
                      </div>
                      <h3>22</h3>
                      <p>Absent Today</p><span class="tag tag-red">8.9%</span>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#fef3c7;color:#d97706;"><i
                          class="bi bi-dash-circle-fill"></i>
                      </div>
                      <h3>4</h3>
                      <p>On Leave</p><span class="tag tag-yellow">Approved</span>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#dbeafe;color:#2563eb;"><i class="bi bi-calendar3"></i>
                      </div>
                      <h3>184</h3>
                      <p>Working Days</p><span class="tag tag-blue">This Year</span>
                    </div>
                  </div>
                </div>
                <div class="card-box mb-3">
                  <div class="card-head">
                    <h6>Class-wise Attendance — Today</h6>
                  </div>
                  <div class="table-responsive">
                    <table class="table tbl mb-0">
                      <thead>
                        <tr>
                          <th>Class</th>
                          <th>Total Students</th>
                          <th>Present</th>
                          <th>Absent</th>
                          <th>%</th>
                          <th>Status</th>
                          <th>Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td style="font-weight:700;">Class 9</td>
                          <td>62</td>
                          <td style="color:var(--green);font-weight:700;">58</td>
                          <td style="color:var(--red);font-weight:700;">4</td>
                          <td style="font-weight:700;font-family:'JetBrains Mono',monospace;">94%</td>
                          <td><span class="tag tag-green">Good</span></td>
                          <td><button class="btn-icon"><i class="bi bi-eye-fill"></i></button></td>
                        </tr>
                        <tr>
                          <td style="font-weight:700;">Class 10</td>
                          <td>56</td>
                          <td style="color:var(--green);font-weight:700;">51</td>
                          <td style="color:var(--red);font-weight:700;">5</td>
                          <td style="font-weight:700;font-family:'JetBrains Mono',monospace;">91%</td>
                          <td><span class="tag tag-green">Good</span></td>
                          <td><button class="btn-icon"><i class="bi bi-eye-fill"></i></button></td>
                        </tr>
                        <tr>
                          <td style="font-weight:700;">Class 11</td>
                          <td>70</td>
                          <td style="color:var(--green);font-weight:700;">60</td>
                          <td style="color:var(--red);font-weight:700;">10</td>
                          <td style="font-weight:700;font-family:'JetBrains Mono',monospace;">86%</td>
                          <td><span class="tag tag-yellow">Average</span></td>
                          <td><button class="btn-icon"><i class="bi bi-eye-fill"></i></button></td>
                        </tr>
                        <tr>
                          <td style="font-weight:700;">Class 12</td>
                          <td>60</td>
                          <td style="color:var(--green);font-weight:700;">54</td>
                          <td style="color:var(--red);font-weight:700;">6</td>
                          <td style="font-weight:700;font-family:'JetBrains Mono',monospace;">90%</td>
                          <td><span class="tag tag-green">Good</span></td>
                          <td><button class="btn-icon"><i class="bi bi-eye-fill"></i></button></td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
                <div class="card-box">
                  <div class="card-head"><i class="bi bi-exclamation-triangle-fill" style="color:var(--red);"></i>
                    <h6>Low Attendance Alert (Below 75%)</h6>
                  </div>
                  <div class="card-body-p">
                    <table class="table tbl mb-0">
                      <thead>
                        <tr>
                          <th>Student</th>
                          <th>Class</th>
                          <th>Attendance %</th>
                          <th>Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td>
                            <div class="d-flex align-items-center gap-2">
                              <div class="av-sm" style="background:#fee2e2;color:#dc2626;">SM</div>Suresh Mehta
                            </div>
                          </td>
                          <td>12-A</td>
                          <td><span
                              style="font-weight:800;color:var(--red);font-family:'JetBrains Mono',monospace;">65%</span>
                          </td>
                          <td><button class="btn-accent" style="padding:6px 14px;font-size:12px;">Notice Bhejo</button>
                          </td>
                        </tr>
                        <tr>
                          <td>
                            <div class="d-flex align-items-center gap-2">
                              <div class="av-sm" style="background:#fee2e2;color:#dc2626;">PS</div>Priya Singh
                            </div>
                          </td>
                          <td>10-B</td>
                          <td><span
                              style="font-weight:800;color:var(--red);font-family:'JetBrains Mono',monospace;">72%</span>
                          </td>
                          <td><button class="btn-accent" style="padding:6px 14px;font-size:12px;">Notice Bhejo</button>
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>

              <!-- ═══ RESULTS ═══ -->
              <div class="page" id="page-results">
                <div class="pg-header">
                  <div class="pg-header-left">
                    <h4>Results & Grades</h4>
                    <p>Exam results manage karo aur marksheets generate karo</p>
                  </div>
                  <button class="btn-accent"><i class="bi bi-upload"></i> Results Upload Karo</button>
                </div>
                <div class="row g-3 mb-3">
                  <div class="col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#ede9fe;color:#7c3aed;"><i class="bi bi-trophy-fill"></i>
                      </div>
                      <h3>78.4%</h3>
                      <p>School Average</p><span class="tag tag-purple">All Classes</span>
                    </div>
                  </div>
                  <div class="col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#d1fae5;color:#059669;"><i class="bi bi-star-fill"></i>
                      </div>
                      <h3>28</h3>
                      <p>Distinctions</p><span class="tag tag-green">90%+</span>
                    </div>
                  </div>
                  <div class="col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#fee2e2;color:#dc2626;"><i
                          class="bi bi-x-circle-fill"></i>
                      </div>
                      <h3>6</h3>
                      <p>Failed Students</p><span class="tag tag-red">Needs Attention</span>
                    </div>
                  </div>
                  <div class="col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#ffedd5;color:#ea580c;"><i
                          class="bi bi-file-earmark-text-fill"></i>
                      </div>
                      <h3>4</h3>
                      <p>Exams Completed</p>
                    </div>
                  </div>
                </div>
                <div class="card-box">
                  <div class="card-head">
                    <h6>Class-wise Result Summary — Half Yearly 2025</h6>
                    <div class="ms-auto"><button class="btn-outline" style="font-size:12px;padding:6px 14px;"><i
                          class="bi bi-download"></i> Export PDF</button></div>
                  </div>
                  <div class="table-responsive">
                    <table class="table tbl mb-0">
                      <thead>
                        <tr>
                          <th>Class</th>
                          <th>Total Students</th>
                          <th>Appeared</th>
                          <th>Passed</th>
                          <th>Failed</th>
                          <th>Average %</th>
                          <th>Highest</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td style="font-weight:700;">Class 9</td>
                          <td>62</td>
                          <td>62</td>
                          <td style="color:var(--green);font-weight:700;">60</td>
                          <td style="color:var(--red);font-weight:700;">2</td>
                          <td style="font-family:'JetBrains Mono',monospace;font-weight:700;">74.2%</td>
                          <td><span class="tag tag-green">92%</span></td>
                        </tr>
                        <tr>
                          <td style="font-weight:700;">Class 10</td>
                          <td>56</td>
                          <td>55</td>
                          <td style="color:var(--green);font-weight:700;">54</td>
                          <td style="color:var(--red);font-weight:700;">1</td>
                          <td style="font-family:'JetBrains Mono',monospace;font-weight:700;">78.4%</td>
                          <td><span class="tag tag-yellow">96%</span></td>
                        </tr>
                        <tr>
                          <td style="font-weight:700;">Class 11</td>
                          <td>70</td>
                          <td>70</td>
                          <td style="color:var(--green);font-weight:700;">68</td>
                          <td style="color:var(--red);font-weight:700;">2</td>
                          <td style="font-family:'JetBrains Mono',monospace;font-weight:700;">71.8%</td>
                          <td><span class="tag tag-blue">91%</span></td>
                        </tr>
                        <tr>
                          <td style="font-weight:700;">Class 12</td>
                          <td>60</td>
                          <td>60</td>
                          <td style="color:var(--green);font-weight:700;">59</td>
                          <td style="color:var(--red);font-weight:700;">1</td>
                          <td style="font-family:'JetBrains Mono',monospace;font-weight:700;">81.6%</td>
                          <td><span class="tag tag-purple">96%</span></td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>

              <!-- ═══ COURSES ═══ -->
              <div class="page" id="page-courses">
                <div class="pg-header">
                  <div class="pg-header-left">
                    <h4>Courses Management</h4>
                    <p>Sabhi subjects aur courses manage karo</p>
                  </div>
                  <button class="btn-accent"><i class="bi bi-plus-lg"></i> Naya Course Add</button>
                </div>
                <div class="row g-3">
                  <div class="col-md-4">
                    <div class="card-box p-4">
                      <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="stat-ico" style="background:#ffedd5;color:#ea580c;margin:0;"><i
                            class="bi bi-calculator-fill"></i></div>
                        <div>
                          <div style="font-weight:700;font-size:15px;">Mathematics</div>
                          <div style="font-size:12px;color:var(--muted);">Ramesh Gupta</div>
                        </div>
                        <div class="ms-auto d-flex gap-1"><button class="btn-icon"><i
                              class="bi bi-pencil-fill"></i></button><button class="btn-icon del"><i
                              class="bi bi-trash-fill"></i></button></div>
                      </div>
                      <div class="d-flex justify-content-between"><span class="tag tag-orange">9, 10, 11, 12</span><span
                          style="font-size:13px;font-weight:600;">168 Students</span></div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="card-box p-4">
                      <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="stat-ico" style="background:#d1fae5;color:#059669;margin:0;"><i
                            class="bi bi-flask-fill"></i>
                        </div>
                        <div>
                          <div style="font-weight:700;font-size:15px;">Science</div>
                          <div style="font-size:12px;color:var(--muted);">Priya Joshi</div>
                        </div>
                        <div class="ms-auto d-flex gap-1"><button class="btn-icon"><i
                              class="bi bi-pencil-fill"></i></button><button class="btn-icon del"><i
                              class="bi bi-trash-fill"></i></button></div>
                      </div>
                      <div class="d-flex justify-content-between"><span class="tag tag-green">9, 10</span><span
                          style="font-size:13px;font-weight:600;">118 Students</span></div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="card-box p-4">
                      <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="stat-ico" style="background:#dbeafe;color:#2563eb;margin:0;"><i
                            class="bi bi-translate"></i>
                        </div>
                        <div>
                          <div style="font-weight:700;font-size:15px;">English</div>
                          <div style="font-size:12px;color:var(--muted);">David Abraham</div>
                        </div>
                        <div class="ms-auto d-flex gap-1"><button class="btn-icon"><i
                              class="bi bi-pencil-fill"></i></button><button class="btn-icon del"><i
                              class="bi bi-trash-fill"></i></button></div>
                      </div>
                      <div class="d-flex justify-content-between"><span class="tag tag-blue">9, 10, 11, 12</span><span
                          style="font-size:13px;font-weight:600;">248 Students</span></div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="card-box p-4">
                      <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="stat-ico" style="background:#ede9fe;color:#7c3aed;margin:0;"><i
                            class="bi bi-globe"></i>
                        </div>
                        <div>
                          <div style="font-weight:700;font-size:15px;">Social Science</div>
                          <div style="font-size:12px;color:var(--muted);">Anita Rao</div>
                        </div>
                        <div class="ms-auto d-flex gap-1"><button class="btn-icon"><i
                              class="bi bi-pencil-fill"></i></button><button class="btn-icon del"><i
                              class="bi bi-trash-fill"></i></button></div>
                      </div>
                      <div class="d-flex justify-content-between"><span class="tag tag-purple">9, 10</span><span
                          style="font-size:13px;font-weight:600;">118 Students</span></div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="card-box p-4">
                      <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="stat-ico" style="background:#fef3c7;color:#d97706;margin:0;"><i
                            class="bi bi-cpu-fill"></i>
                        </div>
                        <div>
                          <div style="font-weight:700;font-size:15px;">Computer Science</div>
                          <div style="font-size:12px;color:var(--muted);">Vikram Nair</div>
                        </div>
                        <div class="ms-auto d-flex gap-1"><button class="btn-icon"><i
                              class="bi bi-pencil-fill"></i></button><button class="btn-icon del"><i
                              class="bi bi-trash-fill"></i></button></div>
                      </div>
                      <div class="d-flex justify-content-between"><span class="tag tag-yellow">11, 12</span><span
                          style="font-size:13px;font-weight:600;">74 Students</span></div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="card-box p-4"
                      style="border-style:dashed;cursor:pointer;display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:100px;gap:8px;">
                      <i class="bi bi-plus-circle-fill" style="font-size:28px;color:var(--muted);"></i><span
                        style="font-weight:600;color:var(--muted);">Naya Course Add Karo</span>
                    </div>
                  </div>
                </div>
              </div>

              <!-- ═══ FEES ═══ -->
              <div class="page" id="page-fees">
                <div class="pg-header">
                  <div class="pg-header-left">
                    <h4>Fee Management</h4>
                    <p>Collections, pending aur transactions manage karo</p>
                  </div>
                  <div class="d-flex gap-2">
                    <button class="btn-outline"><i class="bi bi-download"></i> Export</button>
                    <button class="btn-accent"><i class="bi bi-plus-lg"></i> Payment Add Karo</button>
                  </div>
                </div>
                <div class="row g-3 mb-3">
                  <div class="col-6 col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#d1fae5;color:#059669;"><i
                          class="bi bi-check-circle-fill"></i>
                      </div>
                      <h3>2.4L</h3>
                      <p>Collected (₹)</p><span class="tag tag-green">This Month</span>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#fee2e2;color:#dc2626;"><i
                          class="bi bi-exclamation-circle-fill"></i></div>
                      <h3>48K</h3>
                      <p>Pending (₹)</p><span class="tag tag-red">18 Students</span>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#ffedd5;color:#ea580c;"><i class="bi bi-cash-stack"></i>
                      </div>
                      <h3>7.94L</h3>
                      <p>Annual Target (₹)</p>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#ede9fe;color:#7c3aed;"><i class="bi bi-receipt"></i>
                      </div>
                      <h3>230</h3>
                      <p>Payments Done</p><span class="tag tag-purple">This Month</span>
                    </div>
                  </div>
                </div>
                <div class="card-box">
                  <div class="card-head">
                    <h6>Recent Transactions</h6>
                    <div class="ms-auto"><select class="form-select"
                        style="width:130px;font-size:12px;padding:6px 10px;border-radius:9px;">
                        <option>All Status</option>
                        <option>Paid</option>
                        <option>Pending</option>
                      </select></div>
                  </div>
                  <div class="table-responsive">
                    <table class="table tbl mb-0">
                      <thead>
                        <tr>
                          <th>Transaction ID</th>
                          <th>Student</th>
                          <th>Class</th>
                          <th>Amount</th>
                          <th>Date</th>
                          <th>Status</th>
                          <th>Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td style="font-family:'JetBrains Mono',monospace;font-size:11px;">TXN-20260302-001</td>
                          <td>Arjun Kumar</td>
                          <td>10-A</td>
                          <td style="font-weight:700;">₹8,000</td>
                          <td>2 Mar 2026</td>
                          <td><span class="tag tag-green">Paid</span></td>
                          <td><button class="btn-icon"><i class="bi bi-receipt"></i></button></td>
                        </tr>
                        <tr>
                          <td style="font-family:'JetBrains Mono',monospace;font-size:11px;">TXN-20260301-008</td>
                          <td>Neha Kapoor</td>
                          <td>9-C</td>
                          <td style="font-weight:700;">₹8,000</td>
                          <td>1 Mar 2026</td>
                          <td><span class="tag tag-green">Paid</span></td>
                          <td><button class="btn-icon"><i class="bi bi-receipt"></i></button></td>
                        </tr>
                        <tr>
                          <td style="font-family:'JetBrains Mono',monospace;font-size:11px;">TXN-20260228-003</td>
                          <td>Priya Singh</td>
                          <td>10-B</td>
                          <td style="font-weight:700;">₹8,000</td>
                          <td>28 Feb 2026</td>
                          <td><span class="tag tag-red">Pending</span></td>
                          <td><button class="btn-icon"><i class="bi bi-send-fill"></i></button></td>
                        </tr>
                        <tr>
                          <td style="font-family:'JetBrains Mono',monospace;font-size:11px;">TXN-20260228-005</td>
                          <td>Suresh Mehta</td>
                          <td>12-A</td>
                          <td style="font-weight:700;">₹8,000</td>
                          <td>28 Feb 2026</td>
                          <td><span class="tag tag-red">Pending</span></td>
                          <td><button class="btn-icon"><i class="bi bi-send-fill"></i></button></td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>

              <!-- ═══ NOTICES ═══ -->
              <div class="page" id="page-notices">
                <div class="pg-header">
                  <div class="pg-header-left">
                    <h4>Notice Board</h4>
                    <p>Notices create karo aur publish karo</p>
                  </div>
                  <button class="btn-accent"><i class="bi bi-megaphone-fill"></i> Naya Notice Publish Karo</button>
                </div>
                <div class="row g-3">
                  <div class="col-12 col-md-7">
                    <div class="card-box">
                      <div class="card-head">
                        <h6>Active Notices (3)</h6>
                      </div>
                      <div class="card-body-p">
                        <div class="notice-item" style="border-left:4px solid var(--accent);">
                          <div class="d-flex justify-content-between align-items-start mb-1">
                            <h6>Annual Sports Day – 10 March 2026</h6>
                            <div class="d-flex gap-1"><button class="btn-icon"><i
                                  class="bi bi-pencil-fill"></i></button><button class="btn-icon del"><i
                                  class="bi bi-trash-fill"></i></button></div>
                          </div>
                          <p>Saare students ko sports ground pe 8 AM tak report karna hai. Proper sports kit pehenna
                            zaroori
                            hai.
                          </p>
                          <div class="d-flex align-items-center gap-2 mt-2"><span class="tag tag-orange">All
                              Students</span><span
                              style="font-size:11px;color:var(--muted);font-family:'JetBrains Mono',monospace;">Published:
                              28
                              Feb
                              2026</span></div>
                        </div>
                        <div class="notice-item" style="border-left:4px solid var(--yellow);">
                          <div class="d-flex justify-content-between align-items-start mb-1">
                            <h6>Half-Yearly Exam Schedule Released</h6>
                            <div class="d-flex gap-1"><button class="btn-icon"><i
                                  class="bi bi-pencil-fill"></i></button><button class="btn-icon del"><i
                                  class="bi bi-trash-fill"></i></button></div>
                          </div>
                          <p>Half-yearly exams 15 March se start honge. Timetable attached hai.</p>
                          <div class="d-flex align-items-center gap-2 mt-2"><span class="tag tag-yellow">Class
                              9-12</span><span
                              style="font-size:11px;color:var(--muted);font-family:'JetBrains Mono',monospace;">Published:
                              25
                              Feb
                              2026</span></div>
                        </div>
                        <div class="notice-item" style="border-left:4px solid var(--red);">
                          <div class="d-flex justify-content-between align-items-start mb-1">
                            <h6>Fee Submission Last Date – 5 March 2026</h6>
                            <div class="d-flex gap-1"><button class="btn-icon"><i
                                  class="bi bi-pencil-fill"></i></button><button class="btn-icon del"><i
                                  class="bi bi-trash-fill"></i></button></div>
                          </div>
                          <p>Pending fees 5 March tak submit karni hogi, warna late fine lagega.</p>
                          <div class="d-flex align-items-center gap-2 mt-2"><span class="tag tag-red">Urgent</span><span
                              style="font-size:11px;color:var(--muted);font-family:'JetBrains Mono',monospace;">Published:
                              24
                              Feb
                              2026</span></div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="col-12 col-md-5">
                    <div class="card-box">
                      <div class="card-head"><i class="bi bi-pencil-square" style="color:var(--accent);"></i>
                        <h6>Quick Notice Create Karo</h6>
                      </div>
                      <div class="card-body-p">
                        <div class="mb-3"><label class="form-label">Title</label><input class="form-control"
                            placeholder="Notice ka title..." /></div>
                        <div class="mb-3"><label class="form-label">Message</label><textarea class="form-control"
                            rows="3" placeholder="Notice content yahan likhो..."></textarea></div>
                        <div class="mb-3"><label class="form-label">Target Audience</label><select class="form-select">
                            <option>All Students</option>
                            <option>Class 9</option>
                            <option>Class 10</option>
                            <option>Class 11</option>
                            <option>Class 12</option>
                            <option>Teachers Only</option>
                          </select></div>
                        <div class="mb-3"><label class="form-label">Priority</label><select class="form-select">
                            <option>Normal</option>
                            <option>Important</option>
                            <option>Urgent</option>
                          </select></div>
                        <button class="btn-accent" style="width:100%;justify-content:center;"><i
                            class="bi bi-megaphone-fill"></i>
                          Publish Karo</button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- ═══ REPORTS ═══ -->
              <div class="page" id="page-reports">
                <div class="pg-header">
                  <div class="pg-header-left">
                    <h4>Reports & Analytics</h4>
                    <p>School performance aur data reports yahan dekho</p>
                  </div>
                  <button class="btn-outline"><i class="bi bi-download"></i> All Reports Export</button>
                </div>
                <div class="row g-3">
                  <div class="col-md-4">
                    <div class="card-box p-4" style="cursor:pointer;transition:all .2s;"
                      onmouseover="this.style.borderColor='var(--accent)'"
                      onmouseout="this.style.borderColor='var(--border)'">
                      <div class="stat-ico" style="background:#ffedd5;color:#ea580c;margin-bottom:14px;"><i
                          class="bi bi-people-fill"></i></div>
                      <div style="font-weight:700;font-size:15px;margin-bottom:4px;">Student Enrollment Report</div>
                      <div style="font-size:13px;color:var(--muted);margin-bottom:14px;">Class-wise enrollment aur
                        growth
                        data
                      </div>
                      <button class="btn-accent" style="padding:7px 16px;font-size:12px;"><i class="bi bi-download"></i>
                        Download
                        PDF</button>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="card-box p-4" style="cursor:pointer;transition:all .2s;"
                      onmouseover="this.style.borderColor='var(--accent)'"
                      onmouseout="this.style.borderColor='var(--border)'">
                      <div class="stat-ico" style="background:#d1fae5;color:#059669;margin-bottom:14px;"><i
                          class="bi bi-calendar-check-fill"></i></div>
                      <div style="font-weight:700;font-size:15px;margin-bottom:4px;">Attendance Report</div>
                      <div style="font-size:13px;color:var(--muted);margin-bottom:14px;">Monthly aur annual attendance
                        analysis
                      </div>
                      <button class="btn-accent" style="padding:7px 16px;font-size:12px;"><i class="bi bi-download"></i>
                        Download
                        PDF</button>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="card-box p-4" style="cursor:pointer;transition:all .2s;"
                      onmouseover="this.style.borderColor='var(--accent)'"
                      onmouseout="this.style.borderColor='var(--border)'">
                      <div class="stat-ico" style="background:#fef3c7;color:#d97706;margin-bottom:14px;"><i
                          class="bi bi-cash-coin"></i></div>
                      <div style="font-weight:700;font-size:15px;margin-bottom:4px;">Fee Collection Report</div>
                      <div style="font-size:13px;color:var(--muted);margin-bottom:14px;">Monthly fee collection aur
                        pending
                        analysis</div>
                      <button class="btn-accent" style="padding:7px 16px;font-size:12px;"><i class="bi bi-download"></i>
                        Download
                        PDF</button>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="card-box p-4" style="cursor:pointer;transition:all .2s;"
                      onmouseover="this.style.borderColor='var(--accent)'"
                      onmouseout="this.style.borderColor='var(--border)'">
                      <div class="stat-ico" style="background:#ede9fe;color:#7c3aed;margin-bottom:14px;"><i
                          class="bi bi-bar-chart-fill"></i></div>
                      <div style="font-weight:700;font-size:15px;margin-bottom:4px;">Academic Performance</div>
                      <div style="font-size:13px;color:var(--muted);margin-bottom:14px;">Exam results aur class average
                        summary
                      </div>
                      <button class="btn-accent" style="padding:7px 16px;font-size:12px;"><i class="bi bi-download"></i>
                        Download
                        PDF</button>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="card-box p-4" style="cursor:pointer;transition:all .2s;"
                      onmouseover="this.style.borderColor='var(--accent)'"
                      onmouseout="this.style.borderColor='var(--border)'">
                      <div class="stat-ico" style="background:#dbeafe;color:#2563eb;margin-bottom:14px;"><i
                          class="bi bi-person-video3"></i></div>
                      <div style="font-weight:700;font-size:15px;margin-bottom:4px;">Teacher Performance</div>
                      <div style="font-size:13px;color:var(--muted);margin-bottom:14px;">Staff attendance aur class
                        performance
                        data</div>
                      <button class="btn-accent" style="padding:7px 16px;font-size:12px;"><i class="bi bi-download"></i>
                        Download
                        PDF</button>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="card-box p-4" style="cursor:pointer;transition:all .2s;"
                      onmouseover="this.style.borderColor='var(--accent)'"
                      onmouseout="this.style.borderColor='var(--border)'">
                      <div class="stat-ico" style="background:#fee2e2;color:#dc2626;margin-bottom:14px;"><i
                          class="bi bi-exclamation-triangle-fill"></i></div>
                      <div style="font-weight:700;font-size:15px;margin-bottom:4px;">Defaulters Report</div>
                      <div style="font-size:13px;color:var(--muted);margin-bottom:14px;">Low attendance aur pending fee
                        wale
                        students</div>
                      <button class="btn-accent" style="padding:7px 16px;font-size:12px;"><i class="bi bi-download"></i>
                        Download
                        PDF</button>
                    </div>
                  </div>
                </div>
              </div>

              <!-- ═══ SETTINGS ═══ -->
              <div class="page" id="page-settings">
                <div class="pg-header">
                  <div class="pg-header-left">
                    <h4>System Settings</h4>
                    <p>School aur system ki configurations</p>
                  </div>
                </div>
                <div class="row g-3">
                  <div class="col-12 col-md-7">
                    <div class="card-box mb-3">
                      <div class="card-head"><i class="bi bi-building" style="color:var(--accent);"></i>
                        <h6>School Information</h6>
                      </div>
                      <div class="card-body-p">
                        <div class="row g-3">
                          <div class="col-12"><label class="form-label">School Name</label><input class="form-control"
                              value="Delhi Public School" /></div>
                          <div class="col-6"><label class="form-label">Academic Year</label><input class="form-control"
                              value="2025-2026" /></div>
                          <div class="col-6"><label class="form-label">School Code</label><input class="form-control"
                              value="DPS-001" disabled /></div>
                          <div class="col-6"><label class="form-label">Board</label><select class="form-select">
                              <option selected>CBSE</option>
                              <option>ICSE</option>
                              <option>State Board</option>
                            </select></div>
                          <div class="col-6"><label class="form-label">Medium</label><select class="form-select">
                              <option selected>English</option>
                              <option>Hindi</option>
                              <option>Both</option>
                            </select></div>
                          <div class="col-12"><label class="form-label">School Address</label><input
                              class="form-control" value="Sector 12, Dwarka, New Delhi - 110078" /></div>
                          <div class="col-12"><label class="form-label">Contact Email</label><input class="form-control"
                              value="info@dps.edu.in" /></div>
                          <div class="col-12"><button class="btn-accent"><i class="bi bi-check-lg"></i> Settings Save
                              Karo</button></div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="col-12 col-md-5">
                    <div class="card-box mb-3">
                      <div class="card-head"><i class="bi bi-lock-fill" style="color:var(--red);"></i>
                        <h6>Security Settings</h6>
                      </div>
                      <div class="card-body-p">
                        <div class="row g-3">
                          <div class="col-12"><label class="form-label">Current Password</label><input
                              class="form-control" type="password" placeholder="••••••••" /></div>
                          <div class="col-12"><label class="form-label">New Password</label><input class="form-control"
                              type="password" placeholder="••••••••" /></div>
                          <div class="col-12"><label class="form-label">Confirm Password</label><input
                              class="form-control" type="password" placeholder="••••••••" /></div>
                          <div class="col-12"><button class="btn-accent"
                              style="background:var(--red);box-shadow:none;"><i class="bi bi-key-fill"></i> Password
                              Change Karo</button></div>
                        </div>
                      </div>
                    </div>

                    <div class="card-box">
                      <div class="card-head"><i class="bi bi-bell-fill" style="color:var(--yellow);"></i>
                        <h6>Notification Settings</h6>
                      </div>
                      <div class="card-body-p">
                        <div class="d-flex align-items-center justify-content-between mb-3">
                          <div>
                            <div style="font-size:13px;font-weight:600;">Email Notifications</div>
                            <div style="font-size:12px;color:var(--muted);">Fee reminders, alerts</div>
                          </div>
                          <div class="form-check form-switch mb-0"><input class="form-check-input" type="checkbox"
                              checked style="width:40px;height:20px;cursor:pointer;" /></div>
                        </div>
                        <div class="d-flex align-items-center justify-content-between">
                          <div>
                            <div style="font-size:13px;font-weight:600;">Low Attendance Alerts</div>
                            <div style="font-size:12px;color:var(--muted);">Below 75% warning</div>
                          </div>
                          <div class="form-check form-switch mb-0"><input class="form-check-input" type="checkbox"
                              checked style="width:40px;height:20px;cursor:pointer;" /></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- ═══ LEAVE MANAGEMENT ═══ -->
              <div class="page" id="page-leavemgmt">
                <div class="pg-header">
                  <div class="pg-header-left">
                    <h4>Leave Management</h4>
                    <p>Teachers ko leave assign karo aur applications manage karo</p>
                  </div>
                  <button class="btn-accent" onclick="openAssignLeaveModal()"><i class="bi bi-plus-lg"></i> Leave Assign
                    Karo</button>
                </div>

                <div class="row g-3 mb-4">
                  <div class="col-6 col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#fef3c7;color:#d97706;"><i
                          class="bi bi-hourglass-split"></i>
                      </div>
                      <h3>1</h3>
                      <p>Pending Requests</p><span class="tag tag-yellow">Awaiting</span>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#d1fae5;color:#059669;"><i
                          class="bi bi-check-circle-fill"></i>
                      </div>
                      <h3>8</h3>
                      <p>Approved (March)</p><span class="tag tag-green">This Month</span>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#dbeafe;color:#2563eb;"><i class="bi bi-people-fill"></i>
                      </div>
                      <h3>3</h3>
                      <p>On Leave Today</p><span class="tag tag-blue">Out of Office</span>
                    </div>
                  </div>
                  <div class="col-6 col-md-3">
                    <div class="stat">
                      <div class="stat-ico" style="background:#fee2e2;color:#dc2626;"><i
                          class="bi bi-x-circle-fill"></i>
                      </div>
                      <h3>2</h3>
                      <p>Rejected</p><span class="tag tag-red">This Month</span>
                    </div>
                  </div>
                </div>

                <div class="row g-3">

                  <!-- Pending Requests -->
                  <div class="col-12">
                    <div class="card-box">
                      <div class="card-head"><i class="bi bi-hourglass-split" style="color:var(--yellow);"></i>
                        <h6>Pending Leave Requests</h6><span class="ms-auto tag tag-yellow">1 Pending</span>
                      </div>
                      <div class="table-responsive">
                        <table class="table tbl mb-0">
                          <thead>
                            <tr>
                              <th>Teacher</th>
                              <th>Leave Type</th>
                              <th>From</th>
                              <th>To</th>
                              <th>Days</th>
                              <th>Reason</th>
                              <th>Applied On</th>
                              <th>Action</th>
                            </tr>
                          </thead>
                          <tbody id="pending-tbody">
                            <tr id="pending-row-1">
                              <td>
                                <div class="d-flex align-items-center gap-2">
                                  <div class="av-sm" style="background:#d1fae5;color:#059669;">PJ</div>
                                  <div>
                                    <div style="font-weight:600;">Priya Joshi</div>
                                    <div style="font-size:11px;color:var(--muted);">Science</div>
                                  </div>
                                </div>
                              </td>
                              <td><span class="tag tag-yellow">Casual Leave</span></td>
                              <td style="font-family:'JetBrains Mono',monospace;font-size:12px;">5 Mar 2026</td>
                              <td style="font-family:'JetBrains Mono',monospace;font-size:12px;">5 Mar 2026</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;">1</td>
                              <td style="max-width:160px;font-size:12px;">Personal work ke liye</td>
                              <td style="font-size:12px;color:var(--muted);">1 Mar 2026</td>
                              <td>
                                <div class="d-flex gap-1">
                                  <button class="btn-accent" style="padding:5px 12px;font-size:12px;"
                                    onclick="approveLeave('pending-row-1')"><i class="bi bi-check-lg"></i>
                                    Approve</button>
                                  <button class="btn-icon" style="border-color:var(--red);color:var(--red);"
                                    onclick="rejectLeave('pending-row-1')"><i class="bi bi-x-lg"></i></button>
                                </div>
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </div>
                      <div id="no-pending"
                        style="display:none;padding:24px;text-align:center;color:var(--muted);font-size:13px;">
                        <i class="bi bi-check-circle-fill"
                          style="font-size:28px;color:var(--green);display:block;margin-bottom:8px;"></i>Koi pending
                        request
                        nahi
                        hai!
                      </div>
                    </div>
                  </div>

                  <!-- Teacher Leave Balance -->
                  <div class="col-12 col-lg-7">
                    <div class="card-box">
                      <div class="card-head"><i class="bi bi-calendar2-x-fill" style="color:var(--accent);"></i>
                        <h6>Teacher-wise Leave Balance</h6><button class="btn-outline ms-auto"
                          style="font-size:12px;padding:6px 12px;" onclick="openAssignLeaveModal()"><i
                            class="bi bi-plus-lg"></i>
                          Assign Leave</button>
                      </div>
                      <div class="table-responsive">
                        <table class="table tbl mb-0">
                          <thead>
                            <tr>
                              <th>Teacher</th>
                              <th>Subject</th>
                              <th>Casual</th>
                              <th>Medical</th>
                              <th>Earned</th>
                              <th>Used</th>
                              <th>Edit</th>
                            </tr>
                          </thead>
                          <tbody>
                            <tr>
                              <td>
                                <div class="d-flex align-items-center gap-2">
                                  <div class="av-sm" style="background:#ffedd5;color:#ea580c;">RG</div><b>Ramesh
                                    Gupta</b>
                                </div>
                              </td>
                              <td style="font-size:12px;color:var(--muted);">Mathematics</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#d97706;">8</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#2563eb;">6</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#7c3aed;">2</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--red);">3
                              </td>
                              <td><button class="btn-icon" onclick="openEditLeaveModal('Ramesh Gupta','8','6','2')"><i
                                    class="bi bi-pencil-fill"></i></button></td>
                            </tr>
                            <tr>
                              <td>
                                <div class="d-flex align-items-center gap-2">
                                  <div class="av-sm" style="background:#d1fae5;color:#059669;">PJ</div><b>Priya
                                    Joshi</b>
                                </div>
                              </td>
                              <td style="font-size:12px;color:var(--muted);">Science</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#d97706;">10</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#2563eb;">6</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#7c3aed;">2</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--red);">5
                              </td>
                              <td><button class="btn-icon" onclick="openEditLeaveModal('Priya Joshi','10','6','2')"><i
                                    class="bi bi-pencil-fill"></i></button></td>
                            </tr>
                            <tr>
                              <td>
                                <div class="d-flex align-items-center gap-2">
                                  <div class="av-sm" style="background:#dbeafe;color:#2563eb;">DA</div><b>David
                                    Abraham</b>
                                </div>
                              </td>
                              <td style="font-size:12px;color:var(--muted);">English</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#d97706;">8</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#2563eb;">4</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#7c3aed;">1</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--red);">7
                              </td>
                              <td><button class="btn-icon" onclick="openEditLeaveModal('David Abraham','8','4','1')"><i
                                    class="bi bi-pencil-fill"></i></button></td>
                            </tr>
                            <tr>
                              <td>
                                <div class="d-flex align-items-center gap-2">
                                  <div class="av-sm" style="background:#ede9fe;color:#7c3aed;">AR</div><b>Anita Rao</b>
                                </div>
                              </td>
                              <td style="font-size:12px;color:var(--muted);">Social Science</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#d97706;">9</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#2563eb;">6</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#7c3aed;">2</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--red);">1
                              </td>
                              <td><button class="btn-icon" onclick="openEditLeaveModal('Anita Rao','9','6','2')"><i
                                    class="bi bi-pencil-fill"></i></button></td>
                            </tr>
                            <tr>
                              <td>
                                <div class="d-flex align-items-center gap-2">
                                  <div class="av-sm" style="background:#fef3c7;color:#d97706;">VN</div><b>Vikram
                                    Nair</b>
                                </div>
                              </td>
                              <td style="font-size:12px;color:var(--muted);">Computer Sc.</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#d97706;">10</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#2563eb;">6</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#7c3aed;">2</td>
                              <td style="font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--red);">0
                              </td>
                              <td><button class="btn-icon" onclick="openEditLeaveModal('Vikram Nair','10','6','2')"><i
                                    class="bi bi-pencil-fill"></i></button></td>
                            </tr>
                          </tbody>
                        </table>
                      </div>
                    </div>
                  </div>

                  <!-- Leave History -->
                  <div class="col-12 col-lg-5">
                    <div class="card-box">
                      <div class="card-head"><i class="bi bi-clock-history" style="color:var(--muted);"></i>
                        <h6>Recent Leave History</h6>
                      </div>
                      <div class="card-body-p" id="leave-history-list">
                        <div
                          style="display:flex;align-items:center;gap:12px;padding:11px 0;border-bottom:1px solid var(--border);">
                          <div
                            style="width:40px;height:40px;border-radius:11px;background:#fef3c7;color:#d97706;display:flex;align-items:center;justify-content:center;font-size:17px;flex-shrink:0;">
                            <i class="bi bi-clock-fill"></i>
                          </div>
                          <div style="flex:1;">
                            <div style="font-size:13px;font-weight:600;">Priya Joshi — Casual</div>
                            <div style="font-size:12px;color:var(--muted);">5 Mar 2026 • 1 day</div>
                          </div><span class="tag tag-yellow">Pending</span>
                        </div>
                        <div
                          style="display:flex;align-items:center;gap:12px;padding:11px 0;border-bottom:1px solid var(--border);">
                          <div
                            style="width:40px;height:40px;border-radius:11px;background:#d1fae5;color:#059669;display:flex;align-items:center;justify-content:center;font-size:17px;flex-shrink:0;">
                            <i class="bi bi-check-circle-fill"></i>
                          </div>
                          <div style="flex:1;">
                            <div style="font-size:13px;font-weight:600;">David Abraham — Medical</div>
                            <div style="font-size:12px;color:var(--muted);">24–25 Feb 2026 • 2 days</div>
                          </div><span class="tag tag-green">Approved</span>
                        </div>
                        <div
                          style="display:flex;align-items:center;gap:12px;padding:11px 0;border-bottom:1px solid var(--border);">
                          <div
                            style="width:40px;height:40px;border-radius:11px;background:#d1fae5;color:#059669;display:flex;align-items:center;justify-content:center;font-size:17px;flex-shrink:0;">
                            <i class="bi bi-check-circle-fill"></i>
                          </div>
                          <div style="flex:1;">
                            <div style="font-size:13px;font-weight:600;">Ramesh Gupta — Casual</div>
                            <div style="font-size:12px;color:var(--muted);">20 Feb 2026 • 1 day</div>
                          </div><span class="tag tag-green">Approved</span>
                        </div>
                        <div
                          style="display:flex;align-items:center;gap:12px;padding:11px 0;border-bottom:1px solid var(--border);">
                          <div
                            style="width:40px;height:40px;border-radius:11px;background:#fee2e2;color:#dc2626;display:flex;align-items:center;justify-content:center;font-size:17px;flex-shrink:0;">
                            <i class="bi bi-x-circle-fill"></i>
                          </div>
                          <div style="flex:1;">
                            <div style="font-size:13px;font-weight:600;">Priya Joshi — Earned</div>
                            <div style="font-size:12px;color:var(--muted);">15–17 Oct 2025 • 3 days</div>
                          </div><span class="tag tag-red">Rejected</span>
                        </div>
                        <div style="display:flex;align-items:center;gap:12px;padding:11px 0;">
                          <div
                            style="width:40px;height:40px;border-radius:11px;background:#d1fae5;color:#059669;display:flex;align-items:center;justify-content:center;font-size:17px;flex-shrink:0;">
                            <i class="bi bi-check-circle-fill"></i>
                          </div>
                          <div style="flex:1;">
                            <div style="font-size:13px;font-weight:600;">Anita Rao — Casual</div>
                            <div style="font-size:12px;color:var(--muted);">10 Jan 2026 • 1 day</div>
                          </div><span class="tag tag-green">Approved</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- On Leave Today -->
                  <div class="col-12">
                    <div class="card-box">
                      <div class="card-head"><i class="bi bi-person-x-fill" style="color:var(--red);"></i>
                        <h6>Aaj Leave Pe Hain (3 Teachers)</h6><span class="ms-auto"
                          style="font-size:12px;color:var(--muted);">Monday, 2 March 2026</span>
                      </div>
                      <div class="card-body-p">
                        <div class="row g-3">
                          <div class="col-12 col-md-4">
                            <div
                              style="background:#fff5f5;border:1.5px solid #fecaca;border-radius:14px;padding:16px;display:flex;align-items:center;gap:12px;">
                              <div class="av-sm"
                                style="background:#fee2e2;color:#dc2626;width:44px;height:44px;border-radius:12px;font-size:14px;font-weight:700;">
                                DA</div>
                              <div>
                                <div style="font-weight:700;font-size:14px;">David Abraham</div>
                                <div style="font-size:12px;color:var(--muted);">English • Medical Leave</div>
                                <div style="font-size:11px;color:#dc2626;font-weight:600;margin-top:2px;">24–25 Feb 2026
                                </div>
                              </div>
                            </div>
                          </div>
                          <div class="col-12 col-md-4">
                            <div
                              style="background:#fff5f5;border:1.5px solid #fecaca;border-radius:14px;padding:16px;display:flex;align-items:center;gap:12px;">
                              <div class="av-sm"
                                style="background:#fee2e2;color:#dc2626;width:44px;height:44px;border-radius:12px;font-size:14px;font-weight:700;">
                                SK</div>
                              <div>
                                <div style="font-weight:700;font-size:14px;">Sunita Kapoor</div>
                                <div style="font-size:12px;color:var(--muted);">Hindi • Casual Leave</div>
                                <div style="font-size:11px;color:#dc2626;font-weight:600;margin-top:2px;">2 Mar 2026
                                </div>
                              </div>
                            </div>
                          </div>
                          <div class="col-12 col-md-4">
                            <div
                              style="background:#fff5f5;border:1.5px solid #fecaca;border-radius:14px;padding:16px;display:flex;align-items:center;gap:12px;">
                              <div class="av-sm"
                                style="background:#fee2e2;color:#dc2626;width:44px;height:44px;border-radius:12px;font-size:14px;font-weight:700;">
                                MK</div>
                              <div>
                                <div style="font-weight:700;font-size:14px;">Manish Kumar</div>
                                <div style="font-size:12px;color:var(--muted);">Physics • Earned Leave</div>
                                <div style="font-size:11px;color:#dc2626;font-weight:600;margin-top:2px;">1–3 Mar 2026
                                </div>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- ASSIGN LEAVE MODAL -->
            <div class="modal-backdrop-custom" id="assignLeaveModal" onclick="closeAssignLeaveOutside(event)">
              <div class="edit-modal" style="max-width:520px;">
                <div class="edit-modal-head">
                  <h5><i class="bi bi-calendar2-x-fill me-2" style="color:var(--accent);"></i>Teacher ko Leave Assign
                    Karo
                  </h5>
                  <button class="modal-close" onclick="closeAssignLeaveModal()">✕</button>
                </div>
                <div class="edit-modal-body">
                  <div class="row g-3">
                    <div class="col-12">
                      <label class="form-label">Teacher Select Karo</label>
                      <select class="form-select" id="al-teacher">
                        <option value="">-- Teacher chuniye --</option>
                        <option>Ramesh Gupta — Mathematics</option>
                        <option>Priya Joshi — Science</option>
                        <option>David Abraham — English</option>
                        <option>Anita Rao — Social Science</option>
                        <option>Vikram Nair — Computer Science</option>
                        <option>Sunita Kapoor — Hindi</option>
                        <option>Manish Kumar — Physics</option>
                      </select>
                    </div>
                    <div class="col-12">
                      <label class="form-label">Leave Type</label>
                      <div class="row g-2">
                        <div class="col-6 col-md-3">
                          <div class="ltype-assign-btn active-ltype" onclick="selectLT(this)"
                            style="border:1.5px solid var(--accent);background:rgba(249,115,22,.08);border-radius:11px;padding:12px;text-align:center;cursor:pointer;transition:all .18s;">
                            <i class="bi bi-sun-fill"
                              style="font-size:20px;color:#d97706;display:block;margin-bottom:4px;"></i><span
                              style="font-size:12px;font-weight:600;">Casual</span>
                          </div>
                        </div>
                        <div class="col-6 col-md-3">
                          <div class="ltype-assign-btn" onclick="selectLT(this)"
                            style="border:1.5px solid var(--border);border-radius:11px;padding:12px;text-align:center;cursor:pointer;transition:all .18s;">
                            <i class="bi bi-hospital-fill"
                              style="font-size:20px;color:#2563eb;display:block;margin-bottom:4px;"></i><span
                              style="font-size:12px;font-weight:600;">Medical</span>
                          </div>
                        </div>
                        <div class="col-6 col-md-3">
                          <div class="ltype-assign-btn" onclick="selectLT(this)"
                            style="border:1.5px solid var(--border);border-radius:11px;padding:12px;text-align:center;cursor:pointer;transition:all .18s;">
                            <i class="bi bi-award-fill"
                              style="font-size:20px;color:#7c3aed;display:block;margin-bottom:4px;"></i><span
                              style="font-size:12px;font-weight:600;">Earned</span>
                          </div>
                        </div>
                        <div class="col-6 col-md-3">
                          <div class="ltype-assign-btn" onclick="selectLT(this)"
                            style="border:1.5px solid var(--border);border-radius:11px;padding:12px;text-align:center;cursor:pointer;transition:all .18s;">
                            <i class="bi bi-house-heart-fill"
                              style="font-size:20px;color:#ec4899;display:block;margin-bottom:4px;"></i><span
                              style="font-size:12px;font-weight:600;">Special</span>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="col-6"><label class="form-label">Start Date</label><input class="form-control"
                        type="date" id="al-from" /></div>
                    <div class="col-6"><label class="form-label">End Date</label><input class="form-control" type="date"
                        id="al-to" /></div>
                    <div class="col-12"><label class="form-label">Reason</label><textarea class="form-control"
                        id="al-reason" rows="3"
                        placeholder="Reason likhein (Medical emergency, Official duty, etc.)"></textarea></div>
                    <div class="col-12">
                      <label class="form-label">Status</label>
                      <select class="form-select" id="al-status">
                        <option value="approved">Direct Approve</option>
                        <option value="pending">Pending Rakhein</option>
                      </select>
                    </div>
                    <div class="col-12 d-flex gap-2 pt-1">
                      <button class="save-btn" onclick="assignLeave()"><i class="bi bi-check-lg me-1"></i>Leave Assign
                        Karo</button>
                      <button onclick="closeAssignLeaveModal()"
                        style="background:var(--bg);border:1.5px solid var(--border);border-radius:11px;padding:12px 20px;font-size:14px;font-weight:600;cursor:pointer;font-family:inherit;">Cancel</button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- EDIT LEAVE BALANCE MODAL -->
            <div class="modal-backdrop-custom" id="editLeaveModal" onclick="closeEditLeaveOutside(event)">
              <div class="edit-modal" style="max-width:420px;">
                <div class="edit-modal-head">
                  <h5><i class="bi bi-pencil-fill me-2" style="color:var(--accent);"></i>Leave Balance Edit Karo</h5>
                  <button class="modal-close" onclick="closeEditLeaveModal()">✕</button>
                </div>
                <div class="edit-modal-body">
                  <div
                    style="background:var(--bg);border-radius:12px;padding:13px;margin-bottom:18px;font-size:13px;font-weight:600;">
                    Teacher: <span id="el-teacher-name" style="color:var(--accent);">—</span></div>
                  <div class="row g-3">
                    <div class="col-4"><label class="form-label">Casual Leave</label><input class="form-control"
                        type="number" id="el-casual" min="0" max="30" /></div>
                    <div class="col-4"><label class="form-label">Medical Leave</label><input class="form-control"
                        type="number" id="el-medical" min="0" max="30" /></div>
                    <div class="col-4"><label class="form-label">Earned Leave</label><input class="form-control"
                        type="number" id="el-earned" min="0" max="30" /></div>
                    <div class="col-12 d-flex gap-2 pt-1">
                      <button class="save-btn" onclick="saveLeaveBalance()"><i class="bi bi-check-lg me-1"></i>Save
                        Karo</button>
                      <button onclick="closeEditLeaveModal()"
                        style="background:var(--bg);border:1.5px solid var(--border);border-radius:11px;padding:12px 20px;font-size:14px;font-weight:600;cursor:pointer;font-family:inherit;">Cancel</button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- ═══ ADD STUDENT MODAL ═══ -->
            <div class="modal-backdrop-custom" id="addStudentModal" onclick="closeAddStudentOutside(event)">
              <div class="edit-modal" style="max-width:500px;">
                <div class="edit-modal-head" style="border-radius:18px 18px 0 0;">
                  <h5><i class="bi bi-person-plus-fill me-2" style="color:var(--accent);"></i>Add New Student</h5>
                  <button class="modal-close" onclick="closeAddStudentModal()">✕</button>
                </div>
                <div class="edit-modal-body" style="padding:24px;">
                  <form action="AddStudentServlet" method="post">
                    <div class="row g-3">
                      <div class="col-12"><label class="form-label">Student Full Name</label><input name="name"
                          class="form-control" placeholder="Enter Full Name" required /></div>
                      <div class="col-6"><label class="form-label">Email ID</label><input name="email" type="email"
                          class="form-control" placeholder="school_id@example.com" required /></div>
                      <div class="col-6"><label class="form-label">Login Password</label><input name="password"
                          type="password" class="form-control" placeholder="Create Password" required /></div>
                      <div class="col-4"><label class="form-label">Class</label><input name="class" class="form-control"
                          placeholder="e.g. 10" required /></div>
                      <div class="col-4"><label class="form-label">Section</label><input name="section"
                          class="form-control" placeholder="e.g. A" required /></div>
                      <div class="col-4"><label class="form-label">Roll No</label><input name="roll_no"
                          class="form-control" placeholder="e.g. 101" required /></div>
                      <div class="col-12 d-flex gap-2 pt-2">
                        <button type="submit" class="save-btn" style="width:100%"><i
                            class="bi bi-person-plus-fill me-1"></i>Add Student to Database</button>
                      </div>
                    </div>
                  </form>
                </div>
              </div>
            </div>

            <!-- ═══ PROFILE EDIT MODAL ═══ -->
            <div class="modal-backdrop-custom" id="editModal" onclick="closeEditModalOutside(event)">
              <div class="edit-modal">
                <div class="edit-modal-head">
                  <h5><i class="bi bi-pencil-fill me-2" style="color:var(--accent);"></i>Profile Edit Karo</h5>
                  <button class="modal-close" onclick="closeEditModal()">✕</button>
                </div>
                <form action="UpdateProfileServlet" method="post" enctype="multipart/form-data">
                  <div class="avatar-upload-area">
                    <div class="upload-preview">
                      <img src='<%= adPhotoBase64 != null ? "data:image/jpeg;base64," + adPhotoBase64
                        : "images/user_default_photo.webp" %>'
                      style="width:100%;height:100%;object-fit:cover;border-radius:12px;" id="modal-photo-preview"/>
                    </div>
                    <div>
                      <div style="font-weight:700;font-size:14px;margin-bottom:4px;">Profile Photo</div>
                      <div style="font-size:12px;color:var(--muted);margin-bottom:10px;">JPG, PNG. Max 2MB</div>
                      <button type="button" class="upload-btn"
                        onclick="document.getElementById('avatar-input-modal').click()">
                        <i class="bi bi-cloud-upload-fill"></i> Photo Upload Karo
                      </button>
                      <input type="file" name="photo" id="avatar-input-modal" accept="image/*" style="display:none"
                        onchange="previewImage(this)" />
                    </div>
                  </div>
                  <div class="row g-3">
                    <div class="col-6"><label class="form-label">Full Name</label><input name="name"
                        class="form-control" value="<%= adName %>" /></div>
                    <div class="col-6"><label class="form-label">Date of Birth</label><input name="dob"
                        class="form-control" type="date" value="<%= adDob %>" /></div>
                    <div class="col-6"><label class="form-label">Gender</label><select name="gender"
                        class="form-select">
                        <option <%="Male" .equals(adGender) ? "selected" : "" %>>Male</option>
                        <option <%="Female" .equals(adGender) ? "selected" : "" %>>Female</option>
                        <option <%="Other" .equals(adGender) ? "selected" : "" %>>Other</option>
                      </select></div>
                    <div class="col-6"><label class="form-label">Blood Group</label><select name="blood_group"
                        class="form-select">
                        <option <%="A+" .equals(adBlood) ? "selected" : "" %>>A+</option>
                        <option <%="A-" .equals(adBlood) ? "selected" : "" %>>A-</option>
                        <option <%="B+" .equals(adBlood) ? "selected" : "" %>>B+</option>
                        <option <%="B-" .equals(adBlood) ? "selected" : "" %>>B-</option>
                        <option <%="O+" .equals(adBlood) ? "selected" : "" %>>O+</option>
                        <option <%="O-" .equals(adBlood) ? "selected" : "" %>>O-</option>
                        <option <%="AB+" .equals(adBlood) ? "selected" : "" %>>AB+</option>
                        <option <%="AB-" .equals(adBlood) ? "selected" : "" %>>AB-</option>
                      </select></div>
                    <div class="col-6"><label class="form-label">Phone Number</label><input name="phone"
                        class="form-control" value="<%= adPhone %>" /></div>
                    <div class="col-6"><label class="form-label">Email</label><input name="email" class="form-control"
                        value="<%= adEmail %>" /></div>
                    <div class="col-6"><label class="form-label">Subject</label><input name="subject"
                        class="form-control" value="<%= adSubject %>" /></div>
                    <div class="col-6"><label class="form-label">Qualification</label><input name="qualification"
                        class="form-control" value="<%= adQual %>" /></div>
                    <div class="col-6"><label class="form-label">Experience</label><input name="experience"
                        class="form-control" value="<%= adExp %>" /></div>
                    <div class="col-6"><label class="form-label">Designation/Dept</label><input name="department"
                        class="form-control" value="<%= adDept %>" /></div>
                    <div class="col-12"><label class="form-label">Address</label><input name="address"
                        class="form-control" value="<%= adAddress %>" /></div>
                    <div class="col-6"><label class="form-label">Employee ID</label><input name="employee_id"
                        class="form-control" value="<%= adEmpId %>" /></div>
                    <div class="col-6"><label class="form-label">Joined On</label><input name="joined_on" type="date"
                        class="form-control" value="<%= adJoined %>" /></div>
                    <div class="col-12 d-flex gap-2 pt-2">
                      <button type="submit" class="save-btn"><i class="bi bi-check-lg me-1"></i>Save
                        Changes</button>
                      <button type="button" onclick="closeEditModal()"
                        style="background:var(--bg);border:1.5px solid var(--border);border-radius:11px;padding:12px 20px;font-size:14px;font-weight:600;cursor:pointer;font-family:inherit;">Cancel</button>
                    </div>
                  </div>
                </form>
              </div>
            </div>
            </div>

            <script data-cfasync="false" src="/cdn-cgi/scripts/5c5dd728/cloudflare-static/email-decode.min.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
            <script>
              const pageTitles = {
                dashboard: 'Dashboard', profile: 'My Profile', students: 'Students Management',
                teachers: 'Teachers Management', leavemgmt: 'Leave Management',
                attendance: 'Attendance', results: 'Results & Grades',
                courses: 'Courses', fees: 'Fee Management', notices: 'Notice Board',
                reports: 'Reports', settings: 'Settings'
              };

              function showPage(name, el) {
                // Ensure it hides ALL .page divs first
                document.querySelectorAll('.page').forEach(p => {
                  p.style.display = 'none';
                  p.classList.remove('active');
                });

                // Then only shows the target page (add class 'active')
                const targetPage = document.getElementById('page-' + name);
                if (targetPage) {
                  targetPage.style.display = 'block';
                  targetPage.classList.add('active');
                }

                // Update sidebar active state
                document.querySelectorAll('.s-nav-link').forEach(l => l.classList.remove('active'));
                if (el) el.classList.add('active');

                // Update the topbar title correctly per page
                document.getElementById('page-title').textContent = pageTitles[name] || name;

                // Close sidebar after selection (on mobile)
                const sidebar = document.getElementById('sidebar');
                if (sidebar) sidebar.classList.remove('open');
              }

              function toggleSidebar() {
                document.getElementById('sidebar').classList.toggle('open');
              }

              function openEditModal() {
                document.getElementById('editModal').classList.add('show');
                document.body.style.overflow = 'hidden';
              }

              function closeEditModal() {
                document.getElementById('editModal').classList.remove('show');
                document.body.style.overflow = '';
              }

              function previewImage(input) {
                if (input.files && input.files[0]) {
                  const reader = new FileReader();
                  reader.onload = function (e) {
                    document.getElementById('modal-photo-preview').src = e.target.result;
                  }
                  reader.readAsDataURL(input.files[0]);
                }
              }

              // ─── LEAVE MANAGEMENT FUNCTIONS ───
              function openAssignLeaveModal() {
                document.getElementById('assignLeaveModal').classList.add('show');
                document.body.style.overflow = 'hidden';
              }
              function closeAssignLeaveModal() {
                document.getElementById('assignLeaveModal').classList.remove('show');
                document.body.style.overflow = '';
              }
              function closeAssignLeaveOutside(e) {
                if (e.target === document.getElementById('assignLeaveModal')) closeAssignLeaveModal();
              }

              function openEditLeaveModal(name, casual, medical, earned) {
                document.getElementById('el-teacher-name').textContent = name;
                document.getElementById('el-casual').value = casual;
                document.getElementById('el-medical').value = medical;
                document.getElementById('el-earned').value = earned;
                document.getElementById('editLeaveModal').classList.add('show');
                document.body.style.overflow = 'hidden';
              }
              function closeEditLeaveModal() {
                document.getElementById('editLeaveModal').classList.remove('show');
                document.body.style.overflow = '';
              }
              function closeEditLeaveOutside(e) {
                if (e.target === document.getElementById('editLeaveModal')) closeEditLeaveModal();
              }

              function selectLT(el) {
                el.closest('.row').querySelectorAll('.ltype-assign-btn').forEach(b => {
                  b.style.border = '1.5px solid var(--border)';
                  b.style.background = '';
                });
                el.style.border = '1.5px solid var(--accent)';
                el.style.background = 'rgba(249,115,22,.08)';
              }

              function assignLeave() {
                const teacher = document.getElementById('al-teacher').value;
                const from = document.getElementById('al-from').value;
                const to = document.getElementById('al-to').value;
                const reason = document.getElementById('al-reason').value;
                const status = document.getElementById('al-status').value;
                if (!teacher || !from || !to) { showAdminToast('Sabhi fields bharna zaroori hai!', true); return; }

                const fromDate = new Date(from);
                const toDate = new Date(to);
                const days = Math.max(1, Math.round((toDate - fromDate) / (1000 * 60 * 60 * 24)) + 1);
                const tName = teacher.split(' — ')[0];
                const tInitials = tName.split(' ').map(w => w[0]).join('').substring(0, 2).toUpperCase();
                const statusTag = status === 'approved'
                  ? '<span class="tag tag-green">Approved</span>'
                  : '<span class="tag tag-yellow">Pending</span>';
                const ico = status === 'approved'
                  ? '<i class="bi bi-check-circle-fill"></i>'
                  : '<i class="bi bi-clock-fill"></i>';
                const icoBg = status === 'approved' ? '#d1fae5' : '#fef3c7';
                const icoColor = status === 'approved' ? '#059669' : '#d97706';
                const fromFmt = fromDate.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' });
                const toFmt = toDate.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' });

                const histItem = `<div style="display:flex;align-items:center;gap:12px;padding:11px 0;border-bottom:1px solid var(--border);">
      <div style="width:40px;height:40px;border-radius:11px;background:${icoBg};color:${icoColor};display:flex;align-items:center;justify-content:center;font-size:17px;flex-shrink:0;">${ico}</div>
      <div style="flex:1;"><div style="font-size:13px;font-weight:600;">${tName} — Assigned</div><div style="font-size:12px;color:var(--muted);">${fromFmt}${days > 1 ? ' – ' + toFmt : ''} • ${days} day${days > 1 ? 's' : ''}</div></div>
      ${statusTag}
    </div>`;
                document.getElementById('leave-history-list').insertAdjacentHTML('afterbegin', histItem);

                closeAssignLeaveModal();
                document.getElementById('al-teacher').value = '';
                document.getElementById('al-from').value = '';
                document.getElementById('al-to').value = '';
                document.getElementById('al-reason').value = '';
                showAdminToast(tName + ' ko leave assign ho gayi! ✓');
              }

              function approveLeave(rowId) {
                const row = document.getElementById(rowId);
                if (row) row.remove();
                const tbody = document.getElementById('pending-tbody');
                if (tbody && tbody.children.length === 0) {
                  document.getElementById('no-pending').style.display = 'block';
                }
                showAdminToast('Leave approve ho gayi! ✓');
              }

              function rejectLeave(rowId) {
                const row = document.getElementById(rowId);
                if (row) row.remove();
                const tbody = document.getElementById('pending-tbody');
                if (tbody && tbody.children.length === 0) {
                  document.getElementById('no-pending').style.display = 'block';
                }
                showAdminToast('Leave reject kar di gayi.');
              }

              function saveLeaveBalance() {
                closeEditLeaveModal();
                showAdminToast('Leave balance update ho gaya! ✓');
              }

              function showAdminToast(msg, isErr) {
                const t = document.createElement('div');
                t.textContent = msg;
                Object.assign(t.style, {
                  position: 'fixed', bottom: '24px', left: '50%',
                  transform: 'translateX(-50%) translateY(20px)',
                  background: isErr ? '#ef4444' : '#0c1a2e',
                  color: '#fff', padding: '12px 24px', borderRadius: '12px',
                  fontSize: '13px', fontWeight: '600', zIndex: '9999', opacity: '0',
                  transition: 'all .3s ease', boxShadow: '0 8px 24px rgba(0,0,0,.2)',
                  fontFamily: 'Sora,sans-serif'
                });
                document.body.appendChild(t);
                requestAnimationFrame(() => { t.style.opacity = '1'; t.style.transform = 'translateX(-50%) translateY(0)'; });
                setTimeout(() => { t.style.opacity = '0'; t.style.transform = 'translateX(-50%) translateY(20px)'; setTimeout(() => t.remove(), 300); }, 2600);
              }

              function handleAvatarChange(input) {
                if (input.files && input.files[0]) {
                  const reader = new FileReader();
                  reader.onload = function (e) {
                    const ids = ['sidebar-photo', 'profile-photo', 'modal-photo-preview'];
                    ids.forEach(id => {
                      const el = document.getElementById(id);
                      if (el) el.src = e.target.result;
                    });
                  };
                  reader.readAsDataURL(input.files[0]);
                }
              }



              // --- STUDENT MANAGEMENT FUNCTIONS ---
              function openAddStudentModal() {
                document.getElementById('addStudentModal').classList.add('show');
                document.body.style.overflow = 'hidden';
              }
              function closeAddStudentModal() {
                document.getElementById('addStudentModal').classList.remove('show');
                document.body.style.overflow = '';
              }
              function closeAddStudentOutside(e) {
                if (e.target === document.getElementById('addStudentModal')) closeAddStudentModal();
              }

              function applyStudentFilters() {
                const searchInput = document.getElementById('studentSearchInput');
                const classFilter = document.getElementById('classFilterSelect');
                const query = searchInput.value.toLowerCase().trim();
                const selectedClass = classFilter.value;
                const rows = document.querySelectorAll('.student-row');
                const noRow = document.getElementById('noStudentRow');

                // Visual update for dropdown
                classFilter.style.borderColor = selectedClass ? 'var(--accent)' : '';
                classFilter.style.fontWeight = selectedClass ? '700' : '';

                let visibleCount = 0;

                rows.forEach(row => {
                  const name = row.getAttribute('data-name');
                  const email = row.getAttribute('data-email');
                  const roll = row.getAttribute('data-roll');
                  const cls = row.getAttribute('data-class');

                  const matchesSearch = !query || name.includes(query) || email.includes(query) || roll.includes(query) || cls.includes(query);
                  const matchesClass = !selectedClass || cls === selectedClass;

                  if (matchesSearch && matchesClass) {
                    row.style.display = '';
                    visibleCount++;

                    // Highlighting
                    if (query) {
                      highlightText(row.querySelector('.search-name'), query);
                      highlightText(row.querySelector('.search-email'), query);
                      highlightText(row.querySelector('.search-roll'), query);
                      highlightText(row.querySelector('.search-class'), query);
                    } else {
                      removeHighlight(row);
                    }
                  } else {
                    row.style.display = 'none';
                  }
                });

                if (noRow) noRow.style.display = (visibleCount === 0) ? '' : 'none';
              }

              function highlightText(el, query) {
                if (!el) return;
                const originalText = el.innerText;
                const regex = new RegExp(`(${query})`, 'gi');
                el.innerHTML = originalText.replace(regex, '<mark style="background:#fef08a;border-radius:3px;padding:0 2px;">$1</mark>');
              }

              function removeHighlight(row) {
                row.querySelectorAll('.search-name, .search-email, .search-roll, .search-class').forEach(el => {
                  el.innerHTML = el.innerText;
                });
              }

              function exportStudentsToExcel() {
                const table = document.querySelector("#page-students table");
                const rows = table.querySelectorAll("tbody tr.student-row");

                // CSV Headers
                let csv = ['"S.No","Name","Email","Roll No.","Class","Attendance","Fees Status","Status"'];

                let serial = 1;
                rows.forEach(function (row) {
                  // Skip hidden rows (filtered out)
                  if (row.style.display === 'none') return;

                  // Read all data from data attributes (cleanest method)
                  const name = row.getAttribute('data-name-val') || '';
                  const email = row.getAttribute('data-email-val') || '';
                  const roll = row.getAttribute('data-roll-val') || '';
                  const cls = row.getAttribute('data-class-val') || '';
                  const att = row.getAttribute('data-att') || '';
                  const fees = row.getAttribute('data-fees') || '';
                  const status = row.getAttribute('data-status') || '';

                  csv.push(
                    `"${serial}","${name}","${email}","${roll}","${cls}","${att}","${fees}","${status}"`
                  );
                  serial++;
                });

                // Download
                const BOM = '\uFEFF'; // UTF-8 BOM for Excel support
                const csvFile = new Blob([BOM + csv.join('\n')], { type: 'text/csv;charset=utf-8;' });
                const downloadLink = document.createElement('a');
                downloadLink.download = 'Students_List.csv';
                downloadLink.href = window.URL.createObjectURL(csvFile);
                downloadLink.style.display = 'none';
                document.body.appendChild(downloadLink);
                downloadLink.click();
                document.body.removeChild(downloadLink);
                showAdminToast('CSV Export ho gaya! ✓');
              }

              function confirmDeleteStudent(id, name) {
                if (confirm(`Kya aap pakka '${name}' ko delete karna chahte hain?`)) {
                  window.location.href = 'deleteStudent?id=' + id;
                }
              }

              function openEditStudentModal(id) {
                const row = document.querySelector('.student-row[data-id="' + id + '"]');
                if (!row) return;
                document.getElementById('edit-sid').value = id;
                document.getElementById('edit-name').value = row.getAttribute('data-name-val');
                document.getElementById('edit-email').value = row.getAttribute('data-email-val');
                document.getElementById('edit-roll').value = row.getAttribute('data-roll-val');
                document.getElementById('edit-class').value = row.getAttribute('data-class-val');
                document.getElementById('edit-section').value = row.getAttribute('data-section-val');
                document.getElementById('editStudentModal').classList.add('show');
                document.body.style.overflow = 'hidden';
              }

              function closeEditStudentModal() {
                document.getElementById('editStudentModal').classList.remove('show');
                document.body.style.overflow = '';
              }

              window.onload = function () {
                updateDynamicDates();
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get('success')) {
                  showAdminToast("Kaam safal raha! Student add ho gaya. ✓");
                }
                if (urlParams.get('error')) {
                  showAdminToast("Kuch galat ho gaya! Dobara try karein.", true);
                }
                if (urlParams.get('deleted')) {
                  showAdminToast("Student data successfully delete ho gaya! ✓");
                }
                const page = urlParams.get('page');
                if (page) {
                  const targetBtn = document.querySelector(`[onclick="showPage('${page}', this)"]`);
                  if (targetBtn) showPage(page, targetBtn);
                }
              };

              function updateDynamicDates() {
                const today = new Date();
                const shortFmt = today.toLocaleDateString('en-GB', { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' });
                const longFmt = today.toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
                const topbar = document.getElementById('topbar-date');
                if (topbar) topbar.innerText = shortFmt;
                const dash = document.getElementById('dash-date');
                if (dash) dash.innerText = longFmt;
              }
            </script>
            <!-- ═══ EDIT STUDENT MODAL ═══ -->
            <div class="modal-backdrop-custom" id="editStudentModal"
              onclick="if(event.target===this) closeEditStudentModal()">
              <div class="edit-modal" style="max-width:500px;">
                <div class="edit-modal-head" style="border-radius:18px 18px 0 0;">
                  <h5><i class="bi bi-pencil-fill me-2" style="color:var(--accent);"></i>Edit Student</h5>
                  <button class="modal-close" onclick="closeEditStudentModal()">✕</button>
                </div>
                <div class="edit-modal-body" style="padding:24px;">
                  <form action="EditStudentServlet" method="post">
                    <input type="hidden" name="student_id" id="edit-sid" />
                    <div class="row g-3">
                      <div class="col-12">
                        <label class="form-label">Full Name</label>
                        <input name="name" id="edit-name" class="form-control" required />
                      </div>
                      <div class="col-6">
                        <label class="form-label">Email</label>
                        <input name="email" id="edit-email" type="email" class="form-control" required />
                      </div>
                      <div class="col-6">
                        <label class="form-label">Roll No</label>
                        <input name="roll_no" id="edit-roll" class="form-control" required />
                      </div>
                      <div class="col-6">
                        <label class="form-label">Class</label>
                        <input name="class" id="edit-class" class="form-control" required />
                      </div>
                      <div class="col-6">
                        <label class="form-label">Section</label>
                        <input name="section" id="edit-section" class="form-control" required />
                      </div>
                      <div class="col-12 pt-2">
                        <button type="submit" class="save-btn" style="width:100%">
                          <i class="bi bi-check-circle-fill me-1"></i>Save Changes
                        </button>
                      </div>
                    </div>
                  </form>
                </div>
              </div>
            </div>
          </body>

          </html>