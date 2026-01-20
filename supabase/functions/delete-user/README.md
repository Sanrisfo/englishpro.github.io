# Edge Function: delete-user

This function deletes a user from Supabase Authentication.

## Deployment

1.  **Install Supabase CLI:**
    If you don't have it, install it using npm:
    ```bash
    npm i supabase@1.131.2 --save-dev
    ```

2.  **Link your project:**
    ```bash
    npx supabase link --project-ref <your-project-ref>
    ```
    You can get your project reference from the URL of your Supabase dashboard.

3.  **Deploy the function:**
    ```bash
    npx supabase functions deploy delete-user
    ```

## Environment Variables

This function requires the following environment variables to be set in your Supabase project:

-   `SUPABASE_URL`: Your project's Supabase URL.
-   `SUPABASE_SERVICE_ROLE_KEY`: Your project's service role key.

You can set them by running:
```bash
npx supabase secrets set SUPABASE_URL=<your-supabase-url>
npx supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<your-supabase-service-role-key>
```

You can find these keys in your Supabase project's "API" settings.

## Invocation

You can call this function from your client-side code like this:

```dart
final response = await supabase.functions.invoke(
  'delete-user',
  body: {'user_id': supabaseUid},
);

if (response.error != null) {
  // Handle error
}
```
