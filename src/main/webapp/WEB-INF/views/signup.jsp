<jsp:include page="bootstraplink.jsp" />


<!doctype html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Sign Up</title>

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    /* Page background: blurred AVIF image behind content */
    html,
    body {
      height: 100%;
      margin: 0;
    }

    body {
      position: relative;
      min-height: 100vh;
      background-color: #fff;
      /* fallback */
    }

    body::before {
      content: "";
      position: fixed;
      inset: 0;
      background-image: url('${pageContext.request.contextPath}/images/bookimg.jpg');
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
      filter: blur(4px) saturate(0.95);
      transform: scale(1.03);
      z-index: -1;
      will-change: transform;
    }

    .signup-card {
      border-radius: 15px;
      max-height: calc(90vh - 40px);
      overflow-y: auto;
      position: relative;
      -ms-overflow-style: none;
      /* IE and Edge */
      scrollbar-width: none;
      /* Firefox */
    }

    /* WebKit: prepare scrollbar and fade-in thumb on hover */
    .signup-card::-webkit-scrollbar {
      width: 10px;
    }

    .signup-card::-webkit-scrollbar-track {
      background: transparent;
      border-radius: 10px;
    }

    .signup-card::-webkit-scrollbar-thumb {
      background: rgba(0, 0, 0, 0);
      border-radius: 10px;
      opacity: 0;
      transition: background-color .25s ease, opacity .25s ease;
    }

    /* Show and style scrollbar when explicit 'show-scroll' is present (or on scroll) */
    .signup-card.show-scroll {
      scrollbar-width: thin;
      /* Firefox */
      scrollbar-color: rgba(0, 0, 0, 0.18) rgba(0, 0, 0, 0.04);
    }

    .signup-card.show-scroll::-webkit-scrollbar-track {
      background: rgba(0, 0, 0, 0.04);
    }

    .signup-card.show-scroll::-webkit-scrollbar-thumb {
      background: rgba(0, 0, 0, 0.18);
      opacity: 1;
    }

    /* Reveal scrollbar when pointer is near the right edge (see JS) */
    .google-logo {
      height: 20px;
      width: auto;
    }

    .btn-google {
      color: #444;
    }

    .btn-google:hover {
      box-shadow: 0 2px 6px rgba(0, 0, 0, 0.12);
    }

    /* Custom alert styling: green for success, red for error. Only message text is shown. */
    .custom-alert {
      padding: .75rem 1rem;
      border-radius: .375rem;
      margin-bottom: 1rem;
      font-weight: 500;
    }

    .custom-alert.success {
      background-color: #d1e7dd;
      color: #0f5132;
      border: 1px solid #bcd0c7;
    }

    .custom-alert.error {
      background-color: #f8d7da;
      color: #842029;
      border: 1px solid #f1c0c6;
    }
  </style>
</head>

<body>

  <div class="container d-flex justify-content-center align-items-center min-vh-100">
    <div class="card signup-card shadow-lg p-4" style="max-width: 420px; width: 100%;">

      <div class="text-center mb-4">
        <h3 class="fw-bold text-primary">Create Account</h3>

        <p class="text-muted">Join us Now!!</p>
      </div>

      <form action="/save_user" method="post">

        <% if (request.getAttribute("error") !=null) { %>
          <div class="custom-alert error">
            <%= request.getAttribute("error") %>
          </div>
          <% } else if (request.getAttribute("msg") !=null) { %>
            <div class="custom-alert success">
              <%= request.getAttribute("msg") %>
            </div>
            <% } %>

              <!-- Name -->
              <div class="mb-3">
                <label class="form-label">Full Name</label>
                <input type="text" class="form-control" placeholder="Enter your full name" name="name" required>
              </div>

              <!-- Role -->
              <div class="mb-3">
                <label class="form-label">Role</label>
                <select class="form-select" name="role" required>
                  <option value="" disabled selected>Select your role</option>
                  <option value="STUDENT">Student</option>
                  <option value="FACULTY">Faculty</option>
                  <option value="ADMIN">Admin</option>
                </select>
              </div>

              <!-- Password -->
              <div class="mb-3">
                <label class="form-label">Password</label>
                <input type="password" class="form-control" placeholder="Create password" name="password" required>
              </div>

              <!-- Confirm Password -->
              <div class="mb-3">
                <label class="form-label">Confirm Password</label>
                <input type="password" class="form-control" placeholder="Confirm password" name="confirmpassword"
                  required>
              </div>

              <button type="submit" class="btn btn-primary w-100 mb-3">
                Sign Up
              </button>



              <!-- OR divider -->
              <div class="d-flex align-items-center my-2">
                <hr class="flex-grow-1 me-2" />
                <small class="text-muted">or</small>
                <hr class="flex-grow-1 ms-2" />
              </div>

              <!-- Google sign-in -->
              <div class="d-grid mb-3">
                <a href="#" class="btn btn-light border d-flex align-items-center justify-content-center btn-google">
                  <img src="${pageContext.request.contextPath}/images/googlelogo.png" class="google-logo me-2"
                    alt="Google logo">
                  <span class="fw-semibold">Sign in with Google</span>
                </a>
              </div>

              <p class="text-center mt-1 mb-0">
                Already have an account?
                <a href="/signin" class="text-primary fw-bold">Login</a>

              </p>

      </form>


      <!-- Bootstrap JS -->
      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

      <script>
        document.addEventListener('DOMContentLoaded', function () {
          const form = document.querySelector('form[action="/save_user"]');
          if (!form) return;
          const pwd = form.querySelector('input[name="password"]');
          const cpwd = form.querySelector('input[name="confirmpassword"]');

          // Inline alert placeholder (will use same custom styles)
          const inlineAlert = document.createElement('div');
          inlineAlert.style.display = 'none';
          inlineAlert.className = 'custom-alert';
          form.insertBefore(inlineAlert, form.firstChild);

          // Ensure card fits on screen: limit height and allow internal scrolling
          const card = document.querySelector('.signup-card');
          if (card) {
            card.style.maxHeight = 'calc(90vh - 40px)';
            card.style.overflowY = 'auto';
          }

          form.addEventListener('submit', function (e) {
            if (pwd && cpwd && pwd.value !== cpwd.value) {
              e.preventDefault();
              inlineAlert.className = 'custom-alert error';
              inlineAlert.textContent = 'Password and Confirm Password do not match.';
              inlineAlert.style.display = 'block';
              cpwd.focus();
              // scroll the card into view so the alert is visible
              if (card) card.scrollIntoView({ behavior: 'smooth', block: 'center' });
              return false;
            }
          });

          // If server-rendered message exists on load, scroll card into view
          const serverAlert = document.querySelector('.custom-alert');
          if (serverAlert && card) {
            // small timeout to allow layout to settle
            setTimeout(() => card.scrollIntoView({ behavior: 'smooth', block: 'center' }), 50);
          }

          // Reveal scrollbar when pointer is near the right edge so native scrollbar stays clickable
          if (card) {
            const threshold = 18; // px from right edge to trigger
            let hoverTimer;
            card.addEventListener('mousemove', (ev) => {
              const rect = card.getBoundingClientRect();
              const x = ev.clientX - rect.left;
              const dist = rect.width - x;
              if (dist <= threshold) {
                card.classList.add('show-scroll');
                clearTimeout(hoverTimer);
              } else {
                clearTimeout(hoverTimer);
                hoverTimer = setTimeout(() => card.classList.remove('show-scroll'), 300);
              }
            });
            card.addEventListener('mouseleave', () => {
              card.classList.remove('show-scroll');
            });

            // When user scrolls the card manually, show scrollbar briefly
            let scrollTimer;
            card.addEventListener('scroll', () => {
              card.classList.add('show-scroll');
              clearTimeout(scrollTimer);
              scrollTimer = setTimeout(() => card.classList.remove('show-scroll'), 900);
            }, { passive: true });
          }
        });
      </script>
    </div>
  </div>
</body>

</html>