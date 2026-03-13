<%@ page import="java.sql.*, java.util.*" %>
    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
        <% if (session==null || session.getAttribute("user_id")==null) { response.sendRedirect("/signin"); return; }
            Object userId=session.getAttribute("user_id"); String tName="Teacher" ; String tSubject="Subject Teacher" ;
            String tInitials="T" ; String tPhotoBase64=null; String tDob="" , tGender="" , tBlood="" , tPhone="" ,
            tEmail="" , tAddress="" , tDept="" , tEmpId="" , tQual="" , tExp="" , tJoined="" ; Connection conn=null;
            PreparedStatement pstmt=null; ResultSet rs=null; try { Class.forName("com.mysql.cj.jdbc.Driver");
            conn=DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root" , "" ); String
            sql="SELECT u.name, t.* FROM user u LEFT JOIN teachers t ON u.user_id = t.user_id WHERE u.user_id = ?" ;
            pstmt=conn.prepareStatement(sql); pstmt.setObject(1, userId); rs=pstmt.executeQuery(); if (rs.next()) {
            tName=rs.getString("name"); tDob=rs.getString("dob"); tGender=rs.getString("gender");
            tBlood=rs.getString("blood_group"); tPhone=rs.getString("phone"); tEmail=rs.getString("email");
            tAddress=rs.getString("address"); tDept=rs.getString("department"); tEmpId=rs.getString("employee_id");
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

                // Conditional Display Logic for Profile Sections
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

                        /* SIDEBAR */
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
                            gap: 11px;
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

                        /* MAIN */
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

                        /* PAGES */
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

                        /* Cards */
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

                        /* Stats */
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

                        /* Buttons */
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

                        /* LEAVE PAGE */
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

                        /* PROFILE HERO */
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

                        /* MODAL */
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

                        /* Leave Form Modal */
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

                    <!-- SIDEBAR -->
                    <aside class="sidebar" id="sidebar">
                        <div class="s-brand">
                            <div class="s-brand-icon"><i class="bi bi-person-video3"></i></div>
                            <div class="s-brand-text">
                                <h6>EduManage</h6><small>Teacher Portal</small>
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
                            <div class="s-item"><a class="s-link active" onclick="showPage('dashboard',this)"><i
                                        class="bi bi-grid-fill"></i> Dashboard</a></div>
                            <div class="s-item"><a class="s-link" onclick="showPage('profile',this)"><i
                                        class="bi bi-person-fill"></i>
                                    My Profile</a></div>

                            <div class="s-lbl">Teaching</div>
                            <div class="s-item"><a class="s-link" onclick="showPage('myclasses',this)"><i
                                        class="bi bi-easel2-fill"></i>
                                    My Classes <span class="sbadge">4</span></a></div>
                            <div class="s-item"><a class="s-link" onclick="showPage('timetable',this)"><i
                                        class="bi bi-clock-fill"></i>
                                    My Timetable</a></div>
                            <div class="s-item"><a class="s-link" onclick="showPage('attendance',this)"><i
                                        class="bi bi-calendar-check-fill"></i> Mark Attendance</a></div>
                            <div class="s-item"><a class="s-link" onclick="showPage('assignments',this)"><i
                                        class="bi bi-clipboard2-check-fill"></i> Assignments <span
                                        class="sbadge red">5</span></a></div>
                            <div class="s-item"><a class="s-link" onclick="showPage('results',this)"><i
                                        class="bi bi-bar-chart-fill"></i> Results & Marks</a></div>

                            <div class="s-lbl">Personal</div>
                            <div class="s-item"><a class="s-link" onclick="showPage('leave',this)"><i
                                        class="bi bi-calendar2-x-fill"></i> Leave Application <span
                                        class="sbadge">1</span></a>
                            </div>
                            <div class="s-item"><a class="s-link" onclick="showPage('notices',this)"><i
                                        class="bi bi-bell-fill"></i>
                                    Notices <span class="sbadge">3</span></a></div>
                        </nav>

                        <div class="s-bottom">
                            <a href="/teacher_logout" class="s-out" style="text-decoration: none;"><i
                                    class="bi bi-box-arrow-left" style="font-size:16px"></i> Logout</a>
                        </div>
                    </aside>

                    <!-- MAIN -->
                    <div class="main">
                        <div class="topbar">
                            <button class="mob-toggle" onclick="toggleSidebar()"><i class="bi bi-list"></i></button>
                            <span class="tbar-title" id="page-title">Dashboard</span>
                            <div class="tbar-right">
                                <span class="tb-date" id="topbar-date">Monday, 2 Mar</span>
                                <div class="tb-srch"><i class="bi bi-search"></i><input type="text"
                                        placeholder="Search for student or class..." /></div>
                                <div class="tb-btn"><i class="bi bi-bell"></i><span class="notif-dot"></span></div>
                                <div><a href="/teacher_logout" class="tb-btn" style="text-decoration: none;">
                                        <i class="bi bi-box-arrow-right"></i>
                                    </a></div>
                            </div>
                        </div>

                        <!-- DASHBOARD -->
                        <div class="page active" id="page-dashboard">
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>Namaste, <%= tName %>! 👋</h4>
                                    <p>Aaj ke classes aur students ka overview</p>
                                </div>
                                <button class="btn-a"
                                    onclick="showPage('leave',document.querySelector('[onclick*=leave]'))"><i
                                        class="bi bi-calendar2-x-fill"></i> Leave Apply Karo</button>
                            </div>

                            <div class="row g-3 mb-4">
                                <div class="col-6 col-xl-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#dcfce7;color:#16a34a"><i
                                                class="bi bi-easel2-fill"></i>
                                        </div>
                                        <h3>4</h3>
                                        <p>My Classes</p><span class="tag tg">This Term</span>
                                    </div>
                                </div>
                                <div class="col-6 col-xl-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#dbeafe;color:#2563eb"><i
                                                class="bi bi-people-fill"></i>
                                        </div>
                                        <h3>118</h3>
                                        <p>Total Students</p><span class="tag tb">4 Classes</span>
                                    </div>
                                </div>
                                <div class="col-6 col-xl-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#fef3c7;color:#d97706"><i
                                                class="bi bi-clipboard2-check-fill"></i></div>
                                        <h3>5</h3>
                                        <p>Pending Reviews</p><span class="tag ty">Assignments</span>
                                    </div>
                                </div>
                                <div class="col-6 col-xl-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#ede9fe;color:#7c3aed"><i
                                                class="bi bi-graph-up-arrow"></i></div>
                                        <h3>82%</h3>
                                        <p>Class Average</p><span class="tag tp">↑ 3.1%</span>
                                    </div>
                                </div>
                            </div>

                            <div class="row g-3">
                                <!-- Today Schedule -->
                                <div class="col-12 col-lg-5">
                                    <div class="cbox">
                                        <div class="chead"><i class="bi bi-clock-fill" style="color:var(--accent)"></i>
                                            <h6>Aaj ka Schedule</h6><span class="ms-auto" id="dash-date-short"
                                                style="font-size:12px;color:var(--muted)">Monday, 2 Mar</span>
                                        </div>
                                        <div class="cbody">
                                            <div class="tslot done"><span class="t-time">8:00 – 9:00</span>
                                                <div class="t-info">
                                                    <p>Science — Class 9-A</p><small>Chapter 8: Motion</small>
                                                </div><span class="t-room">Lab-1</span>
                                            </div>
                                            <div class="tslot now"><span class="t-time">9:05 – 10:05</span>
                                                <div class="t-info">
                                                    <p>Science — Class 10-B ✦ Now</p><small>Chapter 12:
                                                        Electricity</small>
                                                </div><span class="t-room">R-204</span>
                                            </div>
                                            <div class="tslot"><span class="t-time">11:30 – 12:30</span>
                                                <div class="t-info">
                                                    <p>Science — Class 10-A</p><small>Chapter 12:
                                                        Electricity</small>
                                                </div><span class="t-room">Lab-2</span>
                                            </div>
                                            <div class="tslot"><span class="t-time">1:30 – 2:30</span>
                                                <div class="t-info">
                                                    <p>Science — Class 9-B</p><small>Chapter 8: Motion</small>
                                                </div><span class="t-room">R-208</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Class Performance -->
                                <div class="col-12 col-lg-7">
                                    <div class="cbox">
                                        <div class="chead"><i class="bi bi-bar-chart-fill"
                                                style="color:var(--purple)"></i>
                                            <h6>My Classes — Performance</h6>
                                        </div>
                                        <div class="cbody">
                                            <div class="mb-3">
                                                <div class="d-flex justify-content-between mb-1"><span
                                                        style="font-size:13px;font-weight:600">Class 9-A <span
                                                            style="color:var(--muted);font-weight:400">(30
                                                            Students)</span></span><span
                                                        style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:#16a34a">86%</span>
                                                </div>
                                                <div class="pb-wrap">
                                                    <div class="pb" style="width:86%;background:#22c55e"></div>
                                                </div>
                                            </div>
                                            <div class="mb-3">
                                                <div class="d-flex justify-content-between mb-1"><span
                                                        style="font-size:13px;font-weight:600">Class 9-B <span
                                                            style="color:var(--muted);font-weight:400">(28
                                                            Students)</span></span><span
                                                        style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:#2563eb">79%</span>
                                                </div>
                                                <div class="pb-wrap">
                                                    <div class="pb" style="width:79%;background:#3b82f6"></div>
                                                </div>
                                            </div>
                                            <div class="mb-3">
                                                <div class="d-flex justify-content-between mb-1"><span
                                                        style="font-size:13px;font-weight:600">Class 10-A <span
                                                            style="color:var(--muted);font-weight:400">(32
                                                            Students)</span></span><span
                                                        style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:#8b5cf6">82%</span>
                                                </div>
                                                <div class="pb-wrap">
                                                    <div class="pb" style="width:82%;background:#8b5cf6"></div>
                                                </div>
                                            </div>
                                            <div>
                                                <div class="d-flex justify-content-between mb-1"><span
                                                        style="font-size:13px;font-weight:600">Class 10-B <span
                                                            style="color:var(--muted);font-weight:400">(28
                                                            Students)</span></span><span
                                                        style="font-size:13px;font-weight:700;font-family:'JetBrains Mono',monospace;color:#f59e0b">84%</span>
                                                </div>
                                                <div class="pb-wrap">
                                                    <div class="pb" style="width:84%;background:#f59e0b"></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Pending Assignments -->
                                <div class="col-12 col-lg-6">
                                    <div class="cbox">
                                        <div class="chead"><i class="bi bi-clipboard2-check-fill"
                                                style="color:var(--yellow)"></i>
                                            <h6>Pending Assignment Reviews</h6><a
                                                onclick="showPage('assignments',document.querySelector('[onclick*=assignments]'))"
                                                class="ms-auto"
                                                style="font-size:12px;color:var(--accent);cursor:pointer;text-decoration:none;font-weight:600">Sabhi
                                                →</a>
                                        </div>
                                        <div class="cbody">
                                            <div class="arow">
                                                <div class="aico" style="background:#dcfce7;color:#16a34a"><i
                                                        class="bi bi-flask-fill"></i></div>
                                                <div class="ainfo">
                                                    <p>Lab Report — Acid-Base (9-A)</p><small>12 submissions
                                                        pending</small>
                                                </div><span class="tag tr">Urgent</span>
                                            </div>
                                            <div class="arow">
                                                <div class="aico" style="background:#dbeafe;color:#2563eb"><i
                                                        class="bi bi-lightning-fill"></i></div>
                                                <div class="ainfo">
                                                    <p>Electricity Worksheet (10-B)</p><small>8 submissions
                                                        pending</small>
                                                </div><span class="tag ty">Soon</span>
                                            </div>
                                            <div class="arow">
                                                <div class="aico" style="background:#ede9fe;color:#7c3aed"><i
                                                        class="bi bi-wind"></i>
                                                </div>
                                                <div class="ainfo">
                                                    <p>Motion Numericals (9-B)</p><small>5 submissions
                                                        pending</small>
                                                </div><span class="tag tg">Open</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Leave Quick View -->
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
                                                            12</div>
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
                                                            5</div>
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
                                                            1</div>
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

                        <!-- PROFILE -->
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
                                    <%= tSubject %> • Class 9 & 10
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

                                                <% if (hasProfessionalInfo) { %>
                                                    <div class="col-12 col-lg-5">
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
                                                                                    8</div>
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
                                                                                    4</div>
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
                                                                                    0</div>
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
                                                                                    5</div>
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
                        </div> <!-- FIX: page-profile closes here -->

                        <!-- MY CLASSES -->
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
                                            <p>4</p><small>Classes</small>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="mstat">
                                        <div class="mstat-ico" style="background:#dbeafe;color:#2563eb"><i
                                                class="bi bi-people-fill"></i></div>
                                        <div>
                                            <p>118</p><small>Students</small>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="mstat">
                                        <div class="mstat-ico" style="background:#fef3c7;color:#d97706"><i
                                                class="bi bi-graph-up-arrow"></i></div>
                                        <div>
                                            <p>82%</p><small>Avg Score</small>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="mstat">
                                        <div class="mstat-ico" style="background:#ede9fe;color:#7c3aed"><i
                                                class="bi bi-calendar-check-fill"></i></div>
                                        <div>
                                            <p>89%</p><small>Avg Attendance</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <div class="cbox p-4">
                                        <div class="d-flex align-items-center gap-3 mb-3">
                                            <div class="stat-ico"
                                                style="background:#dcfce7;color:#16a34a;width:46px;height:46px;border-radius:13px;display:flex;align-items:center;justify-content:center;font-size:20px">
                                                <i class="bi bi-easel2-fill"></i>
                                            </div>
                                            <div>
                                                <div style="font-weight:700;font-size:15px">Class 9-A</div>
                                                <div style="font-size:12px;color:var(--muted)">30 Students • Room
                                                    R-201
                                                </div>
                                            </div><span class="ms-auto tag tg">86%</span>
                                        </div>
                                        <div class="mb-2">
                                            <div class="d-flex justify-content-between mb-1"><span
                                                    style="font-size:12px;color:var(--muted)">Class
                                                    Average</span><span
                                                    style="font-size:12px;font-weight:700">86%</span>
                                            </div>
                                            <div class="pb-wrap">
                                                <div class="pb" style="width:86%;background:#22c55e"></div>
                                            </div>
                                        </div>
                                        <div class="d-flex justify-content-between"
                                            style="font-size:12px;color:var(--muted)">
                                            <span>Present Today: <b style="color:#16a34a">28/30</b></span><span>Low
                                                Attendance: <b style="color:var(--red)">2</b></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="cbox p-4">
                                        <div class="d-flex align-items-center gap-3 mb-3">
                                            <div class="stat-ico"
                                                style="background:#dbeafe;color:#2563eb;width:46px;height:46px;border-radius:13px;display:flex;align-items:center;justify-content:center;font-size:20px">
                                                <i class="bi bi-easel2-fill"></i>
                                            </div>
                                            <div>
                                                <div style="font-weight:700;font-size:15px">Class 9-B</div>
                                                <div style="font-size:12px;color:var(--muted)">28 Students • Room
                                                    R-208
                                                </div>
                                            </div><span class="ms-auto tag tb">79%</span>
                                        </div>
                                        <div class="mb-2">
                                            <div class="d-flex justify-content-between mb-1"><span
                                                    style="font-size:12px;color:var(--muted)">Class
                                                    Average</span><span
                                                    style="font-size:12px;font-weight:700">79%</span>
                                            </div>
                                            <div class="pb-wrap">
                                                <div class="pb" style="width:79%;background:#3b82f6"></div>
                                            </div>
                                        </div>
                                        <div class="d-flex justify-content-between"
                                            style="font-size:12px;color:var(--muted)">
                                            <span>Present Today: <b style="color:#16a34a">25/28</b></span><span>Low
                                                Attendance: <b style="color:var(--red)">3</b></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="cbox p-4">
                                        <div class="d-flex align-items-center gap-3 mb-3">
                                            <div class="stat-ico"
                                                style="background:#ede9fe;color:#7c3aed;width:46px;height:46px;border-radius:13px;display:flex;align-items:center;justify-content:center;font-size:20px">
                                                <i class="bi bi-easel2-fill"></i>
                                            </div>
                                            <div>
                                                <div style="font-weight:700;font-size:15px">Class 10-A</div>
                                                <div style="font-size:12px;color:var(--muted)">32 Students • Lab-2
                                                </div>
                                            </div><span class="ms-auto tag tp">82%</span>
                                        </div>
                                        <div class="mb-2">
                                            <div class="d-flex justify-content-between mb-1"><span
                                                    style="font-size:12px;color:var(--muted)">Class
                                                    Average</span><span
                                                    style="font-size:12px;font-weight:700">82%</span>
                                            </div>
                                            <div class="pb-wrap">
                                                <div class="pb" style="width:82%;background:#8b5cf6"></div>
                                            </div>
                                        </div>
                                        <div class="d-flex justify-content-between"
                                            style="font-size:12px;color:var(--muted)">
                                            <span>Present Today: <b style="color:#16a34a">30/32</b></span><span>Low
                                                Attendance: <b style="color:var(--red)">1</b></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="cbox p-4">
                                        <div class="d-flex align-items-center gap-3 mb-3">
                                            <div class="stat-ico"
                                                style="background:#fef3c7;color:#d97706;width:46px;height:46px;border-radius:13px;display:flex;align-items:center;justify-content:center;font-size:20px">
                                                <i class="bi bi-easel2-fill"></i>
                                            </div>
                                            <div>
                                                <div style="font-weight:700;font-size:15px">Class 10-B</div>
                                                <div style="font-size:12px;color:var(--muted)">28 Students • R-204
                                                </div>
                                            </div><span class="ms-auto tag ty">84%</span>
                                        </div>
                                        <div class="mb-2">
                                            <div class="d-flex justify-content-between mb-1"><span
                                                    style="font-size:12px;color:var(--muted)">Class
                                                    Average</span><span
                                                    style="font-size:12px;font-weight:700">84%</span>
                                            </div>
                                            <div class="pb-wrap">
                                                <div class="pb" style="width:84%;background:#f59e0b"></div>
                                            </div>
                                        </div>
                                        <div class="d-flex justify-content-between"
                                            style="font-size:12px;color:var(--muted)">
                                            <span>Present Today: <b style="color:#16a34a">26/28</b></span><span>Low
                                                Attendance: <b style="color:var(--red)">2</b></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- TIMETABLE -->
                        <div class="page" id="page-timetable">
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>My Timetable</h4>
                                    <p>Weekly teaching schedule</p>
                                </div>
                            </div>
                            <div class="cbox">
                                <div class="chead">
                                    <h6>Weekly Schedule — Priya Joshi (Science)</h6>
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
                                                </tr>
                                            </thead>
                                            <tbody style="font-size:13px">
                                                <tr>
                                                    <td style="font-family:'JetBrains Mono',monospace;font-size:12px">
                                                        8:00–9:00</td>
                                                    <td style="font-weight:600;color:#16a34a">9-A</td>
                                                    <td style="font-weight:600;color:var(--muted)">—</td>
                                                    <td style="font-weight:600;color:#2563eb">9-B</td>
                                                    <td style="font-weight:600;color:#16a34a">9-A</td>
                                                    <td style="font-weight:600;color:var(--muted)">—</td>
                                                </tr>
                                                <tr>
                                                    <td style="font-family:'JetBrains Mono',monospace;font-size:12px">
                                                        9:05–10:05</td>
                                                    <td style="font-weight:600;color:#f59e0b">10-B ✦</td>
                                                    <td style="font-weight:600;color:#8b5cf6">10-A</td>
                                                    <td style="font-weight:600;color:var(--muted)">—</td>
                                                    <td style="font-weight:600;color:#f59e0b">10-B</td>
                                                    <td style="font-weight:600;color:#8b5cf6">10-A</td>
                                                </tr>
                                                <tr>
                                                    <td style="font-family:'JetBrains Mono',monospace;font-size:12px">
                                                        11:30–12:30</td>
                                                    <td style="font-weight:600;color:#8b5cf6">10-A</td>
                                                    <td style="font-weight:600;color:#16a34a">9-A</td>
                                                    <td style="font-weight:600;color:#f59e0b">10-B</td>
                                                    <td style="font-weight:600;color:var(--muted)">—</td>
                                                    <td style="font-weight:600;color:#2563eb">9-B</td>
                                                </tr>
                                                <tr>
                                                    <td style="font-family:'JetBrains Mono',monospace;font-size:12px">
                                                        1:30–2:30</td>
                                                    <td style="font-weight:600;color:#2563eb">9-B</td>
                                                    <td style="font-weight:600;color:var(--muted)">—</td>
                                                    <td style="font-weight:600;color:#16a34a">9-A</td>
                                                    <td style="font-weight:600;color:#8b5cf6">10-A</td>
                                                    <td style="font-weight:600;color:#f59e0b">10-B</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                    <div class="d-flex gap-3 flex-wrap mt-3">
                                        <span style="font-size:12px;display:flex;align-items:center;gap:6px"><span
                                                style="width:12px;height:12px;background:#22c55e;border-radius:3px;display:inline-block"></span>Class
                                            9-A</span>
                                        <span style="font-size:12px;display:flex;align-items:center;gap:6px"><span
                                                style="width:12px;height:12px;background:#3b82f6;border-radius:3px;display:inline-block"></span>Class
                                            9-B</span>
                                        <span style="font-size:12px;display:flex;align-items:center;gap:6px"><span
                                                style="width:12px;height:12px;background:#8b5cf6;border-radius:3px;display:inline-block"></span>Class
                                            10-A</span>
                                        <span style="font-size:12px;display:flex;align-items:center;gap:6px"><span
                                                style="width:12px;height:12px;background:#f59e0b;border-radius:3px;display:inline-block"></span>Class
                                            10-B</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- MARK ATTENDANCE -->
                        <div class="page" id="page-attendance">
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>Mark Attendance</h4>
                                    <p>Class-wise attendance mark karo</p>
                                </div>
                                <button class="btn-a"><i class="bi bi-floppy-fill"></i> Save Attendance</button>
                            </div>
                            <div class="cbox mb-3">
                                <div class="chead">
                                    <h6>Select Class</h6>
                                </div>
                                <div class="cbody">
                                    <div class="row g-2">
                                        <div class="col-6 col-md-3">
                                            <div class="ltype sel" onclick="selectClass(this,'9-A')"><i
                                                    class="bi bi-easel2-fill" style="color:#16a34a"></i><span>Class
                                                    9-A</span><small>30 Students</small></div>
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <div class="ltype" onclick="selectClass(this,'9-B')"><i
                                                    class="bi bi-easel2-fill" style="color:#2563eb"></i><span>Class
                                                    9-B</span><small>28 Students</small></div>
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <div class="ltype" onclick="selectClass(this,'10-A')"><i
                                                    class="bi bi-easel2-fill" style="color:#8b5cf6"></i><span>Class
                                                    10-A</span><small>32 Students</small></div>
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <div class="ltype" onclick="selectClass(this,'10-B')"><i
                                                    class="bi bi-easel2-fill" style="color:#f59e0b"></i><span>Class
                                                    10-B</span><small>28 Students</small></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="cbox">
                                <div class="chead">
                                    <h6 id="att-class-title">Class 9-A — Attendance (<span id="att-date-val">2 March
                                            2026</span>)</h6>
                                    <div class="ms-auto d-flex gap-2"><button class="btn-o"
                                            style="font-size:12px;padding:6px 12px" onclick="markAll('P')">Sabhi
                                            Present</button><button class="btn-o"
                                            style="font-size:12px;padding:6px 12px" onclick="markAll('A')">Sabhi
                                            Absent</button></div>
                                </div>
                                <div class="table-responsive">
                                    <table class="table tbl mb-0">
                                        <thead>
                                            <tr>
                                                <th>#</th>
                                                <th>Student Name</th>
                                                <th>Roll No.</th>
                                                <th>Present</th>
                                                <th>Absent</th>
                                                <th>Leave</th>
                                            </tr>
                                        </thead>
                                        <tbody id="att-tbody">
                                            <tr>
                                                <td>1</td>
                                                <td>
                                                    <div class="d-flex align-items-center gap-2">
                                                        <div class="avsm" style="background:#dcfce7;color:#16a34a">
                                                            AK
                                                        </div>
                                                        Arjun Kumar
                                                    </div>
                                                </td>
                                                <td style="font-family:'JetBrains Mono',monospace">#42</td>
                                                <td><input type="radio" name="s1" value="P" checked
                                                        class="form-check-input" />
                                                </td>
                                                <td><input type="radio" name="s1" value="A" class="form-check-input" />
                                                </td>
                                                <td><input type="radio" name="s1" value="L" class="form-check-input" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>2</td>
                                                <td>
                                                    <div class="d-flex align-items-center gap-2">
                                                        <div class="avsm" style="background:#dbeafe;color:#2563eb">
                                                            NK
                                                        </div>
                                                        Neha Kapoor
                                                    </div>
                                                </td>
                                                <td style="font-family:'JetBrains Mono',monospace">#22</td>
                                                <td><input type="radio" name="s2" value="P" checked
                                                        class="form-check-input" />
                                                </td>
                                                <td><input type="radio" name="s2" value="A" class="form-check-input" />
                                                </td>
                                                <td><input type="radio" name="s2" value="L" class="form-check-input" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>3</td>
                                                <td>
                                                    <div class="d-flex align-items-center gap-2">
                                                        <div class="avsm" style="background:#fef3c7;color:#d97706">
                                                            SM
                                                        </div>
                                                        Suresh Mehta
                                                    </div>
                                                </td>
                                                <td style="font-family:'JetBrains Mono',monospace">#31</td>
                                                <td><input type="radio" name="s3" value="P" class="form-check-input" />
                                                </td>
                                                <td><input type="radio" name="s3" value="A" checked
                                                        class="form-check-input" />
                                                </td>
                                                <td><input type="radio" name="s3" value="L" class="form-check-input" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>4</td>
                                                <td>
                                                    <div class="d-flex align-items-center gap-2">
                                                        <div class="avsm" style="background:#ede9fe;color:#7c3aed">
                                                            RS
                                                        </div>
                                                        Rahul Singh
                                                    </div>
                                                </td>
                                                <td style="font-family:'JetBrains Mono',monospace">#18</td>
                                                <td><input type="radio" name="s4" value="P" checked
                                                        class="form-check-input" />
                                                </td>
                                                <td><input type="radio" name="s4" value="A" class="form-check-input" />
                                                </td>
                                                <td><input type="radio" name="s4" value="L" class="form-check-input" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>5</td>
                                                <td>
                                                    <div class="d-flex align-items-center gap-2">
                                                        <div class="avsm" style="background:#fee2e2;color:#dc2626">
                                                            PS
                                                        </div>
                                                        Pooja Sharma
                                                    </div>
                                                </td>
                                                <td style="font-family:'JetBrains Mono',monospace">#07</td>
                                                <td><input type="radio" name="s5" value="P" class="form-check-input" />
                                                </td>
                                                <td><input type="radio" name="s5" value="A" class="form-check-input" />
                                                </td>
                                                <td><input type="radio" name="s5" value="L" checked
                                                        class="form-check-input" />
                                                </td>
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
                                    <p>Assignments create karo aur submissions review karo</p>
                                </div>
                                <button class="btn-a"><i class="bi bi-plus-lg"></i> Naya Assignment Do</button>
                            </div>
                            <div class="cbox mb-3">
                                <div class="chead"><i class="bi bi-hourglass-split" style="color:var(--red)"></i>
                                    <h6>Review Pending (5)</h6>
                                </div>
                                <div class="cbody">
                                    <div class="arow">
                                        <div class="aico" style="background:#dcfce7;color:#16a34a"><i
                                                class="bi bi-flask-fill"></i>
                                        </div>
                                        <div class="ainfo">
                                            <p>Lab Report — Acid-Base Reaction</p><small>Class 9-A • 12 submissions
                                                •
                                                Due: 3
                                                Mar
                                                2026</small>
                                        </div><span class="tag tr">Urgent</span>
                                    </div>
                                    <div class="arow">
                                        <div class="aico" style="background:#dbeafe;color:#2563eb"><i
                                                class="bi bi-lightning-fill"></i>
                                        </div>
                                        <div class="ainfo">
                                            <p>Electricity Worksheet</p><small>Class 10-B • 8 submissions • Due: 4
                                                Mar
                                                2026</small>
                                        </div><span class="tag ty">Soon</span>
                                    </div>
                                    <div class="arow">
                                        <div class="aico" style="background:#ede9fe;color:#7c3aed"><i
                                                class="bi bi-wind"></i>
                                        </div>
                                        <div class="ainfo">
                                            <p>Motion Numericals — Chapter 8</p><small>Class 9-B • 5 submissions •
                                                Due:
                                                6
                                                Mar
                                                2026</small>
                                        </div><span class="tag tg">Open</span>
                                    </div>
                                    <div class="arow">
                                        <div class="aico" style="background:#fef3c7;color:#d97706"><i
                                                class="bi bi-atom"></i>
                                        </div>
                                        <div class="ainfo">
                                            <p>Chemical Reactions Lab Summary</p><small>Class 10-A • 3 submissions •
                                                Due: 7
                                                Mar
                                                2026</small>
                                        </div><span class="tag tg">Open</span>
                                    </div>
                                    <div class="arow">
                                        <div class="aico" style="background:#fee2e2;color:#dc2626"><i
                                                class="bi bi-soundwave"></i></div>
                                        <div class="ainfo">
                                            <p>Sound Waves Diagram Activity</p><small>Class 9-A • 1 submission •
                                                Due: 10
                                                Mar
                                                2026</small>
                                        </div><span class="tag tg">Open</span>
                                    </div>
                                </div>
                            </div>
                            <div class="cbox">
                                <div class="chead"><i class="bi bi-check-circle-fill" style="color:var(--green)"></i>
                                    <h6>Completed (8)</h6>
                                </div>
                                <div class="cbody">
                                    <div class="arow">
                                        <div class="aico" style="background:#dcfce7;color:#16a34a"><i
                                                class="bi bi-check2-circle"></i>
                                        </div>
                                        <div class="ainfo">
                                            <p>Chapter 5 — Force & Pressure</p><small>Class 9-A • Graded 20 Feb •
                                                Avg:
                                                78%</small>
                                        </div><span class="tag tg">Graded ✓</span>
                                    </div>
                                    <div class="arow">
                                        <div class="aico" style="background:#dcfce7;color:#16a34a"><i
                                                class="bi bi-check2-circle"></i>
                                        </div>
                                        <div class="ainfo">
                                            <p>Magnetic Effects Worksheet</p><small>Class 10-B • Graded 18 Feb •
                                                Avg:
                                                82%</small>
                                        </div><span class="tag tg">Graded ✓</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- RESULTS & MARKS -->
                        <div class="page" id="page-results">
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>Results & Marks</h4>
                                    <p>Apni classes ke exam results enter karo</p>
                                </div>
                                <button class="btn-a"><i class="bi bi-upload"></i> Marks Upload Karo</button>
                            </div>
                            <div class="row g-3 mb-3">
                                <div class="col-md-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#dcfce7;color:#16a34a"><i
                                                class="bi bi-trophy-fill"></i>
                                        </div>
                                        <h3>82%</h3>
                                        <p>Overall Average</p><span class="tag tg">All Classes</span>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#dbeafe;color:#2563eb"><i
                                                class="bi bi-star-fill"></i>
                                        </div>
                                        <h3>18</h3>
                                        <p>Distinctions</p><span class="tag tb">80%+</span>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#fee2e2;color:#dc2626"><i
                                                class="bi bi-x-circle-fill"></i></div>
                                        <h3>3</h3>
                                        <p>Failed</p><span class="tag tr">Needs Help</span>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stat">
                                        <div class="stat-ico" style="background:#ede9fe;color:#7c3aed"><i
                                                class="bi bi-people-fill"></i>
                                        </div>
                                        <h3>118</h3>
                                        <p>Total Students</p>
                                    </div>
                                </div>
                            </div>
                            <div class="cbox">
                                <div class="chead">
                                    <h6>Half-Yearly Results — Science</h6>
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
                                            <tr>
                                                <td style="font-weight:700">Class 9-A</td>
                                                <td>30</td>
                                                <td>30</td>
                                                <td style="color:#16a34a;font-weight:700">29</td>
                                                <td style="color:var(--red);font-weight:700">1</td>
                                                <td style="font-family:'JetBrains Mono',monospace;font-weight:700">
                                                    86%
                                                </td>
                                                <td><span class="tag tg">96%</span></td>
                                            </tr>
                                            <tr>
                                                <td style="font-weight:700">Class 9-B</td>
                                                <td>28</td>
                                                <td>28</td>
                                                <td style="color:#16a34a;font-weight:700">26</td>
                                                <td style="color:var(--red);font-weight:700">2</td>
                                                <td style="font-family:'JetBrains Mono',monospace;font-weight:700">
                                                    79%
                                                </td>
                                                <td><span class="tag tb">91%</span></td>
                                            </tr>
                                            <tr>
                                                <td style="font-weight:700">Class 10-A</td>
                                                <td>32</td>
                                                <td>32</td>
                                                <td style="color:#16a34a;font-weight:700">32</td>
                                                <td style="color:var(--red);font-weight:700">0</td>
                                                <td style="font-family:'JetBrains Mono',monospace;font-weight:700">
                                                    82%
                                                </td>
                                                <td><span class="tag tp">94%</span></td>
                                            </tr>
                                            <tr>
                                                <td style="font-weight:700">Class 10-B</td>
                                                <td>28</td>
                                                <td>28</td>
                                                <td style="color:#16a34a;font-weight:700">28</td>
                                                <td style="color:var(--red);font-weight:700">0</td>
                                                <td style="font-family:'JetBrains Mono',monospace;font-weight:700">
                                                    84%
                                                </td>
                                                <td><span class="tag ty">93%</span></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                        <!-- ═══ LEAVE APPLICATION ═══ -->
                        <div class="page" id="page-leave">
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>Leave Application</h4>
                                    <p>Leave apply karo aur history dekho</p>
                                </div>
                                <button class="btn-a" onclick="openLeaveModal()"><i class="bi bi-plus-lg"></i> Naya
                                    Leave
                                    Apply
                                    Karo</button>
                            </div>

                            <!-- Leave Quota Hero -->
                            <div class="leave-hero mb-4">
                                <div
                                    style="color:rgba(255,255,255,.45);font-size:11px;text-transform:uppercase;letter-spacing:1px;margin-bottom:14px;font-weight:600">
                                    Leave Balance — Session 2025-26</div>
                                <div class="lq-grid">
                                    <div class="lq-item avail">
                                        <h3>12</h3>
                                        <p>Available</p>
                                    </div>
                                    <div class="lq-item used">
                                        <h3>5</h3>
                                        <p>Used</p>
                                    </div>
                                    <div class="lq-item pending">
                                        <h3>1</h3>
                                        <p>Pending</p>
                                    </div>
                                    <div class="lq-item total">
                                        <h3>18</h3>
                                        <p>Total Allotted</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Leave Types -->
                            <div class="cbox mb-4">
                                <div class="chead"><i class="bi bi-list-check" style="color:var(--accent)"></i>
                                    <h6>Leave Types & Balance</h6>
                                </div>
                                <div class="cbody">
                                    <div class="row g-3">
                                        <div class="col-6 col-md-3">
                                            <div
                                                style="border:1.5px solid var(--border);border-radius:14px;padding:18px;text-align:center">
                                                <i class="bi bi-sun-fill"
                                                    style="font-size:28px;color:#d97706;display:block;margin-bottom:10px"></i>
                                                <div
                                                    style="font-weight:800;font-size:22px;font-family:'JetBrains Mono',monospace;color:#d97706">
                                                    8</div>
                                                <div style="font-weight:700;font-size:13px;margin:2px 0">Casual
                                                    Leave
                                                </div>
                                                <div style="font-size:11px;color:var(--muted)">Used: 2 | Total: 10
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <div
                                                style="border:1.5px solid var(--border);border-radius:14px;padding:18px;text-align:center">
                                                <i class="bi bi-hospital-fill"
                                                    style="font-size:28px;color:#2563eb;display:block;margin-bottom:10px"></i>
                                                <div
                                                    style="font-weight:800;font-size:22px;font-family:'JetBrains Mono',monospace;color:#2563eb">
                                                    4</div>
                                                <div style="font-weight:700;font-size:13px;margin:2px 0">Medical
                                                    Leave
                                                </div>
                                                <div style="font-size:11px;color:var(--muted)">Used: 2 | Total: 6
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <div
                                                style="border:1.5px solid var(--border);border-radius:14px;padding:18px;text-align:center">
                                                <i class="bi bi-award-fill"
                                                    style="font-size:28px;color:#7c3aed;display:block;margin-bottom:10px"></i>
                                                <div
                                                    style="font-weight:800;font-size:22px;font-family:'JetBrains Mono',monospace;color:#7c3aed">
                                                    0</div>
                                                <div style="font-weight:700;font-size:13px;margin:2px 0">Earned
                                                    Leave
                                                </div>
                                                <div style="font-size:11px;color:var(--muted)">Used: 1 | Total: 2
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <div
                                                style="border:1.5px solid var(--border);border-radius:14px;padding:18px;text-align:center">
                                                <i class="bi bi-house-heart-fill"
                                                    style="font-size:28px;color:#ec4899;display:block;margin-bottom:10px"></i>
                                                <div
                                                    style="font-weight:800;font-size:22px;font-family:'JetBrains Mono',monospace;color:#ec4899">
                                                    0</div>
                                                <div style="font-weight:700;font-size:13px;margin:2px 0">Special
                                                    Leave
                                                </div>
                                                <div style="font-size:11px;color:var(--muted)">Used: 0 | Total: 0
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Leave History -->
                            <div class="cbox">
                                <div class="chead"><i class="bi bi-clock-history" style="color:var(--muted)"></i>
                                    <h6>Leave History</h6>
                                </div>
                                <div class="cbody">

                                    <!-- Pending -->
                                    <div class="lhist">
                                        <div class="lhist-ico" style="background:#fef3c7;color:#d97706"><i
                                                class="bi bi-clock-fill"></i>
                                        </div>
                                        <div class="lhist-info">
                                            <p>Casual Leave — Personal Work</p>
                                            <small>5 March 2026 (1 day) • Applied: 1 Mar 2026</small>
                                        </div>
                                        <div class="ldays">1 Day</div>
                                        <span class="tag ty ms-3">Pending</span>
                                    </div>

                                    <!-- Approved -->
                                    <div class="lhist">
                                        <div class="lhist-ico" style="background:#dcfce7;color:#16a34a"><i
                                                class="bi bi-check-circle-fill"></i></div>
                                        <div class="lhist-info">
                                            <p>Medical Leave — Doctor Visit</p>
                                            <small>14–15 Jan 2026 (2 days) • Approved by: Principal</small>
                                        </div>
                                        <div class="ldays">2 Days</div>
                                        <span class="tag tg ms-3">Approved</span>
                                    </div>

                                    <div class="lhist">
                                        <div class="lhist-ico" style="background:#dcfce7;color:#16a34a"><i
                                                class="bi bi-check-circle-fill"></i></div>
                                        <div class="lhist-info">
                                            <p>Casual Leave — Family Function</p>
                                            <small>20 Dec 2025 (1 day) • Approved by: Principal</small>
                                        </div>
                                        <div class="ldays">1 Day</div>
                                        <span class="tag tg ms-3">Approved</span>
                                    </div>

                                    <div class="lhist">
                                        <div class="lhist-ico" style="background:#dcfce7;color:#16a34a"><i
                                                class="bi bi-check-circle-fill"></i></div>
                                        <div class="lhist-info">
                                            <p>Casual Leave — Personal</p>
                                            <small>10 Nov 2025 (1 day) • Approved by: Vice Principal</small>
                                        </div>
                                        <div class="ldays">1 Day</div>
                                        <span class="tag tg ms-3">Approved</span>
                                    </div>

                                    <!-- Rejected -->
                                    <div class="lhist">
                                        <div class="lhist-ico" style="background:#fee2e2;color:#dc2626"><i
                                                class="bi bi-x-circle-fill"></i></div>
                                        <div class="lhist-info">
                                            <p>Earned Leave — Vacation</p>
                                            <small>15–17 Oct 2025 (3 days) • Rejected: Exam week conflict</small>
                                        </div>
                                        <div class="ldays">3 Days</div>
                                        <span class="tag tr ms-3">Rejected</span>
                                    </div>

                                </div>
                            </div>
                        </div>

                        <!-- NOTICES -->
                        <div class="page" id="page-notices">
                            <div class="pg-header">
                                <div class="pg-header-left">
                                    <h4>Notices</h4>
                                    <p>School aur admin ki sabhi notifications</p>
                                </div>
                            </div>
                            <div class="cbox">
                                <div class="chead"><i class="bi bi-megaphone-fill" style="color:var(--yellow)"></i>
                                    <h6>Active Notices (3)</h6>
                                </div>
                                <div class="cbody">
                                    <div
                                        style="border-left:4px solid var(--accent);background:#f0fdf4;border-radius:12px;padding:14px;margin-bottom:10px">
                                        <div class="d-flex justify-content-between align-items-start mb-1">
                                            <h6 style="font-size:14px;font-weight:700;margin:0">Annual Sports Day —
                                                10
                                                March
                                                2026</h6>
                                            <span
                                                style="font-size:11px;color:var(--muted);font-family:'JetBrains Mono',monospace">28
                                                Feb 2026</span>
                                        </div>
                                        <p style="font-size:13px;color:var(--muted);margin:0">Sabhi teachers ko
                                            sports
                                            ground pe 7:30 AM
                                            tak report karna hai. Class duties assigned kar di gayi hain.</p>
                                        <span class="tag tg mt-2 d-inline-block">All Staff</span>
                                    </div>
                                    <div
                                        style="border-left:4px solid var(--yellow);background:#fffbeb;border-radius:12px;padding:14px;margin-bottom:10px">
                                        <div class="d-flex justify-content-between align-items-start mb-1">
                                            <h6 style="font-size:14px;font-weight:700;margin:0">Half-Yearly Result
                                                Submission Deadline
                                            </h6>
                                            <span
                                                style="font-size:11px;color:var(--muted);font-family:'JetBrains Mono',monospace">25
                                                Feb 2026</span>
                                        </div>
                                        <p style="font-size:13px;color:var(--muted);margin:0">Sabhi teachers apne
                                            subject ke
                                            marks 10
                                            March tak portal pe upload kar dein.</p>
                                        <span class="tag ty mt-2 d-inline-block">Teaching Staff</span>
                                    </div>
                                    <div
                                        style="border-left:4px solid var(--red);background:#fff5f5;border-radius:12px;padding:14px">
                                        <div class="d-flex justify-content-between align-items-start mb-1">
                                            <h6 style="font-size:14px;font-weight:700;margin:0">Staff Meeting — 7
                                                March
                                                2026
                                            </h6>
                                            <span
                                                style="font-size:11px;color:var(--muted);font-family:'JetBrains Mono',monospace">22
                                                Feb 2026</span>
                                        </div>
                                        <p style="font-size:13px;color:var(--muted);margin:0">Monthly staff meeting
                                            Friday 7
                                            March ko
                                            3:30 PM pe Conference Room mein hogi. Attendance mandatory hai.</p>
                                        <span class="tag tr mt-2 d-inline-block">Mandatory</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div><!-- end main -->

                    <!-- PROFILE EDIT MODAL -->
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

                    <!-- LEAVE APPLY MODAL -->
                    <div class="lback" id="leaveModal" onclick="closeLeaveOutside(event)">
                        <div class="emodal">
                            <div class="ehead">
                                <h5><i class="bi bi-calendar2-x-fill me-2" style="color:var(--red)"></i>Leave
                                    Application
                                </h5>
                                <button class="eclose" onclick="closeLeaveModal()">✕</button>
                            </div>
                            <div class="ebody">
                                <div class="row g-3">
                                    <div class="col-12">
                                        <label class="form-label">Leave Ka Type</label>
                                        <div class="row g-2">
                                            <div class="col-6 col-md-3">
                                                <div class="ltype sel" onclick="selectLeaveType(this)"
                                                    style="padding:12px">
                                                    <i class="bi bi-sun-fill" style="color:#d97706"></i><span
                                                        style="font-size:12px">Casual</span>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3">
                                                <div class="ltype" onclick="selectLeaveType(this)" style="padding:12px">
                                                    <i class="bi bi-hospital-fill" style="color:#2563eb"></i><span
                                                        style="font-size:12px">Medical</span>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3">
                                                <div class="ltype" onclick="selectLeaveType(this)" style="padding:12px">
                                                    <i class="bi bi-award-fill" style="color:#7c3aed"></i><span
                                                        style="font-size:12px">Earned</span>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3">
                                                <div class="ltype" onclick="selectLeaveType(this)" style="padding:12px">
                                                    <i class="bi bi-house-heart-fill" style="color:#ec4899"></i><span
                                                        style="font-size:12px">Special</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6"><label class="form-label">Start Date</label><input
                                            class="form-control" type="date" /></div>
                                    <div class="col-6"><label class="form-label">End Date</label><input
                                            class="form-control" type="date" /></div>
                                    <div class="col-12"><label class="form-label">Leave Ka Karan
                                            (Reason)</label><textarea class="form-control" rows="3"
                                            placeholder="Leave lene ka reason likhein..."></textarea>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label">Supporting Document (Optional)</label>
                                        <div style="border:1.5px dashed var(--border);border-radius:10px;padding:20px;text-align:center;cursor:pointer"
                                            onclick="document.getElementById('leave-doc-input').click()">
                                            <i class="bi bi-cloud-upload"
                                                style="font-size:24px;color:var(--muted);display:block;margin-bottom:8px"></i>
                                            <div style="font-size:13px;font-weight:600">Medical certificate ya
                                                document
                                                upload karo
                                            </div>
                                            <div style="font-size:12px;color:var(--muted)">PDF, JPG, PNG (Max 5MB)
                                            </div>
                                        </div>
                                        <input type="file" id="leave-doc-input" style="display:none" />
                                    </div>
                                    <div class="col-12 d-flex gap-2 pt-1">
                                        <button class="save-btn" onclick="submitLeave()"><i
                                                class="bi bi-send-fill me-1"></i>Leave
                                            Submit Karo</button>
                                        <button onclick="closeLeaveModal()"
                                            style="background:var(--bg);border:1.5px solid var(--border);border-radius:11px;padding:12px 20px;font-size:14px;font-weight:600;cursor:pointer;font-family:inherit">Cancel</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <script
                        src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
                    <script>
                        const pageTitles = { dashboard: 'Dashboard', profile: 'My Profile', myclasses: 'My Classes', timetable: 'My Timetable', attendance: 'Mark Attendance', assignments: 'Assignments', results: 'Results & Marks', leave: 'Leave Application', notices: 'Notices' };

                        function showPage(n, el) {
                            document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
                            document.getElementById('page-' + n).classList.add('active');
                            document.querySelectorAll('.s-link').forEach(l => l.classList.remove('active'));
                            if (el) el.classList.add('active');
                            document.getElementById('page-title').textContent = pageTitles[n] || n;
                            document.getElementById('sidebar').classList.remove('open');
                        }

                        function toggleSidebar() { document.getElementById('sidebar').classList.toggle('open') }

                        function openEditModal() { document.getElementById('editModal').classList.add('show'); document.body.style.overflow = 'hidden' }
                        function closeEditModal() { document.getElementById('editModal').classList.remove('show'); document.body.style.overflow = '' }
                        function closeEditOutside(e) { if (e.target === document.getElementById('editModal')) closeEditModal() }

                        function previewImage(input) {
                            if (input.files && input.files[0]) {
                                const reader = new FileReader();
                                reader.onload = function (e) {
                                    document.getElementById('modal-photo-preview').src = e.target.result;
                                }
                                reader.readAsDataURL(input.files[0]);
                            }
                        }

                        function openLeaveModal() { document.getElementById('leaveModal').classList.add('show'); document.body.style.overflow = 'hidden' }
                        function closeLeaveModal() { document.getElementById('leaveModal').classList.remove('show'); document.body.style.overflow = '' }
                        function closeLeaveOutside(e) { if (e.target === document.getElementById('leaveModal')) closeLeaveModal() }

                        function handleAvatarChange(input) {
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


                        function submitLeave() {
                            closeLeaveModal();
                            showToast('Leave application submit ho gayi! Admin review karega. ✓');
                        }

                        function selectClass(el, name) {
                            document.querySelectorAll('#page-attendance .ltype').forEach(e => e.classList.remove('sel'));
                            el.classList.add('sel');
                            const dateStr = new Date().toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
                            document.getElementById('att-class-title').innerHTML = 'Class ' + name + ' — Attendance (<span id="att-date-val">' + dateStr + '</span>)';
                        }

                        function selectLeaveType(el) {
                            document.querySelectorAll('#leaveModal .ltype').forEach(e => e.classList.remove('sel'));
                            el.classList.add('sel');
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