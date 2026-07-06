-- =========================================================================
-- Supabase Schema for Smart Coach AVI Migration
-- =========================================================================
-- Execute this script in the Supabase SQL Editor to create all necessary
-- tables, indexes, and setup Realtime.

-- 1. Odour Management
CREATE TABLE IF NOT EXISTS odour_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sensor_id TEXT UNIQUE NOT NULL,
    coach_number TEXT NOT NULL,
    level NUMERIC,
    status TEXT,
    battery_voltage NUMERIC,
    remarks TEXT,
    last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Water Level Indicator
CREATE TABLE IF NOT EXISTS water_level_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sensor_id TEXT UNIQUE NOT NULL,
    coach_number TEXT NOT NULL,
    tank_name TEXT,
    water_level NUMERIC,
    status TEXT,
    last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Level Indicator (General Sensors)
CREATE TABLE IF NOT EXISTS level_indicator_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sensor_id TEXT UNIQUE NOT NULL,
    coach_number TEXT NOT NULL,
    device_name TEXT,
    status TEXT,
    battery_status TEXT,
    alarm_status TEXT,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Hot Axle Detection
CREATE TABLE IF NOT EXISTS hot_axle_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sensor_id TEXT UNIQUE NOT NULL,
    coach_number TEXT NOT NULL,
    axle_number TEXT,
    temperature NUMERIC,
    status TEXT,
    last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Diesel Tank Fuel Monitoring
CREATE TABLE IF NOT EXISTS diesel_tank_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sensor_id TEXT UNIQUE NOT NULL,
    coach_number TEXT NOT NULL,
    fuel_level NUMERIC,
    status TEXT,
    last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- 6. BC Pressure
CREATE TABLE IF NOT EXISTS bc_pressure_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sensor_id TEXT UNIQUE NOT NULL,
    coach_number TEXT NOT NULL,
    pressure NUMERIC,
    brake_applied TEXT,
    brake_released TEXT,
    status TEXT,
    last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Break Binding
CREATE TABLE IF NOT EXISTS break_binding_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sensor_id TEXT UNIQUE NOT NULL,
    coach_number TEXT NOT NULL,
    brake_status TEXT,
    brake_fault TEXT,
    last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- 8. FSDS (Fire and Smoke Detection System)
CREATE TABLE IF NOT EXISTS fsds_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sensor_id TEXT UNIQUE NOT NULL,
    coach_number TEXT NOT NULL,
    device_name TEXT,
    location TEXT,
    alert_status BOOLEAN DEFAULT FALSE,
    bypass_status BOOLEAN DEFAULT FALSE,
    remarks TEXT,
    last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- 9. ACP (Alarm Chain Pulling)
CREATE TABLE IF NOT EXISTS acp_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id TEXT UNIQUE NOT NULL,
    train_no TEXT,
    comm_coach_no TEXT,
    tech_coach_no TEXT,
    train_location TEXT,
    acp_status TEXT,
    raw_asset_name TEXT,
    last_updated TIMESTAMPTZ DEFAULT NOW()
);


-- =========================================================================
-- Enable Supabase Realtime for Dashboard Subscriptions
-- =========================================================================
-- This allows `supabase.from('table').stream(...)` to work in the app.

alter publication supabase_realtime add table odour_data;
alter publication supabase_realtime add table water_level_data;
alter publication supabase_realtime add table level_indicator_data;
alter publication supabase_realtime add table hot_axle_data;
alter publication supabase_realtime add table diesel_tank_data;
alter publication supabase_realtime add table bc_pressure_data;
alter publication supabase_realtime add table break_binding_data;
alter publication supabase_realtime add table fsds_data;
alter publication supabase_realtime add table acp_data;


-- =========================================================================
-- (Optional) RLS Policies 
-- Note: Replace with actual authentication policies based on project requirements.
-- For quick dev, allowing ALL access.
-- =========================================================================
*/

-- =========================================================================
-- V2 MIGRATION: ADD U-COUNT AND F-COUNT COLUMNS
-- =========================================================================
ALTER TABLE odour_management_live 
ADD COLUMN IF NOT EXISTS u_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS f_count INTEGER DEFAULT 0;
