<jsp:include page="bootstraplink.jsp"/>

<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>User Profile</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

  <style>
    body {
      background-color: #f4f6f9;
    }

    .profile-card {
      max-width: 800px;
      margin: auto;
      border-radius: 15px;
      box-shadow: 0 8px 20px rgba(0,0,0,0.08);
      border: none;
    }

    .profile-img {
      width: 150px;
      height: 150px;
      object-fit: cover;
      border-radius: 50%;
      border: 4px solid #0d6efd;
    }

    .edit-photo {
      position: absolute;
      bottom: 10px;
      right: 10px;
      background: #0d6efd;
      color: white;
      border-radius: 50%;
      padding: 8px;
      cursor: pointer;
    }

    .photo-wrapper {
      position: relative;
      display: inline-block;
    }
  </style>
</head>
<body>

<div class="container py-5">

  <div class="card profile-card p-4">
    <div class="row">

      <!-- Left: Profile Photo -->
      <div class="col-md-4 text-center">
        <div class="photo-wrapper">
          <img src="https://via.placeholder.com/150" class="profile-img" alt="Profile Photo">
          <label class="edit-photo">
            <i class="bi bi-camera-fill"></i>
            <input type="file" hidden>
          </label>
        </div>
        <h5 class="mt-3">${userprofile[0].name}</h5>
      </div>

      <!-- Right: Profile Details -->
      <div class="col-md-8">
        <h5 class="mb-3">Profile Details</h5>

        <form>
          <div class="mb-3">
            <label class="form-label">Full Name</label>
            <input type="text" class="form-control" value="${userprofile[0].name}">
          </div>

          <div class="mb-3">
            <label class="form-label">Email</label>
            <input type="email" class="form-control" value="${userprofile[0].email}" readonly>
          </div>

          <div class="mb-3">
            <label class="form-label">Contact Number</label>
            <input type="text" class="form-control" value="${userprofile[0].mobile}">
          </div>

          <button class="btn btn-primary">
            <i class="bi bi-pencil-square"></i> Update Profile
          </button>
        </form>
      </div>

    </div>
  </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

