# Daily I Do - Custom Analytics System

## Overview

Build a custom analytics system for the Daily I Do wedding countdown iOS app. The system consists of three parts:

1. **Supabase Tables** — Store raw events and aggregated data
2. **iOS Analytics Service** — Log events from the app
3. **Admin Dashboard** — Display metrics, funnel visualization, AI chat, and auto-summaries

The dashboard will live at `thedailyido.com/admin` and be password protected.

---

## Part 1: Database Schema (Supabase)

Run these SQL migrations in Supabase:

```sql
-- ============================================
-- ANALYTICS EVENTS TABLE (Raw Event Log)
-- ============================================

CREATE TABLE analytics_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  event_name TEXT NOT NULL,
  event_data JSONB DEFAULT '{}',
  screen_name TEXT,
  session_id UUID,
  device_type TEXT,
  os_version TEXT,
  app_version TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for fast queries
CREATE INDEX idx_events_name ON analytics_events(event_name);
CREATE INDEX idx_events_created ON analytics_events(created_at);
CREATE INDEX idx_events_user ON analytics_events(user_id);
CREATE INDEX idx_events_session ON analytics_events(session_id);

-- ============================================
-- DAILY AGGREGATES TABLE (For Fast Queries)
-- ============================================

CREATE TABLE analytics_daily (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE NOT NULL UNIQUE,
  total_users INTEGER DEFAULT 0,
  new_users INTEGER DEFAULT 0,
  active_users INTEGER DEFAULT 0,
  tips_viewed INTEGER DEFAULT 0,
  checklist_completions INTEGER DEFAULT 0,
  onboarding_starts INTEGER DEFAULT 0,
  onboarding_completions INTEGER DEFAULT 0,
  avg_streak FLOAT DEFAULT 0,
  retention_day_1 INTEGER DEFAULT 0,
  retention_day_7 INTEGER DEFAULT 0,
  retention_day_30 INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- AI SUMMARIES TABLE
-- ============================================

CREATE TABLE analytics_summaries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  period_type TEXT NOT NULL, -- 'daily', 'weekly', 'monthly'
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  summary_text TEXT NOT NULL,
  key_metrics JSONB,
  anomalies JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ONBOARDING FUNNEL VIEW (Materialized for speed)
-- ============================================

CREATE MATERIALIZED VIEW onboarding_funnel AS
SELECT 
  screen_name,
  COUNT(DISTINCT user_id) as users,
  COUNT(DISTINCT session_id) as sessions
FROM analytics_events
WHERE event_name = 'onboarding_screen_viewed'
  AND created_at > NOW() - INTERVAL '30 days'
GROUP BY screen_name;

-- Refresh this view periodically via cron or Edge Function
-- REFRESH MATERIALIZED VIEW onboarding_funnel;

-- ============================================
-- ADMIN USERS TABLE (For Dashboard Auth)
-- ============================================

CREATE TABLE admin_users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

-- Analytics events: App can insert, dashboard can read
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "App can insert events" ON analytics_events
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Dashboard can read events" ON analytics_events
  FOR SELECT USING (true);

-- Daily aggregates: Only dashboard reads/writes
ALTER TABLE analytics_daily ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Dashboard can manage daily" ON analytics_daily
  FOR ALL USING (true);

-- Summaries: Only dashboard reads/writes
ALTER TABLE analytics_summaries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Dashboard can manage summaries" ON analytics_summaries
  FOR ALL USING (true);
```

---

## Part 2: iOS Analytics Service

Create a new file `Services/AnalyticsService.swift`:

```swift
import Foundation
import UIKit

// MARK: - Analytics Event Names

enum AnalyticsEvent: String {
    // Onboarding
    case onboardingStarted = "onboarding_started"
    case onboardingScreenViewed = "onboarding_screen_viewed"
    case onboardingScreenCompleted = "onboarding_screen_completed"
    case onboardingCompleted = "onboarding_completed"
    case onboardingAbandoned = "onboarding_abandoned"
    
    // App Lifecycle
    case appOpened = "app_opened"
    case appClosed = "app_closed"
    case appBackgrounded = "app_backgrounded"
    case appForegrounded = "app_foregrounded"
    
    // Engagement
    case tipViewed = "tip_viewed"
    case checklistItemCompleted = "checklist_item_completed"
    case checklistItemUncompleted = "checklist_item_uncompleted"
    case calendarSwiped = "calendar_swiped"
    case checklistTabOpened = "checklist_tab_opened"
    case calendarTabOpened = "calendar_tab_opened"
    case settingsOpened = "settings_opened"
    case shareTapped = "share_tapped"
    
    // Streaks
    case streakUpdated = "streak_updated"
    case streakMilestoneHit = "streak_milestone_hit"
    case streakBroken = "streak_broken"
    
    // Retention
    case day1Return = "day_1_return"
    case day7Return = "day_7_return"
    case day30Return = "day_30_return"
    
    // Errors
    case errorOccurred = "error_occurred"
}

// MARK: - Onboarding Screen Names

enum OnboardingScreen: String {
    case welcome = "welcome"
    case yourName = "your_name"
    case partnerName = "partner_name"
    case weddingDate = "wedding_date"
    case weddingLocation = "wedding_location"
    case tentedQuestion = "tented_question"
    case planningPhilosophy = "planning_philosophy"
    case notificationsPermission = "notifications_permission"
    case preparednessCheck = "preparedness_check"
    case ratingRequest = "rating_request"
    case loading = "loading"
    case planReveal = "plan_reveal"
}

// MARK: - Analytics Service

class AnalyticsService {
    static let shared = AnalyticsService()
    
    private var sessionId: UUID = UUID()
    private var sessionStart: Date = Date()
    private var isEnabled: Bool = true
    
    private init() {}
    
    // MARK: - Session Management
    
    func startSession() {
        sessionId = UUID()
        sessionStart = Date()
        log(.appOpened)
        checkRetentionMilestones()
    }
    
    func endSession() {
        let duration = Date().timeIntervalSince(sessionStart)
        log(.appClosed, data: ["session_duration_seconds": Int(duration)])
    }
    
    func appBackgrounded() {
        let duration = Date().timeIntervalSince(sessionStart)
        log(.appBackgrounded, data: ["session_duration_seconds": Int(duration)])
    }
    
    func appForegrounded() {
        log(.appForegrounded)
    }
    
    // MARK: - Core Logging
    
    func log(_ event: AnalyticsEvent, data: [String: Any] = [:], screenName: String? = nil) {
        guard isEnabled else { return }
        
        Task {
            do {
                let eventRecord: [String: Any] = [
                    "user_id": AuthService.shared.currentUserId?.uuidString as Any,
                    "event_name": event.rawValue,
                    "event_data": data,
                    "screen_name": screenName as Any,
                    "session_id": sessionId.uuidString,
                    "device_type": UIDevice.current.model,
                    "os_version": UIDevice.current.systemVersion,
                    "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
                ]
                
                try await SupabaseService.shared.client
                    .from("analytics_events")
                    .insert(eventRecord)
                    .execute()
            } catch {
                print("Analytics error: \(error)")
            }
        }
    }
    
    // MARK: - Onboarding Tracking
    
    func logOnboardingStarted() {
        log(.onboardingStarted)
    }
    
    func logOnboardingScreen(_ screen: OnboardingScreen) {
        log(.onboardingScreenViewed, screenName: screen.rawValue)
    }
    
    func logOnboardingScreenCompleted(_ screen: OnboardingScreen) {
        log(.onboardingScreenCompleted, screenName: screen.rawValue)
    }
    
    func logOnboardingCompleted() {
        log(.onboardingCompleted)
    }
    
    func logOnboardingAbandoned(atScreen screen: OnboardingScreen) {
        log(.onboardingAbandoned, data: ["last_screen": screen.rawValue])
    }
    
    // MARK: - Engagement Tracking
    
    func logTipViewed(tipId: UUID, dayNumber: Int, isFunTip: Bool) {
        log(.tipViewed, data: [
            "tip_id": tipId.uuidString,
            "day_number": dayNumber,
            "is_fun_tip": isFunTip
        ])
    }
    
    func logChecklistCompleted(tipId: UUID) {
        log(.checklistItemCompleted, data: ["tip_id": tipId.uuidString])
    }
    
    func logChecklistUncompleted(tipId: UUID) {
        log(.checklistItemUncompleted, data: ["tip_id": tipId.uuidString])
    }
    
    func logCalendarSwiped(direction: String, fromDay: Int, toDay: Int) {
        log(.calendarSwiped, data: [
            "direction": direction,
            "from_day": fromDay,
            "to_day": toDay
        ])
    }
    
    func logTabOpened(_ tab: String) {
        switch tab {
        case "calendar":
            log(.calendarTabOpened)
        case "checklist":
            log(.checklistTabOpened)
        default:
            break
        }
    }
    
    func logSettingsOpened() {
        log(.settingsOpened)
    }
    
    func logShareTapped(tipId: UUID, platform: String) {
        log(.shareTapped, data: [
            "tip_id": tipId.uuidString,
            "platform": platform
        ])
    }
    
    // MARK: - Streak Tracking
    
    func logStreakUpdated(current: Int, longest: Int) {
        log(.streakUpdated, data: [
            "current_streak": current,
            "longest_streak": longest
        ])
    }
    
    func logStreakMilestone(_ days: Int) {
        log(.streakMilestoneHit, data: ["milestone_days": days])
    }
    
    func logStreakBroken(previousStreak: Int) {
        log(.streakBroken, data: ["previous_streak": previousStreak])
    }
    
    // MARK: - Retention Tracking
    
    private func checkRetentionMilestones() {
        guard let user = AuthService.shared.currentUser,
              let createdAt = user.createdAt else { return }
        
        let daysSinceSignup = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        
        // Check if we should log retention events
        let key = "retention_logged_day_\(daysSinceSignup)"
        if !UserDefaults.standard.bool(forKey: key) {
            switch daysSinceSignup {
            case 1:
                log(.day1Return)
                UserDefaults.standard.set(true, forKey: key)
            case 7:
                log(.day7Return)
                UserDefaults.standard.set(true, forKey: key)
            case 30:
                log(.day30Return)
                UserDefaults.standard.set(true, forKey: key)
            default:
                break
            }
        }
    }
    
    // MARK: - Error Tracking
    
    func logError(_ error: Error, context: String) {
        log(.errorOccurred, data: [
            "error_message": error.localizedDescription,
            "context": context
        ])
    }
    
    // MARK: - Settings
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
}
```

### Integration Points

Add analytics calls throughout the app:

**AppDelegate.swift or App.swift:**
```swift
// App launch
AnalyticsService.shared.startSession()

// App lifecycle
NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
    AnalyticsService.shared.appBackgrounded()
}

NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
    AnalyticsService.shared.appForegrounded()
}

NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _ in
    AnalyticsService.shared.endSession()
}
```

**OnboardingContainerView.swift:**
```swift
.onAppear {
    AnalyticsService.shared.logOnboardingStarted()
}

// Each screen's .onAppear:
.onAppear {
    AnalyticsService.shared.logOnboardingScreen(.yourName)
}

// On continue button tap:
AnalyticsService.shared.logOnboardingScreenCompleted(.yourName)

// On final completion:
AnalyticsService.shared.logOnboardingCompleted()
```

**CalendarView.swift:**
```swift
// When tip is displayed
AnalyticsService.shared.logTipViewed(tipId: tip.id, dayNumber: daysOut, isFunTip: tip.isFunTip)

// On swipe
AnalyticsService.shared.logCalendarSwiped(direction: "left", fromDay: 180, toDay: 179)
```

**ChecklistView.swift:**
```swift
// Tab opened
.onAppear {
    AnalyticsService.shared.logTabOpened("checklist")
}

// Item completed
AnalyticsService.shared.logChecklistCompleted(tipId: item.tipId)
```

**StreakService.swift:**
```swift
// After streak update
AnalyticsService.shared.logStreakUpdated(current: newStreak, longest: longestStreak)

// On milestone
AnalyticsService.shared.logStreakMilestone(7)

// On broken streak
AnalyticsService.shared.logStreakBroken(previousStreak: oldStreak)
```

---

## Part 3: Admin Dashboard

Build a Next.js dashboard at `thedailyido.com/admin`

### Tech Stack

- **Framework:** Next.js 14 (App Router)
- **Styling:** Tailwind CSS
- **Charts:** Recharts
- **AI Chat:** Claude API (Anthropic)
- **Auth:** Simple password protection (or Supabase Auth)
- **Database:** Supabase (same project as app)

### File Structure

```
app/
├── admin/
│   ├── layout.tsx          # Admin layout with auth check
│   ├── page.tsx            # Main dashboard
│   ├── login/
│   │   └── page.tsx        # Login page
│   ├── components/
│   │   ├── MetricCard.tsx
│   │   ├── OnboardingFunnel.tsx
│   │   ├── EngagementChart.tsx
│   │   ├── RetentionChart.tsx
│   │   ├── StreakDistribution.tsx
│   │   ├── AIChat.tsx
│   │   └── WeeklySummary.tsx
│   └── api/
│       ├── metrics/route.ts
│       ├── funnel/route.ts
│       ├── chat/route.ts
│       └── summary/route.ts
```

### Main Dashboard Page (page.tsx)

```tsx
// app/admin/page.tsx

import { Suspense } from 'react';
import MetricCard from './components/MetricCard';
import OnboardingFunnel from './components/OnboardingFunnel';
import EngagementChart from './components/EngagementChart';
import RetentionChart from './components/RetentionChart';
import StreakDistribution from './components/StreakDistribution';
import AIChat from './components/AIChat';
import WeeklySummary from './components/WeeklySummary';

export default function AdminDashboard() {
  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Daily I Do Analytics</h1>
      
      {/* Top Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4 mb-8">
        <Suspense fallback={<MetricCardSkeleton />}>
          <MetricCard title="Users Today" metric="active_users" />
        </Suspense>
        <Suspense fallback={<MetricCardSkeleton />}>
          <MetricCard title="New Signups" metric="new_users" />
        </Suspense>
        <Suspense fallback={<MetricCardSkeleton />}>
          <MetricCard title="Onboarding %" metric="onboarding_rate" />
        </Suspense>
        <Suspense fallback={<MetricCardSkeleton />}>
          <MetricCard title="Tips Viewed" metric="tips_viewed" />
        </Suspense>
        <Suspense fallback={<MetricCardSkeleton />}>
          <MetricCard title="Avg Streak" metric="avg_streak" />
        </Suspense>
      </div>
      
      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        {/* Left Column - Charts */}
        <div className="lg:col-span-2 space-y-8">
          <div className="bg-white rounded-xl shadow p-6">
            <h2 className="text-xl font-semibold mb-4">Onboarding Funnel (Last 30 Days)</h2>
            <OnboardingFunnel />
          </div>
          
          <div className="bg-white rounded-xl shadow p-6">
            <h2 className="text-xl font-semibold mb-4">Daily Engagement</h2>
            <EngagementChart />
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div className="bg-white rounded-xl shadow p-6">
              <h2 className="text-xl font-semibold mb-4">Retention</h2>
              <RetentionChart />
            </div>
            <div className="bg-white rounded-xl shadow p-6">
              <h2 className="text-xl font-semibold mb-4">Streak Distribution</h2>
              <StreakDistribution />
            </div>
          </div>
        </div>
        
        {/* Right Column - AI & Summary */}
        <div className="space-y-8">
          <div className="bg-white rounded-xl shadow p-6">
            <h2 className="text-xl font-semibold mb-4">Ask About Your Data</h2>
            <AIChat />
          </div>
          
          <div className="bg-white rounded-xl shadow p-6">
            <h2 className="text-xl font-semibold mb-4">Weekly Summary</h2>
            <WeeklySummary />
          </div>
        </div>
      </div>
    </div>
  );
}
```

### Onboarding Funnel Component

```tsx
// app/admin/components/OnboardingFunnel.tsx

'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

const SCREEN_ORDER = [
  { key: 'welcome', label: 'Welcome' },
  { key: 'your_name', label: 'Your Name' },
  { key: 'partner_name', label: 'Partner Name' },
  { key: 'wedding_date', label: 'Wedding Date' },
  { key: 'wedding_location', label: 'Location' },
  { key: 'tented_question', label: 'Tented Question' },
  { key: 'planning_philosophy', label: 'Philosophy' },
  { key: 'notifications_permission', label: 'Notifications' },
  { key: 'preparedness_check', label: 'Preparedness' },
  { key: 'rating_request', label: 'Rating Request' },
  { key: 'loading', label: 'Loading' },
  { key: 'plan_reveal', label: 'Plan Reveal' },
];

export default function OnboardingFunnel() {
  const [data, setData] = useState<Record<string, number>>({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchFunnel() {
      const { data: events, error } = await supabase
        .from('analytics_events')
        .select('screen_name, user_id')
        .eq('event_name', 'onboarding_screen_viewed')
        .gte('created_at', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString());

      if (error) {
        console.error(error);
        return;
      }

      // Count unique users per screen
      const counts: Record<string, Set<string>> = {};
      events?.forEach(event => {
        if (!counts[event.screen_name]) {
          counts[event.screen_name] = new Set();
        }
        counts[event.screen_name].add(event.user_id);
      });

      const result: Record<string, number> = {};
      Object.entries(counts).forEach(([screen, users]) => {
        result[screen] = users.size;
      });

      setData(result);
      setLoading(false);
    }

    fetchFunnel();
  }, []);

  if (loading) return <div>Loading funnel...</div>;

  const maxUsers = Math.max(...Object.values(data), 1);

  return (
    <div className="space-y-2">
      {SCREEN_ORDER.map((screen, index) => {
        const count = data[screen.key] || 0;
        const percentage = maxUsers > 0 ? (count / data['welcome'] * 100) : 0;
        const dropoff = index > 0 
          ? ((data[SCREEN_ORDER[index - 1].key] || 0) - count) 
          : 0;
        
        return (
          <div key={screen.key} className="flex items-center gap-4">
            <div className="w-32 text-sm text-gray-600">{screen.label}</div>
            <div className="flex-1 h-8 bg-gray-100 rounded-full overflow-hidden">
              <div 
                className="h-full bg-blue-500 rounded-full transition-all"
                style={{ width: `${percentage}%` }}
              />
            </div>
            <div className="w-20 text-sm text-right">
              {percentage.toFixed(0)}% ({count})
            </div>
            {dropoff > 0 && (
              <div className="w-16 text-sm text-red-500 text-right">
                -{dropoff}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}
```

### AI Chat Component

```tsx
// app/admin/components/AIChat.tsx

'use client';

import { useState } from 'react';

interface Message {
  role: 'user' | 'assistant';
  content: string;
}

export default function AIChat() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!input.trim() || loading) return;

    const userMessage = input.trim();
    setInput('');
    setMessages(prev => [...prev, { role: 'user', content: userMessage }]);
    setLoading(true);

    try {
      const response = await fetch('/admin/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: userMessage }),
      });

      const data = await response.json();
      setMessages(prev => [...prev, { role: 'assistant', content: data.response }]);
    } catch (error) {
      setMessages(prev => [...prev, { 
        role: 'assistant', 
        content: 'Sorry, I encountered an error. Please try again.' 
      }]);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex flex-col h-96">
      {/* Messages */}
      <div className="flex-1 overflow-y-auto space-y-4 mb-4">
        {messages.length === 0 && (
          <div className="text-gray-400 text-sm">
            Ask questions about your data:
            <ul className="mt-2 space-y-1">
              <li>• "What's the onboarding completion rate?"</li>
              <li>• "Where are users dropping off?"</li>
              <li>• "Compare this week to last week"</li>
              <li>• "Any anomalies today?"</li>
            </ul>
          </div>
        )}
        {messages.map((msg, i) => (
          <div 
            key={i} 
            className={`p-3 rounded-lg ${
              msg.role === 'user' 
                ? 'bg-blue-100 ml-8' 
                : 'bg-gray-100 mr-8'
            }`}
          >
            {msg.content}
          </div>
        ))}
        {loading && (
          <div className="bg-gray-100 mr-8 p-3 rounded-lg animate-pulse">
            Analyzing...
          </div>
        )}
      </div>

      {/* Input */}
      <form onSubmit={handleSubmit} className="flex gap-2">
        <input
          type="text"
          value={input}
          onChange={e => setInput(e.target.value)}
          placeholder="Ask about your analytics..."
          className="flex-1 px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <button
          type="submit"
          disabled={loading}
          className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50"
        >
          Send
        </button>
      </form>
    </div>
  );
}
```

### AI Chat API Route

```typescript
// app/admin/api/chat/route.ts

import { NextRequest, NextResponse } from 'next/server';
import Anthropic from '@anthropic-ai/sdk';
import { createClient } from '@supabase/supabase-js';

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY!,
});

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!
);

export async function POST(req: NextRequest) {
  const { message } = await req.json();

  // Fetch relevant analytics data
  const [
    { data: recentEvents },
    { data: dailyStats },
    { data: funnelData },
    { data: streakData }
  ] = await Promise.all([
    supabase
      .from('analytics_events')
      .select('*')
      .gte('created_at', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString())
      .order('created_at', { ascending: false })
      .limit(1000),
    supabase
      .from('analytics_daily')
      .select('*')
      .order('date', { ascending: false })
      .limit(30),
    supabase
      .from('analytics_events')
      .select('screen_name, user_id')
      .eq('event_name', 'onboarding_screen_viewed')
      .gte('created_at', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString()),
    supabase
      .from('users')
      .select('current_streak, longest_streak, created_at')
  ]);

  // Build context for Claude
  const context = `
You are an analytics assistant for Daily I Do, a wedding countdown app. 
Answer questions about the app's analytics data.

RECENT DATA (Last 7 days):
- Total events: ${recentEvents?.length || 0}
- Event types: ${[...new Set(recentEvents?.map(e => e.event_name))].join(', ')}

DAILY STATS (Last 30 days):
${JSON.stringify(dailyStats?.slice(0, 7), null, 2)}

ONBOARDING FUNNEL (Last 30 days):
${JSON.stringify(
  Object.entries(
    funnelData?.reduce((acc: Record<string, number>, e: any) => {
      acc[e.screen_name] = (acc[e.screen_name] || 0) + 1;
      return acc;
    }, {}) || {}
  ),
  null,
  2
)}

USER STREAKS:
- Total users: ${streakData?.length || 0}
- Users with 7+ day streak: ${streakData?.filter((u: any) => u.current_streak >= 7).length || 0}
- Average streak: ${streakData?.length ? (streakData.reduce((sum: number, u: any) => sum + (u.current_streak || 0), 0) / streakData.length).toFixed(1) : 0}

Be concise and data-driven. If you notice anomalies or interesting patterns, mention them.
Format numbers nicely (e.g., "1,234" not "1234").
`;

  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 1024,
    system: context,
    messages: [{ role: 'user', content: message }],
  });

  const textContent = response.content.find(c => c.type === 'text');
  
  return NextResponse.json({ 
    response: textContent?.text || 'Unable to generate response' 
  });
}
```

### Weekly Summary Generator (Edge Function or Cron)

```typescript
// supabase/functions/generate-weekly-summary/index.ts
// Or as a Next.js API route that runs on cron

import Anthropic from '@anthropic-ai/sdk';
import { createClient } from '@supabase/supabase-js';

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY!,
});

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!
);

export async function generateWeeklySummary() {
  const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
  const twoWeeksAgo = new Date(Date.now() - 14 * 24 * 60 * 60 * 1000);

  // Fetch this week's data
  const [thisWeek, lastWeek] = await Promise.all([
    supabase
      .from('analytics_daily')
      .select('*')
      .gte('date', weekAgo.toISOString().split('T')[0]),
    supabase
      .from('analytics_daily')
      .select('*')
      .gte('date', twoWeeksAgo.toISOString().split('T')[0])
      .lt('date', weekAgo.toISOString().split('T')[0])
  ]);

  // Get onboarding funnel for anomaly detection
  const { data: funnelEvents } = await supabase
    .from('analytics_events')
    .select('screen_name, created_at')
    .eq('event_name', 'onboarding_screen_viewed')
    .gte('created_at', weekAgo.toISOString());

  const prompt = `
Generate a weekly analytics summary for Daily I Do app.

THIS WEEK'S DATA:
${JSON.stringify(thisWeek.data, null, 2)}

LAST WEEK'S DATA (for comparison):
${JSON.stringify(lastWeek.data, null, 2)}

ONBOARDING EVENTS THIS WEEK:
${JSON.stringify(funnelEvents?.slice(0, 100), null, 2)}

Generate a summary with these sections:
1. HIGHLIGHTS (3-4 bullet points with key wins or concerns)
2. ENGAGEMENT (active users, tips viewed, checklist completions)
3. ONBOARDING (completion rate, biggest dropoff point)
4. STREAKS (notable streak achievements)
5. ANOMALIES (anything unusual - good or bad)

Use emojis sparingly. Compare to last week where relevant (↑ or ↓ with percentages).
Be concise - this should be scannable in 30 seconds.
`;

  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 1024,
    messages: [{ role: 'user', content: prompt }],
  });

  const textContent = response.content.find(c => c.type === 'text');
  const summaryText = textContent?.text || '';

  // Store the summary
  await supabase.from('analytics_summaries').insert({
    period_type: 'weekly',
    period_start: weekAgo.toISOString().split('T')[0],
    period_end: new Date().toISOString().split('T')[0],
    summary_text: summaryText,
    key_metrics: {
      new_users: thisWeek.data?.reduce((sum, d) => sum + d.new_users, 0),
      active_users_avg: thisWeek.data?.reduce((sum, d) => sum + d.active_users, 0) / 7,
    }
  });

  return summaryText;
}
```

### Password Protection Middleware

```typescript
// middleware.ts

import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  if (request.nextUrl.pathname.startsWith('/admin')) {
    // Skip login page
    if (request.nextUrl.pathname === '/admin/login') {
      return NextResponse.next();
    }

    // Check for auth cookie
    const authCookie = request.cookies.get('admin_auth');
    
    if (!authCookie || authCookie.value !== process.env.ADMIN_AUTH_TOKEN) {
      return NextResponse.redirect(new URL('/admin/login', request.url));
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: '/admin/:path*',
};
```

### Login Page

```tsx
// app/admin/login/page.tsx

'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function AdminLogin() {
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const router = useRouter();

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    
    const res = await fetch('/admin/api/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password }),
    });

    if (res.ok) {
      router.push('/admin');
    } else {
      setError('Invalid password');
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <form onSubmit={handleSubmit} className="bg-white p-8 rounded-xl shadow-lg w-96">
        <h1 className="text-2xl font-bold mb-6">Daily I Do Admin</h1>
        
        {error && (
          <div className="bg-red-100 text-red-600 p-3 rounded mb-4">{error}</div>
        )}
        
        <input
          type="password"
          value={password}
          onChange={e => setPassword(e.target.value)}
          placeholder="Enter password"
          className="w-full px-4 py-3 border rounded-lg mb-4 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        
        <button
          type="submit"
          className="w-full py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
        >
          Login
        </button>
      </form>
    </div>
  );
}
```

### Login API Route

```typescript
// app/admin/api/login/route.ts

import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  const { password } = await req.json();

  if (password === process.env.ADMIN_PASSWORD) {
    const response = NextResponse.json({ success: true });
    
    response.cookies.set('admin_auth', process.env.ADMIN_AUTH_TOKEN!, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 60 * 60 * 24 * 7, // 1 week
    });

    return response;
  }

  return NextResponse.json({ error: 'Invalid password' }, { status: 401 });
}
```

---

## Environment Variables

### iOS App (already have these)
```
SUPABASE_URL=xxx
SUPABASE_ANON_KEY=xxx
```

### Dashboard (.env.local)
```
NEXT_PUBLIC_SUPABASE_URL=xxx
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx
SUPABASE_SERVICE_KEY=xxx
ANTHROPIC_API_KEY=xxx
ADMIN_PASSWORD=xxx
ADMIN_AUTH_TOKEN=xxx (generate a random string)
```

---

## Summary

| Component | What It Does |
|-----------|--------------|
| **analytics_events table** | Stores every event from the app |
| **AnalyticsService.swift** | Logs events from iOS to Supabase |
| **Dashboard** | Displays metrics, funnel, charts |
| **AI Chat** | Answer questions using Claude + your data |
| **Weekly Summary** | Auto-generated insights via Claude |
| **Anomaly Detection** | Flags unusual patterns |

---

## Testing Checklist

- [ ] Events log to Supabase from iOS app
- [ ] Onboarding screens each fire screen_viewed event
- [ ] Dashboard loads and displays metrics
- [ ] Funnel visualization shows accurate dropoff
- [ ] AI chat responds with data-informed answers
- [ ] Weekly summary generates correctly
- [ ] Password protection works
- [ ] Retention events fire on day 1, 7, 30
