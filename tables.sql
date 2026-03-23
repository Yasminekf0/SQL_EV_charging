-- EV charging network schema (3 tables: stations, users, sessions)

CREATE TABLE stations (
    station_id   INT          PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    location     VARCHAR(150) NOT NULL,
    max_kw       DECIMAL(6,2) NOT NULL,
    installed_at DATE         NOT NULL
);

CREATE TABLE users (
    user_id   INT          PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email     VARCHAR(255) NOT NULL UNIQUE,
    joined_at DATE         NOT NULL,
    is_active BOOLEAN      DEFAULT TRUE
);

CREATE TABLE sessions (
    session_id    INT          PRIMARY KEY,
    station_id    INT          NOT NULL REFERENCES stations(station_id),
    user_id       INT          NOT NULL REFERENCES users(user_id),
    started_at    TIMESTAMP    NOT NULL,
    ended_at      TIMESTAMP    NOT NULL,
    kwh_delivered DECIMAL(8,3) NOT NULL
);
