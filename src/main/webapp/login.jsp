<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - BenedictJeromeMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
    <header class="navbar">
        <a href="#" class="brand">
            <div class="brand-icon">🛒</div>
            BenedictJeromeMart
        </a>
    </header>

    <main class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <h2>Welcome Back!</h2>
                <p>Log in to order your favorite delicious food</p>
            </div>

            <form id="loginForm">
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" placeholder="name@example.com" required>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required>
                </div>

                <button type="submit" class="btn btn-primary" style="margin-top: 1rem;">
                    Sign In ➔
                </button>
            </form>

            <div id="message"></div>

            <div class="auth-footer">
                Don't have an account yet? <a href="register.jsp">Create one here</a>
            </div>
        </div>
    </main>

    <script>
        document.getElementById('loginForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            const messageDiv = document.getElementById('message');
            messageDiv.innerHTML = '';
            
            const formData = new URLSearchParams(new FormData(this));

            try {
                const response = await fetch('<%= request.getContextPath() %>/api/v1/login', {
                    method: 'POST',
                    body: formData
                });

                const result = await response.json();
                if (result.success) {
                    messageDiv.className = 'alert-message alert-success';
                    messageDiv.textContent = 'Login successful! Redirecting...';
                    setTimeout(() => {
                        window.location.href = 'home.jsp';
                    }, 500);
                } else {
                    messageDiv.className = 'alert-message alert-error';
                    messageDiv.textContent = result.error.message || 'Invalid credentials';
                }
            } catch (err) {
                messageDiv.className = 'alert-message alert-error';
                messageDiv.textContent = 'Server connection error. Please try again.';
            }
        });
    </script>
</body>
</html>