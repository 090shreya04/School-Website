<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% 
    if (session == null || session.getAttribute("user_id") == null || !"admin".equals(session.getAttribute("role"))) { 
        response.sendRedirect("/signin"); 
        return; 
    } 
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Fee Structure | Admin</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #0f172a;
            --accent: #6366f1;
            --bg: #f8fafc;
            --card: #ffffff;
            --border: #e2e8f0;
            --text: #0f172a;
            --muted: #64748b;
        }
        body {
            font-family: 'Sora', sans-serif;
            background: var(--bg);
            color: var(--text);
            padding: 40px 20px;
        }
        .container { max-width: 800px; }
        .card-box {
            background: var(--card);
            border-radius: 20px;
            border: 1.5px solid var(--border);
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
        }
        .card-head {
            padding: 24px 30px;
            border-bottom: 1.5px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .card-head h5 { margin: 0; font-weight: 800; }
        .card-body-p { padding: 30px; }
        .fee-item {
            display: flex;
            align-items: center;
            gap: 20px;
            padding: 16px;
            background: #f1f5f9;
            border-radius: 14px;
            margin-bottom: 12px;
            transition: all 0.2s;
        }
        .fee-item:hover { background: #e2e8f0; }
        .class-badge {
            width: 50px;
            height: 50px;
            background: var(--accent);
            color: #fff;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 18px;
            flex-shrink: 0;
        }
        .fee-info { flex: 1; }
        .fee-info p { margin: 0; font-size: 14px; font-weight: 600; color: var(--muted); }
        .fee-input-wrap { display: flex; align-items: center; gap: 8px; }
        .fee-input {
            width: 140px;
            border: 1.5px solid var(--border);
            border-radius: 10px;
            padding: 8px 12px;
            font-weight: 700;
            font-family: inherit;
            outline: none;
        }
        .fee-input:focus { border-color: var(--accent); }
        .save-btn {
            background: var(--accent);
            color: #fff;
            border: none;
            border-radius: 10px;
            padding: 8px 16px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }
        .save-btn:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3); }
        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: var(--muted);
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 20px;
            transition: color 0.2s;
        }
        .back-btn:hover { color: var(--accent); }
    </style>
</head>
<body>
    <div class="container">
        <a href="adashboard?page=fees" class="back-btn"><i class="bi bi-arrow-left"></i> Back to Fees</a>
        
        <div class="card-box">
            <div class="card-head">
                <h5><i class="bi bi-gear-fill me-2" style="color:var(--accent)"></i> Monthly Fee Structure</h5>
                <span class="badge bg-primary rounded-pill">Admin Only</span>
            </div>
            <div class="card-body-p">
                <% 
                    Connection conn = null;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root", "");
                        
                        // Handle Update
                        if("POST".equalsIgnoreCase(request.getMethod())) {
                            String className = request.getParameter("class_name");
                            String feeStr = request.getParameter("monthly_fee");
                            if(className != null && feeStr != null) {
                                double fee = Double.parseDouble(feeStr);
                                PreparedStatement psUp = conn.prepareStatement("UPDATE fee_structure SET monthly_fee = ? WHERE class_name = ?");
                                psUp.setDouble(1, fee);
                                psUp.setString(2, className);
                                psUp.executeUpdate();
                                out.println("<div class='alert alert-success py-2' style='font-size:13px'>Fee updated for Class " + className + "!</div>");
                            }
                        }

                        // Fetch Current Structure
                        String sql = "SELECT * FROM fee_structure ORDER BY CAST(class_name AS UNSIGNED) ASC";
                        ResultSet rs = conn.createStatement().executeQuery(sql);
                        while(rs.next()) {
                            String cls = rs.getString("class_name");
                            double fee = rs.getDouble("monthly_fee");
                %>
                <form method="POST" class="fee-item">
                    <input type="hidden" name="class_name" value="<%= cls %>">
                    <div class="class-badge"><%= cls %></div>
                    <div class="fee-info">
                        <p>Monthly Fee (Class <%= cls %>)</p>
                        <div class="fee-input-wrap mt-1">
                            <span style="font-weight:700">₹</span>
                            <input type="number" name="monthly_fee" class="fee-input" value="<%= (int)fee %>" step="100">
                        </div>
                    </div>
                    <button type="submit" class="save-btn">Update</button>
                </form>
                <% 
                        }
                    } catch(Exception e) { 
                        out.println("<p class='text-danger'>Error: " + e.getMessage() + "</p>");
                    } finally { 
                        if(conn != null) conn.close(); 
                    } 
                %>
            </div>
        </div>
        <p class="mt-4 text-center text-muted" style="font-size:12px">Note: Changing these values will affect new fee generation. Already generated pending dues might need manual adjustment.</p>
    </div>
</body>
</html>
