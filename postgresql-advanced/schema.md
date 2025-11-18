# Database Schema Diagram

## Entity Relationship Diagram

```mermaid
erDiagram
    users ||--o{ orders : places
    users ||--o{ reviews : writes
    orders ||--|{ order_items : contains
    products ||--o{ order_items : "ordered in"
    products ||--o{ reviews : "reviewed in"

    users {
        uuid user_id PK
        varchar username UK
        varchar email UK
        varchar full_name
        user_status status
        jsonb preferences
        jsonb metadata
        timestamp created_at
        timestamp updated_at
        timestamp last_login
    }

    products {
        uuid product_id PK
        varchar sku UK
        varchar name
        text description
        varchar category
        numeric price
        integer stock_quantity
        jsonb attributes
        timestamp created_at
        timestamp updated_at
    }

    orders {
        uuid order_id PK
        uuid user_id FK
        varchar order_number UK
        order_status status
        numeric total_amount
        jsonb shipping_address
        timestamp created_at
        timestamp updated_at
        timestamp shipped_at
        timestamp delivered_at
    }

    order_items {
        uuid order_item_id PK
        uuid order_id FK
        uuid product_id FK
        integer quantity
        numeric unit_price
        numeric subtotal "computed"
        timestamp created_at
    }

    reviews {
        uuid review_id PK
        uuid product_id FK
        uuid user_id FK
        integer rating
        varchar title
        text comment
        integer helpful_count
        timestamp created_at
        timestamp updated_at
    }

    audit_log {
        bigint log_id PK
        varchar table_name
        varchar operation
        uuid user_id
        jsonb old_data
        jsonb new_data
        timestamp changed_at
    }
```

## Index Visualization

```mermaid
graph TD
    subgraph "users table"
        U[users]
        U --> U1[idx_users_email<br/>B-tree]
        U --> U2[idx_users_status<br/>B-tree]
        U --> U3[idx_users_preferences<br/>GIN]
        U --> U4[idx_active_users<br/>Partial]
    end

    subgraph "products table"
        P[products]
        P --> P1[idx_products_category<br/>B-tree]
        P --> P2[idx_products_price<br/>B-tree]
        P --> P3[idx_products_attributes<br/>GIN]
        P --> P4[idx_products_name_trgm<br/>GIN Trigram]
    end

    subgraph "orders table"
        O[orders]
        O --> O1[idx_orders_user_id<br/>B-tree]
        O --> O2[idx_orders_status<br/>B-tree]
        O --> O3[idx_orders_user_status<br/>Composite]
        O --> O4[idx_orders_pending<br/>Partial]
    end
```

## Trigger Flow

```mermaid
sequenceDiagram
    participant App
    participant Users
    participant Trigger
    participant AuditLog

    App->>Users: UPDATE user
    Users->>Trigger: BEFORE UPDATE
    Trigger->>Users: Set updated_at = NOW()
    Users->>Trigger: AFTER UPDATE
    Trigger->>AuditLog: INSERT audit record
    AuditLog-->>Trigger: Success
    Trigger-->>App: Update complete
```

## Order Creation Flow

```mermaid
flowchart LR
    A[create_order] --> B{Check User}
    B -->|Valid| C[Create Order]
    B -->|Invalid| X[Error]
    C --> D[Generate Order Number]
    D --> E{For Each Item}
    E --> F[Check Product Stock]
    F -->|Available| G[Insert Order Item]
    F -->|Insufficient| X
    G --> H[Update Stock]
    H --> I[Calculate Subtotal]
    I --> E
    E -->|Done| J[Update Order Total]
    J --> K[Commit Transaction]
```

## Data Flow

```mermaid
graph LR
    A[User Registration] --> B[users table]
    B --> C[Order Placement]
    C --> D[orders table]
    D --> E[order_items table]
    E --> F[Stock Update]
    F --> G[products table]
    D --> H[Review Submission]
    H --> I[reviews table]

    style B fill:#e1f5ff
    style D fill:#fff4e1
    style E fill:#fff4e1
    style G fill:#e8f5e9
    style I fill:#fce4ec
```

## Query Performance by Index Type

```mermaid
gantt
    title Query Performance Comparison (lower is better)
    dateFormat X
    axisFormat %s ms

    section Equality Search
    Without Index :0, 150
    B-tree Index :0, 5

    section Range Query
    Without Index :0, 200
    B-tree Index :0, 15

    section JSONB Query
    Without Index :0, 300
    GIN Index :0, 20

    section Full-Text Search
    LIKE Query :0, 250
    GIN Trigram :0, 30
```

## Table Relationships Summary

| Parent Table | Child Table | Relationship | Constraint |
|--------------|-------------|--------------|------------|
| users | orders | 1:N | ON DELETE CASCADE |
| users | reviews | 1:N | ON DELETE CASCADE |
| products | order_items | 1:N | ON DELETE RESTRICT |
| products | reviews | 1:N | ON DELETE CASCADE |
| orders | order_items | 1:N | ON DELETE CASCADE |

## Indexes Summary

| Table | Index Name | Type | Columns | Purpose |
|-------|-----------|------|---------|---------|
| users | idx_users_email | B-tree | email | Fast email lookup |
| users | idx_users_preferences | GIN | preferences | JSONB queries |
| users | idx_active_users | Partial B-tree | last_login WHERE status='active' | Active user queries |
| products | idx_products_price | B-tree | price | Price range queries |
| products | idx_products_attributes | GIN | attributes | JSONB attribute search |
| products | idx_products_name_trgm | GIN Trigram | name | Full-text search |
| orders | idx_orders_user_status | Composite B-tree | user_id, status | User order filtering |
| orders | idx_orders_pending | Partial B-tree | created_at WHERE status='pending' | Pending orders |

## Triggers Summary

| Trigger Name | Table | Event | Function | Purpose |
|--------------|-------|-------|----------|---------|
| update_users_updated_at | users | BEFORE UPDATE | update_updated_at_column() | Auto-update timestamp |
| audit_users | users | AFTER INSERT/UPDATE/DELETE | audit_trigger_function() | Audit logging |
| check_stock_before_order | order_items | BEFORE INSERT | check_product_stock() | Stock validation |
| order_status_timestamp | orders | BEFORE UPDATE | update_order_timestamps() | Status timestamp tracking |
