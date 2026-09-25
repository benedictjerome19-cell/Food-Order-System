<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - BenedictJeromeMart</title>
    <!-- Link to the central glassmorphism stylesheet -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/home.jsp" class="brand">
            <div class="brand-icon">🛒</div>
            BenedictJeromeMart
        </a>
    </header>

    <main class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <h2>Welcome Back!</h2>
                <p style="color:var(--text-muted)">Log in to order your favorite delicious food</p>
            </div>

            <!-- Message banner for success or error feedback -->
            <div id="message"></div>

            <form id="loginForm">
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" placeholder="name@example.com" required>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required>
                </div>

                <button type="submit" class="btn btn-primary" style="margin-top: 1rem; width: 100%;">
                    Sign In ➔
                </button>
            </form>

            <div class="auth-footer" style="margin-top: 1.5rem; text-align: center;">
                Don't have an account yet? <a href="<%= request.getContextPath() %>/register.jsp" style="color:var(--primary);font-weight:bold;">Create one here</a>
            </div>
        </div>
    </main>

    <script>
        // Capture the dynamic Tomcat context path (e.g., "" for ROOT or "/app" otherwise)
        const ctx = '<%= request.getContextPath() %>';

        document.getElementById('loginForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            const messageDiv = document.getElementById('message');
            messageDiv.innerHTML = '';
            messageDiv.className = '';
            
            // Serialize form input values for url-encoded submission
            const formData = new URLSearchParams(new FormData(this));

            try {
                // Send asynchronous POST request to LoginServlet
                const response = await fetch(ctx + '/api/v1/login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData
                });

                const result = await response.json();
                console.log("Server Login Response:", result);

                if (result.success) {
                    messageDiv.style.cssText = 'background: rgba(16,185,129,0.2); color: #10b981; border: 1px solid #10b981; padding: 10px; border-radius: 8px; margin-bottom: 1rem; font-size: 0.9rem;';
                    messageDiv.textContent = result.message || 'Login successful! Redirecting...';
                    
                    // Normalize the target redirect URL provided by backend servlet
                    let target = result.redirectUrl || 'home.jsp';
                    if (!target.startsWith('/')) {
                        target = '/' + target;
                    }

                    // Force browser navigation after a short delay
                    setTimeout(() => {
                        window.location.replace(ctx + target);
                    }, 800);
                } else {
                    messageDiv.style.cssText = 'background: rgba(239,68,68,0.2); color: #ef4444; border: 1px solid #ef4444; padding: 10px; border-radius: 8px; margin-bottom: 1rem; font-size: 0.9rem;';
                    messageDiv.textContent = (result.error && result.error.message) ? result.error.message : 'Invalid credentials';
                }
            } catch (err) {
                console.error('Fetch error during login:', err);
                messageDiv.style.cssText = 'background: rgba(239,68,68,0.2); color: #ef4444; border: 1px solid #ef4444; padding: 10px; border-radius: 8px; margin-bottom: 1rem; font-size: 0.9rem;';
                messageDiv.textContent = 'Server connection error. Please try again.';
            }
        });
    </script>
</body>
</html>


