CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "accounts" ("id" uuid NOT NULL PRIMARY KEY, "name" varchar, "slug" varchar, "logo_url" varchar, "timezone" varchar, "currency" varchar, "settings" json, "status" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_accounts_on_slug" ON "accounts" ("slug") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "users" ("id" uuid NOT NULL PRIMARY KEY, "account_id" uuid NOT NULL, "name" varchar, "role" integer DEFAULT 0, "email_address" varchar NOT NULL, "password_digest" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_61ac11da2b"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_users_on_account_id" ON "users" ("account_id") /*application='AgendaAi'*/;
CREATE UNIQUE INDEX "index_users_on_account_id_and_email_address" ON "users" ("account_id", "email_address") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "sessions" ("id" uuid NOT NULL PRIMARY KEY, "user_id" uuid NOT NULL, "ip_address" varchar, "user_agent" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_758836b4f0"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_sessions_on_user_id" ON "sessions" ("user_id") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "professionals" ("id" uuid NOT NULL PRIMARY KEY, "account_id" uuid NOT NULL, "user_id" uuid, "name" varchar NOT NULL, "email" varchar, "avatar_url" varchar, "active" boolean DEFAULT TRUE NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_4f370f7e2f"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
, CONSTRAINT "fk_rails_84604d2557"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_professionals_on_account_id" ON "professionals" ("account_id") /*application='AgendaAi'*/;
CREATE INDEX "index_professionals_on_user_id" ON "professionals" ("user_id") /*application='AgendaAi'*/;
CREATE INDEX "index_professionals_on_account_id_and_email" ON "professionals" ("account_id", "email") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "services" ("id" uuid NOT NULL PRIMARY KEY, "account_id" uuid NOT NULL, "name" varchar NOT NULL, "description" text, "duration_minutes" integer DEFAULT 30 NOT NULL, "price_cents" integer DEFAULT 0 NOT NULL, "currency" varchar DEFAULT 'BRL' NOT NULL, "active" boolean DEFAULT TRUE NOT NULL, "sort_order" integer DEFAULT 0 NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_561fd4f186"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_services_on_account_id" ON "services" ("account_id") /*application='AgendaAi'*/;
CREATE INDEX "index_services_on_account_id_and_sort_order" ON "services" ("account_id", "sort_order") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "professional_services" ("id" uuid NOT NULL PRIMARY KEY, "professional_id" uuid NOT NULL, "service_id" uuid NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_bbf2eb5b6c"
FOREIGN KEY ("professional_id")
  REFERENCES "professionals" ("id")
, CONSTRAINT "fk_rails_0df2633a97"
FOREIGN KEY ("service_id")
  REFERENCES "services" ("id")
);
CREATE INDEX "index_professional_services_on_professional_id" ON "professional_services" ("professional_id") /*application='AgendaAi'*/;
CREATE INDEX "index_professional_services_on_service_id" ON "professional_services" ("service_id") /*application='AgendaAi'*/;
CREATE UNIQUE INDEX "index_professional_services_on_professional_id_and_service_id" ON "professional_services" ("professional_id", "service_id") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "work_schedules" ("id" uuid NOT NULL PRIMARY KEY, "professional_id" uuid NOT NULL, "day_of_week" integer NOT NULL, "start_time" time NOT NULL, "end_time" time NOT NULL, "break_start" time, "break_end" time, "enabled" boolean DEFAULT TRUE NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_0b65627a0f"
FOREIGN KEY ("professional_id")
  REFERENCES "professionals" ("id")
);
CREATE INDEX "index_work_schedules_on_professional_id" ON "work_schedules" ("professional_id") /*application='AgendaAi'*/;
CREATE UNIQUE INDEX "index_work_schedules_on_professional_id_and_day_of_week" ON "work_schedules" ("professional_id", "day_of_week") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "schedule_exceptions" ("id" uuid NOT NULL PRIMARY KEY, "professional_id" uuid NOT NULL, "exception_date" date NOT NULL, "is_blocked" boolean DEFAULT TRUE NOT NULL, "start_time" time, "end_time" time, "reason" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_90d372bacc"
FOREIGN KEY ("professional_id")
  REFERENCES "professionals" ("id")
);
CREATE INDEX "index_schedule_exceptions_on_professional_id" ON "schedule_exceptions" ("professional_id") /*application='AgendaAi'*/;
CREATE INDEX "idx_on_professional_id_exception_date_466f4d3f26" ON "schedule_exceptions" ("professional_id", "exception_date") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "clients" ("id" uuid NOT NULL PRIMARY KEY, "account_id" uuid NOT NULL, "name" varchar NOT NULL, "email" varchar, "phone" varchar, "notes" text, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_bed59fd791"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_clients_on_account_id" ON "clients" ("account_id") /*application='AgendaAi'*/;
CREATE INDEX "index_clients_on_account_id_and_email" ON "clients" ("account_id", "email") /*application='AgendaAi'*/;
CREATE INDEX "index_clients_on_account_id_and_phone" ON "clients" ("account_id", "phone") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "appointments" ("id" uuid NOT NULL PRIMARY KEY, "account_id" uuid NOT NULL, "professional_id" uuid NOT NULL, "service_id" uuid NOT NULL, "client_id" uuid NOT NULL, "starts_at" datetime(6) NOT NULL, "ends_at" datetime(6) NOT NULL, "status" integer DEFAULT 0 NOT NULL, "price_cents" integer DEFAULT 0 NOT NULL, "cancellation_reason" varchar, "notes" text, "metadata" json, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_aa14456f23"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
, CONSTRAINT "fk_rails_e6009ecf68"
FOREIGN KEY ("professional_id")
  REFERENCES "professionals" ("id")
, CONSTRAINT "fk_rails_486091c262"
FOREIGN KEY ("service_id")
  REFERENCES "services" ("id")
, CONSTRAINT "fk_rails_6497fe64e8"
FOREIGN KEY ("client_id")
  REFERENCES "clients" ("id")
);
CREATE INDEX "index_appointments_on_account_id" ON "appointments" ("account_id") /*application='AgendaAi'*/;
CREATE INDEX "index_appointments_on_professional_id" ON "appointments" ("professional_id") /*application='AgendaAi'*/;
CREATE INDEX "index_appointments_on_service_id" ON "appointments" ("service_id") /*application='AgendaAi'*/;
CREATE INDEX "index_appointments_on_client_id" ON "appointments" ("client_id") /*application='AgendaAi'*/;
CREATE INDEX "idx_on_account_id_professional_id_starts_at_e3091553de" ON "appointments" ("account_id", "professional_id", "starts_at") /*application='AgendaAi'*/;
CREATE INDEX "idx_on_professional_id_starts_at_ends_at_240872b2f4" ON "appointments" ("professional_id", "starts_at", "ends_at") /*application='AgendaAi'*/;
CREATE INDEX "index_appointments_on_account_id_and_status" ON "appointments" ("account_id", "status") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "subscriptions" ("id" uuid NOT NULL PRIMARY KEY, "account_id" uuid NOT NULL, "plan_interval" integer DEFAULT 0 NOT NULL, "status" integer DEFAULT 0 NOT NULL, "stripe_customer_id" varchar, "stripe_subscription_id" varchar, "stripe_price_id" varchar, "current_period_start" datetime(6), "current_period_end" datetime(6), "cancel_at_period_end" boolean DEFAULT FALSE NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_eb0e3ffd90"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE UNIQUE INDEX "index_subscriptions_on_account_id" ON "subscriptions" ("account_id") /*application='AgendaAi'*/;
CREATE INDEX "index_subscriptions_on_stripe_customer_id" ON "subscriptions" ("stripe_customer_id") /*application='AgendaAi'*/;
CREATE INDEX "index_subscriptions_on_stripe_subscription_id" ON "subscriptions" ("stripe_subscription_id") /*application='AgendaAi'*/;
CREATE INDEX "index_subscriptions_on_status" ON "subscriptions" ("status") /*application='AgendaAi'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20260829150000'),
('20260829140602'),
('20260829140601'),
('20260829140600'),
('20260829140559'),
('20260829140547'),
('20260829140546'),
('20260829140545'),
('20260829140441'),
('20260829140440'),
('20260829140354');

