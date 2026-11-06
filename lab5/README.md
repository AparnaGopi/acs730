# Lab 5 — count vs for_each

## Subnets: `for_each`
The subnets are distinct things with stable names (`a`, `b`, ...), so they are
keyed by name. Each subnet's state address is its key, e.g.
`aws_subnet.public["a"]`, not its position in a list.

- **Add key `"c"`** → `Plan: 1 to add, 0 to change, 0 to destroy.`
  Only the new subnet appears; `a` and `b` are untouched.
- **Remove key `"a"`** → `Plan: 0 to add, 0 to change, 1 to destroy.`
  Only `public["a"]` is destroyed; `public["b"]` keeps its address and is untouched.

## Why `count` would be a trap for the subnets
With `count`, the addresses are positions: `public[0]`, `public[1]`, `public[2]`.
Delete the middle entry and every entry after it shifts down one slot. Terraform
then compares `public[1]` in state against a *different* subnet in config, so it
plans to destroy and recreate two subnets to remove one. The CIDR/AZ changes
force replacement, and anything in those subnets goes with them.

## Bucket: `count`
The bucket input is a yes/no about a single resource
(`count = var.create_bucket ? 1 : 0`). There are only two possible plans,
`0 to add` and `1 to add`, and there is no key to keep stable, so `for_each`
would add nothing.

## Rule of thumb
**`count` when the question is *how many*; `for_each` when the question is *which ones*.**
