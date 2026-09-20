<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register - Benedict Jerome Mart</title>
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
                <h2>Create Account</h2>
                <p>Join for a premium food experience.</p>
            </div>
            
            <% String error = request.getParameter("error");
               if (error != null) { %>
                   <div class="alert-message alert-error"><%= error %></div>
            <% } %>

            <!-- Submits dynamically to the correct context path -->
            <form action="${pageContext.request.contextPath}/register" method="post">
                <div class="form-group">
                    <label for="name">Full Name</label>
                    <input type="text" id="name" name="name" class="form-control" required placeholder="John Doe">
                </div>
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" required placeholder="name@example.com">
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-control" required placeholder="••••••••">
                </div>
                <div class="form-group">
                    <label for="role">Account Role</label>
                    <select id="role" name="role" class="form-control" required style="background: rgba(10,9,14,0.9);">
                        <option value="CUSTOMER">Customer</option>
                        <option value="RESTAURANT_OWNER">Restaurant Owner</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary" style="margin-top: 1rem;">Create Account</button>
            </form>
            
            <div class="auth-footer">
                Already have an account? <a href="${pageContext.request.contextPath}/login.jsp">Log in here</a>
            </div>
        </div>
    </div>
</body>
</html>