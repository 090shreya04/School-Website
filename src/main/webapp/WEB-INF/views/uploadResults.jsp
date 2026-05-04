<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session == null || session.getAttribute("user_id") == null) {
        response.sendRedirect("/signin");
        return;
    }
    
    String cls = request.getParameter("class");
    String sec = request.getParameter("section");
    String subject = request.getParameter("subject");
    String examType = request.getParameter("exam_type");
    String totalMarks = request.getParameter("total_marks");
    String examDate = request.getParameter("exam_date");
    
    boolean selectionDone = (cls != null && sec != null && subject != null && examType != null);
    
    String userRole = (String) session.getAttribute("role");
    String dashboardUrl = "faculty".equalsIgnoreCase(userRole) ? "/tdashboard?page=results" : "/adashboard?page=results";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Results - EduManage</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet" />
    <style>
        :root {
            --primary: #0c1a2e;
            --accent: #f97316;
            --bg: #f8fafc;
            --card: #ffffff;
            --border: #e2e8f0;
            --text: #0c1a2e;
            --muted: #64748b;
            --glass: rgba(255, 255, 255, 0.7);
        }
        
        body {
            font-family: 'Sora', sans-serif;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
            color: var(--text);
            min-height: 100vh;
            padding: 40px 20px;
        }

        .glass-card {
            background: var(--glass);
            backdrop-filter: blur(12px);
            border: 1.5px solid rgba(255, 255, 255, 0.8);
            border-radius: 24px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.05);
            padding: 30px;
            margin-bottom: 30px;
        }

        .header-section {
            margin-bottom: 35px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }

        .pg-title {
            font-weight: 800;
            font-size: 28px;
            background: linear-gradient(90deg, var(--primary), var(--accent));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin: 0;
        }

        .form-label {
            font-size: 13px;
            font-weight: 700;
            color: var(--muted);
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .form-control, .form-select {
            border-radius: 12px;
            padding: 12px 16px;
            border: 1.5px solid var(--border);
            font-size: 14px;
            font-weight: 600;
            transition: all 0.2s;
            background: white;
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 4px rgba(249, 115, 22, 0.1);
        }

        .btn-primary-custom {
            background: var(--primary);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 12px;
            font-weight: 700;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }

        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(12, 26, 46, 0.2);
        }

        .btn-accent-custom {
            background: var(--accent);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 12px;
            font-weight: 700;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }

        .btn-accent-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(249, 115, 22, 0.2);
        }

        .student-table-card {
            background: white;
            border-radius: 20px;
            border: 1.5px solid var(--border);
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.03);
        }

        .table thead {
            background: #f8fafc;
        }

        .table thead th {
            font-weight: 700;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 18px 20px;
            color: var(--muted);
            border: none;
        }

        .table td {
            padding: 18px 20px;
            vertical-align: middle;
            border-bottom: 1.5px solid #f1f5f9;
        }

        .roll-badge {
            font-family: 'JetBrains Mono', monospace;
            font-weight: 800;
            color: var(--accent);
            background: rgba(249, 115, 22, 0.1);
            padding: 4px 10px;
            border-radius: 8px;
            font-size: 14px;
        }

        .marks-input {
            width: 100px;
            text-align: center;
            font-weight: 800;
            color: var(--primary);
            font-family: 'JetBrains Mono', monospace;
            font-size: 16px;
        }

        .status-badge {
            font-size: 11px;
            font-weight: 800;
            padding: 4px 10px;
            border-radius: 20px;
        }

        .save-bar {
            position: fixed;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%);
            background: var(--primary);
            color: white;
            padding: 15px 40px;
            border-radius: 100px;
            display: flex;
            align-items: center;
            gap: 25px;
            box-shadow: 0 15px 40px rgba(0,0,0,0.3);
            z-index: 1000;
            animation: slideUp 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }

        @keyframes slideUp {
            from { transform: translate(-50%, 100px); opacity: 0; }
            to { transform: translate(-50%, 0); opacity: 1; }
        }

        .back-btn {
            color: var(--muted);
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: color 0.2s;
        }

        .back-btn:hover {
            color: var(--primary);
        }

        .selection-pill {
            background: white;
            padding: 10px 20px;
            border-radius: 15px;
            border: 1.5px solid var(--border);
            display: inline-flex;
            align-items: center;
            gap: 12px;
            font-weight: 700;
            font-size: 13px;
            color: var(--primary);
        }
        
        .selection-pill i {
            color: var(--accent);
        }
    </style>
</head>
<body>
    <div class="container" style="max-width: 1000px;">
        <div class="header-section">
            <div>
                <a href="<%= dashboardUrl %>" class="back-btn mb-3">
                    <i class="bi bi-arrow-left"></i> Back to Results Dashboard
                </a>
                <h1 class="pg-title">Results Upload Portal 🎓</h1>
                <p class="text-muted mt-2">Enter marks for each student dynamically from the database.</p>
            </div>
            <% if(selectionDone) { %>
                <a href="/uploadResults" class="btn-primary-custom" style="background: white; color: var(--primary); border: 1.5px solid var(--border);">
                    <i class="bi bi-arrow-repeat"></i> Change Selection
                </a>
            <% } %>
        </div>

        <% if(!selectionDone) { %>
            <!-- Selection Form -->
            <div class="glass-card">
                <h5 class="mb-4" style="font-weight: 800;"><i class="bi bi-funnel-fill me-2 text-accent"></i> Exam Details Select Karein</h5>
                <%
                    Object uIdObj = session.getAttribute("user_id");
                    String uId = (uIdObj != null) ? uIdObj.toString() : "";
                    List<Map<String, String>> teacherAssignments = new ArrayList<>();
                    Connection connTA = null;
                    try {
                        connTA = DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root", "");
                        
                        // First get teacher_id from teachers table using user_id from session
                        String tId = "";
                        PreparedStatement psT = connTA.prepareStatement("SELECT teacher_id FROM teachers WHERE user_id = ?");
                        psT.setString(1, uId);
                        ResultSet rsT = psT.executeQuery();
                        if(rsT.next()) tId = rsT.getString("teacher_id");

                        if(!tId.isEmpty()) {
                            String sqlTA = "SELECT DISTINCT class, section, subject FROM timetable WHERE teacher_id = ? ORDER BY class, section";
                            PreparedStatement psTA = connTA.prepareStatement(sqlTA);
                            psTA.setString(1, tId);
                            ResultSet rsTA = psTA.executeQuery();
                            while(rsTA.next()) {
                                Map<String, String> assignment = new HashMap<>();
                                assignment.put("class", rsTA.getString("class"));
                                assignment.put("section", rsTA.getString("section"));
                                assignment.put("subject", rsTA.getString("subject"));
                                teacherAssignments.add(assignment);
                            }
                        }
                    } catch(Exception e) {
                        e.printStackTrace();
                    } finally {
                        if(connTA != null) connTA.close();
                    }
                %>
                <script>
                    const teacherAssignments = [
                        <% for(Map<String, String> a : teacherAssignments) { %>
                        { class: "<%= a.get("class") %>", section: "<%= a.get("section") %>", subject: "<%= a.get("subject") %>" },
                        <% } %>
                    ];

                    function updateSections() {
                        const classSelect = document.getElementById('classSelect');
                        const sectionSelect = document.getElementById('sectionSelect');
                        const subjectSelect = document.getElementById('subjectSelect');
                        const selectedClass = classSelect.value;
                        
                        sectionSelect.innerHTML = '<option value="">-- Section --</option>';
                        if(subjectSelect) subjectSelect.innerHTML = '<option value="">-- Subject --</option>';
                        
                        if(!selectedClass) return;

                        const sections = [...new Set(teacherAssignments
                            .filter(a => a.class === selectedClass)
                            .map(a => a.section))];
                        
                        sections.forEach(s => {
                            const opt = document.createElement('option');
                            opt.value = s;
                            opt.textContent = 'Section ' + s;
                            sectionSelect.appendChild(opt);
                        });
                        
                        // If only one section, select it
                        if(sections.length === 1) {
                            sectionSelect.value = sections[0];
                            updateSubject();
                        }
                    }

                    function updateSubject() {
                        const classSelect = document.getElementById('classSelect');
                        const sectionSelect = document.getElementById('sectionSelect');
                        const subjectSelect = document.getElementById('subjectSelect');
                        const selectedClass = classSelect.value;
                        const selectedSection = sectionSelect.value;
                        
                        subjectSelect.innerHTML = '<option value="">-- Subject --</option>';
                        
                        if(!selectedClass || !selectedSection) return;

                        const subjects = teacherAssignments
                            .filter(a => a.class === selectedClass && a.section === selectedSection)
                            .map(a => a.subject);
                        
                        subjects.forEach(sub => {
                            const opt = document.createElement('option');
                            opt.value = sub;
                            opt.textContent = sub;
                            subjectSelect.appendChild(opt);
                        });
                        
                        if(subjects.length === 1) {
                            subjectSelect.value = subjects[0];
                        }
                    }
                </script>
                <form action="/uploadResults" method="get">
                    <div class="row g-4">
                        <div class="col-md-4">
                            <label class="form-label">Select Class</label>
                            <select name="class" id="classSelect" class="form-select" onchange="updateSections()" required>
                                <option value="">-- Class --</option>
                                <% 
                                    java.util.Set<String> uniqueClasses = new java.util.TreeSet<>(new Comparator<String>() {
                                        public int compare(String s1, String s2) {
                                            try { return Integer.compare(Integer.parseInt(s1), Integer.parseInt(s2)); }
                                            catch(Exception e) { return s1.compareTo(s2); }
                                        }
                                    });
                                    for(Map<String, String> a : teacherAssignments) uniqueClasses.add(a.get("class"));
                                    for(String c : uniqueClasses) {
                                %>
                                <option value="<%= c %>">Class <%= c %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Select Section</label>
                            <select name="section" id="sectionSelect" class="form-select" onchange="updateSubject()" required>
                                <option value="">-- Section --</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Subject</label>
                            <select name="subject" id="subjectSelect" class="form-select" required>
                                <option value="">-- Subject --</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Exam Type</label>
                            <select name="exam_type" class="form-select" required>
                                <option value="Unit Test 1">Unit Test 1</option>
                                <option value="Half Yearly">Half Yearly</option>
                                <option value="Unit Test 2">Unit Test 2</option>
                                <option value="Final Exam">Final Exam</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Total Marks</label>
                            <input type="number" name="total_marks" class="form-control" value="100" required />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Exam Date</label>
                            <input type="date" name="exam_date" class="form-control" value="<%= new java.sql.Date(System.currentTimeMillis()) %>" required />
                        </div>
                        <div class="col-12 mt-4 text-end">
                            <button type="submit" class="btn-accent-custom px-5">
                                Next: Enter Marks <i class="bi bi-arrow-right ms-2"></i>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        <% } else { %>
            <!-- Marks Entry Form -->
            <div class="d-flex flex-wrap gap-3 mb-4">
                <div class="selection-pill"><i class="bi bi-mortarboard-fill"></i> Class <%= cls %>-<%= sec %></div>
                <div class="selection-pill"><i class="bi bi-journal-bookmark-fill"></i> <%= subject %></div>
                <div class="selection-pill"><i class="bi bi-file-earmark-text-fill"></i> <%= examType %></div>
                <div class="selection-pill"><i class="bi bi-trophy-fill"></i> Total: <%= totalMarks %></div>
                <div class="selection-pill"><i class="bi bi-calendar-event-fill"></i> <%= examDate %></div>
            </div>

            <form action="/saveResults" method="post" id="resultsForm">
                <input type="hidden" name="class" value="<%= cls %>">
                <input type="hidden" name="section" value="<%= sec %>">
                <input type="hidden" name="subject" value="<%= subject %>">
                <input type="hidden" name="exam_type" value="<%= examType %>">
                <input type="hidden" name="total_marks" value="<%= totalMarks %>">
                <input type="hidden" name="exam_date" value="<%= examDate %>">

                <div class="student-table-card">
                    <table class="table mb-0">
                        <thead>
                            <tr>
                                <th style="width: 120px;">Roll No</th>
                                <th>Student Name</th>
                                <th style="text-align: center; width: 200px;">Marks Obtained</th>
                                <th style="text-align: center; width: 150px;">Percentage</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null;
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root", "");
                                    
                                    // Fetch students for the selected class/section
                                    String sql = "SELECT s.student_id, s.name, s.roll_no, r.marks_obtained FROM students s " +
                                                 "LEFT JOIN results r ON s.student_id = r.student_id AND r.subject = ? AND r.exam_type = ? " +
                                                 "WHERE s.class = ? AND s.section = ? ORDER BY CAST(s.roll_no AS UNSIGNED)";
                                    PreparedStatement pstmt = conn.prepareStatement(sql);
                                    pstmt.setString(1, subject);
                                    pstmt.setString(2, examType);
                                    pstmt.setString(3, cls);
                                    pstmt.setString(4, sec);
                                    ResultSet rs = pstmt.executeQuery();
                                    
                                    int count = 0;
                                    while(rs.next()) {
                                        count++;
                                        String sid = rs.getString("student_id");
                                        String name = rs.getString("name");
                                        String roll = rs.getString("roll_no");
                                        Double existingMarks = rs.getDouble("marks_obtained");
                                        String marksVal = rs.wasNull() ? "" : String.valueOf(existingMarks);
                            %>
                            <tr>
                                <td><span class="roll-badge">#<%= roll %></span></td>
                                <td>
                                    <div style="font-weight: 700; color: var(--primary);"><%= name %></div>
                                    <div style="font-size: 11px; color: var(--muted);">ID: <%= sid %></div>
                                </td>
                                <td>
                                    <div class="d-flex justify-content-center align-items-center gap-2">
                                        <input type="number" step="0.1" max="<%= totalMarks %>" min="0" 
                                               name="marks_<%= sid %>" class="form-control marks-input" 
                                               value="<%= marksVal %>" oninput="calculatePerc(this, '<%= sid %>', <%= totalMarks %>)">
                                        <span class="text-muted" style="font-size: 12px; font-weight: 700;">/ <%= totalMarks %></span>
                                    </div>
                                    <input type="hidden" name="student_ids" value="<%= sid %>">
                                </td>
                                <td style="text-align: center;">
                                    <div id="perc_<%= sid %>" style="font-weight: 800; color: var(--muted); font-family: 'JetBrains Mono', monospace;">
                                        <% if(!marksVal.isEmpty()) { %>
                                            <%= String.format("%.1f", (existingMarks * 100 / Double.parseDouble(totalMarks))) %>%
                                        <% } else { %>
                                            --
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                    if(count == 0) {
                            %>
                            <tr>
                                <td colspan="4" style="text-align: center; padding: 60px;">
                                    <div style="font-size: 40px;">📂</div>
                                    <h6 class="mt-3" style="font-weight: 700;">No Students Found</h6>
                                    <p class="text-muted">Is class aur section mein koi students nahi mile.</p>
                                </td>
                            </tr>
                            <%
                                    }
                                } catch(Exception e) {
                                    out.println("Error: " + e.getMessage());
                                } finally {
                                    if(conn != null) conn.close();
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <div class="save-bar">
                    <div class="d-flex align-items-center gap-3">
                        <div style="width: 40px; height: 40px; border-radius: 50%; background: rgba(255,255,255,0.1); display: flex; align-items: center; justify-content: center;">
                            <i class="bi bi-cloud-check-fill"></i>
                        </div>
                        <div>
                            <div style="font-size: 14px; font-weight: 700;">Ready to Save</div>
                            <div style="font-size: 11px; opacity: 0.7;">Data entry dynamic hai.</div>
                        </div>
                    </div>
                    <button type="submit" class="btn-accent-custom px-4" style="border-radius: 50px;">
                        <i class="bi bi-check-circle-fill"></i> Results Publish Karein
                    </button>
                </div>
            </form>
        <% } %>
    </div>

    <script>
        function calculatePerc(input, sid, total) {
            const val = parseFloat(input.value);
            const percEl = document.getElementById('perc_' + sid);
            if(!isNaN(val) && val >= 0) {
                const perc = (val * 100 / total).toFixed(1);
                percEl.innerText = perc + '%';
                
                if(perc < 33) percEl.style.color = '#ef4444';
                else if(perc >= 75) percEl.style.color = '#10b981';
                else percEl.style.color = '#f59e0b';
            } else {
                percEl.innerText = '--';
                percEl.style.color = 'var(--muted)';
            }
        }
        
        // Initial color check
        window.onload = function() {
            document.querySelectorAll('.marks-input').forEach(input => {
                const sid = input.name.split('_')[1];
                const total = <%= totalMarks != null ? totalMarks : "100" %>;
                calculatePerc(input, sid, total);
            });
        };
    </script>
</body>
</html>
