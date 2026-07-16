# Porkbun → Vercel DNS cutover

This connects `foremancompanybuilder.com` to the Vercel project without moving the domain away from Porkbun. Do these steps only after the landing preview has been approved.

## 1. Add the domain in Vercel

1. Sign in to the [Vercel dashboard](https://vercel.com/dashboard).
2. Open the `foreman-company-builder-landing` project.
3. Open **Settings → Domains**.
4. Click **Add Domain**.
5. Enter `foremancompanybuilder.com` and add it.
6. When Vercel offers to add `www.foremancompanybuilder.com`, add that too.
7. Keep this Vercel page open. It shows the exact DNS values assigned to this project.

Vercel may show **Invalid Configuration** until the Porkbun records in the next step have propagated. That is expected.

## 2. Enter these records in Porkbun

1. Sign in to Porkbun.
2. Open **Account → Domain Management**.
3. Find `foremancompanybuilder.com` and open its **DNS** settings.
4. Remove any existing `A`, `AAAA`, or `CNAME` record for the root (`@`) or `www` that points to a different website. Do not delete MX/TXT email records.
5. Add these two records:

| Type | Host | Answer / Value | TTL |
| --- | --- | --- | --- |
| `A` | `@` | `76.76.21.21` | `600` (or Porkbun default) |
| `CNAME` | `www` | `cname.vercel-dns-0.com` | `600` (or Porkbun default) |

Copy the host exactly as `@` and `www`; do not enter the full domain in the Host field.

Important: Vercel's current domain guide calls these its general-purpose values and says a project can receive a specific CNAME. If the open Vercel **Settings → Domains** page shows a different CNAME, copy the Vercel dashboard value instead of `cname.vercel-dns-0.com`. The older `cname.vercel-dns.com` value in the original dispatch brief appears in an older Vercel troubleshooting guide; the current March 2026 setup guide uses `cname.vercel-dns-0.com`.

## 3. Verify and choose the canonical domain

1. Return to Vercel **Settings → Domains**.
2. Wait for both domain cards to show **Valid Configuration**. DNS can take several minutes to propagate.
3. Edit the domain cards so `foremancompanybuilder.com` is the primary domain and `www.foremancompanybuilder.com` redirects to it (or choose the reverse, but keep only one canonical URL).
4. Open both URLs in a private browser window and confirm they reach the landing page over HTTPS.

If Vercel asks for a TXT ownership record, copy that temporary TXT record exactly into Porkbun, wait for Vercel to verify it, then continue. This can happen if another Vercel account previously claimed the domain.

## 4. Promote the approved build

From the landing app directory on the machine that has the approved source:

```bash
cd landing
vercel --prod
```

This is the production promotion step. Do not run it until the preview is approved and the domain records above are ready.

## References

- [Vercel: Setting up a custom domain](https://vercel.com/docs/domains/set-up-custom-domain)
- [Vercel: Adding and configuring a custom domain](https://vercel.com/docs/domains/working-with-domains/add-a-domain)
- [Vercel CLI overview](https://vercel.com/docs/cli)
