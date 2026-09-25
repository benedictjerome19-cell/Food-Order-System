<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    HttpSession currentSession = request.getSession(false);
    String userRole = currentSession != null ? (String) currentSession.getAttribute("userRole") : null;
    if (userRole != null) {
        userRole = userRole.trim().toUpperCase();
    } else {
        userRole = "";
    }
    
    // Secure developer/admin role validation
    if (!"ADMIN".equals(userRole) && !"DEVELOPER".equals(userRole) && !"RESTAURANT_OWNER".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    String userName = currentSession != null && currentSession.getAttribute("userName") != null 
        ? (String) currentSession.getAttribute("userName") 
        : "Benedict Jerome";

    // Safely retrieve restaurantId or ownerId with fallback
    long restaurantId = 1L;
    if (currentSession != null) {
        Object restIdObj = currentSession.getAttribute("restaurantId");
        if (restIdObj == null) {
            restIdObj = currentSession.getAttribute("ownerId");
        }
        if (restIdObj != null) {
            try {
                restaurantId = Long.parseLong(restIdObj.toString());
            } catch (Exception e) {
                restaurantId = 1L;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Management Control Center - BenedictJeromeMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .admin-grid { max-width: 1300px; margin: 2rem auto; padding: 0 1rem; }
        .admin-card { background: #ffffff; border: 1px solid #cbd5e1; border-radius: 16px; padding: 1.8rem; box-shadow: 0 10px 30px rgba(0,0,0,0.08); }
        .data-table { width: 100%; border-collapse: collapse; margin-top: 1rem; color: #1e293b; font-size: 0.9rem; }
        .data-table th, .data-table td { padding: 12px; text-align: left; border-bottom: 1px solid #e2e8f0; }
        .data-table th { color: #d97706; text-transform: uppercase; font-size: 0.8rem; font-weight: 700; }
        .error-banner { background: rgba(239, 68, 68, 0.15); border: 1px solid #ef4444; color: #991b1b; padding: 1rem; border-radius: 8px; margin-top: 1rem; font-size: 0.9rem; }
        .info-badge { display: inline-block; background: rgba(217, 119, 6, 0.1); color: #d97706; border: 1px solid #fcd34d; padding: 4px 10px; border-radius: 8px; font-size: 0.85rem; font-weight: 600; margin-bottom: 1rem; }
    </style>
</head>
<body data-restaurant-id="<%= restaurantId %>">
    <nav class="navbar">
        <a href="#" class="brand">
            <div class="brand-icon">⚡</div>
            Management Control Center
        </a>
        <div class="nav-right">
            <div class="welcome-badge">
                <span class="welcome-avatar">BJ</span>
                <%= userName %> <span style="color:#ef4444;font-weight:bold;"><%= userRole %></span>
            </div>
            <a href="<%= request.getContextPath() %>/home.jsp" class="btn-outline-sm">Customer View</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-outline-sm">Logout</a>
        </div>
    </nav>

    <div class="admin-grid">
        <div class="admin-card">
            <div class="info-badge">🏪 Active Restaurant ID: #<%= restaurantId %></div>
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem;">
                <h2 style="color: #1e293b;">👥 Platform Records Overview</h2>
                <button onclick="loadUsers()" class="btn-outline-sm" style="cursor:pointer;">🔄 Refresh Records</button>
            </div>
            <p style="color: #64748b; font-size:0.9rem; margin-bottom:1rem;">Full platform records inspection authorized for <strong><%= userName %></strong>.</p>
            <div id="users-table-container">
                <p style="color: #64748b;">Loading database records...</p>
            </div>
        </div>
    </div>

    <script>
    const ctx = '<%= request.getContextPath() %>';
    // Read restaurant ID cleanly from body dataset (Zero IDE linter warnings)
    const activeRestaurantId = parseInt(document.body.dataset.restaurantId || '1', 10);

    document.addEventListener('DOMContentLoaded', () => {
        loadUsers();
    });

    function safeGet(val, fallback = 'N/A') {
        if (val === null || val === undefined || String(val).trim() === '') {
            return fallback;
        }
        return val;
    }

    async function loadUsers() {
        const container = document.getElementById('users-table-container');
        container.innerHTML = `<p style="color: #64748b;">Fetching records from server...</p>`;
        
        try {
            const res = await fetch(ctx + '/api/v1/admin/users', {
                method: 'GET',
                credentials: 'include'
            });
            if (!res.ok) throw new Error('HTTP ' + res.status);
            const result = await res.json();
            console.log("Admin Users API Full Response:", result);

            if (result.success === false) {
                const errorMsg = result.error ? result.error.message : 'Access denied or server error';
                container.innerHTML = `
                    <div class="error-banner">
                        <strong>⚠️ Error:</strong> ${errorMsg}
                    </div>`;
                return;
            }

            let users = [];
            if (Array.isArray(result.data)) {
                users = result.data;
            } else if (Array.isArray(result)) {
                users = result;
            }

            if (users.length === 0) {
                container.innerHTML = `<p style="color: #64748b;">No user records found in database.</p>`;
                return;
            }

            let html = `
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email Address</th>
                            <th>Role</th>
                            <th>Created At</th>
                        </tr>
                    </thead>
                    <tbody>
            `;

            users.forEach((user, index) => {
                const uId = safeGet(user.id ?? user.ID, index + 1);
                const uName = safeGet(user.name ?? user.NAME ?? user.userName, 'N/A');
                const uEmail = safeGet(user.email ?? user.EMAIL, 'N/A');
                const uRole = safeGet(user.role ?? user.ROLE, 'CUSTOMER');
                const uCreated = safeGet(user.createdAt ?? user.CREATEDAT, 'Recently');

                html += `
                    <tr>
                        <td>#${uId}</td>
                        <td><strong>${uName}</strong></td>
                        <td>${uEmail}</td>
                        <td><span style="background: rgba(59, 130, 246, 0.1); color: #2563eb; border: 1px solid #93c5fd; padding: 2px 8px; border-radius: 10px; font-size: 0.75rem; font-weight: 600;">${uRole}</span></td>
                        <td style="color: #64748b; font-size: 0.85rem;">${uCreated}</td>
                    </tr>
                `;
            });

            html += `</tbody></table>`;
            container.innerHTML = html;
        } catch (err) {
            console.error("Error loading users:", err);
            container.innerHTML = `
                <div class="error-banner">
                    <strong>⚠️ Connection Failed:</strong> Could not load user records from the server.
                </div>`;
        }
    }
    </script>
</body>
</html>