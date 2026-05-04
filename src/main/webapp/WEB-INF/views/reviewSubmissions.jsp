<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Review Submissions - ${assignmentTitle}</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet" />
    <style>
        :root {
            --bg: #f8fafc;
            --card: #ffffff;
            --accent: #22c55e;
            --text: #0f172a;
            --muted: #64748b;
            --border: #e2e8f0;
        }

        body {
            font-family: 'Sora', sans-serif;
            background-color: var(--bg);
            color: var(--text);
            padding-bottom: 50px;
        }

        .navbar {
            background: #0d1f12;
            padding: 15px 0;
            margin-bottom: 30px;
            position: sticky;
            top: 0;
            z-index: 1000;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .back-btn {
            color: #fff;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            font-weight: 500;
            opacity: 0.8;
            transition: opacity 0.2s;
        }

        .back-btn:hover {
            opacity: 1;
            color: #fff;
        }

        .header-section {
            background: #fff;
            padding: 30px;
            border-radius: 20px;
            border: 1px solid var(--border);
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.02);
        }

        .asgn-badge {
            background: rgba(34, 197, 94, 0.1);
            color: var(--accent);
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            display: inline-block;
            margin-bottom: 10px;
        }

        .submission-card {
            background: var(--card);
            border-radius: 16px;
            border: 1px solid var(--border);
            padding: 24px;
            margin-bottom: 20px;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .submission-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
        }

        .student-name {
            font-weight: 700;
            font-size: 18px;
            margin-bottom: 4px;
        }

        .sub-meta {
            font-size: 13px;
            color: var(--muted);
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .sub-answer {
            background: #f1f5f9;
            padding: 20px;
            border-radius: 12px;
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 20px;
            border: 1px solid var(--border);
        }

        .grade-form {
            display: flex;
            gap: 12px;
            align-items: center;
            padding-top: 15px;
            border-top: 1px dashed var(--border);
        }

        .marks-input {
            max-width: 150px;
            border-radius: 10px;
            border: 1.5px solid var(--border);
            padding: 8px 15px;
            font-weight: 600;
            font-family: 'JetBrains Mono', monospace;
        }

        .save-btn {
            background: var(--accent);
            color: #fff;
            border: none;
            padding: 8px 24px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.2s;
        }

        .save-btn:hover {
            filter: brightness(0.9);
            box-shadow: 0 4px 12px rgba(34, 197, 94, 0.3);
        }

        .status-badge {
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .badge-pending { background: #fef3c7; color: #d97706; }
        .badge-graded { background: #dcfce7; color: #16a34a; }

        .empty-state {
            text-align: center;
            padding: 80px 20px;
            background: #fff;
            border-radius: 20px;
            border: 2px dashed var(--border);
        }
    </style>
</head>
<body>

<nav class="navbar">
    <div class="container">
        <a href="/tdashboard?page=assignments" class="back-btn">
            <i class="bi bi-arrow-left"></i> Back to Dashboard
        </a>
        <div class="ms-auto d-none d-md-block">
            <span class="text-white opacity-50" style="font-size: 13px;">Teacher Grading Portal</span>
        </div>
    </div>
</nav>

<div class="container">
    <div class="header-section">
        <span class="asgn-badge">Assignment Submissions</span>
        <h1 class="h3 fw-bold mb-2">${assignmentTitle}</h1>
        <p class="text-muted mb-0">Total Submissions: <%= ((List)request.getAttribute("submissions")).size() %></p>
    </div>

    <% 
        List<Map<String, Object>> subs = (List<Map<String, Object>>) request.getAttribute("submissions");
        if(subs == null || subs.isEmpty()) {
    %>
        <div class="empty-state">
            <i class="bi bi-folder2-open display-1 text-muted mb-3"></i>
            <h4 class="fw-bold">No Submissions Found</h4>
            <p class="text-muted">Abhi tak kisi student ne ye assignment submit nahi kiya hai.</p>
        </div>
    <% 
        } else {
            for(Map<String, Object> sub : subs) {
                String status = (String) sub.get("status");
                String marks = sub.get("marks") != null ? sub.get("marks").toString() : "0";
    %>
        <div class="submission-card">
            <div class="d-flex justify-content-between align-items-start mb-2">
                <h3 class="student-name"><%= sub.get("student_name") %></h3>
                <span class="status-badge <%= "graded".equals(status) ? "badge-graded" : "badge-pending" %>">
                    <%= "graded".equals(status) ? "Graded" : "Pending Review" %>
                </span>
            </div>
            <div class="sub-meta">
                <span><i class="bi bi-clock me-1"></i> Submitted: <%= sub.get("submitted_at") %></span>
                <% if(sub.get("submission_file") != null) { %>
                    <a href="/<%= sub.get("submission_file") %>" target="_blank" class="text-primary text-decoration-none fw-bold">
                        <i class="bi bi-file-earmark-text me-1"></i> View Attachment
                    </a>
                <% } %>
            </div>

            <div class="sub-answer">
                <strong>Student's Response:</strong><br>
                <p class="mt-2 mb-0"><%= sub.get("submission_text") != null ? sub.get("submission_text") : "No text answer provided." %></p>
            </div>

            <form action="/gradeSubmission" method="post" class="grade-form">
                <input type="hidden" name="sub_id" value="<%= sub.get("sub_id") %>">
                <div class="input-group" style="max-width: 250px;">
                    <span class="input-group-text bg-white border-end-0" style="font-size: 13px; font-weight: 600;">Marks</span>
                    <input type="number" step="0.5" name="marks" class="form-control marks-input border-start-0" value="<%= marks %>" required>
                </div>
                <button type="submit" class="save-btn">
                    <i class="bi bi-check2-circle me-1"></i> Assign Marks
                </button>
            </form>
        </div>
    <% 
            }
        }
    %>
</div>

<script>
    // Toast notification for success
    window.onload = function() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('success') === 'graded') {
            alert("✅ Marks successfully updated!");
        }
    }
</script>

</body>
</html>
