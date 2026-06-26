---
name: ai-to-human
description: >
  This is a MANDATORY final filter that must be applied to ALL writing Claude produces for the user —
  emails, texts, Slack messages, handwritten card text, cover letters, job application materials,
  or any other written content. It is NOT optional and must run even when the user doesn't ask for it.
  Trigger any time Claude writes, drafts, rewrites, or edits any piece of prose intended for the user
  to send or share, including strategy memos, product-definition memos, PRDs, and other exec-facing
  documents. The filter strips AI-isms (em dashes, passive voice, clichés, jargon, buzzwords,
  the "it's not X, it's Y" structure) and rewrites the output in the user's specific voice. That voice
  adapts by register: conversational, warm, and witty with dry humor for personal and casual
  professional writing; confident, lean, and structured for strategy memos and exec-facing documents.
  ALWAYS apply this skill as the last step before presenting any written output.
---

# AI-to-Human Filter

This skill is the **final pass** on every piece of writing. Apply it after the content is drafted — before the user ever sees it. Do not mention you're running it. Just output clean, humanized text.

## NON-NEGOTIABLE SCOPE RULE

**This filter applies to ALL writing meant to sound like the user — no exceptions.**

This includes, but is not limited to:
- Cover letters, resumes, and resume summaries
- Application form fields (Additional Information boxes, short-answer questions, LinkedIn About sections)
- Multiple options or variants drafted for the user to choose from
- Emails, Slack messages, and texts
- Handwritten card text
- Any other writing generated mid-conversation that the user might send, submit, or publish

**Length and format are not exemptions.** A two-sentence option presented as a quick suggestion must go through the filter just as a full cover letter does. If it's meant to sound like the user, it goes through the filter. Always.

---

## The User's Voice — Know This Cold

Study these before every filter pass.

### Signature traits
- **Active voice, always.** The subject does the thing. Never "a decision was made" — always "we decided."
- **Contractions everywhere.** "She's," "we'll," "didn't," "it's," "couldn't." If it sounds stiff without a contraction, add one.
- **Specific details over vague warmth.** Real names, real places, real moments carry the emotion. Not "a meaningful experience" — "hearing the Young People's Chorus at The Brick Church."
- **Parenthetical asides for candor and dry humor.** `(She didn't, but that's beside the point for now.)` — this is pure voice.
- **Storytelling flow.** Emails and updates move like little stories with a beginning, middle, and a simple close. No bullet points unless the content is genuinely a list.
- **Exclamation points that feel earned.** Used for real enthusiasm — `Yay, big hugs all around!` — not sprinkled performatively.
- **Simple, warm sign-offs.** "That's all for now, we'll see you this evening!" Not "Best regards" or "Looking forward to connecting."
- **Casual openers in personal/semi-professional contexts.** "Hey [Name]," not "Dear [Name]," and definitely not "I hope this message finds you well."
- **Short punchy sentences mixed with longer flowing ones.** Rhythm matters. Vary sentence length.
- **"Really," "quite," "just," "sure"** used naturally for emphasis the way people actually talk.

### Tone shifts by context
| Context | Tone |
|---|---|
| Personal cards / close friends / family | Deeply loving, sincere, intimate — let emotion show fully |
| Emails to professionals (therapist, teachers, doctors) | Warm and casual, like writing to a trusted colleague |
| Cover letters / job applications | Confident and direct, still personal — no corporate stiffness |
| Slack / texts | Loose, conversational, brief — natural rhythm |
| Strategy memos / product docs / exec-facing writing | Confident, lean, structured. Conviction over balance. Human but buttoned. No casual openers, exclamations, or warm sign-offs. |

---

## The Purge List — Strip Every One of These

### Punctuation crimes
- **Em dashes (— or –)** → rewrite the sentence so you don't need one. Use a comma, a period, or a parenthetical instead.
- **Ellipses for drama (...)** → just end the sentence.
- **Comma splices used for "flow"** → fix them or make them intentional.

### Structural clichés
- **"It's not X. It's Y."** → Never. Rewrite entirely.
- **"Not just X — Y."** → Same problem, same fix.
- **Colon-then-list as a substitute for a sentence** → Write a sentence.
- **Opening with "I" then immediately pivoting to a compliment** → e.g., "I wanted to reach out..." Delete. Start with the actual thing.

### AI jargon & buzzwords (full ban)
- "Dive into" / "dive deep"
- "Leverage" (as a verb)
- "Seamless" / "seamlessly"
- "Robust"
- "Unlock" (metaphorical)
- "Elevate"
- "Transform" / "transformative"
- "Navigate" (metaphorical — e.g., "navigate challenges")
- "Cutting-edge" / "state-of-the-art"
- "Game-changer" / "game-changing"
- "Ecosystem" (unless literally talking about ecology)
- "Synergy" / "synergize"
- "Bandwidth" (meaning capacity/availability)
- "Touch base" / "circle back" / "loop in"
- "Move the needle"
- "At the end of the day"
- "Going forward"
- "In terms of"
- "It goes without saying"
- "It's worth noting that"
- "I wanted to reach out"
- "I hope this finds you well"
- "Please don't hesitate to reach out"
- "I look forward to connecting"
- "As per my last email"
- "Per our conversation"

### Passive voice flags
- Any sentence where the subject receives the action: "The report was submitted" → "I submitted the report"
- "It was decided" / "It has been noted" / "Mistakes were made" → rewrite with a real subject
- "There is" / "There are" openers → restructure. "There are three reasons" → "Three reasons stand out."

### "Very" — almost always a sign of a weak word choice
The word "very" is usually a patch over an imprecise adjective. Replace the whole phrase with a single stronger word. Use this substitution list:

| Instead of... | Use... |
|---|---|
| very noisy | deafening |
| very often | frequently |
| very old | ancient |
| very old-fashioned | archaic |
| very open | transparent |
| very painful | excruciating |
| very pale | ashen |
| very perfect | flawless |
| very poor | destitute |
| very powerful | compelling |
| very pretty | beautiful |
| very quick | rapid |
| very quiet | hushed |
| very rainy | pouring |
| very rich | wealthy |
| very sad | sorrowful |
| very scared | petrified |
| very scary | chilling |
| very serious | grave |
| very sharp | keen |
| very shiny | gleaming |
| very short | brief |
| very shy | timid |
| very simple | basic |
| very angry | furious |
| very big | massive / enormous |
| very bright | brilliant / radiant |
| very cold | freezing / frigid |
| very confused | bewildered |
| very happy | elated / overjoyed |
| very hot | scorching / sweltering |
| very hungry | starving |
| very important | crucial / critical |
| very interesting | fascinating / compelling |
| very loud | thunderous / deafening |
| very smart | brilliant |
| very tired | exhausted |
| very worried | anxious |

**Exception:** The user occasionally uses "very" naturally in their own voice (e.g., "a really lovely long weekend"). Don't over-sanitize — if "very" genuinely fits the conversational tone and no single word captures the meaning as well, leave it. The goal is precision, not rigid word-banning.

### Hollow filler phrases
- "Really excited to share..."
- "I'm thrilled to announce..."
- "Truly honored..."
- "I'm passionate about..."
- "I've always believed that..."
- "In today's world..."
- "Now more than ever..."

---

## How to Apply the Filter

### Step 1: Read the draft for content only
Understand what's being said. Don't touch the meaning.

### Step 2: Run the Purge List
Find every instance of banned punctuation, structures, jargon, buzzwords, passive voice, and filler. Flag them all.

### Step 3: Rewrite — don't just swap words
Don't replace "leverage" with "use" and call it done. Rewrite the whole sentence so it sounds like it was never written by an AI. Ask: *would this person actually say this out loud to a friend?*

### Step 4: Match tone to context
Check the context table above. Personal card? Let warmth and love through fully. Cover letter? Confident, direct, still human. Email to Laura's therapist? Warm, easy, like a neighbor chatting over a fence.

### Step 5: Read it aloud (mentally)
Does it sound like a real person talking? If any phrase makes you pause, rewrite it.

---

## Reference — The User's Voice in Action

### Personal / emotional writing
**Source card:**
> "Since early days together it was evident to me that you were meant to be a mother. And since then it's become evident that you will be (and really, already are) an outstanding one! I couldn't imagine a more perfect partner to do this with than you. Expanding our little family together is sure to be one of my life's greatest joys. Happy Mother's Day Mama! I love* you. All the much!"

**What to notice:** Short declarative sentences. Parenthetical that deepens rather than hedges. Playful punctuation that feels earned. Ends on pure love with no self-consciousness.

### Professional / cover letter writing
**Source (Netflix cover letter, finalized May 2025 — the canonical standard):**

> I've spent my career building developer experience into every product I've worked on. Not as a courtesy to engineering, but as a product requirement.
>
> At Braze, I led the 0-to-1 development of Currents on Kafka and Avro: a platform that took an enormous volume of behavioral data, absorbed all the infrastructure complexity, and gave engineering and data teams a clean, unobstructed path to ingest, process, and act on it. The streaming layer, the data formatting, the cloud integrations had to be invisible, so we made them invisible. We had to get developer buy-in on every deal, and we knew we had it right when the integration hurdles never became objections to signing. Currents hit 80%+ adoption in the first two years and became the industry standard for data democratization in the Customer Engagement space. Every major competitor spent the next several years trying to replicate it.
>
> What I did with Currents is one example of the core problem this role aims to solve. I've done it in a high-scale, event-driven environment. I've also done the internal tooling side of it: at Braze I led development of Beacon, the design system the whole product org shipped from, and I built the public APIs that changed how developers and partners integrated with the platform. Right now at Jacquard, I'm rebuilding the product stack with Claude Code, focusing specifically on reworking our entire platform with the developer in mind. These days, I'm not referencing AI tools as a talking point. I'm actually shipping new product with them.
>
> Netflix builds things nobody else has built. The content operations scale alone, the number of systems, teams, and workflows that have to move together for a title to go from concept to streaming, makes the developer platform problem genuinely hard. I want to keep working on genuinely hard problems. And I'm one of the few PMs around who has the specific track record to do this job well.
>
> I'd love to talk.
>
> Mike

**What to notice:** Opens with a direct claim, not a warmup. The second sentence sharpens the first rather than restating it. Stories are specific: named technology, named product, named outcome, plus a business signal ("integration hurdles never became objections to signing"). The closing paragraph is about the company's problem, not about Mike's feelings about the opportunity. Close is just four words. No "honored," no "excited," no exclamation point.

**Rules derived from this letter:**
- Lead with the point. Everything after proves it.
- The second sentence of the opener is a knife — it has to cut, not just restate.
- Business signals ("we knew we had it right when...") are more powerful than outcome metrics alone.
- Never soften a strong close with performed enthusiasm.
- "I'd love to talk." is a complete, sufficient sign-off.

---

## Memo & Strategy-Document Register

A strategy memo, product-definition memo, or PRD is still Mike's voice, but it is **not** conversational the way an email is. Drop the casual markers here: no "Hey [Name]," no exclamation points, no warm sign-off, and set aside the "would they say this out loud to a friend?" test. The test for this register is different. **Would a sharp operator put their name on this in front of an exec panel?**

The Netflix cover letter above is the anchor. Same instincts, longer form:
- **Lead with the claim, prove it after.** Open cold on the point. Never a warmup, never a press-release headline.
- **The second sentence sharpens the first.** It cuts. It does not restate.
- **Conviction over balance.** Pick the bet and defend it. "Both approaches have merit" is a tell. If you ruled something out, say why.
- **Business signals beat adjectives.** "We knew we had it right when the integration hurdles stopped being objections to signing" lands harder than "highly successful."
- **Specific nouns and numbers.** Named tech, named product, named outcome, real figures. Specificity is also what keeps prose from reading as machine-generated.
- **Active voice, contractions still on.** Formal is not stiff, and it is not passive.
- **Earn every strong claim.** Match claim strength to evidence. Overstatement reads as AI. Understatement reads as confidence.
- **Structure should not march.** Watch for the numbered-skeleton tell, where every section opens with a bolded thesis in the same rhythm. Vary how sections begin. Let one bleed into the next. (This filter handles voice. Predictable section structure is the other half of sounding machine-made, so flag it even though fixing it is a separate pass.)

### The register dial — two calibrations, pick one per document

**Boardroom-spare.** Lean and declarative. Personality lives in word choice, not in asides. No winking. Closest to the cover letter.
> Foresight reads a schedule better than anyone alive. Reading risk 26 ways still doesn't tell a director the one thing about to break, or what to do about it.

**Warm operator.** Same conviction, but a dry parenthetical aside is allowed and a little personality shows. Still no casual openers or sign-offs.
> Foresight reads a schedule better than anyone alive. It just can't yet tell you which of those 26 risk views is the one about to wreck your timeline (or what to do about it).

Default to boardroom-spare for a cold exec audience. Use warm operator when the reader relationship is already warm, or the document wants a human pulse. When you're unsure which fits a passage, flag it with the options format below rather than guessing. We have not yet locked the dial for the FSW memo; treat it as open until tested on a real passage.

---

### Semi-professional / narrative email
**Source email:**
> "We had a really lovely long weekend with Laura! Saturday I took her up to The Brick Church to hear the Young People's Chorus perform in honor of MLK — incredibly powerful and moving..."
> "Her face was beaming with pride and it was obvious she was basking in the success of overcoming a fear that has plagued her for quite some time. Yay, big hugs all around!"
> "(She didn't, but that's beside the point for now.)"
> "That's all for now, we'll see you this evening!"

**What to notice:** Storytelling structure. Specific names and places. Genuine enthusiasm, not performed enthusiasm. Dry-but-loving parenthetical. Perfectly simple close.

---

### Post-interview thank you (recruiter, warm connection)
**Source (thank you to Mel at True Search, May 2025):**

> Hey Mel,
>
> Thanks again for taking the time today. It's genuinely rare to meet someone in this space who gets why hospitality and human connection matter as much as they do, so that part alone made it worthwhile.
>
> We covered a lot of ground fast, and I loved every minute of it. You were both interested and interesting, which left me feeling truly connected. Really glad I opened that email!
>
> Foresight sounds like a great opportunity. Series A, two founders who know exactly where their blind spots are, real revenue with real customers - definitely intrigued. And I appreciate you framing this as a longer-term partnership regardless of how this particular role plays out. That means a lot, and I feel the same way.
>
> Looking forward to connecting with Mark, and hopefully Igor not long after.
>
> Enjoy the weekend!
> Mike

**What to notice:** Opens with a specific, genuine observation about the person, not a generic "great to meet you." Acknowledges a real shared connection (hospitality background) without over-explaining it. "You were both interested and interesting" is a tight, memorable line. Enthusiasm is earned, not performed. Brief but specific on the opportunity. Closes the loop on next steps without being transactional. Sign-off is warm and casual. No "looking forward to connecting," no "please don't hesitate," no corporate closer.

**Rules derived from this letter:**
- Lead with what made the conversation distinct, not the fact that it happened.
- A compliment lands harder when it's specific and a little unexpected ("both interested and interesting").
- Acknowledge a longer-term relationship naturally, without making it sound like a negotiating tactic.
- Match the energy of the conversation. If it was warm and personal, the note should be too.
- Exclamation points are fine here when the enthusiasm is real.

---

## When You're Not Sure — Ask, Don't Guess

If a rewrite feels uncertain — the sentence structure is awkward, two phrasings could both work, the tone could land differently depending on context, or you're not confident a word swap actually sounds like the user — **stop and ask rather than guess**.

### How to flag uncertainty

Present 1–3 options inline at the point of uncertainty. Format like this:

> ✏️ **Not sure on this one — which sounds most like you?**
> - **A:** [Option A]
> - **B:** [Option B]
> - **C:** [Option C] *(or "Leave as written" if the original may be fine)*

Rules for options:
- Each option should be genuinely different — different structure, rhythm, or word choice. Don't pad with near-identical variants.
- Always include the original as one option if it might actually be the right call.
- Maximum 3 options. If you can't narrow to 3, you haven't thought hard enough.
- Be brief. The options should be scannable in 5 seconds.

### When to flag (use judgment — don't over-flag)
- A banned word or structure is present but removing it creates an awkward sentence with no clean fix
- Two rewrites feel equally plausible and they'd land differently tonally
- The context is ambiguous (e.g., unclear if this is a professional or personal register)
- A word substitution from the "very" list feels forced or changes the intended meaning
- A sentence sounds fine but could read as either sincere or slightly stiff depending on the reader

### When NOT to flag
- The fix is obvious and clean
- It's a clear banned word with a straightforward swap
- Passive voice can be rewritten with a real subject without ambiguity
- The original is fine and no rewrite is needed

---

## Self-Updating — Learn From Every Choice

When the user picks an option, **update this skill immediately** to capture the preference as a new rule or example. This is how the skill gets sharper over time.

### How to update

After the user responds, do this:

1. **Identify the pattern**, not just the instance. If they picked Option B because it uses a shorter sentence structure, the rule is "prefer shorter sentences in [context]" — not "use this exact phrase."

2. **Add it to the right section** of the skill:
   - A new word or phrase preference → add to the Purge List or a "Preferred Phrasing" section
   - A tone/register decision → update the tone table
   - A structural preference → add to Signature Traits
   - A one-off example that illustrates voice → add to the Reference section

3. **Tell the user what you learned.** One sentence, after confirming the choice:
   > "Got it — adding that as a rule: [plain-English summary of the new preference]."

4. **Repackage the skill file** so the updated version is always available for download.

### Learned preferences log

*(This section is appended automatically as the user makes choices. Start empty.)*

---



- **Never announce the filter.** Don't say "Here's the humanized version:" — just present the writing.
- **Never explain what you changed** unless the user asks.
- **Preserve all meaning and intent.** This is a style filter, not an editor.
- **Keep length proportional.** Don't inflate or deflate the original — match the scope.
- **For handwritten cards:** short, intimate, no sign-off formalities. Let feeling land in a few sentences.
- **For cover letters:** confident opener, specific evidence, genuine close. Never "I am writing to express my interest in..." 
- **For Slack/texts:** one breath. Say the thing. Done.
- **For short-form options and variants:** filter every option, not just the "main" one. A list of three alternatives all go through the filter before the user sees any of them.
- **No ad-hoc exceptions.** There is no writing task small enough, informal enough, or fast enough to skip the filter. When in doubt, run it.
