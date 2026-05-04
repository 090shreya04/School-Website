<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ page import="java.sql.*, java.util.*, java.io.*" %>

    <% 
      response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
      response.setHeader("Pragma", "no-cache");
      response.setDateHeader("Expires", 0);
      if (session==null || session.getAttribute("user_id")==null) { response.sendRedirect("/signin"); return; } Object
      userId=session.getAttribute("user_id"); String adName="Admin User" , adDesignation="Super Administrator" ,
      adInitials="A" , adPhotoBase64=null; String adDob="" , adGender="" , adBlood="" , adPhone="" , adEmail="" ,
      adAddress="" ; String adDept="" , adEmpId="" , adJoined="" , adSubject="" , adQual="" , adExp="" , adRole="" ,
      adActive="" ; Connection conn=null; PreparedStatement pstmt=null; ResultSet rs=null; try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      conn=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root" , "" ); String
      sql="SELECT u.*, t.* FROM user u LEFT JOIN teachers t ON u.user_id = t.user_id WHERE u.user_id = ?" ;
      pstmt=conn.prepareStatement(sql); pstmt.setObject(1, userId); rs=pstmt.executeQuery(); if (rs.next()) {
      adName=rs.getString("name"); adRole=rs.getString("role"); int status=rs.getInt("is_active"); adActive=(status==1)
      ? "Active" : "Inactive" ; adDob=rs.getString("dob"); if (adDob==null) adDob="" ; adGender=rs.getString("gender");
      if (adGender==null) adGender="" ; adBlood=rs.getString("blood_group"); if (adBlood==null) adBlood="" ;
      adPhone=rs.getString("phone"); if (adPhone==null) adPhone="" ; adEmail=rs.getString("email"); if (adEmail==null)
      adEmail="" ; adAddress=rs.getString("address"); if (adAddress==null) adAddress="" ;
      adDept=rs.getString("department"); if (adDept==null) adDept="" ; adEmpId=rs.getString("employee_id"); if
      (adEmpId==null) adEmpId="" ; adJoined=rs.getString("joined_on"); if (adJoined==null) adJoined="" ;
      adSubject=rs.getString("subject"); if (adSubject==null) adSubject="" ; adQual=rs.getString("qualification"); if
      (adQual==null) adQual="" ; adExp=rs.getString("experience"); if (adExp==null) adExp="" ; adDesignation=adDept; if
      (adDesignation==null || adDesignation.isEmpty()) adDesignation="Super Administrator" ; byte[]
      photoBytes=rs.getBytes("photo"); if (photoBytes !=null && photoBytes.length> 0) {
      adPhotoBase64 = java.util.Base64.getEncoder().encodeToString(photoBytes);
      }
      if (adName != null && !adName.isEmpty()) {
      String[] parts = adName.trim().split("\\s+");
      StringBuilder sb = new StringBuilder();
      for (int i = 0; i < Math.min(parts.length, 2); i++) { if (parts[i].length()> 0) sb.append(parts[i].charAt(0));
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

        // -- Student Stats --
        int totalStudents = 0, activeStudents = 0, inactiveStudents = 0, newStudentsThisMonth = 0;
        int totalTeachers = 0, activeTeachers = 0, onLeaveTeachers = 0, totalDepts = 0;
        int absentToday = 0, presentToday = 0, onLeaveToday = 0, workingDaysYear = 0;
        double feesCollected = 0;
        int feesPending = 0;
        double schoolAvg = 0;
        int distinctions = 0;
        int failedResults = 0;
        int examsCompleted = 0;
        int currentMonth = java.time.LocalDate.now().getMonthValue();
        int currentYear = java.time.LocalDate.now().getYear();
        String monthName = java.time.LocalDate.now().getMonth().name().substring(0, 1).toUpperCase() +
        java.time.LocalDate.now().getMonth().name().substring(1).toLowerCase();

        // -- Dashboard Dynamic Variables --
        int newNoticesCount = 0;
        double totalExpectedFees = 0;
        int feesCollectedCount = 0;
        int feesPendingCount = 0;
        Map<String, Double> classAttendance = new LinkedHashMap<>();
            class DashActivity {
            String type, title, subtitle, time, icon, color;
            DashActivity(String t, String tl, String st, String tm, String ic, String cl) {
            type=t; title=tl; subtitle=st; time=tm; icon=ic; color=cl;
            }
            }
            List<DashActivity> recentActivities = new ArrayList<>();

                // -- System Settings --
                String schoolName = "Delhi Public School", academicYear = "2025-2026", schoolCode = "DPS-001", board =
                "CBSE", medium = "English", schoolAddress = "Sector 12, Dwarka, New Delhi - 110078", contactEmail =
                "info@dps.edu.in";
                boolean emailNotif = true, attendanceAlert = true;

                Connection conn2 = null;
                try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root", "");
                ResultSet r1 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM students");
                if(r1.next()) totalStudents = r1.getInt(1);
                ResultSet r2 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM students s JOIN user u ON s.user_id = u.user_id WHERE u.is_active=1");
                if(r2.next()) activeStudents = r2.getInt(1);
                inactiveStudents = totalStudents - activeStudents;
                ResultSet r3 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM students s JOIN user u ON s.user_id = u.user_id WHERE MONTH(u.created_at)=MONTH(NOW()) AND YEAR(u.created_at)=YEAR(NOW())");
                if(r3.next()) newStudentsThisMonth = r3.getInt(1);
                ResultSet r4 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM teachers");
                if(r4.next()) totalTeachers = r4.getInt(1);
                ResultSet rT1 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM teachers WHERE status='Active'");
                if(rT1.next()) activeTeachers = rT1.getInt(1);
                ResultSet rT2 = conn2.createStatement().executeQuery("SELECT COUNT(DISTINCT teacher_id) FROM leave_applications WHERE status='approved' AND CURDATE() BETWEEN from_date AND to_date");
                if(rT2.next()) onLeaveTeachers = rT2.getInt(1);
                ResultSet rT3 = conn2.createStatement().executeQuery("SELECT COUNT(DISTINCT department) FROM teachers WHERE department IS NOT NULL AND department != ''");
                if(rT3.next()) totalDepts = rT3.getInt(1);
                ResultSet r5 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM attendance WHERE date = CURDATE() AND status='present'");
                if(r5.next()) presentToday = r5.getInt(1);
                ResultSet r6 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM attendance WHERE date = CURDATE() AND status='absent'");
                if(r6.next()) absentToday = r6.getInt(1);
                ResultSet r7 = conn2.createStatement().executeQuery("SELECT SUM(amount) FROM fees WHERE status='paid' AND month='" + monthName + "' AND year=" + currentYear); if(r7.next()) feesCollected = r7.getDouble(1); ResultSet r8 = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM fees WHERE status='pending' AND month='" + monthName + "' AND year=" + currentYear); if(r8.next()) feesPending = r8.getInt(1); ResultSet rWD = conn2.createStatement().executeQuery("SELECT config_key, config_value FROM settings");
                while(rWD.next()) {
                String key = rWD.getString("config_key");
                String val = rWD.getString("config_value");
                if("working_days_year".equals(key)) workingDaysYear = Integer.parseInt(val);
                else if("school_name".equals(key)) schoolName = val;
                else if("academic_year".equals(key)) academicYear = val;
                else if("school_code".equals(key)) schoolCode = val;
                else if("board".equals(key)) board = val;
                else if("medium".equals(key)) medium = val;
                else if("school_address".equals(key)) schoolAddress = val;
                else if("contact_email".equals(key)) contactEmail = val;
                else if("email_notifications".equals(key)) emailNotif = "true".equalsIgnoreCase(val);
                else if("low_attendance_alerts".equals(key)) attendanceAlert = "true".equalsIgnoreCase(val);
                }
                ResultSet rsRAvg = conn2.createStatement().executeQuery("SELECT AVG(marks_obtained * 100.0 / total_marks) FROM results");
                if(rsRAvg.next()) schoolAvg = rsRAvg.getDouble(1);
                ResultSet rsRDist = conn2.createStatement().executeQuery("SELECT COUNT(DISTINCT student_id) FROM results GROUP BY student_id HAVING AVG(marks_obtained * 100.0 / total_marks) >= 90");
                distinctions = 0; while(rsRDist.next()) distinctions++;
                ResultSet rsRFail = conn2.createStatement().executeQuery("SELECT COUNT(DISTINCT student_id) FROM results GROUP BY student_id HAVING AVG(marks_obtained * 100.0 / total_marks) < 33"); failedResults=0;
                  while(rsRFail.next()) failedResults++; ResultSet rsRExams=conn2.createStatement().executeQuery("SELECT COUNT(DISTINCT exam_type, exam_date) FROM results"); if(rsRExams.next())
                  examsCompleted=rsRExams.getInt(1); 
// -- Notice Count -- 
try { ResultSet rsNotices=conn2.createStatement().executeQuery("SELECT COUNT(*) FROM notices WHERE published_at>= DATE_SUB(NOW(), INTERVAL 7 DAY)");
                  if(rsNotices.next()) newNoticesCount = rsNotices.getInt(1);
                  } catch(Exception e) { e.printStackTrace(); }

                  // -- Fee Progress --
                  try {
                  // Collected this month
                  ResultSet rsColCount = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM fees WHERE status='paid' AND month='" + monthName + "' AND year=" + currentYear); if(rsColCount.next()) feesCollectedCount = rsColCount.getInt(1); /* Total Students (active) */ int totalActiveSt = 0; ResultSet rsTotalActive = conn2.createStatement().executeQuery("SELECT COUNT(*) FROM students s JOIN user u ON s.user_id = u.user_id WHERE u.is_active=1");
                  if(rsTotalActive.next()) totalActiveSt = rsTotalActive.getInt(1);

                  // Pending Count = Total Active Students - Collected Count
                  feesPendingCount = totalActiveSt - feesCollectedCount;
                  if(feesPendingCount < 0) feesPendingCount=0; 
/* Expected Fees based on active students and their class */
                  ResultSet rsFeeExp=conn2.createStatement().executeQuery("SELECT SUM(fs.monthly_fee) FROM students s JOIN user u ON s.user_id=u.user_id JOIN fee_structure fs ON TRIM(s.class)=TRIM(fs.class_name) WHERE u.is_active=1");
                  if(rsFeeExp.next()) totalExpectedFees=rsFeeExp.getDouble(1); } catch(Exception e) { e.printStackTrace(); } 
                  
                  // -- Class-wise Attendance (Robust) -- 
                  try { 
                    String attSql="SELECT s.class, (COUNT(CASE WHEN a.status='present' THEN 1 END) * 100.0 / COUNT(*)) as pct FROM attendance a JOIN students s ON a.student_id = s.student_id WHERE a.date = CURDATE() GROUP BY s.class"; 
                    ResultSet rsAttData=conn2.createStatement().executeQuery(attSql); 
                    while(rsAttData.next()) {
                      classAttendance.put(rsAttData.getString("class"), rsAttData.getDouble("pct")); 
                    } 
                    // Ensure all classes show up even if 0% 
                    ResultSet rsAllCls=conn2.createStatement().executeQuery("SELECT DISTINCT class FROM students"); 
                    while(rsAllCls.next()) { 
                      String cls=rsAllCls.getString("class");
                      if(!classAttendance.containsKey(cls)) classAttendance.put(cls, 0.0); 
                    } 
                  } catch(Exception e) { e.printStackTrace(); } 
                  
                  // -- Recent Activity (Consolidated Top 2) -- 
                  try { 
                    String combinedSql="(SELECT 'student' as type, 'Naya student admit hua' as title, CONCAT(s.name, ' — Class ', s.class, '-', s.section) as subtitle, u.created_at as sort_time, DATE_FORMAT(u.created_at, '%d %b, %h:%i %p') as time_str, 'rgba(16, 185, 129, 0.1);color:#059669' as color, 'bi-person-plus-fill' as icon FROM students s JOIN user u ON s.user_id = u.user_id WHERE u.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)) "
                    + "UNION ALL "
                    + "(SELECT 'fee' as type, 'Fee payment receive hua' as title, CONCAT(s.name, ' — ₹', amount) as subtitle, payment_date as sort_time, DATE_FORMAT(payment_date, '%d %b, %h:%i %p') as time_str, 'rgba(59, 130, 246, 0.1);color:#2563eb' as color, 'bi-cash-stack' as icon FROM fees f JOIN students s ON f.student_id = s.student_id WHERE payment_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)) "
                    + "UNION ALL "
                    + "(SELECT 'notice' as type, 'Naya notice publish kiya' as title, title as subtitle, published_at as sort_time, DATE_FORMAT(published_at, '%d %b, %h:%i %p') as time_str, 'rgba(245, 158, 11, 0.1);color:#d97706' as color, 'bi-megaphone-fill' as icon FROM notices WHERE published_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)) "
                    + "ORDER BY sort_time DESC LIMIT 2" ; ResultSet
                    rsComb=conn2.createStatement().executeQuery(combinedSql); while(rsComb.next()) {
                    recentActivities.add(new DashActivity(rsComb.getString("type"), rsComb.getString("title"),
                    rsComb.getString("subtitle"), rsComb.getString("time_str"), rsComb.getString("icon"),
                    rsComb.getString("color"))); } } catch(Exception e) { e.printStackTrace(); } } catch(Exception e) {
                    e.printStackTrace(); } finally { if(conn2 !=null) try { conn2.close(); } catch(Exception e) {} }
                    boolean hasPersonalInfo=(adName !=null && !adName.trim().isEmpty()) && (adDob !=null &&
                    !adDob.trim().isEmpty()) && (adGender !=null && !adGender.trim().isEmpty()) && (adBlood !=null &&
                    !adBlood.trim().isEmpty()) && (adPhone !=null && !adPhone.trim().isEmpty()) && (adEmail !=null &&
                    !adEmail.trim().isEmpty()) && (adAddress !=null && !adAddress.trim().isEmpty()); boolean
                    hasProfessionalInfo=(adSubject !=null && !adSubject.trim().isEmpty()) && (adDesignation !=null &&
                    !adDesignation.trim().isEmpty()) && (adDept !=null && !adDept.trim().isEmpty()) && (adEmpId !=null
                    && !adEmpId.trim().isEmpty()) && (adQual !=null && !adQual.trim().isEmpty()) && (adExp !=null &&
                    !adExp.trim().isEmpty()); %>



                    <!DOCTYPE html>

                    <html lang="en">

                    <head>

                      <meta charset="UTF-8" />

                      <meta name="viewport" content="width=device-width, initial-scale=1.0" />

                      <title>Admin Dashboard</title>

                      <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css"
                        rel="stylesheet" />

                      <link
                        href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css"
                        rel="stylesheet" />

                      <link
                        href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap"
                        rel="stylesheet" />

                      <link rel="stylesheet" href="/css/adashboard.css" />

                    </head>

                    <body>

                      <!-- ═══════ ADD TIMETABLE MODAL ═══════ -->

                      <div class="modal-backdrop-custom" id="addTimetableModal" style="z-index: 99999; display: none;"
                        onclick="if(event.target===this) closeAddTimetableModal()">

                        <div class="edit-modal" style="max-width:550px;">

                          <div class="edit-modal-head">

                            <h5><i class="bi bi-calendar-plus me-2" style="color:var(--accent);"></i> Add Timetable Slot
                            </h5>

                            <button class="modal-close" onclick="closeAddTimetableModal()">✕</button>

                          </div>

                          <form action="/addTimetable" method="post">

                            <div class="edit-modal-body">

                              <div class="row g-3">

                                <div class="col-md-6">

                                  <label class="form-label">Day</label>

                                  <select name="day" class="form-select" required>

                                    <option value="Monday">Monday</option>

                                    <option value="Tuesday">Tuesday</option>

                                    <option value="Wednesday">Wednesday</option>

                                    <option value="Thursday">Thursday</option>

                                    <option value="Friday">Friday</option>

                                    <option value="Saturday">Saturday</option>

                                  </select>

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Teacher</label>

                                  <select name="teacher_id" class="form-select" required>

                                    <option value="">-- Teacher --</option>

                                    <% Connection connTTAdd=null; try { Class.forName("com.mysql.cj.jdbc.Driver");
                                      connTTAdd=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root", "" ); 
                                      ResultSet rsTAdd=connTTAdd.createStatement().executeQuery("SELECT teacher_id, name FROM teachers WHERE status='Active' ORDER BY name ASC");
                                      while(rsTAdd.next()) { %>

                                      <option value="<%= rsTAdd.getInt("teacher_id")%>"><%= rsTAdd.getString("name")%>

                                      </option>

                                      <% } } catch(Exception e) {} finally { if(connTTAdd !=null) try {
                                        connTTAdd.close(); } catch(Exception e) {} } %>

                                  </select>

                                </div>

                                <div class="col-md-4">

                                  <label class="form-label">Class</label>

                                  <input type="text" name="class" class="form-control" placeholder="e.g. 10" required />

                                </div>

                                <div class="col-md-4">

                                  <label class="form-label">Section</label>

                                  <input type="text" name="section" class="form-control" placeholder="e.g. A"
                                    required />

                                </div>

                                <div class="col-md-4">

                                  <label class="form-label">Subject</label>

                                  <input type="text" name="subject" class="form-control" placeholder="e.g. Mathematics"
                                    required />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Start Time</label>

                                  <input type="time" name="start_time" class="form-control" required />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">End Time</label>

                                  <input type="time" name="end_time" class="form-control" required />

                                </div>

                                <div class="col-md-12">

                                  <label class="form-label">Room / Lab</label>

                                  <input type="text" name="room" class="form-control" placeholder="e.g. Room 102"
                                    required />

                                </div>

                              </div>

                            </div>

                            <div class="edit-modal-footer d-flex gap-2 p-3 border-top">

                              <button type="submit" class="save-btn" style="flex:1;"><i class="bi bi-check-lg me-1"></i>
                                Add

                                Slot</button>

                              <button type="button" class="btn-icon" onclick="closeAddTimetableModal()"
                                style="width:auto; height:auto; padding:12px 20px; border-radius:11px; background:var(--bg); border:1.5px solid var(--border); font-weight:600;">Cancel</button>

                            </div>

                          </form>

                        </div>

                      </div>

                      <!-- ═══════ EDIT WORKING DAYS MODAL ═══════ -->

                      <div class="modal-backdrop-custom" id="editWorkingDaysModal"
                        style="z-index: 99999; display: none;">

                        <div class="edit-modal" style="max-width:400px;">

                          <div class="edit-modal-head">

                            <h5><i class="bi bi-calendar-event-fill me-2" style="color:var(--accent);"></i> Working Days
                              Setup

                            </h5>

                            <button class="modal-close" onclick="closeWorkingDaysModal()">✕</button>

                          </div>

                          <form action="/updateWorkingDays" method="post">

                            <div class="edit-modal-body">

                              <div class="row g-3">

                                <div class="col-md-12">

                                  <label class="form-label">Kul Working Days (Salana)</label>

                                  <input type="number" name="days" class="form-control" value="<%= workingDaysYear%>"
                                    required />

                                  <small class="text-muted">Ye value pura saal ke liye update ho jayegi.</small>

                                </div>

                              </div>

                            </div>

                            <div class="edit-modal-footer d-flex gap-2 p-3 border-top">

                              <button type="submit" class="save-btn" style="flex:1;"><i
                                  class="bi bi-save2-fill me-1"></i>

                                Update Karein</button>

                              <button type="button" class="btn-icon" onclick="closeWorkingDaysModal()"
                                style="width:auto; height:auto; padding:12px 20px; border-radius:11px; background:var(--bg); border:1.5px solid var(--border); font-weight:600;">Cancel</button>

                            </div>

                          </form>

                        </div>

                      </div>

                      <!-- ═══════ ADD PAYMENT MODAL ═══════ -->

                      <div class="modal-backdrop-custom" id="addPaymentModal" style="z-index: 99999; display: none;">

                        <div class="edit-modal" style="max-width:500px;">

                          <div class="edit-modal-head">

                            <h5><i class="bi bi-cash-stack me-2" style="color:var(--accent);"></i> Add Payment</h5>

                            <button class="modal-close" onclick="closeAddPaymentModal()">✕</button>

                          </div>

                          <form action="/addPayment" method="post">

                            <div class="edit-modal-body">

                              <div class="row g-3">

                                <div class="col-md-12">

                                  <label class="form-label">Student Roll No.</label>

                                  <input type="text" name="roll_no" class="form-control" placeholder="e.g. 10A-05"
                                    required />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Amount (₹)</label>

                                  <input type="number" step="0.01" name="amount" class="form-control" required />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Transaction ID</label>

                                  <input type="text" name="transaction_id" class="form-control" required />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Payment Date</label>

                                  <input type="date" name="payment_date" class="form-control" required />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Status</label>

                                  <select name="status" class="form-select" required>

                                    <option value="Paid">Paid</option>

                                    <option value="Pending">Pending</option>

                                  </select>

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Month</label>

                                  <select name="month" class="form-select" required>

                                    <option value="January">January</option>

                                    <option value="February">February</option>

                                    <option value="March">March</option>

                                    <option value="April">April</option>

                                    <option value="May">May</option>

                                    <option value="June">June</option>

                                    <option value="July">July</option>

                                    <option value="August">August</option>

                                    <option value="September">September</option>

                                    <option value="October">October</option>

                                    <option value="November">November</option>

                                    <option value="December">December</option>

                                  </select>

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Year</label>

                                  <input type="number" name="year" class="form-control" value="2026" required />

                                </div>

                              </div>

                            </div>

                            <div class="edit-modal-footer d-flex gap-2 p-3 border-top">

                              <button type="submit" class="save-btn" style="flex:1;"><i class="bi bi-check-lg me-1"></i>
                                Add

                                Payment</button>

                              <button type="button" class="btn-icon" onclick="closeAddPaymentModal()"
                                style="width:auto; height:auto; padding:12px 20px; border-radius:11px; background:var(--bg); border:1.5px solid var(--border); font-weight:600;">Cancel</button>

                            </div>

                          </form>

                        </div>

                      </div>

                      <!-- ═══════ PUBLISH NOTICE MODAL (TOP-LEVEL) ═══════ -->

                      <div class="modal-backdrop-custom" id="publishNoticeModal" style="z-index: 9999; display: none;"
                        onclick="if(event.target===this) window.closePublishNoticeModal()">

                        <div class="edit-modal" style="max-width:550px;">

                          <div class="edit-modal-head">

                            <h5><i class="bi bi-megaphone-fill me-2" style="color:var(--accent);"></i> Naya Notice Draft
                              Karo

                            </h5>

                            <button class="modal-close" onclick="window.closePublishNoticeModal()">✕</button>

                          </div>

                          <form action="/publishNotice" method="post">

                            <input type="hidden" name="student_id" id="notice-student-id">

                            <div class="edit-modal-body">

                              <div id="notice-specific-student"
                                style="display:none; padding:10px; background:#f0fdf4; border-radius:8px; border:1px solid #bbf7d0; margin-bottom:15px;">

                                <i class="bi bi-person-check-fill me-2" style="color:#16a34a;"></i>

                                Sending specifically to student: <strong id="notice-student-name"
                                  style="color:#166534;"></strong>

                              </div>

                              <div class="row g-3">

                                <div class="col-md-12">

                                  <label class="form-label">Notice Title</label>

                                  <input type="text" name="title" class="form-control" required
                                    placeholder="e.g. Annual Sports Day 2026" />

                                </div>

                                <div class="col-md-12">

                                  <label class="form-label">Message / Details</label>

                                  <textarea name="message" class="form-control" rows="4" required
                                    placeholder="Type your announcement here..."></textarea>

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Target Audience</label>

                                  <select name="target" class="form-select">

                                    <option value="all">All (Students & Teachers)</option>

                                    <option value="students">Only Students</option>

                                    <option value="teachers">Only Teachers</option>

                                  </select>

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Priority Level</label>

                                  <select name="priority" class="form-select">

                                    <option value="normal">Normal (Green)</option>

                                    <option value="important">Important (Yellow)</option>

                                    <option value="urgent">Urgent (Red)</option>

                                  </select>

                                </div>

                              </div>

                            </div>

                            <div class="edit-modal-footer d-flex gap-2 p-3 border-top">

                              <button type="submit" class="save-btn" style="flex:1;"><i
                                  class="bi bi-send-fill me-1"></i>Publish

                                Notice</button>

                              <button type="button" class="btn-icon" onclick="window.closePublishNoticeModal()"
                                style="width:auto; height:auto; padding:12px 20px; border-radius:11px; background:var(--bg); border:1.5px solid var(--border); font-weight:600;">Cancel</button>

                            </div>

                          </form>

                        </div>

                      </div>

                      <!-- ═══════ SIDEBAR ═══════ -->

                      <aside class="sidebar" id="sidebar">

                        <div class="s-brand">

                          <div class="s-brand-icon"><i class="bi bi-shield-fill-check"></i></div>

                          <div class="s-brand-text">

                            <h6><%= schoolName %></h6>

                            <small>Admin Control Panel</small>

                          </div>

                        </div>

                        <div class="s-admin-card">

                          <div class="s-avatar">

                            <img
                              src='<%= adPhotoBase64 != null ? "data:image/jpeg;base64," + adPhotoBase64                      : "images/user_default_photo.webp"%>'
                              style="width:100%;height:100%;object-fit:cover;" id="sidebar-photo" />

                          </div>

                          <div class="s-admin-info">

                            <h6 id="sidebar-name">

                              <%= adName%>

                            </h6>

                            <small id="sidebar-sub">

                              <%= adDesignation%>

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

                              <span class="s-badge">

                                <%= totalStudents%>

                              </span>

                            </a>

                          </div>

                          <div class="s-nav-item">

                            <a class="s-nav-link" onclick="showPage('teachers', this)">

                              <i class="bi bi-person-video3"></i> Teachers

                              <span class="s-badge">

                                <%= totalTeachers%>

                              </span>

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

                            <a class="s-nav-link" onclick="showPage('timetable', this)">

                              <i class="bi bi-calendar3"></i> Timetable

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

                          <a href="/admin_logout" class="s-logout" style="text-decoration: none;"
                            onclick="localStorage.removeItem('activeAdminPage')">
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

                            <div class="tb-btn"
                              onclick="showPage('notices', document.querySelector('[onclick*=notices]'))">

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
                              <h4>Welcome back, <%= (adName !=null && !adName.isEmpty()) ? adName.split(" ")[0] : "Admin" %>! 👋</h4>
                              <p>Yahan hai aapke school ka aaj ka poora overview.</p>
                            </div>
                            <div class="pg-header-right d-none d-md-flex align-items-center gap-3">
                            </div>
                          </div>

                          <!-- Big stats -->

                          <div class="row g-4 mb-5">
                            <div class="col-12 col-sm-6 col-xl-3">
                              <div class="stat">
                                <div class="stat-ico" style="background:rgba(249, 115, 22, 0.1);color:#ea580c;"><i
                                    class="bi bi-people-fill"></i></div>
                                <h3>
                                  <%= totalStudents %>
                                </h3>
                                <p>Total Students</p>
                                <div class="d-flex align-items-center gap-2">
                                  <span class="tag tag-orange">↑ <%= newStudentsThisMonth %> new admission</span>
                                  <small class="text-muted" style="font-size: 10px;">this month</small>
                                </div>
                              </div>
                            </div>

                            <div class="col-12 col-sm-6 col-xl-3">
                              <div class="stat">
                                <div class="stat-ico" style="background:rgba(59, 130, 246, 0.1);color:#2563eb;"><i
                                    class="bi bi-person-video3"></i></div>
                                <h3>
                                  <%= totalTeachers %>
                                </h3>
                                <p>Total Staff</p>
                                <div class="d-flex align-items-center gap-2">
                                  <span class="tag tag-blue">Active: <%= activeTeachers %></span>
                                  <span class="tag tag-purple">
                                    <%= onLeaveTeachers %> Leave
                                  </span>
                                </div>
                              </div>
                            </div>

                            <div class="col-12 col-sm-6 col-xl-3">
                              <div class="stat">
                                <div class="stat-ico" style="background:rgba(16, 185, 129, 0.1);color:#059669;"><i
                                    class="bi bi-calendar-check-fill"></i></div>
                                <h3>
                                  <%= (totalStudents> 0 ? (presentToday * 100 / totalStudents) : 0) %>%
                                </h3>
                                <p>Today's Attendance</p>
                                <div class="prog-bar-wrap mb-2" style="height: 4px;">
                                  <div class="prog-bar"
                                    style="background: var(--green); width: <%= (totalStudents > 0 ? (presentToday * 100 / totalStudents) : 0) %>%">
                                  </div>
                                </div>
                                <span class="tag tag-green">
                                  <%= presentToday %> Present Today
                                </span>
                              </div>
                            </div>

                            <div class="col-12 col-sm-6 col-xl-3">
                              <div class="stat">
                                <div class="stat-ico" style="background:rgba(245, 158, 11, 0.1);color:#d97706;"><i
                                    class="bi bi-cash-coin"></i></div>
                                <h3>₹<%= String.format("%.1f", feesCollected / 1000.0) %>K</h3>
                                <p>Fees Collected</p>
                                <div class="d-flex align-items-center gap-2">
                                  <span class="tag tag-yellow">
                                    <%= feesPendingCount %> pending payments
                                  </span>
                                </div>
                              </div>
                            </div>
                          </div>

                          <!-- Mini stats -->

                          <div class="row g-3 mb-4">

                            <div class="col-6 col-md-3">

                              <div class="mini-stat">

                                <div class="mini-stat-ico" style="background:#ede9fe;color:#7c3aed;"><i
                                    class="bi bi-calendar-range-fill"></i>

                                </div>

                                <div class="mini-stat-info">

                                  <% int activeSlots=0; try { Class.forName("com.mysql.cj.jdbc.Driver"); Connection connStat=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root"
                                    , "" ); ResultSet rsStat=connStat.createStatement().executeQuery("SELECT COUNT(*) FROM timetable"); if(rsStat.next()) activeSlots=rsStat.getInt(1); connStat.close();
                                    } catch(Exception e) {} %>

                                    <p>

                                      <%= activeSlots%>

                                    </p><small>Active Slots</small>

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

                                    <%= absentToday%>

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
                                  <p>
                                    <%= String.format("%.1f", schoolAvg) %>%
                                  </p><small>Avg Score</small>
                                </div>

                              </div>

                            </div>

                            <div class="col-6 col-md-3">

                              <div class="mini-stat">

                                <div class="mini-stat-ico" style="background:#fef3c7;color:#d97706;"><i
                                    class="bi bi-bell-fill"></i>

                                </div>

                                <div class="mini-stat-info">
                                  <p>
                                    <%= newNoticesCount %>
                                  </p><small>New Notices</small>
                                </div>

                              </div>

                            </div>

                          </div>

                          <div class="row g-3 mb-4">
                            <!-- Attendance by class -->
                            <div class="col-12 col-lg-6">
                              <div class="card-box">
                                <div class="card-head">
                                  <i class="bi bi-calendar-check-fill" style="color:var(--accent);"></i>
                                  <h6>Class-wise Attendance Today</h6>
                                </div>
                                <div class="card-body-p">
                                  <% if(classAttendance.isEmpty()) { %>
                                    <div class="p-4 text-center text-muted">No attendance data for today</div>
                                    <% } else { String[] attColors={"#10b981", "#f97316" , "#f59e0b" , "#3b82f6" }; int
                                      attColorIdx=0; for(Map.Entry<String, Double> entry : classAttendance.entrySet()) {
                                      String className = entry.getKey();
                                      double percentage = entry.getValue();
                                      String color = attColors[attColorIdx % attColors.length];
                                      %>
                                      <div class="mb-3">
                                        <div class="d-flex justify-content-between mb-1">
                                          <span style="font-size:13px;font-weight:600;">Class <%= className %></span>
                                          <span
                                            style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:<%= color %>;">
                                            <%= String.format("%.0f", percentage) %>%
                                          </span>
                                        </div>
                                        <div class="prog-bar-wrap">
                                          <div class="prog-bar"
                                            style="width:<%= percentage %>%;background:<%= color %>;"></div>
                                        </div>
                                      </div>
                                      <% attColorIdx++; } } %>
                                </div>
                              </div>
                            </div>

                            <!-- Fee Collection Progress (Moved up) -->
                            <div class="col-12 col-lg-6">
                              <div class="card-box">
                                <div class="card-head">
                                  <i class="bi bi-cash-coin" style="color:var(--yellow);"></i>
                                  <h6>Fee Collection — <%= monthName %> <%= currentYear %></h6>
                                </div>
                                <div class="card-body-p">
                                  <div style="display:flex;align-items:baseline;gap:8px;margin-bottom:6px;">
                                    <span style="font-size:32px;font-weight:800;font-family:'JetBrains Mono',monospace;">₹<%= String.format("%.1f", feesCollected / 1000.0) %>K</span>
                                    <span style="color:var(--muted);font-size:13px;">of ₹<%= String.format("%.1f", totalExpectedFees / 1000.0) %>K</span>
                                  </div>
                                  <% double feePercent=totalExpectedFees> 0 ? (feesCollected * 100 / totalExpectedFees) : 0; %>
                                    <div class="prog-bar-wrap mb-3" style="height:10px;">
                                      <div class="prog-bar" style="width:<%= feePercent %>%;background:linear-gradient(90deg,#f97316,#fbbf24);"></div>
                                    </div>
                                    <div class="d-flex justify-content-between">
                                      <div>
                                        <div class="info-label">Collected</div>
                                        <div style="font-weight:700;color:var(--green);"><%= feesCollectedCount %> Students</div>
                                      </div>
                                      <div style="text-align:right;">
                                        <div class="info-label">Pending</div>
                                        <div style="font-weight:700;color:var(--red);"><%= feesPendingCount %> Students</div>
                                      </div>
                                    </div>
                                </div>
                              </div>
                            </div>
                          </div>

                          <div class="row g-3 mb-4">
                            <!-- Recent Activity (Full Width) -->
                            <div class="col-12">
                              <div class="card-box">
                                <div class="card-head d-flex justify-content-between align-items-center">
                                  <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-lightning-charge-fill" style="color:var(--purple);"></i>
                                    <h6>Recent Activity</h6>
                                  </div>
                                  <button class="btn-icon" style="border:none; background:transparent;"><i class="bi bi-three-dots"></i></button>
                                </div>
                                <div class="card-body-p">
                                  <% if(recentActivities.isEmpty()) { %>
                                    <div class="p-4 text-center text-muted">No recent activity</div>
                                    <% } else { for(DashActivity act : recentActivities) { %>
                                      <div class="activity-item">
                                        <div class="act-ico" style="background:<%= act.color %>;"><i class="bi <%= act.icon %>"></i></div>
                                        <div class="act-text">
                                          <p><%= act.title %></p>
                                          <small><%= act.subtitle %></small>
                                        </div>
                                        <div class="act-time"><%= act.time %></div>
                                      </div>
                                      <% } } %>
                                </div>
                                <div class="p-3 text-center" style="border-top:1px solid var(--border);">
                                  <a href="#" class="text-accent fw-bold" style="font-size: 12px; text-decoration:none; color:var(--accent);" onclick="showPage('activity', this)">View All Activity <i class="bi bi-chevron-right"></i></a>
                                </div>
                              </div>
                            </div>
                          </div>

                          <div class="row g-3 mb-4">
                            <!-- Top performers (Full Width) -->
                            <div class="col-12">
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
                                      <% Connection connTop=null; try { Class.forName("com.mysql.cj.jdbc.Driver");
                                        connTop=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root", "" ); String
                                        topSql="SELECT s.name, s.class, s.section, AVG(r.marks_obtained * 100.0 / r.total_marks) as avg_score "
                                        + "FROM students s JOIN results r ON s.student_id = r.student_id "
                                        + "GROUP BY s.student_id ORDER BY avg_score DESC LIMIT 3" ; ResultSet
                                        rsTop=connTop.createStatement().executeQuery(topSql); int rank=1; String[]
                                        rankColors={"#d97706", "var(--muted)" , "var(--muted)" }; String[]
                                        avBgs={"#fef3c7", "#d1fae5" , "#dbeafe" }; String[] avTcs={"#d97706", "#059669"
                                        , "#2563eb" }; while(rsTop.next()) { String name=rsTop.getString("name"); String
                                        cls_=rsTop.getString("class"); String sec_=rsTop.getString("section"); double
                                        score=rsTop.getDouble("avg_score"); String initials=name.substring(0,
                                        Math.min(2, name.length())).toUpperCase(); %>
                                        <tr>
                                          <td><span style="font-weight:800; font-family:'JetBrains Mono', monospace; color:<%= rankColors[rank-1] %>;">#<%= rank %></span></td>
                                          <td>
                                            <div class="d-flex align-items-center gap-2">
                                              <div class="av-sm" style="background:<%= avBgs[rank-1]%>;color:<%= avTcs[rank-1]%>;"><%= initials%></div>
                                              <%= name%>
                                            </div>
                                          </td>
                                          <td><%= cls_%> <%= sec_%></td>
                                          <td><span class="tag <%= score >= 90 ? "tag-yellow" : (score>= 75 ? "tag-green" : "tag-blue") %>"><%= String.format("%.1f", score) %>%</span></td>
                                        </tr>
                                        <% rank++; } if(rank==1) { %>
                                          <tr><td colspan="4" class="text-center py-3 text-muted">No results recorded yet.</td></tr>
                                          <% } } catch(Exception e) { e.printStackTrace(); } finally { if(connTop !=null) try { connTop.close(); } catch(Exception e) {} } %>
                                    </tbody>
                                  </table>

                                </div>

                              </div>

                            </div>
                          </div>
                        </div>

                        <!-- Recent Activity Page (Full) -->
                        <div id="page-activity" class="page" style="display:none;">
                          <div class="pg-header d-flex justify-content-between align-items-center mb-4">
                            <div>
                              <h4 style="font-weight:800; color:var(--dark); margin:0;">All Recent Activity</h4>
                              <p style="color:var(--muted); margin:5px 0 0 0;">School transactions aur updates track
                                karein</p>
                            </div>
                            <button class="btn-accent" onclick="showPage('dashboard')"><i class="bi bi-grid-fill"></i>
                              Dashboard Wapasi</button>
                          </div>

                          <div class="card-box">
                            <div class="table-responsive">
                              <table class="table tbl mb-0">
                                <thead>
                                  <tr>
                                    <th>Activity Type</th>
                                    <th>Details</th>
                                    <th>Date & Time</th>
                                    <th>Status</th>
                                  </tr>
                                </thead>
                                <tbody>
                                  <% Connection connActFull=null; try { Class.forName("com.mysql.cj.jdbc.Driver");
                                    connActFull=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root"
                                    , "" ); 
// Get everything from last 30 days 
String
                                    fullActSql="(SELECT 'Student Admission' as type, s.name as title, CONCAT('Class ', s.class, '-', s.section) as subtitle, u.created_at as sort_time, DATE_FORMAT(u.created_at, '%d %b %Y, %h:%i %p') as time_str, 'success' as color_tag FROM students s JOIN user u ON s.user_id = u.user_id) "
                                    + "UNION ALL "
                                    + "(SELECT 'Fee Payment' as type, s.name as title, CONCAT('Amount: ₹', amount) as subtitle, payment_date as sort_time, DATE_FORMAT(payment_date, '%d %b %Y, %h:%i %p') as time_str, 'info' as color_tag FROM fees f JOIN students s ON f.student_id = s.student_id) "
                                    + "UNION ALL "
                                    + "(SELECT 'Notice Published' as type, title as title, target as subtitle, published_at as sort_time, DATE_FORMAT(published_at, '%d %b %Y, %h:%i %p') as time_str, 'warning' as color_tag FROM notices) "
                                    + "ORDER BY sort_time DESC LIMIT 50" ; ResultSet
                                    rsFullAct=connActFull.createStatement().executeQuery(fullActSql);
                                    while(rsFullAct.next()) { String type=rsFullAct.getString("type"); String
                                    title=rsFullAct.getString("title"); String subtitle=rsFullAct.getString("subtitle");
                                    String timeStr=rsFullAct.getString("time_str"); String
                                    tag=rsFullAct.getString("color_tag"); String tagClass="tag-" + ( "success"
                                    .equals(tag) ? "green" : ("info".equals(tag) ? "blue" : "orange" ) ); %>
                                    <tr>
                                      <td>
                                        <div class="d-flex align-items-center gap-2">
                                          <div class="av-sm"
                                            style="width:32px; height:32px; background:var(--bg); color:var(--dark); font-size:14px;">
                                            <i class="bi <%= " Student Admission".equals(type) ? "bi-person-plus" : ("Fee Payment".equals(type) ? "bi-cash" : "bi-megaphone" ) %>"></i>
                                          </div>
                                          <span style="font-weight:600; font-size:13px;">
                                            <%= type %>
                                          </span>
                                        </div>
                                      </td>
                                      <td>
                                        <div style="font-weight:700;">
                                          <%= title %>
                                        </div>
                                        <div style="font-size:12px; color:var(--muted);">
                                          <%= subtitle %>
                                        </div>
                                      </td>
                                      <td style="font-family:'JetBrains Mono',monospace; font-size:12px;">
                                        <%= timeStr %>
                                      </td>
                                      <td><span class="tag <%= tagClass %>">Completed</span></td>
                                    </tr>
                                    <% } } catch(Exception e) { %>
                                      <tr>
                                        <td colspan="4" class="text-center p-4">Error loading activity: <%=
                                            e.getMessage() %>
                                        </td>
                                      </tr>
                                      <% } finally { if(connActFull!=null) try{connActFull.close();}catch(Exception e){}
                                        } %>
                                </tbody>
                              </table>
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

                                <img
                                  src='<%= adPhotoBase64 != null ? "data:image/jpeg;base64," + adPhotoBase64                          : "images/user_default_photo.webp"%>'
                                  style="width:100%;height:100%;object-fit:cover;" id="profile-photo" />

                              </div>

                              <div class="avatar-edit-btn"
                                onclick="document.getElementById('avatar-input-hero').click()">

                                <i class="bi bi-camera-fill"></i>

                              </div>

                              <input type="file" id="avatar-input-hero" accept="image/*" style="display:none"
                                onchange="handleAvatarChange(this)" />

                            </div>

                            <h3 id="profile-name">

                              <%= adName%>

                            </h3>

                            <div class="role-text" id="profile-role">

                              <%= adDesignation%> • <%= schoolName %> System

                            </div>

                            <div class="profile-tags">

                              <span class="ptag" id="profile-dept-tag"><i class="bi bi-diagram-3-fill"></i>

                                <%= adDept%>

                              </span>

                              <span class="ptag"
                                style="background:rgba(249,115,22,.15);border-color:rgba(249,115,22,.3);color:var(--accent);">

                                Since <%= adJoined%>

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
                          <div class="row g-3">
                            <% if (!hasPersonalInfo && !hasProfessionalInfo) { %>
                              <div class="col-12">
                                <div class="card-box p-5 text-center mb-4">
                                  <i class="bi bi-person-exclamation"
                                    style="font-size: 48px; color: var(--accent); opacity: 0.5;"></i>
                                  <h5 class="mt-3" style="font-weight: 700;">Profile Incomplete Hai</h5>
                                  <p class="text-muted">Your Profile is currently incomplete. Please, click on edit
                                    profile and fill all the details.</p>
                                  <button class="btn-accent mx-auto mt-2" onclick="openEditModal()">
                                    <i class="bi bi-pencil-fill me-2"></i>Edit Profile
                                  </button>
                                </div>
                              </div>
                              <% } %>

                                <% if (hasPersonalInfo) { %>
                                  <div class="col-12">
                                    <div class="card-box">
                                      <div class="card-head"><i class="bi bi-person-fill"
                                          style="color:var(--accent);"></i>
                                        <h6>Personal Information</h6>
                                      </div>
                                      <div class="card-body-p">
                                        <div class="row g-3">
                                          <div class="col-6">
                                            <div class="info-label">Full Name</div>
                                            <div class="info-val" id="info-name">
                                              <%= adName%>
                                            </div>
                                          </div>
                                          <div class="col-6">
                                            <div class="info-label">Date of Birth</div>
                                            <div class="info-val" id="info-dob">
                                              <%= adDob%>
                                            </div>
                                          </div>
                                          <div class="col-6">
                                            <div class="info-label">Gender</div>
                                            <div class="info-val" id="info-gender">
                                              <%= adGender%>
                                            </div>
                                          </div>
                                          <div class="col-6">
                                            <div class="info-label">Blood Group</div>
                                            <div class="info-val" id="info-blood">
                                              <%= adBlood%>
                                            </div>
                                          </div>
                                          <div class="col-6">
                                            <div class="info-label">Phone Number</div>
                                            <div class="info-val" id="info-phone">
                                              <%= adPhone%>
                                            </div>
                                          </div>
                                          <div class="col-6">
                                            <div class="info-label">Email</div>
                                            <div class="info-val" id="info-email">
                                              <%= adEmail%>
                                            </div>
                                          </div>
                                          <div class="col-12">
                                            <div class="info-label">Address</div>
                                            <div class="info-val" id="info-address">
                                              <%= adAddress%>
                                            </div>
                                          </div>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                  <% } %>

                                    <% if (hasProfessionalInfo) { %>
                                      <div class="col-12">
                                        <div class="card-box mb-3">
                                          <div class="card-head"><i class="bi bi-briefcase-fill"
                                              style="color:var(--blue);"></i>
                                            <h6>Professional Details</h6>
                                          </div>
                                          <div class="card-body-p">
                                            <div class="row g-3">
                                              <div class="col-12">
                                                <div class="info-label">Subject</div>
                                                <div class="info-val">
                                                  <%= adSubject%>
                                                </div>
                                              </div>
                                              <div class="col-6">
                                                <div class="info-label">Department</div>
                                                <div class="info-val" id="info-dept">
                                                  <%= adDept%>
                                                </div>
                                              </div>
                                              <div class="col-6">
                                                <div class="info-label">Employee ID</div>
                                                <div class="info-val" style="font-family:'JetBrains Mono',monospace;">
                                                  <%= adEmpId%>
                                                </div>
                                              </div>
                                              <div class="col-6">
                                                <div class="info-label">Qualification</div>
                                                <div class="info-val">
                                                  <%= adQual%>
                                                </div>
                                              </div>
                                              <div class="col-6">
                                                <div class="info-label">Experience</div>
                                                <div class="info-val">
                                                  <%= adExp%>
                                                </div>
                                              </div>
                                              <div class="col-12">
                                                <div class="info-label">Joined On</div>
                                                <div class="info-val">
                                                  <%= adJoined%>
                                                </div>
                                              </div>
                                            </div>
                                          </div>
                                        </div>

                                        <div class="card-box">
                                          <div class="card-head"><i class="bi bi-shield-lock-fill"
                                              style="color:var(--green);"></i>
                                            <h6>Access & Permissions</h6>
                                          </div>
                                          <div class="card-body-p">
                                            <div class="row g-2">
                                              <div class="col-12">
                                                <div
                                                  class="d-flex align-items-center justify-content-between p-2 rounded-3"
                                                  style="background:#f8fafc;">
                                                  <span style="font-size:13px;font-weight:600;">Student
                                                    Management</span>
                                                  <span class="tag tag-green">Full Access</span>
                                                </div>
                                              </div>
                                              <div class="col-12">
                                                <div
                                                  class="d-flex align-items-center justify-content-between p-2 rounded-3"
                                                  style="background:#f8fafc;">
                                                  <span style="font-size:13px;font-weight:600;">Fee Management</span>
                                                  <span class="tag tag-green">Full Access</span>
                                                </div>
                                              </div>
                                              <div class="col-12">
                                                <div
                                                  class="d-flex align-items-center justify-content-between p-2 rounded-3"
                                                  style="background:#f8fafc;">
                                                  <span style="font-size:13px;font-weight:600;">System Settings</span>
                                                  <span class="tag tag-orange">Admin Only</span>
                                                </div>
                                              </div>
                                            </div>
                                          </div>
                                        </div>
                                      </div>
                                      <% } %>
                          </div>
                        </div> <!-- End of Page Profile -->







                        <!-- ═══ STUDENTS ═══ -->

                        <div class="page" id="page-students">

                          <div class="pg-header">

                            <div class="pg-header-left">

                              <p>List of all students!! Add, edit and delete students</p>

                            </div>

                            <div class="d-flex gap-2">

                              <button class="btn-outline" onclick="exportStudentsToExcel()"><i
                                  class="bi bi-download"></i>

                                Export</button>

                              <button class="btn-accent" onclick="openAddStudentModal()"><i
                                  class="bi bi-person-plus-fill"></i>

                                Add New Student</button>

                            </div>

                          </div>

                          <!-- Stats row -->

                          <div class="row g-3 mb-3">

                            <div class="col-12">

                              <div class="mini-stat">

                                <div class="mini-stat-ico" style="background:#ffedd5;color:#ea580c;"><i
                                    class="bi bi-people-fill"></i>

                                </div>

                                <div class="mini-stat-info">

                                  <p>

                                    <%= totalStudents%>

                                  </p><small>Total</small>

                                </div>

                              </div>

                            </div>

                            <div class="col-12">

                              <div class="mini-stat">

                                <div class="mini-stat-ico" style="background:#d1fae5;color:#059669;"><i
                                    class="bi bi-person-check-fill"></i>

                                </div>

                                <div class="mini-stat-info">

                                  <p>

                                    <%= activeStudents%>

                                  </p><small>Active</small>

                                </div>

                              </div>

                            </div>

                            <div class="col-12">

                              <div class="mini-stat">

                                <div class="mini-stat-ico" style="background:#fee2e2;color:#dc2626;"><i
                                    class="bi bi-person-x-fill"></i>

                                </div>

                                <div class="mini-stat-info">

                                  <p>

                                    <%= inactiveStudents%>

                                  </p><small>Inactive</small>

                                </div>

                              </div>

                            </div>

                            <div class="col-12">

                              <div class="mini-stat">

                                <div class="mini-stat-ico" style="background:#dbeafe;color:#2563eb;"><i
                                    class="bi bi-person-plus-fill"></i>

                                </div>

                                <div class="mini-stat-info">

                                  <p>

                                    <%= newStudentsThisMonth%>

                                  </p><small>New (March)</small>

                                </div>

                              </div>

                            </div>

                          </div>

                          <% String searchVal=(request.getParameter("search") !=null) ? request.getParameter("search")
                            : "" ; %>

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
                                        placeholder="Search students..." value="<%= searchVal%>"
                                        oninput="applyStudentFilters()"
                                        onkeydown="if(event.key==='Enter') applyStudentFilters()"
                                        style="width:180px;padding:7px 12px;font-size:13px;border-radius:9px;" />

                                    </div>

                                    <select name="classFilter" id="classFilterSelect" class="form-select"
                                      onchange="applyStudentFilters()"
                                      style="width:130px;font-size:13px;padding:7px 10px;border-radius:9px; transition:all 0.2s;">

                                      <option value="">All Classes</option>

                                      <% Connection connC=null; try { Class.forName("com.mysql.cj.jdbc.Driver");
                                        connC=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root", "" ); 
                                        String queryC="SELECT DISTINCT class FROM students WHERE class IS NOT NULL AND class != '' ORDER BY CAST(class AS UNSIGNED) ASC"; 
                                        ResultSet rsC=connC.createStatement().executeQuery(queryC); 
                                        String currentFilter=request.getParameter("classFilter"); while(rsC.next()){ String cName=rsC.getString("class"); %>

                                        <option value="<%= cName%>" <%=(cName !=null && cName.equals(currentFilter)) ? "selected" : "" %>>Class <%= cName%>

                                        </option>

                                        <% } } catch(Exception e){ e.printStackTrace(); } finally { if(connC !=null) try { connC.close(); } catch(Exception e) {} } %>

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
                                      <th style="text-align:center;">Action</th>
                                    </tr>
                                  </thead>
                                  <tbody>

                                    <% Connection connSt=null; try {
                                      Class.forName("com.mysql.cj.jdbc.Driver"); connSt=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root", "" ); 
                                      String search=(request.getParameter("search") !=null) ? request.getParameter("search") : "" ; 
                                      String classFilter=(request.getParameter("classFilter") !=null) ? request.getParameter("classFilter") : "" ; 
                                      StringBuilder baseQuery=new StringBuilder("SELECT s.student_id, s.name, s.email, s.roll_no, s.class, s.section, u.is_active FROM students s JOIN user u ON s.user_id=u.user_id WHERE 1=1"); 
                                      if (!search.isEmpty()) { baseQuery.append(" AND (s.name LIKE '%").append(search).append("%' OR s.email LIKE '%").append(search).append("%' OR s.roll_no LIKE '%").append(search).append("%' )"); } 
                                      if (!classFilter.isEmpty()) { baseQuery.append(" AND s.class='").append(classFilter).append("'"); } 
                                      baseQuery.append(" ORDER BY s.name"); 
                                      String[] colors={"#ffedd5", "#dbeafe" , "#d1fae5" , "#fef3c7", "#ede9fe" , "#fee2e2" }; 
                                      String[] textColors={"#ea580c", "#2563eb" , "#059669", "#d97706" , "#7c3aed" , "#dc2626" }; ResultSet
                                      stRs=connSt.createStatement().executeQuery(baseQuery.toString()); int idx=0; while
                                      (stRs.next()) { String sid=stRs.getString("student_id"); String
                                      sName=stRs.getString("name"); if (sName==null) sName="Unknown" ; String
                                      sEmail=stRs.getString("email"); if (sEmail==null) sEmail="" ; String
                                      sRoll=stRs.getString("roll_no"); if (sRoll==null) sRoll="0" ; String
                                      sClassVal=stRs.getString("class"); String sSectVal=stRs.getString("section");
                                      String sClass=(sClassVal !=null ? sClassVal : "" ) + "-" + (sSectVal !=null ? sSectVal : "" ); int sAtt=92; String sFees="Paid" ; int
                                      sActive=stRs.getInt("is_active"); String statusText=(sActive==1) ? "Active" : "Inactive" ; String statusClass=(sActive==1) ? "tag-green" : "tag-red" ; String
                                      feesTag="Paid".equals(sFees) ? "tag-green" : "tag-red" ; StringBuilder sbInit=new
                                      StringBuilder(); String[] parts=sName.trim().split("\\s+"); for (String part :
                                      parts) { if (part.length()> 0) sbInit.append(part.charAt(0)); } String initials =
                                      sbInit.toString().toUpperCase(); if (initials.length() > 2) initials =
                                      initials.substring(0, 2); if (initials.isEmpty()) initials = "??"; String rowBg =
                                      colors[idx % colors.length]; String rowTc = textColors[idx % textColors.length];
                                      String rowStyle = "background-color:" + rowBg + ";color:" + rowTc + ";"; String
                                      attColor = sAtt >= 85 ? "var(--green)" : sAtt >= 70 ? "var(--yellow)" : "var(--red)"; String attStyle = "font-weight:700; color:" + attColor + ";"; String
                                      escapedName = sName.replace("'", "\\'"); String avatarHtml = "<div class=\"av-sm\" style=\"background-color:" + rowBg + ";color:" + rowTc + "\">" + initials + "</div>"; 
                                      String attSpan = "<span style=\"font-weight:700;color:" + attColor + "\">" + sAtt + "%</span>"; 
                                      String feesSpan = "<span class=\"tag " + feesTag + "\">" + sFees + "</span>"; 
                                      String statusSpan = "<span class=\"tag " + statusClass + "\">" + statusText + "</span>"; idx++; %>

                                      <tr class="student-row" data-id="<%= sid%>" data-name="<%= sName.toLowerCase()%>"
                                        data-email="<%= sEmail.toLowerCase()%>" data-roll="<%= sRoll.toLowerCase()%>"
                                        data-class="<%= sClassVal%>" data-att="<%= sAtt%>%" data-fees="<%= sFees%>"
                                        data-status="<%= statusText%>" data-name-val="<%= sName%>"
                                        data-email-val="<%= sEmail%>" data-class-val="<%= sClassVal%>"
                                        data-section-val="<%= sSectVal != null ? sSectVal : ""%>"
                                        data-roll-val="<%= sRoll%>">

                                        <td>

                                          <div class="d-flex align-items-center gap-2">

                                            <%= avatarHtml%>

                                              <div>

                                                <div style="font-weight:600;" class="search-name">

                                                  <%= sName%>

                                                </div>

                                                <div style="font-size:11px;color:var(--muted);" class="search-email">

                                                  <%= sEmail%>

                                                </div>

                                              </div>

                                          </div>

                                        </td>

                                        <td style="font-family:'JetBrains Mono',monospace;" class="search-roll">#<%=
                                            sRoll%>

                                        </td>

                                        <td class="search-class">

                                          <%= sClass%>

                                        </td>

                                        <td>

                                          <%= attSpan%>

                                        </td>

                                        <td>

                                          <%= feesSpan%>

                                        </td>

                                        <td>

                                          <%= statusSpan%>

                                        </td>

                                        <td>

                                          <div class=" d-flex gap-1">

                                            <button class="btn-icon"
                                              onclick="openEditStudentModal('<%= sid.replace("'", "\\'") %>', '<%= sName.replace("'", "\\'").replace("\"", "&quot;") %>', '<%= sEmail.replace("'", "\\'").replace("\"", "&quot;") %>', '<%= sRoll.replace("'", "\\'").replace("\"", "&quot;") %>', '<%= (sClassVal != null ? sClassVal : "").replace("'", "\\'").replace("\"", "&quot;") %>', '<%= (sSectVal != null ? sSectVal : "").replace("'", "\\'").replace("\"", "&quot;") %>')"><i class="bi bi-pencil-fill"></i></button>

                                            <button class="btn-icon del"
                                              onclick="confirmDeleteStudent('<%= sid%>', '<%= escapedName%>')"><i
                                                class="bi bi-trash-fill"></i></button>

                                          </div>

                                        </td>

                                      </tr>



                                      <tr id="noStudentRow" <%=(idx> 0) ? "hidden" : ""%>>

                                        <td colspan="7" style="text-align:center;padding:40px 20px;">

                                          <div style="font-size:36px;">😕</div>

                                          <div style="font-size:16px;font-weight:700;margin-top:8px;">Oops!! Data Not
                                            Found

                                          </div>

                                          <div style="font-size:13px;color:var(--muted);margin-top:4px;">

                                            <%= (idx==0) ? "Search ya filter change karke dobara try karein." : "" %>

                                          </div>

                                        </td>

                                      </tr>

                                      <% } } catch(Exception e) { e.printStackTrace(); } finally { if(connSt !=null) try
                                        { connSt.close(); } catch(Exception ex) {} } %>

                                  </tbody>

                                </table>

                              </div>

                            </div>

                        </div> <!-- End of Page Students -->

                        <!-- ═══ TEACHERS ═══ -->

                        <div class="page" id="page-teachers">

                          <div class="pg-header">

                            <div class="pg-header-left">

                              <p>Staff ki poori details manage karo</p>

                            </div>

                            <div class="d-flex gap-2">

                              <button class="btn-outline" onclick="exportTeachersToCSV()">

                                <i class="bi bi-download"></i> Export

                              </button>

                              <button class="btn-accent" onclick="openAddTeacherModal()">

                                <i class="bi bi-person-plus-fill"></i> Naya Teacher Add

                              </button>

                            </div>

                          </div>

                          <div class="row g-3 mb-3">

                            <div class="col-12">

                              <div class="mini-stat">

                                <div class="mini-stat-ico" style="background:#dbeafe;color:#2563eb;"><i
                                    class="bi bi-people-fill"></i>

                                </div>

                                <div class="mini-stat-info">

                                  <p>

                                    <%= totalTeachers%>

                                  </p><small>Total Staff</small>

                                </div>

                              </div>

                            </div>

                            <div class="col-12">

                              <div class="mini-stat">

                                <div class="mini-stat-ico" style="background:#d1fae5;color:#059669;"><i
                                    class="bi bi-person-check-fill"></i>

                                </div>

                                <div class="mini-stat-info">

                                  <p>

                                    <%= activeTeachers%>

                                  </p><small>Active</small>

                                </div>

                              </div>

                            </div>

                            <div class="col-12">

                              <div class="mini-stat">

                                <div class="mini-stat-ico" style="background:#fef3c7;color:#d97706;"><i
                                    class="bi bi-hourglass-split"></i>

                                </div>

                                <div class="mini-stat-info">

                                  <p>

                                    <%= onLeaveTeachers%>

                                  </p><small>On Leave</small>

                                </div>

                              </div>

                            </div>

                            <div class="col-12">

                              <div class="mini-stat">

                                <div class="mini-stat-ico" style="background:#ffedd5;color:#ea580c;"><i
                                    class="bi bi-award-fill"></i>

                                </div>

                                <div class="mini-stat-info">

                                  <p>

                                    <%= totalDepts%>

                                  </p><small>Departments</small>

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

                                    <th>Department</th>

                                    <th>Experience</th>

                                    <th>Status</th>

                                    <th>Actions</th>

                                  </tr>

                                </thead>

                                <tbody>

                                  <% Connection connTeach=null; try {
                                    Class.forName("com.mysql.cj.jdbc.Driver"); connTeach=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root"
                                    , "" ); String
                                    tSql="SELECT teacher_id, employee_id, name, email, subject, department, experience, status FROM teachers ORDER BY name"
                                    ; java.sql.ResultSet stRsT=connTeach.createStatement().executeQuery(tSql); String[]
                                    colors={"#ffedd5","#dbeafe","#d1fae5","#fef3c7","#ede9fe","#fee2e2"}; String[]
                                    textColors={"#ea580c","#2563eb","#059669","#d97706","#7c3aed","#dc2626"}; int idx=0;
                                    while(stRsT.next()) { String tid=stRsT.getString("teacher_id"); if(tid==null) tid=""
                                    ; String tempid=stRsT.getString("employee_id"); if(tempid==null) tempid="" ; String
                                    tname=stRsT.getString("name"); if(tname==null) tname="Unknown" ; String
                                    temail=stRsT.getString("email"); if(temail==null) temail="" ; String
                                    tsubj=stRsT.getString("subject"); if(tsubj==null) tsubj="" ; String
                                    tdept=stRsT.getString("department"); if(tdept==null) tdept="" ; String
                                    texp=stRsT.getString("experience"); if(texp==null) texp="" ; String
                                    statusText=stRsT.getString("status"); if(statusText==null) statusText="" ; String
                                    statusTag="Active".equalsIgnoreCase(statusText) ? "tag-green" : ("On Leave".equalsIgnoreCase(statusText) ? "tag-yellow" : "tag-red" );
                                    if(statusText.isEmpty()) { statusText="Active" ; statusTag="tag-green" ; }
                                    StringBuilder sbInit=new StringBuilder(); String[] parts=tname.trim().split("\\s+");
                                    for (int i=0; i < Math.min(parts.length, 2); i++) { if (parts[i].length()> 0)
                                    sbInit.append(parts[i].charAt(0)); } String initials =
                                    sbInit.toString().toUpperCase(); if(initials.isEmpty()) initials = "??"; String
                                    rowBg = colors[idx % colors.length]; String rowTc = textColors[idx %
                                    textColors.length]; String avatarHtml = "<div class=\"av-sm\" style=\"background-color:" + rowBg + ";color:" + rowTc + "\">" + initials + "</div>"; idx++;
                                    // JS Escaping
                                    String jsTid = tid.replace("'", "\\'");
                                    String jsTname = tname.replace("'", "\\'").replace("\"", "&quot;");
                                    String jsTemail = temail.replace("'", "\\'").replace("\"", "&quot;");
                                    String jsTempid = tempid.replace("'", "\\'").replace("\"", "&quot;");
                                    String jsTsubj = tsubj.replace("'", "\\'").replace("\"", "&quot;");
                                    String jsTdept = tdept.replace("'", "\\'").replace("\"", "&quot;");
                                    String jsTexp = texp.replace("'", "\\'").replace("\"", "&quot;");
                                    String jsTstatus = statusText.replace("'", "\\'").replace("\"", "&quot;");

                                    String escapedName = tname.replace("'", "\\'");
                                    String dtCls = tdept.replace("\"", "&quot;");
                                    String escName = tname.replace("\"", "&quot;");
                                    String escEmail = temail.replace("\"", "&quot;");
                                    String escEmpid = tempid.replace("\"", "&quot;");
                                    String escSubj = tsubj.replace("\"", "&quot;");
                                    String escExp = texp.replace("\"", "&quot;"); %>

                                    <tr class="teacher-row" data-id="<%= tid%>" data-name-val="<%= escName%>"
                                      data-email-val="<%= escEmail%>" data-empid-val="<%= escEmpid%>"
                                      data-subject-val="<%= escSubj%>" data-classes-val="<%= dtCls%>"
                                      data-exp-val="<%= escExp%>" data-dept-val="<%= dtCls%>"
                                      data-status="<%= statusText%>">

                                      <td>

                                        <div class="d-flex align-items-center gap-2">

                                          <%= avatarHtml%>

                                            <div>

                                              <div style="font-weight:600;">

                                                <%= tname%>

                                              </div>

                                              <div style="font-size:11px;color:var(--muted);">

                                                <%= temail%>

                                              </div>

                                            </div>

                                        </div>

                                      </td>

                                      <td style="font-family:'JetBrains Mono',monospace;">

                                        <%= tempid%>

                                      </td>

                                      <td>

                                        <%= tsubj%>

                                      </td>

                                      <td>

                                        <%= tdept%>

                                      </td>

                                      <td>

                                        <%= texp%>

                                      </td>

                                      <td><span class="tag <%= statusTag%>">

                                          <%= statusText%>

                                        </span></td>

                                      <td>

                                        <div class="d-flex gap-1">

                                          <button class="btn-icon"
                                            onclick="openEditTeacherModal('<%= jsTid%>','<%= jsTname%>','<%= jsTemail%>','<%= jsTempid%>','<%= jsTsubj%>','<%= jsTdept%>','<%= jsTexp%>','<%= jsTstatus%>')"><i
                                              class="bi bi-pencil-fill"></i></button>

                                          <button class="btn-icon del"
                                            onclick="confirmDeleteTeacher('<%= jsTid%>', '<%= jsTname%>')"><i
                                              class="bi bi-trash-fill"></i></button>

                                        </div>

                                      </td>

                                    </tr>

                                    <% } if (idx==0) { %>

                                      <tr>

                                        <td colspan="7" style="text-align:center;padding:40px 20px;">

                                          <div style="font-size:36px;">😕</div>

                                          <div style="font-size:16px;font-weight:700;margin-top:8px;">No teachers found
                                          </div>

                                        </td>

                                      </tr>

                                      <% } } catch(Exception e) { e.printStackTrace(); } finally { if(connTeach!=null)
                                        try{connTeach.close();}catch(Exception e){} } %>

                                </tbody>

                              </table>

                            </div>

                          </div>

                        </div>

                        <!-- ═══ ATTENDANCE ═══ -->

                        <div class="page" id="page-attendance">

                          <div class="pg-header">

                            <div class="pg-header-left">

                              <p>Class-wise attendance mark karo aur reports dekho</p>

                            </div>

                          </div>

                          <div class="row g-4 mb-4">

                            <div class="col-12">

                              <div class="stat">

                                <div class="stat-ico" style="background:#d1fae5;color:#059669;"><i
                                    class="bi bi-check-circle-fill"></i>

                                </div>

                                <h3>

                                  <%= presentToday%>

                                </h3>

                                <p>Present Today</p><span class="tag tag-green">

                                  <%= (totalStudents> 0) ? (presentToday * 100 / totalStudents) : 0%>%

                                </span>

                              </div>

                            </div>

                            <div class="col-12">

                              <div class="stat">

                                <div class="stat-ico" style="background:#fee2e2;color:#dc2626;"><i
                                    class="bi bi-x-circle-fill"></i>

                                </div>

                                <h3>

                                  <%= absentToday%>

                                </h3>

                                <p>Absent Today</p><span class="tag tag-red">

                                  <%= (totalStudents> 0) ? (absentToday * 100 / totalStudents) : 0%>%

                                </span>

                              </div>

                            </div>

                            <div class="col-12">

                              <div class="stat working-days-card" style="position:relative; cursor:default;">

                                <div class="stat-ico" style="background:#dbeafe;color:#2563eb;"><i
                                    class="bi bi-calendar3"></i>

                                </div>

                                <h3>

                                  <%= workingDaysYear%>

                                </h3>

                                <p>Working Days</p><span class="tag tag-blue">This Year</span>

                                <% if("admin".equalsIgnoreCase(adRole)) { %>

                                  <button onclick="event.stopPropagation(); openWorkingDaysModal()" class="btn-edit-wd"
                                    title="Edit Working Days"
                                    style="position:absolute; top:15px; right:15px; background:rgba(99, 102, 241, 0.1); border:1px solid var(--border); color:var(--accent); width:32px; height:32px; border-radius:8px; display:flex; align-items:center; justify-content:center; cursor:pointer; transition:all 0.2s; opacity:0.6; z-index:100;">

                                    <i class="bi bi-pencil-square"></i>

                                  </button>

                                  <style>
                                    .working-days-card:hover .btn-edit-wd {

                                      opacity: 1 !important;

                                      background: var(--accent) !important;

                                      color: white !important;

                                      transform: scale(1.1);

                                    }
                                  </style>
                                  <% } %>



                              </div>

                            </div>

                          </div>

                          <div class="card-box mb-3">

                            <div class="card-head">

                              <h6>Class-wise Attendance — Today</h6>

                            </div>

                            <div class="table-responsive shadow-sm" style="border-radius:16px;">

                              <table class="table tbl mb-0" style="border-collapse: separate; border-spacing: 0;">

                                <thead>

                                  <tr>

                                    <th>Class</th>

                                    <th>Total Students</th>

                                    <th>Present</th>

                                    <th>Absent</th>

                                    <th>%</th>

                                    <th>Status</th>

                                  </tr>

                                </thead>

                                <tbody>

                                  <% Connection connAtt1=null; try {
                                    Class.forName("com.mysql.cj.jdbc.Driver"); connAtt1=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1","root","");
                                    } catch(Exception eAtt){} String
                                    clSql="SELECT s.class, COUNT(s.student_id) as total, "
                                    + "SUM(CASE WHEN a.status='present' THEN 1 ELSE 0 END) as present, "
                                    + "SUM(CASE WHEN a.status='absent' THEN 1 ELSE 0 END) as absent "
                                    + "FROM students s "
                                    + "LEFT JOIN attendance a ON s.student_id = a.student_id AND a.date = CURDATE() "
                                    + "GROUP BY s.class ORDER BY s.class" ; ResultSet
                                    rsCl=(connAtt1!=null)?connAtt1.createStatement().executeQuery(clSql):null; boolean
                                    hasClData=false; while(rsCl!=null && rsCl.next()) { hasClData=true; String
                                    cls=rsCl.getString("class"); int tot=rsCl.getInt("total"); int
                                    pres=rsCl.getInt("present"); int abs=rsCl.getInt("absent"); int perc=(tot> 0) ?
                                    (pres * 100 / tot) : 0; String statusTag = perc >= 90 ? "tag-green" : (perc >= 75 ?
                                    "tag-yellow" : "tag-red"); String statusText = perc >= 90 ? "Good" : (perc >= 75 ?
                                    "Average" : "Low"); %>

                                    <tr>

                                      <td style="font-weight:700;">

                                        <%= cls%>

                                      </td>

                                      <td>

                                        <%= tot%>

                                      </td>

                                      <td style="color:var(--green);font-weight:700;">

                                        <%= pres%>

                                      </td>

                                      <td style="color:var(--red);font-weight:700;">

                                        <%= abs%>

                                      </td>

                                      <td style="font-weight:700;font-family:'JetBrains Mono',monospace;">

                                        <%= perc%>%

                                      </td>

                                      <td><span class="tag <%= statusTag%>">

                                          <%= statusText%>

                                        </span></td>

                                    </tr>

                                    <% } if(!hasClData) { %>

                                      <tr>

                                        <td colspan="7" style="text-align:center;padding:20px;color:var(--muted);">No

                                          attendance

                                          records found for today.</td>

                                      </tr>

                                      <% } if(connAtt1!=null) try{connAtt1.close();}catch(Exception e){} %>

                                </tbody>

                              </table>

                            </div>

                          </div>

                          <div class="card-box">

                            <div class="card-head"><i class="bi bi-exclamation-triangle-fill"
                                style="color:var(--red);"></i>

                              <h6>Low Attendance Alert (Below 75%)</h6>

                            </div>

                            <div class="card-body-p p-0">

                              <div class="table-responsive" style="border-radius:0 0 16px 16px;">

                                <table class="table tbl mb-0" style="border-collapse: separate; border-spacing: 0;">

                                  <thead>

                                    <tr>

                                      <th>Student</th>

                                      <th>Class</th>

                                      <th>Attendance % & Action</th>

                                    </tr>

                                  </thead>

                                  <tbody>

                                    <% Connection connAtt2=null; try {
                                      Class.forName("com.mysql.cj.jdbc.Driver"); connAtt2=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1","root","");
                                      } catch(Exception eAtt2){} String lowSql="SELECT s.student_id, s.name, s.class, "
                                      + "(SUM(CASE WHEN a.status='present' THEN 1 ELSE 0 END) * 100 / COUNT(a.att_id)) as perc "
                                      + "FROM students s " + "JOIN attendance a ON s.student_id = a.student_id "
                                      + "GROUP BY s.student_id, s.name, s.class " + "HAVING perc < 75 LIMIT 5" ;
                                      ResultSet
                                      rsLow=(connAtt2!=null)?connAtt2.createStatement().executeQuery(lowSql):null;
                                      boolean hasLow=false; while(rsLow!=null && rsLow.next()) { hasLow=true; int
                                      sid=rsLow.getInt("student_id"); String sname=rsLow.getString("name"); String
                                      scls=rsLow.getString("class"); int sperc=rsLow.getInt("perc"); String
                                      initials=sname.substring(0, Math.min(2, sname.length())).toUpperCase(); %>

                                      <tr>

                                        <td>

                                          <div class="d-flex align-items-center gap-2">

                                            <div class="av-sm" style="background:#fee2e2;color:#dc2626;">

                                              <%= initials%>

                                            </div>

                                            <%= sname%>

                                          </div>

                                        </td>

                                        <td>

                                          <%= scls%>

                                        </td>
                                        <td>

                                          <div class="d-flex align-items-center justify-content-between">

                                            <span
                                              style="font-weight:800;color:var(--red);font-family:'JetBrains Mono',monospace;">

                                              <%= sperc%>%

                                            </span>

                                            <% String escapedSName=(sname !=null) ? sname.replace("'", "\\'" ) : "" ;
                                              String noticeCall=String.format("window.openPublishNoticeModal(event, %d, '%s' )", sid, escapedSName); %>
                                              <button class="btn-accent"
                                                style="padding:4px 10px; font-size:11px; white-space:nowrap; border-radius:8px;"
                                                onclick="<%= noticeCall %>">
                                                <i class="bi bi-send-fill me-1"></i>Notice Bhejo
                                              </button>

                                          </div>

                                        </td>

                                      </tr>

                                      <% } if(connAtt2!=null) try{connAtt2.close();}catch(Exception e){} if(!hasLow) {
                                        %>

                                        <tr>

                                          <td colspan="4" style="text-align:center;padding:20px;color:var(--green);">
                                            Sabhi

                                            boards

                                            green hain! 🌟 Sabki attendance focus mein hai.</td>

                                        </tr>
                                        <% } %>


                                  </tbody>

                                </table>

                              </div>

                            </div>

                          </div>

                        </div>

                        <div class="page" id="page-results">

                          <div class="pg-header">

                            <div class="pg-header-left">



                              <p>Exam results manage karo aur marksheets generate karo</p>

                            </div>

                            <a href="/uploadResults" class="btn-accent" style="text-decoration: none;"><i
                                class="bi bi-upload"></i> Results Upload Karo</a>

                          </div>

                          <div class="row g-3 mb-3">

                            <div class="col-12">

                              <div class="stat">

                                <div class="stat-ico" style="background:#ede9fe;color:#7c3aed;"><i
                                    class="bi bi-trophy-fill"></i>

                                </div>

                                <h3>

                                  <%= String.format("%.1f", schoolAvg)%>%

                                </h3>

                                <p>School Average</p><span class="tag tag-purple">All Classes</span>

                              </div>

                            </div>

                            <div class="col-12">

                              <div class="stat">

                                <div class="stat-ico" style="background:#d1fae5;color:#059669;"><i
                                    class="bi bi-star-fill"></i>

                                </div>

                                <h3>

                                  <%= distinctions%>

                                </h3>

                                <p>Distinctions</p><span class="tag tag-green">90%+</span>

                              </div>

                            </div>

                            <div class="col-12">

                              <div class="stat">

                                <div class="stat-ico" style="background:#fee2e2;color:#dc2626;"><i
                                    class="bi bi-x-circle-fill"></i>

                                </div>

                                <h3>

                                  <%= failedResults%>

                                </h3>

                                <p>Failed Students</p><span class="tag tag-red">Needs Attention</span>

                              </div>

                            </div>

                            <div class="col-12">

                              <div class="stat">

                                <div class="stat-ico" style="background:#ffedd5;color:#ea580c;"><i
                                    class="bi bi-file-earmark-text-fill"></i>

                                </div>

                                <h3>

                                  <%= examsCompleted%>

                                </h3>

                                <p>Exams Completed</p>

                              </div>

                            </div>

                          </div>

                          <div class="card-box">

                            <div class="card-head">

                              <h6>Class-wise Result Summary — Current Academic Year</h6>

                              <div class="ms-auto"><button class="btn-outline"
                                  style="font-size:12px;padding:6px 14px;"><i class="bi bi-download"></i> Export
                                  PDF</button></div>

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

                                  <% Connection connRes=null; try { Class.forName("com.mysql.cj.jdbc.Driver");
                                    connRes=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root"
                                    , "" ); String summarySql="SELECT s.class, "
                                    + "COUNT(DISTINCT s.student_id) as total_students, "
                                    + "COUNT(DISTINCT r.student_id) as appeared, "
                                    + "COUNT(DISTINCT CASE WHEN (r.marks_obtained * 100.0 / r.total_marks) >= 33 THEN r.student_id END) as passed, "
                                    + "COUNT(DISTINCT CASE WHEN (r.marks_obtained * 100.0 / r.total_marks) < 33 THEN r.student_id END) as failed, "
                                    + "AVG(r.marks_obtained * 100.0 / r.total_marks) as avg_score, "
                                    + "MAX(r.marks_obtained * 100.0 / r.total_marks) as highest_score "
                                    + "FROM students s " + "LEFT JOIN results r ON s.class = r.class "
                                    + "GROUP BY s.class ORDER BY s.class" ; ResultSet
                                    rsSum=connRes.createStatement().executeQuery(summarySql); boolean hasResData=false;
                                    while(rsSum.next()) { hasResData=true; String cls=rsSum.getString("class"); int
                                    totalS=rsSum.getInt("total_students"); int app=rsSum.getInt("appeared"); int
                                    pass=rsSum.getInt("passed"); int fail=rsSum.getInt("failed"); double
                                    avg=rsSum.getDouble("avg_score"); double high=rsSum.getDouble("highest_score");
                                    String highTag=high>= 90 ? "tag-green" : (high >= 75 ? "tag-yellow" : (high >= 50 ?
                                    "tag-blue" : "tag-purple")); %>

                                    <tr>

                                      <td style="font-weight:700;">

                                        <%= cls !=null ? "Class " + cls : "N/A" %>

                                      </td>

                                      <td>

                                        <%= totalS%>

                                      </td>

                                      <td>

                                        <%= app%>

                                      </td>

                                      <td style="color:var(--green);font-weight:700;">

                                        <%= pass%>

                                      </td>

                                      <td style="color:var(--red);font-weight:700;">

                                        <%= fail%>

                                      </td>

                                      <td style="font-family:'JetBrains Mono',monospace;font-weight:700;">

                                        <%= String.format("%.1f", avg)%>%

                                      </td>

                                      <td><span class="tag <%= highTag%>">

                                          <%= String.format("%.1f", high)%>%

                                        </span></td>

                                    </tr>

                                    <% } if(!hasResData) { %>

                                      <tr>

                                        <td colspan="7" style="text-align:center;padding:20px;color:var(--muted);">No
                                          results

                                          data available.</td>

                                      </tr>

                                      <% } } catch(Exception e) { e.printStackTrace(); } finally { if(connRes !=null)
                                        try { connRes.close(); } catch(Exception e) {} } %>

                                </tbody>

                              </table>

                            </div>

                          </div>

                        </div>

                        <!-- ═══ TIMETABLE ═══ -->

                        <div class="page" id="page-timetable">

                          <div class="pg-header">

                            <div class="pg-header-left">



                              <p>Classes aur sections ke liye timetable manage karein</p>

                            </div>

                            <button class="btn-accent" onclick="openAddTimetableModal()">

                              <i class="bi bi-calendar-plus-fill"></i> Naya Slot Add Karo

                            </button>

                          </div>

                          <div class="card-box">

                            <div class="card-head">

                              <i class="bi bi-table" style="color:var(--accent);"></i>

                              <h6>Weekly Schedule Overview</h6>

                              <div class="ms-auto d-flex gap-2">

                                <select id="ttDayFilter" class="form-select" style="width:130px; font-size:13px;"
                                  onchange="filterTimetable()">

                                  <option value="">All Days</option>

                                  <option value="Monday">Monday</option>

                                  <option value="Tuesday">Tuesday</option>

                                  <option value="Wednesday">Wednesday</option>

                                  <option value="Thursday">Thursday</option>

                                  <option value="Friday">Friday</option>

                                  <option value="Saturday">Saturday</option>

                                </select>

                              </div>

                            </div>

                            <div class="table-responsive">

                              <table class="table tbl mb-0" id="ttTable">

                                <thead>

                                  <tr>

                                    <th>Day</th>

                                    <th>Time Slot</th>

                                    <th>Subject</th>

                                    <th>Class</th>

                                    <th>Section</th>

                                    <th>Teacher</th>

                                    <th>Room</th>

                                    <th>Action</th>

                                  </tr>

                                </thead>

                                <tbody>

                                  <% Connection connTT=null; try { Class.forName("com.mysql.cj.jdbc.Driver");
                                    connTT=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root"
                                    , "" ); String
                                    ttSql="SELECT tt.*, t.name as teacher_name FROM timetable tt LEFT JOIN teachers t ON tt.teacher_id = t.teacher_id ORDER BY FIELD(day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'), start_time"
                                    ; ResultSet rsTT=connTT.createStatement().executeQuery(ttSql); boolean hasTT=false;
                                    while(rsTT.next()) { hasTT=true; String tid=rsTT.getString("tt_id"); String
                                    day=rsTT.getString("day"); String startTime=rsTT.getString("start_time"); String
                                    endTime=rsTT.getString("end_time"); String sub=rsTT.getString("subject"); String
                                    cls_=rsTT.getString("class"); String sec=rsTT.getString("section"); String
                                    tname=rsTT.getString("teacher_name"); String room=rsTT.getString("room"); %>

                                    <tr class="tt-row" data-day="<%= day%>">

                                      <td><span class="tag tag-blue">

                                          <%= day%>

                                        </span></td>

                                      <td><strong style="font-family:'JetBrains Mono';">

                                          <%= startTime%>
                                            <%= endTime%>

                                        </strong></td>

                                      <td><span style="font-weight:700;">

                                          <%= sub%>

                                        </span></td>

                                      <td>Class <%= cls_%>

                                      </td>

                                      <td>

                                        <%= sec%>

                                      </td>

                                      <td>

                                        <div class="d-flex align-items-center gap-2">

                                          <div class="av-sm" style="background:#f0fdf4; color:#16a34a;">

                                            <%= tname !=null ? tname.substring(0,1).toUpperCase() : "?" %>

                                          </div>

                                          <%= tname !=null ? tname : "Not Assigned" %>

                                        </div>

                                      </td>

                                      <td><span class="tag tag-purple">Room <%= room%></span></td>

                                      <td>

                                        <div class="d-flex gap-1">

                                          <button class="btn-icon del" onclick="deleteTimetable('<%= tid%>')"><i
                                              class="bi bi-trash-fill"></i></button>

                                        </div>

                                      </td>

                                    </tr>

                                    <% } if(!hasTT) { %>

                                      <tr>

                                        <td colspan="8" class="text-center py-5 text-muted">No timetable slots found.
                                          Click

                                          'Naya Slot Add Karo' to begin.</td>

                                      </tr>

                                      <% } } catch(Exception e) { e.printStackTrace(); } finally { if(connTT !=null) try
                                        { connTT.close(); } catch(Exception e) {} } %>

                                </tbody>

                              </table>

                            </div>

                          </div>

                        </div>

                        <!-- ═══ FEES ═══ -->
                        <!-- ═══ FEES ═══ -->

                        <div class="page" id="page-fees">

                          <div class="pg-header">

                            <div class="pg-header-left">



                              <p>Collections, pending aur transactions manage karo</p>

                            </div>

                            <div class="d-flex gap-2">

                              <a href="/exportFees" class="btn-outline" style="text-decoration:none;"><i
                                  class="bi bi-download"></i> Export</a>

                              <button class="btn-outline" onclick="window.location.href='feeStructure'"><i
                                  class="bi bi-pencil-square"></i> Monthly Fees Edit</button>

                              <button class="btn-accent" onclick="openAddPaymentModal()"><i class="bi bi-plus-lg"></i>
                                Payment

                                Add Karo</button>

                            </div>

                          </div>

                          <% double collectedThisMonth=0.0; double pendingTotal=0.0; int pendingStudentsCount=0; int
                            paymentsDoneThisMonth=0; double annualTarget=1500000.0; Connection connFees=null; try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            connFees=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root" , "" );
                            String
                            colSql="SELECT SUM(amount) FROM fees WHERE status='Paid' AND MONTH(payment_date) = MONTH(CURRENT_DATE()) AND YEAR(payment_date) = YEAR(CURRENT_DATE())"
                            ; ResultSet rsCol=connFees.createStatement().executeQuery(colSql); if(rsCol.next())
                            collectedThisMonth=rsCol.getDouble(1); String
                            paySql="SELECT COUNT(*) FROM fees WHERE status='Paid' AND MONTH(payment_date) = MONTH(CURRENT_DATE()) AND YEAR(payment_date) = YEAR(CURRENT_DATE())"
                            ; ResultSet rsPay=connFees.createStatement().executeQuery(paySql); if(rsPay.next())
                            paymentsDoneThisMonth=rsPay.getInt(1); 
/* Automatic Pending Calculation */ int totalStCount=0;
                            ResultSet rsSt=connFees.createStatement().executeQuery("SELECT COUNT(*) FROM students");
                            if(rsSt.next()) totalStCount=rsSt.getInt(1); pendingStudentsCount=totalStCount -
                            paymentsDoneThisMonth; double totalMonthlyExp=0; ResultSet
                            rsExp=connFees.createStatement().executeQuery("SELECT SUM(fs.monthly_fee) FROM students s JOIN fee_structure fs ON s.class=fs.class_name"); if(rsExp.next())
                            totalMonthlyExp=rsExp.getDouble(1); pendingTotal=totalMonthlyExp - collectedThisMonth;
                            if(pendingTotal < 0) pendingTotal=0; } catch(Exception e) { e.printStackTrace(); } finally {
                            if(connFees!=null) try{connFees.close();}catch(Exception e){} } String
                            fmtCollected=collectedThisMonth>= 100000 ? String.format("%.2fL", collectedThisMonth/100000)
                            : (collectedThisMonth >= 1000 ? String.format("%.1fK", collectedThisMonth/1000) :
                            String.valueOf((int)collectedThisMonth)); String fmtPending = pendingTotal >= 100000 ?
                            String.format("%.2fL", pendingTotal/100000) : (pendingTotal >= 1000 ? String.format("%.1fK",
                            pendingTotal/1000) : String.valueOf((int)pendingTotal)); String fmtTarget = annualTarget >=
                            100000 ? String.format("%.2fL", annualTarget/100000) : String.valueOf((int)annualTarget); %>

                            <div class="row g-3 mb-3">

                              <div class="col-12">

                                <div class="stat">

                                  <div class="stat-ico" style="background:#d1fae5;color:#059669;"><i
                                      class="bi bi-check-circle-fill"></i></div>

                                  <h3>

                                    <%= fmtCollected%>

                                  </h3>

                                  <p>Collected (₹)</p><span class="tag tag-green">This Month</span>

                                </div>

                              </div>

                              <div class="col-12">

                                <div class="stat">

                                  <div class="stat-ico" style="background:#fee2e2;color:#dc2626;"><i
                                      class="bi bi-exclamation-circle-fill"></i></div>

                                  <h3>

                                    <%= fmtPending%>

                                  </h3>

                                  <p>Pending (₹)</p><span class="tag tag-red">

                                    <%= pendingStudentsCount%> Students

                                  </span>

                                </div>

                              </div>

                              <div class="col-12">

                                <div class="stat">

                                  <div class="stat-ico" style="background:#ffedd5;color:#ea580c;"><i
                                      class="bi bi-cash-stack"></i></div>

                                  <h3>

                                    <%= fmtTarget%>

                                  </h3>

                                  <p>Annual Target (₹)</p>

                                </div>

                              </div>

                              <div class="col-12">

                                <div class="stat">

                                  <div class="stat-ico" style="background:#ede9fe;color:#7c3aed;"><i
                                      class="bi bi-receipt"></i></div>

                                  <h3>

                                    <%= paymentsDoneThisMonth%>

                                  </h3>

                                  <p>Payments Done</p><span class="tag tag-purple">This Month</span>

                                </div>

                              </div>

                            </div>

                            <div class="card-box">

                              <div class="card-head">

                                <h6>Recent Transactions</h6>

                                <div class="ms-auto">

                                  <select class="form-select" id="feeStatusFilter" onchange="filterFeeTable()"
                                    style="width:130px;font-size:12px;padding:6px 10px;border-radius:9px;">

                                    <option value="all">All Status</option>

                                    <option value="Paid">Paid</option>

                                    <option value="Pending">Pending</option>

                                  </select>

                                </div>

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

                                    <% Connection connFeesList=null; try {
                                      Class.forName("com.mysql.cj.jdbc.Driver"); connFeesList=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root"
                                      , "" ); String
                                      fSql="SELECT f.*, s.name as student_name, s.class, s.section FROM fees f JOIN students s ON f.student_id = s.student_id ORDER BY payment_date DESC LIMIT 20"
                                      ; ResultSet rsFees=connFeesList.createStatement().executeQuery(fSql); boolean
                                      hasFees=false; java.text.SimpleDateFormat outFmt=new java.text.SimpleDateFormat("d MMM yyyy"); java.text.SimpleDateFormat inFmt=new
                                      java.text.SimpleDateFormat("yyyy-MM-dd"); while(rsFees.next()) { hasFees=true;
                                      String txnId=rsFees.getString("transaction_id"); String
                                      sName=rsFees.getString("student_name"); String cls=rsFees.getString("class") + "-"
                                      + rsFees.getString("section"); double amt=rsFees.getDouble("amount"); String
                                      date=rsFees.getString("payment_date"); if(date !=null && !date.isEmpty()) { try {
                                      date=outFmt.format(inFmt.parse(date)); } catch(Exception e){} } else { date="N/A"
                                      ; } String status=rsFees.getString("status"); String statusTag="Paid"
                                      .equalsIgnoreCase(status) ? "tag-green" : "tag-red" ; %>

                                      <tr class="fee-row" data-status="<%= status%>">

                                        <td style="font-family:'JetBrains Mono',monospace;font-size:11px;">

                                          <%= txnId !=null ? txnId : "N/A" %>

                                        </td>

                                        <td>

                                          <%= sName%>

                                        </td>

                                        <td>

                                          <%= cls%>

                                        </td>

                                        <td style="font-weight:700;">₹<%= String.format("%,.0f", amt)%>

                                        </td>

                                        <td>

                                          <%= date%>

                                        </td>

                                        <td><span class="tag <%= statusTag%>">

                                            <%= status !=null ? status : "N/A" %>

                                          </span></td>

                                        <td>

                                          <% if("Paid".equalsIgnoreCase(status)) { %>

                                            <a href="/downloadReceipt?id=<%= rsFees.getInt("fee_id")%>"
                                              class="btn-icon"><i class="bi bi-receipt"></i></a>

                                            <% } else { %>

                                              <a href="/sendFeeReminder?id=<%= rsFees.getInt("fee_id")%>"

                                                class="btn-icon"><i class="bi bi-send-fill"></i></a>

                                              <% } %>

                                        </td>

                                      </tr>

                                      <% } if(!hasFees) { %>

                                        <tr>

                                          <td colspan="7" class="text-center py-4 text-muted">No fee records found.</td>

                                        </tr>

                                        <% } } catch(Exception e) { e.printStackTrace(); } finally { if(connFeesList
                                          !=null) try { connFeesList.close(); } catch(Exception e) {} } %>

                                  </tbody>

                                </table>

                              </div>

                            </div>

                        </div>

                        <!-- ═══ NOTICE BOARD ═══ -->

                        <div class="page" id="page-notices">

                          <div class="pg-header">

                            <div class="pg-header-left">



                              <p>Latest updates aur announcements publish karein</p>

                            </div>

                            <button class="btn-accent" onclick="window.openPublishNoticeModal(event)">

                              <i class="bi bi-megaphone-fill"></i> Naya Notice Public Karo

                            </button>

                          </div>

                          <div class="card-box">

                            <div class="card-head">

                              <i class="bi bi-bell-fill" style="color:var(--yellow);"></i>

                              <h6>Published Notices</h6>

                            </div>

                            <div class="table-responsive">

                              <table class="table tbl mb-0">

                                <thead>

                                  <tr>

                                    <th>Notice Details</th>

                                    <th>Target Audience</th>

                                    <th>Priority</th>

                                    <th>Published At</th>

                                    <th>Actions</th>

                                  </tr>

                                </thead>

                                <tbody>

                                  <% Connection connN=null; try {
                                    Class.forName("com.mysql.cj.jdbc.Driver"); connN=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root"
                                    , "" ); String nSql="SELECT * FROM notices ORDER BY published_at DESC" ; ResultSet
                                    rsN=connN.createStatement().executeQuery(nSql); boolean hasNotices=false;
                                    while(rsN.next()){ hasNotices=true; int nid=rsN.getInt("notice_id"); String
                                    nTitle=rsN.getString("title"); String nMsg=rsN.getString("message"); String
                                    nTarget=rsN.getString("target"); String nPriority=rsN.getString("priority");
                                    java.sql.Timestamp nTime=rsN.getTimestamp("published_at"); String targetTag="all"
                                    .equals(nTarget) ? "tag-blue" : ("students".equals(nTarget) ? "tag-purple"
                                    : "tag-orange" ); String priorityTag="urgent" .equals(nPriority) ? "tag-red" :
                                    ("important".equals(nPriority) ? "tag-yellow" : "tag-green" ); %>

                                    <tr>

                                      <td>

                                        <div style="font-weight:700;font-size:14px;">

                                          <%= nTitle%>

                                        </div>

                                        <div
                                          style="font-size:12px;color:var(--muted);max-width:400px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">

                                          <%= nMsg%>

                                        </div>

                                      </td>

                                      <td><span class="tag <%= targetTag%>">

                                          <%= nTarget.toUpperCase()%>

                                        </span></td>

                                      <td><span class="tag <%= priorityTag%>">

                                          <%= nPriority.toUpperCase()%>

                                        </span></td>

                                      <td style="font-size:12px;font-family:'JetBrains Mono',monospace;">

                                        <%= new java.text.SimpleDateFormat("dd MMM, hh:mm a").format(nTime)%>

                                      </td>

                                      <% String escapedNTitle=nTitle.replace("'", "&#39;" ); %>

                                        <td>

                                          <button class="btn-icon del"
                                            onclick="confirmDeleteNotice(<%= nid%>, '<%= escapedNTitle%>')">

                                            <i class="bi bi-trash-fill"></i>

                                          </button>

                                        </td>

                                    </tr>

                                    <% } if(!hasNotices) { %>

                                      <tr>

                                        <td colspan="5" style="text-align:center;padding:40px;color:var(--muted);">

                                          <i class="bi bi-info-circle"
                                            style="font-size:24px;display:block;margin-bottom:8px;"></i>

                                          Abhi koi notice published nahi hai.

                                        </td>

                                      </tr>

                                      <% } } catch(Exception e){ e.printStackTrace(); } finally { if(connN!=null)
                                        try{connN.close();}catch(Exception e){} } %>

                                </tbody>

                              </table>

                            </div>

                          </div>

                        </div>

                        <!-- ═══ REPORTS ═══ -->

                        <div class="page" id="page-reports">

                          <div class="pg-header">

                            <div class="pg-header-left">



                              <p>School performance aur data reports yahan dekho</p>

                            </div>

                            <button class="btn-outline"><i class="bi bi-download"></i> All Reports Export</button>

                          </div>

                          <div class="row g-3">

                            <div class="col-md-4">

                              <div class="card-box p-4 report-card">

                                <div class="stat-ico" style="background:#ffedd5;color:#ea580c;margin-bottom:14px;"><i
                                    class="bi bi-people-fill"></i></div>

                                <div style="font-weight:700;font-size:15px;margin-bottom:4px;">Student Enrollment Report
                                </div>

                                <div style="font-size:13px;color:var(--muted);margin-bottom:14px;">Class-wise enrollment
                                  aur

                                  growth

                                  data

                                </div>

                                <button class="btn-accent" style="padding:7px 16px;font-size:12px;"><i
                                    class="bi bi-download"></i>

                                  Download

                                  PDF</button>

                              </div>

                            </div>

                            <div class="col-md-4">

                              <div class="card-box p-4 report-card">

                                <div class="stat-ico" style="background:#d1fae5;color:#059669;margin-bottom:14px;"><i
                                    class="bi bi-calendar-check-fill"></i></div>

                                <div style="font-weight:700;font-size:15px;margin-bottom:4px;">Attendance Report</div>

                                <div style="font-size:13px;color:var(--muted);margin-bottom:14px;">Monthly aur annual

                                  attendance

                                  analysis

                                </div>

                                <button class="btn-accent" style="padding:7px 16px;font-size:12px;"><i
                                    class="bi bi-download"></i>

                                  Download

                                  PDF</button>

                              </div>

                            </div>

                            <div class="col-md-4">

                              <div class="card-box p-4 report-card">

                                <div class="stat-ico" style="background:#fef3c7;color:#d97706;margin-bottom:14px;"><i
                                    class="bi bi-cash-coin"></i></div>

                                <div style="font-weight:700;font-size:15px;margin-bottom:4px;">Fee Collection Report
                                </div>

                                <div style="font-size:13px;color:var(--muted);margin-bottom:14px;">Monthly fee
                                  collection aur

                                  pending

                                  analysis</div>

                                <button class="btn-accent" style="padding:7px 16px;font-size:12px;"><i
                                    class="bi bi-download"></i>

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

                                <div style="font-weight:700;font-size:15px;margin-bottom:4px;">Academic Performance
                                </div>

                                <div style="font-size:13px;color:var(--muted);margin-bottom:14px;">Exam results aur
                                  class

                                  average

                                  summary

                                </div>

                                <button class="btn-accent" style="padding:7px 16px;font-size:12px;"><i
                                    class="bi bi-download"></i>

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

                                <div style="font-size:13px;color:var(--muted);margin-bottom:14px;">Staff attendance aur
                                  class

                                  performance

                                  data</div>

                                <button class="btn-accent" style="padding:7px 16px;font-size:12px;"><i
                                    class="bi bi-download"></i>

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

                                <div style="font-size:13px;color:var(--muted);margin-bottom:14px;">Low attendance aur
                                  pending

                                  fee

                                  wale

                                  students</div>

                                <button class="btn-accent" style="padding:7px 16px;font-size:12px;"><i
                                    class="bi bi-download"></i>

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



                              <p>School aur system ki configurations</p>

                            </div>

                          </div>

                          <div class="row g-3">

                            <div class="col-12 col-md-7">

                              <form action="/saveSettings" method="post">

                                <div class="card-box mb-3">

                                  <div class="card-head"><i class="bi bi-building" style="color:var(--accent);"></i>

                                    <h6>School Information</h6>

                                  </div>

                                  <div class="card-body-p">

                                    <div class="row g-3">

                                      <div class="col-12">

                                        <label class="form-label">School Name</label>

                                        <input name="school_name" class="form-control" value="<%= schoolName%>"
                                          required />

                                      </div>

                                      <div class="col-6">

                                        <label class="form-label">Academic Year</label>

                                        <input name="academic_year" class="form-control" value="<%= academicYear%>"
                                          required />

                                      </div>

                                      <div class="col-6">

                                        <label class="form-label">School Code</label>

                                        <input name="school_code" class="form-control" value="<%= schoolCode%>"
                                          required />

                                      </div>

                                      <div class="col-6">

                                        <label class="form-label">Board</label>

                                        <select name="board" class="form-select">

                                          <option <%="CBSE" .equals(board) ? "selected" : "" %>>CBSE</option>

                                          <option <%="ICSE" .equals(board) ? "selected" : "" %>>ICSE</option>

                                          <option <%="State Board" .equals(board) ? "selected" : "" %>>State Board
                                          </option>

                                        </select>

                                      </div>

                                      <div class="col-6">

                                        <label class="form-label">Medium</label>

                                        <select name="medium" class="form-select">

                                          <option <%="English" .equals(medium) ? "selected" : "" %>>English</option>

                                          <option <%="Hindi" .equals(medium) ? "selected" : "" %>>Hindi</option>

                                          <option <%="Both" .equals(medium) ? "selected" : "" %>>Both</option>

                                        </select>

                                      </div>

                                      <div class="col-12">

                                        <label class="form-label">School Address</label>

                                        <input name="school_address" class="form-control" value="<%= schoolAddress%>"
                                          required />

                                      </div>

                                      <div class="col-12">

                                        <label class="form-label">Contact Email</label>

                                        <input name="contact_email" class="form-control" value="<%= contactEmail%>"
                                          required />

                                      </div>

                                      <div class="col-12">

                                        <button type="submit" class="btn-accent">

                                          <i class="bi bi-check-lg"></i> Settings Save Karo

                                        </button>

                                      </div>

                                    </div>

                                  </div>

                                </div>

                              </form>

                            </div>

                            <div class="col-12 col-md-5">

                              <form action="/changePassword" method="post">

                                <div class="card-box mb-3">

                                  <div class="card-head"><i class="bi bi-lock-fill" style="color:var(--red);"></i>

                                    <h6>Security Settings</h6>

                                  </div>

                                  <div class="card-body-p">

                                    <div class="row g-3">

                                      <div class="col-12">

                                        <label class="form-label">Current Password</label>

                                        <input name="current_password" class="form-control" type="password"
                                          placeholder="••••••••" required />

                                      </div>

                                      <div class="col-12">

                                        <label class="form-label">New Password</label>

                                        <input name="new_password" class="form-control" type="password"
                                          placeholder="••••••••" required />

                                      </div>

                                      <div class="col-12">

                                        <label class="form-label">Confirm Password</label>

                                        <input name="confirm_password" class="form-control" type="password"
                                          placeholder="••••••••" required />

                                      </div>

                                      <div class="col-12">

                                        <button type="submit" class="btn-accent"
                                          style="background:var(--red);box-shadow:none;">

                                          <i class="bi bi-key-fill"></i> Password Change Karo

                                        </button>

                                      </div>

                                    </div>

                                  </div>

                                </div>

                              </form>

                              <form action="/updateNotificationSettings" method="post">

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

                                      <div class="form-check form-switch mb-0">

                                        <input name="email_notifications" class="form-check-input" type="checkbox"
                                          <%=emailNotif ? "checked" : "" %> value="true"

                                        style="width:40px;height:20px;cursor:pointer;" onchange="this.form.submit()" />

                                      </div>

                                    </div>

                                    <div class="d-flex align-items-center justify-content-between">

                                      <div>

                                        <div style="font-size:13px;font-weight:600;">Low Attendance Alerts</div>

                                        <div style="font-size:12px;color:var(--muted);">Below 75% warning</div>

                                      </div>

                                      <div class="form-check form-switch mb-0">

                                        <input name="low_attendance_alerts" class="form-check-input" type="checkbox"
                                          <%=attendanceAlert ? "checked" : "" %> value="true"

                                        style="width:40px;height:20px;cursor:pointer;" onchange="this.form.submit()" />

                                      </div>

                                    </div>

                                  </div>

                                </div>

                              </form>

                            </div>

                          </div>

                        </div>

                        <!-- ═══ LEAVE MANAGEMENT ═══ -->
                        <!-- ═══ LEAVE MANAGEMENT ═══ -->

                        <div class="page" id="page-leavemgmt">

                          <div class="pg-header">

                            <div class="pg-header-left">



                              <p>Teachers ko leave assign karo aur applications manage karo</p>

                            </div>

                            <button class="btn-accent" onclick="openAssignLeaveModal()"><i class="bi bi-plus-lg"></i>
                              Leave

                              Assign

                              Karo</button>

                          </div>

                          <% int pendingCount=0; int approvedMonth=0; int onLeaveCount=0; int rejectedMonth=0;
                            Connection connL=null; try {
                            Class.forName("com.mysql.cj.jdbc.Driver"); connL=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root" , "" );
                            ResultSet rsP=connL.createStatement().executeQuery("SELECT COUNT(*) FROM leave_applications WHERE status='pending'"); 
                            if(rsP.next()) pendingCount = rsP.getInt(1); 
                            ResultSet rsA = connL.createStatement().executeQuery("SELECT COUNT(*) FROM leave_applications WHERE status='approved' AND MONTH(from_date)=MONTH(CURDATE()) AND YEAR(from_date)=YEAR(CURDATE())");
                            if(rsA.next()) approvedMonth=rsA.getInt(1); 
                            ResultSet rsO=connL.createStatement().executeQuery("SELECT COUNT(*) FROM leave_applications WHERE status='approved' AND CURDATE() BETWEEN from_date AND to_date"); 
                            if(rsO.next()) onLeaveCount=rsO.getInt(1); 
                            ResultSet rsR=connL.createStatement().executeQuery("SELECT COUNT(*) FROM leave_applications WHERE status='rejected' AND MONTH(from_date)=MONTH(CURDATE()) AND YEAR(from_date)=YEAR(CURDATE())");
                            if(rsR.next()) rejectedMonth=rsR.getInt(1); %>

                            <div class="row g-3 mb-4">

                              <div class="col-6 col-md-3">

                                <div class="stat">

                                  <div class="stat-ico" style="background:#fef3c7;color:#d97706;"><i
                                      class="bi bi-hourglass-split"></i></div>

                                  <h3>

                                    <%= pendingCount%>

                                  </h3>

                                  <p>Pending Requests</p><span class="tag tag-yellow">Awaiting</span>

                                </div>

                              </div>

                              <div class="col-6 col-md-3">

                                <div class="stat">

                                  <div class="stat-ico" style="background:#d1fae5;color:#059669;"><i
                                      class="bi bi-check-circle-fill"></i></div>

                                  <h3>

                                    <%= approvedMonth%>

                                  </h3>

                                  <p>Approved (<%= new java.text.SimpleDateFormat("MMMM").format(new java.util.Date())%>
                                      )</p>

                                  <span class="tag tag-green">This Month</span>

                                </div>

                              </div>

                              <div class="col-6 col-md-3">

                                <div class="stat">

                                  <div class="stat-ico" style="background:#dbeafe;color:#2563eb;"><i
                                      class="bi bi-people-fill"></i></div>

                                  <h3>

                                    <%= onLeaveCount%>

                                  </h3>

                                  <p>On Leave Today</p><span class="tag tag-blue">Out of Office</span>

                                </div>

                              </div>

                              <div class="col-6 col-md-3">

                                <div class="stat">

                                  <div class="stat-ico" style="background:#fee2e2;color:#dc2626;"><i
                                      class="bi bi-x-circle-fill"></i></div>

                                  <h3>

                                    <%= rejectedMonth%>

                                  </h3>

                                  <p>Rejected</p><span class="tag tag-red">This Month</span>

                                </div>

                              </div>

                            </div>

                            <div class="row g-3">

                              <!-- Pending Requests -->

                              <div class="col-12">

                                <div class="card-box">

                                  <div class="card-head"><i class="bi bi-hourglass-split"
                                      style="color:var(--yellow);"></i>

                                    <h6>Pending Leave Requests</h6>

                                    <% if(pendingCount> 0) { %><span class="ms-auto tag tag-yellow">

                                        <%= pendingCount%> Pending

                                      </span>

                                      <% } %>

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

                                      <tbody>

                                        <% String
                                          pendSql="SELECT la.*, t.name, t.department, t.subject FROM leave_applications la JOIN teachers t ON la.teacher_id = t.teacher_id WHERE la.status='pending' ORDER BY la.applied_at DESC"
                                          ; ResultSet rsPend=connL.createStatement().executeQuery(pendSql); boolean
                                          hasPending=false; while(rsPend.next()) { hasPending=true; String
                                          lid=rsPend.getString("leave_id"); String tname=rsPend.getString("name");
                                          String dept=rsPend.getString("department"); String
                                          ltype=rsPend.getString("leave_type"); String
                                          from=rsPend.getString("from_date"); String to=rsPend.getString("to_date"); int
                                          days=rsPend.getInt("days"); String reason=rsPend.getString("reason"); String
                                          applied=rsPend.getString("applied_at"); String
                                          initials = (tname != null && !tname.isEmpty()) ? (tname.split(" ").length > 1 ? (tname.split(" ")[0].substring(0,1) + tname.split(" ")[1].substring(0,1)).toUpperCase() : tname.substring(0, Math.min(2, tname.length())).toUpperCase()) : "??"; %>

                            <tr>

                              <td>

                                <div class=" d-flex align-items-center gap-2">

                                          <div class="av-sm" style="background:#d1fae5;color:#059669;">

                                            <%= initials%>

                                          </div>

                                          <div>

                                            <div style="font-weight:600;">

                                              <%= tname%>

                                            </div>

                                            <div style="font-size:11px;color:var(--muted);">

                                              <%= dept%>

                                            </div>

                                          </div>

                                  </div>

                                  </td>

                                  <td><span class="tag tag-yellow">

                                      <%= ltype%>

                                    </span></td>

                                  <td style="font-family:'JetBrains Mono',monospace;font-size:12px;">

                                    <%= from%>

                                  </td>

                                  <td style="font-family:'JetBrains Mono',monospace;font-size:12px;">

                                    <%= to%>

                                  </td>

                                  <td style="font-weight:700;font-family:'JetBrains Mono',monospace;">

                                    <%= days%>

                                  </td>

                                  <td style="max-width:160px;font-size:12px;">

                                    <%= reason%>

                                  </td>

                                  <td style="font-size:12px;color:var(--muted);">

                                    <%= applied%>

                                  </td>

                                  <td>

                                    <div class="d-flex gap-1">

                                      <form action="/approveLeave" method="post" style="display:inline;">

                                        <input type="hidden" name="id" value="<%= lid%>">

                                        <button type="submit" class="btn-accent"
                                          style="padding:5px 12px;font-size:12px;"><i class="bi bi-check-lg"></i>
                                          Approve</button>

                                      </form>

                                      <form action="/rejectLeave" method="post" style="display:inline;">

                                        <input type="hidden" name="id" value="<%= lid%>">

                                        <button type="submit" class="btn-icon"
                                          style="border-color:var(--red);color:var(--red);"><i
                                            class="bi bi-x-lg"></i></button>

                                      </form>

                                    </div>

                                  </td>

                                  </tr>

                                  <% } if(!hasPending) { %>

                                    <tr>

                                      <td colspan="8" style="text-align:center;padding:40px;color:var(--muted);">

                                        <i class="bi bi-check-circle-fill"
                                          style="font-size:28px;color:var(--green);display:block;margin-bottom:8px;"></i>

                                        Koi pending request nahi hai!

                                      </td>

                                    </tr>



                                    </tbody>

                                    </table>

                                </div>

                              </div>

                            </div>

                            <% } } catch(Exception e) { e.printStackTrace(); } finally { if(connL !=null) try {
                              connL.close(); } catch(Exception e) {} } %>

                              <div class="row g-3">
                                <!-- Teacher Leave Balance -->

                                <div class="col-12 col-lg-7">

                                  <div class="card-box">

                                    <div class="card-head"><i class="bi bi-calendar2-x-fill"
                                        style="color:var(--accent);"></i>

                                      <h6>Teacher-wise Leave Balance</h6><button class="btn-outline ms-auto"
                                        style="font-size:12px;padding:6px 12px;" onclick="openAssignBalanceModal()"><i
                                          class="bi bi-plus-lg"></i>

                                        Assign Balance</button>

                                    </div>

                                    <div class="table-responsive">

                                      <table class="table tbl mb-0">

                                        <thead>

                                          <tr>

                                            <th>Teacher</th>

                                            <th>Subject</th>

                                            <% Connection connLB=null; try {
                                              Class.forName("com.mysql.cj.jdbc.Driver"); connLB=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root"
                                              , "" ); String
                                              lbSql="SELECT t.name, t.subject, t.department, lb.* FROM teachers t JOIN leave_balance lb ON t.teacher_id = lb.teacher_id ORDER BY t.name ASC"
                                              ; ResultSet rsLB=connLB.createStatement().executeQuery(lbSql);
                                              while(rsLB.next()) { String tname=rsLB.getString("name"); String
                                              subj=rsLB.getString("subject"); if(subj==null || subj.isEmpty())
                                              subj=rsLB.getString("department"); int ct=rsLB.getInt("casual_total"); int
                                              mt=rsLB.getInt("medical_total"); int et=rsLB.getInt("earned_total"); int
                                              cu=rsLB.getInt("casual_used"); int mu=rsLB.getInt("medical_used"); int
                                              eu=rsLB.getInt("earned_used"); int totalUsed=cu + mu + eu; String
                                              initials="??" ; if(tname !=null && !tname.isEmpty()){ String[]
                                              p=tname.split(" "); 
                                          if(p.length > 1) initials = (p[0].substring(0,1) + p[1].substring(0,1)).toUpperCase(); 
                                          else initials = tname.substring(0, Math.min(2, tname.length())).toUpperCase(); 
                                        } 
                                        String[] colors = {" #ffedd5", "#d1fae5" , "#dbeafe" , "#ede9fe" , "#fee2e2" };
                                              String[] textColors={"#ea580c", "#059669" , "#2563eb" , "#7c3aed"
                                              , "#dc2626" }; int colorIdx=Math.abs(tname.hashCode()) % colors.length;
                                              int tid=rsLB.getInt("teacher_id"); %>

                                          <tr>

                                            <td>

                                              <div class="d-flex align-items-center gap-2">

                                                <div class="av-sm"
                                                  style="background-color:<%= colors[colorIdx]%>; color:<%= textColors[colorIdx]%>;">

                                                  <%= initials%>

                                                </div>

                                                <b>

                                                  <%= tname%>

                                                </b>

                                              </div>

                                            </td>

                                            <td style="font-size:12px;color:var(--muted);">

                                              <%= subj%>

                                            </td>

                                            <td
                                              style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#d97706;">

                                              <%= ct%>

                                            </td>
                                            <td
                                              style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#2563eb;">
                                              <%= mt %>
                                            </td>

                                            <td
                                              style="font-weight:700;font-family:'JetBrains Mono',monospace;color:#7c3aed;">

                                              <%= et %>

                                            </td>

                                            </td>

                                            <td
                                              style="font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--red);">

                                              <%= totalUsed %>

                                            </td>

                                            <% String escapedTName=(tname !=null) ? tname.replace("'", "\\'" ) : "" ; %>
                                              <td><button class="btn-icon"
                                                  onclick="openEditLeaveModal(<%= tid %>, '<%= escapedTName %>', <%= ct %>, <%= mt %>, <%= et %>)"><i
                                                    class="bi bi-pencil-fill"></i></button></td>

                                          </tr>

                                          <% } } catch(Exception e) { e.printStackTrace(); } finally { if(connLB !=null)
                                            try { connLB.close(); } catch(Exception e) {} } %>

                                            </tbody>

                                      </table>

                                    </div>

                                  </div>

                                </div>

                                <!-- Leave History -->

                                <div class="col-12 col-lg-5">

                                  <div class="card-box">

                                    <div class="card-head"><i class="bi bi-clock-history"
                                        style="color:var(--muted);"></i>

                                      <h6>Recent Leave History</h6>

                                    </div>

                                    <div class="card-body-p" id="leave-history-list">

                                      <% Connection connLH=null; try {
                                        Class.forName("com.mysql.cj.jdbc.Driver"); connLH=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root"
                                        , "" ); String
                                        lhSql="SELECT la.*, t.name FROM leave_applications la JOIN teachers t ON la.teacher_id = t.teacher_id ORDER BY la.applied_at DESC LIMIT 6"
                                        ; ResultSet rsLH=connLH.createStatement().executeQuery(lhSql); boolean
                                        hasHistory=false; while(rsLH.next()) { hasHistory=true; String
                                        tname=rsLH.getString("name"); String ltype=rsLH.getString("leave_type"); String
                                        lhStatus=rsLH.getString("status"); String fromDate=rsLH.getString("from_date");
                                        String toDate=rsLH.getString("to_date"); int days=rsLH.getInt("days"); String
                                        statusClass=lhStatus.equalsIgnoreCase("approved") ? "tag-green" :
                                        (lhStatus.equalsIgnoreCase("pending") ? "tag-yellow" : "tag-red" ); String
                                        iconClass=lhStatus.equalsIgnoreCase("approved") ? "bi-check-circle-fill" :
                                        (lhStatus.equalsIgnoreCase("pending") ? "bi-clock-fill" : "bi-x-circle-fill" );
                                        String iconBg=lhStatus.equalsIgnoreCase("approved") ? "#d1fae5" :
                                        (lhStatus.equalsIgnoreCase("pending") ? "#fef3c7" : "#fee2e2" ); String
                                        iconColor=lhStatus.equalsIgnoreCase("approved") ? "#059669" :
                                        (lhStatus.equalsIgnoreCase("pending") ? "#d97706" : "#dc2626" ); String
                                        historyIconStyle="width:40px; height:40px; border-radius:11px; background-color:"
                                        + iconBg + "; color:" + iconColor
                                        + "; display:flex; align-items:center; justify-content:center; font-size:17px; flex-shrink:0;"
                                        ; %>
                                        <div
                                          style="display:flex;align-items:center;gap:12px;padding:11px 0;border-bottom:1px solid var(--border);">
                                          <div style="<%= historyIconStyle%>">
                                            <i class="bi <%= iconClass%>"></i>
                                          </div>
                                          <div style="flex:1;">
                                            <div style="font-size:13px;font-weight:600;">
                                              <%= tname%>
                                                <%= ltype%>
                                            </div>
                                            <div style="font-size:12px;color:var(--muted);">
                                              <%= fromDate%>
                                                <%= fromDate.equals(toDate) ? "" : "–" + toDate %> (<%= days %> day<%=
                                                      days> 1 ? "s" : "" %>)
                                            </div>
                                          </div>
                                          <span class="tag <%= statusClass%>">
                                            <%= lhStatus.substring(0,1).toUpperCase() + lhStatus.substring(1) %>
                                          </span>
                                        </div>
                                        <% } if(!hasHistory) { %>
                                          <div style="padding:20px;text-align:center;color:var(--muted);">No leave
                                            history found.</div>
                                          <% } } catch(Exception e) { e.printStackTrace(); } finally { if(connLH !=null)
                                            try { connLH.close(); } catch(Exception e) {} } %>

                                    </div>

                                  </div>

                                </div>

                                <!-- On Leave Today -->

                                <div class="col-12">

                                  <div class="card-box">

                                    <% int onLeaveTodayCount=0; Connection connOL=null; try {
                                      Class.forName("com.mysql.cj.jdbc.Driver"); connOL=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root"
                                      , "" ); ResultSet rsOLC=connOL.createStatement().executeQuery("SELECT COUNT(*) FROM leave_applications WHERE status='approved' AND CURDATE() BETWEEN from_date AND to_date"); if(rsOLC.next()) onLeaveTodayCount=rsOLC.getInt(1);
                                      %>

                                      <div class="card-head"><i class="bi bi-person-x-fill"
                                          style="color:var(--red);"></i>

                                        <h6>Aaj Leave Pe Hain (<%= onLeaveTodayCount%> Teacher<%= onLeaveTodayCount !=1
                                              ? "s" : "" %>)</h6>

                                        <span class="ms-auto" style="font-size:12px;color:var(--muted);">

                                          <%= new java.text.SimpleDateFormat("EEEE, d MMMM yyyy").format(new
                                            java.util.Date())%>

                                        </span>

                                      </div>

                                      <div class="card-body-p">

                                        <div class="row g-3">

                                          <% String
                                            olSql="SELECT la.*, t.name, t.department FROM leave_applications la JOIN teachers t ON la.teacher_id = t.teacher_id WHERE la.status='approved' AND CURDATE() BETWEEN la.from_date AND la.to_date"
                                            ; ResultSet rsOL=connOL.createStatement().executeQuery(olSql); boolean
                                            anyOnLeave=false; while(rsOL.next()) { anyOnLeave=true; String
                                            tname=rsOL.getString("name"); String ltype=rsOL.getString("leave_type");
                                            String from=rsOL.getString("from_date"); String
                                            to=rsOL.getString("to_date");
                                            String initials = (tname != null && !tname.isEmpty()) ? (tname.split(" ").length > 1 ? (tname.split(" ")[0].substring(0,1) + tname.split(" ")[1].substring(0,1)).toUpperCase() : tname.substring(0, Math.min(2, tname.length())).toUpperCase()) : "??"; %>

                          <div class=" col-12 col-md-4">

                                            <div
                                              style="background:#fff5f5;border:1.5px solid #fecaca;border-radius:14px;padding:16px;display:flex;align-items:center;gap:12px;">

                                              <div class="av-sm"
                                                style="background:#fee2e2;color:#dc2626;width:44px;height:44px;border-radius:12px;font-size:14px;font-weight:700;">

                                                <%= initials%>

                                              </div>

                                              <div>

                                                <div style="font-weight:700;font-size:14px;">

                                                  <%= tname%>

                                                </div>

                                                <div style="font-size:12px;color:var(--red);font-weight:600;">

                                                  <%= ltype%>

                                                </div>

                                                <div style="font-size:11px;color:var(--muted);">

                                                  <%= from%>

                                                    <%= from.equals(to) ? "" : " se " + to%>

                                                </div>

                                              </div>

                                            </div>

                                        </div>

                                        <% } if(!anyOnLeave) { %>

                                          <div class="col-12"
                                            style="text-align:center;padding:20px;color:var(--muted);">

                                            <i class="bi bi-emoji-smile"
                                              style="font-size:24px;display:block;margin-bottom:5px;"></i>

                                            Aaj sabhi teachers present hain!

                                          </div>

                                          <% } } catch(Exception e) { e.printStackTrace(); } finally { if(connOL !=null)
                                            try { connOL.close(); } catch(Exception e) {} } %>

                                      </div>

                                  </div>

                                </div>

                              </div>
                        </div>

                      </div>

                      </div>

                      </div>

                      <!-- ASSIGN LEAVE MODAL -->

                      <div class="modal-backdrop-custom" id="assignLeaveModal" style="display:none;"
                        onclick="closeAssignLeaveOutside(event)">

                        <div class="edit-modal" style="max-width:520px;">

                          <div class="edit-modal-head">

                            <h5><i class="bi bi-calendar2-x-fill me-2" style="color:var(--accent);"></i>Teacher ko Leave

                              Assign

                              Karo</h5>

                            <button class="modal-close" onclick="closeAssignLeaveModal()">✕</button>

                          </div>

                          <div class="edit-modal-body">

                            <form action="/assignLeave" method="post" id="assignLeaveForm">

                              <div class="row g-3">

                                <div class="col-12">

                                  <label class="form-label">Teacher Select Karo</label>

                                  <select class="form-select" name="teacher_id" id="al-teacher" required>

                                    <option value="">-- Teacher chuniye --</option>

                                    <% Connection connT=null; try {
                                      Class.forName("com.mysql.cj.jdbc.Driver"); connT=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root"
                                      , "" ); ResultSet rsT=connT.createStatement().executeQuery("SELECT teacher_id, name, subject,  department FROM teachers WHERE status='active' ORDER BY name ASC"); while(rsT.next()) { String tid=rsT.getString("teacher_id"); String
                                      tname=rsT.getString("name"); String tsubj=rsT.getString("subject"); if(tsubj==null
                                      || tsubj.isEmpty()) tsubj=rsT.getString("department"); %>

                                      <option value="<%= tid%>">

                                        <%= tname %>
                                          <%= tsubj %>

                                      </option>

                                      <% } } catch(Exception e) {} finally { if(connT !=null) try { connT.close(); }
                                        catch(Exception e) {} } %>

                                  </select>

                                </div>

                                <div class="col-12">

                                  <label class="form-label">Leave Type</label>

                                  <input type="hidden" name="leave_type" id="al-leave-type" value="Casual">

                                  <div class="row g-2">

                                    <div class="col-6 col-md-3">

                                      <div class="ltype-assign-btn active-ltype" onclick="selectLT(this, 'Casual')"
                                        style="border:1.5px solid var(--accent);background:rgba(249,115,22,.08);border-radius:11px;padding:12px;text-align:center;cursor:pointer;transition:all .18s;">

                                        <i class="bi bi-sun-fill"
                                          style="font-size:20px;color:#d97706;display:block;margin-bottom:4px;"></i>

                                        <span style="font-size:12px;font-weight:600;">Casual</span>

                                      </div>

                                    </div>

                                    <div class="col-6 col-md-3">

                                      <div class="ltype-assign-btn" onclick="selectLT(this, 'Medical')"
                                        style="border:1.5px solid var(--border);border-radius:11px;padding:12px;text-align:center;cursor:pointer;transition:all .18s;">

                                        <i class="bi bi-hospital-fill"
                                          style="font-size:20px;color:#2563eb;display:block;margin-bottom:4px;"></i>

                                        <span style="font-size:12px;font-weight:600;">Medical</span>

                                      </div>

                                    </div>

                                    <div class="col-6 col-md-3">

                                      <div class="ltype-assign-btn" onclick="selectLT(this, 'Earned')"
                                        style="border:1.5px solid var(--border);border-radius:11px;padding:12px;text-align:center;cursor:pointer;transition:all .18s;">

                                        <i class="bi bi-award-fill"
                                          style="font-size:20px;color:#7c3aed;display:block;margin-bottom:4px;"></i>

                                        <span style="font-size:12px;font-weight:600;">Earned</span>

                                      </div>

                                    </div>

                                    <div class="col-6 col-md-3">

                                      <div class="ltype-assign-btn" onclick="selectLT(this, 'Special')"
                                        style="border:1.5px solid var(--border);border-radius:11px;padding:12px;text-align:center;cursor:pointer;transition:all .18s;">

                                        <i class="bi bi-house-heart-fill"
                                          style="font-size:20px;color:#ec4899;display:block;margin-bottom:4px;"></i>

                                        <span style="font-size:12px;font-weight:600;">Special</span>

                                      </div>

                                    </div>

                                  </div>

                                </div>

                                <div class="col-6"><label class="form-label">Start Date</label><input
                                    class="form-control" type="date" name="from_date" id="al-from" required /></div>

                                <div class="col-6"><label class="form-label">End Date</label><input class="form-control"
                                    type="date" name="to_date" id="al-to" required /></div>

                                <div class="col-12"><label class="form-label">Reason</label><textarea
                                    class="form-control" name="reason" id="al-reason" rows="3"
                                    placeholder="Reason likhein (Medical emergency, Official duty, etc.)"
                                    required></textarea>

                                </div>

                                <div class="col-12">

                                  <label class="form-label">Status</label>

                                  <select class="form-select" name="status" id="al-status">

                                    <option value="approved">Direct Approve</option>

                                    <option value="pending">Pending Rakhein</option>

                                  </select>

                                </div>

                                <div class="col-12 d-flex gap-2 pt-1">

                                  <button type="submit" class="save-btn"><i class="bi bi-check-lg me-1"></i>Leave Assign

                                    Karo</button>

                                  <button type="button" onclick="closeAssignLeaveModal()"
                                    style="background:var(--bg);border:1.5px solid var(--border);border-radius:11px;padding:12px 20px;font-size:14px;font-weight:600;cursor:pointer;font-family:inherit;">Cancel</button>

                                </div>

                              </div>

                            </form>

                          </div>

                        </div>

                      </div>

                      <!-- ASSIGN LEAVE BALANCE MODAL -->

                      <div class="modal-backdrop-custom" id="assignBalanceModal" style="display:none;"
                        onclick="closeAssignBalanceOutside(event)">

                        <div class="edit-modal" style="max-width:480px;">

                          <div class="edit-modal-head">

                            <h5><i class="bi bi-plus-circle-fill me-2" style="color:var(--accent);"></i>Teacher ko Leave

                              Balance

                              Assign Karo</h5>

                            <button class="modal-close" onclick="closeAssignBalanceModal()">✕</button>

                          </div>

                          <div class="edit-modal-body">

                            <form action="/updateLeaveBalance" method="post">

                              <div class="row g-3">

                                <div class="col-12">

                                  <label class="form-label">Teacher Select Karo</label>

                                  <select class="form-select" name="teacher_id" required>

                                    <option value="">-- Teacher chuniye --</option>

                                    <% Connection connT2=null; try {
                                      Class.forName("com.mysql.cj.jdbc.Driver"); connT2=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root"
                                      , "" ); ResultSet rsT2=connT2.createStatement().executeQuery("SELECT teacher_id, name FROM  teachers WHERE status='active' AND teacher_id NOT IN (SELECT teacher_id FROM  leave_balance) ORDER BY name ASC"); while(rsT2.next()) { %>

                                      <option value="<%= rsT2.getString("teacher_id")%>"><%= rsT2.getString("name")%>

                                      </option>

                                      <% } } catch(Exception e) {} finally { if(connT2 !=null) try { connT2.close(); }
                                        catch(Exception e) {} } %>

                                  </select>

                                </div>

                                <div class="col-4"><label class="form-label">Casual</label><input class="form-control"
                                    name="casual_total" type="number" value="12" min="0" required /></div>

                                <div class="col-4"><label class="form-label">Medical</label><input class="form-control"
                                    name="medical_total" type="number" value="10" min="0" required /></div>

                                <div class="col-4"><label class="form-label">Earned</label><input class="form-control"
                                    name="earned_total" type="number" value="15" min="0" required /></div>

                                <div class="col-12 d-flex gap-2 pt-1">

                                  <button type="submit" class="save-btn"><i class="bi bi-check-lg me-1"></i>Assign

                                    Karo</button>

                                  <button type="button" onclick="closeAssignBalanceModal()"
                                    style="background:var(--bg);border:1.5px solid var(--border);border-radius:11px;padding:12px 20px;font-size:14px;font-weight:600;cursor:pointer;font-family:inherit;">Cancel</button>

                                </div>

                              </div>

                            </form>

                          </div>

                        </div>

                      </div>

                      <!-- EDIT LEAVE BALANCE MODAL -->

                      <div class="modal-backdrop-custom" id="editLeaveModal" style="display:none;"
                        onclick="closeEditLeaveOutside(event)">

                        <div class="edit-modal" style="max-width:420px;">

                          <div class="edit-modal-head">

                            <h5><i class="bi bi-pencil-fill me-2" style="color:var(--accent);"></i>Leave Balance Edit
                              Karo

                            </h5>

                            <button class="modal-close" onclick="closeEditLeaveModal()">✕</button>

                          </div>

                          <div class="edit-modal-body">

                            <form action="/updateLeaveBalance" method="post">

                              <input type="hidden" name="teacher_id" id="el-teacher-id">

                              <div
                                style="background:var(--bg);border-radius:12px;padding:13px;margin-bottom:18px;font-size:13px;font-weight:600;">

                                Teacher: <span id="el-teacher-name" style="color:var(--accent);">—</span></div>

                              <div class="row g-3">

                                <div class="col-4"><label class="form-label">Casual Leave</label><input
                                    class="form-control" type="number" name="casual_total" id="el-casual" min="0"
                                    max="30" /></div>

                                <div class="col-4"><label class="form-label">Medical Leave</label><input
                                    class="form-control" type="number" name="medical_total" id="el-medical" min="0"
                                    max="30" /></div>

                                <div class="col-4"><label class="form-label">Earned Leave</label><input
                                    class="form-control" type="number" name="earned_total" id="el-earned" min="0"
                                    max="30" /></div>

                                <div class="col-12 d-flex gap-2 pt-1">

                                  <button type="submit" class="save-btn"><i class="bi bi-check-lg me-1"></i>Save
                                    Karo</button>

                                  <button type="button" onclick="closeEditLeaveModal()"
                                    style="background:var(--bg);border:1.5px solid var(--border);border-radius:11px;padding:12px 20px;font-size:14px;font-weight:600;cursor:pointer;font-family:inherit;">Cancel</button>

                                </div>

                              </div>

                            </form>

                          </div>

                        </div>

                      </div>

                      <!-- ═══ ADD STUDENT MODAL ═══ -->

                      <div class="modal-backdrop-custom" id="addStudentModal" style="display:none;"
                        onclick="closeAddStudentOutside(event)">

                        <div class="edit-modal" style="max-width:500px;">

                          <div class="edit-modal-head" style="border-radius:18px 18px 0 0;">

                            <h5><i class="bi bi-person-plus-fill me-2" style="color:var(--accent);"></i>Add New Student
                            </h5>

                            <button class="modal-close" onclick="closeAddStudentModal()">✕</button>

                          </div>

                          <div class="edit-modal-body" style="padding:24px;">

                            <form action="AddStudentServlet" method="post">

                              <div class="row g-3">

                                <div class="col-12"><label class="form-label">Student Full Name</label><input
                                    name="name" class="form-control" placeholder="Enter Full Name" required /></div>

                                <div class="col-6"><label class="form-label">Email ID</label><input name="email"
                                    type="email" class="form-control" placeholder="school_id@example.com" required />
                                </div>

                                <div class="col-6"><label class="form-label">Login Password</label><input
                                    name="password" type="password" class="form-control" placeholder="Create Password"
                                    required /></div>

                                <div class="col-4"><label class="form-label">Class</label><input name="class"
                                    class="form-control" placeholder="e.g. 10" required /></div>

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

                      <div class="modal-backdrop-custom" id="editModal" style="display:none;"
                        onclick="closeEditModalOutside(event)">

                        <div class="edit-modal">

                          <div class="edit-modal-head">

                            <h5><i class="bi bi-pencil-fill me-2" style="color:var(--accent);"></i>Profile Edit Karo
                            </h5>

                            <button class="modal-close" onclick="closeEditModal()">✕</button>

                          </div>

                          <form action="UpdateProfileServlet" method="post" enctype="multipart/form-data">

                            <div class="avatar-upload-area">

                              <div class="upload-preview">

                                <img
                                  src='<%= adPhotoBase64 != null ? "data:image/jpeg;base64," + adPhotoBase64                          : "images/user_default_photo.webp"%>'
                                  style="width:100%;height:100%;object-fit:cover;border-radius:12px;"
                                  id="modal-photo-preview" />

                              </div>

                              <div>

                                <div style="font-weight:700;font-size:14px;margin-bottom:4px;">Profile Photo</div>

                                <div style="font-size:12px;color:var(--muted);margin-bottom:10px;">JPG, PNG. Max 2MB
                                </div>

                                <button type="button" class="upload-btn"
                                  onclick="document.getElementById('avatar-input-modal').click()">

                                  <i class="bi bi-cloud-upload-fill"></i> Photo Upload Karo

                                </button>

                                <input type="file" name="photo" id="avatar-input-modal" accept="image/*"
                                  style="display:none" onchange="previewImage(this)" />

                              </div>

                            </div>

                            <div class="row g-3">

                              <div class="col-6"><label class="form-label">Full Name</label><input name="name"
                                  class="form-control" value="<%= adName%>" /></div>

                              <div class="col-6"><label class="form-label">Date of Birth</label><input name="dob"
                                  class="form-control" type="date" value="<%= adDob%>" /></div>

                              <div class="col-6"><label class="form-label">Gender</label><select name="gender"
                                  class="form-select">

                                  <option value="Male" <%="Male" .equals(adGender) ? "selected" : "" %>>Male</option>

                                  <option value="Female" <%="Female" .equals(adGender) ? "selected" : "" %>>Female
                                  </option>

                                  <option value="Other" <%="Other" .equals(adGender) ? "selected" : "" %>>Other</option>

                                </select></div>

                              <div class="col-6"><label class="form-label">Blood Group</label><select name="blood_group"
                                  class="form-select">

                                  <option value="A+" <%="A+" .equals(adBlood) ? "selected" : "" %>>A+</option>

                                  <option value="A-" <%="A-" .equals(adBlood) ? "selected" : "" %>>A-</option>

                                  <option value="B+" <%="B+" .equals(adBlood) ? "selected" : "" %>>B+</option>

                                  <option value="B-" <%="B-" .equals(adBlood) ? "selected" : "" %>>B-</option>

                                  <option value="O+" <%="O+" .equals(adBlood) ? "selected" : "" %>>O+</option>

                                  <option value="O-" <%="O-" .equals(adBlood) ? "selected" : "" %>>O-</option>

                                  <option value="AB+" <%="AB+" .equals(adBlood) ? "selected" : "" %>>AB+</option>

                                  <option value="AB-" <%="AB-" .equals(adBlood) ? "selected" : "" %>>AB-</option>

                                </select></div>

                              <div class="col-6"><label class="form-label">Phone Number</label><input name="phone"
                                  class="form-control" value="<%= adPhone%>" /></div>

                              <div class="col-6"><label class="form-label">Email</label><input name="email"
                                  class="form-control" value="<%= adEmail%>" /></div>

                              <div class="col-6"><label class="form-label">Subject</label><input name="subject"
                                  class="form-control" value="<%= adSubject%>" /></div>

                              <div class="col-6"><label class="form-label">Qualification</label><input
                                  name="qualification" class="form-control" value="<%= adQual%>" /></div>

                              <div class="col-6"><label class="form-label">Experience</label><input name="experience"
                                  class="form-control" value="<%= adExp%>" /></div>

                              <div class="col-6"><label class="form-label">Designation/Dept</label><input
                                  name="department" class="form-control" value="<%= adDept%>" /></div>

                              <div class="col-12"><label class="form-label">Address</label><input name="address"
                                  class="form-control" value="<%= adAddress%>" /></div>

                              <div class="col-6"><label class="form-label">Employee ID</label><input name="employee_id"
                                  class="form-control" value="<%= adEmpId%>" /></div>

                              <div class="col-6"><label class="form-label">Joined On</label><input name="joined_on"
                                  type="date" class="form-control" value="<%= adJoined%>" /></div>

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

                      <script data-cfasync="false"
                        src="/cdn-cgi/scripts/5c5dd728/cloudflare-static/email-decode.min.js"></script>

                      <script
                        src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>

                      <script>

                        // --- GLOBAL SCOPE INITIALIZATION ---

                        // All interactive controller functions are explicitly attached to 'window' 

                        // to bypass potential scope isolation issues in fragmented script blocks.

                        window.openPublishNoticeModal = function (e, studentId, studentName) {

                          console.log('Opening Publish Notice Modal...', studentId);

                          if (e && e.preventDefault) { e.preventDefault(); e.stopPropagation(); }

                          const el = document.getElementById('publishNoticeModal');

                          if (el) {

                            const idInput = document.getElementById('notice-student-id');

                            const infoBox = document.getElementById('notice-specific-student');

                            const nameSpan = document.getElementById('notice-student-name');

                            if (studentId) {

                              idInput.value = studentId;

                              nameSpan.textContent = studentName;

                              infoBox.style.display = 'block';

                            } else {

                              idInput.value = '';

                              infoBox.style.display = 'none';

                            }

                            el.style.display = 'flex';

                            setTimeout(function () { el.classList.add('show'); }, 10);

                          }

                          document.body.style.overflow = 'hidden';

                        };

                        window.closePublishNoticeModal = function () {

                          const el = document.getElementById('publishNoticeModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () {

                              el.style.display = 'none';

                              const idInput = document.getElementById('notice-student-id');

                              const infoBox = document.getElementById('notice-specific-student');

                              if (idInput) idInput.value = '';

                              if (infoBox) infoBox.style.display = 'none';

                            }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        window.confirmDeleteNotice = function (id, title) {

                          const el = document.getElementById('deleteNoticeModal');

                          if (el) {

                            document.getElementById('delNoticeId').value = id;

                            document.getElementById('delNoticeTitle').textContent = title;

                            el.style.display = 'flex';

                            setTimeout(function () { el.classList.add('show'); }, 10);

                          }

                          document.body.style.overflow = 'hidden';

                        };

                        window.closeDeleteNoticeModal = function () {

                          const el = document.getElementById('deleteNoticeModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () { el.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        window.openMarkAttendanceModal = function () {

                          const el = document.getElementById('markAttendanceModal');

                          if (el) {

                            el.style.display = 'flex';

                            setTimeout(function () { el.classList.add('show'); }, 10);

                          }

                          document.body.style.overflow = 'hidden';

                        };

                        window.closeMarkAttendanceModal = function () {

                          const el = document.getElementById('markAttendanceModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () { el.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        const pageTitles = {

                          dashboard: 'Dashboard', profile: 'My Profile', students: 'Students Management',

                          teachers: 'Teachers Management', leavemgmt: 'Leave Management',

                          attendance: 'Attendance', results: 'Results & Grades',

                          timetable: 'Timetable Management', fees: 'Fee Management', notices: 'Notice Board',

                          reports: 'Reports', settings: 'Settings'

                        };

                        window.showPage = function (name, el) {
                          console.log('--- showPage called for:', name);
                          try {
                            const targetPage = document.getElementById('page-' + name);
                            if (!targetPage) {
                              console.error('Page element not found: page-' + name);
                              return;
                            }

                            const allPages = document.querySelectorAll('.page');
                            console.log('Found', allPages.length, 'page elements.');
                            allPages.forEach(p => {
                              p.style.display = 'none';
                              p.classList.remove('active');
                            });

                            targetPage.style.display = 'block';
                            targetPage.classList.add('active');
                            console.log('Activated page:', targetPage.id, 'Display:', targetPage.style.display);

                            const pageTitles = {
                              dashboard: 'Dashboard Overview',
                              profile: 'My Profile',
                              students: 'Student Management',
                              teachers: 'Teacher Management',
                              attendance: 'Attendance Management',
                              results: 'Results & Performance',
                              timetable: 'Timetable Management',
                              fees: 'Fee Management',
                              notices: 'Notice Board',
                              reports: 'System Reports',
                              settings: 'System Settings',
                              leavemgmt: 'Leave Management'
                            };

                            const titleEl = document.getElementById('page-title');
                            if (titleEl) titleEl.textContent = pageTitles[name] || name;

                            document.querySelectorAll('.s-nav-link').forEach(l => l.classList.remove('active'));
                            if (el && el.classList.contains('s-nav-link')) {
                              el.classList.add('active');
                            } else {
                              const allLinks = document.querySelectorAll('.s-nav-link');
                              for (let link of allLinks) {
                                if ((link.getAttribute('onclick') || '').includes("'" + name + "'")) {
                                  link.classList.add('active');
                                  break;
                                }
                              }
                            }
                            const sidebar = document.getElementById('sidebar');
                            if (sidebar) sidebar.classList.remove('open');
                            localStorage.setItem('activeAdminPage', name);

                            // Close all active modals on page switch
                            document.querySelectorAll('.modal-backdrop-custom').forEach(m => {
                              m.style.display = 'none';
                              m.classList.remove('show');
                            });
                            document.body.style.overflow = '';

                            try {
                              const url = new URL(window.location);
                              url.searchParams.set('page', name);
                              window.history.pushState({}, '', url);
                            } catch (e) { }
                          } catch (err) { console.error('showPage Error:', err); }
                        };

                        window.toggleSidebar = function () {

                          document.getElementById('sidebar').classList.toggle('open');

                        };

                        window.openEditModal = function () {

                          const el = document.getElementById('editModal');

                          if (el) {

                            el.style.display = 'flex';

                            setTimeout(function () { el.classList.add('show'); }, 10);

                          }

                          document.body.style.overflow = 'hidden';

                        };

                        window.closeEditModal = function () {

                          const modal = document.getElementById('editModal');

                          if (modal) {

                            modal.classList.remove('show');

                            setTimeout(function () { modal.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        window.previewImage = function (input) {

                          if (input.files && input.files[0]) {

                            const reader = new FileReader();

                            reader.onload = function (e) {

                              const preview = document.getElementById('modal-photo-preview');

                              if (preview) preview.src = e.target.result;

                            }

                            reader.readAsDataURL(input.files[0]);

                          }

                        };

                        // ─── LEAVE MANAGEMENT FUNCTIONS ───

                        window.openAssignLeaveModal = function () {

                          const el = document.getElementById('assignLeaveModal');

                          if (el) {

                            el.style.display = 'flex';

                            setTimeout(function () { el.classList.add('show'); }, 10);

                          }

                          document.body.style.overflow = 'hidden';

                        };

                        window.closeAssignLeaveModal = function () {

                          const el = document.getElementById('assignLeaveModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () { el.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        window.openEditLeaveModal = function (id, name, casual, medical, earned) {

                          document.getElementById('el-teacher-id').value = id;

                          document.getElementById('el-teacher-name').textContent = name;

                          document.getElementById('el-casual').value = casual;

                          document.getElementById('el-medical').value = medical;

                          document.getElementById('el-earned').value = earned;

                          const el = document.getElementById('editLeaveModal');

                          if (el) {

                            el.style.display = 'flex';

                            setTimeout(function () { el.classList.add('show'); }, 10);

                          }

                          document.body.style.overflow = 'hidden';

                        };

                        window.closeEditLeaveModal = function () {

                          const el = document.getElementById('editLeaveModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () { el.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        window.openAssignBalanceModal = function () {

                          const el = document.getElementById('assignBalanceModal');

                          if (el) {

                            el.style.display = 'flex';

                            setTimeout(function () { el.classList.add('show'); }, 10);

                          }

                          document.body.style.overflow = 'hidden';

                        };

                        window.closeAssignBalanceModal = function () {

                          const el = document.getElementById('assignBalanceModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () { el.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        window.selectLT = function (el, type) {

                          document.getElementById('al-leave-type').value = type;

                          el.closest('.row').querySelectorAll('.ltype-assign-btn').forEach(function (b) {

                            b.style.border = '1.5px solid var(--border)';

                            b.style.background = '';

                          });

                          el.style.border = '1.5px solid var(--accent)';

                          el.style.background = 'rgba(249,115,22,.08)';

                        };

                        window.approveLeave = function (rowId) {

                          const row = document.getElementById(rowId);

                          if (row) row.remove();

                          const tbody = document.getElementById('pending-tbody');

                          if (tbody && tbody.children.length === 0) {

                            const noPending = document.getElementById('no-pending');

                            if (noPending) noPending.style.display = 'block';

                          }

                          window.showAdminToast('Leave approve ho gayi! ✓');

                        };

                        window.rejectLeave = function (rowId) {

                          const row = document.getElementById(rowId);

                          if (row) row.remove();

                          const tbody = document.getElementById('pending-tbody');

                          if (tbody && tbody.children.length === 0) {

                            const noPending = document.getElementById('no-pending');

                            if (noPending) noPending.style.display = 'block';

                          }

                          window.showAdminToast('Leave reject kar di gayi.');

                        };

                        window.showAdminToast = function (msg, isErr) {

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

                          requestAnimationFrame(function () { t.style.opacity = '1'; t.style.transform = 'translateX(-50%) translateY(0)'; });

                          setTimeout(function () { t.style.opacity = '0'; t.style.transform = 'translateX(-50%) translateY(20px)'; setTimeout(function () { t.remove(); }, 300); }, 2600);

                        };

                        window.handleAvatarChange = function (input) {

                          if (input.files && input.files[0]) {

                            const reader = new FileReader();

                            reader.onload = function (e) {

                              const ids = ['sidebar-photo', 'profile-photo', 'modal-photo-preview'];

                              ids.forEach(function (id) {

                                const el = document.getElementById(id);

                                if (el) el.src = e.target.result;

                              });
                            };

                            reader.readAsDataURL(input.files[0]);

                          }

                        };

                        // --- STUDENT MANAGEMENT FUNCTIONS ---

                        window.openAddStudentModal = function () {

                          console.log('Opening Add Student Modal...');

                          const el = document.getElementById('addStudentModal');

                          if (el) {

                            el.style.display = 'flex';

                            setTimeout(function () { el.classList.add('show'); }, 10);

                          }

                          document.body.style.overflow = 'hidden';

                        };

                        window.closeAddStudentModal = function () {

                          const el = document.getElementById('addStudentModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () { el.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        window.applyStudentFilters = function () {

                          const searchInput = document.getElementById('studentSearchInput');

                          const classFilter = document.getElementById('classFilterSelect');

                          if (!searchInput || !classFilter) return;

                          const query = searchInput.value.toLowerCase().trim();

                          const selectedClass = classFilter.value;

                          const rows = document.querySelectorAll('.student-row');

                          const noRow = document.getElementById('noStudentRow');

                          classFilter.style.borderColor = selectedClass ? 'var(--accent)' : '';

                          classFilter.style.fontWeight = selectedClass ? '700' : '';

                          let visibleCount = 0;

                          rows.forEach(function (row) {

                            const name = row.getAttribute('data-name') || '';

                            const email = row.getAttribute('data-email') || '';

                            const roll = row.getAttribute('data-roll') || '';

                            const cls = row.getAttribute('data-class') || '';

                            const matchesSearch = !query || name.includes(query) || email.includes(query) || roll.includes(query) || cls.includes(query);

                            const matchesClass = !selectedClass || cls === selectedClass;

                            if (matchesSearch && matchesClass) {

                              row.style.display = '';

                              visibleCount++;

                              if (query) {

                                window.highlightText(row.querySelector('.search-name'), query);

                                window.highlightText(row.querySelector('.search-email'), query);

                                window.highlightText(row.querySelector('.search-roll'), query);

                                window.highlightText(row.querySelector('.search-class'), query);

                              } else {

                                window.removeHighlight(row);

                              }

                            } else {

                              row.style.display = 'none';

                            }

                          });

                          if (noRow) noRow.style.display = (visibleCount === 0) ? '' : 'none';

                        };

                        window.highlightText = function (el, query) {

                          if (!el) return;

                          const originalText = el.innerText;

                          // Escape regex to prevent crashes

                          const escapedQuery = query.replace(/[.*+?^\x24\x7B\x7D()|[\]\\]/g, '$&');

                          const regex = new RegExp('(' + escapedQuery + ')', 'gi');

                          el.innerHTML = originalText.replace(regex, '<mark style="background:#fef08a;border-radius:3px;padding:0 2px;">$1</mark>');

                        };

                        window.removeHighlight = function (row) {

                          row.querySelectorAll('.search-name, .search-email, .search-roll, .search-class').forEach(function (el) {

                            el.innerHTML = el.innerText;

                          });

                        };

                        window.exportTeachersToCSV = function () {

                          const rows = document.querySelectorAll('#page-teachers .teacher-row');

                          let csv = ['"S.No","Name","Email","Employee Id","Subject","Department","Experience","Status"'];

                          let serial = 1;

                          rows.forEach(function (row) {

                            if (row.style.display === 'none') return;

                            const name = row.getAttribute('data-name-val') || '';

                            const email = row.getAttribute('data-email-val') || '';

                            const empid = row.getAttribute('data-empid-val') || '';

                            const subj = row.getAttribute('data-subject-val') || '';

                            const dept = row.getAttribute('data-dept-val') || '';

                            const exp = row.getAttribute('data-exp-val') || '';

                            const status = row.getAttribute('data-status') || '';

                            csv.push('"' + serial + '","' + name + '","' + email + '","	' + empid + '","' + subj + '","' + dept + '","' + exp + '","' + status + '"');

                            serial++;

                          });

                          const BOM = '\uFEFF';

                          const blob = new Blob([BOM + csv.join('\n')], { type: 'text/csv;charset=utf-8;' });

                          const link = document.createElement('a');

                          link.download = 'Teachers_List.csv';

                          link.href = window.URL.createObjectURL(blob);

                          link.style.display = 'none';

                          document.body.appendChild(link);

                          link.click();

                          document.body.removeChild(link);

                        };

                        window.deleteTimetable = function (id) {

                          if (confirm('Kya aap pakka is timetable slot ko delete karna chahte hain?')) {

                            window.location.href = '/deleteTimetable?id=' + id;

                          }

                        };

                        window.openAddTimetableModal = function () {

                          console.log('Opening Timetable Modal...');

                          const el = document.getElementById('addTimetableModal');

                          if (el) {

                            el.style.display = 'flex';

                            setTimeout(function () { el.classList.add('show'); }, 10);

                          }

                          document.body.style.overflow = 'hidden';

                        };

                        window.closeAddTimetableModal = function () {

                          const el = document.getElementById('addTimetableModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () { el.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        window.filterTimetable = function () {

                          const day = document.getElementById('ttDayFilter').value;

                          const rows = document.querySelectorAll('.tt-row');

                          rows.forEach(function (row) {

                            if (!day || row.getAttribute('data-day') === day) {

                              row.style.display = '';

                            } else {

                              row.style.display = 'none';

                            }

                          });

                        };

                        window.openAddTeacherModal = function () {

                          console.log('Opening Add Teacher Modal...');

                          const el = document.getElementById('addTeacherModal');

                          if (el) {

                            el.style.display = 'flex';

                            setTimeout(function () { el.classList.add('show'); }, 10);

                          }

                          document.body.style.overflow = 'hidden';

                        };

                        window.closeAddTeacherModal = function () {

                          const el = document.getElementById('addTeacherModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () { el.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        window.openEditTeacherModal = function (id, name, email, empid, subject, dept, exp, status) {

                          console.log('Opening Edit Teacher Modal for ID:', id);

                          // Close any open student modal first to prevent overlap
                          var sModal = document.getElementById('editStudentModal');
                          if (sModal) { sModal.classList.remove('show'); sModal.style.display = 'none'; }

                          document.getElementById('editTeacherId').value = id || '';
                          document.getElementById('editTeacherName').value = name || '';
                          document.getElementById('editTeacherEmail').value = email || '';
                          document.getElementById('editTeacherEmpId').value = empid || '';
                          document.getElementById('editTeacherSubject').value = subject || '';
                          document.getElementById('editTeacherDept').value = dept || '';
                          document.getElementById('editTeacherExp').value = exp || '';
                          document.getElementById('editTeacherStatus').value = (status === 'Active') ? 'Active' : ((status === 'On Leave') ? 'On Leave' : 'Inactive');

                          var el = document.getElementById('editTeacherModal');
                          if (el) {
                            el.style.display = 'flex';
                            setTimeout(function () { el.classList.add('show'); }, 10);
                          }
                          document.body.style.overflow = 'hidden';

                        };

                        window.closeEditTeacherModal = function () {

                          const el = document.getElementById('editTeacherModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () { el.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        window.confirmDeleteTeacher = function (id, name) {

                          console.log('Opening Delete Teacher Modal for:', name);

                          document.getElementById('delTeacherId').value = id;

                          document.getElementById('delTeacherName').innerText = name;

                          const el = document.getElementById('deleteTeacherModal');

                          if (el) {

                            el.style.display = 'flex';

                            setTimeout(function () { el.classList.add('show'); }, 10);

                          }

                          document.body.style.overflow = 'hidden';

                        };

                        window.closeDeleteTeacherModal = function () {

                          const el = document.getElementById('deleteTeacherModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () { el.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        window.exportStudentsToExcel = function () {
                          const table = document.querySelector("#page-students table") || document.querySelector(".table");
                          const rows = table ? table.querySelectorAll("tr.student-row") : document.querySelectorAll(".student-row");

                          let csv = ['"S.No","Name","Email","Roll No.","Class","Attendance","Fees Status","Status"'];

                          let serial = 1;

                          rows.forEach(function (row) {
                            if (row.style.display === 'none') return;
                            const name = row.getAttribute('data-name-val') || '';
                            const email = row.getAttribute('data-email-val') || '';
                            const roll = row.getAttribute('data-roll-val') || '';
                            const cls = row.getAttribute('data-class-val') || '';
                            const att = row.getAttribute('data-att') || '';
                            const fees = row.getAttribute('data-fees') || '';
                            const status = row.getAttribute('data-status') || '';
                            // Prepend \t to force Excel to treat roll as text
                            csv.push('"' + serial + '","' + name + '","' + email + '","\t' + roll + '","' + cls + '","' + att + '","' + fees + '","' + status + '"');
                            serial++;
                          });

                          const BOM = '\uFEFF';

                          const csvFile = new Blob([BOM + csv.join('\n')], { type: 'text/csv;charset=utf-8;' });

                          const downloadLink = document.createElement('a');

                          downloadLink.download = 'Students_List.csv';

                          downloadLink.href = window.URL.createObjectURL(csvFile);

                          downloadLink.style.display = 'none';

                          document.body.appendChild(downloadLink);

                          downloadLink.click();

                          document.body.removeChild(downloadLink);

                          window.showAdminToast('CSV Export ho gaya! ✓');

                        };

                        window.confirmDeleteStudent = function (id, name) {

                          if (confirm("Kya aap pakka '" + name + "' ko delete karna chahte hain?")) {

                            window.location.href = 'deleteStudent?id=' + id;

                          }

                        };

                        window.openEditStudentModal = function (id, name, email, roll, cls, section) {

                          console.log('Opening Edit Student Modal for ID:', id);

                          // Close any open teacher modal first to prevent overlap
                          var tModal = document.getElementById('editTeacherModal');
                          if (tModal) { tModal.classList.remove('show'); tModal.style.display = 'none'; }

                          document.getElementById('edit-sid').value = id || '';
                          document.getElementById('edit-name').value = name || '';
                          document.getElementById('edit-email').value = email || '';
                          document.getElementById('edit-roll').value = roll || '';
                          document.getElementById('edit-class').value = cls || '';
                          document.getElementById('edit-section').value = section || '';

                          var el = document.getElementById('editStudentModal');
                          if (el) {
                            el.style.display = 'flex';
                            setTimeout(function () { el.classList.add('show'); }, 10);
                          }
                          document.body.style.overflow = 'hidden';

                        };

                        window.closeEditStudentModal = function () {

                          const el = document.getElementById('editStudentModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () { el.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        window.updateDynamicDates = function () {

                          const today = new Date();

                          const shortFmt = today.toLocaleDateString('en-GB', { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' });

                          const longFmt = today.toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });

                          const topbar = document.getElementById('topbar-date');

                          if (topbar) topbar.innerText = shortFmt;

                          const dash = document.getElementById('dash-date');

                          if (dash) dash.innerText = longFmt;

                        };

                        window.openAddPaymentModal = function () {

                          const el = document.getElementById('addPaymentModal');

                          if (el) {

                            el.style.display = 'flex';

                            setTimeout(function () { el.classList.add('show'); }, 10);

                          }

                          document.body.style.overflow = 'hidden';

                        };

                        window.closeAddPaymentModal = function () {

                          const el = document.getElementById('addPaymentModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () { el.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        window.openWorkingDaysModal = function () {

                          const el = document.getElementById('editWorkingDaysModal');

                          if (el) {

                            el.style.display = 'flex';

                            setTimeout(function () { el.classList.add('show'); }, 10);

                          }

                          document.body.style.overflow = 'hidden';

                        };

                        window.closeWorkingDaysModal = function () {

                          const el = document.getElementById('editWorkingDaysModal');

                          if (el) {

                            el.classList.remove('show');

                            setTimeout(function () { el.style.display = 'none'; }, 300);

                          }

                          document.body.style.overflow = '';

                        };

                        // --- EVENT LISTENERS ---

                        window.addEventListener('load', function () {
                          // Browser Back/Forward Disable Logic
                          history.pushState(null, null, location.href);
                          window.onpopstate = function () {
                            history.go(1);
                          };

                          console.log('Admin Dashboard JS Loaded');

                          window.updateDynamicDates();

                          const urlParams = new URLSearchParams(window.location.search);

                          const page = urlParams.get('page');

                          const isErr = urlParams.get('error');

                          if (urlParams.get('success')) {

                            let m = "Kaam safal raha! ✓";

                            if (page === 'teachers') m = "Naya teacher add ho gaya! ✓";

                            if (page === 'timetable') m = "Naya timetable slot add ho gaya! ✓";

                            if (urlParams.get('success') === 'results_uploaded') m = "Results successfully upload ho gaye! 🎓";

                            window.showAdminToast(m, isErr);

                          } else if (urlParams.get('deleted')) {

                            let m = "Data successfully delete ho gaya! ✓";

                            if (page === 'teachers') m = "Teacher record delete ho gaya! ✓";

                            if (page === 'timetable') m = "Timetable slot delete ho gaya! ✓";

                            window.showAdminToast(m, isErr);

                          } else if (urlParams.get('updated')) {

                            let m = "Information update ho gayi! ✓";

                            window.showAdminToast(m, isErr);

                          } else if (isErr) {

                            let m = "Kuch galat ho gaya! Dobara try karein.";

                            if (isErr === 'wrong_current_password') m = "Galti: Purana password galat hai!";

                            if (isErr === 'password_mismatch') m = "Galti: Naye passwords match nahi kar rahe!";

                            window.showAdminToast(m, true);

                          }

                          const isAction = urlParams.get('success') || urlParams.get('updated') || urlParams.get('deleted');
                          if (page && isAction) {
                            window.showPage(page);
                          } else {
                            // Default to dashboard on first login/load unless it's a redirect from an action
                            window.showPage('dashboard');
                          }

                        });

                        // Close modals when clicking outside

                        window.addEventListener('click', function (e) {

                          const modals = [

                            { id: 'addTeacherModal', close: window.closeAddTeacherModal },

                            { id: 'editTeacherModal', close: window.closeEditTeacherModal },

                            { id: 'deleteTeacherModal', close: window.closeDeleteTeacherModal },

                            { id: 'addTimetableModal', close: window.closeAddTimetableModal },

                            { id: 'publishNoticeModal', close: window.closePublishNoticeModal },

                            { id: 'deleteNoticeModal', close: window.closeDeleteNoticeModal },

                            { id: 'addStudentModal', close: window.closeAddStudentModal },

                            { id: 'editStudentModal', close: window.closeEditStudentModal },

                            { id: 'editModal', close: window.closeEditModal },

                            { id: 'assignLeaveModal', close: window.closeAssignLeaveModal },

                            { id: 'editLeaveModal', close: window.closeEditLeaveModal },

                            { id: 'assignBalanceModal', close: window.closeAssignBalanceModal },

                            { id: 'editWorkingDaysModal', close: window.closeWorkingDaysModal },

                            { id: 'addPaymentModal', close: window.closeAddPaymentModal },

                            { id: 'markAttendanceModal', close: window.closeMarkAttendanceModal }

                          ];

                          modals.forEach(function (m) {

                            const el = document.getElementById(m.id);

                            if (e.target === el) m.close();

                          });

                        });

                      </script>

                      <!-- ═══ EDIT STUDENT MODAL ═══ -->

                      <div class="modal-backdrop-custom" id="editStudentModal" style="display:none;"
                        onclick="if(event.target===this) window.closeEditStudentModal()">

                        <div class="edit-modal" style="max-width:500px;">

                          <div class="edit-modal-head" style="border-radius:18px 18px 0 0;">

                            <h5><i class="bi bi-pencil-fill me-2" style="color:var(--accent);"></i>Edit Student</h5>

                            <button class="modal-close" onclick="window.closeEditStudentModal()">✕</button>

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

                              </div>

                              <div class="edit-modal-footer d-flex gap-2 mt-4 border-top pt-3">

                                <button type="submit" class="save-btn" style="flex:1;"><i
                                    class="bi bi-check-lg me-1"></i>Update

                                  Student Details</button>

                                <button type="button" class="btn-icon" onclick="window.closeEditStudentModal()"
                                  style="width:auto; height:auto; padding:12px 20px; border-radius:11px; background:var(--bg); border:1.5px solid var(--border); font-weight:600;">Cancel</button>

                              </div>

                            </form>

                          </div>

                        </div>

                      </div>

                      <!-- ═══════ ADD TEACHER MODAL ═══════ -->

                      <div class="modal-backdrop-custom" id="addTeacherModal" style="display:none;"
                        onclick="if(event.target===this) window.closeAddTeacherModal()">

                        <div class="edit-modal" style="max-width:550px;">

                          <div class="edit-modal-head">

                            <h5><i class="bi bi-person-plus-fill me-2" style="color:var(--accent);"></i> Add New Teacher
                            </h5>

                            <button class="modal-close" onclick="window.closeAddTeacherModal()">✕</button>

                          </div>

                          <form action="addTeacher" method="post">

                            <div class="edit-modal-body">

                              <div class="row g-3">

                                <div class="col-md-6">

                                  <label class="form-label">Full Name</label>

                                  <input type="text" name="name" class="form-control" required
                                    placeholder="e.g. Rahul Sharma" />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Email Address</label>

                                  <input type="email" name="email" class="form-control" required
                                    placeholder="name@school.com" />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Password</label>

                                  <input type="password" name="password" class="form-control" required
                                    placeholder="Login password" />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Employee ID</label>

                                  <input type="text" name="employee_id" class="form-control" required
                                    placeholder="EMP-XXX" />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Subject</label>

                                  <input type="text" name="subject" class="form-control" required
                                    placeholder="e.g. Mathematics" />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Department</label>

                                  <input type="text" name="department" class="form-control" required
                                    placeholder="e.g. Class 9, 10" />

                                </div>

                                <div class="col-md-12">

                                  <label class="form-label">Experience (Years)</label>

                                  <input type="text" name="experience" class="form-control" placeholder="e.g. 5 yrs" />

                                </div>

                              </div>

                            </div>

                            <div class="edit-modal-footer d-flex gap-2 p-3 border-top">

                              <button type="submit" class="save-btn" style="flex:1;"><i
                                  class="bi bi-check-lg me-1"></i>Save

                                Teacher</button>

                              <button type="button" class="btn-icon" onclick="window.closeAddTeacherModal()"
                                style="width:auto; height:auto; padding:12px 20px; border-radius:11px; background:var(--bg); border:1.5px solid var(--border); font-weight:600;">Cancel</button>

                            </div>

                          </form>

                        </div>

                      </div>

                      <!-- ═══════ EDIT TEACHER MODAL ═══════ -->

                      <div class="modal-backdrop-custom" id="editTeacherModal" style="display:none;"
                        onclick="if(event.target===this) window.closeEditTeacherModal()">

                        <div class="edit-modal" style="max-width:550px;">

                          <div class="edit-modal-head">

                            <h5><i class="bi bi-pencil-square me-2" style="color:var(--blue);"></i> Edit Teacher Details
                            </h5>

                            <button class="modal-close" onclick="window.closeEditTeacherModal()">✕</button>

                          </div>

                          <form action="editTeacher" method="post">

                            <input type="hidden" name="teacher_id" id="editTeacherId" />

                            <div class="edit-modal-body">

                              <div class="row g-3">

                                <div class="col-md-6">

                                  <label class="form-label">Full Name</label>

                                  <input type="text" name="name" id="editTeacherName" class="form-control" required />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Email Address</label>

                                  <input type="email" name="email" id="editTeacherEmail" class="form-control"
                                    required />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Employee ID</label>

                                  <input type="text" name="employee_id" id="editTeacherEmpId" class="form-control"
                                    required />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Subject</label>

                                  <input type="text" name="subject" id="editTeacherSubject" class="form-control"
                                    required />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Department</label>

                                  <input type="text" name="department" id="editTeacherDept" class="form-control"
                                    required />

                                </div>

                                <div class="col-md-6">

                                  <label class="form-label">Experience</label>

                                  <input type="text" name="experience" id="editTeacherExp" class="form-control" />

                                </div>

                                <div class="col-md-12">

                                  <label class="form-label">Status</label>

                                  <select name="status" id="editTeacherStatus" class="form-select">

                                    <option value="Active">Active</option>

                                    <option value="On Leave">On Leave</option>

                                    <option value="Inactive">Inactive</option>

                                  </select>

                                </div>

                              </div>

                            </div>

                            <div class="edit-modal-footer d-flex gap-2 p-3 border-top">

                              <button type="submit" class="save-btn" style="background:var(--blue); flex:1;"><i
                                  class="bi bi-check-lg me-1"></i>Update Details</button>

                              <button type="button" class="btn-icon" onclick="window.closeEditTeacherModal()"
                                style="width:auto; height:auto; padding:12px 20px; border-radius:11px; background:var(--bg); border:1.5px solid var(--border); font-weight:600;">Cancel</button>

                            </div>

                          </form>

                        </div>

                      </div>

                      <!-- ═══════ DELETE TEACHER MODAL ═══════ -->

                      <div class="modal-backdrop-custom" id="deleteTeacherModal" style="display:none;"
                        onclick="if(event.target===this) window.closeDeleteTeacherModal()">

                        <div class="edit-modal" style="max-width:400px;text-align:center; padding:30px;">

                          <div style="font-size:48px;color:var(--red);margin-bottom:15px;"><i
                              class="bi bi-exclamation-circle-fill"></i></div>

                          <h5 style="font-weight:700; margin-bottom:10px;">Are you sure?</h5>

                          <p style="color:var(--muted);font-size:14px;margin-bottom:25px;">

                            You are about to delete <span id="delTeacherName"
                              style="font-weight:700;color:var(--dark);"></span>.<br>This action cannot be undone.

                          </p>

                          <form action="deleteTeacher" method="get">

                            <input type="hidden" name="id" id="delTeacherId" />

                            <div class="d-flex gap-2 justify-content-center">

                              <button type="submit" class="save-btn"
                                style="background:var(--red); padding:10px 24px;">Yes,

                                Delete</button>

                              <button type="button" class="btn-icon" onclick="window.closeDeleteTeacherModal()"
                                style="width:auto; height:auto; padding:10px 24px; border-radius:11px; background:var(--bg); border:1.5px solid var(--border); font-weight:600;">Cancel</button>

                            </div>

                          </form>

                        </div>


                        <!-- ═══════ DELETE NOTICE MODAL ═══════ -->

                        <div class="modal-backdrop-custom" id="deleteNoticeModal" style="display:none;"
                          onclick="if(event.target===this) closeDeleteNoticeModal()">

                          <div class="edit-modal" style="max-width:400px;text-align:center; padding:30px;">

                            <div style="font-size:48px;color:var(--red);margin-bottom:15px;"><i
                                class="bi bi-trash-fill"></i>

                            </div>

                            <h5 style="font-weight:700; margin-bottom:10px;">Notice Delete Karein?</h5>

                            <p style="color:var(--muted);font-size:14px;margin-bottom:25px;">

                              Kya aap <span id="delNoticeTitle" style="font-weight:700;color:var(--dark);"></span> ko
                              delete

                              karna

                              chahte hain?<br>Ye action irreversible hai.

                            </p>

                            <form action="/deleteNotice" method="get">

                              <input type="hidden" name="id" id="delNoticeId" />

                              <div class="d-flex gap-2 justify-content-center">

                                <button type="submit" class="save-btn"
                                  style="background:var(--red); padding:10px 24px;">Haan,

                                  Delete Karo</button>

                                <button type="button" class="btn-icon" onclick="closeDeleteNoticeModal()"
                                  style="width:auto; height:auto; padding:10px 24px; border-radius:11px; background:var(--bg); border:1.5px solid var(--border); font-weight:600;">Cancel</button>

                              </div>

                            </form>

                          </div>

                        </div>

                        <!-- ═══════ MARK ATTENDANCE SELECTION MODAL ═══════ -->

                        <div class="modal-backdrop-custom" id="markAttendanceModal"
                          style="z-index: 9999; display: none;"
                          onclick="if(event.target===this) closeMarkAttendanceModal()">

                          <div class="edit-modal" style="max-width:450px;">

                            <div class="edit-modal-head">

                              <h5><i class="bi bi-clipboard-check-fill me-2" style="color:var(--accent);"></i>
                                Attendance

                                Selection

                              </h5>

                              <button class="modal-close" onclick="closeMarkAttendanceModal()">✕</button>

                            </div>

                            <form action="/markAttendance" method="get">

                              <div class="edit-modal-body">

                                <div class="row g-3">

                                  <div class="col-md-12">

                                    <label class="form-label">Select Class</label>

                                    <select name="class" class="form-select" required>

                                      <option value="">-- Class chuniye --</option>

                                      <option value="1">Class 1</option>

                                      <option value="2">Class 2</option>

                                      <option value="3">Class 3</option>

                                      <option value="4">Class 4</option>

                                      <option value="5">Class 5</option>

                                      <option value="6">Class 6</option>

                                      <option value="7">Class 7</option>

                                      <option value="8">Class 8</option>

                                      <option value="9">Class 9</option>

                                      <option value="10">Class 10</option>

                                      <option value="11">Class 11</option>

                                      <option value="12">Class 12</option>

                                    </select>

                                  </div>

                                  <div class="col-md-12">

                                    <label class="form-label">Select Section</label>

                                    <select name="section" class="form-select" required>

                                      <option value="A">Section A</option>

                                      <option value="B">Section B</option>

                                      <option value="C">Section C</option>

                                      <option value="D">Section D</option>

                                    </select>

                                  </div>

                                  <div class="col-md-12">

                                    <label class="form-label">Select Teacher</label>

                                    <select name="teacher_id" class="form-select" required>

                                      <option value="">-- Teacher chuniye --</option>

                                      <% Connection connAtT=null; try {
                                        Class.forName("com.mysql.cj.jdbc.Driver"); connAtT=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root"
                                        , "" ); ResultSet rsAtT=connAtT.createStatement().executeQuery("SELECT teacher_id, name FROM teachers WHERE status='active' ORDER BY name ASC");
                                        while(rsAtT.next()) { %>

                                        <option value="<%= rsAtT.getString("teacher_id")%>"><%=
                                            rsAtT.getString("name")%>

                                        </option>

                                        <% } } catch(Exception e) {} finally { if(connAtT !=null) try { connAtT.close();
                                          } catch(Exception e) {} } %>

                                    </select>

                                  </div>

                                </div>

                              </div>

                              <div class="edit-modal-footer d-flex gap-2 p-3"
                                style="border-top:1.5px solid var(--border); background:#f8fafc; border-radius: 0 0 20px 20px;">

                                <button type="submit" class="save-btn" style="flex:1;"><i
                                    class="bi bi-arrow-right-circle-fill me-1"></i> Proceed to Mark</button>

                                <button type="button" class="btn-icon" onclick="closeMarkAttendanceModal()"
                                  style="width:auto; height:auto; padding:10px 24px; border-radius:11px; background:white; border:1.5px solid var(--border); font-weight:600;">Cancel</button>

                              </div>

                            </form>

                          </div>

                        </div>

                        <script>

                          function filterFeeTable() {

                            const filter = document.getElementById('feeStatusFilter').value;

                            const rows = document.querySelectorAll('.fee-row');

                            rows.forEach(row => {

                              if (filter === 'all' || row.getAttribute('data-status').toLowerCase() === filter.toLowerCase()) {

                                row.style.display = '';

                              } else {

                                row.style.display = 'none';

                              }

                            });

                          }

                        </script>


                      </div>

                    </body>

                    </html>