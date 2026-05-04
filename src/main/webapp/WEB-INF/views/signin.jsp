<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);

  String sessRole = (String) session.getAttribute("role");
  if (session.getAttribute("user_id") != null && sessRole != null) {
      if ("admin".equalsIgnoreCase(sessRole)) {
          response.sendRedirect("/adashboard");
      } else if ("faculty".equalsIgnoreCase(sessRole)) {
          response.sendRedirect("/tdashboard");
      } else if ("student".equalsIgnoreCase(sessRole)) {
          response.sendRedirect("/sdashboard");
      }
      return;
  }
%>
<jsp:include page="bootstraplink.jsp" />

<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Sign In</title>

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    html,
    body {
      height: 100%;
      margin: 0;
    }

    body {
      position: relative;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background-color: #f8f9fa;
    }

    body::before {
      content: "";
      position: fixed;
      inset: 0;
      background-image: url('${pageContext.request.contextPath}/images/userimg.jpg');
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
      filter: blur(4px) saturate(0.95);
      transform: scale(1.03);
      z-index: -1;
    }

    .signin-card {
      border-radius: 12px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      max-width: 420px;
      width: 100%;
      background: rgba(255, 255, 255, 0.92);
    }

    .custom-alert {
      padding: .75rem 1rem;
      border-radius: .375rem;
      margin-bottom: 1rem;
      font-weight: 500;
    }

    .custom-alert.error {
      background-color: #f8d7da;
      color: #842029;
      border: 1px solid #f1c0c6;
    }
  </style>
</head>

<body>

  <div class="container">
    <div class="card signin-card p-4 mx-auto">
      <h3 class="text-center mb-3 text-primary">Login</h3>

      <form action="/check_login" method="post">
        <% if (request.getAttribute("error") !=null) { %>
          <div class="custom-alert error">
            <%= request.getAttribute("error") %>
          </div>
          <% } %>

            <div class="mb-3">
              <label class="form-label">User Name</label>
              <input type="text" class="form-control" placeholder="Enter name" name="name" required>
            </div>

            <div class="mb-3">
              <label class="form-label">Password</label>
              <input type="password" class="form-control" placeholder="Enter password" name="password" required>
            </div>

            <div class="text-center mb-3">
              <a href="/updatePassword" class="text-primary fw-semibold">
                Forgot password?
              </a>
            </div>

            <button type="submit" class="btn btn-primary w-100">Login</button>
      </form>

      <p class="text-center mt-3 mb-0">
        Don't have an account?
        <a href="/signup" class="text-primary fw-bold">Register</a>
      </p>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>