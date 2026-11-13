# Backend Structure

These are language-independent backend defaults. Apply them where project instructions and established conventions leave a choice open, or when the user explicitly requests this structure.

## Organize by feature

Keep each feature's model, persistence operations, workflows, HTTP interface, and payload types near each other. Create the files for those responsibilities when needed, using the applicable language and framework conventions.

Related sub-features can live inside a bounded context, such as billing with invoices and payments. Keep shared infrastructure separate from feature-specific behavior and migrations in the project's migration location.

Prefer a cohesive service and repository per feature. Several tables alone do not require several services or repositories. Split by cohesive responsibility when size or complexity warrants it.

## Layer responsibilities

- **Handlers:** HTTP concerns: extract state and inputs, delegate to a service, and produce the appropriate status and response shape.
- **Services:** Complete workflows or units of work that combine repository operations, enforce domain rules and permissions, and coordinate required external actions.
- **Repositories:** Focused database operations for an entity or cohesive query: CRUD, filters, and fetching records or associated lists.
- **Entities/models:** ORM mappings, relations, and persistence metadata, independent of services, repositories, handlers, and API payloads.
- **Permission helpers:** Cohesive resource-access and ownership checks used by services when those checks warrant a dedicated helper.
- **DTOs:** Feature-specific API requests and responses, boundary validation, and mapping from internal models to public API representations.

Handlers call services; services call repositories; repositories work with entities. Layers may use shared infrastructure. Keep domain decisions, HTTP concerns, API payloads, and external side effects in their owning layers.

Services may coordinate operations across several tables or call other services as part of one workflow. A repository operation remains a focused persistence interaction rather than an end-to-end business workflow.

For small workflows with a few straightforward matching rules, keep decisions beside the relevant repository calls. Prefer this direct structure when no preview or second consumer needs an in-memory plan.

## ORM and transaction contracts

Use the ORM connection or transaction handle as the persistence dependency. Let the ORM's connector and configuration select the backend; application workflows work through that handle rather than managing backend selection.

Service functions receive an existing transaction wherever possible and pass it to participating repository operations. Return control to the caller without committing a transaction the caller owns. The caller can be an outer service coordinating the full unit of work.

A specialized service may accept a connection and start its own transaction when its work must deliberately happen separately from ongoing work. This is a rare exception reserved for a crucial isolation requirement. The service that starts that transaction owns its successful commit and propagates operation or commit errors.

Repositories use the caller's transaction for their database operations. Transaction completion belongs to the workflow owner.

## API and model separation

Keep feature-specific API request and response types, including path and query inputs where needed, together with their validation and mapping. Reuse genuinely shared infrastructure types.

Use request names such as `<Action><Resource>Request` and response names such as `<Resource>Response` or `<Action><Resource>Response`, adapting to the project's naming conventions.

Expose explicit response DTOs so the API can evolve independently from ORM models. Keep model-to-response mapping with the DTOs; services own domain rules and workflow orchestration.

## Persistence tests

Normally test persistence through the actual ORM/database path. A database selected through the ORM's configuration may be real or in-memory.

Introduce mocks only when necessary, using the database/transaction boundary when appropriate. The desire for a fake in tests alone does not justify inventing another persistence abstraction above an existing ORM connector.
