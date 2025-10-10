-- Создание таблицы cities
CREATE TABLE IF NOT EXISTS cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    population INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание индексов
CREATE INDEX IF NOT EXISTS idx_cities_name ON cities(name);
CREATE INDEX IF NOT EXISTS idx_cities_country ON cities(country);

-- Вставка тестовых данных
INSERT INTO cities (name, country, population) VALUES 
('Moscow', 'Russia', 12615000),
('Saint Petersburg', 'Russia', 5383000),
('Novosibirsk', 'Russia', 1625000),
('Yekaterinburg', 'Russia', 1495000),
('Kazan', 'Russia', 1257000)
ON CONFLICT DO NOTHING;
