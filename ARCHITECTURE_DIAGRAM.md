# Architecture Diagram - Flutter Rental Management App

This document provides visual representations of the app's architecture, data flow, and component relationships.

---

## 🏗️ Overall Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                       │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────┐            │
│  │   Admin    │  │   Landlord   │  │    Tenant    │            │
│  │  Screens   │  │   Screens    │  │   Screens    │            │
│  └─────┬──────┘  └──────┬───────┘  └──────┬───────┘            │
│        │                │                  │                     │
│        └────────────────┼──────────────────┘                     │
│                         │                                        │
│  ┌──────────────────────▼─────────────────────────┐             │
│  │         Providers (State Management)           │             │
│  │  ┌─────────┐  ┌──────────┐  ┌──────────────┐  │             │
│  │  │  Auth   │  │ Payment  │  │  Dashboard   │  │             │
│  │  │Provider │  │ Provider │  │   Provider   │  │             │
│  │  └─────────┘  └──────────┘  └──────────────┘  │             │
│  └──────────────────────┬─────────────────────────┘             │
└─────────────────────────┼───────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────┐
│                      BUSINESS LOGIC LAYER                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                     Repositories                         │   │
│  │  ┌───────────┐  ┌────────────┐  ┌─────────────────┐     │   │
│  │  │   Auth    │  │  Payment   │  │    Property     │     │   │
│  │  │Repository │  │ Repository │  │   Repository    │     │   │
│  │  └─────┬─────┘  └─────┬──────┘  └────────┬────────┘     │   │
│  └────────┼──────────────┼──────────────────┼──────────────┘   │
│           │              │                  │                   │
└───────────┼──────────────┼──────────────────┼───────────────────┘
            │              │                  │
┌───────────▼──────────────▼──────────────────▼───────────────────┐
│                         DATA LAYER                               │
│  ┌────────────────────┐          ┌──────────────────────┐        │
│  │  Remote Data       │          │  Local Data Source   │        │
│  │  Source (API)      │◄────────►│  (Cache & Storage)   │        │
│  │  ┌──────────────┐  │          │  ┌────────────────┐  │        │
│  │  │ API Client   │  │          │  │ Hive Database  │  │        │
│  │  │ (Dio)        │  │          │  │ SecureStorage  │  │        │
│  │  └──────┬───────┘  │          │  │ SharedPrefs    │  │        │
│  └─────────┼──────────┘          └──────────────────────┘        │
└────────────┼─────────────────────────────────────────────────────┘
             │
             │ HTTP/HTTPS
             │
┌────────────▼─────────────────────────────────────────────────────┐
│                    LARAVEL BACKEND (API)                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │ Controllers  │  │   Models     │  │   Database   │           │
│  │    (API)     │  │  (Eloquent)  │  │   (MySQL)    │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
└───────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Authentication Flow

```
┌──────────────┐
│    User      │
└──────┬───────┘
       │ Opens App
       ▼
┌──────────────────┐
│  App Launches    │
└──────┬───────────┘
       │
       ▼
┌─────────────────────────┐
│  AuthProvider.          │
│  checkAuthStatus()      │
└──────┬──────────────────┘
       │
       ▼
    ┌──┴──┐
    │Token│ No
    │Exist│────────────────────┐
    │ ?   │                    │
    └──┬──┘                    │
       │Yes                    ▼
       ▼                ┌──────────────┐
┌────────────────┐      │ Show Login   │
│ Fetch User     │      │   Screen     │
│ from Cache     │      └──────┬───────┘
└──────┬─────────┘             │
       │                       │ User enters
       ▼                       │ credentials
┌────────────────┐             │
│ Validate Token │             ▼
│ with API       │      ┌─────────────────┐
└──────┬─────────┘      │ POST /api/login │
       │                └──────┬──────────┘
    ┌──┴───┐                   │
    │Valid?│ No─────────┐      │
    └──┬───┘            │      ▼
       │Yes             │ ┌──────────────┐
       ▼                │ │  Receive     │
┌────────────────┐      │ │  Token +     │
│ Load User Role │      │ │  User Data   │
└──────┬─────────┘      │ └──────┬───────┘
       │                │        │
       ▼                │        ▼
┌────────────────┐      │ ┌──────────────┐
│ Route Based on │◄─────┘ │ Save Token & │
│ Role:          │        │  User Data   │
│ • Admin → /admin│       └──────────────┘
│ • Landlord → /landlord│
│ • Tenant → /tenant   │
└─────────────────────┘
```

---

## 📱 Role-Based Navigation Structure

### Admin Navigation
```
┌───────────────────────────────────────────┐
│          Admin Dashboard                  │
└───────────────────────────────────────────┘
                    │
        ┌───────────┼───────────┬───────────┐
        │           │           │           │
        ▼           ▼           ▼           ▼
┌──────────┐  ┌─────────┐  ┌────────┐  ┌─────────┐
│ Reports  │  │Payments │  │ Tenant │  │Settings │
│          │  │Approvals│  │  Mgmt  │  │         │
└────┬─────┘  └─────────┘  └────────┘  └─────────┘
     │
     ├─ Financial Report
     ├─ Tenant Activity
     ├─ Occupancy Report
     └─ P&L Statement
```

### Landlord Navigation
```
┌───────────────────────────────────────────┐
│        Landlord Dashboard                 │
└───────────────────────────────────────────┘
                    │
        ┌───────────┼───────────┬───────────┐
        │           │           │           │
        ▼           ▼           ▼           ▼
┌──────────┐  ┌─────────┐  ┌────────┐  ┌─────────┐
│Properties│  │ Tenants │  │Payments│  │ Reports │
└────┬─────┘  └─────────┘  └────────┘  └─────────┘
     │
     ├─ Property List
     ├─ Add Property
     ├─ Property Details
     │  ├─ Units
     │  ├─ Images
     │  └─ Tenants
     └─ Property Reports
```

### Tenant Navigation
```
┌───────────────────────────────────────────┐
│          Tenant Dashboard                 │
└───────────────────────────────────────────┘
                    │
        ┌───────────┼───────────┬───────────┐
        │           │           │           │
        ▼           ▼           ▼           ▼
┌──────────┐  ┌─────────┐  ┌────────┐  ┌─────────┐
│Pay Rent  │  │ History │  │  Lease │  │  Alerts │
└──────────┘  └─────────┘  └────────┘  └─────────┘
     │
     ├─ Make Payment
     ├─ Payment Status
     └─ View Receipts
```

---

## 💳 Payment Approval Flow (Admin/Landlord)

```
┌──────────────┐
│   Tenant     │
│ Makes Payment│
└──────┬───────┘
       │ POST /api/payments
       ▼
┌──────────────────┐
│  Payment saved   │
│ status: pending  │
└──────┬───────────┘
       │
       ▼
┌──────────────────────┐
│  Notification sent   │
│  to Admin/Landlord   │
└──────┬───────────────┘
       │
       ▼
┌────────────────────────┐
│ Admin/Landlord views   │
│ pending payments list  │
└──────┬─────────────────┘
       │
       ▼
┌─────────────────────┐
│ Review payment      │
│ details             │
└──────┬──────────────┘
       │
    ┌──┴───┐
    │Action│
    └──┬───┘
       │
  ┌────┴────┐
  │         │
  ▼         ▼
Approve   Reject
  │         │
  │         └─────┐
  ▼               ▼
POST           POST
/api/payments  /api/payments
/{id}/verify   /{id}/reject
  │               │
  ▼               ▼
status:         status:
'paid'         'rejected'
  │               │
  └───────┬───────┘
          ▼
  ┌──────────────┐
  │ Notification │
  │ sent to      │
  │ Tenant       │
  └──────────────┘
```

---

## 🔄 State Management Flow (Provider)

```
┌──────────────────────┐
│      UI Widget       │
│   (Screen/Widget)    │
└──────┬───────────────┘
       │
       │ 1. User Action
       │    (button tap, etc)
       ▼
┌──────────────────────┐
│     Provider         │
│   (State Manager)    │
└──────┬───────────────┘
       │
       │ 2. Call Repository
       │
       ▼
┌──────────────────────┐
│    Repository        │
└──────┬───────────────┘
       │
       │ 3. Fetch Data
       │
       ▼
┌──────────────────────┐
│    API Client        │
│    (Dio/HTTP)        │
└──────┬───────────────┘
       │
       │ 4. HTTP Request
       │
       ▼
┌──────────────────────┐
│   Laravel API        │
│  (Backend Server)    │
└──────┬───────────────┘
       │
       │ 5. JSON Response
       │
       ▼
┌──────────────────────┐
│    API Client        │
│  (Parse Response)    │
└──────┬───────────────┘
       │
       │ 6. Return Model
       │
       ▼
┌──────────────────────┐
│    Repository        │
│  (Optional Cache)    │
└──────┬───────────────┘
       │
       │ 7. Return Data
       │
       ▼
┌──────────────────────┐
│     Provider         │
│  (Update State)      │
└──────┬───────────────┘
       │
       │ 8. notifyListeners()
       │
       ▼
┌──────────────────────┐
│    UI Widget         │
│   (Rebuild with      │
│    new data)         │
└──────────────────────┘
```

---

## 🗄️ Data Model Relationships

```
┌──────────────┐
│    User      │
│  ──────────  │
│  id          │
│  name        │◄───────┐
│  email       │        │
│  roles[]     │        │
└──────┬───────┘        │
       │                │
       │ 1:N            │ N:1
       │                │
       ▼                │
┌──────────────┐        │
│   Property   │        │
│  ──────────  │        │
│  id          │        │
│  name        │        │
│  address     │        │
│  landlord_id ├────────┘
└──────┬───────┘
       │
       │ 1:N
       │
       ▼
┌──────────────┐        ┌──────────────┐
│    Lease     │        │   Payment    │
│  ──────────  │        │  ──────────  │
│  id          │        │  id          │
│  property_id │        │  tenant_id   │
│  tenant_id   ├───────►│  property_id │
│  start_date  │   1:N  │  amount      │
│  end_date    │        │  status      │
│  rent_amount │        │  date        │
└──────────────┘        └──────────────┘
```

---

## 🔒 Security Architecture

```
┌───────────────────────────────────────────────────┐
│               Mobile App (Flutter)                 │
│  ┌──────────────────────────────────────────────┐ │
│  │         1. User Login                        │ │
│  │  ┌──────────────────────────────────────┐   │ │
│  │  │ Email + Password                     │   │ │
│  │  └────────────────┬─────────────────────┘   │ │
│  └───────────────────┼──────────────────────────┘ │
└────────────────────┼┼┘                            
                     ││
          HTTPS/TLS  ││
                     ││
┌────────────────────▼▼───────────────────────────┐
│            2. Laravel Backend                    │
│  ┌────────────────────────────────────────────┐ │
│  │ Laravel Sanctum Authentication            │ │
│  │  • Validate credentials                   │ │
│  │  • Check user roles (Spatie Permission)   │ │
│  │  • Generate API token                     │ │
│  └────────────────┬───────────────────────────┘ │
└───────────────────┼──────────────────────────────┘
                    │
                    ▼
┌────────────────────────────────────────────────┐
│        3. Return Token + User Data             │
│  {                                             │
│    "token": "1|abc123...",                     │
│    "user": {                                   │
│      "id": 1,                                  │
│      "name": "John Doe",                       │
│      "roles": [{"name": "tenant"}]             │
│    }                                           │
│  }                                             │
└────────────────┬───────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│          4. Store Securely                      │
│  ┌────────────────────────────────────────────┐ │
│  │ FlutterSecureStorage (Encrypted)          │ │
│  │  • auth_token: "1|abc123..."              │ │
│  └────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────┐ │
│  │ SharedPreferences (User Data)             │ │
│  │  • user_data: {name, roles, etc}          │ │
│  └────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│      5. Subsequent API Requests                 │
│  Header: Authorization: Bearer 1|abc123...      │
│  ┌────────────────────────────────────────────┐ │
│  │ All requests include token                │ │
│  │ Backend validates token before response   │ │
│  └────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

---

## 📊 Dashboard Data Flow

```
┌────────────────────────────────────────┐
│     Dashboard Screen Mounted           │
└───────────────┬────────────────────────┘
                │
                ▼
┌───────────────────────────────────────┐
│  DashboardProvider.fetchDashboard()   │
└───────────────┬───────────────────────┘
                │
        ┌───────┼───────┬───────┐
        │       │       │       │
        ▼       ▼       ▼       ▼
    ┌──────┐ ┌────┐ ┌────┐ ┌─────┐
    │Stats │ │ Props│ │Tena│ │Paym │
    │ API  │ │ API │ │ API│ │ API │
    └──┬───┘ └──┬─┘ └──┬─┘ └──┬──┘
       │        │      │      │
       └────────┴──────┴──────┘
                │
                ▼
    ┌────────────────────────┐
    │  Aggregate Results     │
    │  {                     │
    │    properties: 25,     │
    │    tenants: 42,        │
    │    payments: 18,       │
    │    revenue: $12,450    │
    │  }                     │
    └───────────┬────────────┘
                │
                ▼
    ┌────────────────────────┐
    │  Update Provider State │
    │  notifyListeners()     │
    └───────────┬────────────┘
                │
                ▼
    ┌────────────────────────┐
    │  UI Rebuilds           │
    │  Display Dashboard     │
    │  Cards & Charts        │
    └────────────────────────┘
```

---

## 🌐 Offline Caching Strategy

```
                    API Request
                        │
                        ▼
              ┌──────────────────┐
              │ Check Connectivity│
              └──────┬────────────┘
                     │
              ┌──────┴──────┐
              │             │
         Online          Offline
              │             │
              ▼             ▼
     ┌─────────────┐  ┌──────────┐
     │Fetch from   │  │Fetch from│
     │  Backend    │  │  Cache   │
     └──────┬──────┘  └─────┬────┘
            │               │
            ▼               │
     ┌─────────────┐        │
     │ Save to     │        │
     │  Cache      │        │
     │  (Hive)     │        │
     └──────┬──────┘        │
            │               │
            └───────┬───────┘
                    │
                    ▼
            ┌───────────────┐
            │Return Data to │
            │   UI          │
            └───────────────┘
```

---

These diagrams provide a visual understanding of how different components interact in the Flutter Rental Management App. Use them as reference while building your application.

For code implementation, refer to:
- [FLUTTER_APP_DEVELOPMENT_GUIDE.md](./FLUTTER_APP_DEVELOPMENT_GUIDE.md)
- [CODE_EXAMPLES.md](./CODE_EXAMPLES.md)

