# Fix Website Registrations Not Showing in SA Portal

  ## What & Why
  When a company registers from the BookaWaka website, their application is saved to Firebase under `onboardRequests/`. However, the SA-Onboard page reads from a separate external admin API that does not know about these Firebase submissions. This means new company registrations from the website are invisible to the super admin — they never appear on the board for review.

  ## Done looks like
  - Any company that registers from the BookaWaka website immediately appears on the SA-Onboard page as a pending application
  - The SA admin can see, approve, or reject these website-submitted registrations
  - Existing admin API registrations continue to work as before

  ## Out of scope
  - Changes to the website registration form itself
  - Approving or processing the specific registration that was already submitted (user handles that manually in Firebase or re-submits)

  ## Steps
  1. **Read Firebase onboardRequests in SA-Onboard** — Update SA-Onboard.aspx to also fetch registrations directly from Firebase `onboardRequests/` using the Firebase JS SDK already on the page, in addition to the existing admin API fetch.
  2. **Merge and deduplicate results** — Combine both data sources (admin API + Firebase) into one list, avoiding duplicates, and render them in the existing table with the same approve/reject actions.
  3. **Handle Firebase-only registrations** — For registrations that came from Firebase (not the admin API), the approve action should call `/api/admin/registrations/:id/approve` if an admin API record exists, or fall back to moving the Firebase record into the correct approved state directly.

  ## Relevant files
  - `taxitime.co.nz/superadmin360taxi/SA-Onboard.aspx`
  - `server.js:1370-1560`
  