<jsp:include page="bootstraplink.jsp"/>
<style>
  .sidebar {
    width: 260px;
    min-height: 100vh;
    background-color: #ffffff;
    border-right: 1px solid #dee2e6;
    position: fixed;
    left: 0;
    top: 0;
    padding: 20px;
  }

  .profile-box {
    text-align: center;
    margin-bottom: 30px;
  }

  .profile-box img {
    width: 90px;
    height: 90px;
    border-radius: 50%;
    object-fit: cover;
    border: 3px solid #0d6efd;
    margin-bottom: 10px;
  }

  .profile-box h6 {
    margin: 0;
    font-weight: 600;
  }

  .profile-box small {
    color: #6c757d;
  }

  .sidebar a {
    display: flex;
    align-items: center;
    padding: 10px 12px;
    margin-bottom: 8px;
    border-radius: 8px;
    text-decoration: none;
    color: #495057;
    font-weight: 500;
  }

  .sidebar a i {
    margin-right: 10px;
    font-size: 18px;
  }

  .sidebar a:hover,
  .sidebar a.active {
    background-color: #e7f1ff;
    color: #0d6efd;
  }
</style>


<!-- Sidebar -->
<div class="sidebar">

  <!-- Profile Section -->
  <div class="profile-box">
    <img src="https://via.placeholder.com/150" alt="Profile">
    <h6>Shreya Singh</h6>
    <small>Java Developer</small>
  </div>

  <!-- Menu Links -->
  <a href="/dashboard" class="active">
    <i class="bi bi-speedometer2"></i> Dashboard
  </a>

  <a href="/profile">
    <i class="bi bi-person"></i> Profile
  </a>

  <a href="/settings">
    <i class="bi bi-gear"></i> Settings
  </a>

  <a href="/changePassword">
    <i class="bi bi-shield-lock"></i> Change Password
  </a>

  <a href="/logout">
    <i class="bi bi-box-arrow-right"></i> Logout
  </a>

</div>
