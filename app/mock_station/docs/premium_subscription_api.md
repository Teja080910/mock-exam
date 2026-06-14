# Premium Subscription API Documentation

## 1. Overview
The Premium Subscription system manages access to mock tests (quizzes) based on user-purchased plans. Mock tests are categorized into specific exam types (e.g., **Railway**, **SSC**, Banking, etc.). 

### Key Rules:
- A user must have an active subscription for a category to access its mock tests.
- Users can purchase a single category plan, multiple category plans, or a "Master Plan" (All Categories).
- **Access Restiction**: If a category is not included in the user's active plan, all mock tests under that category must remain locked and inaccessible.

---

## 2. Authentication
All endpoints require a valid JWT Bearer Token.
- **Header**: `Authorization: Bearer <token>`

---

## 3. Subscription Plans

### Fetch Available Plans
**Endpoint**: `POST /api/get_plan`  
**Description**: Fetches all available subscription plans. Plans can be category-specific or multi-category.

**Response Structure**:
```json
{
  "success": 1,
  "data": {
    "planDetails": [
      {
        "_id": "65b...",
        "name": "Railway Premium Mock Pack",
        "description": "Access to all Railway (NTPC, Group D, ALP) tests",
        "categoryId": ["railway_id"],
        "price": 299,
        "durationDays": 30,
        "isSelectedAll": false
      },
      {
        "_id": "65c...",
        "name": "SSC Complete Series",
        "description": "Access to SSC CGL, CHSL, MTS, GD tests",
        "categoryId": ["ssc_id"],
        "price": 349,
        "durationDays": 30,
        "isSelectedAll": false
      },
      {
        "_id": "65d...",
        "name": "Master Subscription",
        "description": "Full access to ALL categories (SSC, Railway, etc.)",
        "categoryId": [],
        "price": 999,
        "durationDays": 365,
        "isSelectedAll": true
      }
    ]
  }
}
```

---

## 4. Plan Purchase Flow (Razorpay)

### Step 1: Initialize Purchase (Buy Test)
**Endpoint**: `POST /api/buyTest`  
**Description**: Creates a Razorpay order for the selected categories.

**Request Body**:
```json
{
  "categoryId": ["ssc_id", "railway_id"],
  "isSelectedAll": false
}
```

**Response Structure**:
```json
{
  "success": true,
  "orderId": "order_KvkL12345",
  "amount": 499,
  "currency": "INR"
}
```

### Step 2: Verify Payment
**Endpoint**: `POST /api/verifyPayment`  
**Description**: Validates the Razorpay transaction and activates the categories in the user's profile.

**Request Body**:
```json
{
  "razorpay_payment_id": "pay_KvkM...",
  "razorpay_order_id": "order_KvkL...",
  "razorpay_signature": "596a..."
}
```

**Response Structure**:
```json
{
  "success": true,
  "planStatus": "active",
  "message": "Plan activated for selected categories."
}
```

---

## 5. User Subscription Status

### Fetch Current Active Plan
**Endpoint**: `POST /api/fetchUserPlan`  
**Description**: Returns the user's current subscription status and allowed categories.

**Response Structure**:
```json
{
  "success": true,
  "planStatus": "active",
  "isSelectedAll": false,
  "categoryId": ["railway_id"],
  "price": 299,
  "expiryDate": "2024-12-31T23:59:59Z"
}
```

---

## 6. Access Control Rules (IMPORTANT)

### 6.1 Mock Test List Logic
When the app calls `getquizbysubcategory`, the backend MUST identify if the user is authorized.

**Logic for Backend**:
1. If `user.isSelectedAll == true` -> **UNLOCK ALL**
2. If `quiz.categoryId` is in `user.categoryId` -> **UNLOCK**
3. If `quiz.isFree == true` -> **UNLOCK**
4. Else -> **LOCK (Return isUnlocked: false)**

**Response Structure for `getquizbysubcategory`**:
```json
{
  "quizzes": [
    {
      "_id": "q1",
      "name": "Railway Group D - Math Mock",
      "isUnlocked": true 
    },
    {
      "_id": "q2",
      "name": "SSC CGL - English Tier 1",
      "isUnlocked": false
    }
  ]
}
```

### 6.2 Frontend Restriction
If `isUnlocked` is `false`, the "Start Test" button should be disabled or replaced with a "Locked / Upgrade Plan" button that redirects to the `UserPlanScreen`.

---

## 7. Plan History
**Endpoint**: `POST /api/plan_history`  
**Description**: Returns all past plan purchases for the user.

