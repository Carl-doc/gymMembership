<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login | Aki's Fitness Gym</title>

<link rel="stylesheet" href="../assets/css/style.css">

<style>
.login-page{
height:100vh;
display:flex;
justify-content:center;
align-items:center;
background:linear-gradient(90deg,#000,#888);
}

.login-card{
background:#f5f5f5;
padding:40px;
border-radius:15px;
width:350px;
text-align:center;
}

.login-card input{
width:100%;
padding:10px;
margin:10px 0;
}

.login-card button{
width:100%;
padding:10px;
background:#2c5057;
color:#fff;
border:none;
border-radius:8px;
}
</style>

</head>

<body class="login-page">

<div class="login-card">

<h2>Aki's Fitness Gym</h2>

<form method="POST" action="process_login.php">

<input type="text" name="username" placeholder="Username" required>

<input type="password" name="password" placeholder="Password" required>

<button type="submit">Login</button>

</form>

</div>

</body>
</html>