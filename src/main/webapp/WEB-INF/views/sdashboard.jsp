<%@ page import="java.sql.*, java.util.*" %>
  <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <% if (session==null || session.getAttribute("user_id")==null) { response.sendRedirect("/signin"); return; } Object
      userId=session.getAttribute("user_id"); String sName="Student" ; String sClass="Class - | No Profile" ; String
      sInitials="S" ; String sPhotoBase64=null; String sDob="" , sGender="" , sBlood="" , sPhone="" , sEmail="" ,
      sAddress="" , sRoll="" , sClassName="" , sSection="" , sStatus="" ; Connection conn=null; PreparedStatement
      pstmt=null; ResultSet rs=null; try { Class.forName("com.mysql.cj.jdbc.Driver");
      conn=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root" , "" ); String
      sql="SELECT u.name, s.* FROM user u LEFT JOIN students s ON u.user_id = s.user_id WHERE u.user_id = ?" ;
      pstmt=conn.prepareStatement(sql); pstmt.setObject(1, userId); rs=pstmt.executeQuery(); if (rs.next()) {
      sName=rs.getString("name"); sClassName=rs.getString("class"); sRoll=rs.getString("roll_no");
      sDob=rs.getString("dob"); sGender=rs.getString("gender"); sBlood=rs.getString("blood_group");
      sPhone=rs.getString("phone"); sEmail=rs.getString("email"); sAddress=rs.getString("address");
      sSection=rs.getString("section"); sStatus=rs.getString("status"); if (sClassName !=null || sRoll !=null) {
      sClass="Class " + (sClassName !=null ? sClassName : "-" ) + " | Roll #" + (sRoll !=null ? sRoll : "-" ); } byte[]
      photoBytes=rs.getBytes("photo"); if (photoBytes !=null && photoBytes.length> 0) {
      sPhotoBase64 = java.util.Base64.getEncoder().encodeToString(photoBytes);
      }

      if (sName != null && !sName.isEmpty()) {
      String[] parts = sName.trim().split("\\s+");
      StringBuilder sb = new StringBuilder();
      for (int i = 0; i < Math.min(parts.length, 2); i++) { if (parts[i].length()> 0) sb.append(parts[i].charAt(0));
        }
        sInitials = sb.toString().toUpperCase();
        }
        }
        } catch (Exception e) {
        e.printStackTrace();
        } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
        }

        // Conditional Display Logic for Profile Sections
        boolean hasPersonalInfo = (sName != null && !sName.trim().isEmpty())
        && (sDob != null && !sDob.trim().isEmpty())
        && (sGender != null && !sGender.trim().isEmpty())
        && (sBlood != null && !sBlood.trim().isEmpty())
        && (sPhone != null && !sPhone.trim().isEmpty())
        && (sEmail != null && !sEmail.trim().isEmpty())
        && (sAddress != null && !sAddress.trim().isEmpty())
        && (sRoll != null && !sRoll.trim().isEmpty())
        && (sClassName != null && !sClassName.trim().isEmpty())
        && (sSection != null && !sSection.trim().isEmpty());
        %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
          <meta charset="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>Student Dashboard</title>
          <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet" />
          <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css"
            rel="stylesheet" />
          <link
            href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap"
            rel="stylesheet" />
          <style>
            :root {
              --primary: #0f172a;
              --accent: #6366f1;
              --accent-light: #818cf8;
              --accent-glow: rgba(99, 102, 241, 0.15);
              --green: #10b981;
              --yellow: #f59e0b;
              --red: #ef4444;
              --blue: #3b82f6;
              --sidebar-w: 265px;
              --bg: #f1f5f9;
              --card: #ffffff;
              --border: #e2e8f0;
              --text: #0f172a;
              --muted: #64748b;
            }

            *,
            *::before,
            *::after {
              box-sizing: border-box;
              margin: 0;
              padding: 0;
            }

            body {
              font-family: 'Sora', sans-serif;
              background: var(--bg);
              color: var(--text);
              display: flex;
              min-height: 100vh;
              overflow-x: hidden;
            }

            .sidebar {
              width: var(--sidebar-w);
              background: var(--primary);
              position: fixed;
              top: 0;
              left: 0;
              height: 100vh;
              display: flex;
              flex-direction: column;
              z-index: 200;
              transition: transform .3s cubic-bezier(.4, 0, .2, 1);
              overflow-y: auto;
            }

            .sidebar::-webkit-scrollbar {
              width: 0;
            }

            .sidebar::before {
              content: '';
              position: absolute;
              top: 0;
              left: 0;
              right: 0;
              height: 160px;
              background: linear-gradient(160deg, rgba(99, 102, 241, .25) 0%, transparent 100%);
              pointer-events: none;
            }

            .s-brand {
              padding: 26px 20px 20px;
              display: flex;
              align-items: center;
              gap: 12px;
              border-bottom: 1px solid rgba(255, 255, 255, .07);
              position: relative;
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
              box-shadow: 0 4px 16px rgba(99, 102, 241, .4);
            }

            .s-brand-text h6 {
              color: #fff;
              font-size: 14px;
              font-weight: 700;
              margin: 0;
            }

            .s-brand-text small {
              color: rgba(255, 255, 255, .35);
              font-size: 11px;
            }

            .s-student-card {
              margin: 16px 12px;
              background: rgba(255, 255, 255, .05);
              border: 1px solid rgba(255, 255, 255, .08);
              border-radius: 14px;
              padding: 14px;
              display: flex;
              align-items: center;
              gap: 12px;
            }

            .s-avatar {
              width: 44px;
              height: 44px;
              border-radius: 12px;
              overflow: hidden;
              border: 2px solid var(--accent);
              flex-shrink: 0;
            }

            .s-avatar-initials {
              width: 100%;
              height: 100%;
              background: linear-gradient(135deg, var(--accent), var(--accent-light));
              display: flex;
              align-items: center;
              justify-content: center;
              font-weight: 700;
              font-size: 16px;
              color: #fff;
            }

            .s-student-info {
              flex: 1;
              min-width: 0;
            }

            .s-student-info h6 {
              color: #fff;
              font-size: 13px;
              font-weight: 600;
              margin: 0;
              white-space: nowrap;
              overflow: hidden;
              text-overflow: ellipsis;
            }

            .s-student-info small {
              color: rgba(255, 255, 255, .4);
              font-size: 11px;
            }

            .online-dot {
              width: 8px;
              height: 8px;
              border-radius: 50%;
              background: var(--green);
              border: 2px solid var(--primary);
              flex-shrink: 0;
            }

            .s-nav {
              padding: 8px 12px;
              flex: 1;
            }

            .s-section-label {
              padding: 16px 10px 6px;
              color: rgba(255, 255, 255, .22);
              font-size: 10px;
              text-transform: uppercase;
              letter-spacing: 1.6px;
              font-weight: 600;
            }

            .s-nav-item {
              margin-bottom: 2px;
            }

            .s-nav-link {
              display: flex;
              align-items: center;
              gap: 11px;
              padding: 10px 12px;
              border-radius: 11px;
              color: rgba(255, 255, 255, .5);
              text-decoration: none;
              font-size: 13.5px;
              font-weight: 500;
              transition: all .18s ease;
              cursor: pointer;
            }

            .s-nav-link i {
              font-size: 17px;
              min-width: 20px;
              transition: transform .2s;
            }

            .s-nav-link:hover {
              background: rgba(255, 255, 255, .07);
              color: rgba(255, 255, 255, .85);
            }

            .s-nav-link:hover i {
              transform: translateX(2px);
            }

            .s-nav-link.active {
              background: var(--accent);
              color: #fff;
              font-weight: 600;
              box-shadow: 0 4px 14px rgba(99, 102, 241, .35);
            }

            .s-nav-link.active i {
              transform: none;
            }

            .s-badge {
              margin-left: auto;
              font-size: 10px;
              font-weight: 700;
              padding: 2px 7px;
              border-radius: 20px;
              background: rgba(255, 255, 255, .13);
              color: rgba(255, 255, 255, .7);
            }

            .s-nav-link.active .s-badge {
              background: rgba(255, 255, 255, .25);
              color: #fff;
            }

            .s-badge.alert {
              background: var(--red);
              color: #fff;
            }

            .s-bottom {
              padding: 14px 12px;
              border-top: 1px solid rgba(255, 255, 255, .07);
            }

            .s-logout {
              display: flex;
              align-items: center;
              gap: 10px;
              padding: 10px 12px;
              border-radius: 11px;
              color: rgba(255, 255, 255, .35);
              font-size: 13px;
              font-weight: 500;
              cursor: pointer;
              transition: all .18s;
            }

            .s-logout:hover {
              background: rgba(239, 68, 68, .12);
              color: var(--red);
            }

            .tb-date {
              font-size: 12px;
              color: var(--muted);
              font-family: 'JetBrains Mono', monospace;
              margin-right: 15px;
              display: flex;
              align-items: center;
            }

            .main {
              margin-left: var(--sidebar-w);
              flex: 1;
              display: flex;
              flex-direction: column;
            }

            .topbar {
              background: var(--card);
              border-bottom: 1.5px solid var(--border);
              padding: 14px 30px;
              display: flex;
              align-items: center;
              gap: 14px;
              position: sticky;
              top: 0;
              z-index: 100;
            }

            .topbar-page-title {
              font-weight: 700;
              font-size: 17px;
            }

            .topbar-right {
              margin-left: auto;
              display: flex;
              align-items: center;
              gap: 10px;
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
              position: relative;
            }

            .tb-btn:hover {
              border-color: var(--accent);
              color: var(--accent);
            }

            .tb-notif {
              position: absolute;
              top: 5px;
              right: 5px;
              width: 8px;
              height: 8px;
              border-radius: 50%;
              background: var(--red);
              border: 2px solid var(--card);
            }

            .tb-search {
              display: flex;
              align-items: center;
              gap: 8px;
              background: var(--bg);
              border: 1.5px solid var(--border);
              border-radius: 10px;
              padding: 7px 13px;
            }

            .tb-search input {
              border: none;
              background: transparent;
              font-size: 13px;
              font-family: inherit;
              outline: none;
              width: 190px;
            }

            .tb-search i {
              color: var(--muted);
              font-size: 14px;
            }

            .mobile-toggle {
              display: none;
              background: none;
              border: none;
              font-size: 22px;
              color: var(--text);
              cursor: pointer;
            }

            .page {
              display: none;
              padding: 26px 30px;
              animation: fadeUp .28s ease;
            }

            .page.active {
              display: block;
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
              gap: 12px;
            }

            .pg-header-left h4 {
              font-weight: 800;
              font-size: 21px;
              margin: 0;
            }

            .pg-header-left p {
              color: var(--muted);
              font-size: 13.5px;
              margin: 4px 0 0;
            }

            .card-box {
              background: var(--card);
              border-radius: 16px;
              border: 1.5px solid var(--border);
            }

            .card-head {
              padding: 16px 20px;
              border-bottom: 1.5px solid var(--border);
              display: flex;
              align-items: center;
              gap: 10px;
            }

            .card-head h6 {
              font-weight: 700;
              margin: 0;
              font-size: 14px;
            }

            .card-body-p {
              padding: 20px;
            }

            .stat {
              background: var(--card);
              border-radius: 16px;
              border: 1.5px solid var(--border);
              padding: 20px;
              transition: transform .2s, box-shadow .2s;
            }

            .stat:hover {
              transform: translateY(-3px);
              box-shadow: 0 8px 28px rgba(0, 0, 0, .07);
            }

            .stat-ico {
              width: 46px;
              height: 46px;
              border-radius: 13px;
              display: flex;
              align-items: center;
              justify-content: center;
              font-size: 20px;
              margin-bottom: 14px;
            }

            .stat h3 {
              font-size: 28px;
              font-weight: 800;
              margin: 0;
              font-family: 'JetBrains Mono', monospace;
            }

            .stat p {
              font-size: 13px;
              color: var(--muted);
              margin: 4px 0 10px;
            }

            .tag {
              display: inline-block;
              font-size: 11px;
              font-weight: 700;
              padding: 3px 10px;
              border-radius: 20px;
            }

            .tag-green {
              background: #d1fae5;
              color: #059669;
            }

            .tag-red {
              background: #fee2e2;
              color: #dc2626;
            }

            .tag-yellow {
              background: #fef3c7;
              color: #d97706;
            }

            .tag-blue {
              background: #dbeafe;
              color: #2563eb;
            }

            .tag-purple {
              background: #ede9fe;
              color: #7c3aed;
            }

            .prog-bar-wrap {
              background: #f1f5f9;
              border-radius: 100px;
              height: 8px;
              overflow: hidden;
            }

            .prog-bar {
              height: 100%;
              border-radius: 100px;
            }

            .tbl thead th {
              font-size: 11px;
              text-transform: uppercase;
              letter-spacing: .8px;
              color: var(--muted);
              border: none;
              padding: 12px 16px;
              background: #f8fafc;
            }

            .tbl td {
              font-size: 13px;
              padding: 11px 16px;
              vertical-align: middle;
              border-color: var(--border);
            }

            .tbl tbody tr:hover {
              background: #f8fafc;
            }

            .assignment-row {
              display: flex;
              align-items: center;
              gap: 12px;
              padding: 12px 0;
              border-bottom: 1px solid var(--border);
            }

            .assignment-row:last-child {
              border: none;
            }

            .asgn-icon {
              width: 38px;
              height: 38px;
              border-radius: 10px;
              display: flex;
              align-items: center;
              justify-content: center;
              font-size: 17px;
              flex-shrink: 0;
            }

            .asgn-info {
              flex: 1;
              min-width: 0;
            }

            .asgn-info p {
              margin: 0;
              font-size: 13.5px;
              font-weight: 600;
            }

            .asgn-info small {
              color: var(--muted);
              font-size: 12px;
            }

            .time-slot {
              background: var(--bg);
              border-radius: 12px;
              padding: 12px 14px;
              margin-bottom: 8px;
              display: flex;
              align-items: center;
              gap: 12px;
              border-left: 3px solid transparent;
            }

            .time-slot.active-slot {
              background: var(--accent-glow);
              border-left-color: var(--accent);
            }

            .time-text {
              font-size: 12px;
              font-family: 'JetBrains Mono', monospace;
              color: var(--muted);
              min-width: 80px;
            }

            .slot-info {
              flex: 1;
            }

            .slot-info p {
              margin: 0;
              font-size: 13px;
              font-weight: 600;
            }

            .slot-info small {
              color: var(--muted);
              font-size: 12px;
            }

            .slot-room {
              font-size: 11px;
              font-weight: 600;
              background: rgba(99, 102, 241, .1);
              color: var(--accent);
              padding: 3px 9px;
              border-radius: 20px;
            }

            .notice-item {
              padding: 14px;
              border-radius: 13px;
              margin-bottom: 10px;
              border: 1.5px solid var(--border);
            }

            .notice-item h6 {
              font-size: 14px;
              font-weight: 700;
              margin: 0 0 4px;
            }

            .notice-item p {
              font-size: 13px;
              color: var(--muted);
              margin: 0;
            }

            .notice-date {
              font-size: 11px;
              color: var(--muted);
              font-family: 'JetBrains Mono', monospace;
            }

            /* PROFILE */
            .profile-hero {
              background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 60%, #0f172a 100%);
              border-radius: 20px;
              padding: 36px 32px;
              position: relative;
              overflow: hidden;
              margin-bottom: 24px;
            }

            .profile-hero::before {
              content: '';
              position: absolute;
              width: 300px;
              height: 300px;
              border-radius: 50%;
              background: rgba(99, 102, 241, .15);
              top: -80px;
              right: -60px;
            }

            .profile-avatar-wrap {
              position: relative;
              width: fit-content;
              margin-bottom: 16px;
            }

            .profile-avatar {
              width: 100px;
              height: 100px;
              border-radius: 22px;
              border: 3px solid var(--accent);
              overflow: hidden;
              box-shadow: 0 8px 32px rgba(99, 102, 241, .4);
            }

            .profile-avatar-init {
              width: 100%;
              height: 100%;
              background: linear-gradient(135deg, var(--accent), var(--accent-light));
              display: flex;
              align-items: center;
              justify-content: center;
              font-size: 36px;
              font-weight: 800;
              color: #fff;
            }

            .avatar-edit-btn {
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
              border: 2px solid #0f172a;
              transition: transform .2s;
            }

            .avatar-edit-btn:hover {
              transform: scale(1.1);
            }

            .avatar-edit-btn i {
              font-size: 13px;
              color: #fff;
            }

            .profile-hero h3 {
              color: #fff;
              font-size: 24px;
              font-weight: 800;
              margin: 0 0 4px;
            }

            .profile-hero .roll {
              color: rgba(255, 255, 255, .5);
              font-size: 13px;
              font-family: 'JetBrains Mono', monospace;
            }

            .profile-tags {
              display: flex;
              flex-wrap: wrap;
              gap: 8px;
              margin-top: 12px;
            }

            .ptag {
              background: rgba(255, 255, 255, .08);
              border: 1px solid rgba(255, 255, 255, .12);
              color: rgba(255, 255, 255, .7);
              font-size: 12px;
              font-weight: 500;
              padding: 4px 12px;
              border-radius: 20px;
            }

            .profile-edit-btn {
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
              gap: 7px;
            }

            .profile-edit-btn:hover {
              background: var(--accent);
              border-color: var(--accent);
            }

            .modal-backdrop-custom {
              position: fixed;
              inset: 0;
              background: rgba(0, 0, 0, .55);
              backdrop-filter: blur(4px);
              z-index: 500;
              display: none;
              align-items: center;
              justify-content: center;
            }

            .modal-backdrop-custom.show {
              display: flex;
            }

            .edit-modal {
              background: #fff;
              border-radius: 20px;
              width: 90%;
              max-width: 560px;
              max-height: 90vh;
              overflow-y: auto;
              animation: modalIn .25s ease;
            }

            @keyframes modalIn {
              from {
                opacity: 0;
                transform: scale(.95)
              }

              to {
                opacity: 1;
                transform: scale(1)
              }
            }

            .edit-modal-head {
              padding: 22px 24px 18px;
              border-bottom: 1.5px solid var(--border);
              display: flex;
              align-items: center;
              justify-content: space-between;
            }

            .edit-modal-head h5 {
              font-weight: 800;
              margin: 0;
              font-size: 17px;
            }

            .modal-close {
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
              color: var(--muted);
            }

            .modal-close:hover {
              background: #fee2e2;
              color: var(--red);
            }

            .edit-modal-body {
              padding: 22px 24px;
            }

            .avatar-upload-area {
              display: flex;
              align-items: center;
              gap: 20px;
              background: var(--bg);
              border-radius: 14px;
              padding: 16px;
              margin-bottom: 20px;
            }

            .upload-preview {
              width: 72px;
              height: 72px;
              border-radius: 16px;
              overflow: hidden;
              border: 2px solid var(--accent);
              flex-shrink: 0;
            }

            .upload-preview-init {
              width: 100%;
              height: 100%;
              background: linear-gradient(135deg, var(--accent), var(--accent-light));
              display: flex;
              align-items: center;
              justify-content: center;
              font-size: 26px;
              font-weight: 800;
              color: #fff;
            }

            .upload-btn {
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
              font-family: inherit;
            }

            .form-label {
              font-size: 12px;
              font-weight: 700;
              text-transform: uppercase;
              letter-spacing: .6px;
              color: var(--muted);
              margin-bottom: 6px;
            }

            .form-control,
            .form-select {
              border-radius: 10px;
              border: 1.5px solid var(--border);
              font-size: 13.5px;
              font-family: inherit;
              padding: 10px 14px;
            }

            .form-control:focus,
            .form-select:focus {
              border-color: var(--accent);
              box-shadow: 0 0 0 3px rgba(99, 102, 241, .12);
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
              box-shadow: 0 4px 14px rgba(99, 102, 241, .35);
            }

            @media (max-width: 768px) {
              .sidebar {
                transform: translateX(-100%);
              }

              .sidebar.open {
                transform: translateX(0);
              }

              .main {
                margin-left: 0;
              }

              .mobile-toggle {
                display: block;
              }

              .topbar {
                padding: 12px 16px;
              }

              .page {
                padding: 18px 16px;
              }

              .tb-search {
                display: none;
              }
            }
          </style>
        </head>

        <body>

          <aside class="sidebar" id="sidebar">
            <div class="s-brand">
              <div class="s-brand-icon"><i class="bi bi-mortarboard-fill"></i></div>
              <div class="s-brand-text">
                <h6>EduManage</h6>
                <small>Student Portal</small>
              </div>
            </div>

            <div class="s-student-card">
              <div class="s-avatar">
                <img src="<%= sPhotoBase64 != null ? " data:image/jpeg;base64," + sPhotoBase64
                  : "images/user_default_photo.webp" %>"
                style="width:100%;height:100%;object-fit:cover;" id="sidebar-photo" />
              </div>
              <div class="s-student-info">
                <h6 id="sidebar-name">
                  <%= sName %>
                </h6>
                <small>
                  <%= sClass %>
                </small>
              </div>
              <div class="s-badge ms-auto" style="margin-left:auto; font-size:10px;">Student</div>
            </div>

            <nav class="s-nav">
              <div class="s-section-label">Overview</div>
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

              <div class="s-section-label">Academics</div>
              <div class="s-nav-item">
                <a class="s-nav-link" onclick="showPage('attendance', this)">
                  <i class="bi bi-calendar-check-fill"></i> My Attendance
                </a>
              </div>
              <div class="s-nav-item">
                <a class="s-nav-link" onclick="showPage('results', this)">
                  <i class="bi bi-bar-chart-fill"></i> Results & Grades
                </a>
              </div>
              <div class="s-nav-item">
                <a class="s-nav-link" onclick="showPage('assignments', this)">
                  <i class="bi bi-clipboard2-check-fill"></i> Assignments
                  <span class="s-badge alert">3</span>
                </a>
              </div>
              <div class="s-nav-item">
                <a class="s-nav-link" onclick="showPage('timetable', this)">
                  <i class="bi bi-clock-fill"></i> Timetable
                </a>
              </div>

              <div class="s-section-label">Info</div>
              <div class="s-nav-item">
                <a class="s-nav-link" onclick="showPage('fees', this)">
                  <i class="bi bi-credit-card-fill"></i> Fee Status
                </a>
              </div>
              <div class="s-nav-item">
                <a class="s-nav-link" onclick="showPage('notices', this)">
                  <i class="bi bi-bell-fill"></i> Notices
                  <span class="s-badge">2</span>
                </a>
              </div>
            </nav>

            <div class="s-bottom">
              <a href="/student_logout" class="s-logout" style="text-decoration: none;">
                <i class="bi bi-box-arrow-left" style="font-size:16px;"></i> Logout
              </a>
            </div>
          </aside>

          <div class="main">
            <div class="topbar">
              <button class="mobile-toggle" onclick="toggleSidebar()"><i class="bi bi-list"></i></button>
              <span class="topbar-page-title" id="page-title">Dashboard</span>
              <div class="topbar-right">
                <span class="tb-date" id="topbar-date">Monday, 2 March 2026</span>
                <div class="tb-search">
                  <i class="bi bi-search"></i>
                  <input type="text" placeholder="Search..." />
                </div>
                <div class="tb-btn">
                  <i class="bi bi-bell"></i>
                  <span class="tb-notif"></span>
                </div>
                <div><a href="/student_logout" class="tb-btn" style="text-decoration: none;">
                    <i class="bi bi-box-arrow-right"></i>
                  </a></div>
              </div>
            </div>

            <!-- DASHBOARD -->
            <div class="page active" id="page-dashboard">
              <div class="pg-header">
                <h4>Namaste, <%= sName %>! 👋</h4>
                <p>Apna aaj ka academic overview dekho</p>
              </div>
              <div class="row g-3 mb-4">
                <div class="col-6 col-xl-3">
                  <div class="stat">
                    <div class="stat-ico" style="background:#ede9fe; color:#7c3aed;"><i
                        class="bi bi-graph-up-arrow"></i>
                    </div>
                    <h3>78.4%</h3>
                    <p>Overall Score</p>
                    <span class="tag tag-purple">↑ 4.2% last exam</span>
                  </div>
                </div>
                <div class="col-6 col-xl-3">
                  <div class="stat">
                    <div class="stat-ico" style="background:#d1fae5; color:#059669;"><i
                        class="bi bi-calendar-check-fill"></i>
                    </div>
                    <h3>91%</h3>
                    <p>Attendance</p>
                    <span class="tag tag-green">Good Standing</span>
                  </div>
                </div>
                <div class="col-6 col-xl-3">
                  <div class="stat">
                    <div class="stat-ico" style="background:#fef3c7; color:#d97706;"><i
                        class="bi bi-clipboard2-check-fill"></i>
                    </div>
                    <h3>3</h3>
                    <p>Pending Tasks</p>
                    <span class="tag tag-yellow">Due this week</span>
                  </div>
                </div>
                <div class="col-6 col-xl-3">
                  <div class="stat">
                    <div class="stat-ico" style="background:#dbeafe; color:#2563eb;"><i class="bi bi-trophy-fill"></i>
                    </div>
                    <h3>#8</h3>
                    <p>Class Rank</p>
                    <span class="tag tag-blue">Out of 42</span>
                  </div>
                </div>
              </div>

              <div class="row g-3">
                <div class="col-12 col-lg-7">
                  <div class="card-box">
                    <div class="card-head">
                      <i class="bi bi-bar-chart-fill" style="color:var(--accent);"></i>
                      <h6>Subject Performance</h6>
                    </div>
                    <div class="card-body-p">
                      <div class="mb-3">
                        <div class="d-flex justify-content-between mb-1">
                          <span style="font-size:13px;font-weight:600;">Mathematics</span>
                          <span
                            style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--green);">88%</span>
                        </div>
                        <div class="prog-bar-wrap">
                          <div class="prog-bar" style="width:88%;background:#10b981;"></div>
                        </div>
                      </div>
                      <div class="mb-3">
                        <div class="d-flex justify-content-between mb-1">
                          <span style="font-size:13px;font-weight:600;">Science</span>
                          <span
                            style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--accent);">82%</span>
                        </div>
                        <div class="prog-bar-wrap">
                          <div class="prog-bar" style="width:82%;background:#6366f1;"></div>
                        </div>
                      </div>
                      <div class="mb-3">
                        <div class="d-flex justify-content-between mb-1">
                          <span style="font-size:13px;font-weight:600;">English</span>
                          <span
                            style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--blue);">76%</span>
                        </div>
                        <div class="prog-bar-wrap">
                          <div class="prog-bar" style="width:76%;background:#3b82f6;"></div>
                        </div>
                      </div>
                      <div class="mb-3">
                        <div class="d-flex justify-content-between mb-1">
                          <span style="font-size:13px;font-weight:600;">Social Science</span>
                          <span
                            style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:var(--yellow);">71%</span>
                        </div>
                        <div class="prog-bar-wrap">
                          <div class="prog-bar" style="width:71%;background:#f59e0b;"></div>
                        </div>
                      </div>
                      <div>
                        <div class="d-flex justify-content-between mb-1">
                          <span style="font-size:13px;font-weight:600;">Hindi</span>
                          <span
                            style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:#ec4899;">69%</span>
                        </div>
                        <div class="prog-bar-wrap">
                          <div class="prog-bar" style="width:69%;background:#ec4899;"></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="col-12 col-lg-5">
                  <div class="card-box h-100">
                    <div class="card-head">
                      <i class="bi bi-clipboard2-check-fill" style="color:var(--yellow);"></i>
                      <h6>Upcoming Assignments</h6>
                    </div>
                    <div class="card-body-p">
                      <div class="assignment-row">
                        <div class="asgn-icon" style="background:#fef3c7;color:#d97706;"><i
                            class="bi bi-calculator-fill"></i>
                        </div>
                        <div class="asgn-info">
                          <p>Algebra Chapter 7 Exercise</p><small>Mathematics • 3 Mar 2026</small>
                        </div>
                        <span class="tag tag-red">Urgent</span>
                      </div>
                      <div class="assignment-row">
                        <div class="asgn-icon" style="background:#d1fae5;color:#059669;"><i
                            class="bi bi-flask-fill"></i>
                        </div>
                        <div class="asgn-info">
                          <p>Lab Report – Acid-Base</p><small>Science • 5 Mar 2026</small>
                        </div>
                        <span class="tag tag-yellow">Soon</span>
                      </div>
                      <div class="assignment-row">
                        <div class="asgn-icon" style="background:#dbeafe;color:#2563eb;"><i class="bi bi-translate"></i>
                        </div>
                        <div class="asgn-info">
                          <p>Essay: My Favourite Season</p><small>English • 7 Mar 2026</small>
                        </div>
                        <span class="tag tag-green">Open</span>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="col-12">
                  <div class="card-box">
                    <div class="card-head">
                      <i class="bi bi-clock-fill" style="color:var(--blue);"></i>
                      <h6>Aaj ki Classes</h6>
                      <span class="ms-auto" id="dash-date" style="font-size:12px;color:var(--muted);">Monday, 2 March
                        2026</span>
                    </div>
                    <div class="card-body-p">
                      <div class="row g-2">
                        <div class="col-md-4">
                          <div class="time-slot">
                            <span class="time-text">8:00 – 9:00</span>
                            <div class="slot-info">
                              <p>Mathematics</p><small>Mr. Ramesh Gupta</small>
                            </div>
                            <span class="slot-room">R-201</span>
                          </div>
                        </div>
                        <div class="col-md-4">
                          <div class="time-slot active-slot">
                            <span class="time-text">9:05 – 10:05</span>
                            <div class="slot-info">
                              <p>Science ✦ Now</p><small>Mrs. Priya Joshi</small>
                            </div>
                            <span class="slot-room">Lab-1</span>
                          </div>
                        </div>
                        <div class="col-md-4">
                          <div class="time-slot">
                            <span class="time-text">10:15 – 11:15</span>
                            <div class="slot-info">
                              <p>English</p><small>Mr. David Abraham</small>
                            </div>
                            <span class="slot-room">R-204</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- PROFILE -->
            <div class="page" id="page-profile">
              <div class="profile-hero">
                <button class="profile-edit-btn" onclick="openEditModal()">
                  <i class="bi bi-pencil-fill"></i> <span>Profile Edit Karo</span>
                </button>
                <div class="profile-avatar-wrap">
                  <div class="profile-avatar">
                    <img src="<%= sPhotoBase64 != null ? " data:image/jpeg;base64," + sPhotoBase64
                      : "images/user_default_photo.webp" %>"
                    style="width:100%;height:100%;object-fit:cover;" id="profile-photo" />
                  </div>
                  <div class="avatar-edit-btn" onclick="document.getElementById('avatar-input-hero').click()">
                    <i class="bi bi-camera-fill"></i>
                  </div>
                  <input type="file" id="avatar-input-hero" accept="image/*" style="display:none"
                    onchange="handleAvatarChange(this)" />
                </div>
                <h3 id="profile-name">
                  <%= sName %>
                </h3>
                <div class="roll" id="profile-roll-class">Roll No. #<%= sRoll %> • Class <%= sClassName %> - <%=
                        sSection %>
                </div>

                <span class="ptag"
                  style="background:rgba(16,185,129,.15);border-color:rgba(16,185,129,.25);color:#10b981;">Active
                  Student</span>
              </div>
              <% if (!hasPersonalInfo) { %>
                <div class="card-box p-5 text-center mb-4">
                  <div class="mb-4">
                    <div
                      style="width: 80px; height: 80px; background: var(--accent-glow); color: var(--accent); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto; font-size: 32px;">
                      <i class="bi bi-person-exclamation"></i>
                    </div>
                  </div>
                  <h5 style="font-weight: 800; margin-bottom: 12px;">Aapka Profile Incomplete Hai</h5>
                  <p style="color: var(--muted); font-size: 14px; max-width: 400px; margin: 0 auto 24px;">Your Profile
                    is currently incomplete. Please, click on edit profile and fill all the details.</p>
                  <button class="profile-edit-btn"
                    style="position: static; background: var(--accent); border: none; padding: 10px 24px;"
                    onclick="openEditModal()">
                    <i class="bi bi-pencil-fill"></i> <span>Edit Profile Abhi</span>
                  </button>
                </div>
                <% } else { %>
                  <div class="row justify-content-center">
                    <div class="col-12 col-xl-10">
                      <div class="card-box">
                        <div class="card-head"><i class="bi bi-person-fill" style="color:var(--accent);"></i>
                          <h6>Personal Information</h6>
                        </div>
                        <div class="card-body-p">
                          <div class="row g-4">
                            <!-- Grid Layout: name + dob, gender + blood group, phone + email, address full width -->
                            <div class="col-md-6">
                              <div
                                style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:6px;">
                                Full Name</div>
                              <div id="info-name" style="font-size:15px;font-weight:600;">
                                <%= sName %>
                              </div>
                            </div>
                            <div class="col-md-6">
                              <div
                                style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:6px;">
                                Date of Birth</div>
                              <div id="info-dob" style="font-size:15px;font-weight:600;">
                                <%= sDob %>
                              </div>
                            </div>

                            <div class="col-md-6">
                              <div
                                style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:6px;">
                                Gender</div>
                              <div id="info-gender" style="font-size:15px;font-weight:600;">
                                <%= sGender %>
                              </div>
                            </div>
                            <div class="col-md-6">
                              <div
                                style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:6px;">
                                Blood Group</div>
                              <div id="info-blood" style="font-size:15px;font-weight:600;">
                                <%= sBlood %>
                              </div>
                            </div>

                            <div class="col-md-6">
                              <div
                                style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:6px;">
                                Contact Number</div>
                              <div id="info-phone" style="font-size:15px;font-weight:600;">
                                <%= sPhone %>
                              </div>
                            </div>
                            <div class="col-md-6">
                              <div
                                style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:6px;">
                                Email</div>
                              <div id="info-email" style="font-size:15px;font-weight:600;">
                                <%= sEmail %>
                              </div>
                            </div>

                            <div class="col-12">
                              <div
                                style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:6px;">
                                Current Address</div>
                              <div id="info-address" style="font-size:15px;font-weight:600;line-height:1.5;">
                                <%= sAddress %>
                              </div>
                            </div>

                            <div class="col-md-4">
                              <div
                                style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:6px;">
                                Class</div>
                              <div id="info-class" style="font-size:15px;font-weight:600;">
                                <%= sClassName %>
                              </div>
                            </div>
                            <div class="col-md-4">
                              <div
                                style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:6px;">
                                Roll Number</div>
                              <div id="info-roll" style="font-size:15px;font-weight:600;">
                                <%= sRoll %>
                              </div>
                            </div>
                            <div class="col-md-4">
                              <div
                                style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:6px;">
                                Section</div>
                              <div id="info-section" style="font-size:15px;font-weight:600;">
                                <%= sSection %>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <% } %>
            </div> <!-- FIX: page-profile closes here -->

            <!-- ATTENDANCE -->
            <div class="page" id="page-attendance">
              <div class="pg-header">
                <div class="pg-header-left">
                  <h4>My Attendance</h4>
                  <p>Apni monthly attendance track karo</p>
                </div>
              </div>
              <div class="row g-3 mb-3">
                <div class="col-6 col-md-3">
                  <div class="stat">
                    <div class="stat-ico" style="background:#d1fae5;color:#059669;"><i
                        class="bi bi-check-circle-fill"></i>
                    </div>
                    <h3>164</h3>
                    <p>Total Present</p><span class="tag tag-green">91%</span>
                  </div>
                </div>
                <div class="col-6 col-md-3">
                  <div class="stat">
                    <div class="stat-ico" style="background:#fee2e2;color:#dc2626;"><i class="bi bi-x-circle-fill"></i>
                    </div>
                    <h3>16</h3>
                    <p>Total Absent</p><span class="tag tag-red">8.9%</span>
                  </div>
                </div>
                <div class="col-6 col-md-3">
                  <div class="stat">
                    <div class="stat-ico" style="background:#fef3c7;color:#d97706;"><i
                        class="bi bi-dash-circle-fill"></i>
                    </div>
                    <h3>4</h3>
                    <p>Leave</p><span class="tag tag-yellow">Approved</span>
                  </div>
                </div>
                <div class="col-6 col-md-3">
                  <div class="stat">
                    <div class="stat-ico" style="background:#dbeafe;color:#2563eb;"><i class="bi bi-calendar3"></i>
                    </div>
                    <h3>184</h3>
                    <p>Total Working Days</p>
                  </div>
                </div>
              </div>
              <div class="card-box">
                <div class="card-head">
                  <h6>Month-wise Attendance</h6>
                </div>
                <div class="card-body-p">
                  <table class="table tbl mb-0">
                    <thead>
                      <tr>
                        <th>Month</th>
                        <th>Working Days</th>
                        <th>Present</th>
                        <th>Absent</th>
                        <th>%</th>
                        <th>Status</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td>April 2025</td>
                        <td>26</td>
                        <td>25</td>
                        <td>1</td>
                        <td style="font-family:'JetBrains Mono',monospace;font-weight:700;color:var(--green);">96%</td>
                        <td><span class="tag tag-green">Excellent</span></td>
                      </tr>
                      <tr>
                        <td>May 2025</td>
                        <td>24</td>
                        <td>22</td>
                        <td>2</td>
                        <td style="font-family:'JetBrains Mono',monospace;font-weight:700;color:var(--green);">92%</td>
                        <td><span class="tag tag-green">Good</span></td>
                      </tr>
                      <tr>
                        <td>June 2025</td>
                        <td>22</td>
                        <td>19</td>
                        <td>3</td>
                        <td style="font-family:'JetBrains Mono',monospace;font-weight:700;color:var(--yellow);">86%</td>
                        <td><span class="tag tag-yellow">Average</span></td>
                      </tr>
                      <tr>
                        <td>July 2025</td>
                        <td>26</td>
                        <td>25</td>
                        <td>1</td>
                        <td style="font-family:'JetBrains Mono',monospace;font-weight:700;color:var(--green);">96%</td>
                        <td><span class="tag tag-green">Excellent</span></td>
                      </tr>
                      <tr>
                        <td>Feb 2026</td>
                        <td>20</td>
                        <td>17</td>
                        <td>3</td>
                        <td style="font-family:'JetBrains Mono',monospace;font-weight:700;color:var(--yellow);">85%</td>
                        <td><span class="tag tag-yellow">Average</span></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

            <!-- RESULTS -->
            <div class="page" id="page-results">
              <div class="pg-header">
                <div class="pg-header-left">
                  <h4>Results & Grades</h4>
                  <p>Apne saare exam results dekho</p>
                </div>
              </div>
              <div class="row g-3 mb-3">
                <div class="col-md-4">
                  <div class="stat">
                    <div class="stat-ico" style="background:#ede9fe;color:#7c3aed;"><i class="bi bi-trophy-fill"></i>
                    </div>
                    <h3>78.4%</h3>
                    <p>Overall Percentage</p><span class="tag tag-purple">B+ Grade</span>
                  </div>
                </div>
                <div class="col-md-4">
                  <div class="stat">
                    <div class="stat-ico" style="background:#d1fae5;color:#059669;"><i class="bi bi-graph-up-arrow"></i>
                    </div>
                    <h3>#8</h3>
                    <p>Class Rank</p><span class="tag tag-green">Top 20%</span>
                  </div>
                </div>
                <div class="col-md-4">
                  <div class="stat">
                    <div class="stat-ico" style="background:#dbeafe;color:#2563eb;"><i class="bi bi-star-fill"></i>
                    </div>
                    <h3>88%</h3>
                    <p>Best Subject</p><span class="tag tag-blue">Mathematics</span>
                  </div>
                </div>
              </div>
              <div class="card-box">
                <div class="card-head">
                  <h6>Half-Yearly Exam Results 2025</h6>
                </div>
                <div class="card-body-p">
                  <table class="table tbl mb-0">
                    <thead>
                      <tr>
                        <th>Subject</th>
                        <th>Max Marks</th>
                        <th>Marks Obtained</th>
                        <th>Percentage</th>
                        <th>Grade</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td style="font-weight:600;">Mathematics</td>
                        <td>100</td>
                        <td style="font-family:'JetBrains Mono',monospace;">88</td>
                        <td style="font-weight:700;color:var(--green);">88%</td>
                        <td><span class="tag tag-green">A</span></td>
                      </tr>
                      <tr>
                        <td style="font-weight:600;">Science</td>
                        <td>100</td>
                        <td style="font-family:'JetBrains Mono',monospace;">82</td>
                        <td style="font-weight:700;color:var(--accent);">82%</td>
                        <td><span class="tag tag-purple">B+</span></td>
                      </tr>
                      <tr>
                        <td style="font-weight:600;">English</td>
                        <td>100</td>
                        <td style="font-family:'JetBrains Mono',monospace;">76</td>
                        <td style="font-weight:700;color:var(--blue);">76%</td>
                        <td><span class="tag tag-blue">B</span></td>
                      </tr>
                      <tr>
                        <td style="font-weight:600;">Social Science</td>
                        <td>100</td>
                        <td style="font-family:'JetBrains Mono',monospace;">71</td>
                        <td style="font-weight:700;color:var(--yellow);">71%</td>
                        <td><span class="tag tag-yellow">B</span></td>
                      </tr>
                      <tr>
                        <td style="font-weight:600;">Hindi</td>
                        <td>100</td>
                        <td style="font-family:'JetBrains Mono',monospace;">69</td>
                        <td style="font-weight:700;color:var(--red);">69%</td>
                        <td><span class="tag tag-yellow">C+</span></td>
                      </tr>
                      <tr style="background:#f8fafc;">
                        <td colspan="2" style="font-weight:800;">Total / Average</td>
                        <td style="font-family:'JetBrains Mono',monospace;font-weight:700;">386/500</td>
                        <td style="font-weight:800;color:var(--accent);">78.4%</td>
                        <td><span class="tag tag-purple">B+</span></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

            <!-- ASSIGNMENTS -->
            <div class="page" id="page-assignments">
              <div class="pg-header">
                <div class="pg-header-left">
                  <h4>Assignments</h4>
                  <p>Pending aur completed assignments</p>
                </div>
              </div>
              <div class="card-box mb-3">
                <div class="card-head"><i class="bi bi-hourglass-split" style="color:var(--red);"></i>
                  <h6>Pending (3)</h6>
                </div>
                <div class="card-body-p">
                  <div class="assignment-row">
                    <div class="asgn-icon" style="background:#fef3c7;color:#d97706;"><i
                        class="bi bi-calculator-fill"></i>
                    </div>
                    <div class="asgn-info">
                      <p>Algebra Chapter 7 Exercise</p><small>Mathematics • Due: 3 March 2026</small>
                    </div><span class="tag tag-red">Urgent</span>
                  </div>
                  <div class="assignment-row">
                    <div class="asgn-icon" style="background:#d1fae5;color:#059669;"><i class="bi bi-flask-fill"></i>
                    </div>
                    <div class="asgn-info">
                      <p>Lab Report – Acid-Base Reaction</p><small>Science • Due: 5 March 2026</small>
                    </div><span class="tag tag-yellow">Soon</span>
                  </div>
                  <div class="assignment-row">
                    <div class="asgn-icon" style="background:#dbeafe;color:#2563eb;"><i class="bi bi-translate"></i>
                    </div>
                    <div class="asgn-info">
                      <p>Essay: My Favourite Season</p><small>English • Due: 7 March 2026</small>
                    </div><span class="tag tag-green">Open</span>
                  </div>
                </div>
              </div>
              <div class="card-box">
                <div class="card-head"><i class="bi bi-check-circle-fill" style="color:var(--green);"></i>
                  <h6>Completed (5)</h6>
                </div>
                <div class="card-body-p">
                  <div class="assignment-row">
                    <div class="asgn-icon" style="background:#d1fae5;color:#059669;"><i class="bi bi-check2-circle"></i>
                    </div>
                    <div class="asgn-info">
                      <p>Chapter 5 – Geometry Problems</p><small>Mathematics • Submitted 24 Feb</small>
                    </div><span class="tag tag-green">Done ✓</span>
                  </div>
                  <div class="assignment-row">
                    <div class="asgn-icon" style="background:#d1fae5;color:#059669;"><i class="bi bi-check2-circle"></i>
                    </div>
                    <div class="asgn-info">
                      <p>History Essay – Mughal Empire</p><small>Social Science • Submitted 22 Feb</small>
                    </div><span class="tag tag-green">Done ✓</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- TIMETABLE -->
            <div class="page" id="page-timetable">
              <div class="pg-header">
                <div class="pg-header-left">
                  <h4>My Timetable</h4>
                  <p>Weekly class schedule</p>
                </div>
              </div>
              <div class="card-box">
                <div class="card-head">
                  <h6>Class 10-A Weekly Schedule</h6>
                </div>
                <div class="card-body-p">
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
                        </tr>
                      </thead>
                      <tbody style="font-size:13px;">
                        <tr>
                          <td style="font-family:'JetBrains Mono',monospace;font-size:12px;">8:00–9:00</td>
                          <td style="font-weight:600;color:#7c3aed;">Math</td>
                          <td style="font-weight:600;color:#2563eb;">English</td>
                          <td style="font-weight:600;color:#059669;">Science</td>
                          <td style="font-weight:600;color:#d97706;">SST</td>
                          <td style="font-weight:600;color:#7c3aed;">Math</td>
                        </tr>
                        <tr>
                          <td style="font-family:'JetBrains Mono',monospace;font-size:12px;">9:05–10:05</td>
                          <td style="font-weight:600;color:#059669;">Science</td>
                          <td style="font-weight:600;color:#7c3aed;">Math</td>
                          <td style="font-weight:600;color:#ec4899;">Hindi</td>
                          <td style="font-weight:600;color:#059669;">Science</td>
                          <td style="font-weight:600;color:#2563eb;">English</td>
                        </tr>
                        <tr>
                          <td style="font-family:'JetBrains Mono',monospace;font-size:12px;">10:15–11:15</td>
                          <td style="font-weight:600;color:#2563eb;">English</td>
                          <td style="font-weight:600;color:#ec4899;">Hindi</td>
                          <td style="font-weight:600;color:#7c3aed;">Math</td>
                          <td style="font-weight:600;color:#ec4899;">Hindi</td>
                          <td style="font-weight:600;color:#d97706;">SST</td>
                        </tr>
                        <tr>
                          <td style="font-family:'JetBrains Mono',monospace;font-size:12px;">11:30–12:30</td>
                          <td style="font-weight:600;color:#d97706;">SST</td>
                          <td style="font-weight:600;color:#059669;">Science</td>
                          <td style="font-weight:600;color:#2563eb;">English</td>
                          <td style="font-weight:600;color:#7c3aed;">Math</td>
                          <td style="font-weight:600;color:var(--muted);">Free</td>
                        </tr>
                        <tr>
                          <td style="font-family:'JetBrains Mono',monospace;font-size:12px;">1:30–2:30</td>
                          <td style="font-weight:600;color:#ec4899;">Hindi</td>
                          <td style="font-weight:600;color:#d97706;">SST</td>
                          <td style="font-weight:600;color:var(--muted);">Free</td>
                          <td style="font-weight:600;color:#2563eb;">English</td>
                          <td style="font-weight:600;color:#059669;">Science</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>

            <!-- FEES -->
            <div class="page" id="page-fees">
              <div class="pg-header">
                <div class="pg-header-left">
                  <h4>Fee Status</h4>
                  <p>Apni fee payment history dekho</p>
                </div>
              </div>
              <div class="row g-3 mb-3">
                <div class="col-md-4">
                  <div class="stat">
                    <div class="stat-ico" style="background:#d1fae5;color:#059669;"><i
                        class="bi bi-check-circle-fill"></i>
                    </div>
                    <h3>32,000</h3>
                    <p>Annual Fee (₹)</p><span class="tag tag-green">Paid</span>
                  </div>
                </div>
                <div class="col-md-4">
                  <div class="stat">
                    <div class="stat-ico" style="background:#fef3c7;color:#d97706;"><i class="bi bi-clock-fill"></i>
                    </div>
                    <h3>₹0</h3>
                    <p>Pending Amount</p><span class="tag tag-green">No Dues!</span>
                  </div>
                </div>
                <div class="col-md-4">
                  <div class="stat">
                    <div class="stat-ico" style="background:#dbeafe;color:#2563eb;"><i class="bi bi-receipt"></i></div>
                    <h3>4</h3>
                    <p>Transactions</p><span class="tag tag-blue">This year</span>
                  </div>
                </div>
              </div>
              <div class="card-box">
                <div class="card-head">
                  <h6>Payment History</h6>
                </div>
                <div class="card-body-p">
                  <table class="table tbl mb-0">
                    <thead>
                      <tr>
                        <th>Transaction ID</th>
                        <th>Date</th>
                        <th>Description</th>
                        <th>Amount</th>
                        <th>Status</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td style="font-family:'JetBrains Mono',monospace;font-size:12px;">TXN-20250401</td>
                        <td>1 Apr 2025</td>
                        <td>Q1 Tuition Fee</td>
                        <td style="font-weight:700;">₹8,000</td>
                        <td><span class="tag tag-green">Paid</span></td>
                      </tr>
                      <tr>
                        <td style="font-family:'JetBrains Mono',monospace;font-size:12px;">TXN-20250701</td>
                        <td>1 Jul 2025</td>
                        <td>Q2 Tuition Fee</td>
                        <td style="font-weight:700;">₹8,000</td>
                        <td><span class="tag tag-green">Paid</span></td>
                      </tr>
                      <tr>
                        <td style="font-family:'JetBrains Mono',monospace;font-size:12px;">TXN-20251001</td>
                        <td>1 Oct 2025</td>
                        <td>Q3 Tuition Fee</td>
                        <td style="font-weight:700;">₹8,000</td>
                        <td><span class="tag tag-green">Paid</span></td>
                      </tr>
                      <tr>
                        <td style="font-family:'JetBrains Mono',monospace;font-size:12px;">TXN-20260101</td>
                        <td>1 Jan 2026</td>
                        <td>Q4 Tuition Fee</td>
                        <td style="font-weight:700;">₹8,000</td>
                        <td><span class="tag tag-green">Paid</span></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

            <!-- NOTICES -->
            <div class="page" id="page-notices">
              <div class="pg-header">
                <div class="pg-header-left">
                  <h4>School Notices</h4>
                  <p>Sabhi important announcements</p>
                </div>
              </div>
              <div class="card-box">
                <div class="card-head"><i class="bi bi-megaphone-fill" style="color:var(--yellow);"></i>
                  <h6>Latest Notices</h6>
                </div>
                <div class="card-body-p">
                  <div class="notice-item" style="border-left:4px solid #6366f1;">
                    <div class="d-flex justify-content-between align-items-start mb-1">
                      <h6>Annual Sports Day – 10 March 2026</h6>
                      <span class="notice-date">28 Feb 2026</span>
                    </div>
                    <p>Saare students ko sports ground pe 8 AM tak report karna hai.</p>
                    <span class="tag tag-purple mt-2 d-inline-block">All Students</span>
                  </div>
                  <div class="notice-item" style="border-left:4px solid #f59e0b;">
                    <div class="d-flex justify-content-between align-items-start mb-1">
                      <h6>Half-Yearly Exam Schedule</h6>
                      <span class="notice-date">25 Feb 2026</span>
                    </div>
                    <p>Half-yearly exams 15 March se start honge. Timetable school website pe available hai.</p>
                    <span class="tag tag-yellow mt-2 d-inline-block">Class 10</span>
                  </div>
                  <div class="notice-item" style="border-left:4px solid #10b981;">
                    <div class="d-flex justify-content-between align-items-start mb-1">
                      <h6>Science Exhibition – Registrations Open</h6>
                      <span class="notice-date">20 Feb 2026</span>
                    </div>
                    <p>Inter-school Science Exhibition ke liye registrations shuru ho gaye hain.</p>
                    <span class="tag tag-green mt-2 d-inline-block">Voluntary</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- EDIT MODAL -->
          <div class="modal-backdrop-custom" id="editModal" onclick="closeEditModalOutside(event)">
            <div class="edit-modal">
              <div class="edit-modal-head">
                <h5><i class="bi bi-pencil-fill me-2" style="color:var(--accent);"></i>Profile Edit Karo</h5>
                <button class="modal-close" onclick="closeEditModal()">✕</button>
              </div>
              <div class="edit-modal-body">
                <form action="UpdateProfileServlet" method="post" enctype="multipart/form-data">
                  <div class="avatar-upload-area">
                    <div class="upload-preview">
                      <img src="<%= sPhotoBase64 != null ? " data:image/jpeg;base64," + sPhotoBase64
                        : "images/user_default_photo.webp" %>"
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
                        class="form-control" value="<%= sName %>" /></div>
                    <div class="col-6"><label class="form-label">Date of Birth</label><input name="dob"
                        class="form-control" type="date" value="<%= sDob %>" /></div>
                    <div class="col-6"><label class="form-label">Gender</label><select name="gender"
                        class="form-select">
                        <option <%="Male" .equals(sGender) ? "selected" : "" %>>Male</option>
                        <option <%="Female" .equals(sGender) ? "selected" : "" %>>Female</option>
                        <option <%="Other" .equals(sGender) ? "selected" : "" %>>Other</option>
                      </select></div>
                    <div class="col-6"><label class="form-label">Blood Group</label><select name="blood_group"
                        class="form-select">
                        <option <%="A+" .equals(sBlood) ? "selected" : "" %>>A+</option>
                        <option <%="A-" .equals(sBlood) ? "selected" : "" %>>A-</option>
                        <option <%="B+" .equals(sBlood) ? "selected" : "" %>>B+</option>
                        <option <%="B-" .equals(sBlood) ? "selected" : "" %>>B-</option>
                        <option <%="O+" .equals(sBlood) ? "selected" : "" %>>O+</option>
                        <option <%="O-" .equals(sBlood) ? "selected" : "" %>>O-</option>
                        <option <%="AB+" .equals(sBlood) ? "selected" : "" %>>AB+</option>
                        <option <%="AB-" .equals(sBlood) ? "selected" : "" %>>AB-</option>
                      </select></div>
                    <div class="col-6"><label class="form-label">Phone Number</label><input name="phone"
                        class="form-control" value="<%= sPhone %>" /></div>
                    <div class="col-6"><label class="form-label">Email</label><input name="email" class="form-control"
                        value="<%= sEmail %>" /></div>
                    <div class="col-12"><label class="form-label">Address</label><input name="address"
                        class="form-control" value="<%= sAddress %>" /></div>
                    <div class="col-6"><label class="form-label">Class</label><input name="class" class="form-control"
                        value="<%= sClassName %>" /></div>
                    <div class="col-6"><label class="form-label">Roll Number</label><input name="roll_no"
                        class="form-control" value="<%= sRoll %>" /></div>
                    <div class="col-6"><label class="form-label">Section</label><input name="section"
                        class="form-control" value="<%= sSection %>" /></div>
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

          <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
          <script>
            const pageTitles = {
              dashboard: 'Dashboard', profile: 'My Profile', attendance: 'My Attendance',
              results: 'Results & Grades', assignments: 'Assignments', timetable: 'Timetable',
              fees: 'Fee Status', notices: 'Notices'
            };

            function showPage(name, el) {
              document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
              document.getElementById('page-' + name).classList.add('active');
              document.querySelectorAll('.s-nav-link').forEach(l => l.classList.remove('active'));
              if (el) el.classList.add('active');
              document.getElementById('page-title').textContent = pageTitles[name] || name;
              document.getElementById('sidebar').classList.remove('open');
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

            function closeEditModalOutside(e) {
              if (e.target === document.getElementById('editModal')) closeEditModal();
            }

            function previewImage(input) {
              if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function (e) {
                  document.getElementById('modal-photo-preview').src = e.target.result;
                };
                reader.readAsDataURL(input.files[0]);
              }
            }

            function handleAvatarChange(input) {
              if (!input.files || !input.files[0]) return;
              const reader = new FileReader();
              reader.onload = function (e) {
                const src = e.target.result;
                document.getElementById('sidebar-photo').src = src;
                document.getElementById('profile-photo').src = src;
                document.getElementById('modal-photo-preview').src = src;
              };
              reader.readAsDataURL(input.files[0]);
            }

            function updateDynamicDates() {
              const today = new Date();
              const optionsShort = { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' };
              const optionsLong = { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' };
              const longStr = today.toLocaleDateString('en-GB', optionsLong);
              const shortStr = today.toLocaleDateString('en-GB', optionsShort);
              const dash = document.getElementById('dash-date');
              if (dash) dash.innerText = longStr;
              const topbar = document.getElementById('topbar-date');
              if (topbar) topbar.innerText = shortStr;
            }
            updateDynamicDates();
          </script>
        </body>

        </html>