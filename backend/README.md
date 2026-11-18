\# Smart Auto Care – Backend



Django REST Framework backend for the Smart Auto Care project.



\## Technology Stack



\- Python 3.15

\- Django 6.1.3

\- Django REST Framework

\- PostgreSQL

\- Psycopg 3

\- python-dotenv



\## Project Setup



\### 1. Navigate to backend



```bash

cd backend

```



\### 2. Create virtual environment



```bash

py -m venv .venv

```



\### 3. Activate virtual environment (Windows PowerShell)



```powershell

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

.\\.venv\\Scripts\\Activate.ps1

```



\### 4. Install dependencies



```bash

pip install -r requirements.txt

```



\### 5. Configure environment variables



Copy `.env.example` to `.env` and update the PostgreSQL credentials.



Required variables:



\- SECRET\_KEY

\- DEBUG

\- DB\_NAME

\- DB\_USER

\- DB\_PASSWORD

\- DB\_HOST

\- DB\_PORT



\### 6. Create PostgreSQL database



Create a PostgreSQL database named `smart\_auto\_care`.



\### 7. Run Django checks



```bash

python manage.py check

```



\### 8. Start development server



```bash

python manage.py runserver

```



\## Important Notes



\- Never commit `.env` or real database credentials.

\- `.env.example` is safe to commit.

\- PostgreSQL is the primary database.

\- Custom user model and initial migrations will be configured before the first database migration.

\- Do not use Firebase as the backend database.
