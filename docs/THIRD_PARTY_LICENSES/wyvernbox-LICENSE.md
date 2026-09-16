# Wyvernbox (MIT License)

Copyright 2022 Gennady "Don Tnowe" Krupenyov

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

Vendored wholesale at `addons/wyvernbox/` and `addons/wyvernbox_prefabs/`,
provided to this project by its owner. Used for the core item/inventory data
model (`ItemType`, `ItemStack`, `Inventory`) - see `docs/TECHNICAL_PLAN.md`
§4 for what's wired up and what wasn't (the click/2D-UI-oriented ground-item
view and tooltip system don't fit this game's WASD/mouse-look controls, so
our own `scripts/Pickup.gd` is used instead).
