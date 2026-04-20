# MindBloom PHP Backend

This folder contains the PHP API for the MindBloom Flutter app.

## Files

- `api/config.sample.php` template for database credentials
- `api/health.php` backend health check
- `api/bootstrap.php` creates or updates the app user
- `api/moods.php` mood CRUD
- `api/journals.php` journal CRUD and image upload
- `api/habits.php` habit CRUD and completion toggles
- `sql/schema.sql` MySQL schema

## Deployment

1. Upload the `backend` folder to your PHP hosting.
2. Copy `api/config.sample.php` to `api/config.php` on the server.
3. Put your real database host, name, username, and password into `config.php`.
4. Ensure the `uploads/` folder is writable by PHP.
5. Import `sql/schema.sql` into phpMyAdmin.
6. Open `api/health.php` in the browser to verify the backend works.

## Public Repo Safety

Do not commit `api/config.php` to GitHub.
