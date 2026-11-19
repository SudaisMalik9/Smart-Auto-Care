# Smart Auto Care - API Contract



## 1. General Information



- Backend: Django

- API Framework: Django REST Framework

- Database: PostgreSQL

- Authentication: Token Authentication

- Base URL (local): http://127.0.0.1:8000

- API prefix: /api/



## 2. User Roles



The system supports four roles:



| Role | Code |

|---|---|

| Admin | ADMIN |

| Workshop Owner | WORKSHOP_OWNER |

| Customer | CUSTOMER |

| Mechanic | MECHANIC |



Public registration creates CUSTOMER accounts only.



Admin, Workshop Owner and Mechanic accounts must be created through authorized administrative processes.



## 3. Authentication



Protected endpoints require this HTTP header:



Authorization: Token YOUR_AUTH_TOKEN



Content-Type: application/json



### 3.1 Customer Registration



- Method: POST

- Endpoint: /api/auth/register/

- Authentication: Not required



Request:



{

  "username": "customer1",

  "email": "customer@example.com",

  "first_name": "Ali",

  "last_name": "Khan",

  "password": "StrongPassword!7391",

  "password_confirm": "StrongPassword!7391"

}



Success: HTTP 201



Response:



{

  "id": 1,

  "username": "customer1",

  "email": "customer@example.com",

  "first_name": "Ali",

  "last_name": "Khan"

}



Notes:

- Password confirmation must match.

- Password must satisfy Django password validation.

- Role is automatically assigned CUSTOMER.

- Clients cannot assign privileged roles through registration.




### 3.2 Login

- Method: POST
- Endpoint: /api/auth/login/
- Authentication: Not required
- Content-Type: application/json

Users can log in using either their username or email address.

**Option A — Username login**

Request:

{
  "username": "customer1",
  "password": "StrongPassword!7391"
}

**Option B — Email login**

Request:

{
  "email": "customer@example.com",
  "password": "StrongPassword!7391"
}

Important:
- Provide either username or email, not both.
- Email matching is case-insensitive.
- Invalid credentials return HTTP 400.
- Inactive accounts cannot log in.

Success: HTTP 200

Response:

{
  "message": "Login successful.",
  "token": "AUTH_TOKEN",
  "user": {
    "id": 1,
    "username": "customer1",
    "email": "customer@example.com",
    "first_name": "Ali",
    "last_name": "Khan",
    "role": "CUSTOMER"
  }
}

Error responses:
- HTTP 400: Missing login identifier, both identifiers supplied, invalid credentials or inactive account.



### 3.3 Logout



- Method: POST

- Endpoint: /api/auth/logout/

- Authentication: Required



Header:



Authorization: Token YOUR_AUTH_TOKEN



Success: HTTP 200



Response:



{

  "message": "Logout successful."

}



The user's authentication token is deleted.



### 3.4 User Profile



- Method: GET

- Endpoint: /api/auth/profile/

- Authentication: Required



Header:



Authorization: Token YOUR_AUTH_TOKEN



Success: HTTP 200



Response:



{

  "id": 1,

  "username": "customer1",

  "email": "customer@example.com",

  "first_name": "Ali",

  "last_name": "Khan",

  "role": "CUSTOMER"

}



Unauthenticated request: HTTP 401



## 4. Error Responses



Common validation errors:



- HTTP 400: Invalid input, duplicate username/email, password mismatch or invalid credentials.

- HTTP 401: Missing or invalid authentication token.

- HTTP 403: Authenticated user does not have permission for a restricted resource.



## 5. Frontend Integration Notes



Flutter and Website developers must:



1. Use the same backend API.

2. Send JSON requests.

3. Store the authentication token securely.

4. Include the Token authorization header for protected requests.

5. Read the role returned by login/profile.

6. Never assume a user's role from the frontend.

7. Handle API validation and authentication errors.



## 6. Current Implementation Scope



Implemented authentication endpoints:



- POST /api/auth/register/

- POST /api/auth/login/

- POST /api/auth/logout/

- GET /api/auth/profile/



Automated authentication tests currently cover registration, password mismatch, login, profile access and logout.



Role-specific business endpoints are not yet implemented.
