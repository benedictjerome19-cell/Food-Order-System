<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account - BenedictJeromeMart</title>
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
                <h2>Join BenedictJeromeMart</h2>
                <p>Create an account to start exploring tasty options</p>
            </div>

            <form id="registerForm">
                <div class="form-group">
                    <label for="name">Full Name</label>
                    <input type="text" id="name" name="name" class="form-control" placeholder="John Doe" required>
                </div>

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" placeholder="name@example.com" required>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required>
                </div>

                <div class="form-group">
                    <label for="role">Account Role</label>
                    <select id="role" name="role" class="form-control">
                        <option value="CUSTOMER">Customer (Order Food)</option>
                        <option value="RESTAURANT_OWNER">Restaurant Owner</option>
                    </select>
                </div>

                <button type="submit" class="btn btn-primary" style="margin-top: 1rem;">
                    Create Account ✨
                </button>
            </form>

            <div id="message"></div>

            <div class="auth-footer">
                Already have an account? <a href="login.jsp">Log in here</a>
            </div>
        </div>
    </main>

    <script>
        document.getElementById('registerForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            const messageDiv = document.getElementById('message');
            messageDiv.innerHTML = '';
            
            const formData = new URLSearchParams(new FormData(this));

            try {
                const response = await fetch('<%= request.getContextPath() %>/api/v1/register', {
                    method: 'POST',
                    body: formData
                });

                const result = await response.json();
                if (result.success) {
                    messageDiv.className = 'alert-message alert-success';
                    messageDiv.textContent = 'Account created successfully! Redirecting to login...';
                    setTimeout(() => {
                        window.location.href = 'login.jsp';
                    }, 1200);
                } else {
                    messageDiv.className = 'alert-message alert-error';
                    messageDiv.textContent = result.error.message || 'Registration failed';
                }
            } catch (err) {
                messageDiv.className = 'alert-message alert-error';
                messageDiv.textContent = 'Server connection error. Please try again.';
            }
        });
    </script>
</body>
</html>