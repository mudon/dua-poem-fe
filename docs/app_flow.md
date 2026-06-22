# Teduh App — End-to-End Flow Documentation

## 1. Architecture Overview

### Tech Stack
- **Frontend:** Flutter, flutter_bloc (state management), go_router (routing), get_it (DI)
- **Backend:** .NET Web API, SignalR (real-time), JWT auth, cursor-based pagination
- **Real-time:** SignalR hubs for likes, bookmarks, views, reports, content updates, profile, leaderboard, notifications, badges

### DI Registration (`dependency_injection.dart`)
| Scope | Components |
|---|---|
| `LazySingleton` | `SignalRService`, `DuaBloc`, `PoemBloc`, `NotificationBloc`, all Services & Repositories |
| `Factory` | `AuthBloc`, `HomeBloc`, `CategoryBloc`, `TagBloc`, `DonationBloc` |

### Route Map
```
/ (splash)
/auth
StatefulShellRoute (MainShell with BottomNav):
  ├── /home            → HomeScreen
  ├── /my-posts        → MyPostsScreen
  ├── /leaderboard     → LeaderboardScreen
  ├── /profile         → ProfileScreen
  ├── /favorites       → FavoritesScreen
  └── /admin           → AdminScreen (admin only)

/detail routes (outside shell):
  /dua/:duaId          → DuaDetailScreen
  /poem/:poemId        → PoemDetailScreen
  /user/:userId        → UserDetailScreen
  /admin/revision      → RevisionReviewScreen
```

---

## 2. Auth Flow

```
App Launch
  → Firebase init + FCM setup
  → AuthBloc.CheckAuthStatus()
  → GoRouter redirect logic:
      ├── Not authenticated & not /auth → redirect to /auth
      ├── Authenticated & /auth → redirect to /home
      ├── Authenticated & / → redirect to /home
      └── Splash/loading → null (no redirect)

Auth screen states:
  ├── Login (email/password)
  ├── Register (name, email, password)
  ├── Email verification (OTP)
  ├── Forgot password (OTP)
  └── Google OAuth

On login success:
  → JWT stored in SecureStorage
  → AuthBloc emits Authenticated(user)
  → AuthBloc dispatches ConnectToSignalR
  → GoRouter redirects to /home
```

### Auth Endpoints
| Method | Route | Description |
|---|---|---|
| POST | `/api/auth/register` | Register |
| POST | `/api/auth/verify-email` | Verify OTP |
| POST | `/api/auth/resend-otp` | Resend OTP |
| POST | `/api/auth/login` | Login |
| POST | `/api/auth/google` | Google login |
| POST | `/api/auth/refresh` | Refresh token |
| POST | `/api/auth/logout` | Logout |

---

## 3. Home Screen (`/home`)

### Widget Tree
```
HomeScreen
├── Scaffold
│   ├── FAB (+) → CreateFlowSheet (create dua/poem)
│   ├── _HeaderBar
│   │   ├── Logo + "Teduh"
│   │   ├── CoffeeButton (donate)
│   │   ├── NotificationBell
│   │   └── _SearchBar
│   ├── HomeTabBar [Latest Duas | Latest Poems]
│   └── _HomeFeed (IndexedStack)
│       ├── _DuaFeed (when "Latest Duas" tab active)
│       └── _PoemFeed (when "Latest Poems" tab active)
```

### Bloc Structure
| Bloc | Scope | Location |
|---|---|---|
| `DuaFeedBloc` | Home feed — duas | Created inside `_HomeFeed` (per HomeScreen instance) |
| `PoemFeedBloc` | Home feed — poems | Created inside `_HomeFeed` (per HomeScreen instance) |
| `DuaBloc` | Singleton — all dua actions | Provided at `MainShell` level |
| `PoemBloc` | Singleton — all poem actions | Provided at `MainShell` level |
| `HomeBloc` | Tab state + search + my posts | Created per HomeScreen and per MyPostsScreen |

### Feed Sliding Window (Caching Strategy)

**In-memory only. No disk caching.**

```
DuaFeedBloc State:
  ├── windowDuas: List<DuaModel>     ← visible items (max 60)
  ├── windowDuasStart: int           ← scroll offset tracking
  ├── totalLoadedDuas: int           ← cumulative count (grows unbounded, not capped)
  ├── olderCursorDuas: String?       ← cursor for FetchOlderDuas
  ├── latterCursorDuas: String?      ← cursor for FetchLatterDuas
  ├── hasMoreOlderDuas: bool
  └── hasMoreLatterDuas: bool
```

**Scroll behavior:**

```
User scrolls UP (newer):
  → FetchLatterDuas
  → GET /api/duas/{firstId}/latter
  → New items prepended to window
  → If window > 60, trim from bottom

User scrolls DOWN (older):
  → FetchOlderDuas
  → GET /api/duas/{lastId}/older  
  → New items appended to window
  → If window > 60, trim from top

User refreshes (pull-to-refresh):
  → ResetDuas → GET /api/duas (latest) → replace window completely
```

**UI rendering (performance):**

```dart
// Inside window → real DuaCard widget
// Outside window → const SizedBox(height: 200) → zero rendering cost
if (cacheIndex < 0 || cacheIndex >= state.windowDuas.length) {
  return const SizedBox(height: 200);
}
return DuaCard(key: ValueKey(...), dua: state.windowDuas[cacheIndex], currentUser: user);
```

### Search
```
_SearchBar.onSubmitted(query)
  → HomeBloc.SearchRequested(query)
  → Parallel: GET /api/duas/search?q= + GET /api/poems/search?q=
  → Renders in same IndexedStack (replaces feed)
  → Infinite scroll for search results
  → ClearSearch returns to feed

Search dedup:
  if (queryAtCall != state.searchQuery) return;  // stale response guard
```

### Real-time Behavior on Home Screen

| Event | Source | Behavior |
|---|---|---|
| Like count update | SignalR → DuaBloc | ✅ DuaCard/PoemCard listener updates instantly |
| Bookmark count update | SignalR → DuaBloc | ✅ Card updates instantly |
| View count update | SignalR → DuaBloc | ✅ Card updates instantly |
| Content edit | SignalR → DuaBloc | ✅ Card updates title/text instantly |
| Profile update | SignalR → DuaBloc | ✅ Card updates avatar/name instantly |
| Dua/Poem created (by others) | — | ❌ Requires pull-to-refresh |
| Dua/Poem deleted (by others) | — | ❌ Card stays until refresh |
| Report status | SignalR → DuaBloc | ✅ Card updates report badge |

### SignalR Hub Connections (established at app start)
| Hub | Purpose |
|---|---|
| `/hubs/dua-likes` | Real-time like counts |
| `/hubs/dua-favorites` | Real-time bookmark counts |
| `/hubs/dua-views` | Real-time view counts |
| `/hubs/dua-reports` | Real-time report counts |
| `/hubs/notifications` | Push notifications |
| `/hubs/leaderboard` | Leaderboard updates |
| `/hubs/badges` | Badge awards |
| `/hubs/profile` | Profile updates |

### DuaCard Interactivity
```
DuaCard
├── Tap card → context.push('/dua/:duaId', currentUser) → DuaDetailScreen
├── Tap heart → DuaBloc.ToggleLike(id, wasLiked, count)
│             → POST /api/duas/:id/like (or DELETE if unliking)
│             → SignalR broadcasts to all connected clients
├── Tap bookmark → DuaBloc.ToggleBookmark(id, wasBookmarked, count)
│                 → POST /api/duas/:id/favorite (or DELETE)
├── Tap flag → _showReportsPopup → ReportStatusSheet
│             → GET /api/reports
└── Tap avatar → context.push('/user/:userId', userName) → UserDetailScreen
```

---

## 4. My Posts Screen (`/my-posts`)

### Widget Tree
```
MyPostsScreen
├── AppBar "My Posts" + NotificationBell
├── FAB (+) → CreateFlowSheet
├── Tab [My Duas | My Poems] (toggle via HomeBloc.ToggleMyPostsTab)
└── IndexedStack
    ├── _MyDuasFeed
    └── _MyPoemsFeed
```

### Data Loading
```
MyPostsScreen.initState()
  → HomeBloc.FetchMyDuas(userId)    → GET /api/duas/user/:userId
  → HomeBloc.FetchMyPoems(userId)   → GET /api/poems/user/:userId
```

### Infinite Scroll
```
_MyDuasFeed scroll listener:
  if near bottom → HomeBloc.FetchMoreMyDuas(userId, cursor)
                   → GET /api/duas/user/:userId?cursor=...

_MyPoemsFeed scroll listener:
  if near bottom → HomeBloc.FetchMoreMyPoems(userId, cursor)
                   → GET /api/poems/user/:userId?cursor=...
```

### Real-time Behavior (My Posts)

| Event | Source | Screen Behavior |
|---|---|---|
| Dua created (own, current device) | `DuaBloc.created` → `HomeBloc.InsertDua` | ✅ Card appears at top |
| Dua created (other device) | SignalR → `DuaBloc.SignalRDuaCreated` → `HomeBloc.InsertDua` | ✅ Card appears at top |
| Dua deleted (own, current device) | `DuaBloc.deleted` → `HomeBloc.RemoveDua` | ✅ Card removed |
| Dua deleted (other device) | SignalR → `DuaBloc.SignalRDuaDeleted` → `HomeBloc.RemoveDua` | ✅ Card removed |
| Poem created/deleted | Same pattern via `PoemBloc` | ✅ |
| Like/bookmark/view counts | SignalR → `DuaBloc`/`PoemBloc` | ✅ Card handles it via its own listener |
| Content edits | SignalR → `DuaBloc`/`PoemBloc` | ✅ Card updates title/content |
| Profile updates | SignalR → `DuaBloc`/`PoemBloc` | ✅ Card updates avatar/name |

---

## 5. Favorites Screen (`/favorites`)

### Widget Tree
```
FavoritesScreen
├── AppBar "Favorites"
├── Tab [Duas (N) | Poems (M)]
└── IndexedStack
    ├── _FavDuasList
    └── _FavPoemsList
```

### Data Loading
```
FavoritesScreen.initState()
  → _loadFavorites() — parallel:
      ├── GET /api/favorites          (favorite duas, cursor-based)
      └── GET /api/poems/favorites    (favorite poems, cursor-based)
```

### Infinite Scroll
```
_FavDuasList scroll near bottom
  → _loadMoreDuas() → GET /api/favorites?cursor=...
_FavPoemsList scroll near bottom
  → _loadMorePoems() → GET /api/poems/favorites?cursor=...
```

### Real-time Behavior (Favorites)

| Event | Behavior |
|---|---|
| Unfavorite (local tap) | `ActionType.bookmark` → `favoritedStates[id] == false` → remove from list ✅ |
| Unfavorite (other device via SignalR) | `ActionType.signalrBookmark` fires but favorites screen doesn't listen — **item stays in list** ❌ |
| Like/bookmark/view counts | ✅ Card handles it via own listener |
| Content edit | ✅ Card handles it |
| Profile update | ✅ Card handles it |

**Known gap:** SignalR-driven unfavorites from other devices don't remove items from the favorites list. Only local unfavorites do.

---

## 6. User Detail Screen (`/user/:userId`)

### Navigation Entry Points
- Tap avatar/username on any `DuaCard` or `PoemCard`
- Route: `/user/:userId` with `userDisplayName` as extra

### Widget Tree
```
UserDetailScreen
├── Back button
├── Profile Card
│   ├── AvatarWithBadge
│   ├── Full name
│   └── Tabs: [Details | Duas (N) | Poems (M)]
├── IndexedStack
│   ├── Details Tab
│   │   ├── Bio
│   │   ├── Role
│   │   ├── Member since
│   │   ├── Duas created / Poems created
│   │   └── BadgeGrid (if badges exist)
│   ├── _UserDuasList
│   └── _UserPoemsList
```

### Data Loading
```
UserDetailScreen.initState()
  → _loadData() — parallel:
      ├── GET /api/users/:userId          → UserModel profile
      ├── GET /api/users/:userId/stats    → UserStatsModel
      ├── GET /api/duas/user/:userId      → PagedResponse<DuaModel>
      └── GET /api/poems/user/:userId     → PagedResponse<PoemModel>
  → Maps profile data onto each dua/poem (userName, avatar, badge)
  → Joins SignalR groups for real-time updates
```

### Infinite Scroll
```
_UserDuasList scroll near bottom
  → _loadMoreDuas() → GET /api/duas/user/:userId?cursor=...
_UserPoemsList scroll near bottom
  → _loadMorePoems() → GET /api/poems/user/:userId?cursor=...
```

### Real-time Behavior (User Detail)

| Event | Behavior |
|---|---|
| Dua deleted | `DuaBloc.deleted` → `_userDuas.removeWhere()` ✅ |
| Poem deleted | `PoemBloc.deleted` → `_userPoems.removeWhere()` ✅ |
| Like/bookmark/view counts | ✅ Card handles it |
| Content edit | ✅ Card handles it |
| Profile update | ✅ Card handles it |

**Note:** User detail fetches data directly via repositories (not through blocs). It uses `setState` for state management locally.

---

## 7. Profile Screen (`/profile`)

### Widget Tree
```
ProfileScreen
├── AppBar "Profile" + NotificationBell
├── User info (avatar, name, email)
├── Edit profile button → dialog (name, bio, avatar picker, badge)
├── Stats (duas created, poems created, likes received, total views)
├── BadgeGrid (all earned badges)
├── Donation history (if any)
└── Logout button
```

### Data Loading
```
ProfileScreen.initState()
  → GET /api/users/:id/stats
  → Listen to SignalR: onBadgeAwarded / onBadgeRevoked → refresh stats
```

### Profile Edit
```
Edit dialog:
  → User updates name/bio/avatar/badge
  → PUT /api/users/me
  → On success: broadcast profile update via SignalR's ProfileHub
  → All connected clients receive update → DuaBloc/PoemBloc update card displays
```

---

## 8. Leaderboard Screen (`/leaderboard`)

### Widget Tree
```
LeaderboardScreen
├── Tab [Top Duas | Top Poems]
└── IndexedStack
    ├── List of top 10 duas (sorted by likes)
    └── List of top 10 poems (sorted by likes)
```

### Data Loading
```
LeaderboardScreen.initState()
  → GET /api/leaderboard?count=10
  → Subscribe to SignalR: onLeaderboardUpdated
     → Real-time replacement of entire list when leaderboard changes
```

---

## 9. Detail Screens (DuaDetailScreen / PoemDetailScreen)

### DuaDetailScreen Features
```
DuaDetailScreen(duaId, currentUser)
  → GET /api/duas/:id → load full dua
  → GET /api/duas/:id/reports → load reports
  → POST /api/duas/:id/view → record view
  → Join SignalR groups:
      - /hubs/dua-likes (real-time like count)
      - /hubs/dua-favorites (real-time bookmark count)
      - /hubs/dua-views (real-time view count)
      - /hubs/dua-reports (real-time report status)
  → Features:
      ├── Full dua display (Arabic, transliteration, translation)
      ├── Like / Unlike
      ├── Bookmark / Unbookmark
      ├── Edit (own content only) → PUT /api/duas/:id
      ├── Delete (own content only) → DELETE /api/duas/:id
      ├── Report → POST /api/duas/:id/reports
      ├── Revision system → POST /api/duas/:id/revisions
      └── View reports → ReportStatusSheet
```

### PoemDetailScreen Features
Same structure as DuaDetailScreen but for poems:
```
  → GET /api/poems/:id
  → GET /api/poems/:id/reports
  → POST /api/poems/:id/view
  → Join equivalent SignalR groups
```

---

## 10. Admin Screen (`/admin`)

### Widget Tree
```
AdminScreen (visible only if user.role == admin)
├── Dashboard stats
├── User management (list, change roles)
├── Pending revisions review → RevisionReviewScreen
└── Reports management
```

### Data Loading
```
AdminScreen
  → GET /api/admin/status
  → GET /api/admin/users?cursor=...
  → GET /api/admin/stats
  → GET /api/admin/revisions/pending
  
RevisionReviewScreen(revisionId, contentType, contentTitle)
  → Load revision details
  → PUT /api/dua-revisions/:id/review or /api/poem-revisions/:id/review
```

---

## 11. Caching Strategy Summary

### Layer-by-layer

| Layer | Caching | Scope | Cleared when |
|---|---|---|---|
| `DuaService` / `PoemService` (API) | None | — | — |
| `DuaRepository` / `PoemRepository` | None | — | — |
| `DuaFeedBloc` / `PoemFeedBloc` | In-memory sliding window (max 60) | Session | App killed |
| `HomeBloc` (my posts) | In-memory list | Session | App killed |
| `DuaBloc` / `PoemBloc` state | In-memory counts/maps | App lifetime (singleton) | App killed |
| Favorites / User Detail screens | In-memory local state | Screen lifetime | Screen disposed |
| Disk / local DB | **None** | — | — |

### What's Real-time (SignalR)

| Data | Home Feed | My Posts | Favorites | User Detail |
|---|---|---|---|---|
| Like count | ✅ | ✅ | ✅ | ✅ |
| Bookmark count | ✅ | ✅ | ✅ | ✅ |
| View count | ✅ | ✅ | ✅ | ✅ |
| Content edit | ✅ | ✅ | ✅ | ✅ |
| Profile update | ✅ | ✅ | ✅ | ✅ |
| New content | ❌ Pull refresh | ✅ SignalR | N/A | N/A |
| Deleted content | ❌ Pull refresh | ✅ SignalR | N/A | ✅ SignalR |
| Unfavorite (other device) | N/A | N/A | ❌ Not handled | N/A |

### What Requires Pull-to-Refresh
- New duas/poems appearing on Home feed
- Deleted duas/poems removed from Home feed

### Performance Design
- Max 60 rendered items at any time (sliding window with front/back trimming)
- Off-window items are `const SizedBox(height: 200)` — zero build cost
- `ScrollablePositionedList.builder` only builds visible + buffer widgets
- `totalLoadedDuas` counter grows unbounded but doesn't affect rendering (it's just an `int itemCount`)
- The `const` keyword on off-window spacers prevents unnecessary rebuilds

---

## 12. Complete Data Flow Diagram

```
User Interaction
       │
       ▼
┌──────────────────┐
│  Widget (Screen)  │
│  e.g., DuaCard    │
└────────┬─────────┘
         │ dispatch event
         ▼
┌──────────────────┐
│  Bloc (State Mgmt)│
│  e.g., DuaBloc    │
└────────┬─────────┘
         │ calls method
         ▼
┌──────────────────┐
│  Repository       │
│  e.g., DuaRepo    │
└────────┬─────────┘
         │ calls service
         ▼
┌──────────────────┐
│  Service (API)    │  ──── HTTP ────▶  .NET Web API
│  e.g., DuaService │  ◀─── JSON ────
└──────────────────┘
         │
         │ result returned
         ▼
┌──────────────────┐
│  Bloc             │
│  emits new state  │
└────────┬─────────┘
         │ state change
         ▼
┌──────────────────┐
│  Widget rebuilds  │
│  (BlocBuilder)    │
└──────────────────┘

Real-time path:
┌──────────────────┐      SignalR       ┌──────────────────┐
│  SignalR Hubs     │ ◀══════════════▶  │  SignalRService   │
│  (.NET backend)   │                   └────────┬─────────┘
└──────────────────┘                              │
                                                  │ stream event
                                                  ▼
                                          ┌──────────────────┐
                                          │  Bloc (add event) │
                                          │  e.g., DuaBloc    │
                                          │  .add(SignalR...) │
                                          └────────┬─────────┘
                                                   │
                                                   ▼
                                          ┌──────────────────┐
                                          │  Widget rebuilds  │
                                          └──────────────────┘
```

### SignalR Hub Connections

```
SignalRService connects to ALL hubs at app start:
  ┌─────────────────────────────────────────────────────┐
  │ HubRoute.values.map((route) => _connectHub(route)) │
  │                                                     │
  │ /hubs/dua-likes          → onLikesCountUpdated      │
  │ /hubs/dua-favorites      → onFavoritesCountUpdated  │
  │ /hubs/dua-views          → onViewsCountUpdated      │
  │ /hubs/dua-reports        → onReportsCountUpdated    │
  │ /hubs/notifications      → onNotificationReceived   │
  │ /hubs/leaderboard        → onLeaderboardUpdated     │
  │ /hubs/badges             → onBadgeAwarded           │
  │ /hubs/profile            → onProfileUpdated         │
  └─────────────────────────────────────────────────────┘
  
  DuaBloc subscribes to:
    → onLikesCountUpdated         → SignalRLikeCountUpdated
    → onFavoritesCountUpdated     → SignalRFavoritesCountUpdated
    → onViewsCountUpdated         → SignalRViewsCountUpdated
    → onReportsCountUpdated       → SignalRReportsCountUpdated
    → onDuaContentUpdated         → SignalRDuaContentUpdated
    → onDuaDeleted                → SignalRDuaDeleted
    → onDuaCreated                → SignalRDuaCreated
    → onProfileUpdated            → SignalRProfileUpdated
    → onNotificationReceived      → SignalRReportReturned (via notification)
  
  PoemBloc subscribes to:
    (same structure as DuaBloc but for poems)
```
