# Bloom UI Guidelines

## Version

1.0

---

# Design Philosophy

Bloom is not a hookup app.

Bloom is a premium LGBTQ+ dating platform focused on meaningful relationships and authentic human connection.

Every screen should communicate:

* Safety
* Trust
* Warmth
* Authenticity
* Inclusiveness

Before users feel excitement, they should feel welcomed.

---

# Brand Personality

## Core Attributes

* Safe
* Warm
* Elegant
* Premium
* Modern
* Inclusive

---

## Emotional Goals

Users should feel:

```text
I belong here.
```

before

```text
I want to match with someone.
```

---

# Design Principles

## Principle 1

Photo-first experience.

Profiles should prioritize human photography over text.

---

## Principle 2

Soft and welcoming.

Avoid aggressive dating app aesthetics.

---

## Principle 3

Minimal cognitive load.

Keep interfaces simple and focused.

---

## Principle 4

Accessibility first.

Readable by all users.

---

# Color System

## Primary

```css
#00C896
```

Usage:

* Primary actions
* Like actions
* Success states

---

## Primary Light

```css
#E6FAF4
```

Usage:

* Selected chips
* Soft backgrounds
* Highlight states

---

## Secondary

```css
#6D5EF4
```

Usage:

* Premium features
* Subscription screens
* Super Like actions

---

## Accent

```css
#FF7FBF
```

Usage:

* Match celebration
* Compatibility indicators
* Premium highlights

---

## Background

```css
#FAFAFA
```

---

## Surface

```css
#FFFFFF
```

---

## Text Primary

```css
#111827
```

---

## Text Secondary

```css
#6B7280
```

---

## Divider

```css
#E5E7EB
```

---

## Error

```css
#EF4444
```

---

## Warning

```css
#F59E0B
```

---

# Typography

## Font Family

Primary:

```text
SF Pro Display
```

Fallback:

```text
Inter
```

---

## Display

```css
32px
700
```

---

## Heading

```css
24px
600
```

---

## Subtitle

```css
18px
500
```

---

## Body

```css
16px
400
```

---

## Caption

```css
13px
400
```

---

# Spacing System

Use only:

```text
4
8
12
16
24
32
48
64
```

No arbitrary spacing values.

---

# Border Radius

## Input

```css
12px
```

---

## Card

```css
16px
```

---

## Modal

```css
24px
```

---

## Pill

```css
999px
```

---

# Shadows

## Standard Card

```css
0 4 20 rgba(0,0,0,0.08)
```

---

## Floating Action

```css
0 8 30 rgba(0,0,0,0.12)
```

---

# Buttons

## Primary Button

Background:

```css
linear-gradient(
#00C896,
#00D7A0
)
```

Height:

```css
56px
```

Radius:

```css
16px
```

---

## Secondary Button

Background:

```css
#F3F4F6
```

---

## Ghost Button

Transparent background.

Used for:

* Skip
* Later
* Cancel

---

# Navigation

## Bottom Navigation

Height:

```css
72px
```

Tabs:

* Explore
* Browse
* Chat
* Notifications
* Profile

---

## Active State

```css
#00C896
```

---

## Inactive State

```css
#9CA3AF
```

---

# Explore Experience

## Swipe Directions

### Pass

```text
Swipe Left
```

Color:

```css
#F59E0B
```

---

### Like

```text
Swipe Right
```

Color:

```css
#00C896
```

---

### Super Like

```text
Swipe Up
```

Color:

```css
#6D5EF4
```

---

# Map Discovery

Optional map view for nearby user discovery.

---

## Map Display

Show approximate user locations only.

Never display exact coordinates or precise positions.

---

## Map Markers

Use circular profile photo thumbnails as markers.

Radius:

```css
24px
```

Border:

```css
2px solid #00C896
```

---

## Cluster Markers

Group markers in dense areas.

Background:

```css
#00C896
```

Text:

```css
#FFFFFF
```

---

## Privacy Indicator

Always display:

```text
Locations are approximate
```

---

# Profile Cards

Most important component in the application.

---

## Layout Ratio

```text
Photo 80%
Information 20%
```

---

## Required Elements

* Primary photo
* Name
* Age
* Distance
* Verification badge
* Online status
* Interest tags
* Compatibility score

---

## Card Radius

```css
32px
```

---

## Card Shadow

```css
0 10 40 rgba(0,0,0,0.12)
```

---

# Compatibility Score

Compatibility score should appear prominently.

---

## Score Colors

### High Match

```css
80-100
#00C896
```

---

### Medium Match

```css
50-79
#F59E0B
```

---

### Low Match

```css
0-49
#9CA3AF
```

---

## Example

```text
92% Match
```

Display near profile name.

---

# Verification Badge

## Purpose

Increase trust and profile authenticity.

---

## Photo Verified

Icon:

```text
✓
```

Color:

```css
#00C896
```

---

## Government ID Verified

Icon:

```text
✓✓
```

Color:

```css
#00C896
```

Additional label:

```text
ID Verified
```

---

## Placement

Beside user name.

---

# Premium Badge

Premium users display badge.

---

## Color

```css
#6D5EF4
```

---

## Label

```text
Premium
```

---

## Placement

Profile header.

---

# Online Status

## Online

Indicator:

```css
#00C896
```

Label:

```text
Online
```

---

## Offline

Display:

```text
Last seen 2h ago
```

---

## Visibility

Respect user privacy settings.

Do not display if disabled.

---

# Interest Tags

Shape:

```css
999px
```

---

## Selected State

Background:

```css
#E6FAF4
```

Text:

```css
#00C896
```

---

# Chat Experience

Chat must feel personal.

Avoid enterprise messenger aesthetics.

---

## Outgoing Message

Background:

```css
#DDF8F0
```

---

## Incoming Message

Background:

```css
#F3F4F6
```

---

## Radius

```css
20px
```

---

## Read Receipt

Visible only to Premium users.

---

## Typing Indicator

Animated three-dot indicator.

---

# Match Celebration

Bloom-specific experience.

Never use generic dating app match screens.

---

## Headline

```text
It's a Bloom! 🌸
```

---

## Animation

Use:

* Flower petals
* Heart burst
* Soft scale animation
* Gradient background

Avoid:

* Confetti
* Flashing effects

---

# Notification UI

Notifications should feel meaningful.

Not administrative.

---

## Categories

* Match
* Like
* Message
* Verification

---

## Match Notification

Use Accent color.

```css
#FF7FBF
```

---

## Message Notification

Use Primary color.

```css
#00C896
```

---

# Premium Screens

Premium screens should feel exclusive.

---

## Gradient

```css
#6D5EF4
→
#FF7FBF
```

---

## Premium Benefits

Display visually.

Avoid large text blocks.

---

# Empty States

Every empty state should feel encouraging.

---

## Example

No matches:

```text
Your next connection is waiting 🌸
```

---

## Example

No messages:

```text
Start a conversation and let it bloom.
```

---

# Motion Design

Use:

* Spring animations
* Fade transitions
* Scale transitions

---

Avoid:

* Flashing effects
* Excessive movement
* Long animations

---

# Accessibility

## Minimum Touch Target

```css
44px
```

---

## Minimum Text Size

```css
13px
```

---

## Contrast

Must satisfy:

```text
WCAG AA
```

---

# Photography Guidelines

Use:

* Natural lighting
* Authentic portraits
* Warm color grading
* Diverse representation

---

Avoid:

* Stock-photo appearance
* Over-edited photos
* Excessive filters
* Dark club environments

---

# Final Design Test

Before approving any screen ask:

1. Does this feel safe?
2. Does this feel welcoming?
3. Does this feel premium?
4. Does this feel inclusive?
5. Does this feel like Bloom?

If any answer is "No", redesign the screen.
