<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Create Account - BenedictJeromeMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
    <header class="navbar"><a href="#" class="brand"><div class="brand-icon">🛒</div>BenedictJeromeMart</a></header>
    <main class="auth-container">
        <div class="auth-card">
            <div class="auth-header"><h2>Join BenedictJeromeMart</h2><p style="color:var(--text-muted)">Create an account</p></div>
            <div id="message"></div>
            <form id="registerForm">
                <div class="form-group"><label>Full Name</label><input type="text" id="name" name="name" class="form-control" required></div>
                <div class="form-group"><label>Email Address</label><input type="email" id="email" name="email" class="form-control" required></div>
                <div class="form-group"><label>Password</label><input type="password" id="password" name="password" class="form-control" required></div>
                <div class="form-group"><label>Role</label><select id="role" name="role" class="form-control" style="background:#0a090e;color:#fff;"><option value="CUSTOMER">Customer</option><option value="RESTAURANT_OWNER">Restaurant Owner</option></select></div>
                <button type="submit" class="btn btn-primary" style="margin-top:1rem;width:100%;">Create Account ✨</button>
            </form>
            <div class="auth-footer" style="margin-top:1.5rem;text-align:center;">Have an account? <a href="login.jsp" style="color:var(--primary);font-weight:bold;">Log in</a></div>
        </div>
    </main>
    <script>
        document.getElementById('registerForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            const msg = document.getElementById('message');
            const res = await fetch('<%= request.getContextPath() %>/register', { method: 'POST', body: new URLSearchParams(new FormData(this)) });
            const result = await res.json();
            if (result.success) {
                msg.className = 'alert-message alert-success';
                msg.textContent = 'Account created! Redirecting...';
                setTimeout(() => { window.location.href = 'login.jsp'; }, 1000);
            } else {
                msg.className = 'alert-message alert-error';
                msg.textContent = result.error ? result.error.message : 'Registration failed';
            }
        });
    </script>
</body>
</html>