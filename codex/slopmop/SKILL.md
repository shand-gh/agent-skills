---
name: slopmop
description: Audit and refine web apps that feel AI-generated, especially overused font and palette combinations, predictable layouts, generic surface treatments, and redundant copy. Shape the visual identity around the product and preserve its workflows.
---

# SlopMop

Start with the rendered screen. An interface can work perfectly and still look interchangeable. Give a visual complaint its own answer, even when no usability defect is present. Ask what the screen resembles at first glance, which visible choices produce that impression, and what ought to feel distinctive about this product. Then follow one representative task to identify the behavior and familiar affordances to preserve.

## Read the visual signature

Inspect the first viewport at full size and as a thumbnail. Temporarily ignore the logo, heading, and sample imagery. Look at the shapes that remain. Compare neighboring screens when available.

- **Type.** Inspect the rendered family, weights, sizes, tracking, line breaks, and numerals. Inter or a geometric sans paired with a huge tightly tracked headline, tiny uppercase eyebrow, and mono labels can read as a starter kit. An unusual display face pasted onto the same hierarchy can feel equally generic. Try one actual heading, a long record name, and a number-heavy row in a face or setting drawn from the product’s world. Verify the font loads and works at reading size.
- **Color.** Identify the canvas, ink, accent, status, and chart colors and where each repeats. Look for recognizable combinations such as violet-to-blue gradients over white cards, cyan glow on charcoal, or clay accents on beige editorial surfaces. Ask whether the palette relates to this particular brand, material, content, or use setting. Sample a plausible source, assign the colors distinct roles, and check actual text and controls for contrast.
- **Composition and finish.** Read the silhouette: oversized introductory block, identical rounded panels, icon squares, pill clusters, uniform shadows, and evenly spaced modules can add up to a familiar template. Look also for fashionable substitutes such as indiscriminate hairlines, serial numbers, faux print marks, or serif-and-monospace pairings. Trace each motif to an intentional reference. Retain conventions the product owns.
- **Art direction.** Find an anchor specific enough to guide an edit: how a press operator reads a job ticket, how a gallery labels two related works, or how an existing product treats its most distinctive control. Carry a small number of choices through headings, controls, dense content, and interaction states. Avoid using one replacement house style across products.

Judge combinations in context. A common font may be legible, familiar, and required by the brand. Its scale or pairing may be the actual issue. For each significant flag, name the rendered evidence, the impression it creates, and a concrete alternative. Distinguish an observed resemblance from a claim about authorship or how often a pattern occurs.

## Diagnose a specific mismatch

Translate a visual reaction into something observable. “Four equal cards give secondary totals the same weight as the stalled job” suggests an edit you can test. “Looks AI-generated” alone gives no direction. Treat resemblance as a prompt to investigate. Aesthetic choices cannot establish authorship.

- **Swap the content mentally.** Could a banking app occupy this exact screen after changing the nouns? Look for a relationship the current layout hides, such as sequence, dependency, exceptions, physical scale, or ownership. Give that relationship space.
- **Remove the index and reread.** Test standalone `01 / 02 / 03`, lettered tabs, CSS counters, and “Step” labels by imagining the items reordered. What would a user get wrong without the marker? Keep numbers people use to follow a sequence or match an external reference. On a host switcher, `relay-01` identifies a machine; another `01` beside it needs its own purpose, such as a documented physical port mapping. When deleting a marker, remove its reserved column and accessible text too.
- **Map monospace to a task.** Inspect computed type on navigation, headings, controls, metadata, and content separately. A terminal capture needs its character grid. The surrounding host picker and fullscreen control can use the ordinary UI face. Try proportional type with tabular figures for changing prices or aligned times. Check nearby signals such as `//` prefixes, tracked capitals, and status lights. Keep a status treatment when it communicates an actual state. Verify the result after switching records and at phone width, where a hidden marker can leave an empty slot.
- **Trace the containers.** For each border, badge, glow, icon tile, or inset panel, identify what it separates, communicates, or lets someone do. Merge surfaces with the same purpose. Keep grouping that helps comparison or selection.
- **Try the opposite state.** For “live,” “active,” “verified,” a glowing dot, or a tinted tile, find the underlying event or data. Exercise the transition if it exists. Ask what decision the signal helps someone make. Remove claims that the app cannot substantiate. Identify a saved capture as a capture. Reserve changing emphasis for values people track, such as products in the current sale.
- **Inspect ornament at the size people use it.** Trace repeated colored edge strips, multicolor cards, glass overlays, gradients, emoji, and arrows back to a grouping, action, or product reference. Try the screen with one treatment removed. Compare icon and text baselines in a dense row and at a wrapped label. Keep hatching that distinguishes unavailable slots or chart series, and keep color in the artwork itself.
- **Read the screen aloud, including the text added after an action.** For each line, ask what the reader can decide or do with it at that moment. Remove implementation details and reassurance about routine success when the result is already visible. A task appearing in its list usually answers whether it was added. If saving fails, explain what could be lost and when. Look for language lifted from the build brief, like framework credits, and header dates that imply a filter the records do not have. Check whether the empty-state label repeats a zero count or a success notice repeats the updated record. Keep accessible announcements for changes that are otherwise only apparent visually. Check the first render, the next successful action, and the error path so removed copy does not reappear.
- **Read only the labels.** Cut overlines that repeat headings, taglines that describe the interface, fabricated precision, and verbs that hide the outcome. Preserve instructions, units, accessible names, and timely feedback. Use the vocabulary already present in real records.
- **Follow an action into its next state.** Check what the person must remember after filtering, opening a detail, or completing an item. Keep the relevant record, control, state, and feedback together where the task allows.

## Make the intervention

Choose the strongest visual tell or task mismatch first. Change hierarchy, grouping, copy, or interaction close to its cause. Reuse the data, controls, component contracts, and design system where they work. Get visual character from the material people handle, whether that's artwork, schedules, issue titles, or quantities. A fresh aesthetic can become another template when imposed on unrelated apps. Preserve intentional brand treatments. Use representative data and keep any illustrative data clearly within demo scope.

For an audit, report the visible evidence, the visual impression or task consequence, and the proposed edit. For implementation, make the edit and repeat the original trip. Compare the same record and state before and after at the same viewport. Check whether the intended character still reads with the logo covered, at phone width, and in a secondary state such as an open detail view. If the original already has a distinctive treatment, identify exactly what earns its place. Check the behavior touched by the edit, accessible labels, focus after changes, and narrow-screen ordering. Point to a concrete difference the user can judge. Describe untested usability claims as hypotheses.

When the user gives feedback, identify the precise screen, element, or interaction they mean. Apply local taste feedback to that product; generalize the skill only when the observation gives a transferable decision rule.

## Research behind the prompts

Pranav Desai’s account of his college app connects decorative status and verification marks, arbitrary color, and copy borrowed from a build conversation. Use his examples to test the meaning of a treatment against actual records and transitions. [10 tells of a slop UI](https://godobject.dev/blog/10-tells-of-slop/)

Tim Schipper describes removing padded indexes and slash-prefixed labels from his own site. Tridip Thrizu describes how monospace body copy gave an entire screen the character of a terminal. These practitioner accounts motivate the removal and type-role checks above. The U.S. Web Design System gives a functional example of justified numbering in a linear, multi-screen process. [Schipper’s redesign](https://tim-schipper.nl/en/blog/ai-slop-ui-tells) · [Thrizu’s design review](https://solodesign.cc/blog/ai-design-slop-the-tells/) · [USWDS step indicators](https://designsystem.digital.gov/components/step-indicator/)

Paul Bakaus documents recurring generated-design choices including nested cards, redundant text, and interchangeable metric layouts. His observations motivate examining the purpose each element serves. [Design observations](https://www.linkedin.com/posts/paulbakaus_ai-slop-design-tells-design-anti-patterns-activity-7416272383017164800-10DR) · [Impeccable](https://github.com/pbakaus/impeccable)

Baymard observed shoppers dismissing relevant items when decision-making attributes were missing from listings. Use that evidence when reviewing product discovery and choose attributes appropriate to the inventory. [Product listing research](https://baymard.com/research-articles/product-listing-information)

In Design Creativity Bench, the evaluated models often met the brief while varying their layouts less across product domains than human designers. That finding motivates the content-swap exercise above. [Design Creativity Bench preprint](https://arxiv.org/abs/2610.11539)
