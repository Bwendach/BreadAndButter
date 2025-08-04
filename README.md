# Bread & Butter - Qualification Project

This project consists of an Express backend (Node.js) and a Flutter frontend for a bakery app.

## Backend (Express)

### Setup

1. Navigate to the backend folder:
   ```sh
   cd Express/bread_backend
   ```
2. Install dependencies:
   ```sh
   npm install
   ```
3. Create the database (MySQl):
   - Make sure MySQl (xampp) is running.
   - Create a database named `bread_db`.
4. Run migrations and seed data:
   ```sh
   npm run migrate-seed
   ```
5. Start the backend server:
   ```sh
   npm start
   ```
   The server will run on `http://localhost:3000` by default.

## Frontend (Flutter)

### Setup

1. Navigate to the Flutter app folder:
   ```sh
   cd Flutter/mcc_qualification_bd
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Configure environment variables:
   - Edit the `.env` file in `Flutter/mcc_qualification_bd` to set the backend URL:
     ```env
     URLPATH=http://10.0.2.2:3000
     ```
   - `10.0.2.2` is used for Android emulators. Use `localhost` or your machine's IP if running on other platforms.
4. Run the Flutter app:
   ```sh
   flutter run
   ```

## Notes

- The backend must be running before starting the Flutter app.
- Make sure to update the `.env` file if your backend URL changes.

---

**Enjoy Bread & Butter!**
