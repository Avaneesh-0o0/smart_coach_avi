# Supabase Migration Connection Guide

## Step 1: Create a Supabase Project
1. Go to [Supabase](https://supabase.com/) and create a new project.
2. Under project settings, find your **Project URL** and **API Key (anon/public)**.

## Step 2: Setup Database Schema
1. Open the **SQL Editor** in your Supabase dashboard.
2. Copy the contents of the `supabase_schema.sql` file provided in this repository.
3. Paste it into the editor and hit **Run** to create all tables and enable Realtime subscriptions.

## Step 3: Insert Environment Variables
Create or update your `.env` file in the root of the Flutter project (`c:\smartcoach\smart_coach_avi\.env`):

```env
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-supabase-anon-key
```
*(Make sure `.env` is listed in `pubspec.yaml` assets if you are using `flutter_dotenv`, or replace the hardcoded values in `lib/core/config/supabase_config.dart` if configured that way).*

## Step 4: Authentication Configuration
1. Go to **Authentication > Providers** in the Supabase dashboard.
2. Enable **Email/Password** sign-in (or whatever provider you were previously using).
3. If you want to port your existing Firebase users, use the [Supabase Auth Migration Tool](https://supabase.com/docs/guides/auth/managing-user-data) or write a custom script to import users via the Supabase Auth Admin API.

## Step 5: FCM Considerations
As requested, Firebase Cloud Messaging (FCM) is kept intact for push notifications.
- Ensure your `firebase_options.dart` and `google-services.json` remain in the project so FCM can initialize properly via `Firebase.initializeApp()`.
- The real-time data and authentication rely completely on Supabase now.

## Important Note: Fallback Mock Data
If your Supabase connection fails or a table is entirely empty (e.g., Odour Management), the application is programmed to gracefully fail over to offline mock data.
Once real data starts flowing into your Supabase tables (e.g. from IoT devices), the app will automatically prioritize and show that real-time data.
