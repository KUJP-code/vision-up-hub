# Temporary ai-sensei event accounts

Admins can create these accounts from **Users → Create New → ai-sensei**, then edit or delete them from the user list. Use the role filter to find all event accounts. The account type is stored as `AiSensei` in the existing users table, so this feature needs no database migration.

Signing in always opens `/:locale/ai-sensei`, including after opening an unrelated hub link or completing a cross-domain sign-in handoff. The demo's bottom-left control logs out instead of returning to the hub. Admins retain their existing preview and return link.

Event accounts are restricted to the demo, session sign-in/sign-out, and the cross-domain handoff. Hub page requests redirect to the demo; hub writes and account changes are forbidden. They do not enter the hub's privacy-policy or device-approval onboarding. Other account types cannot open the event URL. The old screen-mirroring reference and admin tools remain admin-only.

## Removing the feature after the event

First delete every `AiSensei` account through the admin user list. Keep the STI class until those accounts are gone, or Rails will be unable to load their user records. Their sessions stop working when their records are deleted.

Then remove the `AiSensei` model, management controller, policy, form, event route, and associated specs. Remove the role from `User::TYPES` and `Admin::VISIBLE_TYPES`, the event branches in `ApplicationController`, and the conditional demo logout link. Restore the shared user views' ordinary role labels before removing `user_role_label`. Existing user types retain their announcement enum values because the temporary role was appended to the list.

The existing admin prototype can remain at `/:locale/screen_mirroring_test`.
