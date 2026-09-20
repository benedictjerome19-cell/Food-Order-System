<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login - Benedict Jerome Mart</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <nav class="navbar">
        <a href="${pageContext.request.contextPath}/home.jsp" class="brand">
            <div class="brand-icon">B</div>
            Benedict Jerome Mart
        </a>
    </nav>

    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <h2>Welcome Back</h2>
                <p>Sign in to continue your premium food experience.</p>
            </div>
            
            <% String error = request.getParameter("error");
               if (error != null) { %>
                   <div class="alert-message alert-error"><%= error %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/login" method="post">
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" required placeholder="name@example.com">
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-control" required placeholder="••••••••">
                </div>
                <button type="submit" class="btn btn-primary" style="margin-top: 1rem;">Sign In</button>
            </form>
            
            <div class="auth-footer">
                Don't have an account? <a href="${pageContext.request.contextPath}/register.jsp">Register here</a>
            </div>
        </div>
    </div>
</body>
</html>