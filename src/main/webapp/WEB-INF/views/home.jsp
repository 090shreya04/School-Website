<jsp:include page="bootstraplink.jsp" />

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>School Website</title>

  <style>
    /* Hero Section */
    .hero-section {
      background-image: url("/images/image.png");
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
      min-height: 450px;
      display: flex;
      align-items: center;
      justify-content: center;
      position: relative;
    }

    .hero-section::before {
      content: "";
      position: absolute;
      inset: 0;
      background: rgba(0, 0, 0, 0.5);
    }

    .hero-section .container {
      position: relative;
      z-index: 1;
    }

    /* About Section Styling */
    .about-section {
      background-color: #f8f9fa;
    }

    .about-image {
      border-radius: 15px;
      box-shadow: 0 10px 25px rgba(0,0,0,0.15);
      transition: transform 0.4s ease, box-shadow 0.4s ease;
    }

    .about-image:hover {
      transform: scale(1.05);
      box-shadow: 0 15px 35px rgba(0,0,0,0.25);
    }

    .about-text h2 {
      font-weight: 700;
    }

    .about-text p {
      font-size: 1.05rem;
      line-height: 1.7;
    }


    /* Why Choose Us Section */
.why-section {
  background: linear-gradient(135deg, #eef2ff, #f8f9fa);
}

.why-card {
  background: #ffffff;
  border-radius: 15px;
  padding: 30px 20px;
  transition: all 0.4s ease;
  position: relative;
  overflow: hidden;
}

.why-card::before {
  content: "";
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: rgba(13, 110, 253, 0.08); /* Bootstrap primary */
  transition: left 0.4s ease;
}

.why-card:hover::before {
  left: 0;
}

.why-card:hover {
  transform: translateY(-12px);
  box-shadow: 0 18px 35px rgba(0, 0, 0, 0.2);
}

.why-card h4 {
  font-weight: 600;
  margin-bottom: 10px;
}

.why-card p {
  color: #555;
}

  </style>
</head>

<body>

<!-- Navbar -->
<nav class="navbar navbar-light bg-light shadow-sm">
  <div class="container">
    <a class="navbar-brand fw-bold" href="/">MySchool</a>

    <div class="ms-auto">
      <a href="/signin" class="btn btn-outline-primary me-2">Sign In</a>
      <a href="/signup" class="btn btn-primary">Sign Up</a>
    </div>
  </div>
</nav>

<!-- Hero Section -->
<header class="hero-section text-white text-center">
  <div class="container">
    <h1 class="display-4 fw-bold">Welcome to MySchool</h1>
    <p class="lead">Empowering students with quality education</p>
  </div>
</header>

<!-- About Section (Enhanced) -->
<section class="about-section py-5">
  <div class="container">
    <div class="row align-items-center g-5">

      <!-- Image -->
      <div class="col-md-6 text-center">
        <img src="/images/schoolimg.jpeg"
             class="img-fluid about-image"
             alt="Our School">
      </div>

      <!-- Text -->
      <div class="col-md-6 about-text">
        <h2 class="mb-3">About Our School</h2>
        <p>
          MySchool is committed to nurturing young minds with a perfect blend
          of academic excellence, creativity, and values.
        </p>
        <p>
          With experienced teachers, modern infrastructure, and a student-centric
          approach, we help learners grow into confident and responsible individuals.
        </p>
        
      </div>

    </div>
  </div>
</section>

<!-- Features Section -->
<section class="why-section py-5">
  <div class="container">
    <h2 class="text-center mb-5 fw-bold">Why Choose Us</h2>

    <div class="row text-center g-4">
      <div class="col-md-4">
        <div class="why-card">
          <h4>Expert Teachers</h4>
          <p>Highly qualified and experienced faculty dedicated to student success.</p>
        </div>
      </div>

      <div class="col-md-4">
        <div class="why-card">
          <h4>Modern Classes</h4>
          <p>Smart classrooms equipped with the latest teaching technologies.</p>
        </div>
      </div>

      <div class="col-md-4">
        <div class="why-card">
          <h4>Sports & Activities</h4>
          <p>Balanced focus on academics and extra-curricular development.</p>
        </div>
      </div>
    </div>
  </div>
</section>


<!-- Footer -->
<footer class="bg-dark text-white py-4">
  <div class="container text-center">
    <p>Contact us: info@myschool.com | +91 1234567890</p>
    <p class="mb-0">&copy; 2026 MySchool. All Rights Reserved.</p>
  </div>
</footer>

</body>
</html>
