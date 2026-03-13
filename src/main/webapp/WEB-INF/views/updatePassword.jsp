<jsp:include page="bootstraplink.jsp" />

<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Reset Password</title>

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    body {
      background-color: #f5f5f5;
      background-image: url('/images/forgetpasswordimg.jpg');
      background-size: cover;
      background-position: center;
      background-attachment: fixed;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      position: relative;
    }

    body::before {
      content: '';
      position: fixed;
      inset: 0;
      background: linear-gradient(135deg, rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.4));
      z-index: 0;
      pointer-events: none;
    }

    .container {
      width: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      position: relative;
      z-index: 1;
    }

    .reset-card {
      max-width: 420px;
      width: 100%;
      border-radius: 15px;
      box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
      border-left: 5px solid #0d6efd;
      /* BLUE */
    }

    /* Text Blue */
    .text-primary {
      color: #0d6efd !important;
    }

    /* Button Blue */
    .btn-primary {
      background-color: #0d6efd !important;
      border-color: #0d6efd !important;
    }

    .btn-primary:hover {
      background-color: #0b5ed7 !important;
      border-color: #0b5ed7 !important;
    }

    .text-primary.fw-bold {
      color: #0d6efd !important;
    }

    /* Alerts */
    .alert-success {
      background-color: #e7f1ff;
      color: #084298;
      border: 1px solid #b6d4fe;
      border-radius: 8px;
      padding: 12px;
      margin-bottom: 15px;
    }

    .alert-danger {
      background-color: #f8d7da;
      color: #842029;
      border: 1px solid #f5c2c7;
      border-radius: 8px;
      padding: 12px;
      margin-bottom: 15px;
    }
  </style>

</head>

<body>

  <div class="container">
    <div class="card reset-card p-4">

      <h3 class="text-center text-primary mb-2">Reset Password</h3>
      <p class="text-center text-muted mb-4">
        Enter your details to reset your password
      </p>

      <form action="/update_pass" method="post">

        <!-- Name -->
        <div class="mb-3">
          <label class="form-label">Name</label>
          <input type="text" class="form-control" placeholder="Enter your name" name="name" required>
        </div>

        <!-- New Password -->
        <div class="mb-3">
          <label class="form-label">New Password</label>
          <input type="password" class="form-control" placeholder="Enter new password" name="password" required>
        </div>

        <!-- Confirm Password -->
        <div class="mb-3">
          <label class="form-label">Confirm Password</label>
          <input type="password" class="form-control" placeholder="Confirm new password" name="confirm_password"
            required>
        </div>

        <button type="submit" class="btn btn-primary w-100">
          Update Password
        </button>

      </form>

      <p class="text-center mt-3 mb-0">
        Back to
        <a href="/signin" class="text-primary fw-bold">Login</a>
      </p>

    </div>
  </div>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    window.addEventListener('load', function () {
      var msg = "${msg}";
      var error = "${error}";

      console.log('msg:', msg);
      console.log('error:', error);

      if (msg && msg.length > 0 && msg.indexOf('$') === -1) {
        const alertDiv = document.createElement('div');
        alertDiv.className = 'alert alert-success';
        alertDiv.textContent = msg;

        const card = document.querySelector('.reset-card');
        if (card) {
          card.insertBefore(alertDiv, card.firstChild);
        }
      }
      else if (error && error.length > 0 && error.indexOf('$') === -1) {
        const alertDiv = document.createElement('div');
        alertDiv.className = 'alert alert-danger';
        alertDiv.textContent = error;

        const card = document.querySelector('.reset-card');
        if (card) {
          card.insertBefore(alertDiv, card.firstChild);
        }
      }
    });
  </script>

</body>

</html>