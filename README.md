# Flutter Task Manager (Frontend + Backend)

This is a simple **Task Manager app** built with:
- **Frontend:** Flutter (Riverpod, Dio, GoRouter, Freezed, Secure Storage, custom theming)
- **Backend:** Node.js (Express, Prisma ORM, SQLite, JWT authentication, bcrypt for password hashing)

Users can **register, login, create tasks, update tasks, mark tasks as completed/pending, and delete tasks**. Each user only sees their own tasks.

---

## 📂 Project Structure
project-root/
backend/ <-- Node.js + Prisma + SQLite
frontend/ <-- Flutter app

---

## 🚀 Backend Setup (Node.js + Prisma + SQLite)

 1. Install dependencies
```bash
cd backend
npm install

```
2. Configure database

Prisma is already set up with SQLite.

prisma/schema.prisma defines:
```bash
model User {
  id           String   @id @default(uuid())
  email        String   @unique
  passwordHash String
  tasks        Task[]
}

model Task {
  id          String   @id @default(uuid())
  title       String
  description String
  status      String   @default("pending")
  user        User     @relation(fields: [userId], references: [id])
  userId      String
}
```
Run migration to create the DB
```bash
npx prisma migrate dev --name init
```
3. Run the backend
 ```bash
npm run dev
```
By default the backend runs at:
```bash
http://localhost:8080
```
Reset DB:
```bash
npx prisma migrate reset
```

## 🎨 Frontend Setup (Flutter)
1. Install dependencies
```bash
cd frontend
flutter pub get
```
2. Generate code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
This generates Freezed & JSON serialization code.

3. Run the app

Android Emulator:
The backend is http://10.0.2.2:8080

iOS Simulator:
The backend is http://localhost:8080

Real Device:
Use your machine’s LAN IP, e.g. http://192.168.1.10:8080

Run:
```bash
flutter run
```
🔑 Authentication Flow

Users register with email + password.

Passwords are stored hashed (bcrypt).

Login issues a JWT token (valid for 1 day).

Flutter stores token securely (flutter_secure_storage).

All API requests attach Authorization: Bearer <token>.

Backend validates token with middleware.

📝 Features

✅ Register new user
✅ Login & persist session
✅ Logout
✅ Add tasks (per user)
✅ Edit tasks (title, description, status)
✅ Toggle task completion
✅ Delete tasks
✅ Each user sees only their tasks

🛠️ Tech Stack
Frontend

Flutter

Riverpod
 (state management)

GoRouter
 (navigation)

Dio
 (HTTP client)

Freezed
 (data classes)

flutter_secure_storage
 (secure token storage)

Backend

Node.js

Express

Prisma ORM

SQLite

jsonwebtoken
 (JWT auth)

bcryptjs
 (password hashing)

📸 Screens (Frontend)

Login screen with logo

Register screen

Task list (per user)

Add/Edit task

Toggle completion

Logout

🧑‍💻 Development Notes

Backend is stateless: token determines the user.

On 401 or 403, frontend clears token and redirects to login.

Tasks are tied to userId in SQLite DB.

✅ Future Improvements

Add refresh token support

Persist theme preference

Deploy backend to cloud (Heroku, Render, Railway)

Use PostgreSQL/MySQL for production

📌 Quickstart
# Backend
cd backend
npm install
npx prisma migrate dev --name init
npm run dev

# Frontend
cd frontend
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
