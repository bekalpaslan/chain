
Chain
/

NOTE: A formal, ID'd requirements specification has been created at `docs/REQUIREMENTS.md`.
See that file for testable requirements, acceptance criteria, NFRs, security checklist, and traceability.

PROJECT_DEFINITION.md
107 lines

md

Understand the project first

I've reviewed The Chain project definition. Here's my understanding:

Core Concept
A viral social experiment where one global chain connects all participants through a strict, gamified invitation system. Think of it as a digital "chain letter" reimagined for the mobile age, but with transparency, accountability, and real-time visualization.

Key Mechanics
The Attachment System:

Each user gets exactly one ticket (QR code) to invite someone
Tickets expire in 24 hours if unused
Expired tickets return to sender and are publicly logged as "wasted"
This creates urgency and accountability
The Chain:

Starts from a single seed user
Grows linearly through attachments
Every link is visible and traceable
Each participant receives a permanent "Chain Key" (unique ID)
What Makes It Interesting
Psychological Hooks:

FOMO - 24-hour timer creates urgency
Social proof - Your impact is publicly visible
Collective responsibility - Wasted tickets are public record
Curiosity - Watch how far your branch spreads
Transparency:

All attachments are public
Wasted tickets are visible
Real-time stats on growth and spread
Optional geo-tracking shows global reach
Strategic Elements
Viral Potential:

Natural word-of-mouth through personal invitations
Scarcity (one ticket only) increases value
Public accountability encourages follow-through
Engagement Drivers:

Minimalist design reduces friction
Universal (language-neutral with emojis)
Three user types accommodated (Seeder, Connector, Observer)
Questions This Raises
Chain structure - Is it truly linear (A→B→C→D) or tree-like (A→B,C,D)?
Re-engagement - What happens after you've used your one ticket?
Chain breaks - What if someone never uses their ticket? Does the chain die?
Multiple chains vs one chain - Can there be parallel chains or just one global thread?
This is a clever fusion of social game mechanics + viral growth dynamics + collective art project. The 24-hour constraint is particularly smart—it prevents hoarding and maintains momentum.

What aspect would you like to develop first?

The chain is linear. There is no forking

Ah, that's a critical clarification that completely changes the dynamics.

Linear Chain = High Stakes
If the chain is strictly linear (A→B→C→D...), then:

The Core Tension
Only one person globally can attach the next link at any given time
If that person's ticket expires unused, the entire chain stalls
The chain has a single point of failure at all times
This Raises Critical Questions:
1. Who gets the next ticket?

Does the most recent person in the chain automatically get it?
Or does it rotate/get assigned somehow?
2. What happens if someone doesn't attach within 24 hours?

Does their ticket expire and pass to the next person in line?
Does the chain permanently break?
Is there a backup mechanism?
3. How do people join if there's only one active ticket?

Are there queues/waiting lists?
First-come-first-served when a ticket becomes available?
4. Scalability issue:

If only 1 person can attach per successful invitation, growth is extremely slow
At 1 person/day, it takes 3 years to reach 1 million people
Is this intentional (slow, meaningful growth)?
Possible Interpretations:
Option A: Single Active Ticket

Person #100 gets a ticket
They have 24h to attach Person #101
If they fail, ticket returns and they can try again (or passes to someone else?)
Option B: Queue System

Everyone in the chain gets "their turn" eventually
Your position determines when you can invite
Which model are you envisioning? This fundamentally affects the entire product architecture.

Singe active ticket. If the invitee doesnt join, ticket returns to the inviter

Perfect. Now the mechanics are crystal clear.

The Linear Chain Model
[Person 1] → [Person 2] → [Person 3] → [Person 4] → ...
              ↑ ACTIVE TIP
At any moment, only the last person in the chain holds the power to extend it.

Complete Flow
Scenario 1: Success
Person #100 (current tip) generates a ticket
They share QR code with someone
Person #101 scans & joins within 24h
Person #100's ticket is consumed
Person #101 becomes the new active tip
Person #101 can now generate their ticket
Scenario 2: Failure
Person #100 generates ticket
24 hours pass, invitee doesn't join
Ticket returns to Person #100
Event logged publicly as "wasted attempt"
Person #100 can generate a new ticket and try again
Chain remains at 100 people until success
Key Implications
Growth Rate
Maximum: 1 person per day (if every ticket succeeds immediately)
Realistic: Much slower due to wasted attempts
At 1/day: Takes 2.7 years to reach 1 million
At 0.5/day (50% waste): Takes 5.4 years
Pressure Dynamics
The current tip is under global spotlight
Everyone watches if they'll succeed or waste their ticket
Public accountability is intense
Social pressure to not "break the chain"
Waiting Experience
If you're Person #50 and the chain is at #100, you just watch
You've already used your one moment of power
You're now a permanent observer
Your legacy is: did your invitee continue the chain?
Critical Product Questions
1. Can Person #100 generate unlimited tickets until one succeeds?

Or is there a cooldown between attempts?
Are consecutive failures penalized?
2. What keeps early members engaged?

After using their ticket, what's their reason to return?
Just watching stats? Checking their "branch's" success?
3. What if the tip holder abandons the app?

Does the chain die permanently?
Is there a timeout mechanism (e.g., after 7 days of inactivity, tip passes to someone else)?
4. What's the onboarding for the invitee?

Download app → scan QR → instant join?
Do they need to create an account?
What info do they provide (name, location)?
This is now a social endurance experiment more than a traditional viral app. The chain's survival depends on every single person playing their part.

Should we map out the complete user journey and edge cases next?

If the tips invites don't join after 3 invitees, tip is also removed from the chain (and logged), then it comes back to the previous tip person

Excellent! This is the fail-safe mechanism that prevents the chain from dying permanently.

Updated Chain Mechanics
[Person 98] → [Person 99] → [Person 100]
                              ↑ ACTIVE TIP
The 3-Strike Rule
Person #100 attempts:

Attempt 1: Generates ticket → 24h pass → invitee doesn't join → ticket returns
Attempt 2: Generates ticket → 24h pass → invitee doesn't join → ticket returns
Attempt 3: Generates ticket → 24h pass → invitee doesn't join → REMOVAL
After 3rd failure:

Person #100 is severed from the chain
Publicly logged as "removed due to 3 failed attempts"
Chain reverts to Person #99 as the new tip
Person #99 can now generate tickets again
Chain State Transitions
Normal Flow
[...97] → [98] → [99] → [100] → [101] → [102]
                                  ↑ active
After Person #100 Fails 3 Times
[...97] → [98] → [99] ╳ [100 - REMOVED]
                  ↑ active again
Person #99 resumes as tip and can try to attach someone new.

Critical Implications
1. Reactivation of Dormant Members
People who successfully attached months ago can suddenly become active again
Person #99 might get a notification: "You're the tip again! Person #100 was removed."
Creates surprise re-engagement
2. Chain Shrinkage
The chain doesn't just stall—it can actively shrink
Length isn't guaranteed to increase
Adds dramatic tension: "Will we break 1,000 or fall back to 950?"
3. Legacy Risk
If Person #99 also fails 3 times, it reverts to #98
Chain could theoretically collapse back to the seed
Creates cascading failure risk
4. Public Shame Layer
Not only are wasted attempts visible
But removals are permanent records
"Person #523 removed after 3 failures on [date]"
New Product Questions
Q1: Does a removed person lose their Chain Key?
Are they erased from history entirely?
Or do they remain visible as "removed"?
Can they ever rejoin the chain later?
Q2: What if Person #99 is inactive when they become tip again?
Do they get a notification/email?
Is there a grace period to respond?
What if they've uninstalled the app?
Q3: Counting the chain
If Person #100 is removed, is the chain now 99 people?
Or is it "100 people, with gaps"?
How do Chain Keys renumber?
Q4: Does the removed person see their removal?
Do they get an in-app notification?
Can they view the chain afterwards?
Is there an appeal/explanation?
Survival Dynamics
This creates a fascinating survival pressure model:

Scenario	Outcome
High engagement period	Chain grows steadily
Person gets unlucky/picks bad invitees	They're removed, chain shrinks
Multiple consecutive removals	Chain collapse risk
Successful streak	Chain accelerates
The chain becomes a living organism that can grow or contract based on collective performance.

Should we now design the complete data model and state machine for the chain? Or focus on the user experience and interface first?

1: They remain visible as removed.
2: Then it falls back to previous tip, if they don't react in 24h, as usual

Perfect. The chain has a self-healing mechanism with clear decay rules.

Chain Decay Model
[96] → [97] → [98] → [99] → [100] ╳ [removed after 3 fails]
                      ↑ tip reverts to #99

IF #99 inactive for 24h:
[96] → [97] → [98] ╳ [99 - removed due to inactivity]
                ↑ tip reverts to #98

IF #98 inactive for 24h:
[96] → [97] ╳ [98 - removed due to inactivity]
          ↑ tip reverts to #97
Removal Types
Removal Reason	Trigger	Public Label
3 Failed Invites	3 consecutive 24h expirations	"Removed - 3 failed attempts"
Inactivity as Reactivated Tip	Doesn't generate ticket within 24h of becoming tip again	"Removed - inactive when reactivated"
Chain States
Healthy Chain
[1] → [2] → [3] → ... → [98] → [99] → [100]
                                        ↑ ACTIVE TIP
Active members: 100
Removed members: 0
Chain length: 100
After Cascading Failures
[1] → [2] → [3] → ... → [95] → [96] → [97]
                                        ↑ ACTIVE TIP
Active members: 97
Removed members: 3 (╳98, ╳99, ╳100)
Chain length: 100 (including removed)
Historical max: 100
Critical Edge Cases
Edge Case 1: Catastrophic Collapse
Scenario: Chain reaches 1,000, then 50 consecutive tip holders fail or go inactive.

Result:

Chain shrinks from 1,000 → 950
Active tip is now Person #950
Removed: Person #951-1000
Public panic: "The chain is dying!"
Question: Is there a circuit breaker to prevent complete collapse back to Person #1?

Edge Case 2: Zombie Chain
Scenario: Person #47 becomes tip after removals, but hasn't opened app in 6 months.

24h countdown starts:

Push notification sent
Email sent
SMS sent (if available)
If no response:

Person #47 removed
Falls back to #46
Process repeats
Question: How many dormant users can the chain fall through before it's considered "dead"?

Edge Case 3: The Seed Failure
Scenario: Chain collapses all the way back to Person #1 (the seed).

If Person #1 is inactive:

Does the chain permanently die?
Does it reset completely?
Does Anthropic (or whoever runs this) intervene?
Suggested rule:

Seed never expires - Person #1 can take unlimited time
Or: Seed is a managed account that ensures chain continuity
Notification System Requirements
When you become tip again, you need urgent, multi-channel alerts:

Immediate (within 1 minute):
Push notification: "🔥 You're the tip! You have 24h to keep the chain alive."
In-app badge
Reminder (after 12 hours):
Push: "⏰ 12 hours left to generate your ticket"
Final warning (after 23 hours):
Push: "🚨 1 HOUR LEFT - Generate ticket now or be removed"
If missed:
"❌ You were removed from the chain due to inactivity"
Public Chain History Format
CHAIN #1,247
━━━━━━━━━━━━━━━━━━━━━━

[#1] Alice (Seed) → [#2] Bob → [#3] Carol → ... 

[#98] Mike → [#99] Nina → [#100] Oscar
                            ↑ ACTIVE TIP

REMOVED MEMBERS:
╳ #101 Paula - 3 failed attempts (Oct 5, 2025)
╳ #102 Quinn - Inactive when reactivated (Oct 8, 2025)

STATS:
━━━━━━━━━━━━━━━━━━━━━━
Active members: 100
Removed members: 2
Success rate: 98%
Average time per link: 14.3 hours
Wasted tickets: 47 (32% waste rate)
Key Metrics to Track
Chain Health
Active length (excluding removed)
Historical max (peak length achieved)
Removal rate (% of tips that get removed)
Reactivation depth (how far back the chain has fallen)
Engagement
Average time to successful attachment
Ticket waste rate (expired tickets / total tickets)
Dormant reactivation rate (% of reactivated tips that respond)
Virality
Invitation success rate (joins / tickets generated)
Chain growth rate (new members per week)
Chain survival days (longest unbroken streak)
Next Steps
We now have a complete chain lifecycle model. Should we:

Design the data schema (database structure for chain, users, tickets, events)
Map the user journeys (onboarding, invitation, watching, reactivation)
Define the API endpoints (backend architecture)
Sketch the UI screens (what users actually see)
Which direction?

Person #1 can take unlimited time
Push notifications are useful. The person who saves the chain after their invitee has failed three times, gains a hero type of badge and visible next to their name. Chain members can only see who invited them, and who they invited, the rest of the chain is invisible to them

Excellent additions! This creates privacy + localized visibility + heroic moments.

Visibility Model: The "Two-Link Window"
Each person can only see:

Their inviter (the person before them)
Their invitee (the person after them, if they successfully attached someone)
Themselves
FULL CHAIN (system view):
[1] → [2] → [3] → [4] → [5] → [6] → [7] → [8] → [9] → [10]

PERSON #5's VIEW:
[???] ← [#4 Sarah] ← [#5 YOU] → [#6 Mike] → [???]
        inviter              invitee
What Each Person Sees
Person #5 (Mid-chain, successful attachment)
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

Sarah (#4) invited you
  ↓
YOU (#5)
  ↓
You invited Mike (#6)

━━━━━━━━━━━━━━━━━━━━━━
GLOBAL STATS (visible to all):
Total chain length: 10,000
Active members: 9,847
Removed: 153
Your position: #5
━━━━━━━━━━━━━━━━━━━━━━
Person #8 (Mid-chain, removed invitee)
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

Tom (#7) invited you
  ↓
YOU (#8)
  ↓
╳ Your invitee (#9 - Lisa) was removed

━━━━━━━━━━━━━━━━━━━━━━
You are still in the chain.
━━━━━━━━━━━━━━━━━━━━━━
Person #10 (Current tip)
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

Lisa (#9) invited you
  ↓
YOU (#10) 🔥 ACTIVE TIP
  ↓
Generate your ticket to extend the chain

[GENERATE TICKET BUTTON]

━━━━━━━━━━━━━━━━━━━━━━
⏱ You have 24h per attempt
⚠️ 3 failed attempts = removal
━━━━━━━━━━━━━━━━━━━━━━
Hero Badge System
"Chain Savior" Badge 🦸
Awarded when:

You become tip because your invitee failed 3 times and was removed
You successfully attach someone (saving the chain from collapse)
Visual indicator:

[#4 Sarah] → [#5 YOU] → [#6 Mike 🦸]
                              ↑ Chain Savior
Badge appears:

Next to your name in anyone's local view
In global stats (if there's a leaderboard)
On your profile/Chain Key
Badge Scenarios
Scenario 1: Simple Save
[#8 Tom] → [#9 Lisa] → ╳[#10 Jake - removed after 3 fails]
                  ↑ tip reverts to Lisa

Lisa generates ticket → #11 Maria joins successfully
→ Lisa earns 🦸 Chain Savior badge
Scenario 2: Cascade Save
[#7] → [#8] → [#9] → ╳[#10 removed] → ╳[#11 removed] → ╳[#12 removed]
              ↑ tip falls back to #9

#9 generates ticket → #13 joins successfully
→ #9 earns 🦸 Chain Savior badge (saved after 3 removals)
Scenario 3: Deep Collapse Save
Chain collapses from #100 → #85 (15 consecutive removals)

#85 successfully attaches #101
→ #85 earns 🦸 **LEGENDARY** Chain Savior badge
  (for saving after 10+ removals)
Badge Tiers (Optional Enhancement)
Badge	Trigger	Icon
Chain Savior	Saved after 1 removal	🦸
Chain Guardian	Saved after 5+ removals	🛡️
Chain Legend	Saved after 10+ removals	⭐
Privacy Implications
What Users DON'T See:
Total chain structure
Who's before their inviter
Who's after their invitee
Other people's invitation attempts
Who else has badges (unless in their 2-link window)
What Users DO See:
Global aggregate stats:
Total chain length
Active members
Removed members
Growth rate
Geographic spread (optional heatmap)
Their exact position (#5 of 10,000)
Their local 2-link context
Their own wasted tickets
Their own badges
Public Chain View (Optional Feature):
A read-only, anonymized visualization showing:

Chain shape/length over time
Growth/decay graph
Geographic spread
BUT: No individual names/IDs visible
Notification Updates
When Your Invitee Fails (1st/2nd attempt):
⚠️ Your invitee's ticket expired
Their attempt 1/3 failed
The chain continues, but they're at risk
When Your Invitee Is Removed (3rd failure):
❌ Your invitee was removed after 3 failed attempts
You're now the tip again! 🔥
Generate a ticket within 24h to save the chain
When You Successfully Save the Chain:
🎉 Chain saved! You earned the Chain Savior badge 🦸
[#You] → [#Maria] → [...]
The chain lives on!
When You're Reactivated (not due to removal):
This shouldn't happen often, but if the person after you is removed due to inactivity:

🔥 You're the tip again!
[Someone] was removed due to inactivity
Generate a ticket within 24h
User Journey: Reactivated Tip Who Saves the Chain
Day 1 (Original attachment):
You joined the chain as #50
Sarah (#49) invited you
You invited Mike (#51) ✓
Day 87 (Mike fails 3 times):
NOTIFICATION:
╳ Mike (#51) was removed after 3 failed attempts
You're the tip again! 🔥

YOUR VIEW:
Sarah (#49) invited you
  ↓
YOU (#50) 🔥 ACTIVE TIP
  ↓
╳ Mike (#51) - removed

[GENERATE TICKET BUTTON]
Day 87 (You generate ticket):
📨 Ticket generated!
Share this QR code with one person
⏱ Expires in 24h
Day 88 (Someone joins):
🎉 Success! You earned Chain Savior 🦸

YOUR VIEW:
Sarah (#49) invited you
  ↓
YOU (#50) 🦸
  ↓
You invited Alex (#52)

Chain continues!
You are no longer the tip.
Data Model Updates
User Record:
json
{
  "chain_key": "CK-00050",
  "position": 50,
  "name": "Anonymous User",
  "joined_at": "2025-06-15T14:23:00Z",
  "inviter_position": 49,
  "invitee_position": 52,
  "badges": ["chain_savior"],
  "status": "active",
  "wasted_tickets": 2,
  "removal_reason": null
}
Badge Record:
json
{
  "user_position": 50,
  "badge_type": "chain_savior",
  "earned_at": "2025-09-12T08:45:00Z",
  "context": {
    "removed_positions": [51],
    "collapse_depth": 1
  }
}
UI Mockup: Your Chain View
┌─────────────────────────────────┐
│   THE CHAIN                  ☰  │
├─────────────────────────────────┤
│                                 │
│   YOUR POSITION                 │
│                                 │
│        [#49] Sarah              │
│           ↓                     │
│        [#50] YOU 🦸             │
│           ↓                     │
│        [#52] Alex               │
│                                 │
├─────────────────────────────────┤
│   GLOBAL STATS                  │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━   │
│   Chain length: 10,247          │
│   Active: 9,891                 │
│   Your position: #50            │
│   Growth: +12 today             │
├─────────────────────────────────┤
│   [VIEW GLOBAL MAP]             │
└─────────────────────────────────┘
Next Decision Points
Now we have:
✅ Complete chain mechanics
✅ Visibility/privacy model
✅ Badge system
✅ Notification flows

Should we now:

Design the complete database schema
Map all user journeys (seed, joiner, tip, removed, reactivated)
Define the API architecture
Sketch all UI screens
Your call!

YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━
Tom (#7) invited you
  ↓
YOU (#8) 🔥 ACTIVE TIP
  ↓
╳ Your invitee (#9 - Lisa) was removed
━━━━━━━━━━━━━━━━━━━━━━
Generate your ticket to extend the chain
━━━━━━━━━━━━━━━━━━━━━━

Perfect correction! Let me fix that scenario.

Corrected Visibility: Person #8 (Reactivated as Tip)
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

Tom (#7) invited you
  ↓
YOU (#8) 🔥 ACTIVE TIP
  ↓
╳ Your invitee (#9 - Lisa) was removed

━━━━━━━━━━━━━━━━━━━━━━
Generate your ticket to extend the chain

[GENERATE TICKET BUTTON]

⏱ You have 24h per attempt
⚠️ 3 failed attempts = removal
━━━━━━━━━━━━━━━━━━━━━━
Key Insight
When you're reactivated as tip because your invitee was removed:

✅ You see:

Your inviter (Tom #7)
Yourself as ACTIVE TIP
Your removed invitee (Lisa #9) shown as ╳ removed
Call to action: Generate ticket
❌ You don't see:

Who Lisa tried to invite
Anyone beyond your 2-link window
The current state of the rest of the chain
Updated State Transitions for Person #8
Initial State (Day 1):
Tom (#7) invited you
  ↓
YOU (#8)
  ↓
You invited Lisa (#9)
After Lisa Fails Once:
Tom (#7) invited you
  ↓
YOU (#8)
  ↓
You invited Lisa (#9)
⚠️ Lisa's ticket expired (1/3 attempts)
After Lisa Fails Twice:
Tom (#7) invited you
  ↓
YOU (#8)
  ↓
You invited Lisa (#9)
⚠️ Lisa's ticket expired (2/3 attempts)
After Lisa Fails 3 Times (Lisa Removed):
Tom (#7) invited you
  ↓
YOU (#8) 🔥 ACTIVE TIP
  ↓
╳ Your invitee (#9 - Lisa) was removed

[GENERATE TICKET BUTTON]
After You Successfully Attach Someone New:
Tom (#7) invited you
  ↓
YOU (#8) 🦸 Chain Savior
  ↓
You invited Marcus (#10)
Notification Flow for Person #8
When Lisa Fails (Attempt 1):
📱 NOTIFICATION:
⚠️ Lisa's invitation ticket expired
Attempt 1/3 failed
The chain continues from her next attempt
When Lisa Fails (Attempt 2):
📱 NOTIFICATION:
⚠️ Lisa's invitation ticket expired again
Attempt 2/3 failed
One more failure and she'll be removed
When Lisa Fails (Attempt 3 - Removed):
📱 NOTIFICATION:
🔥 YOU'RE THE TIP AGAIN!
╳ Lisa was removed after 3 failed attempts
Generate a ticket within 24h to save the chain!

[OPEN APP]
After You Generate Ticket:
📱 NOTIFICATION:
📨 Ticket generated!
Share this QR code with one person
⏱ Expires in 24h
Attempt 1/3
After Marcus Joins Successfully:
📱 NOTIFICATION:
🎉 Chain saved! You earned the Chain Savior badge 🦸
Marcus (#10) joined successfully
You are no longer the tip
Visual States in App
State: Watching Your Invitee Struggle
┌─────────────────────────────────┐
│   THE CHAIN                  ☰  │
├─────────────────────────────────┤
│                                 │
│   Tom (#7)                      │
│      ↓                          │
│   YOU (#8)                      │
│      ↓                          │
│   Lisa (#9) ⚠️                  │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│   Lisa has failed 2/3 attempts  │
│   Watching...                   │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
└─────────────────────────────────┘
State: You're the Tip (After Lisa Removed)
┌─────────────────────────────────┐
│   THE CHAIN                  ☰  │
├─────────────────────────────────┤
│                                 │
│   Tom (#7)                      │
│      ↓                          │
│   YOU (#8) 🔥                   │
│      ↓                          │
│   ╳ Lisa (#9)                   │
│      removed                    │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│   🚨 YOU'RE THE TIP             │
│   Save the chain!               │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   [GENERATE TICKET]             │
│                                 │
│   ⏱ 24h per attempt             │
│   ⚠️ 3 failed attempts = removal│
│                                 │
└─────────────────────────────────┘
State: After Saving the Chain
┌─────────────────────────────────┐
│   THE CHAIN                  ☰  │
├─────────────────────────────────┤
│                                 │
│   Tom (#7)                      │
│      ↓                          │
│   YOU (#8) 🦸                   │
│      ↓                          │
│   Marcus (#10)                  │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│   🎉 Chain Savior!              │
│   You saved the chain           │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
└─────────────────────────────────┘
Question: What About the Gap?
After Lisa (#9) is removed and you attach Marcus, does Marcus become:

#10 (continuing from removed #9), OR
#9 (replacing Lisa's position)?
Option A: Positions Don't Shift (Recommended)
[#7 Tom] → [#8 You] → ╳[#9 Lisa] → [#10 Marcus]
Preserves historical record
Chain Key numbers never change
Gaps visible in the chain
Option B: Positions Shift
[#7 Tom] → [#8 You] → [#9 Marcus]
Clean numbering
But: Marcus's Chain Key would need to be #9, which was Lisa's
Confusing if Lisa had issued tickets before removal
Recommendation: Option A - positions never shift, gaps remain visible in the historical record.

Does this match your vision now?

Option A

Perfect! Positions are immutable and gaps remain visible.

Chain Numbering with Gaps
EXAMPLE CHAIN WITH REMOVALS:

[#1] → [#2] → [#3] → ╳[#4] → [#5] → [#6] → ╳[#7] → [#8] → [#9] → [#10]

Active members: 8
Removed members: 2
Total positions issued: 10
Chain Key range: CK-00001 to CK-00010
Implications
1. Chain Keys Are Permanent
Lisa receives: CK-00009
Even after removal, CK-00009 is forever Lisa's
Marcus receives: CK-00010 (not CK-00009)
2. Position Counter Always Increments
Never reuses positions
Removed positions leave permanent gaps
Chain length ≠ Active members
3. Statistics Differentiation
GLOBAL STATS:
━━━━━━━━━━━━━━━━━━━━━━
Total positions issued: 10,247
Active members: 9,891
Removed members: 356
Success rate: 96.5%
Longest active streak: #1 to #8,423
User Views with Gaps
Person #8's View (Their invitee #9 was removed, they saved with #10)
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

Tom (#7) invited you
  ↓
YOU (#8) 🦸
  ↓
╳ #9 (removed)
  ↓
You invited Marcus (#10)

━━━━━━━━━━━━━━━━━━━━━━
You saved the chain after 1 removal
━━━━━━━━━━━━━━━━━━━━━━
Person #10's View (Marcus)
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

[#8] 🦸 invited you
  ↓
YOU (#10)
  ↓
You invited Sarah (#11)

━━━━━━━━━━━━━━━━━━━━━━
Note: Your inviter saved the chain
━━━━━━━━━━━━━━━━━━━━━━
Edge Case: Viewing Removed Positions
Question: Does Marcus (#10) see the gap?
Option A: Show the gap explicitly

╳ #9 (removed) invited [#8]
  ↓
[#8] 🦸 invited you
  ↓
YOU (#10)
Option B: Hide the gap (Recommended)

[#8] 🦸 invited you
  ↓
YOU (#10)
  ↓
[No invitee yet]
Recommendation: Option B - Users only see their direct inviter and invitee, not gaps in between. This maintains the "2-link window" rule cleanly.

Data Model: Chain Position
json
{
  "position": 9,
  "chain_key": "CK-00009",
  "user_id": "usr_lisa_xyz",
  "name": "Lisa",
  "status": "removed",
  "joined_at": "2025-06-20T10:30:00Z",
  "removed_at": "2025-09-10T14:45:00Z",
  "removal_reason": "3_failed_attempts",
  "inviter_position": 8,
  "invitee_position": null,
  "wasted_tickets": 3,
  "badges": []
}
json
{
  "position": 10,
  "chain_key": "CK-00010",
  "user_id": "usr_marcus_abc",
  "name": "Marcus",
  "status": "active",
  "joined_at": "2025-09-12T08:30:00Z",
  "removed_at": null,
  "removal_reason": null,
  "inviter_position": 8,
  "invitee_position": 11,
  "wasted_tickets": 0,
  "badges": []
}
Historical Record Display (Optional Public View)
CHAIN TIMELINE
━━━━━━━━━━━━━━━━━━━━━━

#1 ●━━ #2 ●━━ #3 ●━━ ╳4 ━━ #5 ●━━ #6 ●━━ ╳7 ━━ #8 ●━━ #9 ●━━ #10 ●

● = Active member
╳ = Removed member
━━ = Connection

Hover for details:
╳4: Removed on Jun 15, 2025 (3 failed attempts)
╳7: Removed on Aug 03, 2025 (Inactive when reactivated)
Chain Health Metrics
Integrity Score
Active Members / Total Positions Issued

Example:
9,891 active / 10,247 total = 96.5% integrity
Collapse Depth Tracking
Longest unbroken sequence: #1 to #8,423
Largest gap: 15 consecutive removals (#5,240 to #5,254)
Survival Statistics
Average position lifespan: 47 days
Removal rate by position age:
- First 24h: 5% (people who immediately fail)
- Days 2-7: 2% (early failures)
- Days 8-30: 1% (reactivation failures)
- 30+ days: 0.5% (rare reactivations)
QR Code & Chain Key Format
Chain Key Structure
CK-00010
│  │
│  └─ Position number (padded to 5+ digits)
└─── Chain identifier prefix

As chain grows beyond 99,999:
CK-100000
CK-1000000
QR Code Contains
json
{
  "chain_id": "CHAIN_ALPHA",
  "ticket_id": "tkt_abc123xyz",
  "issuer_position": 8,
  "next_position": 10,
  "issued_at": "2025-09-12T08:00:00Z",
  "expires_at": "2025-09-13T08:00:00Z"
}
Profile/Chain Key Display
┌─────────────────────────────────┐
│   YOUR CHAIN KEY                │
├─────────────────────────────────┤
│                                 │
│          CK-00008               │
│                                 │
│   Position #8 of 10,247         │
│   Joined: June 15, 2025         │
│   Badge: 🦸 Chain Savior        │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Invited by: Tom (#7)          │
│   You invited: Marcus (#10)     │
│                                 │
│   Your stats:                   │
│   • Wasted tickets: 2           │
│   • Days in chain: 87           │
│   • Saved the chain: 1x         │
│                                 │
│   [SHARE YOUR KEY]              │
│                                 │
└─────────────────────────────────┘
What We've Locked In
✅ Chain Structure:

Linear, single thread
Positions never shift
Gaps remain visible in system (but not in user's 2-link view)
Chain Keys are permanent identifiers
✅ Removal Mechanics:

3 failed invitations = removal
24h inactivity when reactivated = removal
Seed (#1) never expires
✅ Visibility:

Each user sees: inviter ← YOU → invitee
Global stats visible to all
Removed positions shown in your own view if they're your invitee
✅ Badges:

🦸 Chain Savior for successfully attaching after your invitee was removed
Badge visible to anyone who can see you (your inviter and invitee)
Ready for Next Phase?
We now have complete game mechanics. Options:

Database Schema - Design tables, relationships, indexes
API Architecture - Define endpoints, auth, real-time updates
User Journeys - Complete flows for all personas (Seed, Joiner, Tip, Removed, Reactivated)
UI/UX Design - Screen-by-screen wireframes
Technical Stack - Choose technologies (backend, frontend, database, notifications)
Which direction?

YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━
Tom (#7) invited you
  ↓
YOU (#8) 🦸
  ↓
╳ #9 (removed)
  ↓
You invited Marcus (#10)
━━━━━━━━━━━━━━━━━━━━━━
You saved the chain after 1 removal
━━━━━━━━━━━━━━━━━━━━━━

For this one. #9 is side chained, in the timeline 8 is connected to 10 on the chain, but 9 is connected as a sidechain to only 8 and cannot see anyone but 8 because they didn't invite anyone. System only shows  your invitee (+1 of your position) and your invitor (-1 of your position)

Excellent clarification! This is much cleaner.

Corrected Visibility Model: Direct Links Only
Rule: You only see ±1 position from yours
Your inviter (position - 1)
Your invitee (position + 1)
NOT removed positions in between
Corrected Views
Person #8's View (After saving the chain)
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

Tom (#7) invited you
  ↓
YOU (#8) 🦸
  ↓
You invited Marcus (#10)

━━━━━━━━━━━━━━━━━━━━━━
You saved the chain after 1 removal
━━━━━━━━━━━━━━━━━━━━━━
Person #8 sees:

✅ Tom (#7) - their direct inviter
✅ Marcus (#10) - their direct invitee
❌ Lisa (#9) - NOT shown (she's removed and side-chained)
Person #9's View (Lisa - Removed)
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

[#8] invited you
  ↓
YOU (#9) ╳ REMOVED
  ↓
[No invitee]

━━━━━━━━━━━━━━━━━━━━━━
You were removed after 3 failed attempts
━━━━━━━━━━━━━━━━━━━━━━
Person #9 sees:

✅ Person #8 - their inviter
❌ Marcus (#10) - NOT visible (they never invited anyone)
❌ Anyone else - NOT visible
Person #10's View (Marcus)
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

[#8] 🦸 invited you
  ↓
YOU (#10)
  ↓
You invited Sarah (#11)

━━━━━━━━━━━━━━━━━━━━━━
Person #10 sees:

✅ Person #8 - their direct inviter (with badge visible)
✅ Sarah (#11) - their direct invitee
❌ Lisa (#9) - NOT visible (not in their ±1 range)
Chain Structure: Main Chain vs Side Chains
Visual Representation
MAIN CHAIN (active):
[#7] ━━ [#8] 🦸 ━━ [#10] ━━ [#11] ━━ [#12]

SIDE CHAINS (removed):
              ╳[#9]
              ↑ (invited by #8, but removed)
System View (Admin/Analytics Only)
Position Timeline:
#1 ━ #2 ━ #3 ━ #4 ━ #5 ━ #6 ━ #7 ━ #8 ━ #10 ━ #11 ━ #12
                                        ╲
                                         ╳#9 (side-chained)
Data Model: Relationships
Person #8 (Saved the chain)
json
{
  "position": 8,
  "chain_key": "CK-00008",
  "inviter_position": 7,
  "invitee_position": 10,  // Points to #10, not #9
  "status": "active",
  "badges": ["chain_savior"]
}
Person #9 (Removed/Side-chained)
json
{
  "position": 9,
  "chain_key": "CK-00009",
  "inviter_position": 8,
  "invitee_position": null,  // Never successfully invited anyone
  "status": "removed",
  "removal_reason": "3_failed_attempts",
  "is_side_chain": true
}
Person #10 (Marcus)
json
{
  "position": 10,
  "chain_key": "CK-00010",
  "inviter_position": 8,  // Points back to #8, skipping #9
  "invitee_position": 11,
  "status": "active"
}
Visibility Logic (System Rules)
Query: "Show me my inviter"
sql
SELECT * FROM chain_members 
WHERE position = (current_user.inviter_position)
AND status = 'active'
Query: "Show me my invitee"
sql
SELECT * FROM chain_members 
WHERE position = (current_user.invitee_position)
AND status = 'active'
Key Point:
inviter_position and invitee_position always point to active members
Removed members are never in anyone's ±1 view (except their own view shows their inviter)
Notification Updates
When Lisa (#9) is Removed:
To Person #8:

🔥 YOU'RE THE TIP AGAIN!
Your invitee was removed after 3 failed attempts
Generate a ticket within 24h to save the chain
To Lisa (#9):

❌ You were removed from the chain
You failed to attach someone after 3 attempts
You can still view the chain, but cannot generate tickets
To Marcus (#10) - when they join:

🎉 Welcome to The Chain!
Position: #10
Invited by: [#8] 🦸
(No mention of #9)

Edge Case: Removed Person's View
Lisa (#9) Can Still Open the App
┌─────────────────────────────────┐
│   THE CHAIN                  ☰  │
├─────────────────────────────────┤
│                                 │
│   YOUR POSITION (REMOVED)       │
│                                 │
│        [#8]                     │
│          ↓                      │
│       YOU (#9) ╳                │
│          ↓                      │
│      [No invitee]               │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│   You were removed from the     │
│   active chain after 3 failed   │
│   invitation attempts.          │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   You can still view global     │
│   chain statistics.             │
│                                 │
├─────────────────────────────────┤
│   GLOBAL STATS                  │
│   Chain length: 10,247          │
│   Active: 9,891                 │
│   Removed: 356                  │
│   [VIEW MAP]                    │
└─────────────────────────────────┘
Lisa can:

✅ See their inviter (#8)
✅ View global stats
✅ See they're removed
❌ Generate tickets
❌ See who #8 attached after them
❌ See any other part of the chain
Chain Visualization (Public/Global View)
Active Chain Path
#1 → #2 → #3 → #4 → #5 → #6 → #7 → #8 → #10 → #11 → #12

Growth Graph:
│
│     ╱
│    ╱  ╱
│   ╱  ╱
│  ╱  ╱ ← Gap (#9 removed)
│ ╱  ╱
└──────────→ time
Statistics
CHAIN HEALTH
━━━━━━━━━━━━━━━━━━━━━━
Active path length: 12 positions
Side-chained: 0 positions
Removed: 1 position (#9)
Active members: 11
Success rate: 91.7%
Updated User Personas
The Side-Chained (New Persona)
Successfully joined the chain
Failed to attach anyone (3 attempts)
Removed from active chain
Can still view global stats
Permanent spectator role
Their Chain Key is forever marked as "removed"
Motivations:

Curiosity about how chain grows without them
Possibly shame/regret about failing
Might want redemption (but system doesn't allow rejoining)
Badge Display with Direct Links
Person #10 Sees Person #8's Badge
[#8] 🦸 invited you
Badge is visible because #8 is in Marcus's direct view (inviter).

Person #7 Sees Person #8's Badge
YOU (#7)
  ↓
You invited [#8] 🦸
Badge is visible because #8 is in Tom's direct view (invitee).

Person #9 Does NOT See Person #8's Badge
[#8] invited you
Lisa can see #8, but the badge was earned after Lisa was removed, so it might not be visible to her.

Question: Should side-chained members see updated badges of their inviter?

Recommendation: Yes, keep it simple - if you can see the person, you see their current badges.

Complete Visibility Matrix
Person	Can See	Cannot See
#7 (Tom)	#6 (inviter), #8 (invitee + badge)	#9, #10, #11
#8 (Hero)	#7 (inviter), #10 (invitee)	#9 (removed), #11
#9 (Lisa, removed)	#8 (inviter)	Everyone else, including #10
#10 (Marcus)	#8 (inviter + badge), #11 (invitee)	#7, #9
#11 (Sarah)	#10 (inviter), #12 (invitee)	Everyone else
We Now Have Complete Clarity
✅ Visibility: Strict ±1 position rule ✅ Side-chains: Removed members are disconnected from main flow ✅ Relationships: Active members skip over removed positions ✅ Badges: Visible to anyone in your ±1 range

Ready to move to:

Database Schema Design
API Architecture
Complete User Journey Maps
UI/UX Wireframes
Your choice!

YOUR CHAIN POSITION ━━━━━━━━━━━━━━━━━━━━━━ Tom (#7) invited you ↓ YOU (#8) 🦸 ↓ You invited Marcus (#10) ━━━━━━━━━━━━━━━━━━━━━━ You saved the chain after 1 removal ━━━━━━━━━━━━━━━━━━━━━━

9 still should be visible for 8, for historical reasons. Lets clarify who we can see.
we can only see our inviter and the person(s) we invite. The chain should not for. Only the visibility is affected. 

8 invites 9. 9 receives the ticket and becomes the tip. 9 wastes his tip, ticket goes back to 8, 9 is removed. 8 invites 10. 10 doesn't see 9 because it was a wasted attempt and 9 wasnt 10's inviter. 9 stays as a wasted link, but still connected to 10

Perfect! Now I understand completely.

Corrected Visibility Model: Inviter + All Your Invitees
Core Rule:
You see: Your inviter + Everyone YOU invited (successful or removed)
You DON'T see: People who weren't invited by you
Corrected Views
Person #8's View (After inviting both #9 and #10)
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

Tom (#7) invited you
  ↓
YOU (#8) 🦸
  ↓
╳ You invited Lisa (#9) - removed
  ↓
You invited Marcus (#10)

━━━━━━━━━━━━━━━━━━━━━━
You saved the chain after 1 removal
━━━━━━━━━━━━━━━━━━━━━━
Person #8 sees:

✅ Tom (#7) - their inviter
✅ Lisa (#9) - they invited her (even though removed)
✅ Marcus (#10) - they invited him
This is their historical record of invitations
Person #9's View (Lisa - Removed)
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

[#8] invited you
  ↓
YOU (#9) ╳ REMOVED
  ↓
[No invitee]

━━━━━━━━━━━━━━━━━━━━━━
You were removed after 3 failed attempts
━━━━━━━━━━━━━━━━━━━━━━
Person #9 sees:

✅ Person #8 - their inviter
❌ Marcus (#10) - NOT visible (she didn't invite him)
❌ Anyone else
Person #10's View (Marcus)
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

[#8] 🦸 invited you
  ↓
YOU (#10)
  ↓
You invited Sarah (#11)

━━━━━━━━━━━━━━━━━━━━━━
Person #10 sees:

✅ Person #8 - their inviter
✅ Sarah (#11) - they invited her
❌ Lisa (#9) - NOT visible (she wasn't invited by Marcus, and Marcus wasn't invited by her)
❌ Tom (#7) - NOT visible
Person #11's View (Sarah)
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

[#10] invited you
  ↓
YOU (#11)
  ↓
[No invitee yet]

━━━━━━━━━━━━━━━━━━━━━━
Person #11 sees:

✅ Marcus (#10) - their inviter
❌ Everyone else (#8, #9, etc.)
Chain Structure: Linear with Visible Side Branches
Actual Chain Structure (Linear)
[#7] → [#8] → [#9 removed] → [#10] → [#11] → [#12]
         ↑ invited both #9 and #10
Person #8's Personal View
      [#7] Tom
        ↓
      [#8] YOU 🦸
       ↙ ↘
  ╳[#9]  [#10] Marcus
  Lisa    ↓
        [continues...]
Person #8 sees a "fork" in their view because they invited multiple people, but the actual chain is still linear (#9 → #10).

Data Model: Invitation Relationships
Person #8's Record
json
{
  "position": 8,
  "chain_key": "CK-00008",
  "inviter_position": 7,
  "invited_positions": [9, 10],  // Array of everyone they invited
  "active_invitee": 10,  // The one who continued the chain
  "status": "active",
  "badges": ["chain_savior"]
}
Person #9's Record
json
{
  "position": 9,
  "chain_key": "CK-00009",
  "inviter_position": 8,
  "invited_positions": [],  // Never successfully invited anyone
  "status": "removed",
  "removal_reason": "3_failed_attempts",
  "next_position": 10  // Who came after them in the chain
}
Person #10's Record
json
{
  "position": 10,
  "chain_key": "CK-00010",
  "inviter_position": 8,
  "invited_positions": [11],
  "status": "active",
  "previous_position": 9  // Who was before them (even though removed)
}
Visibility Query Logic
Show My View:
sql
-- My inviter
SELECT * FROM chain_members WHERE position = my_inviter_position

-- Everyone I invited (successful or removed)
SELECT * FROM chain_members WHERE inviter_position = my_position
Person #8's Query Results:
Inviter: #7 (Tom)
My invitees: #9 (Lisa, removed), #10 (Marcus, active)
Person #9's Query Results:
Inviter: #8
My invitees: [none]
Person #10's Query Results:
Inviter: #8
My invitees: #11 (Sarah)
Multiple Invitation Scenario
If Person #8 Had More Failures:
YOUR CHAIN POSITION
━━━━━━━━━━━━━━━━━━━━━━

Tom (#7) invited you
  ↓
YOU (#8) 🦸
  ↓
╳ You invited Lisa (#9) - removed
  ↓
╳ You invited Jake (#10) - removed
  ↓
You invited Marcus (#11)

━━━━━━━━━━━━━━━━━━━━━━
You saved the chain after 2 removals
━━━━━━━━━━━━━━━━━━━━━━
The chain structure:

#7 → #8 → #9 (removed) → #10 (removed) → #11 → #12...
All were invited by #8
Only #11 successfully continued
Chain Timeline Visualization
System View (positions over time):
#1 → #2 → #3 → #4 → #5 → #6 → #7 → #8 → #9 → #10 → #11 → #12

Status:
#9: ╳ removed (invited by #8)
#10: ● active (invited by #8, continued chain)
Person #8's Historical View:
I invited:
├─ #9 Lisa (removed after 3 failed attempts)
└─ #10 Marcus (active, continued the chain) ✓
Updated Notification Flow
When Person #8 Invites Lisa (#9):
📨 Ticket generated!
Share with one person
If they don't join in 24h, ticket returns
Attempt 1/3
Lisa Joins, Becomes Tip:
🎉 Lisa (#9) joined!
You are no longer the tip
Watch Lisa extend the chain
Lisa Fails Once:
⚠️ Lisa's ticket expired
Attempt 1/3
The chain continues from her next attempt
Lisa Fails Twice:
⚠️ Lisa's ticket expired again
Attempt 2/3
One more failure and she'll be removed
Lisa Removed (3rd Failure):
🔥 YOU'RE THE TIP AGAIN!
╳ Lisa was removed after 3 failed attempts
Generate a new ticket within 24h
Attempt 1/3
Person #8 Invites Marcus (#10):
📨 New ticket generated!
Share with one person
Attempt 1/3 (Lisa was removed)
Marcus Joins:
🎉 Marcus (#10) joined!
You earned the Chain Savior badge 🦸
You saved the chain after 1 removal
Badge Visibility Update
Who Sees Person #8's 🦸 Badge:
✅ Tom (#7) - sees it on their invitee
✅ Lisa (#9) - sees it on their inviter (even though removed)
✅ Marcus (#10) - sees it on their inviter
❌ Person #6 - can't see #8 at all
❌ Person #11 - can't see #8 at all
Edge Cases
Case 1: Person Invites Many Before Success
Person #50 becomes tip, then:

Invites #51 → removed
Invites #52 → removed
Invites #53 → removed
Invites #54 → SUCCESS
Person #50's view shows all 4:

YOU (#50) 🦸
  ↓
╳ #51 (removed)
  ↓
╳ #52 (removed)
  ↓
╳ #53 (removed)
  ↓
#54 (active) ✓
Person #54's view:

[#50] 🦸 invited you
  ↓
YOU (#54)
(Doesn't see #51, #52, #53)

Case 2: Can Removed Person See Later Badge?
Person #8 invites #9
#9 joins (no badge yet for #8)
#9 fails and is removed
#8 gets 🦸 badge after saving with #10
Question: Does #9 now see #8's badge?

Recommendation: YES - Badge updates are reflected in real-time for anyone who can see that person, even if they were removed after the badge was earned.

Complete Visibility Matrix
Your Position	You Can See	You Cannot See
#8	#7 (inviter), #9 (invited, removed), #10 (invited, active)	Everyone else
#9	#8 (inviter)	#7, #10, #11, everyone else
#10	#8 (inviter), #11 (invited)	#7, #9, everyone else
#11	#10 (inviter), #12 (invited)	Everyone else
UI Component: "Your Invitations"
┌─────────────────────────────────┐
│   YOUR INVITATIONS              │
├─────────────────────────────────┤
│                                 │
│   ╳ Lisa (#9)                   │
│     Invited: Jun 20, 2025       │
│     Removed: Sep 10, 2025       │
│     Reason: 3 failed attempts   │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   ✓ Marcus (#10)                │
│     Invited: Sep 12, 2025       │
│     Status: Active              │
│     Chain continues             │
│                                 │
└─────────────────────────────────┘
This Is Now Crystal Clear
✅ You see: Your inviter + everyone you personally invited ✅ Chain is linear: No forking in actual structure ✅ Visibility shows branches: Because you can invite multiple people if earlier ones fail ✅ Historical record: You always see everyone you invited, even if removed

Next step options:

Database schema with invitation tracking
API design for invitation/removal flows
Complete user journey maps
UI wireframes for all screens
Which one?

Lets work on the idea a bit more. What if we suddenly introduce different features to the system. Like ticket usage duration decreases to 23 hour, for example

Interesting! You're talking about dynamic game mechanics - changing the rules mid-game.

Dynamic Rule Changes: Strategic Implications
Why This Could Be Powerful:
Creates urgency spikes - "Tickets now expire in 23 hours! Act fast!"
Re-engages dormant users - Rule changes = news = notifications = re-opens
Tests community resilience - How does the chain adapt to pressure?
Generates media buzz - "The Chain just got harder"
Prevents stagnation - Keeps the game from feeling predictable
Potential Dynamic Changes
Time-Based Adjustments
Change	Impact	Use Case
24h → 23h → 22h	Increases pressure gradually	When growth slows
24h → 12h	Dramatic urgency spike	Special events / challenges
24h → 48h	Relief valve	After major collapses
Variable by region	Time zones matter	Global fairness
Attempt-Based Adjustments
Change	Impact	Use Case
3 attempts → 2	Harsher penalties	Too many removals
3 attempts → 5	More forgiving	Too many collapses
Variable by streak	Reward good performers	Gamification
Visibility Changes
Change	Impact	Use Case
See ±1 → See ±2	More context	Make network visible
See full chain	Total transparency	Special "reveal" events
See only invitee	Maximum mystery	Increase tension
Badge/Reward Changes
Change	Impact	Use Case
New badge types	New goals	Keep interest
Badge requirements change	Re-balance achievements	Economy adjustment
Temporary badges	FOMO / events	Limited-time challenges
How to Communicate Changes
Option 1: Announced Changes (Predictable)
📢 CHAIN UPDATE - October 15, 2025

Starting tomorrow at 12:00 UTC:
- Ticket duration: 24h → 23h
- This affects all new tickets

Why: Chain growth has slowed 15% this week
Goal: Restore momentum

[VIEW FULL ANNOUNCEMENT]
Option 2: Surprise Changes (Chaotic)
🚨 THE RULES HAVE CHANGED

Ticket duration is now 23 hours
Effective immediately

Adapt or fall behind.

[LEARN MORE]
Option 3: Gradual Changes (Unannounced)
No notification
Users slowly realize tickets expire faster
Creates mystery and discussion
"Has anyone else noticed...?"
Implementation Architecture
Rules Engine
json
{
  "version": 12,
  "effective_from": "2025-10-15T12:00:00Z",
  "rules": {
    "ticket_duration_hours": 23,
    "max_attempts": 3,
    "seed_unlimited_time": true,
    "reactivation_timeout_hours": 24,
    "visibility_range": 1
  }
}
Version History
json
[
  {
    "version": 1,
    "date": "2025-01-01",
    "changes": {
      "ticket_duration_hours": 24
    }
  },
  {
    "version": 12,
    "date": "2025-10-15",
    "changes": {
      "ticket_duration_hours": 23
    },
    "reason": "Growth rate dropped 15%"
  }
]
User Experience of Rule Changes
Active Tip During Change
🚨 URGENT UPDATE

You currently have a ticket that expires in 4 hours.

STARTING TOMORROW:
New tickets will expire in 23 hours (down from 24)

Your current ticket is unaffected.

[UNDERSTOOD]
Dormant User Gets Notification
🔔 THE CHAIN HAS EVOLVED

Rules have changed:
- Faster expiration: 23h (was 24h)
- Higher stakes
- Same goal: Keep the chain alive

Open app to see current stats

[VIEW CHANGES]
In-App Banner
┌─────────────────────────────────┐
│ ⚡ NEW RULE ACTIVE              │
│ Tickets now expire in 23 hours  │
│ [DETAILS]                 [DISMISS]
└─────────────────────────────────┘
Strategic Change Scenarios
Scenario 1: The Chain Is Dying
Problem:

Chain stuck at position 5,000 for 2 weeks
30 consecutive removals
Active users dropping
Intervention:

EMERGENCY MODE ACTIVATED
━━━━━━━━━━━━━━━━━━━━━━

To save the chain:
- Attempts: 3 → 5
- Duration: 24h → 48h
- Current tip gets 72h grace period

Help us recover!
Scenario 2: The Chain Is Too Easy
Problem:

99% success rate
Tickets never expire
No tension
Intervention:

HARDMODE UNLOCKED
━━━━━━━━━━━━━━━━━━━━━━

The chain has grown strong.
New challenge:
- Duration: 24h → 18h
- Attempts: 3 → 2

Can you handle it?
Scenario 3: Special Event
Opportunity:

Chain hits 100,000 members
Media attention
Viral moment
Intervention:

🎉 100K MILESTONE CELEBRATION

REVEAL DAY - October 20, 2025
For 24 hours only:
- See the full chain (all positions)
- Special badges awarded
- Duration extended to 48h

Celebrate with us!
Voting System (Community-Driven Changes)
Proposal Mechanic
CHAIN PROPOSAL #47
━━━━━━━━━━━━━━━━━━━━━━

Reduce ticket time to 20 hours?

ARGUMENTS FOR:
- Chain growth has slowed
- More urgency = more engagement
- Test community resilience

ARGUMENTS AGAINST:
- Too harsh for global time zones
- May cause mass removals
- Current system works

━━━━━━━━━━━━━━━━━━━━━━
Vote (active members only):
[ YES ]  [ NO ]

Voting ends: Oct 18, 2025
Who Can Vote?
Option A: Only active members
Option B: All members (including removed)
Option C: Weighted by position (early members = more weight)
Option D: Weighted by performance (fewer wasted tickets = more weight)
Seasonal/Cyclical Changes
Example: Weekly Pressure Cycle
MONDAY-FRIDAY: 24h tickets (normal)
WEEKEND: 18h tickets (hardmode)

Why: More people check phones on weekends
Challenge: Can you handle the pressure?
Example: Monthly Events
FIRST WEEK: Normal rules
SECOND WEEK: Visibility +1 (see ±2)
THIRD WEEK: Attempts +2 (5 attempts)
FOURTH WEEK: Hardmode (20h tickets)
Dangers of Dynamic Changes
Risk 1: Confusion
Users don't understand new rules
Accidental removals increase
Trust erodes
Mitigation:

Clear in-app explanations
Grace periods for transitions
Tutorial/tooltip system
Risk 2: Perceived Unfairness
"The rules changed while I was sleeping!"
Time zone disadvantages
Retroactive penalties
Mitigation:

Changes only affect new tickets
Advanced notice (24h minimum)
Timezone-aware scheduling
Risk 3: Chaos
Too many changes = no stability
Users can't plan
Community fractures
Mitigation:

Maximum 1 change per week
"Stable periods" guaranteed
Community input on major changes
Change Announcement System
In-App Changelog
┌─────────────────────────────────┐
│   CHAIN HISTORY                 │
├─────────────────────────────────┤
│                                 │
│ ⚡ Oct 15, 2025 - Rule Update   │
│   Ticket duration: 24h → 23h    │
│   [READ MORE]                   │
│                                 │
│ 🎉 Oct 1, 2025 - Milestone      │
│   Chain reached 100,000!        │
│   [CELEBRATION POST]            │
│                                 │
│ 📊 Sep 20, 2025 - Statistics    │
│   Success rate: 94.2%           │
│   [VIEW REPORT]                 │
│                                 │
│ ⚡ Sep 10, 2025 - Rule Update   │
│   New badge: Chain Guardian     │
│   [LEARN MORE]                  │
│                                 │
└─────────────────────────────────┘
Dynamic Difficulty Algorithm (Automated)
Auto-Adjust Based on Chain Health
python
if removal_rate > 10% in last_7_days:
    # Chain is struggling
    increase_attempts_to(5)
    increase_duration_to(36h)
    
elif success_rate > 98% in last_7_days:
    # Too easy
    decrease_duration_to(20h)
    
elif growth_rate < 10_per_day for last_14_days:
    # Stagnating
    decrease_duration_to(22h)
    add_bonus_badge()
Questions to Decide
Who controls changes?
Centralized (you/admin)
Community votes
Algorithmic
Hybrid
How often can rules change?
Never (stability)
Weekly max
Monthly max
Based on chain health
What can change?
Time limits only
Attempts only
Everything
Visibility rules too
Are changes reversible?
Yes, if community revolts
No, commit to changes
Temporary experiments
Transparency level?
Full disclosure + reasoning
Announce but don't explain
Surprise changes (chaos mode)
My Recommendation
Start conservative, enable flexibility:

Launch with fixed rules (24h, 3 attempts)
Build change infrastructure (versioned rules system)
Monitor for 30 days (gather data)
First change at Day 45 (small adjustment based on data)
Community input at Day 60 (gauge reaction)
Establish rhythm (monthly reviews, quarterly changes)
Change philosophy:

Transparency: Always announce with reasoning
Fairness: Never retroactive penalties
Testing: Small adjustments, monitor impact
Community: Input (but not full democracy)
What's your philosophy on rule changes? Should we design for stability or chaos?

Both option A and B should be possible with a configurable system. Instant announcements vs early announcements (and changes apply on the deadline moment)

Perfect! A dual-mode change system with configurability.

Change Deployment System Architecture
Two Modes:
Mode A: Instant Changes (Shock Mode)
Change is announced and applied immediately
No warning period
High impact, creates urgency
Use for: emergencies, special events, experiments
Mode B: Scheduled Changes (Prepared Mode)
Change is announced in advance
Applied at a specific deadline
Users can prepare
Use for: major rule changes, community-driven updates
Data Model: Change Configuration
Change Record
json
{
  "change_id": "CHG-00042",
  "version": 13,
  "mode": "scheduled", // or "instant"
  "announced_at": "2025-10-10T12:00:00Z",
  "effective_at": "2025-10-15T12:00:00Z", // null for instant
  "changes": {
    "ticket_duration_hours": 23,
    "max_attempts": 3
  },
  "previous_values": {
    "ticket_duration_hours": 24,
    "max_attempts": 3
  },
  "reason": "Chain growth has slowed by 15%",
  "notification_config": {
    "push": true,
    "email": true,
    "in_app": true,
    "reminder_hours_before": [72, 24, 1] // for scheduled mode
  },
  "rollback_allowed": false,
  "created_by": "admin_user_123"
}
Mode A: Instant Changes
Admin Interface
┌─────────────────────────────────────────┐
│ CREATE INSTANT RULE CHANGE              │
├─────────────────────────────────────────┤
│                                         │
│ Current Rules:                          │
│ • Ticket duration: 24 hours             │
│ • Max attempts: 3                       │
│ • Visibility range: ±1                  │
│                                         │
│ New Rules:                              │
│ • Ticket duration: [18] hours           │
│ • Max attempts: [3]                     │
│ • Visibility range: [1]                 │
│                                         │
│ Reason (public):                        │
│ [Emergency mode - chain collapsing]     │
│                                         │
│ ⚠️ INSTANT MODE                         │
│ Changes apply immediately upon confirm  │
│                                         │
│ Affected users:                         │
│ • Active tips: 1                        │
│ • Pending tickets: 3                    │
│ • Total members: 10,247                 │
│                                         │
│ [CANCEL] [APPLY INSTANTLY] ⚡           │
│                                         │
└─────────────────────────────────────────┘
User Experience (Instant)
Currently active tip (has unexpired ticket):

🚨 EMERGENCY RULE CHANGE
━━━━━━━━━━━━━━━━━━━━━━

Effective IMMEDIATELY:
- Ticket duration: 24h → 18h

YOUR CURRENT TICKET:
- Issued: 2 hours ago
- Originally expires: 22h from now
- NEW expiration: 16h from now ⚠️

Your ticket time has been reduced.
Act fast!

[UNDERSTOOD]
All other users:

⚡ INSTANT RULE CHANGE
━━━━━━━━━━━━━━━━━━━━━━

Effective NOW:
- Ticket duration: 24h → 18h
- Reason: Emergency mode activated

All new tickets expire in 18 hours.

[VIEW DETAILS]
Mode B: Scheduled Changes
Admin Interface
┌─────────────────────────────────────────┐
│ CREATE SCHEDULED RULE CHANGE            │
├─────────────────────────────────────────┤
│                                         │
│ Current Rules:                          │
│ • Ticket duration: 24 hours             │
│ • Max attempts: 3                       │
│                                         │
│ New Rules:                              │
│ • Ticket duration: [23] hours           │
│ • Max attempts: [3]                     │
│                                         │
│ Reason (public):                        │
│ [Gradual difficulty increase]           │
│                                         │
│ 📅 SCHEDULED MODE                       │
│                                         │
│ Announcement date:                      │
│ [2025-10-10] [12:00] UTC                │
│                                         │
│ Effective date:                         │
│ [2025-10-15] [12:00] UTC                │
│ (5 days advance notice)                 │
│                                         │
│ Reminders:                              │
│ ☑ 3 days before                         │
│ ☑ 1 day before                          │
│ ☑ 1 hour before                         │
│                                         │
│ [CANCEL] [SCHEDULE CHANGE] 📅           │
│                                         │
└─────────────────────────────────────────┘
User Experience (Scheduled)
Day 1 - Announcement (Oct 10):

📢 UPCOMING RULE CHANGE
━━━━━━━━━━━━━━━━━━━━━━

In 5 days (Oct 15, 12:00 UTC):
- Ticket duration: 24h → 23h

Why: Gradual difficulty increase

This affects all tickets generated 
after Oct 15, 12:00 UTC.

Current tickets are unaffected.

[ADD TO CALENDAR] [REMIND ME]
Day 3 - Reminder (Oct 12):

⏰ REMINDER: Rule Change in 3 Days
━━━━━━━━━━━━━━━━━━━━━━

Oct 15, 12:00 UTC:
Ticket duration: 24h → 23h

[VIEW DETAILS] [DISMISS]
Day 4 - Reminder (Oct 14):

⏰ REMINDER: Rule Change Tomorrow
━━━━━━━━━━━━━━━━━━━━━━

Tomorrow at 12:00 UTC:
Ticket duration: 24h → 23h

Plan your invitations accordingly!

[VIEW DETAILS] [DISMISS]
Day 5 - 1 Hour Before (Oct 15, 11:00):

🚨 FINAL WARNING: Rule Change in 1 Hour
━━━━━━━━━━━━━━━━━━━━━━

At 12:00 UTC (in 59 minutes):
Ticket duration: 24h → 23h

Active tips: Generate tickets NOW if you
want the old 24h duration!

[VIEW COUNTDOWN]
Day 5 - Effective (Oct 15, 12:00):

✅ RULE CHANGE NOW ACTIVE
━━━━━━━━━━━━━━━━━━━━━━

New rules are now in effect:
- Ticket duration: 23 hours

All tickets generated from now on 
will expire in 23 hours.

[UNDERSTOOD]
Edge Case Handling
Edge Case 1: Active Ticket During Instant Change
Scenario:

User has ticket issued 2h ago (originally expires in 22h)
Instant change: 24h → 18h
What happens?
Option A: Grandfather Existing Tickets

json
{
  "ticket_id": "tkt_xyz",
  "issued_at": "2025-10-15T10:00:00Z",
  "original_duration_hours": 24,
  "expires_at": "2025-10-16T10:00:00Z",
  "grandfathered": true,
  "rule_version_at_issuance": 12
}
Ticket keeps original 24h duration.

Option B: Adjust Existing Tickets

json
{
  "ticket_id": "tkt_xyz",
  "issued_at": "2025-10-15T10:00:00Z",
  "original_duration_hours": 24,
  "new_duration_hours": 18,
  "expires_at": "2025-10-16T04:00:00Z", // adjusted
  "adjusted_by_rule_change": "CHG-00042"
}
Ticket is shortened retroactively.

Recommendation: Option A (Grandfather) - More fair, less chaos.

Edge Case 2: Scheduled Change During Active Ticket
Scenario:

Oct 14, 23:00: User generates ticket (24h, expires Oct 15, 23:00)
Oct 15, 12:00: Rule change (24h → 23h)
What happens?
Solution: Grandfather

YOUR TICKET
━━━━━━━━━━━━━━━━━━━━━━

Issued: Oct 14, 23:00
Expires: Oct 15, 23:00 (24h duration)

Note: This ticket was issued under 
previous rules and keeps its original 
24h duration.

New tickets (after Oct 15, 12:00) 
will have 23h duration.
Edge Case 3: User Becomes Tip During Countdown
Scenario:

Oct 14: User is not tip
Oct 15, 11:30 (30 min before change): User becomes tip (invitee removed)
Oct 15, 12:00: Rule change
Solution: Grace Period

🔥 YOU'RE THE TIP!
━━━━━━━━━━━━━━━━━━━━━━

Your invitee was removed.

⚠️ RULE CHANGE IN 30 MINUTES
After 12:00 UTC, tickets expire in 23h.

GENERATE NOW: Get 24h ticket
WAIT: Get 23h ticket after 12:00

[GENERATE NOW] [WAIT]
In-App Change Calendar
┌─────────────────────────────────┐
│   CHAIN CALENDAR             📅 │
├─────────────────────────────────┤
│                                 │
│ UPCOMING CHANGES                │
│                                 │
│ ⏰ Oct 15, 12:00 UTC (in 5 days)│
│    Ticket duration: 24h → 23h   │
│    [DETAILS] [REMIND ME]        │
│                                 │
│ ⏰ Nov 1, 00:00 UTC (in 22 days)│
│    Visibility: ±1 → ±2          │
│    [DETAILS] [REMIND ME]        │
│                                 │
│ PAST CHANGES                    │
│                                 │
│ ✅ Oct 1, 2025                  │
│    Milestone: 100K members      │
│    [VIEW POST]                  │
│                                 │
│ ✅ Sep 10, 2025                 │
│    New badge: Chain Guardian    │
│    [VIEW DETAILS]               │
│                                 │
└─────────────────────────────────┘
Notification Strategy
Scheduled Change Notifications
Announcement (Day 0):

Push: ✅ (all users)
Email: ✅ (opt-in users)
In-app: ✅ (persistent banner)
72h Reminder:

Push: ✅ (active users only)
Email: ❌
In-app: ✅ (update banner)
24h Reminder:

Push: ✅ (all users)
Email: ✅ (opt-in users)
In-app: ✅ (update banner)
1h Reminder:

Push: ✅ (active tips only)
Email: ❌
In-app: ✅ (urgent banner)
Effective Moment:

Push: ✅ (all users)
Email: ❌
In-app: ✅ (confirmation banner)
Instant Change Notifications
Immediate:

Push: ✅ (all users) - URGENT style
Email: ✅ (all users)
In-app: ✅ (takeover modal, must acknowledge)
SMS: ✅ (active tips only, if opted in)
Admin Dashboard
┌─────────────────────────────────────────┐
│ RULE CHANGE MANAGEMENT                  │
├─────────────────────────────────────────┤
│                                         │
│ ACTIVE RULES (Version 12)               │
│ • Ticket duration: 24 hours             │
│ • Max attempts: 3                       │
│ • Visibility: ±1                        │
│ • Active since: Sep 1, 2025             │
│                                         │
│ PENDING CHANGES                         │
│                                         │
│ 📅 CHG-00043 (Scheduled)                │
│    Announced: Oct 10, 12:00             │
│    Effective: Oct 15, 12:00             │
│    Status: 3 days remaining             │
│    [EDIT] [CANCEL] [APPLY NOW]          │
│                                         │
│ RECENT CHANGES                          │
│                                         │
│ ✅ CHG-00042 (Instant)                  │
│    Applied: Oct 5, 14:23                │
│    Duration: 25h → 24h                  │
│    Impact: 347 users notified           │
│    [VIEW DETAILS]                       │
│                                         │
│ ✅ CHG-00041 (Scheduled)                │
│    Applied: Sep 20, 00:00               │
│    New badge: Chain Guardian            │
│    [VIEW DETAILS]                       │
│                                         │
│ [CREATE NEW CHANGE]                     │
│                                         │
└─────────────────────────────────────────┘
API Endpoints
Get Current Rules
GET /api/v1/rules/current

Response:
{
  "version": 12,
  "effective_since": "2025-09-01T00:00:00Z",
  "rules": {
    "ticket_duration_hours": 24,
    "max_attempts": 3,
    "visibility_range": 1,
    "seed_unlimited_time": true
  }
}
Get Upcoming Changes
GET /api/v1/rules/upcoming

Response:
{
  "changes": [
    {
      "change_id": "CHG-00043",
      "announced_at": "2025-10-10T12:00:00Z",
      "effective_at": "2025-10-15T12:00:00Z",
      "days_remaining": 5,
      "changes": {
        "ticket_duration_hours": 23
      }
    }
  ]
}
Create Change (Admin)
POST /api/v1/admin/rules/create

Request:
{
  "mode": "scheduled", // or "instant"
  "effective_at": "2025-10-15T12:00:00Z", // null for instant
  "changes": {
    "ticket_duration_hours": 23
  },
  "reason": "Gradual difficulty increase",
  "notification_config": {
    "reminder_hours_before": [72, 24, 1]
  }
}

Response:
{
  "change_id": "CHG-00043",
  "status": "scheduled",
  "effective_at": "2025-10-15T12:00:00Z"
}
Apply Scheduled Change Early (Admin)
POST /api/v1/admin/rules/apply-now/{change_id}

Response:
{
  "status": "applied",
  "applied_at": "2025-10-12T15:30:00Z",
  "originally_scheduled_for": "2025-10-15T12:00:00Z"
}
Configuration File Example
yaml
# config/rule_changes.yml

change_policies:
  instant:
    requires_admin_approval: true
    notification_channels:
      - push
      - email
      - in_app
      - sms_to_active_tips
    acknowledgment_required: true
    
  scheduled:
    min_advance_notice_hours: 24
    max_advance_notice_days: 30
    default_reminder_schedule: [72, 24, 1]
    notification_channels:
      - push
      - email
      - in_app
    can_cancel_before_hours: 1
    
  grandfathering:
    existing_tickets: true
    active_attempts: true
    
  rollback:
    allowed_within_hours: 24
    requires_reason: true
User Settings: Change Notifications
┌─────────────────────────────────┐
│   NOTIFICATION PREFERENCES      │
├─────────────────────────────────┤
│                                 │
│ Rule Changes                    │
│ ☑ Push notifications            │
│ ☑ Email alerts                  │
│ ☐ SMS (for urgent changes)      │
│                                 │
│ Reminders for scheduled changes │
│ ☑ 3 days before                 │
│ ☑ 1 day before                  │
│ ☑ 1 hour before                 │
│                                 │
│ ☑ Add to my calendar (iCal)     │
│                                 │
└─────────────────────────────────┘
Combined System: Instant + Scheduled
Example Timeline:

Oct 1: Scheduled change announced (effective Oct 15)
Oct 5: Emergency instant change (overrides scheduled)
Oct 15: Original scheduled change cancelled
Oct 20: New scheduled change announced (effective Nov 1)
Nov 1: Scheduled change applied successfully
What We've Built
✅ Dual-mode system: Instant vs Scheduled ✅ Grandfathering: Existing tickets protected ✅ Notification cascade: Multiple reminders for scheduled ✅ Admin control: Full change management dashboard ✅ User transparency: Clear communication of changes ✅ API support: Programmatic rule management

Ready to move on to:

Database schema (users, tickets, changes, etc.)
Complete user journey maps
API architecture (full endpoint design)
UI/UX wireframes (all screens)
Which direction?

DB Schema and API architecture (full endpoint design)

Database Schema & API Architecture
Database Schema
Core Tables
1. users
sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chain_key VARCHAR(20) UNIQUE NOT NULL, -- CK-00001
    position INTEGER UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    
    -- Status
    status VARCHAR(20) NOT NULL, -- 'active', 'removed', 'seed'
    removal_reason VARCHAR(50), -- '3_failed_attempts', 'inactive_when_reactivated'
    
    -- Relationships
    inviter_position INTEGER REFERENCES users(position),
    
    -- Timestamps
    joined_at TIMESTAMP NOT NULL DEFAULT NOW(),
    removed_at TIMESTAMP,
    last_active_at TIMESTAMP,
    
    -- Stats
    wasted_tickets INTEGER DEFAULT 0,
    total_tickets_generated INTEGER DEFAULT 0,
    
    -- Settings
    notification_preferences JSONB DEFAULT '{"push": true, "email": true, "sms": false}',
    geo_location JSONB, -- {"lat": 52.37, "lon": 4.89, "city": "Amsterdam", "country": "NL"}
    geo_sharing_enabled BOOLEAN DEFAULT false,
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Indexes
    INDEX idx_position (position),
    INDEX idx_status (status),
    INDEX idx_inviter_position (inviter_position),
    INDEX idx_joined_at (joined_at)
);
2. invitations
sql
CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Who invited whom
    inviter_position INTEGER NOT NULL REFERENCES users(position),
    invitee_position INTEGER REFERENCES users(position), -- NULL until someone joins
    
    -- Status
    status VARCHAR(20) NOT NULL, -- 'active', 'joined', 'removed'
    
    -- Metadata
    invited_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Indexes
    INDEX idx_inviter_position (inviter_position),
    INDEX idx_invitee_position (invitee_position),
    INDEX idx_status (status)
);
3. tickets
sql
CREATE TABLE tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_code VARCHAR(50) UNIQUE NOT NULL, -- tkt_abc123xyz
    
    -- Ownership
    issuer_position INTEGER NOT NULL REFERENCES users(position),
    next_position INTEGER NOT NULL, -- What position will the invitee get?
    
    -- Timing
    issued_at TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,
    
    -- Status
    status VARCHAR(20) NOT NULL, -- 'active', 'expired', 'used'
    attempt_number INTEGER NOT NULL, -- 1, 2, or 3
    
    -- Rule version at issuance (for grandfathering)
    rule_version INTEGER NOT NULL REFERENCES rule_versions(version),
    duration_hours INTEGER NOT NULL, -- Actual duration for this ticket
    
    -- QR code data
    qr_code_url TEXT,
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Indexes
    INDEX idx_issuer_position (issuer_position),
    INDEX idx_status (status),
    INDEX idx_expires_at (expires_at),
    INDEX idx_ticket_code (ticket_code)
);
4. badges
sql
CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Badge info
    badge_type VARCHAR(50) NOT NULL, -- 'chain_savior', 'chain_guardian', 'chain_legend'
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(10), -- 🦸, 🛡️, ⭐
    
    -- Requirements
    requirement_config JSONB, -- {"min_removals_saved": 1}
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    UNIQUE(badge_type)
);
5. user_badges
sql
CREATE TABLE user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Who earned what
    user_position INTEGER NOT NULL REFERENCES users(position),
    badge_type VARCHAR(50) NOT NULL REFERENCES badges(badge_type),
    
    -- Context
    earned_at TIMESTAMP NOT NULL DEFAULT NOW(),
    context JSONB, -- {"removed_positions": [9], "collapse_depth": 1}
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    UNIQUE(user_position, badge_type),
    INDEX idx_user_position (user_position),
    INDEX idx_badge_type (badge_type)
);
6. rule_versions
sql
CREATE TABLE rule_versions (
    version INTEGER PRIMARY KEY,
    
    -- Rules
    ticket_duration_hours INTEGER NOT NULL,
    max_attempts INTEGER NOT NULL,
    visibility_range INTEGER NOT NULL,
    seed_unlimited_time BOOLEAN NOT NULL DEFAULT true,
    reactivation_timeout_hours INTEGER NOT NULL,
    
    -- Additional rules (extensible)
    custom_rules JSONB,
    
    -- Timing
    effective_from TIMESTAMP NOT NULL,
    effective_until TIMESTAMP, -- NULL if still active
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by UUID, -- Admin user who created this version
    
    INDEX idx_effective_from (effective_from)
);
7. rule_changes
sql
CREATE TABLE rule_changes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    change_id VARCHAR(20) UNIQUE NOT NULL, -- CHG-00042
    
    -- Version info
    from_version INTEGER REFERENCES rule_versions(version),
    to_version INTEGER NOT NULL REFERENCES rule_versions(version),
    
    -- Deployment
    mode VARCHAR(20) NOT NULL, -- 'instant', 'scheduled'
    announced_at TIMESTAMP NOT NULL,
    effective_at TIMESTAMP NOT NULL,
    applied_at TIMESTAMP, -- When it actually went live
    
    -- Communication
    reason TEXT NOT NULL,
    public_announcement TEXT,
    
    -- Notification config
    notification_config JSONB,
    notifications_sent INTEGER DEFAULT 0,
    
    -- Status
    status VARCHAR(20) NOT NULL, -- 'announced', 'pending', 'applied', 'cancelled'
    
    -- Metadata
    created_by UUID, -- Admin user
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_status (status),
    INDEX idx_effective_at (effective_at),
    INDEX idx_change_id (change_id)
);
8. chain_events
sql
CREATE TABLE chain_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Event info
    event_type VARCHAR(50) NOT NULL, -- 'user_joined', 'user_removed', 'ticket_generated', 
                                     -- 'ticket_expired', 'ticket_used', 'badge_earned',
                                     -- 'rule_changed', 'tip_changed'
    
    -- Related entities
    user_position INTEGER REFERENCES users(position),
    ticket_id UUID REFERENCES tickets(id),
    badge_type VARCHAR(50) REFERENCES badges(badge_type),
    rule_change_id UUID REFERENCES rule_changes(id),
    
    -- Event data
    event_data JSONB, -- Flexible field for event-specific data
    
    -- Metadata
    occurred_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Indexes
    INDEX idx_event_type (event_type),
    INDEX idx_user_position (user_position),
    INDEX idx_occurred_at (occurred_at)
);
9. chain_stats
sql
CREATE TABLE chain_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Snapshot time
    snapshot_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Position stats
    total_positions_issued INTEGER NOT NULL,
    active_members INTEGER NOT NULL,
    removed_members INTEGER NOT NULL,
    current_tip_position INTEGER NOT NULL,
    
    -- Performance stats
    success_rate DECIMAL(5,2), -- 96.50
    avg_time_per_link_hours DECIMAL(10,2),
    wasted_tickets_total INTEGER,
    wasted_tickets_rate DECIMAL(5,2),
    
    -- Growth stats
    daily_growth INTEGER,
    weekly_growth INTEGER,
    monthly_growth INTEGER,
    
    -- Geographic stats
    countries_reached INTEGER,
    cities_reached INTEGER,
    
    -- Health metrics
    removal_rate_7d DECIMAL(5,2),
    removal_rate_30d DECIMAL(5,2),
    longest_active_streak INTEGER,
    current_active_streak INTEGER,
    
    INDEX idx_snapshot_at (snapshot_at)
);
10. notifications
sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Target
    user_position INTEGER NOT NULL REFERENCES users(position),
    
    -- Content
    notification_type VARCHAR(50) NOT NULL, -- 'became_tip', 'invitee_removed', 'rule_change', etc.
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    
    -- Channels
    push_sent BOOLEAN DEFAULT false,
    push_sent_at TIMESTAMP,
    email_sent BOOLEAN DEFAULT false,
    email_sent_at TIMESTAMP,
    sms_sent BOOLEAN DEFAULT false,
    sms_sent_at TIMESTAMP,
    
    -- Status
    read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    
    -- Related entities
    related_ticket_id UUID REFERENCES tickets(id),
    related_rule_change_id UUID REFERENCES rule_changes(id),
    related_event_id UUID REFERENCES chain_events(id),
    
    -- Action
    action_url TEXT,
    action_label VARCHAR(50),
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP,
    
    INDEX idx_user_position (user_position),
    INDEX idx_notification_type (notification_type),
    INDEX idx_read (read),
    INDEX idx_created_at (created_at)
);
11. admin_users
sql
CREATE TABLE admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Auth
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    
    -- Permissions
    role VARCHAR(20) NOT NULL, -- 'super_admin', 'admin', 'moderator'
    permissions JSONB, -- {"can_change_rules": true, "can_ban_users": false}
    
    -- Status
    active BOOLEAN DEFAULT true,
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMP,
    
    INDEX idx_email (email)
);
12. admin_audit_log
sql
CREATE TABLE admin_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Who did what
    admin_id UUID NOT NULL REFERENCES admin_users(id),
    action VARCHAR(100) NOT NULL, -- 'created_rule_change', 'removed_user', 'applied_rule_early'
    
    -- Details
    entity_type VARCHAR(50), -- 'rule_change', 'user', 'ticket'
    entity_id UUID,
    
    -- Changes
    before_data JSONB,
    after_data JSONB,
    
    -- Metadata
    occurred_at TIMESTAMP NOT NULL DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT,
    
    INDEX idx_admin_id (admin_id),
    INDEX idx_action (action),
    INDEX idx_occurred_at (occurred_at)
);
Views & Computed Queries
View: current_tip
sql
CREATE VIEW current_tip AS
SELECT 
    u.*,
    COUNT(t.id) as active_tickets
FROM users u
LEFT JOIN tickets t ON t.issuer_position = u.position 
    AND t.status = 'active'
WHERE u.status = 'active'
    AND NOT EXISTS (
        SELECT 1 FROM invitations i 
        WHERE i.inviter_position = u.position 
        AND i.status = 'active'
    )
GROUP BY u.id;
View: chain_health
sql
CREATE VIEW chain_health AS
SELECT 
    COUNT(*) FILTER (WHERE status = 'active') as active_members,
    COUNT(*) FILTER (WHERE status = 'removed') as removed_members,
    MAX(position) as total_positions_issued,
    ROUND(COUNT(*) FILTER (WHERE status = 'active')::DECIMAL / MAX(position) * 100, 2) as success_rate,
    (SELECT position FROM current_tip LIMIT 1) as current_tip_position
FROM users;
API Architecture
Base URL
https://api.thechain.app/v1
Authentication
Authorization: Bearer <jwt_token>
API Endpoints
1. Authentication
POST /auth/register
Register via invitation ticket scan

Request:

json
{
  "ticket_code": "tkt_abc123xyz",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+31612345678",
  "geo_location": {
    "lat": 52.3676,
    "lon": 4.9041,
    "city": "Amsterdam",
    "country": "NL"
  },
  "geo_sharing_enabled": true
}
Response:

json
{
  "success": true,
  "user": {
    "id": "uuid",
    "chain_key": "CK-00101",
    "position": 101,
    "name": "John Doe",
    "status": "active",
    "joined_at": "2025-10-15T14:30:00Z"
  },
  "token": "jwt_token_here",
  "inviter": {
    "position": 100,
    "name": "Jane Smith",
    "badges": ["chain_savior"]
  }
}
Errors:

400 - Ticket expired, invalid, or already used
404 - Ticket not found
409 - Email already registered
POST /auth/login
Login for existing users

Request:

json
{
  "email": "john@example.com",
  "password": "hashed_password"
}
Response:

json
{
  "success": true,
  "token": "jwt_token_here",
  "user": {
    "id": "uuid",
    "chain_key": "CK-00101",
    "position": 101,
    "status": "active"
  }
}
2. User Profile
GET /users/me
Get current user's profile and chain position

Response:

json
{
  "user": {
    "id": "uuid",
    "chain_key": "CK-00101",
    "position": 101,
    "name": "John Doe",
    "email": "john@example.com",
    "status": "active",
    "joined_at": "2025-10-15T14:30:00Z",
    "last_active_at": "2025-10-20T10:00:00Z",
    "wasted_tickets": 2,
    "total_tickets_generated": 3,
    "badges": [
      {
        "type": "chain_savior",
        "name": "Chain Savior",
        "icon": "🦸",
        "earned_at": "2025-10-18T12:00:00Z",
        "context": {
          "removed_positions": [102],
          "collapse_depth": 1
        }
      }
    ],
    "geo_location": {
      "city": "Amsterdam",
      "country": "NL"
    }
  },
  "inviter": {
    "position": 100,
    "name": "Jane Smith",
    "badges": []
  },
  "invitees": [
    {
      "position": 102,
      "name": "Bob Johnson",
      "status": "removed",
      "invited_at": "2025-10-16T09:00:00Z",
      "removed_at": "2025-10-17T09:00:00Z",
      "removal_reason": "3_failed_attempts"
    },
    {
      "position": 103,
      "name": "Alice Williams",
      "status": "active",
      "invited_at": "2025-10-18T11:00:00Z"
    }
  ],
  "is_current_tip": false
}
PATCH /users/me
Update user profile

Request:

json
{
  "name": "John M. Doe",
  "notification_preferences": {
    "push": true,
    "email": false,
    "sms": true
  },
  "geo_sharing_enabled": false
}
Response:

json
{
  "success": true,
  "user": {
    "id": "uuid",
    "name": "John M. Doe",
    "notification_preferences": {
      "push": true,
      "email": false,
      "sms": true
    }
  }
}
3. Chain Status
GET /chain/status
Get current chain statistics

Response:

json
{
  "chain": {
    "total_positions_issued": 10247,
    "active_members": 9891,
    "removed_members": 356,
    "success_rate": 96.5,
    "current_tip": {
      "position": 10247,
      "name": "Current Tip User",
      "joined_at": "2025-10-20T08:00:00Z",
      "has_active_ticket": true
    },
    "stats": {
      "avg_time_per_link_hours": 14.3,
      "wasted_tickets_total": 1247,
      "wasted_tickets_rate": 32.5,
      "daily_growth": 12,
      "weekly_growth": 84,
      "monthly_growth": 347,
      "countries_reached": 47,
      "cities_reached": 892,
      "removal_rate_7d": 3.2,
      "removal_rate_30d": 2.8,
      "longest_active_streak": 8423,
      "current_active_streak": 543
    },
    "last_updated": "2025-10-20T10:00:00Z"
  }
}
GET /chain/timeline
Get recent chain events

Query params:

limit (default: 20, max: 100)
offset (default: 0)
event_types (filter: comma-separated)
Response:

json
{
  "events": [
    {
      "id": "uuid",
      "event_type": "user_joined",
      "position": 10247,
      "name": "Alice",
      "occurred_at": "2025-10-20T08:00:00Z"
    },
    {
      "id": "uuid",
      "event_type": "user_removed",
      "position": 10246,
      "name": "Bob",
      "removal_reason": "3_failed_attempts",
      "occurred_at": "2025-10-19T22:00:00Z"
    },
    {
      "id": "uuid",
      "event_type": "badge_earned",
      "position": 10245,
      "badge_type": "chain_savior",
      "occurred_at": "2025-10-20T08:05:00Z"
    }
  ],
  "pagination": {
    "total": 10247,
    "limit": 20,
    "offset": 0,
    "has_more": true
  }
}
GET /chain/map
Get geographic distribution (if enabled)

Response:

json
{
  "locations": [
    {
      "country": "NL",
      "country_name": "Netherlands",
      "member_count": 1247,
      "cities": [
        {
          "city": "Amsterdam",
          "member_count": 543,
          "lat": 52.3676,
          "lon": 4.9041
        }
      ]
    }
  ],
  "total_countries": 47,
  "total_cities": 892,
  "members_sharing_location": 7234
}
4. Tickets
POST /tickets/generate
Generate a new invitation ticket (only if you're the tip)

Request:

json
{}
Response:

json
{
  "success": true,
  "ticket": {
    "id": "uuid",
    "ticket_code": "tkt_abc123xyz",
    "issued_at": "2025-10-20T10:00:00Z",
    "expires_at": "2025-10-21T10:00:00Z",
    "duration_hours": 24,
    "attempt_number": 1,
    "next_position": 10248,
    "qr_code_url": "https://cdn.thechain.app/qr/tkt_abc123xyz.png",
    "share_url": "https://thechain.app/join/tkt_abc123xyz",
    "rule_version": 12
  },
  "time_remaining": {
    "hours": 24,
    "minutes": 0,
    "seconds": 0
  }
}
Errors:

403 - Not the current tip
409 - Already have an active ticket
429 - Too many attempts (rate limiting)
GET /tickets/active
Get your current active ticket (if any)

Response:

json
{
  "ticket": {
    "id": "uuid",
    "ticket_code": "tkt_abc123xyz",
    "issued_at": "2025-10-20T10:00:00Z",
    "expires_at": "2025-10-21T10:00:00Z",
    "attempt_number": 1,
    "qr_code_url": "https://cdn.thechain.app/qr/tkt_abc123xyz.png",
    "share_url": "https://thechain.app/join/tkt_abc123xyz"
  },
  "time_remaining": {
    "hours": 18,
    "minutes": 23,
    "seconds": 45,
    "total_seconds": 66225
  }
}
If no active ticket:

json
{
  "ticket": null
}
GET /tickets/history
Get ticket generation history

Response:

json
{
  "tickets": [
    {
      "id": "uuid",
      "issued_at": "2025-10-20T10:00:00Z",
      "expires_at": "2025-10-21T10:00:00Z",
      "status": "active",
      "attempt_number": 1
    },
    {
      "id": "uuid",
      "issued_at": "2025-10-18T12:00:00Z",
      "expires_at": "2025-10-19T12:00:00Z",
      "status": "expired",
      "attempt_number": 2
    },
    {
      "id": "uuid",
      "issued_at": "2025-10-17T09:00:00Z",
      "expires_at": "2025-10-18T09:00:00Z",
      "status": "used",
      "used_at": "2025-10-17T14:30:00Z",
      "attempt_number": 1
    }
  ],
  "total_generated": 15,
  "total_used": 8,
  "total_expired": 7
}
GET /tickets/validate/:ticket_code
Validate a ticket before joining (public endpoint)

Response:

json
{
  "valid": true,
  "ticket": {
    "ticket_code": "tkt_abc123xyz",
    "next_position": 10248,
    "expires_at": "2025-10-21T10:00:00Z",
    "issuer": {
      "position": 10247,
      "name": "Alice"
    }
  },
  "time_remaining": {
    "hours": 18,
    "minutes": 23,
    "seconds": 45
  },
  "current_rules": {
    "version": 12,
    "ticket_duration_hours": 24,
    "max_attempts": 3
  }
}
If invalid:

json
{
  "valid": false,
  "reason": "expired",
  "message": "This ticket expired on 2025-10-20T10:00:00Z"
}
5. Rules & Changes
GET /rules/current
Get currently active rules

Response:

json
{
  "version": 12,
  "effective_since": "2025-09-01T00:00:00Z",
  "rules": {
    "ticket_duration_hours": 24,
    "max_attempts": 3,
    "visibility_range": 1,
    "seed_unlimited_time": true,
    "reactivation_timeout_hours": 24
  }
}
GET /rules/upcoming
Get upcoming scheduled rule changes

Response:

json
{
  "changes": [
    {
      "change_id": "CHG-00043",
      "announced_at": "2025-10-10T12:00:00Z",
      "effective_at": "2025-10-15T12:00:00Z",
      "status": "pending",
      "time_remaining": {
        "days": 5,
        "hours": 12,
        "minutes": 30
      },
      "changes": {
        "ticket_duration_hours": {
          "from": 24,
          "to": 23
        }
      },
      "reason": "Gradual difficulty increase",
      "public_announcement": "To maintain momentum, we're slightly reducing ticket duration."
    }
  ]
}
GET /rules/history
Get rule change history

Response:

json
{
  "changes": [
    {
      "change_id": "CHG-00042",
      "version": 12,
      "mode": "instant",
      "announced_at": "2025-10-05T14:23:00Z",
      "effective_at": "2025-10-05T14:23:00Z",
      "applied_at": "2025-10-05T14:23:00Z",
      "changes": {
        "ticket_duration_hours": {
          "from": 25,
          "to": 24
        }
      },
      "reason": "Normalizing after special event"
    }
  ],
  "total": 42
}
6. Notifications
GET /notifications
Get user notifications

Query params:

unread_only (boolean, default: false)
limit (default: 20)
offset (default: 0)
Response:

json
{
  "notifications": [
    {
      "id": "uuid",
      "type": "became_tip",
      "title": "You're the tip!",
      "body": "Your invitee was removed. Generate a ticket within 24h.",
      "read": false,
      "created_at": "2025-10-20T10:00:00Z",
      "action_url": "/tickets/generate",
      "action_label": "Generate Ticket"
    },
    {
      "id": "uuid",
      "type": "rule_change_reminder",
      "title": "Rule change in 24 hours",
      "body": "Ticket duration will change from 24h to 23h tomorrow.",
      "read": true,
      "read_at": "2025-10-14T15:00:00Z",
      "created_at": "2025-10-14T12:00:00Z",
      "action_url": "/rules/upcoming",
      "action_label": "View Details"
    }
  ],
  "unread_count": 3,
  "pagination": {
    "total": 47,
    "limit": 20,
    "offset": 0
  }
}
PATCH /notifications/:id/read
Mark notification as read

Response:

json
{
  "success": true,
  "notification": {
    "id": "uuid",
    "read": true,
    "read_at": "2025-10-20T10:30:00Z"
  }
}
POST /notifications/read-all
Mark all notifications as read

Response:

json
{
  "success": true,
  "marked_read": 3
}
7. Admin Endpoints
All admin endpoints require admin authentication.

POST /admin/auth/login
Admin login

Request:

json
{
  "email": "admin@thechain.app",
  "password": "secure_password"
}
Response:

json
{
  "success": true,
  "token": "admin_jwt_token",
  "admin": {
    "id": "uuid",
    "email": "admin@thechain.app",
    "role": "super_admin",
    "permissions": {
      "can_change_rules": true,
      "can_manage_users": true,
      "can_view_analytics": true
    }
  }
}
GET /admin/dashboard
Get admin dashboard overview

Response:

json
{
  "chain_health": {
    "total_positions": 10247,
    "active_members": 9891,
    "removed_members": 356,
    "success_rate": 96.5,
    "current_tip": {
      "position": 10247,
      "name": "Alice",
      "has_active_ticket": true,
      "ticket_expires_in_hours": 18
    }
  },
  "recent_activity": {
    "last_hour_joins": 3,
    "last_hour_removals": 0,
    "last_24h_growth": 47
  },
  "pending_changes": [
    {
      "change_id": "CHG-00043",
      "effective_at": "2025-10-15T12:00:00Z",
      "status": "pending"
    }
  ],
  "alerts": [
    {
      "type": "warning",
      "message": "Removal rate increased to 5.2% in last 24h"
    }
  ]
}
POST /admin/rules/create
Create a new rule change

Request:

json
{
  "mode": "scheduled",
  "effective_at": "2025-10-15T12:00:00Z",
  "changes": {
    "ticket_duration_hours": 23
  },
  "reason": "Gradual difficulty increase",
  "public_announcement": "To maintain chain momentum...",
  "notification_config": {
    "push": true,
    "email": true,
    "reminder_hours_before": [72, 24, 1]
  }
}
Response:

json
{
  "success": true,
  "change": {
    "change_id": "CHG-00043",
    "status": "scheduled",
    "announced_at": "2025-10-10T12:00:00Z",
    "effective_at": "2025-10-15T12:00:00Z",
    "notifications_scheduled": 3
  }
}
POST /admin/rules/apply-now/:change_id
Apply a scheduled change immediately

Response:

json
{
  "success": true,
  "change": {
    "change_id": "CHG-00043",
    "status": "applied",
    "applied_at": "2025-10-12T15:30:00Z",
    "originally_scheduled_for": "2025-10-15T12:00:00Z"
  },
  "affected_users": 10247,
  "notifications_sent": 10247
}
DELETE /admin/rules/cancel/:change_id
Cancel a scheduled change

Response:

json
{
  "success": true,
  "change": {
    "change_id": "CHG-00043",
    "status": "cancelled",
    "cancelled_at": "2025-10-12T10:00:00Z"
  }
}
GET /admin/users
List/search users

Query params:

status (active, removed, all)
search (search by name, email, position)
sort (position, joined_at, wasted_tickets)
limit, offset
Response:

json
{
  "users": [
    {
      "position": 10247,
      "chain_key": "CK-10247",
      "name": "Alice",
      "email": "alice@example.com",
      "status": "active",
      "joined_at": "2025-10-20T08:00:00Z",
      "wasted_tickets": 0,
      "is_current_tip": true,
      "badges": []
    }
  ],
  "pagination": {
    "total": 10247,
    "limit": 50,
    "offset": 0
  }
}
PATCH /admin/users/:position
Update user (admin override)

Request:

json
{
  "status": "removed",
  "removal_reason": "admin_action",
  "reason_note": "Violated terms of service"
}
Response:

json
{
  "success": true,
  "user": {
    "position": 5000,
    "status": "removed",
    "removal_reason": "admin_action",
    "removed_at": "2025-10-20T11:00:00Z"
  },
  "tip_reverted_to": 4999
}
GET /admin/analytics
Get detailed analytics

Query params:

start_date, end_date
metrics (comma-separated: growth, removals, tickets, geographic)
Response:

json
{
  "period": {
    "start": "2025-10-01T00:00:00Z",
    "end": "2025-10-20T23:59:59Z"
  },
  "growth": {
    "total_new_members": 1247,
    "average_per_day": 62.35,
    "peak_day": {
      "date": "2025-10-15",
      "new_members": 89
    }
  },
  "removals": {
    "total": 47,
    "by_reason": {
      "3_failed_attempts": 42,
      "inactive_when_reactivated": 5
    },
    "removal_rate": 3.77
  },
  "tickets": {
    "total_generated": 1347,
    "total_used": 1247,
    "total_expired": 100,
    "waste_rate": 7.42,
    "avg_attempts_before_success": 1.08
  },
  "geographic": {
    "countries_added": 3,
    "total_countries": 47,
    "top_countries": [
      {"country": "NL", "members": 1247},
      {"country": "US", "members": 892}
    ]
  }
}
GET /admin/audit-log
Get admin action audit log

Response:

json
{
  "logs": [
    {
      "id": "uuid",
      "admin_email": "admin@thechain.app",
      "action": "created_rule_change",
      "entity_type": "rule_change",
      "entity_id": "uuid",
      "details": {
        "change_id": "CHG-00043",
        "mode": "scheduled"
      },
      "occurred_at": "2025-10-10T12:00:00Z",
      "ip_address": "203.0.113.42"
    }
  ],
  "pagination": {
    "total": 523,
    "limit": 50,
    "offset": 0
  }
}
8. Webhooks (Optional)
For external integrations

POST /webhooks/register
Register a webhook endpoint

Request:

json
{
  "url": "https://example.com/webhook",
  "events": ["user_joined", "user_removed", "rule_changed"],
  "secret": "webhook_secret_for_signature"
}
Response:

json
{
  "success": true,
  "webhook": {
    "id": "uuid",
    "url": "https://example.com/webhook",
    "events": ["user_joined", "user_removed", "rule_changed"],
    "created_at": "2025-10-20T12:00:00Z"
  }
}
WebSocket API (Real-time Updates)
Connection
wss://api.thechain.app/v1/ws?token=<jwt_token>
Subscribe to Events
json
{
  "type": "subscribe",
  "events": ["tip_changed", "rule_change_applied", "invitee_status_changed"]
}
Events
tip_changed
json
{
  "type": "tip_changed",
  "data": {
    "old_tip_position": 10246,
    "new_tip_position": 10247,
    "reason": "previous_tip_successful",
    "timestamp": "2025-10-20T10:00:00Z"
  }
}
ticket_expiring_soon
json
{
  "type": "ticket_expiring_soon",
  "data": {
    "ticket_id": "uuid",
    "expires_at": "2025-10-21T10:00:00Z",
    "time_remaining_seconds": 3600,
    "warning_level": "1_hour"
  }
}
you_became_tip
json
{
  "type": "you_became_tip",
  "data": {
    "reason": "invitee_removed",
    "removed_invitee_position": 10248,
    "timeout_hours": 24,
    "timestamp": "2025-10-20T10:00:00Z"
  }
}
invitee_status_changed
json
{
  "type": "invitee_status_changed",
  "data": {
    "invitee_position": 10248,
    "old_status": "active",
    "new_status": "removed",
    "removal_reason": "3_failed_attempts",
    "timestamp": "2025-10-20T09:00:00Z"
  }
}
rule_change_applied
json
{
  "type": "rule_change_applied",
  "data": {
    "change_id": "CHG-00043",
    "new_version": 13,
    "changes": {
      "ticket_duration_hours": {
        "from": 24,
        "to": 23
      }
    },
    "applied_at": "2025-10-15T12:00:00Z"
  }
}
Rate Limiting
Public Endpoints
100 requests per 15 minutes per IP
Authenticated Endpoints
300 requests per 15 minutes per user
Ticket Generation
1 request per 5 minutes per user (to prevent spam)
Admin Endpoints
1000 requests per 15 minutes per admin
Rate Limit Headers
X-RateLimit-Limit: 300
X-RateLimit-Remaining: 287
X-RateLimit-Reset: 1634567890
Error Responses
Standard Error Format
json
{
  "success": false,
  "error": {
    "code": "TICKET_EXPIRED",
    "message": "This ticket expired on 2025-10-20T10:00:00Z",
    "details": {
      "ticket_id": "uuid",
      "expired_at": "2025-10-20T10:00:00Z"
    }
  }
}
Common Error Codes
UNAUTHORIZED - Invalid or missing token
FORBIDDEN - Insufficient permissions
NOT_FOUND - Resource not found
VALIDATION_ERROR - Invalid input data
TICKET_EXPIRED - Ticket has expired
TICKET_USED - Ticket already used
NOT_TIP - User is not the current tip
RATE_LIMIT_EXCEEDED - Too many requests
RULE_CHANGE_CONFLICT - Conflicting rule change
INTERNAL_ERROR - Server error
Pagination
All list endpoints support pagination:

Request:

GET /api/v1/chain/timeline?limit=20&offset=40
Response includes:

json
{
  "data": [...],
  "pagination": {
    "total": 10247,
    "limit": 20,
    "offset": 40,
    "has_more": true,
    "next_offset": 60
  }
}
Data Retention
Active users: Indefinite
Removed users: Indefinite (historical record)
Tickets: 90 days after expiration
Notifications: 30 days after creation
Chain events: Indefinite (audit trail)
Admin audit log: Indefinite
Chain stats snapshots: Indefinite (hourly for 7 days, daily after)
Summary
✅ Complete database schema with 12 core tables ✅ RESTful API with 40+ endpoints ✅ WebSocket API for real-time updates ✅ Admin endpoints for rule management ✅ Authentication & authorization ✅ Rate limiting & error handling ✅ Pagination & filtering

What's next?

Complete user journey wireframes
Frontend implementation plan
Deployment & infrastructure design
Testing strategy
Your choice!

Lets talk about authentication and sign up system

Authentication & Sign-Up System
Core Challenge: Invitation-Only Access
The Chain has a unique constraint: You can ONLY join by scanning a valid invitation ticket. There's no traditional "sign up" button.

Sign-Up Flow Architecture
Flow Overview
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Someone shares QR code/link with you               │
│         ↓                                           │
│  You scan QR code or click link                     │
│         ↓                                           │
│  App validates ticket                               │
│         ↓                                           │
│  You create account (tied to that ticket)           │
│         ↓                                           │
│  You join the chain at the assigned position        │
│                                                     │
└─────────────────────────────────────────────────────┘
Method 1: QR Code Scan (Primary Mobile Flow)
Step 1: Ticket Holder Generates QR Code
┌─────────────────────────────────┐
│   YOU'RE THE TIP! 🔥            │
├─────────────────────────────────┤
│                                 │
│   Invite someone to continue    │
│   the chain                     │
│                                 │
│   [GENERATE TICKET]             │
│                                 │
└─────────────────────────────────┘
After clicking:

┌─────────────────────────────────┐
│   YOUR INVITATION TICKET        │
├─────────────────────────────────┤
│                                 │
│        [QR CODE IMAGE]          │
│                                 │
│   ⏱ Expires in 23h 47m          │
│   Position: #10248              │
│   Attempt: 1/3                  │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Share this QR code with       │
│   ONE person to invite them     │
│                                 │
│   [SHARE LINK INSTEAD]          │
│   [SAVE QR CODE]                │
│                                 │
└─────────────────────────────────┘
Step 2: Invitee Scans QR Code
Option A: Invitee Has App Installed

QR scanner in app detects ticket
Immediately validates ticket
Takes them to registration flow
Option B: Invitee Doesn't Have App

QR code contains deep link: thechain://join/tkt_abc123xyz
Redirects to app store with ticket preserved
After install, opens app with ticket context
Method 2: Share Link (Alternative Flow)
Step 1: Ticket Holder Shares Link
┌─────────────────────────────────┐
│   SHARE YOUR INVITATION         │
├─────────────────────────────────┤
│                                 │
│   Copy link:                    │
│   https://thechain.app/join/    │
│   tkt_abc123xyz                 │
│                                 │
│   [COPY LINK]                   │
│                                 │
│   Or share via:                 │
│   [WhatsApp] [Telegram]         │
│   [iMessage]  [Email]           │
│                                 │
└─────────────────────────────────┘
Step 2: Invitee Clicks Link
On Mobile (Primary):

https://thechain.app/join/tkt_abc123xyz
→ Opens app if installed
→ Or redirects to app store with preserved ticket
On Desktop (Secondary):

https://thechain.app/join/tkt_abc123xyz
→ Shows QR code to scan with phone
→ Shows "Download on App Store / Google Play" buttons
Registration Flow (After Ticket Validation)
Screen 1: Ticket Validated
┌─────────────────────────────────┐
│   YOU'RE INVITED! 🎉            │
├─────────────────────────────────┤
│                                 │
│   [Avatar of inviter]           │
│   Alice (#10247) invited you    │
│                                 │
│   You'll become position #10248 │
│   in The Chain                  │
│                                 │
│   ⏱ This ticket expires in      │
│      22h 13m                    │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   [ACCEPT INVITATION]           │
│                                 │
│   [Learn more about The Chain]  │
│                                 │
└─────────────────────────────────┘
Screen 2: Create Account
┌─────────────────────────────────┐
│   CREATE YOUR ACCOUNT           │
├─────────────────────────────────┤
│                                 │
│   Choose your display name:     │
│   [John Doe             ]       │
│                                 │
│   Email (optional):             │
│   [john@example.com     ]       │
│   For notifications & recovery  │
│                                 │
│   Phone (optional):             │
│   [+31 6 1234 5678      ]       │
│   For urgent notifications      │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Share location?               │
│   ○ Yes - Show my city          │
│   ● No - Stay anonymous         │
│                                 │
│   Why: See the chain spread     │
│   globally on the map           │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   [CONTINUE]                    │
│                                 │
└─────────────────────────────────┘
Screen 3: Set Password (Optional)
┌─────────────────────────────────┐
│   SECURE YOUR ACCOUNT           │
├─────────────────────────────────┤
│                                 │
│   Create a password:            │
│   [●●●●●●●●            ]       │
│                                 │
│   Confirm password:             │
│   [●●●●●●●●            ]       │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Or use:                       │
│   [🍎 Sign in with Apple]       │
│   [📧 Continue with Google]     │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   ☑ I agree to Terms of Service │
│   ☑ I agree to Privacy Policy   │
│                                 │
│   [CREATE ACCOUNT]              │
│                                 │
│   [SKIP - Use as guest]         │
│   (Limited functionality)       │
│                                 │
└─────────────────────────────────┘
Screen 4: Welcome to The Chain
┌─────────────────────────────────┐
│   WELCOME TO THE CHAIN! 🎉      │
├─────────────────────────────────┤
│                                 │
│   Your Chain Key:               │
│   ┌───────────────────────────┐ │
│   │       CK-10248            │ │
│   └───────────────────────────┘ │
│                                 │
│   You are now part of a global  │
│   social experiment connecting  │
│   people one link at a time.    │
│                                 │
│   YOUR CHAIN POSITION           │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Alice (#10247) invited you    │
│        ↓                        │
│   YOU (#10248)                  │
│        ↓                        │
│   [No invitee yet]              │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   When it's your turn, you'll   │
│   be able to invite ONE person. │
│                                 │
│   [EXPLORE THE CHAIN]           │
│                                 │
└─────────────────────────────────┘
Authentication Methods
Option 1: Email + Password (Traditional)
Registration:

json
POST /auth/register
{
  "ticket_code": "tkt_abc123xyz",
  "name": "John Doe",
  "email": "john@example.com",
  "password": "secure_password_123",
  "phone": "+31612345678",
  "geo_location": {
    "lat": 52.3676,
    "lon": 4.9041,
    "city": "Amsterdam",
    "country": "NL"
  },
  "geo_sharing_enabled": true
}
Login:

json
POST /auth/login
{
  "email": "john@example.com",
  "password": "secure_password_123"
}
Password Reset:

json
POST /auth/forgot-password
{
  "email": "john@example.com"
}

→ Email sent with reset link
→ User clicks link, creates new password
Option 2: Social Sign-In (Recommended)
Sign in with Apple:

┌─────────────────────────────────┐
│   [🍎 Sign in with Apple]       │
└─────────────────────────────────┘

Flow:
1. User clicks button
2. Apple auth dialog appears
3. User authenticates with Face ID/Touch ID
4. App receives:
   - User identifier (sub)
   - Email (optional, user can hide)
   - Name (optional)
5. Backend creates account linked to Apple ID
Sign in with Google:

┌─────────────────────────────────┐
│   [📧 Continue with Google]     │
└─────────────────────────────────┘

Flow:
1. User clicks button
2. Google OAuth dialog
3. User selects Google account
4. App receives:
   - Google user ID
   - Email
   - Name
   - Profile picture
5. Backend creates account linked to Google ID
Backend Implementation:

json
POST /auth/register
{
  "ticket_code": "tkt_abc123xyz",
  "auth_provider": "apple",
  "provider_user_id": "apple_sub_123456",
  "email": "john@privaterelay.appleid.com",
  "name": "John Doe",
  "phone": "+31612345678",
  "geo_location": {...},
  "geo_sharing_enabled": true
}
Option 3: Passwordless (Magic Link)
Flow:

1. User enters email during registration
2. System sends magic link via email
3. User clicks link (valid for 15 minutes)
4. User is automatically logged in
Registration:

json
POST /auth/register
{
  "ticket_code": "tkt_abc123xyz",
  "name": "John Doe",
  "email": "john@example.com",
  "send_magic_link": true
}

Response:
{
  "success": true,
  "message": "Check your email for a login link",
  "email": "john@example.com"
}
Login (Future Sessions):

json
POST /auth/magic-link/request
{
  "email": "john@example.com"
}

→ Email sent with link: https://thechain.app/auth/verify/token_xyz
→ User clicks link
→ Auto-login
Option 4: Guest Mode (No Auth)
Limited functionality:

Can join the chain
Can view their position
Can generate tickets
CANNOT recover account if app is deleted
CANNOT access from multiple devices
Registration:

json
POST /auth/register
{
  "ticket_code": "tkt_abc123xyz",
  "name": "Anonymous User",
  "guest_mode": true
}

Response:
{
  "success": true,
  "user": {...},
  "token": "jwt_token",
  "warning": "Guest accounts cannot be recovered. Add email/password later."
}
Upgrading from Guest:

json
POST /auth/upgrade-guest
{
  "email": "john@example.com",
  "password": "secure_password"
}

Response:
{
  "success": true,
  "message": "Account upgraded. You can now login from any device."
}
Database Schema: Auth Tables
users table (updated with auth fields)
sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chain_key VARCHAR(20) UNIQUE NOT NULL,
    position INTEGER UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    
    -- Auth methods
    email VARCHAR(255) UNIQUE,
    email_verified BOOLEAN DEFAULT false,
    password_hash VARCHAR(255), -- NULL if using social auth
    
    phone VARCHAR(20),
    phone_verified BOOLEAN DEFAULT false,
    
    -- Social auth
    apple_user_id VARCHAR(255) UNIQUE,
    google_user_id VARCHAR(255) UNIQUE,
    
    -- Account type
    is_guest BOOLEAN DEFAULT false,
    
    -- ... rest of fields
);
auth_sessions table
sql
CREATE TABLE auth_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Session info
    token_hash VARCHAR(255) UNIQUE NOT NULL,
    refresh_token_hash VARCHAR(255) UNIQUE,
    
    -- Device info
    device_id VARCHAR(255),
    device_name VARCHAR(100), -- "iPhone 15 Pro"
    device_os VARCHAR(50), -- "iOS 17.2"
    
    -- Metadata
    ip_address INET,
    user_agent TEXT,
    
    -- Expiration
    expires_at TIMESTAMP NOT NULL,
    last_used_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Status
    active BOOLEAN DEFAULT true,
    revoked_at TIMESTAMP,
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_active (active)
);
password_reset_tokens table
sql
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    
    token_hash VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT false,
    used_at TIMESTAMP,
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at)
);
magic_link_tokens table
sql
CREATE TABLE magic_link_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    user_id UUID REFERENCES users(id), -- NULL if new user
    
    token_hash VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT false,
    used_at TIMESTAMP,
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_email (email),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at)
);
email_verification_tokens table
sql
CREATE TABLE email_verification_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    
    token_hash VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT false,
    used_at TIMESTAMP,
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash)
);
JWT Token Structure
Access Token (Short-lived: 1 hour)
json
{
  "sub": "uuid", // user_id
  "pos": 10248, // position
  "ck": "CK-10248", // chain_key
  "name": "John Doe",
  "status": "active",
  "is_tip": false,
  "iat": 1634567890,
  "exp": 1634571490,
  "type": "access"
}
Refresh Token (Long-lived: 30 days)
json
{
  "sub": "uuid",
  "session_id": "session_uuid",
  "iat": 1634567890,
  "exp": 1637159890,
  "type": "refresh"
}
API Endpoints: Auth
POST /auth/register
Register with ticket

Request:

json
{
  "ticket_code": "tkt_abc123xyz",
  "name": "John Doe",
  "email": "john@example.com",
  "password": "secure_password",
  // OR
  "auth_provider": "apple",
  "provider_user_id": "apple_sub_123",
  // Optional
  "phone": "+31612345678",
  "geo_location": {...},
  "geo_sharing_enabled": true
}
Response:

json
{
  "success": true,
  "user": {
    "id": "uuid",
    "chain_key": "CK-10248",
    "position": 10248,
    "name": "John Doe",
    "email": "john@example.com",
    "status": "active",
    "joined_at": "2025-10-20T14:30:00Z"
  },
  "tokens": {
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 3600
  },
  "inviter": {
    "position": 10247,
    "name": "Alice"
  }
}
POST /auth/login
Login with email/password

Request:

json
{
  "email": "john@example.com",
  "password": "secure_password",
  "device_info": {
    "device_id": "device_uuid",
    "device_name": "iPhone 15 Pro",
    "device_os": "iOS 17.2"
  }
}
Response:

json
{
  "success": true,
  "user": {...},
  "tokens": {
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 3600
  }
}
POST /auth/refresh
Refresh access token

Request:

json
{
  "refresh_token": "eyJhbGc..."
}
Response:

json
{
  "success": true,
  "tokens": {
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 3600
  }
}
POST /auth/logout
Logout (revoke session)

Request:

json
{
  "refresh_token": "eyJhbGc..."
}
Response:

json
{
  "success": true,
  "message": "Logged out successfully"
}
POST /auth/forgot-password
Request password reset

Request:

json
{
  "email": "john@example.com"
}
Response:

json
{
  "success": true,
  "message": "If an account exists with this email, a reset link has been sent."
}
POST /auth/reset-password
Reset password with token

Request:

json
{
  "token": "reset_token_xyz",
  "new_password": "new_secure_password"
}
Response:

json
{
  "success": true,
  "message": "Password reset successfully. Please login."
}
POST /auth/magic-link/request
Request magic link

Request:

json
{
  "email": "john@example.com"
}
Response:

json
{
  "success": true,
  "message": "Check your email for a login link"
}
GET /auth/magic-link/verify/:token
Verify magic link and auto-login

Response: Redirects to app with tokens in URL params:

thechain://auth/success?access_token=...&refresh_token=...
POST /auth/verify-email
Verify email address

Request:

json
{
  "token": "verification_token_xyz"
}
Response:

json
{
  "success": true,
  "message": "Email verified successfully"
}
POST /auth/resend-verification
Resend email verification

Request:

json
{
  "email": "john@example.com"
}
GET /auth/sessions
Get active sessions (for security settings)

Response:

json
{
  "sessions": [
    {
      "id": "uuid",
      "device_name": "iPhone 15 Pro",
      "device_os": "iOS 17.2",
      "ip_address": "203.0.113.42",
      "last_used_at": "2025-10-20T14:30:00Z",
      "created_at": "2025-10-15T10:00:00Z",
      "current": true
    },
    {
      "id": "uuid",
      "device_name": "MacBook Pro",
      "device_os": "macOS 14.2",
      "ip_address": "203.0.113.43",
      "last_used_at": "2025-10-18T09:00:00Z",
      "created_at": "2025-10-10T12:00:00Z",
      "current": false
    }
  ]
}
DELETE /auth/sessions/:session_id
Revoke a session

Response:

json
{
  "success": true,
  "message": "Session revoked"
}
Security Considerations
1. Password Requirements
javascript
// Minimum requirements
- 8+ characters
- At least 1 uppercase letter
- At least 1 lowercase letter
- At least 1 number
- At least 1 special character

// Check against common passwords list
// Rate limit password attempts (5 per 15 minutes)
2. Token Security
javascript
// Access tokens
- Short-lived (1 hour)
- Stored in memory only (not localStorage)
- Automatically refreshed

// Refresh tokens
- Long-lived (30 days)
- Stored in secure httpOnly cookie
- Rotated on each use
- Revocable via sessions management
3. Rate Limiting
javascript
// Registration: 3 attempts per IP per hour
// Login: 5 attempts per email per 15 minutes
// Password reset: 3 requests per email per hour
// Magic link: 3 requests per email per hour
4. Email Verification
javascript
// Required for:
- Password reset
- Receiving notifications
- Account recovery

// Verification link expires in 24 hours
// Can request new verification email
5. Two-Factor Authentication (Future)
javascript
// Optional 2FA via:
- SMS
- Authenticator app (TOTP)
- Backup codes

// Required for high-value actions
Edge Cases & Handling
Case 1: Ticket Used While Registering
User A starts registration with ticket_123
User B completes registration with ticket_123 first
User A tries to submit registration

Response:
{
  "success": false,
  "error": {
    "code": "TICKET_ALREADY_USED",
    "message": "This ticket was just used by someone else",
    "used_at": "2025-10-20T14:29:58Z"
  }
}
Case 2: Ticket Expires During Registration
User starts registration at 10:00
Ticket expires at 10:15
User submits at 10:16

Response:
{
  "success": false,
  "error": {
    "code": "TICKET_EXPIRED",
    "message": "This ticket expired while you were registering",
    "expired_at": "2025-10-20T10:15:00Z"
  }
}
Case 3: Email Already Registered
User tries to register with john@example.com
Email already exists in system

Response:
{
  "success": false,
  "error": {
    "code": "EMAIL_EXISTS",
    "message": "An account with this email already exists",
    "suggestion": "Try logging in or use password reset"
  }
}
Case 4: Social Auth Email Conflict
User has account with email john@example.com (password auth)
User tries to sign in with Google using same email

Option A: Link accounts
{
  "conflict": true,
  "message": "An account exists with this email. Link your Google account?",
  "actions": ["link", "cancel"]
}

Option B: Reject
{
  "success": false,
  "error": {
    "code": "ACCOUNT_EXISTS",
    "message": "Please login with your password"
  }
}
Case 5: Guest Wants to Upgrade
Guest user (no email) wants to add email/password

POST /auth/upgrade-guest
{
  "email": "john@example.com",
  "password": "secure_password"
}

Response:
{
  "success": true,
  "message": "Account upgraded successfully",
  "email_verification_sent": true
}
Onboarding Tutorial (First-Time Users)
After Registration:
┌─────────────────────────────────┐
│   WELCOME! LET'S LEARN          │
│   HOW THE CHAIN WORKS           │
├─────────────────────────────────┤
│                                 │
│   [Illustration]                │
│                                 │
│   The Chain is a global         │
│   social experiment.            │
│                                 │
│   Everyone is connected         │
│   in a single line.             │
│                                 │
│   [NEXT] (1/5)                  │
│                                 │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│   YOU'LL BECOME THE TIP         │
├─────────────────────────────────┤
│                                 │
│   [Illustration]                │
│                                 │
│   When it's your turn, you      │
│   can invite ONE person.        │
│                                 │
│   You have 24 hours and         │
│   3 attempts.                   │
│                                 │
│   [NEXT] (2/5)                  │
│                                 │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│   KEEP THE CHAIN ALIVE          │
├─────────────────────────────────┤
│                                 │
│   [Illustration]                │
│                                 │
│   If you fail 3 times,          │
│   you'll be removed and         │
│   the chain goes back.          │
│                                 │
│   Your goal: Don't break        │
│   the chain!                    │
│                                 │
│   [NEXT] (3/5)                  │
│                                 │
└─────────────────────────────────┘
Recommendation: Multi-Method Approach
Primary: Social Sign-In (Apple/Google)

Fastest onboarding
Best UX
Most secure (no passwords to manage)
Secondary: Email + Password

For users who prefer traditional auth
Requires email verification
Tertiary: Guest Mode

Quickest entry
Can upgrade later
Risk: Account loss if device lost
Future: Passwordless (Magic Link)

No passwords to remember
Secure
Great UX
Summary
✅ Invitation-only registration via ticket validation ✅ Multiple auth methods (Social, Email/Password, Guest, Magic Link) ✅ Secure token management (JWT with refresh tokens) ✅ Session management (Multiple devices, revocation) ✅ Email verification & password reset ✅ Guest account upgrades ✅ Rate limiting & security measures ✅ Edge case handling

What's next?

UI/UX wireframes for all screens
Notification system deep dive
Backend infrastructure & deployment
Testing strategy
Your call!

Option 1 and Option 2 combined. However I want to give the users the ability to set a publicly visible name when they join. People shouldnt give out their personal information. Doing so could lead questions when we increase the visibility range in the future

Authentication System: Email/Password + Social Auth with Public Display Names
Excellent point about privacy! This is crucial for future-proofing when visibility rules change.

Core Principle: Separation of Identity & Display
PRIVATE IDENTITY                    PUBLIC DISPLAY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Real email (auth)          →      • Display name (public)
- Real name (optional)       →      • Avatar/emoji (public)
- Phone (optional)           →      • Chain Key (public)
- Password/Social ID         →      • Badges (public)

Other users NEVER see your:
- Email address
- Real name (unless you use it as display name)
- Phone number
- Auth method
Updated Registration Flow
Screen 1: Ticket Validated
┌─────────────────────────────────┐
│   YOU'RE INVITED! 🎉            │
├─────────────────────────────────┤
│                                 │
│   🌟 SkyWalker                  │
│   (#10247) invited you          │
│                                 │
│   You'll become position #10248 │
│   in The Chain                  │
│                                 │
│   ⏱ This ticket expires in      │
│      22h 13m                    │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   [ACCEPT INVITATION]           │
│                                 │
└─────────────────────────────────┘
Key change: Inviter shows display name ("SkyWalker"), not real name.

Screen 2: Choose Your Identity
┌─────────────────────────────────┐
│   CHOOSE YOUR IDENTITY          │
├─────────────────────────────────┤
│                                 │
│   This is how others will see   │
│   you in The Chain.             │
│                                 │
│   Display name:                 │
│   [NightRider          ]        │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│   ✓ Available                   │
│                                 │
│   Choose an avatar:             │
│   ┌─────────────────────────┐   │
│   │ 🌙 🌟 ⚡ 🔥 🌊 💎 🎭 🎪 │   │
│   │ 🎨 🎯 🎲 🎸 🚀 🌈 ⭐ 🌸 │   │
│   │ [Selected: 🌙]          │   │
│   └─────────────────────────┘   │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Privacy reminder:             │
│   • Others can see: Display     │
│     name, avatar, position      │
│   • Others CANNOT see: Email,   │
│     phone, personal info        │
│                                 │
│   ☑ I understand                │
│                                 │
│   [CONTINUE]                    │
│                                 │
└─────────────────────────────────┘
Screen 3: Secure Your Account
┌─────────────────────────────────┐
│   SECURE YOUR ACCOUNT           │
├─────────────────────────────────┤
│                                 │
│   Choose how to sign in:        │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   RECOMMENDED                   │
│   [🍎 Continue with Apple]      │
│   [📧 Continue with Google]     │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   OR USE EMAIL                  │
│                                 │
│   Email (private):              │
│   [john@example.com     ]       │
│                                 │
│   Password:                     │
│   [●●●●●●●●            ]       │
│                                 │
│   Confirm password:             │
│   [●●●●●●●●            ]       │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Optional (for notifications): │
│   Phone number:                 │
│   [+31 6 1234 5678      ]       │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   ☑ I agree to Terms of Service │
│   ☑ I agree to Privacy Policy   │
│                                 │
│   [CREATE ACCOUNT]              │
│                                 │
└─────────────────────────────────┘
Screen 4: Optional - Share Location
┌─────────────────────────────────┐
│   ONE MORE THING...             │
├─────────────────────────────────┤
│                                 │
│   [World map illustration]      │
│                                 │
│   Help visualize the chain's    │
│   global spread?                │
│                                 │
│   Share your city:              │
│   ○ Yes - Show "Amsterdam, NL"  │
│   ● No - Stay fully anonymous   │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   What others see if you share: │
│   • Your city & country         │
│   • Dot on the global map       │
│                                 │
│   What others DON'T see:        │
│   • Your exact location         │
│   • Your address                │
│                                 │
│   You can change this anytime.  │
│                                 │
│   [CONTINUE]                    │
│                                 │
└─────────────────────────────────┘
Screen 5: Welcome
┌─────────────────────────────────┐
│   WELCOME, NIGHTRIDER! 🌙       │
├─────────────────────────────────┤
│                                 │
│   Your Chain Key:               │
│   ┌───────────────────────────┐ │
│   │       CK-10248            │ │
│   └───────────────────────────┘ │
│                                 │
│   YOUR CHAIN POSITION           │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   🌟 SkyWalker (#10247)         │
│        ↓                        │
│   🌙 YOU (#10248)               │
│        ↓                        │
│   [No invitee yet]              │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   When it's your turn, you'll   │
│   be able to invite ONE person. │
│                                 │
│   [START EXPLORING]             │
│                                 │
└─────────────────────────────────┘
Updated Database Schema
users table (with display identity)
sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chain_key VARCHAR(20) UNIQUE NOT NULL,
    position INTEGER UNIQUE NOT NULL,
    
    -- PUBLIC DISPLAY IDENTITY
    display_name VARCHAR(50) NOT NULL, -- "NightRider"
    display_name_lower VARCHAR(50) NOT NULL, -- "nightrider" for uniqueness
    avatar_emoji VARCHAR(10) DEFAULT '🌟', -- "🌙"
    
    -- PRIVATE AUTH IDENTITY
    email VARCHAR(255) UNIQUE,
    email_verified BOOLEAN DEFAULT false,
    password_hash VARCHAR(255),
    
    phone VARCHAR(20),
    phone_verified BOOLEAN DEFAULT false,
    
    -- PRIVATE PERSONAL INFO (optional)
    real_name VARCHAR(100), -- Optional, never shown to others
    
    -- Social auth
    apple_user_id VARCHAR(255) UNIQUE,
    google_user_id VARCHAR(255) UNIQUE,
    
    -- Account type
    is_guest BOOLEAN DEFAULT false,
    
    -- Status
    status VARCHAR(20) NOT NULL,
    removal_reason VARCHAR(50),
    
    -- Relationships
    inviter_position INTEGER REFERENCES users(position),
    
    -- Timestamps
    joined_at TIMESTAMP NOT NULL DEFAULT NOW(),
    removed_at TIMESTAMP,
    last_active_at TIMESTAMP,
    
    -- Stats
    wasted_tickets INTEGER DEFAULT 0,
    total_tickets_generated INTEGER DEFAULT 0,
    
    -- Settings
    notification_preferences JSONB DEFAULT '{"push": true, "email": true, "sms": false}',
    geo_location JSONB,
    geo_sharing_enabled BOOLEAN DEFAULT false,
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Indexes
    INDEX idx_position (position),
    INDEX idx_display_name_lower (display_name_lower),
    INDEX idx_email (email),
    INDEX idx_status (status),
    
    -- Uniqueness constraint
    UNIQUE(display_name_lower)
);
Display Name Rules
Validation Rules
javascript
// Display Name Requirements
{
  min_length: 3,
  max_length: 20,
  allowed_characters: "a-z, A-Z, 0-9, _, -",
  no_profanity: true,
  must_be_unique: true,
  case_insensitive_uniqueness: true,
  
  // Reserved names
  reserved: [
    "admin",
    "thechain",
    "system",
    "moderator",
    "official",
    "support"
  ]
}
Examples
✅ Valid:
- NightRider
- Sky_Walker_99
- Phoenix-2025
- CryptoKing
- Anonymous_42

❌ Invalid:
- ab (too short)
- ThisIsWayTooLongForADisplayName (too long)
- Night@Rider (invalid character)
- Admin (reserved)
- nightrider (already taken - case insensitive)
API Updates
POST /auth/register
Request:

json
{
  "ticket_code": "tkt_abc123xyz",
  
  // PUBLIC IDENTITY (required)
  "display_name": "NightRider",
  "avatar_emoji": "🌙",
  
  // PRIVATE AUTH (one required)
  // Option 1: Email/Password
  "email": "john@example.com",
  "password": "secure_password_123",
  
  // Option 2: Social
  "auth_provider": "apple", // or "google"
  "provider_user_id": "apple_sub_123456",
  "provider_email": "john@privaterelay.appleid.com",
  
  // OPTIONAL
  "real_name": "John Doe", // Private, never shown
  "phone": "+31612345678",
  "geo_location": {
    "lat": 52.3676,
    "lon": 4.9041,
    "city": "Amsterdam",
    "country": "NL"
  },
  "geo_sharing_enabled": true
}
Response:

json
{
  "success": true,
  "user": {
    "id": "uuid",
    "chain_key": "CK-10248",
    "position": 10248,
    
    // PUBLIC
    "display_name": "NightRider",
    "avatar_emoji": "🌙",
    
    // PRIVATE (only for the user themselves)
    "email": "john@example.com",
    "phone": "+31612345678",
    "real_name": "John Doe",
    
    "status": "active",
    "joined_at": "2025-10-20T14:30:00Z"
  },
  "tokens": {
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 3600
  },
  "inviter": {
    "position": 10247,
    "display_name": "SkyWalker",
    "avatar_emoji": "🌟"
  }
}
POST /auth/check-display-name
Check if display name is available (real-time validation)

Request:

json
{
  "display_name": "NightRider"
}
Response (Available):

json
{
  "available": true,
  "display_name": "NightRider"
}
Response (Taken):

json
{
  "available": false,
  "display_name": "NightRider",
  "suggestions": [
    "NightRider2025",
    "NightRider_42",
    "Night_Rider",
    "DarkRider",
    "MidnightRider"
  ]
}
Response (Invalid):

json
{
  "available": false,
  "display_name": "ab",
  "error": "TOO_SHORT",
  "message": "Display name must be at least 3 characters"
}
GET /users/me
Response:

json
{
  "user": {
    "id": "uuid",
    "chain_key": "CK-10248",
    "position": 10248,
    
    // PUBLIC INFO (what others see)
    "display_name": "NightRider",
    "avatar_emoji": "🌙",
    
    // PRIVATE INFO (only you see)
    "email": "john@example.com",
    "email_verified": true,
    "phone": "+31612345678",
    "phone_verified": false,
    "real_name": "John Doe",
    "auth_method": "email", // or "apple", "google"
    
    "status": "active",
    "joined_at": "2025-10-20T14:30:00Z",
    "wasted_tickets": 2,
    "badges": [...]
  },
  
  "inviter": {
    "position": 10247,
    "display_name": "SkyWalker",
    "avatar_emoji": "🌟",
    "badges": ["chain_savior"]
  },
  
  "invitees": [
    {
      "position": 10249,
      "display_name": "Phoenix",
      "avatar_emoji": "🔥",
      "status": "active",
      "invited_at": "2025-10-21T09:00:00Z"
    }
  ]
}
PATCH /users/me
Update profile

Request:

json
{
  // PUBLIC (affects what others see)
  "display_name": "DarkRider",
  "avatar_emoji": "🌑",
  
  // PRIVATE
  "real_name": "Jonathan Doe",
  "phone": "+31687654321",
  "notification_preferences": {...},
  "geo_sharing_enabled": false
}
Response:

json
{
  "success": true,
  "user": {
    "display_name": "DarkRider",
    "avatar_emoji": "🌑",
    "updated_at": "2025-10-22T10:00:00Z"
  },
  "display_name_changed": true,
  "cooldown_until": "2025-11-22T10:00:00Z" // 30-day cooldown
}
Display Name Change Policy
Rules:
javascript
{
  // Can change display name
  allowed: true,
  
  // But with cooldown
  cooldown_days: 30,
  
  // History kept
  track_history: true,
  
  // Reason: Prevent abuse
  // - Impersonation
  // - Confusion
  // - Gaming the system
}
display_name_history table
sql
CREATE TABLE display_name_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_position INTEGER NOT NULL REFERENCES users(position),
    
    old_display_name VARCHAR(50) NOT NULL,
    new_display_name VARCHAR(50) NOT NULL,
    
    changed_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_user_position (user_position),
    INDEX idx_changed_at (changed_at)
);
Public vs Private Info Display
What Others See (±1 Visibility)
┌─────────────────────────────────┐
│   YOUR CHAIN POSITION           │
├─────────────────────────────────┤
│                                 │
│   🌟 SkyWalker (#10247)         │
│   Chain Savior 🦸               │
│        ↓                        │
│   🌙 YOU (#10248)               │
│        ↓                        │
│   🔥 Phoenix (#10249)           │
│                                 │
└─────────────────────────────────┘
What they see:

✅ Display name ("SkyWalker")
✅ Avatar emoji (🌟)
✅ Position (#10247)
✅ Badges (🦸)
✅ City/Country (if shared)
❌ Email
❌ Phone
❌ Real name
❌ Auth method
User Profile View (Tap on Someone)
┌─────────────────────────────────┐
│   🌟 SKYWALKER                  │
│   Position #10247               │
├─────────────────────────────────┤
│                                 │
│   Joined: Oct 15, 2025          │
│   Status: Active                │
│                                 │
│   📍 Amsterdam, Netherlands     │
│   (City shared by user)         │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   BADGES                        │
│   🦸 Chain Savior               │
│   Earned: Oct 18, 2025          │
│   Saved the chain after 1       │
│   removal                       │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   CHAIN RELATIONSHIP            │
│   • They invited you            │
│                                 │
└─────────────────────────────────┘
Privacy Settings Screen
┌─────────────────────────────────┐
│   PRIVACY SETTINGS              │
├─────────────────────────────────┤
│                                 │
│   PUBLIC PROFILE                │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Display name:                 │
│   NightRider 🌙                 │
│   [CHANGE]                      │
│   (Can change once per 30 days) │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   LOCATION                      │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Share city on map:            │
│   ● Yes - Amsterdam, NL         │
│   ○ No - Fully anonymous        │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   PRIVATE INFO                  │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Email: john@example.com       │
│   (Never shown to others)       │
│                                 │
│   Phone: +31 6 1234 5678        │
│   (Never shown to others)       │
│                                 │
│   [MANAGE PRIVATE INFO]         │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   WHO CAN SEE ME?               │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Currently: ±1 position        │
│   • Your inviter                │
│   • Your invitee                │
│                                 │
│   This may change based on      │
│   chain rules.                  │
│                                 │
│   [LEARN MORE]                  │
│                                 │
└─────────────────────────────────┘
Social Auth Privacy Handling
Sign in with Apple (Hide Email)
javascript
// Apple returns privaterelay email
{
  "provider_email": "abc123@privaterelay.appleid.com",
  "real_email": null, // User chose to hide
  "name": "John Doe"
}

// Storage:
{
  "email": "abc123@privaterelay.appleid.com",
  "display_name": "NightRider", // User chooses separately
  "real_name": "John Doe", // Private, never shown
  "apple_user_id": "sub_123456"
}
Sign in with Google
javascript
// Google returns real email
{
  "provider_email": "john.doe@gmail.com",
  "name": "John Doe",
  "picture": "https://..."
}

// Storage:
{
  "email": "john.doe@gmail.com",
  "display_name": "NightRider", // User chooses separately
  "real_name": "John Doe", // Private, never shown
  "google_user_id": "google_123456"
}

// Note: Even though we have real email,
// it's NEVER shown to other users
Future-Proofing: Increased Visibility
Scenario: Visibility Changes from ±1 to ±2
Before (±1):

Your view:
[#9] → [YOU #10] → [#11]
After (±2):

Your view:
[#8] → [#9] → [YOU #10] → [#11] → [#12]
Privacy Impact:

2 more people can now see your display name & avatar
They STILL cannot see your email, phone, real name
Your display name was chosen with this in mind
Notification when rule changes:

📢 VISIBILITY UPDATE

The chain now shows ±2 positions
instead of ±1.

More people can see your:
✓ Display name (NightRider)
✓ Avatar (🌙)
✓ Chain position
✓ Badges

They still CANNOT see:
✗ Email
✗ Phone
✗ Real name
✗ Personal info

Your privacy is protected.

[REVIEW PRIVACY SETTINGS]
Moderation System (Future)
Report User
┌─────────────────────────────────┐
│   REPORT USER                   │
├─────────────────────────────────┤
│                                 │
│   User: SomeUser (#10250)       │
│                                 │
│   Reason:                       │
│   ○ Inappropriate display name  │
│   ○ Offensive avatar            │
│   ○ Harassment                  │
│   ○ Impersonation              │
│   ○ Other                       │
│                                 │
│   Details (optional):           │
│   [___________________]         │
│                                 │
│   [CANCEL] [SUBMIT REPORT]      │
│                                 │
└─────────────────────────────────┘
admin_moderation table
sql
CREATE TABLE admin_moderation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    reported_user_position INTEGER NOT NULL REFERENCES users(position),
    reporter_user_position INTEGER REFERENCES users(position),
    
    report_type VARCHAR(50) NOT NULL, -- 'inappropriate_name', 'offensive_avatar'
    report_details TEXT,
    
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'reviewed', 'actioned', 'dismissed'
    
    -- Action taken
    action_type VARCHAR(50), -- 'display_name_reset', 'avatar_reset', 'warning', 'ban'
    action_details TEXT,
    actioned_by UUID REFERENCES admin_users(id),
    actioned_at TIMESTAMP,
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_reported_user (reported_user_position),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);
Complete Registration Flow Diagram
┌─────────────────────────────────────────────────────┐
│                                                     │
│  1. Scan QR / Click Link                           │
│     ↓                                               │
│  2. Validate Ticket                                 │
│     ↓                                               │
│  3. Choose Display Name & Avatar (Public)          │
│     ↓                                               │
│  4. Choose Auth Method:                            │
│     • Email/Password                               │
│     • Sign in with Apple                           │
│     • Sign in with Google                          │
│     ↓                                               │
│  5. Optional: Add phone for notifications          │
│     ↓                                               │
│  6. Optional: Share city for map                   │
│     ↓                                               │
│  7. Join Chain & Get Chain Key                     │
│     ↓                                               │
│  8. Onboarding Tutorial                            │
│                                                     │
└─────────────────────────────────────────────────────┘
Summary
✅ Public identity (display name + avatar) separate from auth ✅ Private auth info (email, phone, real name) never exposed ✅ Multiple auth methods (Email/Password, Apple, Google) ✅ Display name uniqueness with validation & suggestions ✅ 30-day cooldown on display name changes ✅ Future-proof privacy for increased visibility ranges ✅ Moderation system for inappropriate names/avatars ✅ Clear privacy boundaries in UI ✅ Location sharing optional & city-level only

This approach:

Protects user privacy fundamentally
Allows anonymous participation
Prevents awkward personal exposure
Works with any future visibility rule changes
Maintains authentic social connections without revealing identity
Next steps:

UI/UX wireframes for complete app flow
Notification system deep dive
Backend infrastructure design
Moderation & safety systems
What would you like to focus on?

No phone number should be required. And let them know they can only see their inviter and will be able to see their invitiee.

Updated Authentication & Registration Flow
Removing phone number requirement and clarifying visibility upfront.

Updated Registration Flow
Screen 1: Ticket Validated
┌─────────────────────────────────┐
│   YOU'RE INVITED! 🎉            │
├─────────────────────────────────┤
│                                 │
│   🌟 SkyWalker                  │
│   (#10247) invited you          │
│                                 │
│   You'll become position #10248 │
│   in The Chain                  │
│                                 │
│   ⏱ This ticket expires in      │
│      22h 13m                    │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   [ACCEPT INVITATION]           │
│                                 │
│   [Learn more about The Chain]  │
│                                 │
└─────────────────────────────────┘
Screen 2: Choose Your Identity
┌─────────────────────────────────┐
│   CHOOSE YOUR IDENTITY          │
├─────────────────────────────────┤
│                                 │
│   This is how others will see   │
│   you in The Chain.             │
│                                 │
│   Display name:                 │
│   [NightRider          ]        │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│   ✓ Available                   │
│                                 │
│   Choose an avatar:             │
│   ┌─────────────────────────┐   │
│   │ 🌙 🌟 ⚡ 🔥 🌊 💎 🎭 🎪 │   │
│   │ 🎨 🎯 🎲 🎸 🚀 🌈 ⭐ 🌸 │   │
│   │ [Selected: 🌙]          │   │
│   └─────────────────────────┘   │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Who can see you?              │
│   • Your inviter (SkyWalker)    │
│   • Your invitee (when you      │
│     invite someone)             │
│                                 │
│   Everyone else: Hidden         │
│                                 │
│   [CONTINUE]                    │
│                                 │
└─────────────────────────────────┘
Screen 3: Secure Your Account
┌─────────────────────────────────┐
│   SECURE YOUR ACCOUNT           │
├─────────────────────────────────┤
│                                 │
│   Choose how to sign in:        │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   RECOMMENDED                   │
│   [🍎 Continue with Apple]      │
│   [📧 Continue with Google]     │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   OR USE EMAIL                  │
│                                 │
│   Email (private, never shown): │
│   [john@example.com     ]       │
│                                 │
│   Password:                     │
│   [●●●●●●●●            ]       │
│                                 │
│   Confirm password:             │
│   [●●●●●●●●            ]       │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   ☑ I agree to Terms of Service │
│   ☑ I agree to Privacy Policy   │
│                                 │
│   [CREATE ACCOUNT]              │
│                                 │
└─────────────────────────────────┘
Key changes:

❌ No phone number field
✅ Clear label: "Email (private, never shown)"
✅ Streamlined flow
Screen 4: Optional - Share Location
┌─────────────────────────────────┐
│   ONE MORE THING...             │
├─────────────────────────────────┤
│                                 │
│   [World map illustration]      │
│                                 │
│   Help visualize the chain's    │
│   global spread?                │
│                                 │
│   Share your city:              │
│   ○ Yes - Show "Amsterdam, NL"  │
│   ● No - Stay fully anonymous   │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Who can see this?             │
│   • Your inviter                │
│   • Your invitee (when invited) │
│   • Global map (as a dot)       │
│                                 │
│   What they DON'T see:          │
│   • Your exact location         │
│   • Your address                │
│   • Your email                  │
│                                 │
│   You can change this anytime.  │
│                                 │
│   [CONTINUE]                    │
│                                 │
└─────────────────────────────────┘
Screen 5: Welcome
┌─────────────────────────────────┐
│   WELCOME, NIGHTRIDER! 🌙       │
├─────────────────────────────────┤
│                                 │
│   Your Chain Key:               │
│   ┌───────────────────────────┐ │
│   │       CK-10248            │ │
│   └───────────────────────────┘ │
│                                 │
│   WHO YOU CAN SEE               │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   🌟 SkyWalker (#10247)         │
│   Your inviter                  │
│        ↓                        │
│   🌙 YOU (#10248)               │
│        ↓                        │
│   [Your invitee - when you      │
│    invite someone]              │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Everyone else is hidden.      │
│   The rest of the chain is      │
│   invisible to you.             │
│                                 │
│   When it's your turn, you'll   │
│   be able to invite ONE person. │
│                                 │
│   [START EXPLORING]             │
│                                 │
└─────────────────────────────────┘
Updated Database Schema
users table (no phone)
sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chain_key VARCHAR(20) UNIQUE NOT NULL,
    position INTEGER UNIQUE NOT NULL,
    
    -- PUBLIC DISPLAY IDENTITY
    display_name VARCHAR(50) NOT NULL,
    display_name_lower VARCHAR(50) NOT NULL,
    avatar_emoji VARCHAR(10) DEFAULT '🌟',
    
    -- PRIVATE AUTH IDENTITY
    email VARCHAR(255) UNIQUE,
    email_verified BOOLEAN DEFAULT false,
    password_hash VARCHAR(255),
    
    -- REMOVED: phone, phone_verified
    
    -- PRIVATE PERSONAL INFO (optional)
    real_name VARCHAR(100), -- Optional, never shown to others
    
    -- Social auth
    apple_user_id VARCHAR(255) UNIQUE,
    google_user_id VARCHAR(255) UNIQUE,
    
    -- Account type
    is_guest BOOLEAN DEFAULT false,
    
    -- Status
    status VARCHAR(20) NOT NULL,
    removal_reason VARCHAR(50),
    
    -- Relationships
    inviter_position INTEGER REFERENCES users(position),
    
    -- Timestamps
    joined_at TIMESTAMP NOT NULL DEFAULT NOW(),
    removed_at TIMESTAMP,
    last_active_at TIMESTAMP,
    
    -- Stats
    wasted_tickets INTEGER DEFAULT 0,
    total_tickets_generated INTEGER DEFAULT 0,
    
    -- Settings
    notification_preferences JSONB DEFAULT '{"push": true, "email": true}',
    geo_location JSONB,
    geo_sharing_enabled BOOLEAN DEFAULT false,
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Indexes
    INDEX idx_position (position),
    INDEX idx_display_name_lower (display_name_lower),
    INDEX idx_email (email),
    INDEX idx_status (status),
    
    UNIQUE(display_name_lower)
);
Updated API Endpoints
POST /auth/register
Request:

json
{
  "ticket_code": "tkt_abc123xyz",
  
  // PUBLIC IDENTITY (required)
  "display_name": "NightRider",
  "avatar_emoji": "🌙",
  
  // PRIVATE AUTH (one required)
  // Option 1: Email/Password
  "email": "john@example.com",
  "password": "secure_password_123",
  
  // Option 2: Social
  "auth_provider": "apple",
  "provider_user_id": "apple_sub_123456",
  "provider_email": "john@privaterelay.appleid.com",
  
  // OPTIONAL
  "real_name": "John Doe", // Private, never shown
  "geo_location": {
    "lat": 52.3676,
    "lon": 4.9041,
    "city": "Amsterdam",
    "country": "NL"
  },
  "geo_sharing_enabled": true
}
Response:

json
{
  "success": true,
  "user": {
    "id": "uuid",
    "chain_key": "CK-10248",
    "position": 10248,
    
    // PUBLIC
    "display_name": "NightRider",
    "avatar_emoji": "🌙",
    
    // PRIVATE (only for the user themselves)
    "email": "john@example.com",
    "real_name": "John Doe",
    
    "status": "active",
    "joined_at": "2025-10-20T14:30:00Z"
  },
  "tokens": {
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 3600
  },
  "inviter": {
    "position": 10247,
    "display_name": "SkyWalker",
    "avatar_emoji": "🌟"
  },
  "visibility_info": {
    "can_see": ["inviter", "invitee_when_invited"],
    "cannot_see": ["rest_of_chain"]
  }
}
GET /users/me
Response:

json
{
  "user": {
    "id": "uuid",
    "chain_key": "CK-10248",
    "position": 10248,
    
    // PUBLIC INFO (what others in your ±1 range see)
    "display_name": "NightRider",
    "avatar_emoji": "🌙",
    
    // PRIVATE INFO (only you see)
    "email": "john@example.com",
    "email_verified": true,
    "real_name": "John Doe",
    "auth_method": "email",
    
    "status": "active",
    "joined_at": "2025-10-20T14:30:00Z",
    "wasted_tickets": 2,
    "badges": [...]
  },
  
  "inviter": {
    "position": 10247,
    "display_name": "SkyWalker",
    "avatar_emoji": "🌟",
    "badges": ["chain_savior"],
    "city": "Berlin, DE" // Only if they share location
  },
  
  "invitees": [
    {
      "position": 10249,
      "display_name": "Phoenix",
      "avatar_emoji": "🔥",
      "status": "active",
      "invited_at": "2025-10-21T09:00:00Z",
      "city": "Paris, FR"
    }
  ],
  
  "visibility": {
    "you_can_see": {
      "inviter": true,
      "invitees": true,
      "total_visible": 2
    },
    "who_can_see_you": {
      "inviter": true,
      "invitees": 1,
      "total": 2
    }
  }
}
Notification Preferences (Simplified)
Without Phone:
json
{
  "notification_preferences": {
    "push": true,        // In-app push notifications
    "email": true        // Email notifications
  }
}
Notification Settings Screen:
┌─────────────────────────────────┐
│   NOTIFICATION SETTINGS         │
├─────────────────────────────────┤
│                                 │
│   How should we notify you?     │
│                                 │
│   ☑ Push notifications          │
│   ☑ Email (john@example.com)    │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   NOTIFY ME WHEN:               │
│                                 │
│   ☑ I become the tip            │
│   ☑ My invitee joins            │
│   ☑ My invitee is removed       │
│   ☑ Rule changes announced      │
│   ☑ Milestone reached           │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   FREQUENCY                     │
│   ○ All notifications           │
│   ● Important only              │
│   ○ Daily digest                │
│                                 │
└─────────────────────────────────┘
Updated Onboarding Tutorial
Tutorial Screen 1: Visibility
┌─────────────────────────────────┐
│   WHO YOU CAN SEE               │
├─────────────────────────────────┤
│                                 │
│   [Illustration: 3 connected    │
│    nodes, middle one glowing]   │
│                                 │
│   You can ONLY see:             │
│   • The person who invited you  │
│   • The person you invite       │
│                                 │
│   Everyone else is hidden.      │
│                                 │
│   This keeps the chain          │
│   mysterious and personal.      │
│                                 │
│   [NEXT] (1/5)                  │
│                                 │
└─────────────────────────────────┘
Tutorial Screen 2: Your Turn
┌─────────────────────────────────┐
│   WAITING FOR YOUR TURN         │
├─────────────────────────────────┤
│                                 │
│   [Illustration: Chain with     │
│    glowing tip]                 │
│                                 │
│   Right now, someone else is    │
│   the "tip" of the chain.       │
│                                 │
│   When they successfully        │
│   invite someone, it becomes    │
│   that person's turn.           │
│                                 │
│   Eventually, it will be YOUR   │
│   turn to invite someone!       │
│                                 │
│   [NEXT] (2/5)                  │
│                                 │
└─────────────────────────────────┘
Tutorial Screen 3: Your Mission
┌─────────────────────────────────┐
│   YOUR MISSION                  │
├─────────────────────────────────┤
│                                 │
│   [Illustration: QR code and    │
│    timer]                       │
│                                 │
│   When it's your turn:          │
│                                 │
│   1. Generate a ticket          │
│   2. Share it with ONE person   │
│   3. They have 24 hours to join │
│                                 │
│   If they don't join:           │
│   • Ticket expires              │
│   • You can try again (3 tries) │
│                                 │
│   [NEXT] (3/5)                  │
│                                 │
└─────────────────────────────────┘
Tutorial Screen 4: Stakes
┌─────────────────────────────────┐
│   THE STAKES                    │
├─────────────────────────────────┤
│                                 │
│   [Illustration: Broken chain]  │
│                                 │
│   If you fail 3 times:          │
│   • You're removed from chain   │
│   • The tip goes back to the    │
│     person who invited you      │
│                                 │
│   This keeps the chain moving   │
│   and creates accountability.   │
│                                 │
│   Don't break the chain!        │
│                                 │
│   [NEXT] (4/5)                  │
│                                 │
└─────────────────────────────────┘
Tutorial Screen 5: Ready
┌─────────────────────────────────┐
│   YOU'RE READY!                 │
├─────────────────────────────────┤
│                                 │
│   [Illustration: Connected      │
│    chain glowing]               │
│                                 │
│   You're now part of The Chain. │
│                                 │
│   Remember:                     │
│   • You can only see ±1 position│
│   • Wait for your turn          │
│   • Invite wisely               │
│   • Keep the chain alive        │
│                                 │
│   Current chain: 10,248 members │
│   Your position: #10248         │
│                                 │
│   [START EXPLORING]             │
│                                 │
└─────────────────────────────────┘
Main App Screen (Visibility Emphasis)
┌─────────────────────────────────┐
│   THE CHAIN                  ☰  │
├─────────────────────────────────┤
│                                 │
│   YOUR CHAIN POSITION           │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   🌟 SkyWalker (#10247)         │
│   Your inviter                  │
│        ↓                        │
│   🌙 YOU (#10248)               │
│        ↓                        │
│   🔥 Phoenix (#10249)           │
│   Your invitee                  │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   ℹ️ You can only see these 2   │
│      people. Everyone else      │
│      is hidden.                 │
│                                 │
├─────────────────────────────────┤
│   GLOBAL STATS                  │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│   Total members: 10,249         │
│   Active: 9,892                 │
│   Your position: #10248         │
│   Current tip: #10249           │
│   Growth: +12 today             │
│                                 │
│   [VIEW GLOBAL MAP]             │
│                                 │
└─────────────────────────────────┘
Profile Settings (Updated)
┌─────────────────────────────────┐
│   PROFILE SETTINGS              │
├─────────────────────────────────┤
│                                 │
│   PUBLIC PROFILE                │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Display name: NightRider 🌙   │
│   [CHANGE]                      │
│   (Can change once per 30 days) │
│                                 │
│   Who can see this:             │
│   • Your inviter                │
│   • Your invitee                │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   ACCOUNT (PRIVATE)             │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Email: john@example.com ✓     │
│   (Never shown to others)       │
│   [CHANGE EMAIL]                │
│                                 │
│   Password: ••••••••            │
│   [CHANGE PASSWORD]             │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   LOCATION                      │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Share city: ● Yes ○ No        │
│   Amsterdam, NL                 │
│                                 │
│   Visible to:                   │
│   • Your inviter & invitee      │
│   • Global map (as a dot)       │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   VISIBILITY INFO               │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Currently: ±1 position        │
│                                 │
│   You can see:                  │
│   • SkyWalker (#10247)          │
│   • Phoenix (#10249)            │
│                                 │
│   Can see you:                  │
│   • SkyWalker (#10247)          │
│   • Phoenix (#10249)            │
│                                 │
│   [LEARN MORE ABOUT VISIBILITY] │
│                                 │
└─────────────────────────────────┘
Updated Privacy Policy Highlights
In-App Privacy Summary:
┌─────────────────────────────────┐
│   YOUR PRIVACY                  │
├─────────────────────────────────┤
│                                 │
│   WHAT OTHERS SEE               │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Only your inviter and invitee │
│   can see:                      │
│   ✓ Display name (NightRider)   │
│   ✓ Avatar emoji (🌙)           │
│   ✓ Position (#10248)           │
│   ✓ Badges (if earned)          │
│   ✓ City (if you share)         │
│                                 │
│   WHAT THEY NEVER SEE           │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   ✗ Email address               │
│   ✗ Real name                   │
│   ✗ Exact location              │
│   ✗ How you signed up           │
│                                 │
│   IMPORTANT                     │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   • Visibility rules may change │
│   • More people might see you   │
│   • But NEVER your private info │
│                                 │
│   That's why we ask for a       │
│   display name, not your real   │
│   name.                         │
│                                 │
│   [READ FULL PRIVACY POLICY]    │
│                                 │
└─────────────────────────────────┘
When Visibility Rules Change
Notification Example:
📢 VISIBILITY RULE UPDATE

The chain now shows ±2 positions
instead of ±1.

YOU CAN NOW SEE:
- Position #10246 (was hidden)
- Position #10250 (was hidden)

THEY CAN NOW SEE YOU:
- Position #10246
- Position #10250

THEY SEE:
✓ NightRider 🌙 (#10248)
✓ Amsterdam, NL

THEY DON'T SEE:
✗ Your email
✗ Your real name
✗ Your exact location

Your privacy remains protected.

[REVIEW YOUR PROFILE]
[LEARN MORE]
Help/FAQ Section
┌─────────────────────────────────┐
│   FREQUENTLY ASKED QUESTIONS    │
├─────────────────────────────────┤
│                                 │
│   Q: Who can see my email?      │
│   A: Nobody. Your email is      │
│      private and used only for  │
│      login and notifications.   │
│                                 │
│   Q: Can people find my real    │
│      identity?                  │
│   A: No. You choose a display   │
│      name that doesn't have to  │
│      be your real name.         │
│                                 │
│   Q: Who can see me in the      │
│      chain?                     │
│   A: Only 2 people:             │
│      • Your inviter             │
│      • Your invitee             │
│      Everyone else: hidden      │
│                                 │
│   Q: Can visibility rules       │
│      change?                    │
│   A: Yes, but your private info │
│      (email, real name) will    │
│      ALWAYS stay private.       │
│                                 │
│   Q: What if I share location?  │
│   A: Only your city is shown,   │
│      not your exact address.    │
│                                 │
│   [MORE QUESTIONS]              │
│                                 │
└─────────────────────────────────┘
Summary of Changes
✅ Removed phone number completely ✅ Clear visibility explanation during onboarding ✅ Emphasized "±1 only" throughout UI ✅ Privacy warnings about future rule changes ✅ Simplified notification settings (push + email only) ✅ Explicit labeling of private vs public info ✅ "Who can see you" info in profile ✅ Onboarding tutorial includes visibility lesson

Complete Registration Data Model
json
{
  // PUBLIC (visible to inviter + invitee)
  "display_name": "NightRider",
  "avatar_emoji": "🌙",
  "position": 10248,
  "chain_key": "CK-10248",
  "badges": ["chain_savior"],
  "city": "Amsterdam, NL", // if shared
  
  // PRIVATE (only for the user)
  "email": "john@example.com",
  "email_verified": true,
  "password_hash": "...", // or null if social auth
  "apple_user_id": null,
  "google_user_id": null,
  "real_name": "John Doe", // optional
  "auth_method": "email", // "email", "apple", "google"
  
  // VISIBILITY
  "can_see": {
    "inviter": 10247,
    "invitees": [10249]
  },
  "visible_to": {
    "inviter": 10247,
    "invitees": [10249]
  }
}
This updated flow is:

✅ Cleaner (no phone complexity)
✅ More transparent (visibility upfront)
✅ Privacy-focused (clear boundaries)
✅ Future-proof (prepared for rule changes)
✅ User-friendly (less friction)
Ready to move to the next phase?

Complete UI/UX wireframes for entire app
Notification system architecture
Backend infrastructure & deployment
Testing & QA strategy
What's next?

I don't want to keep track of peoples location. Location should not rely on but persons declaration. Lets ask them, what country they feel they belong (doesnt necessarily mean that they live there. This should be mandatory and not changable until I enable it to be changed temporarily in the future events

Updated Location System: Country-Based Identity
Excellent decision! This shifts from technical tracking to cultural/personal identity.

Philosophy Change
OLD Approach:

"Where are you?" (tracking-based)
→ GPS coordinates
→ Privacy concerns
→ Technical complexity
NEW Approach:

"Which country do you belong to?" (identity-based)
→ Personal declaration
→ Cultural connection
→ Simple & meaningful
Updated Registration Flow
Screen 2: Choose Your Identity (Updated)
┌─────────────────────────────────┐
│   CHOOSE YOUR IDENTITY          │
├─────────────────────────────────┤
│                                 │
│   This is how others will see   │
│   you in The Chain.             │
│                                 │
│   Display name:                 │
│   [NightRider          ]        │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│   ✓ Available                   │
│                                 │
│   Choose an avatar:             │
│   ┌─────────────────────────┐   │
│   │ 🌙 🌟 ⚡ 🔥 🌊 💎 🎭 🎪 │   │
│   │ 🎨 🎯 🎲 🎸 🚀 🌈 ⭐ 🌸 │   │
│   │ [Selected: 🌙]          │   │
│   └─────────────────────────┘   │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Who can see you?              │
│   • Your inviter (SkyWalker)    │
│   • Your invitee (when you      │
│     invite someone)             │
│                                 │
│   [CONTINUE]                    │
│                                 │
└─────────────────────────────────┘
NEW Screen 3: Your Country (Mandatory)
┌─────────────────────────────────┐
│   WHICH COUNTRY DO YOU          │
│   BELONG TO?                    │
├─────────────────────────────────┤
│                                 │
│   [Globe illustration]          │
│                                 │
│   This helps visualize the      │
│   chain's global reach.         │
│                                 │
│   Select your country:          │
│   ┌───────────────────────────┐ │
│   │ 🔍 Search countries...    │ │
│   └───────────────────────────┘ │
│                                 │
│   Popular:                      │
│   🇳🇱 Netherlands               │
│   🇺🇸 United States             │
│   🇬🇧 United Kingdom            │
│   🇩🇪 Germany                   │
│   🇫🇷 France                    │
│   🇪🇸 Spain                     │
│                                 │
│   [See all countries ↓]         │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Note: This doesn't have to be │
│   where you currently live.     │
│   Choose the country you feel   │
│   connected to.                 │
│                                 │
│   You cannot change this later. │
│                                 │
│   [CONTINUE]                    │
│                                 │
└─────────────────────────────────┘
Key points:

🌍 Mandatory - Must select to continue
🔒 Permanent - Cannot change (until admin enables)
🎭 Identity-based - "Feel connected to" not "live in"
🚫 No GPS - Pure declaration
Screen 4: Secure Your Account (Same as before)
┌─────────────────────────────────┐
│   SECURE YOUR ACCOUNT           │
├─────────────────────────────────┤
│                                 │
│   Choose how to sign in:        │
│                                 │
│   [🍎 Continue with Apple]      │
│   [📧 Continue with Google]     │
│                                 │
│   OR USE EMAIL                  │
│   Email: [john@example.com]     │
│   Password: [●●●●●●●●]         │
│   Confirm: [●●●●●●●●]          │
│                                 │
│   ☑ I agree to Terms            │
│   ☑ I agree to Privacy Policy   │
│                                 │
│   [CREATE ACCOUNT]              │
│                                 │
└─────────────────────────────────┘
Screen 5: Welcome (Updated)
┌─────────────────────────────────┐
│   WELCOME, NIGHTRIDER! 🌙       │
├─────────────────────────────────┤
│                                 │
│   Your Chain Key:               │
│   ┌───────────────────────────┐ │
│   │       CK-10248            │ │
│   └───────────────────────────┘ │
│                                 │
│   🇳🇱 Netherlands               │
│                                 │
│   YOUR CHAIN POSITION           │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   🌟 SkyWalker (#10247) 🇩🇪    │
│        ↓                        │
│   🌙 YOU (#10248) 🇳🇱          │
│        ↓                        │
│   [No invitee yet]              │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   The chain now spans           │
│   47 countries!                 │
│                                 │
│   [START EXPLORING]             │
│                                 │
└─────────────────────────────────┘
Updated Database Schema
users table (country-based)
sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chain_key VARCHAR(20) UNIQUE NOT NULL,
    position INTEGER UNIQUE NOT NULL,
    
    -- PUBLIC DISPLAY IDENTITY
    display_name VARCHAR(50) NOT NULL,
    display_name_lower VARCHAR(50) NOT NULL,
    avatar_emoji VARCHAR(10) DEFAULT '🌟',
    
    -- COUNTRY (PUBLIC, MANDATORY, IMMUTABLE)
    country_code VARCHAR(2) NOT NULL, -- ISO 3166-1 alpha-2 (NL, US, GB, etc.)
    country_name VARCHAR(100) NOT NULL, -- "Netherlands"
    country_flag_emoji VARCHAR(10) NOT NULL, -- "🇳🇱"
    country_locked BOOLEAN DEFAULT true, -- Admin can unlock temporarily
    country_changed_at TIMESTAMP, -- Track if/when admin allows change
    
    -- PRIVATE AUTH IDENTITY
    email VARCHAR(255) UNIQUE,
    email_verified BOOLEAN DEFAULT false,
    password_hash VARCHAR(255),
    
    -- PRIVATE PERSONAL INFO (optional)
    real_name VARCHAR(100),
    
    -- Social auth
    apple_user_id VARCHAR(255) UNIQUE,
    google_user_id VARCHAR(255) UNIQUE,
    
    -- Account type
    is_guest BOOLEAN DEFAULT false,
    
    -- Status
    status VARCHAR(20) NOT NULL,
    removal_reason VARCHAR(50),
    
    -- Relationships
    inviter_position INTEGER REFERENCES users(position),
    
    -- Timestamps
    joined_at TIMESTAMP NOT NULL DEFAULT NOW(),
    removed_at TIMESTAMP,
    last_active_at TIMESTAMP,
    
    -- Stats
    wasted_tickets INTEGER DEFAULT 0,
    total_tickets_generated INTEGER DEFAULT 0,
    
    -- Settings
    notification_preferences JSONB DEFAULT '{"push": true, "email": true}',
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Indexes
    INDEX idx_position (position),
    INDEX idx_display_name_lower (display_name_lower),
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_country_code (country_code),
    
    UNIQUE(display_name_lower)
);
Key changes:

❌ Removed: geo_location, geo_sharing_enabled, phone, phone_verified
✅ Added: country_code, country_name, country_flag_emoji
✅ Added: country_locked (for admin control)
countries reference table
sql
CREATE TABLE countries (
    code VARCHAR(2) PRIMARY KEY, -- ISO 3166-1 alpha-2
    name VARCHAR(100) NOT NULL,
    flag_emoji VARCHAR(10) NOT NULL,
    region VARCHAR(50), -- "Europe", "Asia", "Americas", etc.
    
    -- Display order
    is_popular BOOLEAN DEFAULT false, -- Show in "Popular" section
    sort_order INTEGER DEFAULT 999,
    
    -- Stats (denormalized for performance)
    member_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_is_popular (is_popular),
    INDEX idx_member_count (member_count)
);

-- Seed data examples
INSERT INTO countries (code, name, flag_emoji, region, is_popular, sort_order) VALUES
('NL', 'Netherlands', '🇳🇱', 'Europe', true, 1),
('US', 'United States', '🇺🇸', 'Americas', true, 2),
('GB', 'United Kingdom', '🇬🇧', 'Europe', true, 3),
('DE', 'Germany', '🇩🇪', 'Europe', true, 4),
('FR', 'France', '🇫🇷', 'Europe', true, 5),
('ES', 'Spain', '🇪🇸', 'Europe', true, 6),
('JP', 'Japan', '🇯🇵', 'Asia', true, 7),
('BR', 'Brazil', '🇧🇷', 'Americas', true, 8),
-- ... all 249 countries
;
country_change_events table (for when admin temporarily allows changes)
sql
CREATE TABLE country_change_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Event details
    event_name VARCHAR(100) NOT NULL, -- "Special Migration Event 2025"
    description TEXT,
    
    -- Timing
    enabled_at TIMESTAMP NOT NULL,
    disabled_at TIMESTAMP,
    
    -- Who can change
    applies_to VARCHAR(20) DEFAULT 'all', -- 'all', 'specific_countries', 'specific_users'
    allowed_countries TEXT[], -- Array of country codes, if specific
    
    -- Usage stats
    total_changes_made INTEGER DEFAULT 0,
    
    -- Metadata
    created_by UUID REFERENCES admin_users(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_enabled_at (enabled_at),
    INDEX idx_disabled_at (disabled_at)
);
country_changes table (track when users change)
sql
CREATE TABLE country_changes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    user_position INTEGER NOT NULL REFERENCES users(position),
    
    old_country_code VARCHAR(2) NOT NULL,
    old_country_name VARCHAR(100) NOT NULL,
    
    new_country_code VARCHAR(2) NOT NULL,
    new_country_name VARCHAR(100) NOT NULL,
    
    -- Which event allowed this change
    change_event_id UUID REFERENCES country_change_events(id),
    
    changed_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    INDEX idx_user_position (user_position),
    INDEX idx_changed_at (changed_at),
    INDEX idx_change_event_id (change_event_id)
);
API Updates
POST /auth/register
Request:

json
{
  "ticket_code": "tkt_abc123xyz",
  
  // PUBLIC IDENTITY (required)
  "display_name": "NightRider",
  "avatar_emoji": "🌙",
  "country_code": "NL", // MANDATORY
  
  // PRIVATE AUTH (one required)
  "email": "john@example.com",
  "password": "secure_password_123"
  // OR social auth
}
Response:

json
{
  "success": true,
  "user": {
    "id": "uuid",
    "chain_key": "CK-10248",
    "position": 10248,
    
    // PUBLIC
    "display_name": "NightRider",
    "avatar_emoji": "🌙",
    "country_code": "NL",
    "country_name": "Netherlands",
    "country_flag": "🇳🇱",
    "country_locked": true,
    
    // PRIVATE
    "email": "john@example.com",
    
    "status": "active",
    "joined_at": "2025-10-20T14:30:00Z"
  },
  "tokens": {...},
  "inviter": {
    "position": 10247,
    "display_name": "SkyWalker",
    "avatar_emoji": "🌟",
    "country_flag": "🇩🇪"
  }
}
GET /countries
Get list of all countries (for registration picker)

Query params:

popular_only (boolean) - Only show popular countries
Response:

json
{
  "countries": [
    {
      "code": "NL",
      "name": "Netherlands",
      "flag": "🇳🇱",
      "region": "Europe",
      "member_count": 247
    },
    {
      "code": "US",
      "name": "United States",
      "flag": "🇺🇸",
      "region": "Americas",
      "member_count": 892
    }
    // ... all countries
  ],
  "total": 249
}
GET /countries/stats
Get country distribution stats

Response:

json
{
  "total_countries_represented": 47,
  "total_members": 10248,
  "top_countries": [
    {
      "code": "US",
      "name": "United States",
      "flag": "🇺🇸",
      "member_count": 892,
      "percentage": 8.7
    },
    {
      "code": "NL",
      "name": "Netherlands",
      "flag": "🇳🇱",
      "member_count": 247,
      "percentage": 2.4
    }
    // ... top 10
  ],
  "regions": [
    {
      "name": "Europe",
      "countries": 23,
      "members": 3456,
      "percentage": 33.7
    },
    {
      "name": "Asia",
      "countries": 12,
      "members": 2891,
      "percentage": 28.2
    }
    // ...
  ]
}
PATCH /users/me/country (normally blocked)
Attempt to change country (will fail unless admin enables)

Request:

json
{
  "new_country_code": "DE"
}
Response (Normal - Locked):

json
{
  "success": false,
  "error": {
    "code": "COUNTRY_LOCKED",
    "message": "Country changes are currently disabled",
    "current_country": {
      "code": "NL",
      "name": "Netherlands",
      "locked_since": "2025-10-20T14:30:00Z"
    }
  }
}
Response (During Special Event - Unlocked):

json
{
  "success": true,
  "user": {
    "country_code": "DE",
    "country_name": "Germany",
    "country_flag": "🇩🇪",
    "country_locked": true,
    "country_changed_at": "2025-11-15T10:00:00Z"
  },
  "change_event": {
    "event_name": "Migration Week 2025",
    "message": "Country successfully updated during special event"
  }
}
Updated UI Components
Your Chain View (with countries)
┌─────────────────────────────────┐
│   THE CHAIN                  ☰  │
├─────────────────────────────────┤
│                                 │
│   YOUR CHAIN POSITION           │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   🌟 SkyWalker (#10247) 🇩🇪    │
│        ↓                        │
│   🌙 YOU (#10248) 🇳🇱          │
│        ↓                        │
│   🔥 Phoenix (#10249) 🇫🇷      │
│                                 │
├─────────────────────────────────┤
│   GLOBAL STATS                  │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│   Total members: 10,249         │
│   Countries: 47                 │
│   Your position: #10248         │
│                                 │
│   [VIEW COUNTRY MAP]            │
│                                 │
└─────────────────────────────────┘
Global Country Map Screen
┌─────────────────────────────────┐
│   GLOBAL REACH               ☰  │
├─────────────────────────────────┤
│                                 │
│   [Interactive World Map]       │
│   • Colored by member count     │
│   • Click country for details   │
│                                 │
├─────────────────────────────────┤
│   TOP COUNTRIES                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   🇺🇸 United States      892    │
│   🇩🇪 Germany            456    │
│   🇳🇱 Netherlands        247    │
│   🇬🇧 United Kingdom     198    │
│   🇫🇷 France             187    │
│                                 │
│   [VIEW ALL 47 COUNTRIES]       │
│                                 │
├─────────────────────────────────┤
│   REGIONAL DISTRIBUTION         │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Europe        3,456 (33.7%)   │
│   Asia          2,891 (28.2%)   │
│   Americas      2,345 (22.9%)   │
│   Africa          892 (8.7%)    │
│   Oceania         665 (6.5%)    │
│                                 │
└─────────────────────────────────┘
Country Detail Screen
┌─────────────────────────────────┐
│   🇳🇱 NETHERLANDS            ←  │
├─────────────────────────────────┤
│                                 │
│   247 members                   │
│   2.4% of total chain           │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   RECENT MEMBERS                │
│                                 │
│   🌙 NightRider (#10248)        │
│   Joined: Oct 20, 2025          │
│                                 │
│   🌊 WaveRunner (#10103)        │
│   Joined: Oct 18, 2025          │
│                                 │
│   ⚡ ThunderBolt (#9847)        │
│   Joined: Oct 15, 2025          │
│                                 │
│   [VIEW ALL 247 MEMBERS]        │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   STATS                         │
│   First member: #47             │
│   Latest member: #10248         │
│   Success rate: 96.3%           │
│                                 │
└─────────────────────────────────┘
Profile Settings (with locked country)
┌─────────────────────────────────┐
│   PROFILE SETTINGS              │
├─────────────────────────────────┤
│                                 │
│   PUBLIC PROFILE                │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Display name: NightRider 🌙   │
│   [CHANGE]                      │
│                                 │
│   Country: 🇳🇱 Netherlands 🔒   │
│   [LOCKED]                      │
│                                 │
│   ℹ️ Your country is permanent   │
│      and cannot be changed.     │
│                                 │
│      Why? To maintain authentic │
│      cultural representation.   │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   ACCOUNT (PRIVATE)             │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Email: john@example.com ✓     │
│   [CHANGE EMAIL]                │
│                                 │
│   Password: ••••••••            │
│   [CHANGE PASSWORD]             │
│                                 │
└─────────────────────────────────┘
Admin Features: Temporary Country Change Events
Admin Dashboard - Create Country Change Event
┌─────────────────────────────────────────┐
│ CREATE COUNTRY CHANGE EVENT             │
├─────────────────────────────────────────┤
│                                         │
│ Event name:                             │
│ [Migration Week 2025        ]           │
│                                         │
│ Description:                            │
│ [Allow users to update their country    │
│  affiliation during this special event] │
│                                         │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                         │
│ Start date & time:                      │
│ [2025-11-01] [00:00] UTC                │
│                                         │
│ End date & time:                        │
│ [2025-11-07] [23:59] UTC                │
│                                         │
│ Duration: 7 days                        │
│                                         │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                         │
│ Who can change?                         │
│ ● All users                             │
│ ○ Specific countries only               │
│ ○ Specific users only                   │
│                                         │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                         │
│ Notifications:                          │
│ ☑ Announce to all users                 │
│ ☑ Remind 24h before end                 │
│ ☑ Send confirmation after change        │
│                                         │
│ [CANCEL] [CREATE EVENT]                 │
│                                         │
└─────────────────────────────────────────┘
User Experience During Change Event
Announcement:

🌍 SPECIAL EVENT: MIGRATION WEEK

From Nov 1-7, 2025, you can update
your country affiliation!

This is a rare opportunity.
Your country is normally locked.

Why: Reflect life changes, new
connections, or deeper cultural ties.

This event will last 7 days.

[CHANGE MY COUNTRY NOW]
[REMIND ME LATER]
During Event - Profile Settings:

┌─────────────────────────────────┐
│   PROFILE SETTINGS              │
├─────────────────────────────────┤
│                                 │
│   PUBLIC PROFILE                │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   Display name: NightRider 🌙   │
│                                 │
│   Country: 🇳🇱 Netherlands 🔓   │
│   [CHANGE COUNTRY] ← UNLOCKED   │
│                                 │
│   🌍 Migration Week Active!     │
│      Change available until     │
│      Nov 7, 23:59 UTC           │
│                                 │
│      ⏱ 5 days remaining          │
│                                 │
└─────────────────────────────────┘
Country Change Flow:

┌─────────────────────────────────┐
│   CHANGE YOUR COUNTRY           │
├─────────────────────────────────┤
│                                 │
│   Current: 🇳🇱 Netherlands      │
│                                 │
│   Select new country:           │
│   ┌───────────────────────────┐ │
│   │ 🔍 Search...              │ │
│   └───────────────────────────┘ │
│                                 │
│   🇩🇪 Germany                   │
│   🇺🇸 United States             │
│   🇬🇧 United Kingdom            │
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                 │
│   ⚠️ Important:                 │
│   This change is permanent      │
│   until the next migration      │
│   event (date unknown).         │
│                                 │
│   Are you sure?                 │
│                                 │
│   [CANCEL] [CONFIRM CHANGE]     │
│                                 │
└─────────────────────────────────┘
After Change:

✅ COUNTRY UPDATED

Your country has been changed:
🇳🇱 Netherlands → 🇩🇪 Germany

This change is now permanent until
the next migration event.

Your inviter and invitee will see
your updated country.

[DONE]
End of Event:

🔒 MIGRATION WEEK ENDED

Country changes are now locked again.

During this event:
- 1,247 users changed countries
- Most popular: 🇺🇸 → 🇩🇪 (89 changes)

Your country: 🇩🇪 Germany
Status: Locked

[VIEW STATS]
Admin API Endpoints
POST /admin/country-events/create
Create a country change event

Request:

json
{
  "event_name": "Migration Week 2025",
  "description": "Allow users to update country affiliation",
  "enabled_at": "2025-11-01T00:00:00Z",
  "disabled_at": "2025-11-07T23:59:59Z",
  "applies_to": "all",
  "notification_config": {
    "announce": true,
    "remind_24h_before_end": true,
    "confirm_after_change": true
  }
}
Response:

json
{
  "success": true,
  "event": {
    "id": "uuid",
    "event_name": "Migration Week 2025",
    "enabled_at": "2025-11-01T00:00:00Z",
    "disabled_at": "2025-11-07T23:59:59Z",
    "duration_days": 7,
    "status": "scheduled"
  }
}
GET /admin/country-events/active
Get current active event

Response (Active):

json
{
  "active": true,
  "event": {
    "id": "uuid",
    "event_name": "Migration Week 2025",
    "enabled_at": "2025-11-01T00:00:00Z",
    "disabled_at": "2025-11-07T23:59:59Z",
    "days_remaining": 5,
    "total_changes_made": 347
  }
}
Response (No Active Event):

json
{
  "active": false,
  "event": null,
  "next_scheduled": null
}
GET /admin/country-events/:id/stats
Get stats for a specific event

Response:

json
{
  "event": {
    "id": "uuid",
    "event_name": "Migration Week 2025",
    "status": "completed"
  },
  "stats": {
    "total_changes": 1247,
    "eligible_users": 10248,
    "participation_rate": 12.17,
    "most_popular_changes": [
      {
        "from": "NL",
        "to": "DE",
        "count": 89
      },
      {
        "from": "US",
        "to": "GB",
        "count": 67
      }
    ],
    "countries_gained_most": [
      {"code": "DE", "gained": 234},
      {"code": "US", "gained": 189}
    ],
    "countries_lost_most": [
      {"code": "NL", "lost": 123},
      {"code": "FR", "lost": 98}
    ]
  }
}
Analytics & Insights
Country Distribution Dashboard
┌─────────────────────────────────────────┐
│ COUNTRY ANALYTICS                       │
├─────────────────────────────────────────┤
│                                         │
│ Total countries represented: 47         │
│ Total members: 10,248                   │
│                                         │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                         │
│ HEATMAP                                 │
│ [World map colored by density]          │
│                                         │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                         │
│ GROWTH BY REGION (Last 30 days)        │
│                                         │
│ Europe:        +234 (27% growth)        │
│ Asia:          +189 (19% growth)        │
│ Americas:      +156 (15% growth)        │
│                                         │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                         │
│ COUNTRY DIVERSITY INDEX                 │
│ 0.87 (Very diverse)                     │
│                                         │
│ • No single country > 10% of total      │
│ • 47 countries represented              │
│ • Balanced regional distribution        │
│                                         │
└─────────────────────────────────────────┘
Summary
✅ Country-based identity instead of GPS location ✅ Mandatory during registration ✅ Permanently locked by default ✅ Admin can enable temporary change events ✅ Cultural affiliation not physical location ✅ Simple & meaningful visualization ✅ No tracking or privacy concerns ✅ Event system for special migrations

Benefits:

🎭 Personal identity - "Which country do you belong to?"
🔒 Stable data - No constant location changes
🌍 Global visualization - Clean country map
🚫 No GPS - Zero tracking, zero privacy issues
🎉 Special events - Create moments of change
📊 Clean analytics - Country distribution stats
Ready for next phase:

Complete UI/UX wireframes
Notification system architecture
Backend infrastructure
Testing strategy
What's next?



Session limit reached ∙ resets 8:00 PM
Upgrade
Now lets write a functional  statement document for the entire projects last status, make a project planning with clear achivables.


Project understanding strategy - Claude