# YourNameEats

Multi-restaurant food ordering web app. Built with Java Servlets, JDBC, H2, and Tomcat 9.

## Before you start
Replace every instance of `yourname` / `yournameeats` in package names, file paths,
and the JDBC URL with your own name-based project name — for example `aditya` /
`adityaeats`. Do this consistently across all files, including folder names under
`src/main/java/com/`.

## Prerequisites
- JDK 17
- Maven
- Apache Tomcat 9.0.x

## Setup steps

1. **Generate real password hashes**
   Run `src/test/java/com/yourname/yournameeats/HashGenerator.java` (right-click →
   Run in your IDE, or `mvn compile exec:java -Dexec.mainClass="com.yourname.yournameeats.HashGenerator"`).
   Copy the printed hashes into `db/migrations/seed.sql`, replacing the placeholder text.

2. **Build the project**
   ```
   mvn clean package
   ```
   This produces `target/yournameeats.war`.

3. **Deploy to Tomcat**
   Copy `target/yournameeats.war` into your Tomcat installation's `webapps/` folder.
   Start Tomcat (`bin/startup.sh` or `bin/startup.bat`).

4. **Load the database schema**
   The app auto-creates an H2 database file at `./data/yournameeats.mv.db` on first
   run (via HikariCP + AppContextListener), but the *tables* need to be created
   manually the first time. Use the H2 Console:
   ```
   java -cp h2*.jar org.h2.tools.Console
   ```
   Connect using JDBC URL `jdbc:h2:./data/yournameeats`, then paste and run the
   contents of `db/migrations/V1__init_schema.sql`, followed by `db/migrations/seed.sql`
   (after you've filled in real password hashes from step 1).

5. **Try it out**
   Visit `http://localhost:8080/yournameeats/register.jsp`, create an account, then
   log in at `login.jsp` and browse/order from `home.jsp`.

## Project structure
```
com.yourname.yournameeats
|-- controller   Servlets (HTTP orchestration only)
|-- service      Business logic and validation
|-- dao          Interfaces + JDBC implementations (all SQL lives here)
|-- model        POJOs / entities
|-- filter       AuthFilter (session check)
|-- listener     AppContextListener (HikariCP connection pool)
`-- util         PasswordUtil (bcrypt)
```

## What's implemented so far
- User registration and login with roles (Customer, Restaurant Owner, Admin)
- Session-based authentication with AuthFilter protecting API routes
- Browse/search menu items
- Cart (add/update/remove)
- Checkout with mock payment confirmation (creates an Order)

## Not yet implemented
- Restaurant owner dashboard (menu item CRUD)
- Admin panel
- Reviews/ratings
- Order status workflow
- Automated tests, security hardening, cloud deployment
