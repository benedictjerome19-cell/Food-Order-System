<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Automatically redirect root URL requests to the login page
    response.sendRedirect(request.getContextPath() + "/login.jsp");
%>