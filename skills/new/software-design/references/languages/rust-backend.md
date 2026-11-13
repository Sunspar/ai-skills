# Rust Backend Conventions

Apply these to Rust backend modules alongside the language-independent backend reference. These are defaults for projects with no established layout, or when the user explicitly requests them.

## Feature files

Use lowercase `snake_case` module and file names:

```text
src/
  core/
  features/
    teams/
      mod.rs
      entity.rs
      handlers.rs
      service.rs
      repo.rs
      permissions.rs
      dto.rs
  migrations/
```

Create each file when its responsibility is needed. A feature without HTTP concerns does not need handler or HTTP-payload files merely to fill the layout.

Use `mod.rs` to declare feature files with the visibility callers need and compose feature routing where applicable. Keep entity files directly in the feature module rather than introducing an entities directory by default.

Bounded contexts can group sub-features, for example `features/billing/invoices/` and `features/billing/payments/`.

Prefer one `dto.rs`, `handlers.rs`, `service.rs`, and `repo.rs` per feature. When splitting by cohesive responsibility is warranted, use `<name>_service.rs` or `<name>_repo.rs`; each dedicated service defines its corresponding `<Name>Service` struct.

## Service and repository functions

Group service operations as associated functions on a service struct, passing dependencies explicitly:

```rust
TeamService::create_with_owner(&transaction, input, &owner_id)?;
```

Group repository operations on a fieldless `<Name>Repo` struct, with low-level database interactions as associated functions, for example `TeamRepo::insert(&transaction, model)`. Use `async` where required by the existing ORM. Keep repository-specific helpers private and query input types at module scope.

Keep API payload types and model-to-response mappings in `dto.rs`. Follow the shared backend reference for layer responsibilities and transaction ownership.
