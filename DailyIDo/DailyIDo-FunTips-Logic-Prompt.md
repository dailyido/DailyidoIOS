# Daily I Do - Fun Tips Logic Implementation

## Overview

Implement the tip display logic that handles both normal engagements (≤350 days) and long engagements (>350 days), incorporating fun tips with proper randomization and tracking.

---

## Database Changes

### 1. Add column to wedding_tips table (if not already added)

```sql
ALTER TABLE wedding_tips 
ADD COLUMN fun_tip BOOLEAN DEFAULT FALSE;
```

When `fun_tip = TRUE`, the app should pull a random fun tip instead of displaying this row's content.

### 2. Create fun_tips table (if not already created)

```sql
CREATE TABLE fun_tips (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  tip_text TEXT NOT NULL,
  has_illustration BOOLEAN DEFAULT FALSE,
  illustration_url TEXT,
  category TEXT NOT NULL,
  affiliate_url TEXT,
  affiliate_button_text TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 3. Create user_fun_tips_shown table (NEW)

```sql
CREATE TABLE user_fun_tips_shown (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  fun_tip_id UUID REFERENCES fun_tips(id) ON DELETE CASCADE,
  shown_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  shown_on_day INTEGER, -- days until wedding when shown
  UNIQUE(user_id, fun_tip_id)
);
```

This tracks which fun tips each user has already seen to prevent repeats.

---

## Tip Display Logic

### Main Function: getTipForDay

```swift
func getTipForDay(user: User, daysUntilWedding: Int) -> Tip {
    
    // Get the last shown tip's category (for back-to-back prevention)
    let lastCategory = getLastShownFunTipCategory(user: user)
    
    // SCENARIO 1: Long engagement (>350 days out)
    if daysUntilWedding > 350 {
        return getTipForLongEngagement(
            user: user,
            daysUntilWedding: daysUntilWedding,
            lastCategory: lastCategory
        )
    }
    
    // SCENARIO 2: Normal engagement (≤350 days out)
    return getTipForNormalEngagement(
        user: user,
        daysUntilWedding: daysUntilWedding,
        lastCategory: lastCategory
    )
}
```

---

### Scenario 1: Long Engagement (>350 days)

Users with >350 days until their wedding need to see the first 50 critical tips spread out with fun tips filling the gaps.

```swift
func getTipForLongEngagement(user: User, daysUntilWedding: Int, lastCategory: String?) -> Tip {
    
    // Calculate total days in "long engagement" phase
    // Example: 600 days wedding = 250 days in this phase (600 → 351)
    let totalLongEngagementDays = user.initialDaysUntilWedding - 350
    let currentDayInPhase = user.initialDaysUntilWedding - daysUntilWedding
    // currentDayInPhase: 0 = first day, increases as wedding approaches
    
    // We need to spread 50 critical tips across totalLongEngagementDays
    // Calculate which critical tips should have been shown by now
    let tipsPerDay = 50.0 / Double(totalLongEngagementDays)
    let criticalTipIndex = Int(Double(currentDayInPhase) * tipsPerDay)
    
    // Check if today is a "critical tip day"
    // A day is critical if we've crossed into a new tip index
    let previousDayIndex = currentDayInPhase > 0 ? Int(Double(currentDayInPhase - 1) * tipsPerDay) : -1
    let isCriticalTipDay = criticalTipIndex > previousDayIndex && criticalTipIndex < 50
    
    if isCriticalTipDay {
        // Show the next critical tip (first 50 from master list)
        let criticalTips = fetchFirst50CriticalTips() // ORDER BY priority, id LIMIT 50
        if criticalTipIndex < criticalTips.count {
            return criticalTips[criticalTipIndex]
        }
    }
    
    // Otherwise, show a fun tip
    return getRandomFunTip(user: user, excludeCategory: lastCategory)
}
```

**Key points:**
- First 50 tips from wedding_tips are "critical early tips"
- These get evenly distributed across the long engagement phase
- All other days show fun tips
- Store `initialDaysUntilWedding` on user record at signup to calculate distribution

### Add to users table:

```sql
ALTER TABLE users 
ADD COLUMN initial_days_until_wedding INTEGER;
```

Set this when user completes onboarding: `initialDaysUntilWedding = daysFromTodayToWeddingDate`

---

### Scenario 2: Normal Engagement (≤350 days)

```swift
func getTipForNormalEngagement(user: User, daysUntilWedding: Int, lastCategory: String?) -> Tip {
    
    // Get the master tip for this day
    let masterTip = getMasterTipForDay(daysUntilWedding: daysUntilWedding, user: user)
    
    // If this tip is marked as fun_tip, pull a random fun tip instead
    if masterTip.funTip == true {
        return getRandomFunTip(user: user, excludeCategory: lastCategory)
    }
    
    // Otherwise return the master tip
    return masterTip
}

func getMasterTipForDay(daysUntilWedding: Int, user: User) -> WeddingTip {
    // Existing logic: check specific_day first, then month_category pool
    // Apply tented wedding filter
    // ... (existing implementation)
}
```

---

### Fun Tip Selection (Shared by both scenarios)

```swift
func getRandomFunTip(user: User, excludeCategory: String?) -> FunTip {
    
    // Get IDs of fun tips this user has already seen
    let seenTipIds = fetchSeenFunTipIds(userId: user.id)
    
    // Build query for available fun tips
    var query = supabase
        .from("fun_tips")
        .select()
        .eq("is_active", true)
    
    // Exclude already seen tips
    if !seenTipIds.isEmpty {
        query = query.not("id", in: seenTipIds)
    }
    
    // Exclude last category to prevent back-to-back
    if let lastCat = excludeCategory {
        query = query.neq("category", lastCat)
    }
    
    // Fetch available tips
    let availableTips = query.execute()
    
    // If no tips available (all seen or category restriction too tight)
    if availableTips.isEmpty {
        // Fallback: allow same category, just don't repeat exact tip
        let fallbackTips = supabase
            .from("fun_tips")
            .select()
            .eq("is_active", true)
            .not("id", in: seenTipIds)
            .execute()
        
        if fallbackTips.isEmpty {
            // User has seen ALL fun tips - reset their history
            resetFunTipHistory(userId: user.id)
            return getRandomFunTip(user: user, excludeCategory: nil)
        }
        
        return fallbackTips.randomElement()!
    }
    
    // Pick a random tip from available pool
    let selectedTip = availableTips.randomElement()!
    
    // Record that this tip was shown
    recordFunTipShown(userId: user.id, funTipId: selectedTip.id, daysOut: currentDaysUntilWedding)
    
    return selectedTip
}

func getLastShownFunTipCategory(user: User) -> String? {
    // Get the most recently shown fun tip for this user
    let result = supabase
        .from("user_fun_tips_shown")
        .select("fun_tips(category)")
        .eq("user_id", user.id)
        .order("shown_at", ascending: false)
        .limit(1)
        .execute()
    
    return result.first?.funTips?.category
}

func recordFunTipShown(userId: UUID, funTipId: UUID, daysOut: Int) {
    supabase
        .from("user_fun_tips_shown")
        .insert([
            "user_id": userId,
            "fun_tip_id": funTipId,
            "shown_on_day": daysOut
        ])
        .execute()
}

func resetFunTipHistory(userId: UUID) {
    supabase
        .from("user_fun_tips_shown")
        .delete()
        .eq("user_id", userId)
        .execute()
}
```

---

## Edge Cases to Handle

### 1. User seen all fun tips
- Reset their `user_fun_tips_shown` history
- Start fresh with the fun tips pool

### 2. Category restriction leaves no options
- If excluding the last category leaves zero available tips, ignore the category restriction for that day
- Still enforce no exact repeats

### 3. Wedding date changes
- If user changes wedding date, recalculate `initial_days_until_wedding` only if the new date is further out than current
- Don't reset their tip history

### 4. User at exactly 350 days
- Day 350 = first day of normal engagement track
- Should show tip from master list for day 350

### 5. First day of app use (no last category)
- `lastCategory` will be nil
- Allow any category for the first fun tip

---

## Categories in fun_tips table

Ensure fun tips are tagged with these categories:
- `trivia`
- `date_night`
- `relationship`
- `conversation`
- `self_care`
- `activity`
- `inspiration`

This variety ensures back-to-back prevention doesn't overly restrict options.

---

## Testing Checklist

- [ ] User with 600 days out sees critical tips spread out with fun tips between
- [ ] User with 300 days out follows master tip list normally
- [ ] Fun tips marked in master list correctly trigger random fun tip
- [ ] Same fun tip never shown twice to same user
- [ ] Same category never shown back-to-back
- [ ] When all fun tips exhausted, history resets and continues
- [ ] Category restriction fallback works when options limited
- [ ] initialDaysUntilWedding saved correctly at onboarding
- [ ] Day 350 shows correct master tip (transition day)

---

## Summary

| Days Out | Behavior |
|----------|----------|
| >350 | Spread 50 critical tips + fun tips fill gaps |
| ≤350 | Follow master list; fun_tip=TRUE triggers random fun tip |

| Fun Tip Rule | Implementation |
|--------------|----------------|
| No repeats | Track in user_fun_tips_shown table |
| No back-to-back category | Check last shown category, exclude from query |
| Pool exhausted | Reset user's history, start fresh |
