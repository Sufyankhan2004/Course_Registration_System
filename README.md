# course_registration_system

A new Flutter project.

## Getting Started

Before running the app, you must configure Supabase credentials. The session guard relies on a Supabase session to route the user to the correct dashboard; missing credentials leave the app on the loading indicator.

1. Create a `.env` file or update your launch configuration with these values:
	- `SUPABASE_URL`
	- `SUPABASE_ANON_KEY`
2. Pass them to Flutter with `--dart-define` flags, for example:
	```bash
	flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=public-anon-key
	```
3. Ensure the Supabase project has a `profiles` table with columns `id`, `name`, `email`, and `role`.

Once configured, run the app normally. If there is any startup failure, the splash screen now reports the error and offers a retry button.
