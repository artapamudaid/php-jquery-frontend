CREATE DATABASE IF NOT EXISTS client_side_processing_demo
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE client_side_processing_demo;

DROP TABLE IF EXISTS imported_customers;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS provinces;
DROP TABLE IF EXISTS sales_reps;

CREATE TABLE imported_customers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    external_id VARCHAR(50) NOT NULL,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(40) NULL,
    city VARCHAR(100) NULL,
    registered_at DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_imported_customers_external_id (external_id),
    KEY idx_imported_customers_email (email)
) ENGINE=InnoDB;

CREATE TABLE provinces (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE cities (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    province_id INT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    KEY idx_cities_province_id (province_id),
    CONSTRAINT fk_cities_province
        FOREIGN KEY (province_id) REFERENCES provinces(id)
) ENGINE=InnoDB;

CREATE TABLE customers (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    city_id INT UNSIGNED NOT NULL,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    segment ENUM('Retail', 'SME', 'Enterprise') NOT NULL,
    KEY idx_customers_city_id (city_id),
    CONSTRAINT fk_customers_city
        FOREIGN KEY (city_id) REFERENCES cities(id)
) ENGINE=InnoDB;

CREATE TABLE sales_reps (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    region VARCHAR(80) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE categories (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE products (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id INT UNSIGNED NOT NULL,
    sku VARCHAR(40) NOT NULL,
    name VARCHAR(150) NOT NULL,
    unit_price DECIMAL(14,2) NOT NULL,
    UNIQUE KEY uq_products_sku (sku),
    KEY idx_products_category_id (category_id),
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
) ENGINE=InnoDB;

CREATE TABLE orders (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED NOT NULL,
    sales_rep_id INT UNSIGNED NOT NULL,
    order_number VARCHAR(40) NOT NULL,
    order_date DATE NOT NULL,
    discount_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
    shipping_cost DECIMAL(14,2) NOT NULL DEFAULT 0,
    UNIQUE KEY uq_orders_order_number (order_number),
    KEY idx_orders_order_date (order_date),
    KEY idx_orders_customer_id (customer_id),
    KEY idx_orders_sales_rep_id (sales_rep_id),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(id),
    CONSTRAINT fk_orders_sales_rep
        FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(id)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(14,2) NOT NULL,
    KEY idx_order_items_order_id (order_id),
    KEY idx_order_items_product_id (product_id),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(id),
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

INSERT INTO provinces (id, name) VALUES
(1, 'DKI Jakarta'),
(2, 'Jawa Barat'),
(3, 'Jawa Timur');

INSERT INTO cities (id, province_id, name) VALUES
(1, 1, 'Jakarta Selatan'),
(2, 1, 'Jakarta Barat'),
(3, 2, 'Bandung'),
(4, 2, 'Bekasi'),
(5, 3, 'Surabaya'),
(6, 3, 'Malang');

INSERT INTO customers (id, city_id, name, email, segment) VALUES
(1, 1, 'PT Sinar Data Nusantara', 'finance@sinar-data.test', 'Enterprise'),
(2, 3, 'Koperasi Maju Bersama', 'admin@majubersama.test', 'SME'),
(3, 5, 'CV Prima Retailindo', 'orders@primaretail.test', 'Retail'),
(4, 4, 'PT Lintas Gudang', 'procurement@lintasgudang.test', 'Enterprise'),
(5, 6, 'Toko Cakrawala', 'owner@cakrawala.test', 'Retail');

INSERT INTO sales_reps (id, name, region) VALUES
(1, 'Ayu Lestari', 'Jabodetabek'),
(2, 'Bima Prakoso', 'Jawa Barat'),
(3, 'Citra Wulandari', 'Jawa Timur');

INSERT INTO categories (id, name) VALUES
(1, 'Hardware'),
(2, 'Software'),
(3, 'Service'),
(4, 'Consumable');

INSERT INTO products (id, category_id, sku, name, unit_price) VALUES
(1, 1, 'HW-NAS-4BAY', 'NAS 4 Bay', 7200000),
(2, 1, 'HW-RTR-AX', 'Router AX Enterprise', 1850000),
(3, 2, 'SW-ERP-STD', 'ERP Standard License', 3500000),
(4, 2, 'SW-SEC-END', 'Endpoint Security', 420000),
(5, 3, 'SRV-IMPL', 'Implementation Service', 8500000),
(6, 3, 'SRV-TRAIN', 'User Training', 2500000),
(7, 4, 'CNS-CABLE-CAT6', 'Cable CAT6 Box', 950000),
(8, 4, 'CNS-LABEL', 'Asset Label Pack', 175000);

INSERT INTO orders (id, customer_id, sales_rep_id, order_number, order_date, discount_amount, shipping_cost) VALUES
(1, 1, 1, 'ORD-2026-0001', '2026-01-12', 500000, 250000),
(2, 2, 2, 'ORD-2026-0002', '2026-01-18', 0, 125000),
(3, 3, 3, 'ORD-2026-0003', '2026-02-03', 150000, 90000),
(4, 4, 1, 'ORD-2026-0004', '2026-02-14', 750000, 300000),
(5, 5, 3, 'ORD-2026-0005', '2026-03-01', 0, 80000),
(6, 1, 1, 'ORD-2026-0006', '2026-03-22', 250000, 200000),
(7, 2, 2, 'ORD-2026-0007', '2026-04-05', 100000, 120000),
(8, 4, 1, 'ORD-2026-0008', '2026-04-19', 300000, 275000);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 2, 7200000),
(1, 3, 5, 3500000),
(1, 5, 1, 8500000),
(2, 2, 3, 1850000),
(2, 7, 2, 950000),
(3, 4, 20, 420000),
(3, 8, 10, 175000),
(4, 1, 4, 7200000),
(4, 2, 4, 1850000),
(4, 6, 2, 2500000),
(5, 7, 1, 950000),
(5, 8, 4, 175000),
(6, 3, 3, 3500000),
(6, 4, 30, 420000),
(7, 2, 2, 1850000),
(7, 6, 1, 2500000),
(8, 1, 1, 7200000),
(8, 5, 1, 8500000),
(8, 6, 3, 2500000);
