# Infrastructure layers — decision grid (13 layers)

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](infrastructure-dimensions.md)

A stack-, language- and platform-neutral **question and risk grid** for the 13 infrastructure layers that turn a prototype
into a product. It **prescribes no technology** — it makes visible *which* infrastructure decisions each layer requires,
*which* risks (failure modes, anti-patterns) lurk, and *when* "minimal" is no longer enough. Concrete, stack-specific
proposals (products, configuration) deliberately **do not** belong here — the `infrastructure-onboarding` skill (BOO-223)
generates them at runtime from the real stack. For the concrete VPS operations/hardening level see
[`vps-ops-checklist.en.md`](vps-ops-checklist.en.md).

> **Two axes, no replacement.** This grid is the **infra axis** (runtime/deployment/infrastructure). The **quality axis**
> (reliability, testability, maintainability, scalability …) lives unchanged in the architecture dimensions (HANDBUCH §5).
> Overlap (security, monitoring, performance) is handled **by cross-reference**, not maintained twice — see the
> layer × quality-attribute matrix below.

Per layer: **Purpose · Mandatory questions · Failure modes · Anti-patterns (the guardrails) · Approach categories
(trade-offs) · Minimal vs. "more needed" · Compliance triggers · §5 overlap.**

---

## Run 1 — Data & Delivery

### 1. Frontend
- **Purpose:** Delivers the user interface and mediates between human interaction and the backend services.
- **Mandatory questions:** Where is rendering done (CSR/SSR/SSG/ISR/Edge), and does it match the SEO requirements? How is state managed? How is the frontend decoupled from the backend by an API contract? Which performance budgets (Core Web Vitals) apply and how are they measured? How is accessibility (WCAG) ensured?
- **Failure modes:** Wrong rendering approach → poor SEO. Too much client state → hard-to-reproduce bugs + larger attack surface. Unpatched JS dependencies → XSS/supply chain. Missing accessibility → legally exposed.
- **Anti-patterns:** SPA for content-heavy public pages · heavy framework for static content · **business logic only in the frontend** (never authoritative) · versionless API coupling · no performance budget.
- **Approach categories:** CSR (interactivity ↔ weak SEO) · SSR (fast first paint ↔ server cost) · SSG (CDN speed ↔ rarely-changing content only) · ISR (SSG speed + freshness ↔ build complexity) · Edge (latency ↔ limited runtime) · Hybrid (flexible ↔ complexity).
- **Minimal vs. more:** CSR/SSG is enough for internal tools/prototypes. More needed for public SEO traffic (SSR/SSG/ISR), global latency SLA (Edge), accessibility obligation (accessibility gate).
- **Compliance triggers:** EU Accessibility Act (from 2025); GDPR Art. 25 for PII in state; PCI-DSS for payment handling.
- **§5 overlap:** rather a quality attribute (performance/accessibility/SEO are cross-cutting); the layer itself is an infra building block.

### 2. APIs & Backend
- **Purpose:** Provides the business logic and data interfaces through which all clients interact with the system.
- **Mandatory questions:** Which API paradigm (REST/GraphQL/gRPC/event-driven)? How is the API contract (schema, versioning, backward-compat) enforced? How are AuthN/AuthZ enforced at the entry? How is input validation done against injection? How is it scaled horizontally (statefulness assumptions)?
- **Failure modes:** Missing input validation → injection (OWASP Top 10). Stateful monolith without scaling → SPOF under load. Unversioned API → breaking changes break clients. Hardcoded credentials → exposure. Missing timeouts → cascading failures.
- **Anti-patterns:** **No API contract/no versioning** · business logic in the database (stored procedures as primary logic) · monolith with implicit coupling · **config/secrets in code** · no idempotency for mutating operations.
- **Approach categories:** Monolith (simple ↔ big ball of mud) · modular monolith (clean boundaries ↔ discipline needed) · microservices (independent scaling ↔ distributed complexity) · serverless (no ops ↔ cold starts/lock-in) · event-driven (decoupling ↔ observability/eventual consistency).
- **Minimal vs. more:** A (modular) monolith is enough for prototype/small team/clear domain. More needed for independent domain teams, compliance separation (PCI scope), strongly diverging load profiles.
- **Compliance triggers:** PCI-DSS (payment API segmented); GDPR Art. 25 (data minimization at entry); HIPAA (PHI encrypted+audited); NIS2/DORA (resilience of critical services).
- **§5 overlap:** infra building block; security and performance are quality attributes to be enforced here.

### 3. Database & Storage
- **Purpose:** Persists the system state and guarantees data integrity across the lifecycle.
- **Mandatory questions:** Which data model fits the domain (relational/document/KV/graph/time-series)? Which consistency guarantees (ACID/eventual)? How is high availability (replication/failover) and scaling (sharding/shard key) achieved? What is the backup strategy (RPO/RTO, restore test)? How are schema migrations versioned?
- **Failure modes:** Missing replication → SPOF/data loss. Wrong shard key → hotspots, re-sharding nightmare. Untested backup → paper RTO ≠ real restore time. Shared DB across service boundaries → implicit coupling. No encryption at rest for regulated data → compliance breach.
- **Anti-patterns:** One-size-fits-all (RDBMS for everything) · no separate read/write path · **migration-free schema in prod** · **shared database across services** · **no restore test** (restore is theory).
- **Approach categories:** RDBMS (ACID ↔ horizontal scaling hard) · document (flexible ↔ weak joins) · KV (max speed ↔ minimal query) · wide-column (massively horizontal ↔ rethink) · graph (relationships ↔ niche) · replication/sharding (scaling ↔ operational complexity).
- **Minimal vs. more:** Single-node RDBMS is enough for prototype/<10k users/no HA SLA. More needed for >99.9% SLA (replication+failover), data growth >1 node (sharding), regulation (encryption at rest + audit logs).
- **Compliance triggers:** GDPR (deletion technically realizable); HIPAA (encryption at rest+transit for PHI); PCI-DSS (isolated card storage); SOC 2 (backup/access audit); MiFID II/DORA (immutable transaction logs).
- **§5 overlap:** infra building block; durability, availability, confidentiality are realized through DB design.

### 4. Caching & CDN
- **Purpose:** Reduces latency and load by temporarily holding frequently requested data closer to the consumer.
- **Mandatory questions:** What is cached (API responses/queries/sessions/assets/HTML)? Which invalidation strategy (TTL/event/write-through/-behind/-around)? Where is the cache (in-process/distributed/CDN edge/browser)? Which staleness is tolerable for the domain? How does the system behave on cold start / cache stampede?
- **Failure modes:** Thundering herd/cache stampede on simultaneously expiring TTLs. Stale data as authority (especially prices/permissions). Sensitive data in a public CDN → data breach. Missing invalidation on deployment → stale assets. Cache as SPOF.
- **Anti-patterns:** Cache-everything-by-default without hot-path measurement · **no TTL** (stale forever) · **personalized responses without Vary header** (CDN serves them to other users) · cache as a backup strategy · invalidation ignorance on mutations.
- **Approach categories:** In-process (no network hop ↔ no sharing, lost on restart) · distributed (shared state ↔ network hop) · CDN edge (latency ↔ limited invalidation) · browser (no server cost ↔ hard to invalidate) · cache-aside / read-/write-through (control ↔ code responsibility).
- **Minimal vs. more:** No explicit caching needed for internal tools/prototype/<1k RPS. Recommended once the DB becomes the bottleneck; CDN mandatory for worldwide users / >10k concurrent / large static assets.
- **Compliance triggers:** GDPR (no PII over a CDN outside the EEA without safeguards); financial/healthcare data not over public/edge caches.
- **§5 overlap:** rather a quality attribute (performance/availability as goals); the cache is a realization mechanism.

---

## Run 2 — Run & Scale

### 5. Hosting & Deployment
- **Purpose:** Provides the runtime environment and defines the transition from code artifact to running service.
- **Mandatory questions:** Which abstraction level (IaaS/container/PaaS/serverless)? How is dev/prod parity maintained? How is IaC used for reproducibility/drift avoidance? How is zero-downtime deployment done (blue/green/canary/rolling)? How are secrets injected securely? How are health/readiness checks defined?
- **Failure modes:** Deployment downtime without a zero-downtime strategy. Environment drift staging↔prod. No IaC → not reproducible/auditable. Missing health checks → broken instances keep getting traffic. Secrets in the build artifact → leakage via registry.
- **Anti-patterns:** **"SSH into production"** (manual changes without IaC) · snowflake servers · single deployment slot (no canary/blue-green) · config baked into the image · no resource budget (no CPU/mem limits).
- **Approach categories:** IaaS (max control ↔ max ops) · container+orchestration (portability ↔ learning curve) · PaaS (fast ↔ limited control/price) · serverless (no ops ↔ cold starts/lock-in) · hybrid (by workload ↔ high maturity needed).
- **Minimal vs. more:** PaaS/serverless is enough for an MVP/small ops team. More needed for >99.9% SLA with maintenance windows, compliance audit (infra control), cost optimization at high hosting budget → IaC+containers.
- **Compliance triggers:** ISO 27001 (change management); SOC 2 (deployment logs as evidence, separation of duties); DORA (deployment as documented ICT risk).
- **§5 overlap:** infra building block; availability, maintainability, reliability are quality attributes of this layer.

### 6. Cloud & Compute
- **Purpose:** Provides (virtualized) compute resources and defines the sourcing strategy.
- **Mandatory questions:** Which cloud strategy (single/multi/hybrid/on-prem)? How is vendor lock-in limited? How is capacity planning done (reactive/auto-scaling/reserved)? How are compute costs measured/optimized (FinOps)? Which data residency/latency zones apply? How are provider incidents handled (AZ/multi-region)?
- **Failure modes:** Single-AZ → AZ outage = total failure. No auto-scaling → traffic spike overwhelms fixed capacity. Cloud cost sprawl → budget overruns. Data-localization violation → GDPR fine. Over-reliance on proprietary → prohibitive exit cost.
- **Anti-patterns:** Lift-and-shift without redesign · manual capacity management (no elasticity) · **no FinOps** (no cost visibility) · all eggs in one AZ · max vendor lock-in without an exit strategy.
- **Approach categories:** Public single-provider (simple ↔ lock-in) · multi-cloud (resilience ↔ complex networking/IAM) · private/on-prem (data control ↔ capex, no elastic scaling) · hybrid (control+elasticity ↔ integration effort) · serverless compute (elasticity ↔ cold starts).
- **Minimal vs. more:** Single-region is enough for prototype/regional user base. More needed for a global user base (multi-region), data-residency obligation (region pinning), >99.95% (multi-AZ), critical infrastructure (private/hybrid).
- **Compliance triggers:** GDPR (processing only in countries with adequate protection, SCCs); BSI C5 (attestation for regulated sectors); DORA (cloud provider registered, exit plan mandatory).
- **§5 overlap:** infra building block; reliability (multi-AZ), cost efficiency (FinOps), portability are quality attributes.

### 7. CI/CD & Version Control
- **Purpose:** Automates the path from code change to tested, delivered deployment — with traceability of every change.
- **Mandatory questions:** Which branching strategy (trunk-based/Gitflow)? How are build/release/run separated? Which quality gates (tests/SAST/dependency scan/lint) are mandatory before merge/deploy? How are artifacts versioned/signed? How are secrets handled in CI/CD? How is the pipeline itself tested/versioned (pipeline as code)?
- **Failure modes:** Secrets in pipeline config/repo → exposure. No artifact signing → supply chain attack. Manual deployments beside the pipeline → drift. Too-rare large releases → high risk. No pipeline tests → breaks in prod without warning.
- **Anti-patterns:** **Secrets in the repository** (including the git history) · no artifact registry · **manual deploy-to-production without audit trail** · monolithic pipeline without stages · no dev/prod parity of pipelines.
- **Approach categories:** Trunk-based (fewer merge conflicts ↔ test discipline/feature flags) · Gitflow/feature branches (structured ↔ merge complexity) · continuous deployment (velocity ↔ excellent coverage needed) · continuous delivery (manual release trigger ↔ more steps) · pipeline as code (reproducible ↔ DSL learning curve).
- **Minimal vs. more:** Minimal = automatic build + tests + manual deploy trigger, secrets out of the code. More needed under regulation (separation of duties), SBOM obligation (EU CRA → dependency-scan gate), >10 developers (branching + branch protection).
- **Compliance triggers:** SOC 2 (deployment logs as evidence); ISO 27001 (change management, authorized changes); EU Cyber Resilience Act (SBOM from 2027); DORA (ICT change management).
- **§5 overlap:** infra building block (delivery process); security (supply chain), maintainability, reliability are quality attributes.

### 8. Rate Limiting
- **Purpose:** Protects the system from overload, abuse and DoS by limiting request frequency per time unit.
- **Mandatory questions:** At which level (gateway/LB/middleware/app)? Which dimension is limited (IP/user/API key/endpoint/tenant)? Which algorithm (fixed/sliding window, token/leaky bucket)? How consistent in distributed deployments (no node-hopping bypass)? How are limits communicated to the client (429, Retry-After)? Fail open or fail closed?
- **Failure modes:** No rate limiting → DDoS/inefficient client overloads, costs explode. Limiting on one node only → bypass via IP rotation. Too restrictive without burst → legitimate peaks blocked. Missing limit communication → immediate retries increase load. Fail-open on failure → protection gone in the attack scenario.
- **Anti-patterns:** No limiting for "trusted clients" (internal can be buggy/compromised too) · **IP level only** (botnet bypasses it) · uniform limits for all endpoints · **no limit headers** in responses · rate limiting as an after-thought.
- **Approach categories:** Fixed window (simple ↔ burst at window end) · sliding window (even ↔ overhead) · token bucket (controlled bursts) · leaky bucket (smooths ↔ no bursts) · central/gateway (consistent ↔ SPOF) · distributed (HA ↔ sync overhead).
- **Minimal vs. more:** Minimal from the first public endpoint: IP-based at the entry, even without auth. More needed for multiple API tiers (user/key limits), >100 RPS (central/distributed), partner APIs (quota management).
- **Compliance triggers:** No universal standard; implicit for availability SLAs; finance: burst abuse on transaction APIs (indirect obligation).
- **§5 overlap:** rather a quality attribute (availability, abuse prevention, fairness); rate limiting is a mechanism, not a standalone infra block.

---

## Run 3 — Trust & Operate

### 9. IAM / RBAC / Permissions
- **Purpose:** Controls who (identity) may do what (permission) on which resource in which context — the system's central trust foundation.
- **Mandatory questions:** How are identities (users/services) authenticated (password/MFA/cert/OIDC/SAML)? How is the role model structured (flat/hierarchical/ABAC)? How is least privilege enforced per role/service account? How are privileged accesses time-limited (JIT)? How do on-/offboarding work? How are service-to-service accesses secured (workload identity/mTLS)?
- **Failure modes:** Too-broad roles → maximum blast radius. No offboarding → ex-employees/-systems keep access. Shared credentials → one compromise hits all. No MFA for privileged accounts → phishing directly effective. Privilege creep over time.
- **Anti-patterns:** **"God mode" service accounts** · static, never-rotated credentials · no IAM-as-code · **no separation of duties** (one person writes+reviews+deploys+DB access) · implicit trust in the internal network.
- **Approach categories:** RBAC (simple ↔ granular exceptions hard) · ABAC (fine-grained ↔ policy complexity) · ReBAC (object hierarchies ↔ demanding) · centralized IdP (single source ↔ SPOF) · federated (SSO ↔ provider dependency) · zero trust/workload identity (no network trust ↔ high maturity).
- **Minimal vs. more:** Minimal = MFA for privileged accounts, least privilege, no shared credentials, offboarding process. More needed for >10 users (formal RBAC), regulation (access reviews), microservices (workload identity/mTLS), SOC 2/ISO 27001 (IAM as audit target).
- **Compliance triggers:** GDPR (access restricted+documented); ISO 27001 A.9; SOC 2 CC6; PCI-DSS Req 7/8; NIS2 (privileged access regulated).
- **§5 overlap:** rather a quality attribute (security); IAM is at once an infra building block (auth system) and a security control.

### 10. Security & RLS (Row-Level Security)
- **Purpose:** Enforces granular access rights on individual records — a user sees only their data, independent of API-layer controls.
- **Mandatory questions:** Which data-level isolation (object/row/column level)? Where is RLS enforced (DB engine/ORM/service)? How is IDOR prevented? How is the security policy managed+tested as code? How is multi-tenancy isolated (shared schema+RLS / separate schema / separate DB)? How are record-level data accesses logged?
- **Failure modes:** IDOR → user A reads B's data via ID manipulation. RLS policy error → all rows instead of filtered (silent full access). Bypass via admin direct queries without RLS. Missing column encryption → breach exposes plaintext. Logging gaps → forensics impossible.
- **Anti-patterns:** **RLS exclusively in the application layer** (one bug opens everything) · no tests of the RLS policies · shared DB user for all services · **tenant isolation only via WHERE clause** · field encryption as an afterthought.
- **Approach categories:** DB-native RLS (independent of app layer ↔ DB-specific) · ORM-level (portable ↔ bypassable on direct DB) · service-layer (flexible ↔ one bug exposes everything) · separate schemas/DBs per tenant (strongest isolation ↔ ops effort) · policy-as-code (central/versioned ↔ runtime call).
- **Minimal vs. more:** Minimal from a multi-user system: IDOR protection (ownership check on every access). DB-native RLS for shared-schema multi-tenancy/regulated data. Column encryption for legal-hold fields (PAN/SSN/health); row-level audit logging for forensic obligations.
- **Compliance triggers:** GDPR Art. 5/25 (data minimization at record level); HIPAA (minimum necessary); PCI-DSS Req 3; SOC 2 CC6.1.
- **§5 overlap:** rather a quality attribute (confidentiality/integrity); RLS is a mechanism to realize them at the data level.

### 11. Monitoring / Logs / Alerts
- **Purpose:** Creates continuous visibility of the system state and detects deviations from service-level objectives in time.
- **Mandatory questions:** Which three signals (metrics/logs/traces) are collected and correlated? How are SLIs defined and on which SLOs do alerts rest? How is alert fatigue avoided (actionable vs. informational)? How are logs structured and centralized? How are logs secured against manipulation (immutability)? Which retention applies (compliance)?
- **Failure modes:** No monitoring → silent failures. Alert fatigue → real incidents missed. Unstructured logs → search takes hours. No distributed traces → diagnosis is guesswork. Log gaps in the audit. Monitoring the wrong signal → green metrics, degraded UX (false comfort).
- **Anti-patterns:** **Threshold alerts without SLO reference** (CPU>80% without user impact) · log-everything-filter-nothing · monitoring as an after-thought · no end-to-end tracing · **mutable logs** (worthless for compliance).
- **Approach categories:** Metrics (efficient ↔ no context) · log aggregation (context ↔ cost/search) · distributed tracing (end-to-end ↔ sampling) · SLO/burn-rate alerting (user-impact-correlated ↔ onboarding) · correlated observability (complete ↔ complexity).
- **Minimal vs. more:** Minimal from the first deployment: health check + uptime alert + error rate + structured logs. More needed for >2 services (tracing), customer SLA (SLO alerting), regulation (immutable logs + retention), high RPS (sampled tracing).
- **Compliance triggers:** SOC 2 CC7; ISO 27001 A.12.4; GDPR Art. 33 (breach detection); DORA (continuous monitoring); MiFID II (transaction logs, 5–7 yr retention).
- **§5 overlap:** rather a quality attribute (reliability/maintainability/security detection); monitoring is cross-cutting over all layers.

### 12. Rollback & Recovery
- **Purpose:** Returns the system to a defined state after failed deployments, data corruption or outages — within agreed RTO/RPO.
- **Mandatory questions:** Which RTO/RPO per system class? How is rollback triggered (automatic on health fail / manual)? How are DB migrations made backward-compatible? How is restore capability verified (regular tests)? How is backup immutability secured against ransomware (3-2-1, air gap)? How is recovery ordering coordinated?
- **Failure modes:** Untested backups → real restore time ≫ paper RTO. Irreversible migration deployed → code rollback impossible without data loss. No backup immutability → ransomware encrypts backups too. Undocumented manual rollback → time lost in the incident. Recovery order undefined.
- **Anti-patterns:** **"We have backups" without a restore test** · **destructive migrations** (DROP COLUMN without a prior code rollback) · no rollback plan in the deployment · hot standby for everything (needless cost) · no post-mortem process.
- **Approach categories:** Hot standby (min RTO/RPO ↔ cost/sync) · warm standby (balance ↔ start/sync time) · cold recovery (cheap ↔ RTO in days) · blue/green (code rollback in seconds ↔ no protection against migration errors) · feature flags (feature rollback ↔ code complexity) · immutable infrastructure (prior image ↔ stateful separate).
- **Minimal vs. more:** Minimal = daily backup + documented manual restore + deployment rollback. More needed for >99.9% SLA (auto-failover), RPO<1h (continuous replication), ransomware risk (immutable/air-gapped), retention obligations.
- **Compliance triggers:** ISO 22301 (BCP/DRP with RTOs); DORA (recovery tests, incident deadlines 24h/72h/1M); SOC 2 A1; GDPR Art. 32; critical infrastructure (BCP mandatory).
- **§5 overlap:** rather a quality attribute (availability/durability/resilience); rollback/recovery is a realization mechanism.

### 13. Audit / Compliance & SLAs
- **Purpose:** Creates the technical and organizational basis for accountability, evidence and contractual commitment toward regulators/customers.
- **Mandatory questions:** Which frameworks apply (GDPR/ISO 27001/SOC 2/PCI-DSS/HIPAA/NIS2/DORA/BSI C5)? How are audit trails implemented (immutable logs, who-when-what)? How are SLAs defined and measured technically as SLOs (≤ SLA with buffer)? How is continuous compliance operated? How are sub-processors assessed? How is the breach-notification process defined+rehearsed?
- **Failure modes:** SLAs without a measurable foundation → violations unnoticed, penalty by surprise. Audit-trail gaps → audit fails. Compliance as a one-off project → compliance debt between audits. No sub-processor control (GDPR Art. 28). Breach without a notification process (Art. 33, 72h).
- **Anti-patterns:** **Compliance theater** (policy on paper, controls missing) · **SLA = SLO** (no error-budget buffer) · retrospective audit effort · compliance as a security substitute (certificate ≠ security) · no third-party register.
- **Approach categories:** Continuous compliance (ongoing ↔ tooling investment) · periodic audit (clearly scheduled ↔ decay in between) · policy-as-code (versioned/testable ↔ extra codebase) · GRC platform (central ↔ expensive, mid-size up) · error-budget SLAs (measurable ↔ monitoring maturity needed).
- **Minimal vs. more:** Minimal (every product) = privacy policy + breach-notification process + basic audit log (logins, data access). More needed for B2B compliance evidence (SOC 2/ISO 27001), payments (PCI-DSS), health data (HIPAA), EU finance (DORA), critical infrastructure (BSI C5/NIS2). SLA depth when customer SLA contracts exist.
- **Compliance triggers:** *This layer is the compliance layer itself* — it aggregates the evidence of all other layers. Triggers = applicable frameworks × sector × data categories × customer profile.
- **§5 overlap:** rather a quality attribute (accountability/auditability/legal compliance); a cross-cutting concern that aggregates evidence from all layers.

---

## Schematic overview: layer × quality-attribute matrix

This matrix makes the **§5 delimitation** operational: where a layer carries a `●` in the "→ rather a Q-attribute" column,
the focus is a **quality property** (belongs primarily on the §5 axis) and the layer only provides the infra mechanism.
Overlaps (security/monitoring/performance) are maintained **by cross-reference** between this table and HANDBUCH §5 — not
twice.

| Layer | Security | Performance | Availability | Compliance | → rather Q-attribute |
|---|---|---|---|---|---|
| Frontend | ◑ | ● | ○ | ◑ | ◑ |
| APIs & Backend | ● | ● | ● | ● | ○ |
| Database & Storage | ● | ◑ | ● | ● | ○ |
| IAM / RBAC | ● | ○ | ◑ | ● | ● |
| Hosting & Deployment | ◑ | ◑ | ● | ◑ | ○ |
| Cloud & Compute | ◑ | ● | ● | ◑ | ○ |
| CI/CD & Version Control | ● | ○ | ◑ | ● | ○ |
| Security & RLS | ● | ○ | ○ | ● | ● |
| Rate Limiting | ● | ● | ● | ○ | ● |
| Caching & CDN | ○ | ● | ◑ | ◑ | ● |
| Monitoring / Logs / Alerts | ● | ○ | ● | ● | ● |
| Rollback & Recovery | ◑ | ○ | ● | ● | ● |
| Audit / Compliance & SLAs | ● | ○ | ◑ | ● | ● |

`●` = primarily relevant · `◑` = secondarily relevant · `○` = little relation

## Two axes — delimitation from HANDBUCH §5

- **Infra axis (this grid):** *which* infrastructure decision per layer, *which* risks, *when* more is needed.
- **Quality axis (HANDBUCH §5):** *which* quality properties (reliability, testability, maintainability, scalability,
  security …) the system must satisfy.
- **Cross-reference instead of duplication:** layers with `●` in "→ rather a Q-attribute" (monitoring, security & RLS, IAM,
  rate limiting, caching, rollback/recovery, audit) are mechanisms that realize a §5 quality goal. A project's infra table
  (BOO-221) references §5 for those layers instead of restating the quality dimension. §5 remains the single source of truth
  for the quality axis.

## Inheritance mechanics (catalog vs. project vs. corporate)

The catalog is **stack-neutral and framework-wide** — it is **not edited per customer**. Two override levels:

1. **Framework/corporate level (forked catalog):** A corporate-wide rule (e.g. "EU regions only", "SOC 2 mandatory from
   layer 13") lives in a **forked framework instance** of this catalog — maintained **once**, **inherited** by all of the
   group's projects (copy at clone, not rewritten per project). Cf. [`../../docs/runbooks/multi-user-vps.en.md`](../../docs/runbooks/multi-user-vps.en.md)
   for the clone/multi-user mechanics.
2. **Single-project level (project table):** Project-specific decisions + deviations live in the project's
   **ARCHITECTURE_DESIGN infra table** (13 rows, status incl. `n/a (deliberate)`; BOO-221). It **references** this catalog
   instead of copying it.

Rule of thumb: **catalog = reference (shared, inherited), project table = decision (local).** The shared catalog is only
maintained at the framework/corporate level.

## Sources

12-Factor App · AWS Well-Architected Framework · OWASP Cheat Sheet Series / Top 10 · Google SRE Book (SLI/SLO/error budgets) ·
NIST CSF 2.0 · ISO 22301 (Business Continuity) · ISO 27001 · SOC 2 Trust Services Criteria · GDPR · PCI-DSS · HIPAA · NIS2 ·
DORA · BSI C5 · EU Accessibility Act · EU Cyber Resilience Act. (Full footnote evidence: deep research
`Research/Infrastruktur-Layer Entscheidungsraster.md` in the project vault.)

> **Technology neutrality:** All products named in the sources (Redis, Kubernetes, etc.) are examples only, not
> recommendations. This catalog deliberately names **no** products — concrete proposals are generated by the
> `infrastructure-onboarding` skill (BOO-223) at runtime from the real stack.
</content>
