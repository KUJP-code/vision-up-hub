# Cross-domain sign in

`hub.kids-up.app`, `vision-up.app`, and `www.vision-up.app` use separate browser cookies. A login-page visit on HTTPS checks the other hosts for an existing session and returns to the original host. Devise retains the requested path, query string, and locale in the original session, so a shared lesson link opens that lesson after either a handoff or normal password login.

The handoff uses a signed request bound to a random state in the destination browser session. The source issues a one-use grant that expires after one minute; only digests are stored in the shared database. Redemption locks and deletes the grant and rechecks account status and the password fingerprint. Endpoints use `Cache-Control: no-store` and `Referrer-Policy: no-referrer`, and token parameters are covered by the existing log filters.

The destination still applies lesson permissions, privacy policy acceptance, device approval, school IP restrictions, and password expiration. Existing sessions on the destination take precedence. Sign-out continues to affect that domain's session; another domain's session remains available for a later sign-in handoff.

## Deployment

Run `bin/rails db:migrate` before serving the new code. All three hosts must serve the same application, database, and Rails secret key. No DNS or cookie-domain changes are needed. Non-production hostnames keep the ordinary login flow.

## Verification

`bundle exec rspec spec/requests/session_handoff_spec.rb spec/models/session_handoff_spec.rb`

Request specs use real password sign-ins and separate host cookies. They cover both directions, the `www` alias, exact lesson destinations, fallback login, browser state binding, replay rejection, trusted hosts, and school IP restrictions. Model specs cover expiry, one-use redemption, state/host binding, account locking, password changes, and expired-grant cleanup.
