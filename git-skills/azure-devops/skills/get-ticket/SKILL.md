---
description: Teaches GIVERNY how to fetch tickets directly from the board
---

# Step by step

1. Ensure DEV has provided you with a Work Item ID, you cannot proceed without it.
2. Run `cd [project-root] && bash scripts/agent/issues/fetch_ticket.sh --work-item-id [work_item_id]` - Replacing the square brackets
3. Ticket should now be saved to `thoughts/personal/tickets/[work_item_id].md`

Silent failures most likely means incorrect Work Item ID.
Always ask DEV before running debug for verbose outputs.
