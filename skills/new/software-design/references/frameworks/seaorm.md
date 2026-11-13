# SeaORM Conventions

Apply this only when working with SeaORM entity definitions.

## Entity modules

Keep entity files directly in their feature module. Use `entity.rs` for a feature with one table. For multiple tables, use descriptive `<name>_entity.rs` files, each defining one primary SeaORM `Model` in its own module.

When applying this convention while adding a second table, give the original `entity.rs` a descriptive name too and update module declarations and references. Separate modules accommodate SeaORM's `Model` naming.

Several tables alone do not require separate services or repositories; use the shared backend responsibilities and cohesive-splitting criteria.
