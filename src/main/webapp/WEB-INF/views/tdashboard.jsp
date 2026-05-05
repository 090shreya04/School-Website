<%@ page import="java.sql.*, java.util.*" %>
    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
        <% 
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
            if (session==null || session.getAttribute("user_id")==null) { response.sendRedirect("/signin"); return; } 
            Object userId=session.getAttribute("user_id"); String tName="Teacher" ; String tSubject="Subject Teacher" ;
            String tInitials="T" ; String tPhotoBase64=null; String tId="", tDob="" , tGender="" , tBlood="" , tPhone="" ,
            tEmail="" , tAddress="" , tDept="" , tEmpId="" , tQual="" , tExp="" , tJoined="" ; Connection conn=null;
            PreparedStatement pstmt=null; ResultSet rs=null; try { Class.forName("com.mysql.cj.jdbc.Driver");
            conn=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root" , "" ); String
            sql="SELECT u.name, t.* FROM user u LEFT JOIN teachers t ON u.user_id = t.user_id WHERE u.user_id = ?" ;
            pstmt=conn.prepareStatement(sql); pstmt.setObject(1, userId); rs=pstmt.executeQuery(); if (rs.next()) {
            tName=rs.getString("name"); tDob=rs.getString("dob"); tGender=rs.getString("gender");
            tBlood=rs.getString("blood_group"); tPhone=rs.getString("phone"); tEmail=rs.getString("email");
            tAddress=rs.getString("address"); tDept=rs.getString("department"); tEmpId=rs.getString("employee_id");
            tId=rs.getString("teacher_id");
            tQual=rs.getString("qualification"); tExp=rs.getString("experience"); tJoined=rs.getString("joined_on");
            tSubject=rs.getString("subject"); if (tSubject==null || tSubject.isEmpty()) tSubject="Teacher" ; else
            tSubject=tSubject + " Teacher" ; byte[] photoBytes=rs.getBytes("photo"); if (photoBytes !=null &&
            photoBytes.length> 0) {
            tPhotoBase64 = java.util.Base64.getEncoder().encodeToString(photoBytes);
            }

            if (tName != null && !tName.isEmpty()) {
            String[] parts = tName.trim().split("\\s+");
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < Math.min(parts.length, 2); i++) { if (parts[i].length()> 0)
                sb.append(parts[i].charAt(0));
                }
                tInitials = sb.toString().toUpperCase();
                }
                }
                } catch (Exception e) {
                e.printStackTrace();
                } finally {
                if (rs != null) try { rs.close(); } catch(Exception e) {}
                if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                if (conn != null) try { conn.close(); } catch(Exception e) {}
                }

                boolean hasPersonalInfo = (tName != null && !tName.trim().isEmpty())
                && (tDob != null && !tDob.trim().isEmpty())
                && (tGender != null && !tGender.trim().isEmpty())
                && (tBlood != null && !tBlood.trim().isEmpty())
                && (tPhone != null && !tPhone.trim().isEmpty())
                && (tEmail != null && !tEmail.trim().isEmpty())
                && (tAddress != null && !tAddress.trim().isEmpty());

                boolean hasProfessionalInfo = (tSubject != null && !tSubject.trim().isEmpty() &&
                !"Teacher".equals(tSubject) && !"Subject Teacher".equals(tSubject))
                && (tDept != null && !tDept.trim().isEmpty())
                && (tQual != null && !tQual.trim().isEmpty());

                int myClassesCount = 0;
                int totalStudentsCount = 0;
                int pendingAssignmentsCount = 0; 
                double classAvgPercent = 0.0;
                String schoolName = "EduManage"; 
                List<Map<String, String>> assignedClasses = new ArrayList<>();

                int totalDistinctions = 0;
                int totalFailed = 0;
                List<Map<String, Object>> resultsSummary = new ArrayList<>();

                List<Map<String, String>> pendingAsgns = new ArrayList<>();
                List<Map<String, String>> completedAsgns = new ArrayList<>();

                int casualTotal=0, medicalTotal=0, earnedTotal=0;
                int casualUsed=0, medicalUsed=0, earnedUsed=0;
                int pendingLeaveCount=0;
                int totalLeaveAllotted=0, totalLeaveUsed=0, totalLeaveAvailable=0;
                int totalNoticesCount = 0;
                List<Map<String, String>> leaveHistory = new ArrayList<>();

                Connection connD = null;
                try {
                    connD = DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root", "");

                    ResultSet rsSN = connD.createStatement().executeQuery("SELECT config_value FROM settings WHERE config_key='school_name'");
                    if(rsSN.next()) schoolName = rsSN.getString(1);

                    if(assignedClasses == null) assignedClasses = new ArrayList<>();
                    if(resultsSummary == null) resultsSummary = new ArrayList<>();
                    if(pendingAsgns == null) pendingAsgns = new ArrayList<>();
                    if(completedAsgns == null) completedAsgns = new ArrayList<>();
                    if(leaveHistory == null) leaveHistory = new ArrayList<>();

                    if (tId != null && !tId.isEmpty()) {

                        try {
                        String classesSql = "SELECT DISTINCT class, section FROM timetable WHERE teacher_id = ? ORDER BY class, section";
                        PreparedStatement psClasses = connD.prepareStatement(classesSql);
                        psClasses.setString(1, tId);
                        ResultSet rsClasses = psClasses.executeQuery();
                        while(rsClasses.next()) {
                            try {
                                Map<String, String> c = new HashMap<>();
                                String cVal = rsClasses.getString("class");
                                String sVal = rsClasses.getString("section");
                                c.put("class", cVal);
                                c.put("section", sVal);

                                PreparedStatement psSC = connD.prepareStatement("SELECT COUNT(*) FROM students WHERE class = ? AND section = ?");
                                psSC.setString(1, cVal);
                                psSC.setString(2, sVal);
                                ResultSet rsSC = psSC.executeQuery();
                                if(rsSC.next()) c.put("student_count", rsSC.getString(1)); else c.put("student_count", "0");

                                PreparedStatement psPerf = connD.prepareStatement("SELECT AVG(marks_obtained / total_marks * 100) FROM results WHERE class = ? AND section = ? AND teacher_id = ?");
                                psPerf.setString(1, cVal);
                                psPerf.setString(2, sVal);
                                psPerf.setString(3, tId);
                                ResultSet rsPerf = psPerf.executeQuery();
                                double perf = 0.0;
                                if(rsPerf.next()) perf = rsPerf.getDouble(1);
                                c.put("performance", String.format("%.1f", perf));

                                PreparedStatement psPres = connD.prepareStatement("SELECT COUNT(*) FROM attendance WHERE class = ? AND section = ? AND date = CURDATE() AND status = 'present'");
                                psPres.setString(1, cVal);
                                psPres.setString(2, sVal);
                                ResultSet rsPres = psPres.executeQuery();
                                if(rsPres.next()) c.put("present_today", rsPres.getString(1)); else c.put("present_today", "0");

                                PreparedStatement psAbs = connD.prepareStatement("SELECT COUNT(*) FROM attendance WHERE class = ? AND section = ? AND date = CURDATE() AND status = 'absent'");
                                psAbs.setString(1, cVal);
                                psAbs.setString(2, sVal);
                                ResultSet rsAbs = psAbs.executeQuery();
                                if(rsAbs.next()) c.put("absent_today", rsAbs.getString(1)); else c.put("absent_today", "0");

                                assignedClasses.add(c);
                                myClassesCount++;
                            } catch (Exception e) { System.err.println("Error processing class row: " + e.getMessage()); }
                        }
                    } catch (Exception e) { System.err.println("Error fetching classes: " + e.getMessage()); }

                        try {
                        String studentsSql = "SELECT COUNT(*) FROM students WHERE (class, section) IN (SELECT DISTINCT class, section FROM timetable WHERE teacher_id = ?)";
                        PreparedStatement psStudents = connD.prepareStatement(studentsSql);
                        psStudents.setString(1, tId);
                        ResultSet rsStudents = psStudents.executeQuery();
                        if(rsStudents.next()) totalStudentsCount = rsStudents.getInt(1);
                        } catch (Exception e) { System.err.println("Error fetching student count: " + e.getMessage()); }

                        try {
                        String avgSql = "SELECT AVG(marks_obtained / total_marks * 100) FROM results WHERE teacher_id = ?";
                        PreparedStatement psAvg = connD.prepareStatement(avgSql);
                        psAvg.setString(1, tId);
                        ResultSet rsAvg = psAvg.executeQuery();
                        if(rsAvg.next()) classAvgPercent = rsAvg.getDouble(1);
                        } catch (Exception e) { System.err.println("Error fetching class avg: " + e.getMessage()); }

                        try {
                            String statsSql = "SELECT " +
                                    "SUM(CASE WHEN (marks_obtained/total_marks*100) >= 80 THEN 1 ELSE 0 END) as distinctions, " +
                                    "SUM(CASE WHEN (marks_obtained/total_marks*100) < 33 THEN 1 ELSE 0 END) as failed " +
                                    "FROM results WHERE teacher_id = ?";
                            PreparedStatement psStats = connD.prepareStatement(statsSql);
                            psStats.setString(1, tId);
                            ResultSet rsStats = psStats.executeQuery();
                            if(rsStats.next()) {
                                totalDistinctions = rsStats.getInt("distinctions");
                                totalFailed = rsStats.getInt("failed");
                            }
                        } catch (Exception e) { System.err.println("Error fetching result stats: " + e.getMessage()); }

                        try {
                            for(Map<String, String> c : assignedClasses) {
                                Map<String, Object> r = new HashMap<>();
                                String cVal = c.get("class");
                                String sVal = c.get("section");
                                r.put("class", cVal + "-" + sVal);
                                r.put("total_students", c.get("student_count"));

                                String classStatsSql = "SELECT COUNT(DISTINCT student_id) as appeared, " +
                                        "SUM(CASE WHEN (marks_obtained/total_marks*100) >= 33 THEN 1 ELSE 0 END) as passed, " +
                                        "SUM(CASE WHEN (marks_obtained/total_marks*100) < 33 THEN 1 ELSE 0 END) as failed, " +
                                        "AVG(marks_obtained/total_marks*100) as avg_perc, " +
                                        "MAX(marks_obtained/total_marks*100) as highest " +
                                        "FROM results WHERE class = ? AND section = ? AND teacher_id = ?";
                                PreparedStatement psCS = connD.prepareStatement(classStatsSql);
                                psCS.setString(1, cVal);
                                psCS.setString(2, sVal);
                                psCS.setString(3, tId);
                                ResultSet rsCS = psCS.executeQuery();
                                if(rsCS.next()) {
                                    r.put("appeared", rsCS.getInt("appeared"));
                                    r.put("passed", rsCS.getInt("passed"));
                                    r.put("failed", rsCS.getInt("failed"));
                                    r.put("avg_perc", String.format("%.1f", rsCS.getDouble("avg_perc")));
                                    r.put("highest", String.format("%.1f", rsCS.getDouble("highest")));
                                }
                                resultsSummary.add(r);
                            }
                        } catch (Exception e) { System.err.println("Error fetching results summary: " + e.getMessage()); }

                        try {
                            String sqlA = "SELECT a.*, (SELECT COUNT(*) FROM assignment_submissions s WHERE s.assignment_id = a.assignment_id) as sub_count " +
                                         "FROM assignments a WHERE a.teacher_id = ? ORDER BY a.due_date ASC";
                            PreparedStatement psA = connD.prepareStatement(sqlA);
                            psA.setString(1, tId);
                            ResultSet rsA = psA.executeQuery();
                            java.util.Date todayAsgn = new java.util.Date();
                            while(rsA.next()) {
                                Map<String, String> asgn = new HashMap<>();
                                asgn.put("id", rsA.getString("assignment_id"));
                                asgn.put("title", rsA.getString("title"));
                                asgn.put("class", rsA.getString("class") + "-" + rsA.getString("section"));
                                asgn.put("subs", rsA.getString("sub_count"));
                                asgn.put("docs", rsA.getString("documents"));
                                java.sql.Date dDate = rsA.getDate("due_date");
                                asgn.put("due", dDate != null ? new java.text.SimpleDateFormat("d MMM yyyy").format(dDate) : "N/A");
                                if(dDate != null && dDate.before(todayAsgn)) {
                                    completedAsgns.add(asgn);
                                } else {
                                    long diff = dDate != null ? dDate.getTime() - todayAsgn.getTime() : Long.MAX_VALUE;
                                    long days = diff / (1000 * 60 * 60 * 24);
                                    if(days < 2) asgn.put("tag", "Urgent");
                                    else if(days < 5) asgn.put("tag", "Soon");
                                    else asgn.put("tag", "Open");
                                    pendingAsgns.add(asgn);
                                }
                            }
                            pendingAssignmentsCount = pendingAsgns.size();
                        } catch (Exception e) { System.err.println("Error fetching assignments: " + e.getMessage()); }

                        try {
                            String balSql = "SELECT * FROM leave_balance WHERE teacher_id = ?";
                            PreparedStatement psBal = connD.prepareStatement(balSql);
                            psBal.setString(1, tId);
                            ResultSet rsBal = psBal.executeQuery();
                            if(rsBal.next()) {
                                casualTotal = rsBal.getInt("casual_total");
                                medicalTotal = rsBal.getInt("medical_total");
                                earnedTotal = rsBal.getInt("earned_total");
                                casualUsed = rsBal.getInt("casual_used");
                                medicalUsed = rsBal.getInt("medical_used");
                                earnedUsed = rsBal.getInt("earned_used");
                            }
                            String pendSql = "SELECT COUNT(*) FROM leave_applications WHERE teacher_id = ? AND status = 'pending'";
                            PreparedStatement psPend = connD.prepareStatement(pendSql);
                            psPend.setString(1, tId);
                            ResultSet rsPend = psPend.executeQuery();
                            if(rsPend.next()) pendingLeaveCount = rsPend.getInt(1);

                            totalLeaveAllotted = casualTotal + medicalTotal + earnedTotal;
                            totalLeaveUsed = casualUsed + medicalUsed + earnedUsed;
                            totalLeaveAvailable = totalLeaveAllotted - totalLeaveUsed;
                        } catch (Exception e) { System.err.println("Error fetching leave balance: " + e.getMessage()); }

                        try {
                            String histSql = "SELECT * FROM leave_applications WHERE teacher_id = ? ORDER BY applied_at DESC";
                            PreparedStatement psHist = connD.prepareStatement(histSql);
                            psHist.setString(1, tId);
                            ResultSet rsHist = psHist.executeQuery();
                            while(rsHist.next()) {
                                Map<String, String> lh = new HashMap<>();
                                String status = rsHist.getString("status");
                                if(status == null) status = "pending";
                                lh.put("status", status);
                                lh.put("leave_type", rsHist.getString("leave_type") != null ? rsHist.getString("leave_type") : "General Leave");
                                lh.put("from_date", rsHist.getString("from_date") != null ? rsHist.getString("from_date") : "N/A");
                                lh.put("to_date", rsHist.getString("to_date") != null ? rsHist.getString("to_date") : "N/A");
                                lh.put("days", rsHist.getString("days"));
                                lh.put("reason", rsHist.getString("reason") != null ? rsHist.getString("reason") : "No reason provided");
                                lh.put("applied_at", rsHist.getString("applied_at") != null ? rsHist.getString("applied_at") : "N/A");
                                leaveHistory.add(lh);
                            }
                        } catch (Exception e) { System.err.println("Error fetching leave history: " + e.getMessage()); }

                        String countNoticesSql = "SELECT COUNT(*) FROM notices WHERE target IN ('all', 'teachers') AND student_id IS NULL";
                        PreparedStatement psNC = connD.prepareStatement(countNoticesSql);
                        ResultSet rsNC = psNC.executeQuery();
                        if(rsNC.next()) totalNoticesCount = rsNC.getInt(1);
                        pageContext.setAttribute("noticesCount", totalNoticesCount);
                    }
                } catch(Exception e) {
                    e.printStackTrace();
                } finally {
                    if(connD != null) try { connD.close(); } catch(Exception e) {}
                }
                %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>Teacher Dashboard</title>
                    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css"
                        rel="stylesheet" />
                    <link
                        href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css"
                        rel="stylesheet" />
                    <link
                        href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap"
                        rel="stylesheet" />
                    <style>
                        :root {
                            --sidebar: #0d1f12;
                            --accent: #22c55e;
                            --accent-light: #4ade80;
                            --accent-glow: rgba(34, 197, 94, 0.13);
                            --green: #10b981;
                            --yellow: #f59e0b;
                            --red: #ef4444;
                            --blue: #3b82f6;
                            --purple: #8b5cf6;
                            --sidebar-w: 268px;
                            --bg: #f0f4f8;
                            --card: #fff;
                            --border: #e2e8f0;
                            --text: #0d1f12;
                            --muted: #64748b;
                        }

                        *,
                        *::before,
                        *::after {
                            box-sizing: border-box;
                            margin: 0;
                            padding: 0
                        }

                        body {
                            font-family: 'Sora', sans-serif;
                            background: var(--bg);
                            color: var(--text);
                            display: flex;
                            min-height: 100vh;
                            overflow-x: hidden
                        }

                        .sidebar {
                            width: var(--sidebar-w);
                            background: var(--sidebar);
                            position: fixed;
                            top: 0;
                            left: 0;
                            height: 100vh;
                            display: flex;
                            flex-direction: column;
                            z-index: 200;
                            transition: transform .3s ease;
                            overflow-y: auto
                        }

                        .sidebar::-webkit-scrollbar {
                            width: 0
                        }

                        .sidebar::before {
                            content: '';
                            position: absolute;
                            top: 0;
                            left: 0;
                            right: 0;
                            height: 170px;
                            background: linear-gradient(160deg, rgba(34, 197, 94, .18) 0%, transparent 100%);
                            pointer-events: none
                        }

                        .s-brand {
                            padding: 24px 20px 18px;
                            display: flex;
                            align-items: center;
                            gap: 12px;
                            border-bottom: 1px solid rgba(255, 255, 255, .07);
                            position: relative
                        }

                        .s-brand-icon {
                            width: 42px;
                            height: 42px;
                            border-radius: 12px;
                            background: var(--accent);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 20px;
                            color: #fff;
                            box-shadow: 0 4px 16px rgba(34, 197, 94, .4)
                        }

                        .s-brand-text h6 {
                            color: #fff;
                            font-size: 14px;
                            font-weight: 700;
                            margin: 0
                        }

                        .s-brand-text small {
                            color: rgba(255, 255, 255, .3);
                            font-size: 11px
                        }

                        .s-teacher-card {
                            margin: 14px 12px;
                            background: rgba(255, 255, 255, .05);
                            border: 1px solid rgba(255, 255, 255, .08);
                            border-radius: 14px;
                            padding: 13px;
                            display: flex;
                            align-items: center;
                            gap: 12px
                        }

                        .s-av {
                            width: 44px;
                            height: 44px;
                            border-radius: 12px;
                            overflow: hidden;
                            border: 2px solid var(--accent);
                            flex-shrink: 0
                        }

                        .s-av-init {
                            width: 100%;
                            height: 100%;
                            background: linear-gradient(135deg, var(--accent), var(--accent-light));
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-weight: 700;
                            font-size: 16px;
                            color: #fff
                        }

                        .s-tinfo {
                            flex: 1;
                            min-width: 0
                        }

                        .s-tinfo h6 {
                            color: #fff;
                            font-size: 13px;
                            font-weight: 600;
                            margin: 0;
                            white-space: nowrap;
                            overflow: hidden;
                            text-overflow: ellipsis
                        }

                        .s-tinfo small {
                            color: rgba(255, 255, 255, .35);
                            font-size: 11px
                        }

                        .tbadge {
                            background: rgba(34, 197, 94, .25);
                            color: var(--accent-light);
                            font-size: 9px;
                            font-weight: 700;
                            padding: 2px 7px;
                            border-radius: 20px;
                            text-transform: uppercase;
                            letter-spacing: .5px;
                            flex-shrink: 0
                        }

                        .s-nav {
                            padding: 6px 12px;
                            flex: 1
                        }

                        .s-lbl {
                            padding: 14px 10px 5px;
                            color: rgba(255, 255, 255, .2);
                            font-size: 10px;
                            text-transform: uppercase;
                            letter-spacing: 1.6px;
                            font-weight: 600
                        }

                        .s-item {
                            margin-bottom: 2px
                        }

                        .s-link {
                            display: flex;
                            align-items: center;
                            gap: 12px;
                            padding: 10px 12px;
                            border-radius: 11px;
                            color: rgba(255, 255, 255, .48);
                            text-decoration: none;
                            font-size: 13px;
                            font-weight: 500;
                            transition: all .18s;
                            cursor: pointer
                        }

                        .s-link i {
                            font-size: 17px;
                            min-width: 20px;
                            transition: transform .2s
                        }

                        .s-link:hover {
                            background: rgba(255, 255, 255, .07);
                            color: rgba(255, 255, 255, .85)
                        }

                        .s-link:hover i {
                            transform: translateX(2px)
                        }

                        .s-link.active {
                            background: var(--accent);
                            color: #fff;
                            font-weight: 600;
                            box-shadow: 0 4px 14px rgba(34, 197, 94, .3)
                        }

                        .s-link.active i {
                            transform: none
                        }

                        .sbadge {
                            margin-left: auto;
                            font-size: 10px;
                            font-weight: 700;
                            padding: 2px 7px;
                            border-radius: 20px;
                            background: rgba(255, 255, 255, .12);
                            color: rgba(255, 255, 255, .65)
                        }

                        .s-link.active .sbadge {
                            background: rgba(255, 255, 255, .25);
                            color: #fff
                        }

                        .sbadge.red {
                            background: var(--red);
                            color: #fff
                        }

                        .s-bottom {
                            padding: 13px 12px;
                            border-top: 1px solid rgba(255, 255, 255, .07)
                        }

                        .s-out {
                            display: flex;
                            align-items: center;
                            gap: 10px;
                            padding: 10px 12px;
                            border-radius: 11px;
                            color: rgba(255, 255, 255, .33);
                            font-size: 13px;
                            font-weight: 500;
                            cursor: pointer;
                            transition: all .18s
                        }

                        .s-out:hover {
                            background: rgba(239, 68, 68, .12);
                            color: var(--red)
                        }

                        .main {
                            margin-left: var(--sidebar-w);
                            flex: 1;
                            display: flex;
                            flex-direction: column
                        }

                        .topbar {
                            background: var(--card);
                            border-bottom: 1.5px solid var(--border);
                            padding: 13px 30px;
                            display: flex;
                            align-items: center;
                            gap: 14px;
                            position: sticky;
                            top: 0;
                            z-index: 100
                        }

                        .tbar-title {
                            font-weight: 700;
                            font-size: 17px
                        }

                        .tbar-right {
                            margin-left: auto;
                            display: flex;
                            align-items: center;
                            gap: 10px
                        }

                        .tb-btn {
                            width: 38px;
                            height: 38px;
                            border-radius: 10px;
                            background: var(--bg);
                            border: 1.5px solid var(--border);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            color: var(--muted);
                            cursor: pointer;
                            transition: all .18s;
                            position: relative
                        }

                        .tb-btn:hover {
                            border-color: var(--accent);
                            color: var(--accent)
                        }

                        .notif-dot {
                            position: absolute;
                            top: 5px;
                            right: 5px;
                            width: 8px;
                            height: 8px;
                            border-radius: 50%;
                            background: var(--red);
                            border: 2px solid var(--card)
                        }

                        .tb-srch {
                            display: flex;
                            align-items: center;
                            gap: 8px;
                            background: var(--bg);
                            border: 1.5px solid var(--border);
                            border-radius: 10px;
                            padding: 7px 13px
                        }

                        .tb-srch input {
                            border: none;
                            background: transparent;
                            font-size: 13px;
                            font-family: inherit;
                            outline: none;
                            width: 190px
                        }

                        .tb-srch i {
                            color: var(--muted);
                            font-size: 14px
                        }

                        .tb-date {
                            font-size: 12px;
                            color: var(--muted);
                            font-family: 'JetBrains Mono', monospace;
                            margin-right: 15px;
                            display: flex;
                            align-items: center
                        }

                        .mob-toggle {
                            background: none;
                            border: none;
                            font-size: 22px;
                            color: var(--text);
                            cursor: pointer
                        }

                        .page {
                            display: none;
                            padding: 26px 30px;
                            animation: fadeUp .28s ease
                        }

                        .page.active {
                            display: block
                        }

                        @keyframes fadeUp {
                            from {
                                opacity: 0;
                                transform: translateY(10px)
                            }

                            to {
                                opacity: 1;
                                transform: translateY(0)
                            }
                        }

                        .pg-header {
                            margin-bottom: 22px;
                            display: flex;
                            align-items: flex-start;
                            justify-content: space-between;
                            flex-wrap: wrap;
                            gap: 12px
                        }

                        .pg-header-left h4 {
                            font-weight: 800;
                            font-size: 21px;
                            margin: 0
                        }

                        .pg-header-left p {
                            color: var(--muted);
                            font-size: 13.5px;
                            margin: 4px 0 0
                        }

                        .cbox {
                            background: var(--card);
                            border-radius: 16px;
                            border: 1.5px solid var(--border)
                        }

                        .chead {
                            padding: 15px 20px;
                            border-bottom: 1.5px solid var(--border);
                            display: flex;
                            align-items: center;
                            gap: 10px
                        }

                        .chead h6 {
                            font-weight: 700;
                            margin: 0;
                            font-size: 14px
                        }

                        .cbody {
                            padding: 20px
                        }

                        .stat {
                            background: var(--card);
                            border-radius: 16px;
                            border: 1.5px solid var(--border);
                            padding: 20px;
                            transition: transform .2s, box-shadow .2s
                        }

                        .stat:hover {
                            transform: translateY(-3px);
                            box-shadow: 0 8px 28px rgba(0, 0, 0, .07)
                        }

                        .stat-ico {
                            width: 46px;
                            height: 46px;
                            border-radius: 13px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 20px;
                            margin-bottom: 14px
                        }

                        .stat h3 {
                            font-size: 28px;
                            font-weight: 800;
                            margin: 0;
                            font-family: 'JetBrains Mono', monospace
                        }

                        .stat p {
                            font-size: 13px;
                            color: var(--muted);
                            margin: 4px 0 10px
                        }

                        .tag {
                            display: inline-block;
                            font-size: 11px;
                            font-weight: 700;
                            padding: 3px 10px;
                            border-radius: 20px
                        }

                        .tg {
                            background: #d1fae5;
                            color: #059669
                        }

                        .tr {
                            background: #fee2e2;
                            color: #dc2626
                        }

                        .ty {
                            background: #fef3c7;
                            color: #d97706
                        }

                        .tb {
                            background: #dbeafe;
                            color: #2563eb
                        }

                        .tp {
                            background: #ede9fe;
                            color: #7c3aed
                        }

                        .tt {
                            background: #ccfbf1;
                            color: #0d9488
                        }

                        .tbl thead th {
                            font-size: 11px;
                            text-transform: uppercase;
                            letter-spacing: .8px;
                            color: var(--muted);
                            border: none;
                            padding: 12px 16px;
                            background: #f8fafc
                        }

                        .tbl td {
                            font-size: 13px;
                            padding: 11px 16px;
                            vertical-align: middle;
                            border-color: var(--border)
                        }

                        .tbl tbody tr:hover {
                            background: #f8fafc
                        }

                        .avsm {
                            width: 34px;
                            height: 34px;
                            border-radius: 9px;
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 13px;
                            font-weight: 700
                        }

                        .pb-wrap {
                            background: #f1f5f9;
                            border-radius: 100px;
                            height: 7px;
                            overflow: hidden
                        }

                        .pb {
                            height: 100%;
                            border-radius: 100px
                        }

                        .btn-a {
                            background: var(--accent);
                            color: #fff;
                            border: none;
                            border-radius: 10px;
                            padding: 9px 18px;
                            font-size: 13px;
                            font-weight: 600;
                            cursor: pointer;
                            font-family: inherit;
                            transition: all .18s;
                            display: inline-flex;
                            align-items: center;
                            gap: 7px
                        }

                        .btn-a:hover {
                            opacity: .88;
                            transform: translateY(-1px)
                        }

                        .btn-o {
                            background: transparent;
                            color: var(--text);
                            border: 1.5px solid var(--border);
                            border-radius: 10px;
                            padding: 8px 16px;
                            font-size: 13px;
                            font-weight: 600;
                            cursor: pointer;
                            font-family: inherit;
                            transition: all .18s;
                            display: inline-flex;
                            align-items: center;
                            gap: 7px
                        }

                        .btn-o:hover {
                            border-color: var(--accent);
                            color: var(--accent)
                        }

                        .btn-ic {
                            width: 32px;
                            height: 32px;
                            border-radius: 8px;
                            border: 1.5px solid var(--border);
                            background: transparent;
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            cursor: pointer;
                            font-size: 14px;
                            color: var(--muted);
                            transition: all .15s
                        }

                        .btn-ic:hover {
                            border-color: var(--accent);
                            color: var(--accent)
                        }

                        .mstat {
                            display: flex;
                            align-items: center;
                            gap: 14px;
                            background: var(--card);
                            border: 1.5px solid var(--border);
                            border-radius: 14px;
                            padding: 16px 18px;
                            transition: transform .2s
                        }

                        .mstat:hover {
                            transform: translateY(-2px)
                        }

                        .mstat-ico {
                            width: 40px;
                            height: 40px;
                            border-radius: 11px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 19px;
                            flex-shrink: 0
                        }

                        .mstat p {
                            margin: 0;
                            font-size: 18px;
                            font-weight: 800;
                            font-family: 'JetBrains Mono', monospace
                        }

                        .mstat small {
                            font-size: 12px;
                            color: var(--muted)
                        }

                        .tslot {
                            background: var(--bg);
                            border-radius: 12px;
                            padding: 12px 14px;
                            margin-bottom: 8px;
                            display: flex;
                            align-items: center;
                            gap: 12px;
                            border-left: 3px solid transparent
                        }

                        .tslot.now {
                            background: var(--accent-glow);
                            border-left-color: var(--accent)
                        }

                        .tslot.done {
                            opacity: .5
                        }

                        .t-time {
                            font-size: 12px;
                            font-family: 'JetBrains Mono', monospace;
                            color: var(--muted);
                            min-width: 90px
                        }

                        .t-info {
                            flex: 1
                        }

                        .t-info p {
                            margin: 0;
                            font-size: 13px;
                            font-weight: 600
                        }

                        .t-info small {
                            color: var(--muted);
                            font-size: 12px
                        }

                        .t-room {
                            font-size: 11px;
                            font-weight: 600;
                            background: rgba(34, 197, 94, .12);
                            color: #16a34a;
                            padding: 3px 9px;
                            border-radius: 20px
                        }

                        .arow {
                            display: flex;
                            align-items: center;
                            gap: 12px;
                            padding: 12px 0;
                            border-bottom: 1px solid var(--border)
                        }

                        .arow:last-child {
                            border: none
                        }

                        .aico {
                            width: 38px;
                            height: 38px;
                            border-radius: 10px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 17px;
                            flex-shrink: 0
                        }

                        .ainfo {
                            flex: 1;
                            min-width: 0
                        }

                        .ainfo p {
                            margin: 0;
                            font-size: 13px;
                            font-weight: 600
                        }

                        .ainfo small {
                            color: var(--muted);
                            font-size: 12px
                        }

                        .leave-hero {
                            background: linear-gradient(135deg, #0d1f12, #052e16);
                            border-radius: 18px;
                            padding: 24px;
                            position: relative;
                            overflow: hidden;
                            margin-bottom: 20px
                        }

                        .leave-hero::before {
                            content: '';
                            position: absolute;
                            width: 200px;
                            height: 200px;
                            border-radius: 50%;
                            background: rgba(34, 197, 94, .1);
                            top: -60px;
                            right: -40px
                        }

                        .lq-grid {
                            display: grid;
                            grid-template-columns: repeat(4, 1fr);
                            gap: 12px;
                            position: relative;
                            z-index: 1
                        }

                        .lq-item {
                            background: rgba(255, 255, 255, .07);
                            border: 1px solid rgba(255, 255, 255, .1);
                            border-radius: 14px;
                            padding: 16px;
                            text-align: center
                        }

                        .lq-item h3 {
                            color: #fff;
                            font-size: 26px;
                            font-weight: 800;
                            font-family: 'JetBrains Mono', monospace;
                            margin: 0
                        }

                        .lq-item p {
                            color: rgba(255, 255, 255, .5);
                            font-size: 11px;
                            margin: 4px 0 0;
                            font-weight: 600;
                            text-transform: uppercase;
                            letter-spacing: .5px
                        }

                        .lq-item.avail h3 {
                            color: var(--accent-light)
                        }

                        .lq-item.used h3 {
                            color: #f87171
                        }

                        .lq-item.pending h3 {
                            color: #fcd34d
                        }

                        .lq-item.total h3 {
                            color: #93c5fd
                        }

                        .ltype {
                            border: 1.5px solid var(--border);
                            border-radius: 12px;
                            padding: 14px 16px;
                            cursor: pointer;
                            transition: all .18s;
                            text-align: center;
                            background: var(--card)
                        }

                        .ltype:hover,
                        .ltype.sel {
                            border-color: var(--accent);
                            background: var(--accent-glow)
                        }

                        .ltype i {
                            font-size: 22px;
                            display: block;
                            margin-bottom: 6px
                        }

                        .ltype span {
                            font-size: 13px;
                            font-weight: 600;
                            display: block
                        }

                        .ltype small {
                            font-size: 11px;
                            color: var(--muted)
                        }

                        .lhist {
                            display: flex;
                            align-items: center;
                            gap: 14px;
                            padding: 14px 0;
                            border-bottom: 1px solid var(--border)
                        }

                        .lhist:last-child {
                            border: none
                        }

                        .lhist-ico {
                            width: 42px;
                            height: 42px;
                            border-radius: 12px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 18px;
                            flex-shrink: 0
                        }

                        .lhist-info {
                            flex: 1
                        }

                        .lhist-info p {
                            margin: 0;
                            font-size: 13px;
                            font-weight: 600
                        }

                        .lhist-info small {
                            color: var(--muted);
                            font-size: 12px
                        }

                        .ldays {
                            font-family: 'JetBrains Mono', monospace;
                            font-size: 13px;
                            font-weight: 700;
                            color: var(--muted)
                        }

                        .prof-hero {
                            background: linear-gradient(135deg, #0d1f12 0%, #052e16 50%, #0d1f12 100%);
                            border-radius: 20px;
                            padding: 36px 32px;
                            position: relative;
                            overflow: hidden;
                            margin-bottom: 24px
                        }

                        .prof-hero::before {
                            content: '';
                            position: absolute;
                            width: 320px;
                            height: 320px;
                            border-radius: 50%;
                            background: rgba(34, 197, 94, .12);
                            top: -100px;
                            right: -80px
                        }

                        .prof-hero::after {
                            content: '';
                            position: absolute;
                            width: 180px;
                            height: 180px;
                            border-radius: 50%;
                            background: rgba(34, 197, 94, .06);
                            bottom: -50px;
                            left: 220px
                        }

                        .pav-wrap {
                            position: relative;
                            width: fit-content;
                            margin-bottom: 16px
                        }

                        .pav {
                            width: 100px;
                            height: 100px;
                            border-radius: 22px;
                            border: 3px solid var(--accent);
                            overflow: hidden;
                            box-shadow: 0 8px 32px rgba(34, 197, 94, .35)
                        }

                        .pav-init {
                            width: 100%;
                            height: 100%;
                            background: linear-gradient(135deg, var(--accent), var(--accent-light));
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 36px;
                            font-weight: 800;
                            color: #fff
                        }

                        .pav-cam {
                            position: absolute;
                            bottom: -6px;
                            right: -6px;
                            width: 30px;
                            height: 30px;
                            border-radius: 8px;
                            background: var(--accent);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            cursor: pointer;
                            border: 2px solid #0d1f12;
                            transition: transform .2s
                        }

                        .pav-cam:hover {
                            transform: scale(1.1)
                        }

                        .pav-cam i {
                            font-size: 13px;
                            color: #fff
                        }

                        .prof-hero h3 {
                            color: #fff;
                            font-size: 24px;
                            font-weight: 800;
                            margin: 0 0 4px
                        }

                        .prof-hero .prole {
                            color: rgba(255, 255, 255, .5);
                            font-size: 13px
                        }

                        .ptags {
                            display: flex;
                            flex-wrap: wrap;
                            gap: 8px;
                            margin-top: 12px
                        }

                        .ptag {
                            background: rgba(255, 255, 255, .08);
                            border: 1px solid rgba(255, 255, 255, .12);
                            color: rgba(255, 255, 255, .7);
                            font-size: 12px;
                            font-weight: 500;
                            padding: 4px 12px;
                            border-radius: 20px
                        }

                        .pedit-btn {
                            position: absolute;
                            top: 24px;
                            right: 24px;
                            z-index: 2;
                            background: rgba(255, 255, 255, .1);
                            border: 1.5px solid rgba(255, 255, 255, .2);
                            color: #fff;
                            font-size: 13px;
                            font-weight: 600;
                            padding: 8px 18px;
                            border-radius: 10px;
                            cursor: pointer;
                            transition: all .18s;
                            display: flex;
                            align-items: center;
                            gap: 7px
                        }

                        .pedit-btn:hover {
                            background: var(--accent);
                            border-color: var(--accent)
                        }

                        .ilabel {
                            font-size: 11px;
                            font-weight: 700;
                            text-transform: uppercase;
                            letter-spacing: .6px;
                            color: var(--muted);
                            margin-bottom: 4px
                        }

                        .ival {
                            font-size: 14px;
                            font-weight: 600
                        }

                        .mback {
                            position: fixed;
                            inset: 0;
                            background: rgba(0, 0, 0, .55);
                            backdrop-filter: blur(4px);
                            z-index: 500;
                            display: none;
                            align-items: center;
                            justify-content: center
                        }

                        .mback.show {
                            display: flex
                        }

                        .emodal {
                            background: #fff;
                            border-radius: 20px;
                            width: 90%;
                            max-width: 580px;
                            max-height: 90vh;
                            overflow-y: auto;
                            animation: mIn .25s ease
                        }

                        @keyframes mIn {
                            from {
                                opacity: 0;
                                transform: scale(.95)
                            }

                            to {
                                opacity: 1;
                                transform: scale(1)
                            }
                        }

                        .ehead {
                            padding: 20px 24px 16px;
                            border-bottom: 1.5px solid var(--border);
                            display: flex;
                            align-items: center;
                            justify-content: space-between
                        }

                        .ehead h5 {
                            font-weight: 800;
                            margin: 0;
                            font-size: 17px
                        }

                        .eclose {
                            width: 32px;
                            height: 32px;
                            border-radius: 9px;
                            background: var(--bg);
                            border: none;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            cursor: pointer;
                            font-size: 18px;
                            color: var(--muted)
                        }

                        .eclose:hover {
                            background: #fee2e2;
                            color: var(--red)
                        }

                        .ebody {
                            padding: 22px 24px
                        }

                        .av-up {
                            display: flex;
                            align-items: center;
                            gap: 20px;
                            background: var(--bg);
                            border-radius: 14px;
                            padding: 16px;
                            margin-bottom: 20px
                        }

                        .up-prev {
                            width: 72px;
                            height: 72px;
                            border-radius: 16px;
                            overflow: hidden;
                            border: 2px solid var(--accent);
                            flex-shrink: 0
                        }

                        .up-prev-init {
                            width: 100%;
                            height: 100%;
                            background: linear-gradient(135deg, var(--accent), var(--accent-light));
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 26px;
                            font-weight: 800;
                            color: #fff
                        }

                        .up-btn {
                            display: inline-flex;
                            align-items: center;
                            gap: 7px;
                            background: var(--accent);
                            color: #fff;
                            border: none;
                            border-radius: 10px;
                            padding: 8px 16px;
                            font-size: 13px;
                            font-weight: 600;
                            cursor: pointer;
                            font-family: inherit
                        }

                        .form-label {
                            font-size: 12px;
                            font-weight: 700;
                            text-transform: uppercase;
                            letter-spacing: .6px;
                            color: var(--muted);
                            margin-bottom: 6px
                        }

                        .form-control,
                        .form-select {
                            border-radius: 10px;
                            border: 1.5px solid var(--border);
                            font-size: 13.5px;
                            font-family: inherit;
                            padding: 10px 14px
                        }

                        .form-control:focus,
                        .form-select:focus {
                            border-color: var(--accent);
                            box-shadow: 0 0 0 3px rgba(34, 197, 94, .12)
                        }

                        .form-control:disabled {
                            background: #f8fafc;
                            color: var(--muted)
                        }

                        .save-btn {
                            background: var(--accent);
                            color: #fff;
                            border: none;
                            border-radius: 11px;
                            padding: 12px 28px;
                            font-size: 14px;
                            font-weight: 700;
                            cursor: pointer;
                            font-family: inherit;
                            box-shadow: 0 4px 14px rgba(34, 197, 94, .3)
                        }

                        .lback {
                            position: fixed;
                            inset: 0;
                            background: rgba(0, 0, 0, .55);
                            backdrop-filter: blur(4px);
                            z-index: 500;
                            display: none;
                            align-items: center;
                            justify-content: center
                        }

                        .lback.show {
                            display: flex
                        }

                        @media(max-width:768px) {
                            .sidebar {
                                transform: translateX(-100%)
                            }

                            .sidebar.open {
                                transform: translateX(0)
                            }

                            .main {
                                margin-left: 0
                            }

                            .mob-toggle {
                                display: block
                            }

                            .topbar {
                                padding: 12px 16px
                            }

                            .page {
                                padding: 18px 16px
                            }

                            .tb-srch {
                                display: none
                            }

                            .pedit-btn span {
                                display: none
                            }

                            .lq-grid {
                                grid-template-columns: repeat(2, 1fr)
                            }
                        }
                    </style>
                </head>

                <body>

                    <aside class="sidebar" id="sidebar">
                        <div class="s-brand">
                            <div class="s-brand-icon"><i class="bi bi-person-video3"></i></div>
                            <div class="s-brand-text">
                                <h6><%= schoolName %></h6><small>Teacher Portal</small>
                            </div>
                        </div>

                        <div class="s-teacher-card">
                            <div class="s-av">
                                <img src="<%= tPhotoBase64 != null ? " data:image/jpeg;base64," + tPhotoBase64
                                    : "images/user_default_photo.webp" %>"
                                style="width:100%;height:100%;object-fit:cover;" id="sidebar-photo" />
                            </div>
                            <div class="s-tinfo">
                                <h6 id="sidebar-name">
                                    <%= tName %>
                                </h6>
                                <small id="sidebar-sub">
                                    <%= tSubject %>
                                </small>
                            </div>
                            <div class="tbadge">Teacher</div>
                        </div>

                        <nav class="s-nav">
                            <div class="s-lbl">Overview</div>
                            <div class="s-item"><a class="s-link active" data-page="dashboard"><i
                                        class="bi bi-grid-fill"></i> Dashboard</a></div>
                            <div class="s-item"><a class="s-link" data-page="profile"><i
                                        class="bi bi-person-fill"></i>
                                    My Profile</a></div>

                            <div class="s-lbl">Teaching</div>
                            <div class="s-item"><a class="s-link" data-page="myclasses"><i
                                        class="bi bi-easel2-fill"></i>
                                    My Classes <span class="sbadge"><%= myClassesCount %></span></a></div>
                            <div class="s-item"><a class="s-link" data-page="timetable"><i
                                        class="bi bi-clock-fill"></i>
                                    My Timetable</a></div>
                            <div class="s-item"><a class="s-link" data-page="attendance"><i
                                        class="bi bi-calendar-check-fill"></i> Mark Attendance</a></div>
                            <div class="s-item"><a class="s-link" data-page="assignments"><i
                                        class="bi bi-clipboard2-check-fill"></i> Assignments <% if(pendingAssignmentsCount > 0) { %><span class="sbadge red"><%= pendingAssignmentsCount %></span><% } %></a></div>
                            <div class="s-item"><a class="s-link" data-page="results"><i
                                        class="bi bi-bar-chart-fill"></i> Results & Marks</a></div>

                            <div class="s-lbl">Personal</div>
                            <div class="s-item"><a class="s-link" data-page="leave"><i
                                        class="bi bi-calendar2-x-fill"></i> Leave Application <span
                                        class="sbadge"><%= pendingLeaveCount %></span></a>
                            </div>
                            <div class="s-item"><a class="s-link" data-page="notices"><i
                                        class="bi bi-bell-fill"></i>
                                    Notices <% if(totalNoticesCount > 0) { %><span class="sbadge" id="sidebar-notif-count"><%= totalNoticesCount %></span><% } %></a></div>
                        </nav>

                        <div class="s-bottom">
                            <a href="/teacher_logout" class="s-out" style="text-decoration: none;"><i
                                    class="bi bi-box-arrow-left" style="font-size:16px"></i> Logout</a>
                        </div>
                    </aside>

                    <div class="main">
                        <div class="topbar">
                            <button class="mob-toggle" onclick="toggleSidebar()"><i class="bi bi-list"></i></button>
                            <span class="tbar-title" id="page-title">Dashboard</span>
                            <div class="tbar-right">
                                <span class="tb-date" id="topbar-date">Monday, 2 Mar</span>
                                <div class="tb-srch"><i class="bi bi-search"></i><input type="text"
                                        placeholder="Search for student or class..." /></div>
                                <div class="tb-btn" onclick="showPage('notices')" title="View Notices" style="cursor:pointer"><i class="bi bi-bell"></i><span class="notif-dot"></span></div>
                                <div><a href="/teacher_logout" class="tb-btn" style="text-decoration: none;">
                                        <i class="bi bi-box-arrow-right"></i>
                                    </a></div>
                            </div>
                        </div>

                        <div class="page active" id="page-dashboard">
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>Namaste, <%= tName %>! 👋</h4>
                                    <p>Aaj ke classes aur students ka overview</p>
                                </div>
                                <button class="btn-a"
                                    onclick="showPage('leave')"><i
                                        class="bi bi-calendar2-x-fill"></i> Leave Apply Karo</button>
                            </div>

                            <div class="row g-3 mb-4">
                                <div class="col-6 col-xl-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#dcfce7;color:#16a34a"><i
                                                class="bi bi-easel2-fill"></i>
                                        </div>
                                        <h3><%= myClassesCount %></h3>
                                        <p>My Classes</p><span class="tag tg">This Term</span>
                                    </div>
                                </div>
                                <div class="col-6 col-xl-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#dbeafe;color:#2563eb"><i
                                                class="bi bi-people-fill"></i>
                                        </div>
                                        <h3><%= totalStudentsCount %></h3>
                                        <p>Total Students</p><span class="tag tb"><%= myClassesCount %> Classes</span>
                                    </div>
                                </div>
                                <div class="col-6 col-xl-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#fef3c7;color:#d97706"><i
                                                class="bi bi-clipboard2-check-fill"></i></div>
                                        <h3><%= pendingAssignmentsCount %></h3>
                                        <p>Pending Reviews</p><span class="tag ty">Assignments</span>
                                    </div>
                                </div>
                                <div class="col-6 col-xl-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#ede9fe;color:#7c3aed"><i
                                                class="bi bi-graph-up-arrow"></i></div>
                                        <h3><%= String.format("%.1f", classAvgPercent) %>%</h3>
                                        <p>Class Average</p><span class="tag tp">↑ Live</span>
                                    </div>
                                </div>
                            </div>

                            <div class="row g-3">

                                <div class="col-12 col-lg-5">
                                    <div class="cbox">
                                        <div class="chead"><i class="bi bi-clock-fill" style="color:var(--accent)"></i>
                                            <h6>Aaj ka Schedule</h6><span class="ms-auto" id="dash-date-short"
                                                style="font-size:12px;color:var(--muted)">Monday, 2 Mar</span>
                                        </div>
                                        <div class="cbody">
                                            <%
                                                Connection connTT = null;
                                                try {
                                                    connTT = DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root" , "" );
                                                    String todayDay = new java.text.SimpleDateFormat("EEEE").format(new java.util.Date());
                                                    String ttTodaySql = "SELECT * FROM timetable WHERE teacher_id = ? AND day = ? ORDER BY start_time";
                                                    PreparedStatement psTT = connTT.prepareStatement(ttTodaySql);
                                                    psTT.setString(1, tId);
                                                    psTT.setString(2, todayDay);
                                                    ResultSet rsTTD = psTT.executeQuery();
                                                    boolean hasTodayTT = false;
                                                    while(rsTTD.next()) {
                                                        hasTodayTT = true;
                                                        String stRaw = rsTTD.getString("start_time");
                                                        String etRaw = rsTTD.getString("end_time");
                                                        String sTime = (stRaw != null && stRaw.length() >= 5) ? stRaw.substring(0,5) : "00:00";
                                                        String eTime = (etRaw != null && etRaw.length() >= 5) ? etRaw.substring(0,5) : "00:00";
                                                        String subT = rsTTD.getString("subject");
                                                        String clsT = rsTTD.getString("class") + "-" + rsTTD.getString("section");
                                                        String roomT = rsTTD.getString("room");
                                            %>
                                                <div class="tslot"><span class="t-time"><%= sTime %> – <%= eTime %></span>
                                                    <div class="t-info">
                                                        <p><%= subT %> — Class <%= clsT %></p><small>Room <%= roomT %></small>
                                                    </div><span class="t-room"><%= roomT %></span>
                                                </div>
                                            <%
                                                    }
                                                    if(!hasTodayTT) {
                                            %>
                                                <div class="text-center py-4 text-muted" style="font-size:13px;">Aaj koi classes schedule nahi hain. Chill maaro! 😎</div>
                                            <%
                                                    }
                                                } catch(Exception e) {
                                                    e.printStackTrace();
                                                } finally {
                                                    if (connTT != null) try { connTT.close(); } catch(Exception e) {}
                                                }
                                            %>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-12 col-lg-7">
                                    <div class="cbox">
                                        <div class="chead"><i class="bi bi-bar-chart-fill"
                                                style="color:var(--purple)"></i>
                                            <h6>My Classes — Performance</h6>
                                        </div>
                                        <div class="cbody">
                                            <%
                                                String[] barColors = {"#22c55e", "#3b82f6", "#8b5cf6", "#f59e0b", "#ef4444", "#06b6d4"};
                                                int barIdx = 0;
                                                for(Map<String, String> c : assignedClasses) {
                                                    String perf = c.get("performance");
                                                    double pVal = 0;
                                                    try { pVal = Double.parseDouble(perf); } catch(Exception e) {}
                                                    String color = barColors[barIdx % barColors.length];
                                                    barIdx++;
                                            %>
                                            <div class="mb-3">
                                                <div class="d-flex justify-content-between mb-1"><span
                                                        style="font-size:13px;font-weight:600">Class <%= c.get("class") %>-<%= c.get("section") %> <span
                                                            style="color:var(--muted);font-weight:400">(<%= c.get("student_count") %>
                                                            Students)</span></span><span
                                                        style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:<%= color %>"><%= perf %>%</span>
                                                </div>
                                                <div class="pb-wrap">
                                                    <div class="pb" style="width:<%= perf %>%;background:<%= color %>"></div>
                                                </div>
                                            </div>
                                            <% } %>
                                            <% if(assignedClasses.isEmpty()) { %>
                                                <div class="text-center py-4 text-muted">Performance data available nahi hai.</div>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-12 col-lg-6">
                                    <div class="cbox">
                                        <div class="chead"><i class="bi bi-clipboard2-check-fill"
                                                style="color:var(--yellow)"></i>
                                            <h6>Pending Assignment Reviews</h6><a
                                                onclick="showPage('assignments')"
                                                class="ms-auto"
                                                style="font-size:12px;color:var(--accent);cursor:pointer;text-decoration:none;font-weight:600">Sabhi
                                                →</a>
                                        </div>
                                        <div class="cbody">
                                            <% 
                                                int dIdx = 0;
                                                for(Map<String, String> pa : pendingAsgns) {
                                                    if(dIdx >= 3) break;
                                                    String tag = pa.get("tag");
                                                    String tagCls = "tg";
                                                    if("Urgent".equals(tag)) tagCls = "tr";
                                                    else if("Soon".equals(tag)) tagCls = "ty";

                                                    String[] asgnIcons = {"bi-flask-fill", "bi-lightning-fill", "bi-wind", "bi-atom", "bi-soundwave"};
                                                    String[] asgnBgs = {"#dcfce7", "#dbeafe", "#ede9fe", "#fef3c7", "#fee2e2"};
                                                    String[] asgnCls = {"#16a34a", "#2563eb", "#7c3aed", "#d97706", "#dc2626"};

                                                    String bg = asgnBgs[dIdx % asgnBgs.length];
                                                    String cl = asgnCls[dIdx % asgnCls.length];
                                                    String ico = asgnIcons[dIdx % asgnIcons.length];
                                            %>
                                            <div class="arow">
                                                <div class="aico" style="background:<%= bg %>;color:<%= cl %>"><i class="bi <%= ico %>"></i></div>
                                                <div class="ainfo">
                                                    <p><%= pa.get("title") %> (<%= pa.get("class") %>)</p>
                                                    <small><%= pa.get("subs") %> submissions pending</small>
                                                </div><span class="tag <%= tagCls %>"><%= tag %></span>
                                            </div>
                                            <% 
                                                    dIdx++;
                                                } 
                                                if(pendingAsgns.isEmpty()) {
                                            %>
                                                <div class="text-center py-4 text-muted">Koi pending assignments nahi hain. ✨</div>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-12 col-lg-6">
                                    <div class="cbox">
                                        <div class="chead"><i class="bi bi-calendar2-x-fill"
                                                style="color:var(--red)"></i>
                                            <h6>Leave Summary</h6><a
                                                onclick="showPage('leave',document.querySelector('[onclick*=leave]'))"
                                                class="ms-auto"
                                                style="font-size:12px;color:var(--accent);cursor:pointer;text-decoration:none;font-weight:600">Manage
                                                →</a>
                                        </div>
                                        <div class="cbody">
                                            <div class="row g-2 mb-3">
                                                <div class="col-4">
                                                    <div
                                                        style="background:#dcfce7;border-radius:12px;padding:12px;text-align:center">
                                                        <div
                                                            style="font-size:22px;font-weight:800;font-family:'JetBrains Mono',monospace;color:#16a34a">
                                                            <%= totalLeaveAvailable %></div>
                                                        <div style="font-size:11px;color:#16a34a;font-weight:600">
                                                            Available
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-4">
                                                    <div
                                                        style="background:#fee2e2;border-radius:12px;padding:12px;text-align:center">
                                                        <div
                                                            style="font-size:22px;font-weight:800;font-family:'JetBrains Mono',monospace;color:#dc2626">
                                                            <%= totalLeaveUsed %></div>
                                                        <div style="font-size:11px;color:#dc2626;font-weight:600">
                                                            Used
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-4">
                                                    <div
                                                        style="background:#fef3c7;border-radius:12px;padding:12px;text-align:center">
                                                        <div
                                                            style="font-size:22px;font-weight:800;font-family:'JetBrains Mono',monospace;color:#d97706">
                                                            <%= pendingLeaveCount %></div>
                                                        <div style="font-size:11px;color:#d97706;font-weight:600">
                                                            Pending
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <button class="btn-a" style="width:100%;justify-content:center"
                                                onclick="showPage('leave',document.querySelector('[onclick*=leave]'))"><i
                                                    class="bi bi-plus-lg"></i> Naya Leave Apply Karo</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="page" id="page-profile">
                            <div class="prof-hero">
                                <button class="pedit-btn" onclick="openEditModal()"><i
                                        class="bi bi-pencil-fill"></i><span>Profile Edit
                                        Karo</span></button>
                                <div class="pav-wrap">
                                    <div class="pav">
                                        <img src="<%= tPhotoBase64 != null ? " data:image/jpeg;base64," + tPhotoBase64
                                            : "images/user_default_photo.webp" %>"
                                        style="width:100%;height:100%;object-fit:cover;" id="profile-photo"/>
                                    </div>
                                    <div class="pav-cam" onclick="document.getElementById('av-hero-input').click()">
                                        <i class="bi bi-camera-fill"></i>
                                    </div>
                                </div>
                                <h3 id="profile-name">
                                    <%= tName %>
                                </h3>
                                <div class="prole" id="profile-role">
                                    <%= tSubject %> • <%= myClassesCount %> Active Classes
                                </div>
                                <div class="ptags">
                                    <span class="ptag" id="profile-dept-tag"><i class="bi bi-diagram-3-fill"></i>
                                        <%= tDept %>
                                    </span>

                                    <span class="ptag"
                                        style="background:rgba(34,197,94,.15);border-color:rgba(34,197,94,.3);color:var(--accent)">Active
                                        Staff</span>
                                </div>
                            </div>

                            <% if (!hasPersonalInfo && !hasProfessionalInfo) { %>
                                <div class="cbox p-5 text-center mb-4">
                                    <i class="bi bi-person-exclamation"
                                        style="font-size: 48px; color: var(--accent); opacity: 0.5;"></i>
                                    <h5 class="mt-3" style="font-weight: 700;">Profile Incomplete Hai</h5>
                                    <p class="text-muted">Your Profile is currently incomplete. Please, click on edit
                                        profile and fill all the details.</p>
                                    <button class="btn-a mx-auto mt-2" onclick="openEditModal()">
                                        <i class="bi bi-pencil-fill me-2"></i>Edit Profile
                                    </button>
                                </div>
                                <% } %>

                                    <div class="row g-3">
                                        <% if (hasPersonalInfo) { %>
                                            <div class="col-12 col-lg-7">
                                                <div class="cbox">
                                                    <div class="chead"><i class="bi bi-person-fill"
                                                            style="color:var(--accent)"></i>
                                                        <h6>Personal Information</h6>
                                                    </div>
                                                    <div class="cbody">
                                                        <div class="row g-3">
                                                            <div class="col-6">
                                                                <div class="ilabel">Full Name</div>
                                                                <div class="ival" id="info-name">
                                                                    <%= tName %>
                                                                </div>
                                                            </div>
                                                            <div class="col-6">
                                                                <div class="ilabel">Date of Birth</div>
                                                                <div class="ival" id="info-dob">
                                                                    <%= tDob %>
                                                                </div>
                                                            </div>
                                                            <div class="col-6">
                                                                <div class="ilabel">Gender</div>
                                                                <div class="ival" id="info-gender">
                                                                    <%= tGender %>
                                                                </div>
                                                            </div>
                                                            <div class="col-6">
                                                                <div class="ilabel">Blood Group</div>
                                                                <div class="ival" id="info-blood">
                                                                    <%= tBlood %>
                                                                </div>
                                                            </div>
                                                            <div class="col-6">
                                                                <div class="ilabel">Phone Number</div>
                                                                <div class="ival" id="info-phone">
                                                                    <%= tPhone %>
                                                                </div>
                                                            </div>
                                                            <div class="col-6">
                                                                <div class="ilabel">Email</div>
                                                                <div class="ival" id="info-email">
                                                                    <%= tEmail %>
                                                                </div>
                                                            </div>
                                                            <div class="col-12">
                                                                <div class="ilabel">Address</div>
                                                                <div class="ival" id="info-address">
                                                                    <%= tAddress %>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <% } %>

                                                <div class="col-12 col-lg-5">
                                                    <% if (hasProfessionalInfo) { %>
                                                        <div class="cbox mb-3">
                                                            <div class="chead"><i class="bi bi-briefcase-fill"
                                                                    style="color:var(--blue)"></i>
                                                                <h6>Professional Details</h6>
                                                            </div>
                                                            <div class="cbody">
                                                                <div class="row g-3">
                                                                    <div class="col-12">
                                                                        <div class="ilabel">Subject</div>
                                                                        <div class="ival" id="info-subject">
                                                                            <%= tSubject %>
                                                                        </div>
                                                                    </div>
                                                                    <div class="col-6">
                                                                        <div class="ilabel">Department</div>
                                                                        <div class="ival" id="info-dept">
                                                                            <%= tDept %>
                                                                        </div>
                                                                    </div>
                                                                    <div class="col-6">
                                                                        <div class="ilabel">Employee ID</div>
                                                                        <div class="ival"
                                                                            style="font-family:'JetBrains Mono',monospace">
                                                                            <%= tEmpId %>
                                                                        </div>
                                                                    </div>
                                                                    <div class="col-6">
                                                                        <div class="ilabel">Qualification</div>
                                                                        <div class="ival" id="info-qual">
                                                                            <%= tQual %>
                                                                        </div>
                                                                    </div>
                                                                    <div class="col-6">
                                                                        <div class="ilabel">Experience</div>
                                                                        <div class="ival">
                                                                            <%= tExp %>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <% } %>

                                                            <div class="cbox">
                                                                <div class="chead"><i class="bi bi-calendar2-x-fill"
                                                                        style="color:var(--red)"></i>
                                                                    <h6>Leave Balance</h6>
                                                                </div>
                                                                <div class="cbody">
                                                                    <div class="row g-2">
                                                                        <div class="col-6">
                                                                            <div
                                                                                style="border:1.5px solid var(--border);border-radius:12px;padding:12px;text-align:center">
                                                                                <div
                                                                                    style="font-size:20px;font-weight:800;font-family:'JetBrains Mono',monospace;color:#16a34a">
                                                                                    <%= (casualTotal - casualUsed) %></div>
                                                                                <div
                                                                                    style="font-size:11px;color:var(--muted);font-weight:600">
                                                                                    Casual Leave
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                        <div class="col-6">
                                                                            <div
                                                                                style="border:1.5px solid var(--border);border-radius:12px;padding:12px;text-align:center">
                                                                                <div
                                                                                    style="font-size:20px;font-weight:800;font-family:'JetBrains Mono',monospace;color:#2563eb">
                                                                                    <%= (medicalTotal - medicalUsed) %></div>
                                                                                <div
                                                                                    style="font-size:11px;color:var(--muted);font-weight:600">
                                                                                    Medical Leave
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                        <div class="col-6">
                                                                            <div
                                                                                style="border:1.5px solid var(--border);border-radius:12px;padding:12px;text-align:center">
                                                                                <div
                                                                                    style="font-size:20px;font-weight:800;font-family:'JetBrains Mono',monospace;color:#d97706">
                                                                                    <%= (earnedTotal - earnedUsed) %></div>
                                                                                <div
                                                                                    style="font-size:11px;color:var(--muted);font-weight:600">
                                                                                    Earned Leave
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                        <div class="col-6">
                                                                            <div
                                                                                style="border:1.5px solid var(--border);border-radius:12px;padding:12px;text-align:center">
                                                                                <div
                                                                                    style="font-size:20px;font-weight:800;font-family:'JetBrains Mono',monospace;color:#7c3aed">
                                                                                    <%= totalLeaveUsed %></div>
                                                                                <div
                                                                                    style="font-size:11px;color:var(--muted);font-weight:600">
                                                                                    Used
                                                                                    (Total)
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                </div> 
                                    </div> 
                        </div> 

                        <div class="page" id="page-myclasses">
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>My Classes</h4>
                                    <p>Assigned classes aur unke students</p>
                                </div>
                            </div>
                            <div class="row g-3 mb-3">
                                <div class="col-6 col-md-3">
                                    <div class="mstat">
                                        <div class="mstat-ico" style="background:#dcfce7;color:#16a34a"><i
                                                class="bi bi-easel2-fill"></i></div>
                                        <div>
                                            <p><%= myClassesCount %></p><small>Classes</small>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="mstat">
                                        <div class="mstat-ico" style="background:#dbeafe;color:#2563eb"><i
                                                class="bi bi-people-fill"></i></div>
                                        <div>
                                            <p><%= totalStudentsCount %></p><small>Students</small>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="mstat">
                                        <div class="mstat-ico" style="background:#fef3c7;color:#d97706"><i
                                                class="bi bi-graph-up-arrow"></i></div>
                                        <div>
                                            <p><%= String.format("%.1f", classAvgPercent) %>%</p><small>Avg Score</small>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="mstat">
                                        <div class="mstat-ico" style="background:#ede9fe;color:#7c3aed"><i
                                                class="bi bi-calendar-check-fill"></i></div>
                                        <div>
                                            <%

                                                int totalPres = 0;
                                                try {
                                                    for(Map<String, String> c : assignedClasses) {
                                                        String pt = c.get("present_today");
                                                        if(pt != null && !pt.isEmpty()) {
                                                            totalPres += Integer.parseInt(pt);
                                                        }
                                                    }
                                                } catch(Exception e) { System.err.println("Error calc avg attendance: " + e.getMessage()); }
                                                double avgAtt = totalStudentsCount > 0 ? (double)totalPres / totalStudentsCount * 100 : 0;
                                            %>
                                            <p><%= String.format("%.1f", avgAtt) %>%</p><small>Today Att.</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row g-3">
                                <%
                                    String[] cardColors = {"#dcfce7", "#dbeafe", "#ede9fe", "#fef3c7", "#fee2e2", "#e0f2fe"};
                                    String[] iconColors = {"#16a34a", "#2563eb", "#7c3aed", "#d97706", "#dc2626", "#0369a1"};
                                    int cardIdx = 0;
                                    for(Map<String, String> c : assignedClasses) {
                                        String bg = cardColors[cardIdx % cardColors.length];
                                        String ic = iconColors[cardIdx % iconColors.length];
                                        String perf = c.get("performance");
                                        cardIdx++;
                                %>
                                <div class="col-md-6">
                                    <div class="cbox p-4">
                                        <div class="d-flex align-items-center gap-3 mb-3">
                                            <div class="stat-ico"
                                                style="background:<%= bg %>;color:<%= ic %>;width:46px;height:46px;border-radius:13px;display:flex;align-items:center;justify-content:center;font-size:20px">
                                                <i class="bi bi-easel2-fill"></i>
                                            </div>
                                            <div>
                                                <div style="font-weight:700;font-size:15px">Class <%= c.get("class") %>-<%= c.get("section") %></div>
                                                <div style="font-size:12px;color:var(--muted)"><%= c.get("student_count") %> Students</div>
                                            </div><span class="ms-auto tag tg"><%= perf %>%</span>
                                        </div>
                                        <div class="mb-2">
                                            <div class="d-flex justify-content-between mb-1"><span
                                                    style="font-size:12px;color:var(--muted)">Class
                                                    Average</span><span
                                                    style="font-size:12px;font-weight:700"><%= perf %>%</span>
                                            </div>
                                            <div class="pb-wrap">
                                                <div class="pb" style="width:<%= perf %>%;background:<%= ic %>"></div>
                                            </div>
                                        </div>
                                        <div class="d-flex justify-content-between"
                                            style="font-size:12px;color:var(--muted)">
                                            <span>Present Today: <b style="color:#16a34a"><%= c.get("present_today") %>/<%= c.get("student_count") %></b></span>
                                            <span>Absent Today: <b style="color:var(--red)"><%= c.get("absent_today") %></b></span>
                                        </div>
                                    </div>
                                </div>
                                <% } %>
                                <% if(assignedClasses.isEmpty()) { %>
                                    <div class="col-12 text-center py-5 text-muted">Aapko koi classes assign nahi ki gayi hain.</div>
                                        <% } %>
                            </div>
                        </div>

                        <div class="page" id="page-timetable">
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>My Timetable</h4>
                                    <p>Weekly teaching schedule</p>
                                </div>
                            </div>
                            <div class="cbox">
                                <div class="chead">
                                    <h6>Weekly Schedule — <%= tName != null ? tName : "Teacher" %> (<%= tSubject != null ? tSubject.replace(" Teacher", "") : "Subject" %>)</h6>
                                </div>
                                <div class="cbody">
                                    <div class="table-responsive">
                                        <table class="table tbl mb-0 text-center">
                                            <thead>
                                                <tr>
                                                    <th>Time</th>
                                                    <th>Monday</th>
                                                    <th>Tuesday</th>
                                                    <th>Wednesday</th>
                                                    <th>Thursday</th>
                                                    <th>Friday</th>
                                                    <th>Saturday</th>
                                                </tr>
                                            </thead>
                                            <tbody style="font-size:13px">
                                                <%
                                                    Connection connTTW = null;
                                                    Map<String, String> classColors = new HashMap<>();
                                                    try {
                                                        connTTW = DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root" , "" );
                                                        String[] days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
                                                        String ttWeeklySql = "SELECT day, start_time, end_time, class, section, subject, room FROM timetable WHERE teacher_id = ? ORDER BY start_time";
                                                        PreparedStatement psTTW = connTTW.prepareStatement(ttWeeklySql);
                                                        psTTW.setString(1, tId);
                                                        ResultSet rsTTW = psTTW.executeQuery();

                                                        Map<String, Map<String, String[]>> scheduleMap = new LinkedHashMap<>();
                                                        java.util.Set<String> uniqueClasses = new java.util.LinkedHashSet<>();
                                                        while(rsTTW.next()) {
                                                            String stW = rsTTW.getString("start_time");
                                                            String etW = rsTTW.getString("end_time");
                                                            String timeKey = ((stW != null && stW.length() >= 5) ? stW.substring(0,5) : "00:00") + "–" + ((etW != null && etW.length() >= 5) ? etW.substring(0,5) : "00:00");
                                                            String dayName = rsTTW.getString("day");
                                                            String classVal = rsTTW.getString("class") + "-" + rsTTW.getString("section");
                                                            String subjectVal = rsTTW.getString("subject");

                                                            if(!scheduleMap.containsKey(timeKey)) scheduleMap.put(timeKey, new HashMap<>());
                                                            scheduleMap.get(timeKey).put(dayName, new String[]{classVal, subjectVal});
                                                            uniqueClasses.add(classVal);
                                                        }

                                                        String[] colors = {"#22c55e", "#3b82f6", "#8b5cf6", "#f59e0b", "#ef4444", "#06b6d4"};
                                                        int colorIdx = 0;
                                                        for(String c : uniqueClasses) {
                                                            classColors.put(c, colors[colorIdx % colors.length]);
                                                            colorIdx++;
                                                        }

                                                        if(scheduleMap.isEmpty()) {
                                                %>
                                                    <tr><td colspan="7" class="text-center py-4 text-muted">Aapka weekly timetable abhi tak set nahi kiya gaya hai.</td></tr>
                                                <%
                                                        } else {
                                                            for(String time : scheduleMap.keySet()) {
                                                %>
                                                    <tr>
                                                        <td style="font-family:'JetBrains Mono',monospace;font-size:12px"><%= time %></td>
                                                        <% for(String d : days) { 
                                                            String[] slotData = scheduleMap.get(time).get(d);
                                                            String clsValue = slotData != null ? slotData[0] : null;
                                                            String subValue = slotData != null ? slotData[1] : null;
                                                        %>
                                                            <td style="font-weight:600;color:<%= clsValue != null ? classColors.get(clsValue) : "var(--muted)" %>; vertical-align:middle;">
                                                                <% if(clsValue != null) { %>
                                                                    <%= clsValue %><br>
                                                                    <small style="color:var(--muted); font-weight:400; font-size:11px"><%= subValue %></small>
                                                                <% } else { %>
                                                                    —
                                                                <% } %>
                                                            </td>
                                                        <% } %>
                                                    </tr>
                                                <%
                                                            }
                                                        }
                                                    } catch(Exception e) { 
                                                        e.printStackTrace(); 
                                                    } finally {
                                                        if (connTTW != null) try { connTTW.close(); } catch(Exception e) {}
                                                    }
                                                %>
                                            </tbody>
                                        </table>
                                    </div>
                                    <div class="d-flex gap-3 flex-wrap mt-3">
                                        <% if(classColors != null && !classColors.isEmpty()) { 
                                            for(Map.Entry<String, String> entry : classColors.entrySet()) {
                                        %>
                                        <span style="font-size:12px;display:flex;align-items:center;gap:6px"><span
                                                style="width:12px;height:12px;background:<%= entry.getValue() %>;border-radius:3px;display:inline-block"></span>Class <%= entry.getKey() %></span>
                                        <% 
                                            } } 
                                        %>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="page" id="page-attendance">
                             <%
                                String selClass = request.getParameter("class");
                                String selSec = request.getParameter("section");

                                if ("null".equals(selClass)) selClass = null;
                                if ("null".equals(selSec)) selSec = null;

                                if(selClass == null && assignedClasses != null && assignedClasses.size() > 0) {

                                }
                            %>
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>Mark Attendance</h4>
                                    <p><%= (selClass == null) ? "Kripya class aur section choose karein" : "Class-wise attendance mark karo" %></p>
                                </div>
                                <% if(selClass != null) { %>
                                <div class="d-flex gap-2">
                                    <button onclick="window.location.href='?page=attendance'" class="btn-o"><i class="bi bi-arrow-left"></i> Change Class</button>
                                    <a href="/markAttendance?class=<%= selClass %>&section=<%= selSec %>&teacher_id=<%= tId %>" class="btn-a" style="text-decoration:none">
                                        <i class="bi bi-pencil-square"></i> Save Attendance
                                    </a>
                                </div>
                                <% } %>
                            </div>

                            <% if(selClass == null) { %>
                                <div class="cbox">
                                    <div class="chead">
                                        <h6>Apni Class Choose Karein</h6>
                                    </div>
                                    <div class="cbody">
                                        <% if(assignedClasses != null && !assignedClasses.isEmpty()) { %>
                                            <div class="row g-3">
                                                <% 
                                                    int cIdx = 0;
                                                    for(Map<String, String> c : assignedClasses) { 
                                                        String bg = cardColors[cIdx % cardColors.length];
                                                        String ic = iconColors[cIdx % iconColors.length];
                                                        cIdx++;
                                                %>
                                                <div class="col-md-4">
                                                    <div class="ltype" onclick="selectClassAndReload('<%= c.get("class") %>', '<%= c.get("section") %>')" style="padding: 20px;">
                                                        <i class="bi bi-easel2-fill" style="color:<%= ic %>; font-size: 28px;"></i>
                                                        <div style="font-weight: 700; font-size: 16px; margin: 8px 0 4px;">Class <%= c.get("class") %>-<%= c.get("section") %></div>
                                                        <small style="color: var(--muted);"><%= c.get("student_count") %> Students Assigned</small>
                                                    </div>
                                                </div>
                                                <% } %>
                                            </div>
                                        <% } else { %>
                                            <div class="text-center py-5">
                                                <i class="bi bi-exclamation-circle" style="font-size: 48px; color: var(--muted); opacity: 0.5;"></i>
                                                <h5 class="mt-3">Aapko koi class assign nahi ki gayi hai</h5>
                                                <p class="text-muted">Kripya Admin se sampark karein (Teacher ID: <%= tId %>)</p>
                                            </div>
                                        <% } %>
                                    </div>
                                </div>
                            <% } else { %>

                            <div class="cbox mb-3">
                                <div class="chead">
                                    <h6>Select Class</h6>
                                </div>
                                <div class="cbody">
                                    <div class="row g-2">
                                        <%
                                            String[] classColorsArray = {"#16a34a", "#2563eb", "#8b5cf6", "#f59e0b", "#ef4444", "#06b6d4"};
                                            int colorIdx = 0;
                                            if(assignedClasses != null) {
                                                for(Map<String, String> c : assignedClasses) {
                                                    boolean isSelected = c.get("class").equals(selClass) && c.get("section").equals(selSec);
                                                    String color = classColorsArray[colorIdx % classColorsArray.length];
                                                    colorIdx++;
                                        %>
                                        <div class="col-6 col-md-3">
                                            <div class="ltype <%= isSelected ? "sel" : "" %>" onclick="selectClassAndReload('<%= c.get("class") %>', '<%= c.get("section") %>')">
                                                <i class="bi bi-easel2-fill" style="color:<%= color %>"></i>
                                                <span>Class <%= c.get("class") %>-<%= c.get("section") %></span>
                                                <small><%= c.get("student_count") %> Students</small>
                                            </div>
                                        </div>
                                        <%      } 
                                            }
                                        %>
                                        <% if(assignedClasses == null || assignedClasses.isEmpty()) { %>
                                            <div class="col-12 text-center py-3 text-muted">Aapko koi class assign nahi ki gayi hai.</div>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                            <div class="cbox">
                                <div class="chead">
                                    <h6 id="att-class-title">Class <%= selClass != null ? selClass + "-" + selSec : "..." %> — Attendance (<span id="att-date-val">...</span>)</h6>
                                </div>
                                <form action="/saveAttendance" method="post" id="attendance-form">
                                    <input type="hidden" name="class" value="<%= selClass %>">
                                    <input type="hidden" name="section" value="<%= selSec %>">
                                    <input type="hidden" name="teacher_id" value="<%= tId %>">

                                    <div class="table-responsive">
                                        <table class="table tbl mb-0">
                                            <thead>
                                                <tr>
                                                    <th>#</th>
                                                    <th>Student Name</th>
                                                    <th>Roll No.</th>
                                                    <th>Present</th>
                                                    <th>Absent</th>
                                                    <th style="width:100px">Status Today</th>
                                                </tr>
                                            </thead>
                                            <tbody id="att-tbody">
                                                <%
                                                    if(selClass != null) {
                                                        Connection connAtt = null;
                                                        try {
                                                            connAtt = DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root", "");
                                                            String studentSql = "SELECT s.student_id, s.name, s.roll_no, a.status FROM students s " +
                                                                              "LEFT JOIN attendance a ON s.student_id = a.student_id AND a.date = CURDATE() " +
                                                                              "WHERE s.class = ? AND s.section = ? ORDER BY s.roll_no";
                                                            PreparedStatement psAtt = connAtt.prepareStatement(studentSql);
                                                            psAtt.setString(1, selClass);
                                                            psAtt.setString(2, selSec);
                                                            ResultSet rsAtt = psAtt.executeQuery();
                                                            int count = 0;
                                                            while(rsAtt.next()) {
                                                                count++;
                                                                String sid = rsAtt.getString("student_id");
                                                                String name = rsAtt.getString("name");
                                                                String roll = rsAtt.getString("roll_no");
                                                                String statusToday = rsAtt.getString("status");
                                                                String initials = "";
                                                                if(name != null && name.length() > 0) {
                                                                    String[] parts = name.split(" ");
                                                                    initials = parts[0].substring(0,1).toUpperCase();
                                                                    if(parts.length > 1) initials += parts[1].substring(0,1).toUpperCase();
                                                                }

                                                                String[] colorP = {"#dcfce7", "#dbeafe", "#fef3c7", "#ede9fe"};
                                                                String[] textP = {"#16a34a", "#2563eb", "#d97706", "#7c3aed"};
                                                                String pCol = colorP[count % 4];
                                                                String tCol = textP[count % 4];

                                                                boolean isMarked = (statusToday != null);
                                                %>
                                                <tr>
                                                    <td><%= count %></td>
                                                    <td>
                                                        <div class="d-flex align-items-center gap-2">
                                                            <div class="avsm" style="background:<%= pCol %>;color:<%= tCol %>"><%= initials %></div>
                                                            <%= name %>
                                                        </div>
                                                        <input type="hidden" name="student_ids" value="<%= sid %>">
                                                    </td>
                                                    <td style="font-family:'JetBrains Mono',monospace">#<%= roll %></td>
                                                    <td>
                                                        <% if(isMarked) { %>
                                                            <% if("present".equalsIgnoreCase(statusToday)) { %>
                                                                <i class="bi bi-check-circle-fill text-success" style="font-size:18px"></i>
                                                            <% } else { %>
                                                                <i class="bi bi-circle text-muted" style="opacity:0.3"></i>
                                                            <% } %>
                                                        <% } else { %>
                                                            <input type="radio" name="status_<%= sid %>" value="present" checked class="form-check-input" />
                                                        <% } %>
                                                    </td>
                                                    <td>
                                                        <% if(isMarked) { %>
                                                            <% if("absent".equalsIgnoreCase(statusToday)) { %>
                                                                <i class="bi bi-x-circle-fill text-danger" style="font-size:18px"></i>
                                                            <% } else { %>
                                                                <i class="bi bi-circle text-muted" style="opacity:0.3"></i>
                                                            <% } %>
                                                        <% } else { %>
                                                            <input type="radio" name="status_<%= sid %>" value="absent" class="form-check-input" />
                                                        <% } %>
                                                    </td>
                                                    <td>
                                                        <% if(isMarked) { %>
                                                            <span class="tag <%= "present".equalsIgnoreCase(statusToday) ? "tg" : "tr" %>"><%= statusToday %></span>
                                                        <% } else { %>
                                                            <span class="tag ty">Not Marked</span>
                                                        <% } %>
                                                    </td>
                                                </tr>
                                                <%
                                                            }
                                                            if(count == 0) {
                                                                out.println("<tr><td colspan='6' class='text-center py-4 text-muted'>Is class mein koi students nahi hain.</td></tr>");
                                                            }
                                                        } catch(Exception e) {
                                                            e.printStackTrace();
                                                        } finally {
                                                            if(connAtt != null) try { connAtt.close(); } catch(Exception e) {}
                                                        }
                                                    }
                                                %>
                                            </tbody>
                                        </table>
                                    </div>
                                    <button type="submit" id="att-submit-btn" style="display:none"></button>
                                </form>
                            </div>
                            <% } %>
                        </div>

                        <div class="page" id="page-assignments">
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>Assignments</h4>
                                    <p>Assignments create karo aur submissions review karo</p>
                                </div>
                                <button class="btn-a" onclick="openAssignmentModal()"><i class="bi bi-plus-lg"></i> Naya Assignment Do</button>
                            </div>

                            <div class="cbox mb-3">
                                <div class="chead"><i class="bi bi-hourglass-split" style="color:var(--red)"></i>
                                    <h6>Review Pending (<%= pendingAsgns.size() %>)</h6>
                                </div>
                                <div class="cbody">
                                    <% 
                                        String[] asgnIcons = {"bi-flask-fill", "bi-lightning-fill", "bi-wind", "bi-atom", "bi-soundwave"};
                                        String[] asgnBgs = {"#dcfce7", "#dbeafe", "#ede9fe", "#fef3c7", "#fee2e2"};
                                        String[] asgnCls = {"#16a34a", "#2563eb", "#7c3aed", "#d97706", "#dc2626"};
                                        int aIdx = 0;
                                        for(Map<String, String> pa : pendingAsgns) {
                                            String bg = asgnBgs[aIdx % asgnBgs.length];
                                            String cl = asgnCls[aIdx % asgnCls.length];
                                            String ico = asgnIcons[aIdx % asgnIcons.length];
                                            String tag = pa.get("tag");
                                            String tagCls = "tg";
                                            if("Urgent".equals(tag)) tagCls = "tr";
                                            else if("Soon".equals(tag)) tagCls = "ty";
                                            aIdx++;
                                    %>
                                    <div class="arow">
                                        <div class="aico" style="background:<%= bg %>;color:<%= cl %>"><i class="bi <%= ico %>"></i></div>
                                        <div class="ainfo">
                                            <p><%= pa.get("title") %></p>
                                            <small>Class <%= pa.get("class") %> • <%= pa.get("subs") %> submissions • Due: <%= pa.get("due") %></small>
                                            <% if(pa.get("docs") != null && !pa.get("docs").isEmpty()) { %>
                                                <div class="mt-1"><a href="<%= pa.get("docs") %>" target="_blank" style="font-size:11px;color:var(--accent);text-decoration:none"><i class="bi bi-paperclip"></i> Attachment View Karein</a></div>
                                            <% } %>
                                        </div>
                                        <div class="d-flex align-items-center gap-2">
                                            <a href="/reviewSubmissions?assignment_id=<%= pa.get("id") %>" class="tag tb" style="text-decoration:none">Review</a>
                                            <span class="tag <%= tagCls %>"><%= tag %></span>
                                        </div>
                                    </div>
                                    <% } %>
                                    <% if(pendingAsgns.isEmpty()) { %>
                                        <div class="text-center py-4 text-muted">Aapka inbox saaf hai! Koi pending assignments nahi hain. ✨</div>
                                    <% } %>
                                </div>
                            </div>

                            <div class="cbox">
                                <div class="chead"><i class="bi bi-check-circle-fill" style="color:var(--green)"></i>
                                    <h6>Completed (<%= completedAsgns.size() %>)</h6>
                                </div>
                                <div class="cbody">
                                    <% for(Map<String, String> ca : completedAsgns) { %>
                                    <div class="arow">
                                        <div class="aico" style="background:#dcfce7;color:#16a34a"><i class="bi bi-check2-circle"></i></div>
                                        <div class="ainfo">
                                            <p><%= ca.get("title") %></p><small>Class <%= ca.get("class") %> • Graded • <%= ca.get("subs") %> submissions</small>
                                        </div>
                                        <div class="d-flex align-items-center gap-2">
                                            <a href="/reviewSubmissions?assignment_id=<%= ca.get("id") %>" class="tag tb" style="text-decoration:none">Review</a>
                                            <span class="tag tg">Graded ✓</span>
                                        </div>
                                    </div>
                                    <% } %>
                                    <% if(completedAsgns.isEmpty()) { %>
                                        <div class="text-center py-4 text-muted">Abhi tak koi completed assignments nahi hain.</div>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <div class="page" id="page-results">
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>Results & Marks</h4>
                                    <p>Apni classes ke exam results enter karo</p>
                                </div>
                                <button class="btn-a" onclick="window.location.href='/uploadResults'"><i class="bi bi-upload"></i> Marks Upload Karo</button>
                            </div>
                            <div class="row g-3 mb-3">
                                <div class="col-md-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#dcfce7;color:#16a34a"><i
                                                class="bi bi-trophy-fill"></i>
                                        </div>
                                        <h3><%= String.format("%.1f", classAvgPercent) %>%</h3>
                                        <p>Overall Average</p><span class="tag tg">All Classes</span>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#dbeafe;color:#2563eb"><i
                                                class="bi bi-star-fill"></i>
                                        </div>
                                        <h3><%= totalDistinctions %></h3>
                                        <p>Distinctions</p><span class="tag tb">80%+</span>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#fee2e2;color:#dc2626"><i
                                                class="bi bi-x-circle-fill"></i></div>
                                        <h3><%= totalFailed %></h3>
                                        <p>Failed</p><span class="tag tr">Needs Help</span>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#ede9fe;color:#7c3aed"><i
                                                class="bi bi-people-fill"></i>
                                        </div>
                                        <h3><%= totalStudentsCount %></h3>
                                        <p>Total Students</p>
                                    </div>
                                </div>
                            </div>
                            <div class="cbox">
                                <div class="chead">
                                    <h6>Performance Summary — <%= tSubject.replace(" Teacher", "") %></h6>
                                    <div class="ms-auto"><button class="btn-o"
                                            style="font-size:12px;padding:6px 14px"><i class="bi bi-download"></i>
                                            Export</button></div>
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
                                            <% for(Map<String, Object> r : resultsSummary) { 
                                                String avg = (String)r.get("avg_perc");
                                                String high = (String)r.get("highest");
                                            %>
                                            <tr>
                                                <td style="font-weight:700">Class <%= r.get("class") %></td>
                                                <td><%= r.get("total_students") %></td>
                                                <td><%= r.get("appeared") %></td>
                                                <td style="color:#16a34a;font-weight:700"><%= r.get("passed") %></td>
                                                <td style="color:var(--red);font-weight:700"><%= r.get("failed") %></td>
                                                <td style="font-family:'JetBrains Mono',monospace;font-weight:700">
                                                    <%= avg %>%
                                                </td>
                                                <td><span class="tag tg"><%= high %>%</span></td>
                                            </tr>
                                            <% } %>
                                            <% if(resultsSummary.isEmpty()) { %>
                                                <tr><td colspan="7" class="text-center py-4 text-muted">Aapki classes ka koi result record nahi mila.</td></tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                        <div class="page" id="page-leave">
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>Leave Management</h4>
                                    <p>Apne leaves track karo aur naye apply karo</p>
                                </div>
                                <button class="btn-a" onclick="openLeaveModal()"><i class="bi bi-plus-lg"></i> Naya Leave
                                    Apply Karo</button>
                            </div>

                            <% 

                                if (tId == null || tId.isEmpty()) {
                                    out.println("<div class='alert alert-warning'>Teacher profile incomplete. Please update your profile to use leave features.</div>");
                                } else {
                            %>

                            <div class="lq-grid mb-4">
                                <div class="stat">
                                    <div class="stat-ico" style="background:#dcfce7;color:#16a34a"><i
                                            class="bi bi-calendar-check"></i></div>
                                    <h3><%= totalLeaveAvailable %></h3>
                                    <p>Available Leaves</p><span class="tag tg">Current Year</span>
                                </div>
                                <div class="stat">
                                    <div class="stat-ico" style="background:#fee2e2;color:#dc2626"><i
                                            class="bi bi-calendar-x"></i></div>
                                    <h3><%= totalLeaveUsed %></h3>
                                    <p>Used Leaves</p><span class="tag tr">Approved</span>
                                </div>
                                <div class="stat">
                                    <div class="stat-ico" style="background:#fef3c7;color:#d97706"><i
                                            class="bi bi-clock-history"></i></div>
                                    <h3><%= pendingLeaveCount %></h3>
                                    <p>Pending Requests</p><span class="tag ty">Wait for Admin</span>
                                </div>
                                <div class="stat">
                                    <div class="stat-ico" style="background:#dbeafe;color:#2563eb"><i
                                            class="bi bi-info-circle"></i></div>
                                    <h3><%= totalLeaveAllotted %></h3>
                                    <p>Total Allotted</p><span class="tag tb">Per Annum</span>
                                </div>
                            </div>

                            <div class="row g-3">
                                <div class="col-12 col-lg-4">
                                    <div class="cbox">
                                        <div class="chead"><i class="bi bi-pie-chart-fill" style="color:var(--accent)"></i>
                                            <h6>Leave Types & Balance</h6>
                                        </div>
                                        <div class="cbody">
                                            <div class="l-item">
                                                <div class="li-info">
                                                    <p>Casual Leave</p><small><%= casualUsed %> used / <%= casualTotal %> total</small>
                                                </div>
                                                <div class="li-val"><%= (casualTotal - casualUsed) %></div>
                                            </div>
                                            <div class="l-item">
                                                <div class="li-info">
                                                    <p>Medical Leave</p><small><%= medicalUsed %> used / <%= medicalTotal %> total</small>
                                                </div>
                                                <div class="li-val"><%= (medicalTotal - medicalUsed) %></div>
                                            </div>
                                            <div class="l-item">
                                                <div class="li-info">
                                                    <p>Earned Leave</p><small><%= earnedUsed %> used / <%= earnedTotal %> total</small>
                                                </div>
                                                <div class="li-val"><%= (earnedTotal - earnedUsed) %></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-12 col-lg-8">
                                    <div class="cbox">
                                        <div class="chead"><i class="bi bi-history" style="color:var(--purple)"></i>
                                            <h6>Leave Application History</h6>
                                        </div>
                                        <div class="cbody p-0">
                                            <div class="table-responsive">
                                                <table class="table tbl mb-0">
                                                    <thead>
                                                        <tr>
                                                            <th>Leave Type</th>
                                                            <th>Duration</th>
                                                            <th>Applied On</th>
                                                            <th>Status</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <%
                                                        boolean hasHistory = false;
                                                        for(Map<String, String> lh : leaveHistory) {
                                                            hasHistory = true;
                                                            String status = lh.get("status");
                                                            String statusClass = "approved".equalsIgnoreCase(status) ? "tg" : ("pending".equalsIgnoreCase(status) ? "ty" : "tr");
                                                            String leaveType = lh.get("leave_type");
                                                            String fromDate = lh.get("from_date");
                                                            String toDate = lh.get("to_date");
                                                            String daysStr = lh.get("days");
                                                            int days = 0;
                                                            try { days = Integer.parseInt(daysStr); } catch(Exception e) {}
                                                            String appliedAt = lh.get("applied_at");
                                                            String reason = lh.get("reason");
                                                        %>
                                                        <tr>
                                                            <td>
                                                                <div class="d-flex align-items-center gap-2">
                                                                    <div class="l-ico" style="background:var(--bg);color:var(--accent)"><i class="bi bi-calendar-event"></i></div>
                                                                    <div>
                                                                        <p class="mb-0 fw-bold" style="font-size:13px"><%= leaveType %></p>
                                                                        <small class="text-muted"><%= reason %></small>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <p class="mb-0" style="font-size:13px"><%= fromDate %> - <%= toDate %></p>
                                                                <small class="text-muted">(<%= days %> day<%= days != 1 ? "s" : "" %>)</small>
                                                            </td>
                                                            <td style="font-size:13px"><%= appliedAt %></td>
                                                            <td><span class="tag <%= statusClass %>"><%= status %></span></td>
                                                        </tr>
                                                        <% } 
                                                        if(!hasHistory) { %>
                                                        <tr>
                                                            <td colspan="4" class="text-center py-4 text-muted">No leave applications found.</td>
                                                        </tr>
                                                        <% } %>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <%
                                } 
                            %>
                        </div>

                        <div class="page" id="page-notices">
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>Notice Board</h4>
                                    <p>School aur admin ki sabhi notifications</p>
                                </div>
                            </div>
                            <div class="row g-3">
                                <% 
                                Connection connNT = null;
                                try {
                                    connNT = DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root", "");
                                    String ntSql = "SELECT * FROM notices WHERE target IN ('all', 'teachers') AND student_id IS NULL ORDER BY published_at DESC";
                                    ResultSet rsNT = connNT.createStatement().executeQuery(ntSql);
                                    boolean hasNoticesT = false;
                                    while(rsNT.next()) {
                                        hasNoticesT = true;
                                        String title = rsNT.getString("title");
                                        String msg = rsNT.getString("message");
                                        String priority = rsNT.getString("priority");
                                        Timestamp time = rsNT.getTimestamp("published_at");

                                        String borderCol = "urgent".equals(priority) ? "var(--red)" : ("important".equals(priority) ? "var(--yellow)" : "var(--accent)");
                                        String bgCol = "urgent".equals(priority) ? "#fff5f5" : ("important".equals(priority) ? "#fffbeb" : "#f0fdf4");
                                        String tagClass = "urgent".equals(priority) ? "tag-red" : ("important".equals(priority) ? "tag-yellow" : "tag-green");
                                %>
                                <div class="col-12 notice-item" data-id="<%= rsNT.getString("notice_id") %>">
                                    <div style="<%= "border-left:4px solid " + (borderCol) + "; background:" + (bgCol) + "; border-radius:12px; padding:20px; box-shadow: 0 2px 10px rgba(0,0,0,0.02);" %>">
                                        <div class="d-flex justify-content-between align-items-start mb-2">
                                            <h6 style="font-weight:800; margin:0; color:var(--dark); font-size:16px;"><%= title %></h6>
                                            <span style="font-size:11px; color:var(--muted); font-family:'JetBrains Mono',monospace;">
                                                <%= new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(time) %>
                                            </span>
                                        </div>
                                        <p style="font-size:14px; color:#4b5563; margin-bottom:12px; line-height:1.6;"><%= msg %></p>
                                        <span class="tag <%= tagClass %>"><%= priority.toUpperCase() %></span>
                                    </div>
                                </div>
                                <% 
                                    } 
                                    if(!hasNoticesT) {
                                %>
                                <div class="col-12 text-center py-5">
                                    <i class="bi bi-bell-slash" style="font-size:40px; color:var(--muted); opacity:0.3;"></i>
                                    <p class="mt-3 text-muted">Abhi koi naya notice nahi hai.</p>
                                </div>
                                <%
                                    }
                                } catch(Exception e) { e.printStackTrace(); } finally { if(connNT != null) try { connNT.close(); } catch(Exception e) {} }
                                %>
                            </div>
                        </div>

                    </div>

                    <div class="mback" id="editModal" onclick="closeEditOutside(event)">
                        <div class="emodal">
                            <div class="ehead">
                                <h5><i class="bi bi-pencil-fill me-2" style="color:var(--accent)"></i>Profile Edit
                                    Karo
                                </h5>
                                <button class="eclose" onclick="closeEditModal()">✕</button>
                            </div>
                            <div class="ebody">
                                <form action="UpdateProfileServlet" method="post" enctype="multipart/form-data">
                                    <div class="av-up">
                                        <div class="up-prev">
                                            <img src="<%= tPhotoBase64 != null ? " data:image/jpeg;base64," +
                                                tPhotoBase64 : "images/user_default_photo.webp" %>"
                                            style="width:100%;height:100%;object-fit:cover;border-radius:12px;"
                                            id="modal-photo-preview"/>
                                        </div>
                                        <div>
                                            <div style="font-weight:700;font-size:14px;margin-bottom:4px">Profile
                                                Photo
                                            </div>
                                            <div style="font-size:12px;color:var(--muted);margin-bottom:10px">JPG,
                                                PNG.
                                                Max
                                                2MB
                                            </div>
                                            <button type="button" class="up-btn"
                                                onclick="document.getElementById('av-modal-input').click()"><i
                                                    class="bi bi-cloud-upload-fill"></i> Photo Upload Karo</button>
                                            <input type="file" name="photo" id="av-modal-input" accept="image/*"
                                                style="display:none" onchange="previewImage(this)" />
                                        </div>
                                    </div>
                                    <div class="row g-3">
                                        <div class="col-6"><label class="form-label">Full Name</label><input name="name"
                                                class="form-control" value="<%= tName %>" /></div>
                                        <div class="col-6"><label class="form-label">Date of Birth</label><input
                                                name="dob" class="form-control" type="date" value="<%= tDob %>" />
                                        </div>
                                        <div class="col-6"><label class="form-label">Gender</label><select name="gender"
                                                class="form-select">
                                                <option <%="Male" .equals(tGender) ? "selected" : "" %>>Male
                                                </option>
                                                <option <%="Female" .equals(tGender) ? "selected" : "" %>>Female
                                                </option>
                                                <option <%="Other" .equals(tGender) ? "selected" : "" %>>Other
                                                </option>
                                            </select></div>
                                        <div class="col-6"><label class="form-label">Blood Group</label><select
                                                name="blood_group" class="form-select">
                                                <option <%="A+" .equals(tBlood) ? "selected" : "" %>>A+</option>
                                                <option <%="A-" .equals(tBlood) ? "selected" : "" %>>A-</option>
                                                <option <%="B+" .equals(tBlood) ? "selected" : "" %>>B+</option>
                                                <option <%="B-" .equals(tBlood) ? "selected" : "" %>>B-</option>
                                                <option <%="O+" .equals(tBlood) ? "selected" : "" %>>O+</option>
                                                <option <%="O-" .equals(tBlood) ? "selected" : "" %>>O-</option>
                                                <option <%="AB+" .equals(tBlood) ? "selected" : "" %>>AB+</option>
                                                <option <%="AB-" .equals(tBlood) ? "selected" : "" %>>AB-</option>
                                            </select></div>
                                        <div class="col-6"><label class="form-label">Phone Number</label><input
                                                name="phone" class="form-control" value="<%= tPhone %>" /></div>
                                        <div class="col-6"><label class="form-label">Email</label><input name="email"
                                                class="form-control" value="<%= tEmail %>" /></div>
                                        <div class="col-6"><label class="form-label">Subject</label><input
                                                name="subject" class="form-control" value="<%= tSubject %>" /></div>
                                        <div class="col-6"><label class="form-label">Department</label><input
                                                name="department" class="form-control" value="<%= tDept %>" /></div>
                                        <div class="col-6"><label class="form-label">Qualification</label><input
                                                name="qualification" class="form-control" value="<%= tQual %>" />
                                        </div>
                                        <div class="col-6"><label class="form-label">Experience</label><input
                                                name="experience" class="form-control" value="<%= tExp %>" />
                                        </div>
                                        <div class="col-6"><label class="form-label">Employee ID</label><input
                                                name="employee_id" class="form-control" value="<%= tEmpId %>" />
                                        </div>
                                        <div class="col-12"><label class="form-label">Address</label><input
                                                name="address" class="form-control" value="<%= tAddress %>" /></div>
                                        <div class="col-12 d-flex gap-2 pt-2">
                                            <button type="submit" class="save-btn"><i
                                                    class="bi bi-check-lg me-1"></i>Save
                                                Changes</button>
                                            <button type="button" onclick="closeEditModal()"
                                                style="background:var(--bg);border:1.5px solid var(--border);border-radius:11px;padding:12px 20px;font-size:14px;font-weight:600;cursor:pointer;font-family:inherit">Cancel</button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <div class="mback" id="leaveModal" onclick="closeLeaveOutside(event)">
                        <div class="emodal">
                            <div class="ehead">
                                <h5><i class="bi bi-calendar2-x-fill me-2" style="color:var(--red)"></i>Leave
                                    Application
                                </h5>
                                <button class="eclose" onclick="closeLeaveModal()">✕</button>
                            </div>
                            <div class="ebody">
                                <form action="/applyLeave" method="post">
                                    <input type="hidden" name="leave_type" id="selected-leave-type" value="Casual">
                                    <div class="row g-3">
                                    <div class="col-12">
                                        <label class="form-label">Leave Ka Type</label>
                                        <div class="row g-2">
                                            <div class="col-6 col-md-3">
                                                <div class="ltype sel" onclick="selectLeaveType(this, 'Casual')"
                                                    style="padding:12px">
                                                    <i class="bi bi-sun-fill" style="color:#d97706"></i><span
                                                        style="font-size:12px">Casual</span>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3">
                                                <div class="ltype" onclick="selectLeaveType(this, 'Medical')" style="padding:12px">
                                                    <i class="bi bi-hospital-fill" style="color:#2563eb"></i><span
                                                        style="font-size:12px">Medical</span>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3">
                                                <div class="ltype" onclick="selectLeaveType(this, 'Earned')" style="padding:12px">
                                                    <i class="bi bi-award-fill" style="color:#7c3aed"></i><span
                                                        style="font-size:12px">Earned</span>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3">
                                                <div class="ltype" onclick="selectLeaveType(this, 'Special')" style="padding:12px">
                                                    <i class="bi bi-house-heart-fill" style="color:#ec4899"></i><span
                                                        style="font-size:12px">Special</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6"><label class="form-label">Start Date</label><input
                                            name="from_date" class="form-control" type="date" required /></div>
                                    <div class="col-6"><label class="form-label">End Date</label><input
                                            name="to_date" class="form-control" type="date" required /></div>
                                    <div class="col-12"><label class="form-label">Leave Ka Karan
                                            (Reason)</label><textarea name="reason" class="form-control" rows="3"
                                            placeholder="Leave lene ka reason likhein..." required></textarea>
                                    </div>
                                </div>
                                    <div class="col-12 d-flex gap-2 pt-1">
                                        <button type="submit" class="save-btn"><i
                                                class="bi bi-send-fill me-1"></i>Leave
                                            Submit Karo</button>
                                        <button type="button" onclick="closeLeaveModal()"
                                            style="background:var(--bg);border:1.5px solid var(--border);border-radius:11px;padding:12px 20px;font-size:14px;font-weight:600;cursor:pointer;font-family:inherit">Cancel</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                        </div>
                    </div>

                    <div class="lback" id="markAttendanceModal" style="z-index: 9999;" onclick="if(event.target===this) window.closeMarkAttendanceModal()">
                        <div class="lbox" style="max-width:450px; background:var(--card); border-radius:20px; overflow:hidden;">
                            <div class="lt-head" style="padding:20px; border-bottom:1px solid var(--border); display:flex; justify-content:space-between; align-items:center;">
                                <h5 style="margin:0; font-weight:700;"><i class="bi bi-clipboard-check-fill me-2" style="color:var(--accent);"></i> Attendance Selection</h5>
                                <button onclick="window.closeMarkAttendanceModal()" style="background:none; border:none; font-size:20px; cursor:pointer;">✕</button>
                            </div>
                            <form action="/markAttendance" method="get">
                                <div style="padding:20px;">
                                    <div class="row g-3">
                                        <div class="col-md-12">
                                            <label class="form-label" style="font-size:13px; font-weight:600; margin-bottom:8px; display:block;">Select Class</label>
                                            <select name="class" class="form-select" required>
                                                <option value="">Choose Class...</option>
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
                                            <label class="form-label" style="font-size:13px; font-weight:600; margin-bottom:8px; display:block;">Select Section</label>
                                            <select name="section" class="form-select" required>
                                                <option value="A">Section A</option>
                                                <option value="B">Section B</option>
                                                <option value="C">Section C</option>
                                                <option value="D">Section D</option>
                                            </select>
                                        </div>

                                        <input type="hidden" name="teacher_id" value="<%= tId %>">
                                    </div>
                                </div>
                                <div style="padding:20px; border-top:1px solid var(--border); background:#f8fafc; display:flex; gap:10px;">
                                    <button type="submit" class="save-btn" style="flex:1;"><i class="bi bi-arrow-right-circle-fill me-1"></i> Proceed to Mark</button>
                                    <button type="button" onclick="window.closeMarkAttendanceModal()" style="padding:12px 20px; border-radius:11px; background:white; border:1.5px solid var(--border); font-weight:600; font-size:14px; cursor:pointer;">Cancel</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div class="mback" id="assignmentModal" onclick="if(event.target===this) closeAssignmentModal()">
                        <div class="emodal">
                            <div class="ehead">
                                <h5><i class="bi bi-clipboard-plus-fill me-2" style="color:var(--accent)"></i>Naya Assignment Do</h5>
                                <button class="eclose" onclick="closeAssignmentModal()">✕</button>
                            </div>
                            <div class="ebody">
                                <form action="/createAssignment" method="post" enctype="multipart/form-data" onsubmit="return validateAssignmentForm()">
                                    <input type="hidden" name="teacher_id" value="<%= tId %>">
                                    <div class="row g-3">
                                        <div class="col-12">
                                            <label class="form-label">Assignment Ka Title</label>
                                            <input type="text" name="title" class="form-control" placeholder="E.g. Newton's Laws Worksheet" required>
                                        </div>
                                        <div class="col-12">
                                            <label class="form-label">Description / Instructions</label>
                                            <textarea name="description" class="form-control" rows="3" placeholder="Assignment ke baare mein details likhein..." required></textarea>
                                        </div>
                                        <div class="col-6">
                                            <label class="form-label">Select Class</label>
                                            <select name="class" class="form-select" required>
                                                <option value="">Chunain...</option>
                                                <% 
                                                    Set<String> uCls = new HashSet<>();
                                                    for(Map<String, String> c : assignedClasses) uCls.add(c.get("class"));
                                                    for(String cl : uCls) { 
                                                %>
                                                    <option value="<%= cl %>">Class <%= cl %></option>
                                                <% } %>
                                            </select>
                                        </div>
                                        <div class="col-6">
                                            <label class="form-label">Select Section</label>
                                            <select name="section" class="form-select" required>
                                                <option value="">Chunain...</option>
                                                <option value="A">Section A</option>
                                                <option value="B">Section B</option>
                                                <option value="C">Section C</option>
                                                <option value="D">Section D</option>
                                            </select>
                                        </div>
                                        <div class="col-6">
                                            <label class="form-label">Subject</label>
                                            <input type="text" name="subject" class="form-control" value="<%= tSubject != null ? tSubject.replace(" Teacher", "") : "" %>" required>
                                        </div>
                                        <div class="col-6">
                                            <label class="form-label">Due Date</label>
                                            <input type="date" name="due_date" class="form-control" required>
                                        </div>
                                        <div class="col-12">
                                            <label class="form-label">Attachment (Photo ya Document)</label>
                                            <input type="file" name="file" class="form-control">
                                        </div>
                                        <div class="col-12">
                                            <label class="form-label">External Link (Optional)</label>
                                            <input type="text" name="document_link" class="form-control" placeholder="E.g. Google Drive link">
                                        </div>
                                        <div class="col-12 d-flex gap-2 pt-2">
                                            <button type="submit" class="save-btn"><i class="bi bi-plus-lg me-1"></i> Assignment Create Karo</button>
                                            <button type="button" onclick="closeAssignmentModal()" style="background:var(--bg);border:1.5px solid var(--border);border-radius:11px;padding:12px 20px;font-size:14px;font-weight:600;cursor:pointer;font-family:inherit">Cancel</button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <script
                        src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
                    <script>
                        function openAssignmentModal() { document.getElementById('assignmentModal').classList.add('show'); document.body.style.overflow = 'hidden' }
                        function closeAssignmentModal() { document.getElementById('assignmentModal').classList.remove('show'); document.body.style.overflow = '' }

                        window.openMarkAttendanceModal = function() {
                            const el = document.getElementById('markAttendanceModal');
                            if(el) {
                                el.style.display = 'flex';
                                setTimeout(() => el.classList.add('show'), 10);
                            }
                        };
                        window.closeMarkAttendanceModal = function() {
                            const el = document.getElementById('markAttendanceModal');
                            if(el) {
                                el.classList.remove('show');
                                setTimeout(() => el.style.display = 'none', 300);
                            }
                        };
                        const pageTitles = { dashboard: 'Dashboard', profile: 'My Profile', myclasses: 'My Classes', timetable: 'My Timetable', attendance: 'Mark Attendance', assignments: 'Assignments', results: 'Results & Marks', leave: 'Leave Application', notices: 'Notices' };

                        window.showPage = function(pageId, el) {
                            if (!pageId) return;
                            const targetPage = document.getElementById('page-' + pageId);
                            if (!targetPage) return;

                            document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));

                            targetPage.classList.add('active');

                            document.querySelectorAll('.s-link').forEach(l => l.classList.remove('active'));
                            if (el) {
                                el.classList.add('active');
                            } else {
                                const link = document.querySelector(`.s-link[data-page="${pageId}"]`);
                                if (link) link.classList.add('active');
                            }

                            const titleEl = document.getElementById('page-title');
                            if (titleEl) titleEl.textContent = pageTitles[pageId] || pageId;

                            if (pageId === 'notices') {
                                markNoticesAsSeen();
                            }

                            const sidebar = document.getElementById('sidebar');
                            if (sidebar) sidebar.classList.remove('open');

                            const url = new URL(window.location.href);
                            let urlChanged = false;

                            if (url.searchParams.get('page') !== pageId) {
                                url.searchParams.set('page', pageId);
                                urlChanged = true;
                            }

                            if (url.searchParams.has('success') || url.searchParams.has('error')) {
                                url.searchParams.delete('success');
                                url.searchParams.delete('error');
                                urlChanged = true;
                            }

                            if (pageId !== 'attendance' && (url.searchParams.has('class') || url.searchParams.has('section'))) {
                                url.searchParams.delete('class');
                                url.searchParams.delete('section');
                                urlChanged = true;
                            }

                            if (urlChanged) {
                                window.history.replaceState({}, '', url);
                            }
                        };

                        function markNoticesAsSeen() {
                            const notices = document.querySelectorAll('.notice-item');
                            let seenIds = JSON.parse(localStorage.getItem('seen_notices') || '[]');
                            let newlySeen = false;

                            notices.forEach(n => {
                                const id = n.getAttribute('data-id');
                                if (!seenIds.includes(id)) {
                                    seenIds.push(id);
                                    newlySeen = true;
                                }
                            });

                            if (newlySeen) {
                                localStorage.setItem('seen_notices', JSON.stringify(seenIds));
                                updateNoticeBadge();
                            }
                        }

                        function updateNoticeBadge() {
                            const badge = document.getElementById('sidebar-notif-count');
                            if (!badge) return;

                            const totalCount = parseInt(badge.getAttribute('data-total') || '<%= totalNoticesCount %>');
                            if (isNaN(totalCount)) return;

                            let seenIds = JSON.parse(localStorage.getItem('seen_notices') || '[]');
                            const notices = document.querySelectorAll('.notice-item');
                            let visibleSeenCount = 0;

                            notices.forEach(n => {
                                if (seenIds.includes(n.getAttribute('data-id'))) {
                                    visibleSeenCount++;
                                }
                            });

                            const unreadCount = Math.max(0, totalCount - visibleSeenCount);
                            badge.textContent = unreadCount;
                            if (unreadCount <= 0) {
                                badge.style.display = 'none';
                            } else {
                                badge.style.display = 'inline-block';
                            }
                        }

                        window.addEventListener('DOMContentLoaded', () => {
                            const badge = document.getElementById('sidebar-notif-count');
                            if (badge) {
                                badge.setAttribute('data-total', '<%= totalNoticesCount %>');
                                updateNoticeBadge();
                            }
                        });

                        window.toggleSidebar = function() {
                            const sidebar = document.getElementById('sidebar');
                            if (sidebar) sidebar.classList.toggle('open');
                        };

                        window.openEditModal = function() { document.getElementById('editModal').classList.add('show'); document.body.style.overflow = 'hidden' }
                        window.closeEditModal = function() { document.getElementById('editModal').classList.remove('show'); document.body.style.overflow = '' }
                        window.closeEditOutside = function(e) { if (e.target === document.getElementById('editModal')) closeEditModal() }

                        window.previewImage = function(input) {
                            if (input.files && input.files[0]) {
                                const reader = new FileReader();
                                reader.onload = function (e) {
                                    document.getElementById('modal-photo-preview').src = e.target.result;
                                }
                                reader.readAsDataURL(input.files[0]);
                            }
                        }

                        window.openLeaveModal = function() { document.getElementById('leaveModal').classList.add('show'); document.body.style.overflow = 'hidden' }
                        window.closeLeaveModal = function() { document.getElementById('leaveModal').classList.remove('show'); document.body.style.overflow = '' }
                        window.closeLeaveOutside = function(e) { if (e.target === document.getElementById('leaveModal')) closeLeaveModal() }

                        window.handleAvatarChange = function(input) {
                            if (!input.files || !input.files[0]) return;
                            const reader = new FileReader();
                            reader.onload = e => {
                                const src = e.target.result;
                                document.getElementById('sidebar-photo').src = src;
                                document.getElementById('profile-photo').src = src;
                                document.getElementById('modal-photo-preview').src = src;
                            };
                            reader.readAsDataURL(input.files[0]);
                        }

                        document.addEventListener('click', function(e) {
                            const link = e.target.closest('.s-link');
                            if (link && link.hasAttribute('data-page')) {
                                e.preventDefault();
                                showPage(link.getAttribute('data-page'), link);
                            }
                        });

                        window.addEventListener('load', function() {
                            const urlParams = new URLSearchParams(window.location.search);

                            history.pushState(null, null, location.href);
                            window.onpopstate = function () {
                                history.go(1);
                            };

                            if (urlParams.has('success')) {
                                const success = urlParams.get('success');
                                if (success === 'assignment_created') alert('✅ Assignment create ho gaya!');
                                else if (success === 'attendance_marked') alert('✅ Attendance save ho gayi!');
                                else if (success === 'graded') alert('✅ Submission grade ho gayi!');
                                else showToast('✅ Success!');
                            }

                            if (urlParams.has('error')) {
                                alert('❌ Kuch error aa gaya. Phir se try karein.');
                            }

                            const page = urlParams.get('page') || 'dashboard';
                            showPage(page);

                            if (typeof updateDynamicDates === 'function') updateDynamicDates();
                        });

                        function validateAssignmentForm() {
                            const title = document.querySelector('input[name="title"]').value;
                            if (!title || title.trim() === "") {
                                alert("⚠️ Kripya Title likhein!");
                                return false;
                            }
                            return true;
                        }

                        function submitLeave() {
                            closeLeaveModal();
                            showToast('Leave application submit ho gayi! Admin review karega. ✓');
                        }

                        function selectClassAndReload(cls, sec) {
                            const url = new URL(window.location.href);
                            url.searchParams.set('page', 'attendance');
                            url.searchParams.set('class', cls);
                            url.searchParams.set('section', sec);
                            window.location.href = url.toString();
                        }

                        function selectLeaveType(el, type) {
                            document.querySelectorAll('#leaveModal .ltype').forEach(e => e.classList.remove('sel'));
                            el.classList.add('sel');
                            document.getElementById('selected-leave-type').value = type;
                        }

                        function markAll(val) {
                            document.querySelectorAll('#att-tbody input[value="' + val + '"]').forEach(r => r.checked = true);
                        }

                        function showToast(msg) {
                            const t = document.createElement('div');
                            t.textContent = msg;
                            Object.assign(t.style, { position: 'fixed', bottom: '24px', left: '50%', transform: 'translateX(-50%) translateY(20px)', background: '#0d1f12', color: '#fff', padding: '12px 24px', borderRadius: '12px', fontSize: '13px', fontWeight: '600', zIndex: '9999', opacity: '0', transition: 'all .3s ease', boxShadow: '0 8px 24px rgba(0,0,0,.2)', fontFamily: 'Sora,sans-serif' });
                            document.body.appendChild(t);
                            requestAnimationFrame(() => { t.style.opacity = '1'; t.style.transform = 'translateX(-50%) translateY(0)' });
                            setTimeout(() => { t.style.opacity = '0'; t.style.transform = 'translateX(-50%) translateY(20px)'; setTimeout(() => t.remove(), 300) }, 2800);
                        }

                        function updateDynamicDates() {
                            const today = new Date();
                            const optionsShort = { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' };
                            const optionsLong = { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' };
                            const optionsDashShort = { weekday: 'long', day: 'numeric', month: 'short' };

                            const shortStr = today.toLocaleDateString('en-GB', optionsShort);
                            const longStr = today.toLocaleDateString('en-GB', optionsLong);
                            const dashShortStr = today.toLocaleDateString('en-GB', optionsDashShort);

                            if (document.getElementById('topbar-date')) document.getElementById('topbar-date').innerText = shortStr;
                            if (document.getElementById('dash-date')) document.getElementById('dash-date').innerText = longStr;
                            if (document.getElementById('dash-date-short')) document.getElementById('dash-date-short').innerText = dashShortStr;
                            if (document.getElementById('att-date-val')) document.getElementById('att-date-val').innerText = longStr;
                        }
                        updateDynamicDates();
                    </script>
                </body>

                </html>